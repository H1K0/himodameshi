// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/nickname.dart' as _i6;
import 'package:himo_api/src/model/user_telegram_all_of_model.dart' as _i4;
import 'package:himo_api/src/model/uuid.dart' as _i5;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class User implements _i1.ParameterEncodable, _i1.UriEncodable {
  const User({
    required this.id,
    required this.nickname,
    required this.telegram,
    required this.createdAt,
  });

  factory User.fromSimple(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for User: contains complex types',
    );
  }

  factory User.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'User');
    return User(
      id: _$map[r'id'].decodeJsonString(context: r'User.id'),
      nickname: _$map[r'nickname'].decodeJsonString(context: r'User.nickname'),
      telegram: _$map[r'telegram'] == null
          ? null
          : _i4.UserTelegramAllOfModel.fromJson(_$map[r'telegram']),
      createdAt: _$map[r'created_at'].decodeJsonDateTime(
        context: r'User.created_at',
      ),
    );
  }

  factory User.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for User: contains complex types',
    );
  }

  final _i5.Uuid id;

  final _i6.Nickname nickname;

  /// Привязанный Telegram или `null`
  final _i4.UserTelegramAllOfModel? telegram;

  final _i3.DateTime createdAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': id,
    r'nickname': nickname,
    r'telegram': telegram?.toJson(),
    r'created_at': createdAt.toTimeZonedIso8601String(),
  };

  $$UserCopyWith<User> get copyWith => _UserCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is User &&
        other.id == this.id &&
        other.nickname == this.nickname &&
        other.telegram == this.telegram &&
        other.createdAt == this.createdAt;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([id, nickname, telegram, createdAt]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for User: contains complex types',
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
      r'Cannot uriEncode User: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$UserCopyWith<$Res> {
  factory $$UserCopyWith(User value) = _UserCopyWith<$Res>;

  $Res call({
    _i5.Uuid? id,
    _i6.Nickname? nickname,
    _i4.UserTelegramAllOfModel? telegram,
    _i3.DateTime? createdAt,
  });
  _i5.Uuid get id;
  _i6.Nickname get nickname;
  _i4.UserTelegramAllOfModel? get telegram;
  _i3.DateTime get createdAt;
}

class _UserCopyWith<$Res> implements $$UserCopyWith<$Res> {
  _UserCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final User _value;

  @_i3.override
  _i5.Uuid get id => _value.id;

  @_i3.override
  _i6.Nickname get nickname => _value.nickname;

  @_i3.override
  _i4.UserTelegramAllOfModel? get telegram => _value.telegram;

  @_i3.override
  _i3.DateTime get createdAt => _value.createdAt;

  @_i3.override
  $Res call({
    _i3.Object? id = _sentinel,
    _i3.Object? nickname = _sentinel,
    _i3.Object? telegram = _sentinel,
    _i3.Object? createdAt = _sentinel,
  }) {
    return (User(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i5.Uuid),
      nickname: _i3.identical(nickname, _sentinel)
          ? this.nickname
          : (nickname as _i6.Nickname),
      telegram: _i3.identical(telegram, _sentinel)
          ? this.telegram
          : (telegram as _i4.UserTelegramAllOfModel?),
      createdAt: _i3.identical(createdAt, _sentinel)
          ? this.createdAt
          : (createdAt as _i3.DateTime),
    ) as $Res);
  }
}
