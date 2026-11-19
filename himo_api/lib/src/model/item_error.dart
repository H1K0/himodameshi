// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class ItemError implements _i1.ParameterEncodable, _i1.UriEncodable {
  const ItemError({required this.code, this.detail});

  factory ItemError.fromSimple(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'code', r'detail'},
      listKeys: {},
      context: r'ItemError',
    );
    return ItemError(
      code: _$values[r'code'].decodeSimpleString(context: r'ItemError.code'),
      detail: _$values[r'detail'].decodeSimpleNullableString(
        context: r'ItemError.detail',
      ),
    );
  }

  factory ItemError.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'ItemError');
    return ItemError(
      code: _$map[r'code'].decodeJsonString(context: r'ItemError.code'),
      detail: _$map[r'detail'].decodeJsonNullableString(
        context: r'ItemError.detail',
      ),
    );
  }

  factory ItemError.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'code', r'detail'},
      listKeys: {},
      context: r'ItemError',
    );
    return ItemError(
      code: _$values[r'code'].decodeFormString(context: r'ItemError.code'),
      detail: _$values[r'detail'].decodeFormNullableString(
        context: r'ItemError.detail',
      ),
    );
  }

  /// Код из таблицы ошибок, а также `cable_not_found` и `id_conflict`
  ///
  /// **Example**:
  /// ```
  /// version_conflict
  /// ```
  final _i3.String code;

  final _i3.String? detail;

  @_i3.override
  _i3.Object? toJson() => {
    r'code': code,
    if (detail != null) r'detail': detail,
  };

  $$ItemErrorCopyWith<ItemError> get copyWith => _ItemErrorCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ItemError &&
        other.code == this.code &&
        other.detail == this.detail;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([code, detail]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'code'] = _i1.PropertyValue.scalar(code);
    if (detail != null) {
      _$result[r'detail'] = _i1.PropertyValue.scalar(detail!);
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
      r'Cannot uriEncode ItemError: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$ItemErrorCopyWith<$Res> {
  factory $$ItemErrorCopyWith(ItemError value) = _ItemErrorCopyWith<$Res>;

  $Res call({_i3.String? code, _i3.String? detail});
  _i3.String get code;
  _i3.String? get detail;
}

class _ItemErrorCopyWith<$Res> implements $$ItemErrorCopyWith<$Res> {
  _ItemErrorCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final ItemError _value;

  @_i3.override
  _i3.String get code => _value.code;

  @_i3.override
  _i3.String? get detail => _value.detail;

  @_i3.override
  $Res call({_i3.Object? code = _sentinel, _i3.Object? detail = _sentinel}) {
    return (ItemError(
      code: _i3.identical(code, _sentinel) ? this.code : (code as _i3.String),
      detail: _i3.identical(detail, _sentinel)
          ? this.detail
          : (detail as _i3.String?),
    ) as $Res);
  }
}
