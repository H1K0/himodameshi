// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/cable_assignee_all_of_model.dart' as _i5;
import 'package:himo_api/src/model/cable_name.dart' as _i8;
import 'package:himo_api/src/model/cable_note.dart' as _i10;
import 'package:himo_api/src/model/cable_type.dart' as _i4;
import 'package:himo_api/src/model/color.dart' as _i9;
import 'package:himo_api/src/model/user_ref.dart' as _i6;
import 'package:himo_api/src/model/uuid.dart' as _i7;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// **Example**:
/// ```json
/// {
///   "id": "0192f1a0-5c3e-7a21-9b4d-3e8f12a7c901",
///   "team_id": "0192e000-11aa-7b00-8c00-5d2e6f7a8b90",
///   "name": "XLR 5 м",
///   "cable_type": "xlr",
///   "color": "639922",
///   "note": null,
///   "assignee": {
///     "id": "0192d000-0000-7000-8000-000000000001",
///     "nickname": "vlad"
///   },
///   "created_by": {
///     "id": "0192d000-0000-7000-8000-000000000001",
///     "nickname": "vlad"
///   },
///   "created_at": "2026-10-18T14:02:11Z",
///   "updated_at": "2026-10-19T09:30:00Z",
///   "version": 2,
///   "archived_at": null,
///   "health_score": 92,
///   "last_test_at": "2026-10-19T09:12:45Z",
///   "test_count": 2
/// }
/// ```
@_i2.immutable
class Cable implements _i1.ParameterEncodable, _i1.UriEncodable {
  const Cable({
    required this.id,
    required this.teamId,
    required this.name,
    required this.cableType,
    required this.color,
    required this.note,
    required this.assignee,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.archivedAt,
    required this.healthScore,
    required this.lastTestAt,
    required this.testCount,
  });

