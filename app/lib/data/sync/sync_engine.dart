import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:himo_api/himo_api.dart';
import 'package:tonik_util/tonik_util.dart';

import 'package:app/data/auth_store.dart';
import 'package:app/data/database_helper.dart';
import 'himo_client.dart';
import 'sync_mappers.dart';

// Серверный контракт: docs/spec/hub/sync.md. Сеанс = push (батчами ≤100, фазы
// cables → cable_updates → tests) затем pull per team (cursor int, страницы
// пока has_more).
//
// Транспорт — сгенерированный SyncApi (himo_api): каждый запрос возвращает
// TonikResult<SyncPushResponse|SyncPullResponse>. HTTP-статусы (401/403/426) —
// это НЕ TonikError: они декодируются в TonikSuccess, чьё value — sealed-класс
// ответа (SyncPushResponse200/400/401/426, SyncPullResponse200/400/401/403/426).
// TonikError покрывает только транспорт/кодек (network/cancelled/decoding).
// Per-item результаты push живут внутри 200-ответа (PushCableResult/PushTestResult,
// ItemStatus accepted/rejected + ItemError.code).

/// Текущее состояние движка для UI.
enum SyncStatus { idle, syncing, needsAuth, appOutdated, error }

/// Неразрешённый конфликт атрибутов кабеля (sync.md §4): сервер отклонил
/// правку с `version_conflict` и вернул актуальный кабель. Пользователь
/// выбирает версию Hub или свою.
class CableConflict {
  final String cableId;
  final int localVersion; // version, от которой сделана локальная правка
  final Cable serverCable; // актуальный кабель из ответа

  const CableConflict({
    required this.cableId,
    required this.localVersion,
    required this.serverCable,
  });
}

/// Итог сеанса синхронизации.
class SyncOutcome {
  int cablesPushed = 0;
  int updatesPushed = 0;
  int testsPushed = 0;
  int cablesPulled = 0;
  int testsPulled = 0;
  int deletedCables = 0;
  final List<String> errors = [];
  final List<String> noAccessTeamIds = []; // команды с потерей доступа (§5.6)
  final List<CableConflict> conflicts = []; // version_conflict (§4)
  bool appOutdated = false;
  bool authRequired = false;

  /// Ошибка уровня запроса (сеть/кодек/400) — прерывает сеанс, в отличие от
  /// per-item ошибок в [errors], которые не останавливают обработку батча.
  String? requestError;

  bool get ok =>
      errors.isEmpty &&
      !authRequired &&
      !appOutdated &&
      conflicts.isEmpty &&
      noAccessTeamIds.isEmpty &&
      requestError == null;

  @override
  String toString() {
    return 'SyncOutcome(pushed: ${cablesPushed}c/${updatesPushed}u/${testsPushed}t, '
        'pulled: ${cablesPulled}c/${testsPulled}t, deleted: $deletedCables, '
        'errors: ${errors.length}, conflicts: ${conflicts.length}, '
        'noAccess: ${noAccessTeamIds.length})';
  }
}

/// Синглтон-движок синхронизации с Himo Hub.
///
/// Порядок сеанса (sync.md §7): push первым, потом pull по каждой команде с
/// отслеживаемыми кабелями. Свои только что выгруженные тесты вернутся в pull
/// ещё раз — запись поверх по id ничего не ломает (§5.4).
class HimoSync {
  static final HimoSync _instance = HimoSync._internal();
  factory HimoSync() => _instance;
  HimoSync._internal();

  static const int _maxItemsPerBatch = 100; // sync.md §3.1

  final HimoClient _client = HimoClient();
  final AuthStore _auth = AuthStore();
  final DatabaseHelper _db = DatabaseHelper();

  /// Состояние для подписки UI.
  final ValueNotifier<SyncStatus> status = ValueNotifier(SyncStatus.idle);
  final ValueNotifier<DateTime?> lastSyncAt = ValueNotifier(null);
  final ValueNotifier<String?> lastError = ValueNotifier(null);
  final ValueNotifier<List<CableConflict>> conflicts = ValueNotifier(const []);
  final ValueNotifier<SyncOutcome?> lastOutcome = ValueNotifier(null);

