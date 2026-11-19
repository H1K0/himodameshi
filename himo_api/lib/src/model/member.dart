// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/team_role.dart' as _i5;
import 'package:himo_api/src/model/user_ref.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class Member implements _i1.ParameterEncodable, _i1.UriEncodable {
  const Member({
    required this.user,
    required this.role,
    required this.joinedAt,
  });

  factory Member.fromSimple(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for Member: contains complex types',
    );
  }

  factory Member.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Member');
    return Member(
      user: _i4.UserRef.fromJson(_$map[r'user']),
      role: _i5.TeamRole.fromJson(_$map[r'role']),
      joinedAt: _$map[r'joined_at'].decodeJsonDateTime(
        context: r'Member.joined_at',
      ),
    );
  }

  factory Member.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for Member: contains complex types',
    );
  }

  final _i4.UserRef user;

  final _i5.TeamRole role;

  final _i3.DateTime joinedAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'user': user.toJson(),
    r'role': role.toJson(),
    r'joined_at': joinedAt.toTimeZonedIso8601String(),
  };

  $$MemberCopyWith<Member> get copyWith => _MemberCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is Member &&
        other.user == this.user &&
        other.role == this.role &&
        other.joinedAt == this.joinedAt;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([user, role, joinedAt]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for Member: contains complex types',
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
      r'Cannot uriEncode Member: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$MemberCopyWith<$Res> {
  factory $$MemberCopyWith(Member value) = _MemberCopyWith<$Res>;

  $Res call({_i4.UserRef? user, _i5.TeamRole? role, _i3.DateTime? joinedAt});
  _i4.UserRef get user;
  _i5.TeamRole get role;
  _i3.DateTime get joinedAt;
}

class _MemberCopyWith<$Res> implements $$MemberCopyWith<$Res> {
  _MemberCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final Member _value;

  @_i3.override
  _i4.UserRef get user => _value.user;

  @_i3.override
  _i5.TeamRole get role => _value.role;

  @_i3.override
  _i3.DateTime get joinedAt => _value.joinedAt;

  @_i3.override
  $Res call({
    _i3.Object? user = _sentinel,
    _i3.Object? role = _sentinel,
    _i3.Object? joinedAt = _sentinel,
  }) {
    return (Member(
      user: _i3.identical(user, _sentinel) ? this.user : (user as _i4.UserRef),
      role: _i3.identical(role, _sentinel) ? this.role : (role as _i5.TeamRole),
      joinedAt: _i3.identical(joinedAt, _sentinel)
          ? this.joinedAt
          : (joinedAt as _i3.DateTime),
    ) as $Res);
  }
}