  factory Cable.fromSimple(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for Cable: contains complex types',
    );
  }

  factory Cable.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Cable');
    return Cable(
      id: _$map[r'id'].decodeJsonString(context: r'Cable.id'),
      teamId: _$map[r'team_id'].decodeJsonString(context: r'Cable.team_id'),
      name: _$map[r'name'].decodeJsonString(context: r'Cable.name'),
      cableType: _i4.CableType.fromJson(_$map[r'cable_type']),
      color: _$map[r'color'].decodeJsonString(context: r'Cable.color'),
      note: _$map[r'note'].decodeJsonNullableString(context: r'Cable.note'),
      assignee: _$map[r'assignee'] == null
          ? null
          : _i5.CableAssigneeAllOfModel.fromJson(_$map[r'assignee']),
      createdBy: _i6.UserRef.fromJson(_$map[r'created_by']),
      createdAt: _$map[r'created_at'].decodeJsonDateTime(
        context: r'Cable.created_at',
      ),
      updatedAt: _$map[r'updated_at'].decodeJsonDateTime(
        context: r'Cable.updated_at',
      ),
      version: _$map[r'version'].decodeJsonInt(context: r'Cable.version'),
      archivedAt: _$map[r'archived_at'].decodeJsonNullableDateTime(
        context: r'Cable.archived_at',
      ),
      healthScore: _$map[r'health_score'].decodeJsonNullableInt(
        context: r'Cable.health_score',
      ),
      lastTestAt: _$map[r'last_test_at'].decodeJsonNullableDateTime(
        context: r'Cable.last_test_at',
      ),
      testCount: _$map[r'test_count'].decodeJsonInt(
        context: r'Cable.test_count',
      ),
    );
  }

  factory Cable.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for Cable: contains complex types',
    );
  }

  final _i7.Uuid id;

  final _i7.Uuid teamId;

  final _i8.CableName name;

  final _i4.CableType cableType;

  final _i9.Color color;

  final _i10.CableNote note;

  /// Ответственный или `null` — не назначен
  final _i5.CableAssigneeAllOfModel? assignee;

  final _i6.UserRef createdBy;

  /// Время создания в приложении
  final _i3.DateTime createdAt;

  final _i3.DateTime updatedAt;

  /// Версия записи для оптимистичной блокировки
  ///
  /// **Example**:
  /// ```json
  /// 3
  /// ```
  final _i3.int version;

  /// `null` — кабель не в архиве
  final _i3.DateTime? archivedAt;

  /// Health Score последнего действительного теста; `null` — действительных тестов нет
  ///
  /// **Example**:
  /// ```json
  /// 92
  /// ```
  final _i3.int? healthScore;

  /// Время измерения последнего теста
  final _i3.DateTime? lastTestAt;

  /// **Example**:
  /// ```json
  /// 14
  /// ```
  final _i3.int testCount;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': id,
    r'team_id': teamId,
    r'name': name,
    r'cable_type': cableType.toJson(),
    r'color': color,
    r'note': note,
    r'assignee': assignee?.toJson(),
    r'created_by': createdBy.toJson(),
    r'created_at': createdAt.toTimeZonedIso8601String(),
    r'updated_at': updatedAt.toTimeZonedIso8601String(),
    r'version': version,
    r'archived_at': archivedAt?.toTimeZonedIso8601String(),
    r'health_score': healthScore,
    r'last_test_at': lastTestAt?.toTimeZonedIso8601String(),
    r'test_count': testCount,
  };

  $$CableCopyWith<Cable> get copyWith => _CableCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is Cable &&
        other.id == this.id &&
        other.teamId == this.teamId &&
        other.name == this.name &&
        other.cableType == this.cableType &&
        other.color == this.color &&
        other.note == this.note &&
        other.assignee == this.assignee &&
        other.createdBy == this.createdBy &&
        other.createdAt == this.createdAt &&
        other.updatedAt == this.updatedAt &&
        other.version == this.version &&
        other.archivedAt == this.archivedAt &&
        other.healthScore == this.healthScore &&
        other.lastTestAt == this.lastTestAt &&
        other.testCount == this.testCount;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      id,
      teamId,
      name,
      cableType,
      color,
      note,
      assignee,
      createdBy,
      createdAt,
      updatedAt,
      version,
      archivedAt,
      healthScore,
      lastTestAt,
      testCount,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for Cable: contains complex types',
  );

  @_i3.override
  _i3.String toSimple({
    required _i3.bool explode,
    required _i3.bool allowEmpty,
    _i3.bool literal = false,
  }) {
    return parameterProperties(allowEmpty: allowEmpty)
        .toSimple(explode: explode, allowEmpty: allowEmpty, literal: literal);
  }

  @_i3.override
  _i3.List<_i1.ParameterEntry> toForm(
    _i3.String paramName, {
    required _i3.bool explode,
    required _i3.bool allowEmpty,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
    _i3.Map<_i3.String, _i1.FormFieldEncoding> fieldEncodings = const {},
  }) {
    return parameterProperties(allowEmpty: allowEmpty).toForm(
      paramName,
      explode: explode,
      allowEmpty: allowEmpty,
      useQueryComponent: useQueryComponent,
      allowReserved: allowReserved,
      fieldEncodings: fieldEncodings,
    );
  }

  @_i3.override
  _i3.String toLabel({
    required _i3.bool explode,
    required _i3.bool allowEmpty,
  }) {
    return parameterProperties(allowEmpty: allowEmpty)
        .toLabel(explode: explode, allowEmpty: allowEmpty);
  }

  @_i3.override
  _i3.String toMatrix(
    _i3.String paramName, {
    required _i3.bool explode,
    required _i3.bool allowEmpty,
  }) {
    return parameterProperties(allowEmpty: allowEmpty)
        .toMatrix(paramName, explode: explode, allowEmpty: allowEmpty);
  }

  @_i3.override
  _i3.List<_i1.ParameterEntry> toDeepObject(
    _i3.String paramName, {
    required _i3.bool explode,
    required _i3.bool allowEmpty,
    _i3.bool allowReserved = false,
  }) {
    return parameterProperties(allowEmpty: allowEmpty).toDeepObject(
      paramName,
      explode: explode,
      allowEmpty: allowEmpty,
      allowReserved: allowReserved,
    );
  }

  @_i3.override
  _i3.List<_i1.ParameterEntry> toPipeDelimited(
    _i3.String paramName, {
    required _i3.bool allowEmpty,
    _i3.bool allowReserved = false,
  }) {
    return parameterProperties(allowEmpty: allowEmpty).toPipeDelimited(
      paramName,
      allowEmpty: allowEmpty,
      allowReserved: allowReserved,
    );
  }

  @_i3.override
  _i3.List<_i1.ParameterEntry> toSpaceDelimited(
    _i3.String paramName, {
    required _i3.bool allowEmpty,
    _i3.bool allowReserved = false,
  }) {
    return parameterProperties(allowEmpty: allowEmpty).toSpaceDelimited(
      paramName,
      allowEmpty: allowEmpty,
      allowReserved: allowReserved,
    );
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode Cable: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$CableCopyWith<$Res> {
  factory $$CableCopyWith(Cable value) = _CableCopyWith<$Res>;

  $Res call({
    _i7.Uuid? id,
    _i7.Uuid? teamId,
    _i8.CableName? name,
    _i4.CableType? cableType,
    _i9.Color? color,
    _i10.CableNote? note,
    _i5.CableAssigneeAllOfModel? assignee,
    _i6.UserRef? createdBy,
    _i3.DateTime? createdAt,
    _i3.DateTime? updatedAt,
    _i3.int? version,
    _i3.DateTime? archivedAt,
    _i3.int? healthScore,
    _i3.DateTime? lastTestAt,
    _i3.int? testCount,
  });
  _i7.Uuid get id;
  _i7.Uuid get teamId;
  _i8.CableName get name;
  _i4.CableType get cableType;
  _i9.Color get color;
  _i10.CableNote get note;
  _i5.CableAssigneeAllOfModel? get assignee;
  _i6.UserRef get createdBy;
  _i3.DateTime get createdAt;
  _i3.DateTime get updatedAt;
  _i3.int get version;
  _i3.DateTime? get archivedAt;
  _i3.int? get healthScore;
  _i3.DateTime? get lastTestAt;
  _i3.int get testCount;
}

class _CableCopyWith<$Res> implements $$CableCopyWith<$Res> {
  _CableCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final Cable _value;

  @_i3.override
  _i7.Uuid get id => _value.id;

  @_i3.override
  _i7.Uuid get teamId => _value.teamId;

  @_i3.override
  _i8.CableName get name => _value.name;

  @_i3.override
  _i4.CableType get cableType => _value.cableType;

  @_i3.override
  _i9.Color get color => _value.color;

  @_i3.override
  _i10.CableNote get note => _value.note;

  @_i3.override
  _i5.CableAssigneeAllOfModel? get assignee => _value.assignee;

  @_i3.override
  _i6.UserRef get createdBy => _value.createdBy;

  @_i3.override
  _i3.DateTime get createdAt => _value.createdAt;

  @_i3.override
  _i3.DateTime get updatedAt => _value.updatedAt;

  @_i3.override
  _i3.int get version => _value.version;

  @_i3.override
  _i3.DateTime? get archivedAt => _value.archivedAt;

  @_i3.override
  _i3.int? get healthScore => _value.healthScore;

  @_i3.override
  _i3.DateTime? get lastTestAt => _value.lastTestAt;

  @_i3.override
  _i3.int get testCount => _value.testCount;

  @_i3.override
  $Res call({
    _i3.Object? id = _sentinel,
    _i3.Object? teamId = _sentinel,
    _i3.Object? name = _sentinel,
    _i3.Object? cableType = _sentinel,
    _i3.Object? color = _sentinel,
    _i3.Object? note = _sentinel,
    _i3.Object? assignee = _sentinel,
    _i3.Object? createdBy = _sentinel,
    _i3.Object? createdAt = _sentinel,
    _i3.Object? updatedAt = _sentinel,
    _i3.Object? version = _sentinel,
    _i3.Object? archivedAt = _sentinel,
    _i3.Object? healthScore = _sentinel,
    _i3.Object? lastTestAt = _sentinel,
    _i3.Object? testCount = _sentinel,
  }) {
    return (Cable(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i7.Uuid),
      teamId: _i3.identical(teamId, _sentinel)
          ? this.teamId
          : (teamId as _i7.Uuid),
      name: _i3.identical(name, _sentinel)
          ? this.name
          : (name as _i8.CableName),
      cableType: _i3.identical(cableType, _sentinel)
          ? this.cableType
          : (cableType as _i4.CableType),
      color: _i3.identical(color, _sentinel)
          ? this.color
          : (color as _i9.Color),
      note: _i3.identical(note, _sentinel)
          ? this.note
          : (note as _i10.CableNote),
      assignee: _i3.identical(assignee, _sentinel)
          ? this.assignee
          : (assignee as _i5.CableAssigneeAllOfModel?),
      createdBy: _i3.identical(createdBy, _sentinel)
          ? this.createdBy
          : (createdBy as _i6.UserRef),
      createdAt: _i3.identical(createdAt, _sentinel)
          ? this.createdAt
          : (createdAt as _i3.DateTime),
      updatedAt: _i3.identical(updatedAt, _sentinel)
          ? this.updatedAt
          : (updatedAt as _i3.DateTime),
      version: _i3.identical(version, _sentinel)
          ? this.version
          : (version as _i3.int),
      archivedAt: _i3.identical(archivedAt, _sentinel)
          ? this.archivedAt
          : (archivedAt as _i3.DateTime?),
      healthScore: _i3.identical(healthScore, _sentinel)
          ? this.healthScore
          : (healthScore as _i3.int?),
      lastTestAt: _i3.identical(lastTestAt, _sentinel)
          ? this.lastTestAt
          : (lastTestAt as _i3.DateTime?),
      testCount: _i3.identical(testCount, _sentinel)
          ? this.testCount
          : (testCount as _i3.int),
    ) as $Res);
  }
}