  bool _running = false;
  bool get isRunning => _running;

  /// Полный сеанс: push всех накопленных объектов, затем pull по командам.
  Future<SyncOutcome> run() async {
    if (_running) {
      final out = SyncOutcome();
      out.errors.add('Синхронизация уже идёт');
      return out;
    }
    _running = true;
    status.value = SyncStatus.syncing;
    lastError.value = null;
    final out = SyncOutcome();

    if (!_client.configured) {
      out.errors.add(
        'HIMO_API_BASE_URL не задан (--dart-define-from-file=config/dev.json)',
      );
      _finish(SyncStatus.error, out.errors.first, out);
      _running = false;
      return out;
    }
    await _auth.load();
    if (!_auth.isLoggedIn) {
      out.authRequired = true;
      _finish(SyncStatus.needsAuth, 'Требуется вход', out);
      _running = false;
      return out;
    }

    try {
      await _pushAll(out); // §7: push первым
      if (!_stop(out)) {
        await _pullAll(out); // потом pull per team
      }
      if (out.authRequired) {
        _finish(SyncStatus.needsAuth, 'Сеанс истёк', out);
      } else if (out.appOutdated) {
        _finish(SyncStatus.appOutdated, 'Приложение устарело', out);
      } else if (out.requestError != null) {
        _finish(SyncStatus.error, out.requestError!, out);
      } else {
        _finish(SyncStatus.idle, null, out);
      }
    } catch (e) {
      out.errors.add('Синхронизация прервана: $e');
      _finish(SyncStatus.error, out.errors.last, out);
    } finally {
      _running = false;
    }
    return out;
  }

  void _finish(SyncStatus s, String? err, SyncOutcome out) {
    status.value = s;
    if (s == SyncStatus.idle) lastSyncAt.value = DateTime.now();
    if (err != null) lastError.value = err;
    conflicts.value = List.unmodifiable(out.conflicts);
    lastOutcome.value = out;
  }

  bool _stop(SyncOutcome out) =>
      out.authRequired || out.appOutdated || out.requestError != null;

  // ---------- PUSH ----------

  Future<void> _pushAll(SyncOutcome out) async {
    // §3.1: сначала все новые кабели, потом правки, потом тесты — чтобы тест
    // не ушёл раньше своего кабеля. Сервер внутри пакета тоже держит порядок.
    await _pushNewCables(out);
    if (_stop(out)) return;
    await _pushUpdates(out);
    if (_stop(out)) return;
    await _pushTests(out);
  }

  Future<void> _pushNewCables(SyncOutcome out) async {
    final rows = await _db.getNewCablesForPush();
    if (rows.isEmpty) return;
    for (int i = 0; i < rows.length; i += _maxItemsPerBatch) {
      if (_stop(out)) return;
      final slice = rows.sublist(i, min(i + _maxItemsPerBatch, rows.length));
      final res = await _client.syncApi.syncPush(
        body: PushRequest(
          cables: slice
              .map((r) => cableRowToNewCable(r, r['team_id'] as String))
              .toList(),
          cableUpdates: const [],
          tests: const [],
        ),
      );
      switch (res) {
        case TonikSuccess(:final value):
          switch (value) {
            case SyncPushResponse200(:final body):
              for (final r in body.cables) {
                await _applyCablePushResult(
                  r,
                  out,
                  isNew: true,
                  localVersion: 0,
                );
              }
            case SyncPushResponse400(:final body):
              out.requestError = 'Push: ${body.code}';
            case SyncPushResponse401():
              out.authRequired = true;
            case SyncPushResponse426():
              out.appOutdated = true;
          }
        case TonikError():
          out.requestError = 'Нет связи с сервером';
      }
    }
  }

