import 'dart:convert';

import 'package:himo_api/himo_api.dart';

// Мапперы между строками локальной sqflite-схемы (Map<String,dynamic>) и
// моделями сгенерированного клиента `himo_api` (контракт `contracts/openapi.yaml`).
// Изолированы сюда, чтобы при перегенерации `himo_api` менялся только этот файл
// и `sync_engine.dart`.
//
// Ключевые конверсии:
//   - время: локально epoch-секунды (INTEGER), у himo_api — DateTime;
//   - cable_type: локально строка ("xlr"/"jack_trs"/"jack_ts"), у himo_api —
//     enum CableType (toJson()/fromJson() совпадают с этими строками);
//   - проводники: локально JSON-массив [{name,r,s}], у himo_api — поимённо
//     ContinuityConductorsModel {tip,ring,sleeve,pin1,pin2,pin3};
//   - cmrr: локально value_db, у himo_api cmrrDb;
//   - freq: локально points (JSON-массив чисел), у himo_api v (List<num>);
//     частоты f добавляет сервер — при отправке не шлём.

/// epoch-секунды → UTC DateTime.
DateTime epochSecondsToDateTime(int seconds) =>
    DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);

/// DateTime → epoch-секунды.
int dateTimeToEpochSeconds(DateTime t) =>
    t.toUtc().millisecondsSinceEpoch ~/ 1000;

// ---------- push: локальная строка → модель himo_api ----------

/// Новый кабель для push: берём строку cables и team_id, выбранный пользователем.
NewCable cableRowToNewCable(Map<String, dynamic> row, String teamId) {
  return NewCable(
    id: row['id'] as String,
    teamId: teamId,
    name: row['name'] as String,
    cableType: _cableType(row['cable_type'] as String),
    color: row['color'] as String,
    note: row['note'] as String?, // CableNote = String?
    createdAt: epochSecondsToDateTime((row['created_at'] as num).toInt()),
  );
}

/// Правка кабеля для push: локальная version + изменённые атрибуты.
/// allOf-композит CableUpdateItem = {cableUpdate, cableUpdateItemModel(id)}.
CableUpdateItem cableRowToUpdateItem(Map<String, dynamic> row) {
  return CableUpdateItem(
    cableUpdate: CableUpdate(
      version: (row['version'] as num?)?.toInt() ?? 0,
      name: row['name'] as String,
      cableType: _cableType(row['cable_type'] as String),
      color: row['color'] as String,
      note: row['note'] as String?,
      assigneeId: _assigneeIdWrapper(row['assignee_id'] as String?),
    ),
    cableUpdateItemModel: CableUpdateItemModel(id: row['id'] as String),
  );
}

/// Тест для push. [appVersion] — из PackageInfo (HimoClient.appVersion).
/// firmware_version локально не хранится — null.
NewTest testSessionRowToNewTest({
  required Map<String, dynamic> session,
  required Map<String, dynamic>? continuityRow,
  required Map<String, dynamic>? cmrrRow,
  required Map<String, dynamic>? freqRow,
  required String appVersion,
}) {
  final rulesVersion = session['rules_version'] as String? ?? '0.1';
  final startedAt = (session['started_at'] as num).toInt();

  Continuity? continuity;
  if (continuityRow != null) {
    continuity = Continuity(
      status: ContinuityStatusModel.fromJson(continuityRow['status']),
      conductors: _conductorsJsonToModel(continuityRow['conductors'] as String),
    );
  }
  Cmrr? cmrr;
  if (cmrrRow != null) {
    cmrr = Cmrr(
      cmrrDb: cmrrRow['value_db'] as num,
      status: CmrrStatusModel.fromJson(cmrrRow['status']),
    );
  }
  FreqResponse? freq;
  if (freqRow != null) {
    freq = FreqResponse(
      status: FreqResponseStatusModel.fromJson(freqRow['status']),
      v: _freqPointsToList(freqRow['points'] as String),
    );
  }

  // allOf-композит NewTest = {testMeta, newTestModel(id, cable_id)}.
  return NewTest(
    testMeta: TestMeta(
      measuredAt: epochSecondsToDateTime(startedAt),
      deviceId: session['ble_device_id'] as String,
      pv: (session['pv'] as num?)?.toInt() ?? 1,
      appVersion: appVersion,
      rulesVersion: rulesVersion,
      firmwareVersion: null,
      healthScore: session['health_score'] as int?,
      healthIncomplete: (session['health_incomplete'] as num?)?.toInt() == 1,
      note: session['note'] as String?,
      results: TestResults(
        continuity: continuity,
        cmrr: cmrr,
        freqResponse: freq,
      ),
    ),
    newTestModel: NewTestModel(
      id: session['id'] as String,
      cableId: session['cable_id'] as String,
    ),
  );
}

// ---------- pull: модель himo_api → локальная строка ----------

