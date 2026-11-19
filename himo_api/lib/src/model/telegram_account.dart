// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class TelegramAccount implements _i1.ParameterEncodable, _i1.UriEncodable {
  const TelegramAccount({required this.id, required this.username});

  factory TelegramAccount.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'id', r'username'},
      listKeys: {},
      context: r'TelegramAccount',
    );
    return TelegramAccount(
      id: _$values[r'id'].decodeSimpleInt(context: r'TelegramAccount.id'),
      username: _$values[r'username'].decodeSimpleNullableString(
        context: r'TelegramAccount.username',
      ),
    );
  }

  factory TelegramAccount.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'TelegramAccount');
    return TelegramAccount(
      id: _$map[r'id'].decodeJsonInt(context: r'TelegramAccount.id'),
      username: _$map[r'username'].decodeJsonNullableString(
        context: r'TelegramAccount.username',
      ),
    );
  }

  factory TelegramAccount.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'id', r'username'},
      listKeys: {},
      context: r'TelegramAccount',
    );
    return TelegramAccount(
      id: _$values[r'id'].decodeFormInt(context: r'TelegramAccount.id'),
      username: _$values[r'username'].decodeFormNullableString(
        context: r'TelegramAccount.username',
      ),
    );
  }

  final _i3.int id;

  final _i3.String? username;

  @_i3.override
  _i3.Object? toJson() => {r'id': id, r'username': username};

  $$TelegramAccountCopyWith<TelegramAccount> get copyWith =>
      _TelegramAccountCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is TelegramAccount &&
        other.id == this.id &&
        other.username == this.username;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([id, username]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(id.toString());
    if (username != null) {
      _$result[r'username'] = _i1.PropertyValue.scalar(username!);
    }
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
      r'Cannot uriEncode TelegramAccount: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$TelegramAccountCopyWith<$Res> {
  factory $$TelegramAccountCopyWith(TelegramAccount value) =
      _TelegramAccountCopyWith<$Res>;

  $Res call({_i3.int? id, _i3.String? username});
  _i3.int get id;
  _i3.String? get username;
}

class _TelegramAccountCopyWith<$Res>
    implements $$TelegramAccountCopyWith<$Res> {
  _TelegramAccountCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final TelegramAccount _value;

  @_i3.override
  _i3.int get id => _value.id;

  @_i3.override
  _i3.String? get username => _value.username;

  @_i3.override
  $Res call({_i3.Object? id = _sentinel, _i3.Object? username = _sentinel}) {
    return (TelegramAccount(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i3.int),
      username: _i3.identical(username, _sentinel)
          ? this.username
          : (username as _i3.String?),
    ) as $Res);
  }
}