  Future<void> _pushUpdates(SyncOutcome out) async {
    final rows = await _db.getDirtyCableUpdates();
    if (rows.isEmpty) return;
    final items = rows.map(cableRowToUpdateItem).toList();
    for (int i = 0; i < items.length; i += _maxItemsPerBatch) {
      if (_stop(out)) return;
      final slice = items.sublist(i, min(i + _maxItemsPerBatch, items.length));
      // id кабеля → локальная version (база правки) для конфликт-тайла.
      final byId = {
        for (final it in slice)
          it.cableUpdateItemModel.id: it.cableUpdate.version,
      };
      final res = await _client.syncApi.syncPush(
        body: PushRequest(
          cables: const [],
          cableUpdates: slice,
          tests: const [],
        ),
      );
      switch (res) {
        case TonikSuccess(:final value):
          switch (value) {
            case SyncPushResponse200(:final body):
              for (final r in body.cableUpdates) {
                await _applyCablePushResult(
                  r,
                  out,
                  isNew: false,
                  localVersion: byId[r.id] ?? 0,
                );
              }
            case SyncPushResponse400(:final body):
              out.requestError = 'Push: ${body.code}';
            case SyncPushResponse401():
              out.authRequired = true;
            case SyncPushResponse426():
              out.appOutdated = true;
          }
        case TonikError():
          out.requestError = 'Нет связи с сервером';
      }
    }
  }

  Future<void> _pushTests(SyncOutcome out) async {
    final rows = await _db.getUnsyncedTestsForPush();
    if (rows.isEmpty) return;
    final items = <NewTest>[];
    for (final s in rows) {
      if (_stop(out)) return;
      items.add(await _sessionRowToNewTest(s));
    }
    for (int i = 0; i < items.length; i += _maxItemsPerBatch) {
      if (_stop(out)) return;
      final slice = items.sublist(i, min(i + _maxItemsPerBatch, items.length));
      final res = await _client.syncApi.syncPush(
        body: PushRequest(
          cables: const [],
          cableUpdates: const [],
          tests: slice,
        ),
      );
      switch (res) {
        case TonikSuccess(:final value):
          switch (value) {
            case SyncPushResponse200(:final body):
              for (final r in body.tests) {
                await _applyTestPushResult(r, out);
              }
            case SyncPushResponse400(:final body):
              out.requestError = 'Push: ${body.code}';
            case SyncPushResponse401():
              out.authRequired = true;
            case SyncPushResponse426():
              out.appOutdated = true;
          }
        case TonikError():
          out.requestError = 'Нет связи с сервером';
      }
    }
  }

  Future<NewTest> _sessionRowToNewTest(Map<String, dynamic> row) async {
    final res = await _db.getTestResults(row['id'] as String);
    return testSessionRowToNewTest(
      session: row,
      continuityRow: res.continuity,
      cmrrRow: res.cmrr,
      freqRow: res.freq,
      appVersion: _client.appVersion,
    );
  }

  Future<void> _applyCablePushResult(
    PushCableResult r,
    SyncOutcome out, {
    required bool isNew,
    required int localVersion,
  }) async {
    if (r.status == ItemStatus.accepted) {
      final v = r.cable?.version ?? 0;
      if (isNew) {
        await _db.markCableSynced(r.id, v);
        out.cablesPushed++;
      } else {
        await _db.markCableUpdateSynced(r.id, v);
        out.updatesPushed++;
      }
      return;
    }
    // rejected — причина в ItemError.code (свободная строка).
    final code = r.error?.code ?? '';
    final detail = r.error?.detail;
    switch (code) {
      case 'version_conflict':
        // §4: сервер вернул актуальный кабель. Конфликт — пользователю.
        if (r.cable != null) {
          out.conflicts.add(
            CableConflict(
              cableId: r.id,
              localVersion: localVersion,
              serverCable: r.cable!,
            ),
          );
        } else {
          out.errors.add(
            'Кабель ${r.id}: version_conflict без актуального состояния',
          );
        }
      case 'cable_not_found':
        // synced=1 → кабель удалён в Hub (§5.5); synced=0 → ошибка приложения.
        await _db.untrackCable(r.id);
        out.deletedCables++;
      case 'cable_archived':
        out.errors.add('Кабель ${r.id} в архиве, правка не принята');
      case 'cable_type_locked':
        out.errors.add('Кабель ${r.id}: тип заблокирован (есть тесты)');
      case 'not_a_member':
        // Ответственный не в команде — сбросить (§3.4).
        await _db.updateCable(r.id, {'assignee_id': null});
        out.errors.add('Кабель ${r.id}: ответственный не в команде, сброшен');
      default:
        out.errors.add(
          'Кабель ${r.id}: $code${detail != null ? ' — $detail' : ''}',
        );
    }
  }

