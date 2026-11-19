// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/plan.dart' as _i5;
import 'package:himo_api/src/model/team_role.dart' as _i4;
import 'package:himo_api/src/model/uuid.dart' as _i6;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class Team implements _i1.ParameterEncodable, _i1.UriEncodable {
  const Team({
    required this.id,
    required this.name,
    required this.description,
    required this.isPersonal,
    required this.role,
    required this.plan,
    required this.memberCount,
    required this.createdAt,
    required this.deletedAt,
  });

  factory Team.fromSimple(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for Team: contains complex types',
    );
  }

  factory Team.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Team');
    return Team(
      id: _$map[r'id'].decodeJsonString(context: r'Team.id'),
      name: _$map[r'name'].decodeJsonString(context: r'Team.name'),
      description: _$map[r'description'].decodeJsonString(
        context: r'Team.description',
      ),
      isPersonal: _$map[r'is_personal'].decodeJsonBool(
        context: r'Team.is_personal',
      ),
      role: _i4.TeamRole.fromJson(_$map[r'role']),
      plan: _i5.Plan.fromJson(_$map[r'plan']),
      memberCount: _$map[r'member_count'].decodeJsonInt(
        context: r'Team.member_count',
      ),
      createdAt: _$map[r'created_at'].decodeJsonDateTime(
        context: r'Team.created_at',
      ),
      deletedAt: _$map[r'deleted_at'].decodeJsonNullableDateTime(
        context: r'Team.deleted_at',
      ),
    );
  }

  factory Team.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for Team: contains complex types',
    );
  }

  final _i6.Uuid id;

  /// **Example**:
  /// ```
  /// Студия «Подвал»
  /// ```
  final _i3.String name;

  /// **Example**:
  /// ```
  /// Кабельный парк репетиционной базы
  /// ```
  final _i3.String description;

  /// Личное пространство — команда из одного человека
  final _i3.bool isPersonal;

  final _i4.TeamRole role;

  final _i5.Plan plan;

  /// **Example**:
  /// ```json
  /// 3
  /// ```
  final _i3.int memberCount;

  final _i3.DateTime createdAt;

  /// Только в списке удалённых команд
  final _i3.DateTime? deletedAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': id,
    r'name': name,
    r'description': description,
    r'is_personal': isPersonal,
    r'role': role.toJson(),
    r'plan': plan.toJson(),
    r'member_count': memberCount,
    r'created_at': createdAt.toTimeZonedIso8601String(),
    r'deleted_at': deletedAt?.toTimeZonedIso8601String(),
  };

  $$TeamCopyWith<Team> get copyWith => _TeamCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is Team &&
        other.id == this.id &&
        other.name == this.name &&
        other.description == this.description &&
        other.isPersonal == this.isPersonal &&
        other.role == this.role &&
        other.plan == this.plan &&
        other.memberCount == this.memberCount &&
        other.createdAt == this.createdAt &&
        other.deletedAt == this.deletedAt;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      id,
      name,
      description,
      isPersonal,
      role,
      plan,
      memberCount,
      createdAt,
      deletedAt,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for Team: contains complex types',
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
      r'Cannot uriEncode Team: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$TeamCopyWith<$Res> {
  factory $$TeamCopyWith(Team value) = _TeamCopyWith<$Res>;

  $Res call({
    _i6.Uuid? id,
    _i3.String? name,
    _i3.String? description,
    _i3.bool? isPersonal,
    _i4.TeamRole? role,
    _i5.Plan? plan,
    _i3.int? memberCount,
    _i3.DateTime? createdAt,
    _i3.DateTime? deletedAt,
  });
  _i6.Uuid get id;
  _i3.String get name;
  _i3.String get description;
  _i3.bool get isPersonal;
  _i4.TeamRole get role;
  _i5.Plan get plan;
  _i3.int get memberCount;
  _i3.DateTime get createdAt;
  _i3.DateTime? get deletedAt;
}

class _TeamCopyWith<$Res> implements $$TeamCopyWith<$Res> {
  _TeamCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final Team _value;

  @_i3.override
  _i6.Uuid get id => _value.id;

  @_i3.override
  _i3.String get name => _value.name;

  @_i3.override
  _i3.String get description => _value.description;

  @_i3.override
  _i3.bool get isPersonal => _value.isPersonal;

  @_i3.override
  _i4.TeamRole get role => _value.role;

  @_i3.override
  _i5.Plan get plan => _value.plan;

  @_i3.override
  _i3.int get memberCount => _value.memberCount;

  @_i3.override
  _i3.DateTime get createdAt => _value.createdAt;

  @_i3.override
  _i3.DateTime? get deletedAt => _value.deletedAt;

  @_i3.override
  $Res call({
    _i3.Object? id = _sentinel,
    _i3.Object? name = _sentinel,
    _i3.Object? description = _sentinel,
    _i3.Object? isPersonal = _sentinel,
    _i3.Object? role = _sentinel,
    _i3.Object? plan = _sentinel,
    _i3.Object? memberCount = _sentinel,
    _i3.Object? createdAt = _sentinel,
    _i3.Object? deletedAt = _sentinel,
  }) {
    return (Team(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i6.Uuid),
      name: _i3.identical(name, _sentinel) ? this.name : (name as _i3.String),
      description: _i3.identical(description, _sentinel)
          ? this.description
          : (description as _i3.String),
      isPersonal: _i3.identical(isPersonal, _sentinel)
          ? this.isPersonal
          : (isPersonal as _i3.bool),
      role: _i3.identical(role, _sentinel) ? this.role : (role as _i4.TeamRole),
      plan: _i3.identical(plan, _sentinel) ? this.plan : (plan as _i5.Plan),
      memberCount: _i3.identical(memberCount, _sentinel)
          ? this.memberCount
          : (memberCount as _i3.int),
      createdAt: _i3.identical(createdAt, _sentinel)
          ? this.createdAt
          : (createdAt as _i3.DateTime),
      deletedAt: _i3.identical(deletedAt, _sentinel)
          ? this.deletedAt
          : (deletedAt as _i3.DateTime?),
    ) as $Res);
  }
}
