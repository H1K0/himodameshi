// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/telegram_account.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// Привязанный Telegram или `null`
@_i2.immutable
class $RawUserTelegramAllOfModel
    implements _i1.ParameterEncodable, _i1.UriEncodable {
  const $RawUserTelegramAllOfModel({required this.telegramAccount});

  factory $RawUserTelegramAllOfModel.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    return $RawUserTelegramAllOfModel(
      telegramAccount: _i4.TelegramAccount.fromSimple(value, explode: explode),
    );
  }

  factory $RawUserTelegramAllOfModel.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    return $RawUserTelegramAllOfModel(
      telegramAccount: _i4.TelegramAccount.fromForm(value, explode: explode),
    );
  }

  factory $RawUserTelegramAllOfModel.fromJson(_i3.Object? json) {
    return $RawUserTelegramAllOfModel(
      telegramAccount: _i4.TelegramAccount.fromJson(json),
    );
  }

  final _i4.TelegramAccount telegramAccount;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Object? toJson() {
    final _$map = <_i3.String, _i3.Object?>{};
    final _$telegramAccountJson = telegramAccount.toJson();
    if (_$telegramAccountJson is! _i3.Map<_i3.String, _i3.Object?>) {
      throw _i1.EncodingException(
        'Expected telegramAccount.toJson() to return Map<String, Object?>, got ${_$telegramAccountJson.runtimeType}',
      );
    }
    _$map.addAll(_$telegramAccountJson);
    return _$map;
  }

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$mergedProperties = <_i3.String, _i1.PropertyValue>{};
    _$mergedProperties.addAll(
      telegramAccount.parameterProperties(allowEmpty: allowEmpty),
    );
    return _$mergedProperties;
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
      r'Cannot uriEncode $RawUserTelegramAllOfModel: contains complex types',
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is $RawUserTelegramAllOfModel &&
        other.telegramAccount == this.telegramAccount;
  }

  @_i3.override
  _i3.int get hashCode => telegramAccount.hashCode;

  $$$RawUserTelegramAllOfModelCopyWith<$RawUserTelegramAllOfModel>
  get copyWith => _$RawUserTelegramAllOfModelCopyWith(this);
}

abstract class $$$RawUserTelegramAllOfModelCopyWith<$Res> {
  factory $$$RawUserTelegramAllOfModelCopyWith(
    $RawUserTelegramAllOfModel value,
  ) = _$RawUserTelegramAllOfModelCopyWith<$Res>;

  $Res call({_i4.TelegramAccount? telegramAccount});
  _i4.TelegramAccount get telegramAccount;
}

class _$RawUserTelegramAllOfModelCopyWith<$Res>
    implements $$$RawUserTelegramAllOfModelCopyWith<$Res> {
  _$RawUserTelegramAllOfModelCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final $RawUserTelegramAllOfModel _value;

  @_i3.override
  _i4.TelegramAccount get telegramAccount => _value.telegramAccount;

  @_i3.override
  $Res call({_i3.Object? telegramAccount = _sentinel}) {
    return ($RawUserTelegramAllOfModel(
      telegramAccount: _i3.identical(telegramAccount, _sentinel)
          ? this.telegramAccount
          : (telegramAccount as _i4.TelegramAccount),
    ) as $Res);
  }
}

typedef UserTelegramAllOfModel = $RawUserTelegramAllOfModel?;