  Future<void> _applyTestPushResult(PushTestResult r, SyncOutcome out) async {
    if (r.status == ItemStatus.accepted) {
      await _db.markTestSynced(r.id);
      out.testsPushed++;
      return;
    }
    final code = r.error?.code ?? '';
    final detail = r.error?.detail;
    switch (code) {
      case 'cable_not_found':
        // Кабель удалён в Hub — следующий pull вернёт его в deleted_cables.
        out.errors.add('Тест ${r.id}: кабель не найден в Hub');
      case 'cable_archived':
        out.errors.add('Тест ${r.id}: кабель в архиве');
      case 'id_conflict':
        out.errors.add('Тест ${r.id}: конфликт ID (другое содержимое)');
      default:
        out.errors.add(
          'Тест ${r.id}: $code${detail != null ? ' — $detail' : ''}',
        );
    }
  }

  // ---------- PULL ----------

  Future<void> _pullAll(SyncOutcome out) async {
    final teamIds = await _db.getTrackedTeamIds();
    for (final teamId in teamIds) {
      if (_stop(out)) break;
      // 403 (no_team_access) для одной команды не роняет остальные (§5.6).
      await _pullTeam(teamId, out);
    }
  }

  Future<void> _pullTeam(String teamId, SyncOutcome out) async {
    final tracked = await _db.getTrackedCableIds(teamId);
    if (tracked.isEmpty) return;
    var cursor = await _db.getCursor(teamId);
    var stop = false;
    while (!stop) {
      final res = await _client.syncApi.syncPull(
        body: PullRequest(teamId: teamId, cursor: cursor, cables: tracked),
      );
      switch (res) {
        case TonikSuccess(:final value):
          switch (value) {
            case SyncPullResponse200(:final body):
              for (final c in body.cables) {
                await _db.upsertCableFromPull(cableToRow(c));
                out.cablesPulled++;
              }
              for (final t in body.tests) {
                final r = testToRows(t);
                await _db.upsertTestFromPull(
                  r.session,
                  r.continuity,
                  r.cmrr,
                  r.freq,
                );
                out.testsPulled++;
              }
              for (final id in body.deletedCables) {
                await _db.untrackCable(id);
                out.deletedCables++;
              }
              // §5.4: применять страницу, затем сохранять курсор — порядок
              // обеспечивает идемпотентность при обрыве (upsert по id).
              cursor = body.cursor;
              if (!body.hasMore) {
                stop = true;
                await _db.saveCursor(teamId, cursor, 'ok');
              }
            case SyncPullResponse400(:final body):
              out.errors.add('Pull $teamId: ${body.code}');
              stop = true;
            case SyncPullResponse401():
              out.authRequired = true;
              stop = true;
            case SyncPullResponse403():
              out.noAccessTeamIds.add(teamId);
              out.errors.add('Команда $teamId: нет доступа');
              stop = true;
            case SyncPullResponse426():
              out.appOutdated = true;
              stop = true;
          }
        case TonikError():
          out.errors.add('Команда $teamId: нет связи с сервером');
          stop = true;
      }
    }
  }

  // ---------- первая загрузка / выгрузка ----------