/// Кабель с сервера → строка cables для upsert.
/// ВНИМАНИЕ: dirty локальной правки здесь не проставляется — вызывавший
/// DatabaseHelper.upsertCableFromPull решает, перезаписывать ли атрибуты
/// (sync.md §5.4: при dirty=true атрибуты и version не записываются).
Map<String, dynamic> cableToRow(Cable c) {
  return {
    'id': c.id,
    'team_id': c.teamId,
    'name': c.name,
    'color': c.color,
    'cable_type': c.cableType.toJson(),
    'note': c.note, // CableNote = String?
    'created_at': dateTimeToEpochSeconds(c.createdAt),
    'version': c.version,
    'synced': 1,
    'assignee_id': c.assignee?.userRef.id,
  };
}

/// Тест с сервера → набор строк для upsert (сессия + опциональные результаты).
/// Тесты неизменяемы: upsert по id перезаписывает. allOf-композит Test =
/// {testMeta(...), testModel(id, cable_id, author, received_at, ...)}.
TestRows testToRows(Test t) {
  final meta = t.testMeta;
  final model = t.testModel;
  final session = <String, dynamic>{
    'id': model.id,
    'cable_id': model.cableId,
    'started_at': dateTimeToEpochSeconds(meta.measuredAt),
    'health_score': meta.healthScore,
    'ble_device_id': meta.deviceId,
    'synced': 1,
    'pv': meta.pv,
    'rules_version': meta.rulesVersion,
    'health_incomplete': meta.healthIncomplete ? 1 : 0,
    'note': meta.note,
  };
  Map<String, dynamic>? continuity;
  if (meta.results.continuity != null) {
    final c = meta.results.continuity!;
    continuity = {
      'session_id': model.id,
      'status': c.status.toJson(),
      'conductors': _conductorsModelToJson(c.conductors),
    };
  }
  Map<String, dynamic>? cmrr;
  if (meta.results.cmrr != null) {
    final c = meta.results.cmrr!;
    cmrr = {
      'session_id': model.id,
      'value_db': c.cmrrDb,
      'status': c.status.toJson(),
    };
  }
  Map<String, dynamic>? freq;
  if (meta.results.freqResponse != null) {
    final f = meta.results.freqResponse!;
    freq = {
      'session_id': model.id,
      'status': f.status.toJson(),
      'points': jsonEncode(f.v),
    };
  }
  return TestRows(session, continuity, cmrr, freq);
}

/// Результат разбора теста с сервера в строки локальной БД.
class TestRows {
  final Map<String, dynamic> session;
  final Map<String, dynamic>? continuity;
  final Map<String, dynamic>? cmrr;
  final Map<String, dynamic>? freq;
  const TestRows(this.session, this.continuity, this.cmrr, this.freq);
}

// ---------- низкоуровневые конверсии ----------

CableType _cableType(String s) => switch (s) {
  'jack_ts' => CableType.jackTs,
  'jack_trs' => CableType.jackTrs,
  'xlr' => CableType.xlr,
  _ => CableType.xlr, // неизвестный тип не должен встречаться в БД
};

/// Обёртка assignee_id для CableUpdate: сериализуется как bare-строка (UUID).
/// `$RawCableUpdateAssigneeIdAllOfModel` — публичный allOf-класс из himo_api.
CableUpdateAssigneeIdAllOfModel _assigneeIdWrapper(String? id) {
  if (id == null || id.isEmpty) return null;
  return $RawCableUpdateAssigneeIdAllOfModel(uuid: id);
}

/// Локальный JSON проводников [{"name":"tip","r":0.1,"s":"ok"},...] → модель.
ContinuityConductorsModel _conductorsJsonToModel(String jsonStr) {
  final list = jsonDecode(jsonStr) as List;
  final byName = {for (final e in list) (e as Map)['name'] as String: e};
  Conductor? mk(String name) {
    final m = byName[name];
    if (m == null) return null;
    return Conductor(
      r: m['r'] as num, // num (int|double)
      s: ConductorStatus.fromJson(m['s']),
    );
  }

  return ContinuityConductorsModel(
    tip: mk('tip'),
    ring: mk('ring'),
    sleeve: mk('sleeve'),
    pin1: mk('pin1'),
    pin2: mk('pin2'),
    pin3: mk('pin3'),
  );
}

/// Модель проводников → локальный JSON-массив.
String _conductorsModelToJson(ContinuityConductorsModel m) {
  final list = <Map<String, dynamic>>[];
  void add(String name, Conductor? c) {
    if (c == null) return;
    list.add({'name': name, 'r': c.r, 's': c.s.toJson()});
  }

  add('tip', m.tip);
  add('ring', m.ring);
  add('sleeve', m.sleeve);
  add('pin1', m.pin1);
  add('pin2', m.pin2);
  add('pin3', m.pin3);
  return jsonEncode(list);
}

/// Локальный JSON точек АЧХ [1.2, 3.4, ...]
List<num> _freqPointsToList(String jsonStr) {
  final list = jsonDecode(jsonStr) as List;
  return list.map((e) => e as num).toList();
}
