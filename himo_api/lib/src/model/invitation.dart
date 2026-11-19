// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/user_ref.dart' as _i4;
import 'package:himo_api/src/model/uuid.dart' as _i5;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class Invitation implements _i1.ParameterEncodable, _i1.UriEncodable {
  const Invitation({
    required this.id,
    required this.teamId,
    required this.createdBy,
    required this.createdAt,
    required this.expiresAt,
  });

  factory Invitation.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for Invitation: contains complex types',
    );
  }

  factory Invitation.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Invitation');
    return Invitation(
      id: _$map[r'id'].decodeJsonString(context: r'Invitation.id'),
      teamId: _$map[r'team_id'].decodeJsonString(
        context: r'Invitation.team_id',
      ),
      createdBy: _i4.UserRef.fromJson(_$map[r'created_by']),
      createdAt: _$map[r'created_at'].decodeJsonDateTime(
        context: r'Invitation.created_at',
      ),
      expiresAt: _$map[r'expires_at'].decodeJsonDateTime(
        context: r'Invitation.expires_at',
      ),
    );
  }

  factory Invitation.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for Invitation: contains complex types',
    );
  }

  final _i5.Uuid id;

  final _i5.Uuid teamId;

  final _i4.UserRef createdBy;

  final _i3.DateTime createdAt;

  final _i3.DateTime expiresAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': id,
    r'team_id': teamId,
    r'created_by': createdBy.toJson(),
    r'created_at': createdAt.toTimeZonedIso8601String(),
    r'expires_at': expiresAt.toTimeZonedIso8601String(),
  };

  $$InvitationCopyWith<Invitation> get copyWith => _InvitationCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is Invitation &&
        other.id == this.id &&
        other.teamId == this.teamId &&
        other.createdBy == this.createdBy &&
        other.createdAt == this.createdAt &&
        other.expiresAt == this.expiresAt;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([id, teamId, createdBy, createdAt, expiresAt]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for Invitation: contains complex types',
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
      r'Cannot uriEncode Invitation: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$InvitationCopyWith<$Res> {
  factory $$InvitationCopyWith(Invitation value) = _InvitationCopyWith<$Res>;

  $Res call({
    _i5.Uuid? id,
    _i5.Uuid? teamId,
    _i4.UserRef? createdBy,
    _i3.DateTime? createdAt,
    _i3.DateTime? expiresAt,
  });
  _i5.Uuid get id;
  _i5.Uuid get teamId;
  _i4.UserRef get createdBy;
  _i3.DateTime get createdAt;
  _i3.DateTime get expiresAt;
}

class _InvitationCopyWith<$Res> implements $$InvitationCopyWith<$Res> {
  _InvitationCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final Invitation _value;

  @_i3.override
  _i5.Uuid get id => _value.id;

  @_i3.override
  _i5.Uuid get teamId => _value.teamId;

  @_i3.override
  _i4.UserRef get createdBy => _value.createdBy;

  @_i3.override
  _i3.DateTime get createdAt => _value.createdAt;

  @_i3.override
  _i3.DateTime get expiresAt => _value.expiresAt;

  @_i3.override
  $Res call({
    _i3.Object? id = _sentinel,
    _i3.Object? teamId = _sentinel,
    _i3.Object? createdBy = _sentinel,
    _i3.Object? createdAt = _sentinel,
    _i3.Object? expiresAt = _sentinel,
  }) {
    return (Invitation(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i5.Uuid),
      teamId: _i3.identical(teamId, _sentinel)
          ? this.teamId
          : (teamId as _i5.Uuid),
      createdBy: _i3.identical(createdBy, _sentinel)
          ? this.createdBy
          : (createdBy as _i4.UserRef),
      createdAt: _i3.identical(createdAt, _sentinel)
          ? this.createdAt
          : (createdAt as _i3.DateTime),
      expiresAt: _i3.identical(expiresAt, _sentinel)
          ? this.expiresAt
          : (expiresAt as _i3.DateTime),
    ) as $Res);
  }
}