  /// Первая загрузка кабеля из каталога команды (sync.md §6). Pull с cursor=0
  /// по одному кабелю; курсор команды не сдвигается, если уже есть (§6.1).
  Future<SyncOutcome> loadCableFromCatalog(
    String teamId,
    String cableId,
  ) async {
    final out = SyncOutcome();
    if (!_client.configured) {
      out.errors.add('HIMO_API_BASE_URL не задан');
      _finish(SyncStatus.error, out.errors.first, out);
      return out;
    }
    await _auth.load();
    if (!_auth.isLoggedIn) {
      out.authRequired = true;
      _finish(SyncStatus.needsAuth, 'Требуется вход', out);
      return out;
    }
    // Эвристика §6.1: cursor=0 считаем «курсора нет». Для команды с реальным
    // cursor=0 это даёт лишний сдвиг, но безвредно — повторно полученные
    // изменения записываются поверх по id.
    final hadCursor = await _db.getCursor(teamId) > 0;
    var cursor = 0;
    var stop = false;
    while (!stop) {
      final res = await _client.syncApi.syncPull(
        body: PullRequest(teamId: teamId, cursor: cursor, cables: [cableId]),
      );
      switch (res) {
        case TonikSuccess(:final value):
          switch (value) {
            case SyncPullResponse200(:final body):
              for (final c in body.cables) {
                await _db.upsertCableFromPull(cableToRow(c));
                out.cablesPulled++;
              }
              for (final t in body.tests) {
                final r = testToRows(t);
                await _db.upsertTestFromPull(
                  r.session,
                  r.continuity,
                  r.cmrr,
                  r.freq,
                );
                out.testsPulled++;
              }
              cursor = body.cursor;
              if (!body.hasMore) {
                stop = true;
                if (!hadCursor) await _db.saveCursor(teamId, cursor, 'ok');
              }
            case SyncPullResponse400(:final body):
              out.errors.add('Pull: ${body.code}');
              stop = true;
            case SyncPullResponse401():
              out.authRequired = true;
              stop = true;
            case SyncPullResponse403():
              out.noAccessTeamIds.add(teamId);
              out.errors.add('Команда $teamId: нет доступа');
              stop = true;
            case SyncPullResponse426():
              out.appOutdated = true;
              stop = true;
          }
        case TonikError():
          out.errors.add('Нет связи с сервером');
          stop = true;
      }
    }
    if (out.authRequired) {
      _finish(SyncStatus.needsAuth, 'Требуется вход', out);
    } else if (out.appOutdated) {
      _finish(SyncStatus.appOutdated, 'Приложение устарело', out);
    } else if (out.errors.isNotEmpty) {
      _finish(SyncStatus.error, out.errors.first, out);
    } else {
      _finish(SyncStatus.idle, null, out);
    }
    return out;
  }

  /// Назначить кабель в команду и выгрузить (sync.md §3.1, секция cables).
  /// После этого кабель становится отслеживаемым и попадает в pull команды.
  Future<SyncOutcome> uploadCableToTeam(String cableId, String teamId) async {
    await _db.updateCable(cableId, {'team_id': teamId});
    return run();
  }

  // ---------- разрешение конфликтов (§4) ----------

  /// Принять версию Hub: перезаписать локальные атрибуты, dirty=0.
  Future<void> resolveConflictWithServer(String cableId) async {
    final conflict = _findConflict(cableId);
    if (conflict == null) return;
    await _db.applyServerCableVersion(cableToRow(conflict.serverCable));
    _removeConflict(cableId);
  }

  /// Оставить свою версию: взять version из ответа как базу, dirty=1 — правка
  /// уйдёт со следующим push как обычная (§4).
  Future<void> resolveConflictWithLocal(String cableId) async {
    final conflict = _findConflict(cableId);
    if (conflict == null) return;
    await _db.keepLocalCableVersion(cableId, conflict.serverCable.version);
    _removeConflict(cableId);
  }

  CableConflict? _findConflict(String id) {
    for (final c in conflicts.value) {
      if (c.cableId == id) return c;
    }
    return null;
  }

  void _removeConflict(String id) {
    conflicts.value = List.unmodifiable(
      conflicts.value.where((c) => c.cableId != id),
    );
    final lo = lastOutcome.value;
    if (lo != null) {
      lo.conflicts.removeWhere((c) => c.cableId == id);
    }
  }
}
