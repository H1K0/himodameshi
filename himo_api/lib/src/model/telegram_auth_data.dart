// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// Объект от Telegram Login Widget — передаётся без изменений
@_i2.immutable
class TelegramAuthData implements _i1.ParameterEncodable, _i1.UriEncodable {
  const TelegramAuthData({
    required this.id,
    required this.firstName,
    required this.authDate,
    required this.hash,
    this.lastName,
    this.username,
    this.photoUrl,
  });

  factory TelegramAuthData.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {
        r'id',
        r'first_name',
        r'last_name',
        r'username',
        r'photo_url',
        r'auth_date',
        r'hash',
      },
      listKeys: {},
      context: r'TelegramAuthData',
    );
    return TelegramAuthData(
      id: _$values[r'id'].decodeSimpleInt(context: r'TelegramAuthData.id'),
      firstName: _$values[r'first_name'].decodeSimpleString(
        context: r'TelegramAuthData.first_name',
      ),
      lastName: _$values[r'last_name'].decodeSimpleNullableString(
        context: r'TelegramAuthData.last_name',
      ),
      username: _$values[r'username'].decodeSimpleNullableString(
        context: r'TelegramAuthData.username',
      ),
      photoUrl: _$values[r'photo_url'].decodeSimpleNullableString(
        context: r'TelegramAuthData.photo_url',
      ),
      authDate: _$values[r'auth_date'].decodeSimpleInt(
        context: r'TelegramAuthData.auth_date',
      ),
      hash: _$values[r'hash'].decodeSimpleString(
        context: r'TelegramAuthData.hash',
      ),
    );
  }

  factory TelegramAuthData.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'TelegramAuthData');
    return TelegramAuthData(
      id: _$map[r'id'].decodeJsonInt(context: r'TelegramAuthData.id'),
      firstName: _$map[r'first_name'].decodeJsonString(
        context: r'TelegramAuthData.first_name',
      ),
      lastName: _$map[r'last_name'].decodeJsonNullableString(
        context: r'TelegramAuthData.last_name',
      ),
      username: _$map[r'username'].decodeJsonNullableString(
        context: r'TelegramAuthData.username',
      ),
      photoUrl: _$map[r'photo_url'].decodeJsonNullableString(
        context: r'TelegramAuthData.photo_url',
      ),
      authDate: _$map[r'auth_date'].decodeJsonInt(
        context: r'TelegramAuthData.auth_date',
      ),
      hash: _$map[r'hash'].decodeJsonString(context: r'TelegramAuthData.hash'),
    );
  }

  factory TelegramAuthData.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'id',
        r'first_name',
        r'last_name',
        r'username',
        r'photo_url',
        r'auth_date',
        r'hash',
      },
      listKeys: {},
      context: r'TelegramAuthData',
    );
    return TelegramAuthData(
      id: _$values[r'id'].decodeFormInt(context: r'TelegramAuthData.id'),
      firstName: _$values[r'first_name'].decodeFormString(
        context: r'TelegramAuthData.first_name',
      ),
      lastName: _$values[r'last_name'].decodeFormNullableString(
        context: r'TelegramAuthData.last_name',
      ),
      username: _$values[r'username'].decodeFormNullableString(
        context: r'TelegramAuthData.username',
      ),
      photoUrl: _$values[r'photo_url'].decodeFormNullableString(
        context: r'TelegramAuthData.photo_url',
      ),
      authDate: _$values[r'auth_date'].decodeFormInt(
        context: r'TelegramAuthData.auth_date',
      ),
      hash: _$values[r'hash'].decodeFormString(
        context: r'TelegramAuthData.hash',
      ),
    );
  }

  /// **Example**:
  /// ```json
  /// 123456789
  /// ```
  final _i3.int id;

  final _i3.String firstName;

  final _i3.String? lastName;

  final _i3.String? username;

  final _i3.String? photoUrl;

  /// Unix-время авторизации в Telegram
  final _i3.int authDate;

  /// Подпись данных
  final _i3.String hash;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': id,
    r'first_name': firstName,
    if (lastName != null) r'last_name': lastName,
    if (username != null) r'username': username,
    if (photoUrl != null) r'photo_url': photoUrl,
    r'auth_date': authDate,
    r'hash': hash,
  };

  $$TelegramAuthDataCopyWith<TelegramAuthData> get copyWith =>
      _TelegramAuthDataCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is TelegramAuthData &&
        other.id == this.id &&
        other.firstName == this.firstName &&
        other.lastName == this.lastName &&
        other.username == this.username &&
        other.photoUrl == this.photoUrl &&
        other.authDate == this.authDate &&
        other.hash == this.hash;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      id,
      firstName,
      lastName,
      username,
      photoUrl,
      authDate,
      hash,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(id.toString());
    _$result[r'first_name'] = _i1.PropertyValue.scalar(firstName);
    if (lastName != null) {
      _$result[r'last_name'] = _i1.PropertyValue.scalar(lastName!);
    }
    if (username != null) {
      _$result[r'username'] = _i1.PropertyValue.scalar(username!);
    }
    if (photoUrl != null) {
      _$result[r'photo_url'] = _i1.PropertyValue.scalar(photoUrl!);
    }
    _$result[r'auth_date'] = _i1.PropertyValue.scalar(authDate.toString());
    _$result[r'hash'] = _i1.PropertyValue.scalar(hash);
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
      r'Cannot uriEncode TelegramAuthData: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$TelegramAuthDataCopyWith<$Res> {
  factory $$TelegramAuthDataCopyWith(TelegramAuthData value) =
      _TelegramAuthDataCopyWith<$Res>;

  $Res call({
    _i3.int? id,
    _i3.String? firstName,
    _i3.String? lastName,
    _i3.String? username,
    _i3.String? photoUrl,
    _i3.int? authDate,
    _i3.String? hash,
  });
  _i3.int get id;
  _i3.String get firstName;
  _i3.String? get lastName;
  _i3.String? get username;
  _i3.String? get photoUrl;
  _i3.int get authDate;
  _i3.String get hash;
}

