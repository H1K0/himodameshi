// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/user.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class Session implements _i1.ParameterEncodable, _i1.UriEncodable {
  const Session({required this.user, required this.expiresAt, this.token});

  factory Session.fromSimple(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for Session: contains complex types',
    );
  }

  factory Session.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Session');
    return Session(
      user: _i4.User.fromJson(_$map[r'user']),
      token: _$map[r'token'].decodeJsonNullableString(
        context: r'Session.token',
      ),
      expiresAt: _$map[r'expires_at'].decodeJsonDateTime(
        context: r'Session.expires_at',
      ),
    );
  }

  factory Session.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for Session: contains complex types',
    );
  }

  final _i4.User user;

  /// Токен сеанса — только для `client: app`
  ///
  /// **Example**:
  /// ```
  /// session-token-example
  /// ```
  final _i3.String? token;

  /// Срок действия; продлевается при использовании
  final _i3.DateTime expiresAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'user': user.toJson(),
    if (token != null) r'token': token,
    r'expires_at': expiresAt.toTimeZonedIso8601String(),
  };

  $$SessionCopyWith<Session> get copyWith => _SessionCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is Session &&
        other.user == this.user &&
        other.token == this.token &&
        other.expiresAt == this.expiresAt;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([user, token, expiresAt]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for Session: contains complex types',
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
      r'Cannot uriEncode Session: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$SessionCopyWith<$Res> {
  factory $$SessionCopyWith(Session value) = _SessionCopyWith<$Res>;

  $Res call({_i4.User? user, _i3.String? token, _i3.DateTime? expiresAt});
  _i4.User get user;
  _i3.String? get token;
  _i3.DateTime get expiresAt;
}

class _SessionCopyWith<$Res> implements $$SessionCopyWith<$Res> {
  _SessionCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final Session _value;

  @_i3.override
  _i4.User get user => _value.user;

  @_i3.override
  _i3.String? get token => _value.token;

  @_i3.override
  _i3.DateTime get expiresAt => _value.expiresAt;

  @_i3.override
  $Res call({
    _i3.Object? user = _sentinel,
    _i3.Object? token = _sentinel,
    _i3.Object? expiresAt = _sentinel,
  }) {
    return (Session(
      user: _i3.identical(user, _sentinel) ? this.user : (user as _i4.User),
      token: _i3.identical(token, _sentinel)
          ? this.token
          : (token as _i3.String?),
      expiresAt: _i3.identical(expiresAt, _sentinel)
          ? this.expiresAt
          : (expiresAt as _i3.DateTime),
    ) as $Res);
  }
}
