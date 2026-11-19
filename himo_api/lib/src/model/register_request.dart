// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/client_type.dart' as _i4;
import 'package:himo_api/src/model/nickname.dart' as _i5;
import 'package:himo_api/src/model/password.dart' as _i6;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class RegisterRequest implements _i1.ParameterEncodable, _i1.UriEncodable {
  const RegisterRequest({
    required this.nickname,
    required this.password,
    required this.client,
  });

  factory RegisterRequest.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'nickname', r'password', r'client'},
      listKeys: {},
      context: r'RegisterRequest',
    );
    return RegisterRequest(
      nickname: _$values[r'nickname'].decodeSimpleString(
        context: r'RegisterRequest.nickname',
      ),
      password: _$values[r'password'].decodeSimpleString(
        context: r'RegisterRequest.password',
      ),
      client: _i4.ClientType.fromSimple(_$values[r'client'], explode: explode),
    );
  }

  factory RegisterRequest.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'RegisterRequest');
    return RegisterRequest(
      nickname: _$map[r'nickname'].decodeJsonString(
        context: r'RegisterRequest.nickname',
      ),
      password: _$map[r'password'].decodeJsonString(
        context: r'RegisterRequest.password',
      ),
      client: _i4.ClientType.fromJson(_$map[r'client']),
    );
  }

  factory RegisterRequest.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'nickname', r'password', r'client'},
      listKeys: {},
      context: r'RegisterRequest',
    );
    return RegisterRequest(
      nickname: _$values[r'nickname'].decodeFormString(
        context: r'RegisterRequest.nickname',
      ),
      password: _$values[r'password'].decodeFormString(
        context: r'RegisterRequest.password',
      ),
      client: _i4.ClientType.fromForm(_$values[r'client'], explode: explode),
    );
  }

  final _i5.Nickname nickname;

  final _i6.Password password;

  final _i4.ClientType client;

  @_i3.override
  _i3.Object? toJson() => {
    r'nickname': nickname,
    r'password': password,
    r'client': client.toJson(),
  };

  $$RegisterRequestCopyWith<RegisterRequest> get copyWith =>
      _RegisterRequestCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RegisterRequest &&
        other.nickname == this.nickname &&
        other.password == this.password &&
        other.client == this.client;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([nickname, password, client]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'nickname'] = _i1.PropertyValue.scalar(nickname);
    _$result[r'password'] = _i1.PropertyValue.scalar(password);
    _$result[r'client'] = _i1.PropertyValue.scalar(client.toJson());
    return _$result;
  }

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
      r'Cannot uriEncode RegisterRequest: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$RegisterRequestCopyWith<$Res> {
  factory $$RegisterRequestCopyWith(RegisterRequest value) =
      _RegisterRequestCopyWith<$Res>;

  $Res call({
    _i5.Nickname? nickname,
    _i6.Password? password,
    _i4.ClientType? client,
  });
  _i5.Nickname get nickname;
  _i6.Password get password;
  _i4.ClientType get client;
}

class _RegisterRequestCopyWith<$Res>
    implements $$RegisterRequestCopyWith<$Res> {
  _RegisterRequestCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final RegisterRequest _value;

  @_i3.override
  _i5.Nickname get nickname => _value.nickname;

  @_i3.override
  _i6.Password get password => _value.password;

  @_i3.override
  _i4.ClientType get client => _value.client;

  @_i3.override
  $Res call({
    _i3.Object? nickname = _sentinel,
    _i3.Object? password = _sentinel,
    _i3.Object? client = _sentinel,
  }) {
    return (RegisterRequest(
      nickname: _i3.identical(nickname, _sentinel)
          ? this.nickname
          : (nickname as _i5.Nickname),
      password: _i3.identical(password, _sentinel)
          ? this.password
          : (password as _i6.Password),
      client: _i3.identical(client, _sentinel)
          ? this.client
          : (client as _i4.ClientType),
    ) as $Res);
  }
}