class _TelegramAuthDataCopyWith<$Res>
    implements $$TelegramAuthDataCopyWith<$Res> {
  _TelegramAuthDataCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final TelegramAuthData _value;

  @_i3.override
  _i3.int get id => _value.id;

  @_i3.override
  _i3.String get firstName => _value.firstName;

  @_i3.override
  _i3.String? get lastName => _value.lastName;

  @_i3.override
  _i3.String? get username => _value.username;

  @_i3.override
  _i3.String? get photoUrl => _value.photoUrl;

  @_i3.override
  _i3.int get authDate => _value.authDate;

  @_i3.override
  _i3.String get hash => _value.hash;

  @_i3.override
  $Res call({
    _i3.Object? id = _sentinel,
    _i3.Object? firstName = _sentinel,
    _i3.Object? lastName = _sentinel,
    _i3.Object? username = _sentinel,
    _i3.Object? photoUrl = _sentinel,
    _i3.Object? authDate = _sentinel,
    _i3.Object? hash = _sentinel,
  }) {
    return (TelegramAuthData(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i3.int),
      firstName: _i3.identical(firstName, _sentinel)
          ? this.firstName
          : (firstName as _i3.String),
      lastName: _i3.identical(lastName, _sentinel)
          ? this.lastName
          : (lastName as _i3.String?),
      username: _i3.identical(username, _sentinel)
          ? this.username
          : (username as _i3.String?),
      photoUrl: _i3.identical(photoUrl, _sentinel)
          ? this.photoUrl
          : (photoUrl as _i3.String?),
      authDate: _i3.identical(authDate, _sentinel)
          ? this.authDate
          : (authDate as _i3.int),
      hash: _i3.identical(hash, _sentinel) ? this.hash : (hash as _i3.String),
    ) as $Res);
  }
}
