// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/invalidation.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// Пометка «недействительный» или `null`
@_i2.immutable
class $RawTestInvalidationAllOfModel
    implements _i1.ParameterEncodable, _i1.UriEncodable {
  const $RawTestInvalidationAllOfModel({required this.invalidation});

  factory $RawTestInvalidationAllOfModel.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    return $RawTestInvalidationAllOfModel(
      invalidation: _i4.Invalidation.fromSimple(value, explode: explode),
    );
  }

  factory $RawTestInvalidationAllOfModel.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    return $RawTestInvalidationAllOfModel(
      invalidation: _i4.Invalidation.fromForm(value, explode: explode),
    );
  }

  factory $RawTestInvalidationAllOfModel.fromJson(_i3.Object? json) {
    return $RawTestInvalidationAllOfModel(
      invalidation: _i4.Invalidation.fromJson(json),
    );
  }

  final _i4.Invalidation invalidation;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Object? toJson() {
    final _$map = <_i3.String, _i3.Object?>{};
    final _$invalidationJson = invalidation.toJson();
    if (_$invalidationJson is! _i3.Map<_i3.String, _i3.Object?>) {
      throw _i1.EncodingException(
        'Expected invalidation.toJson() to return Map<String, Object?>, got ${_$invalidationJson.runtimeType}',
      );
    }
    _$map.addAll(_$invalidationJson);
    return _$map;
  }

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$mergedProperties = <_i3.String, _i1.PropertyValue>{};
    _$mergedProperties.addAll(
      invalidation.parameterProperties(allowEmpty: allowEmpty),
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
      r'Cannot uriEncode $RawTestInvalidationAllOfModel: contains complex types',
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is $RawTestInvalidationAllOfModel &&
        other.invalidation == this.invalidation;
  }

  @_i3.override
  _i3.int get hashCode => invalidation.hashCode;

  $$$RawTestInvalidationAllOfModelCopyWith<$RawTestInvalidationAllOfModel>
  get copyWith => _$RawTestInvalidationAllOfModelCopyWith(this);
}

abstract class $$$RawTestInvalidationAllOfModelCopyWith<$Res> {
  factory $$$RawTestInvalidationAllOfModelCopyWith(
    $RawTestInvalidationAllOfModel value,
  ) = _$RawTestInvalidationAllOfModelCopyWith<$Res>;

  $Res call({_i4.Invalidation? invalidation});
  _i4.Invalidation get invalidation;
}

class _$RawTestInvalidationAllOfModelCopyWith<$Res>
    implements $$$RawTestInvalidationAllOfModelCopyWith<$Res> {
  _$RawTestInvalidationAllOfModelCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final $RawTestInvalidationAllOfModel _value;

  @_i3.override
  _i4.Invalidation get invalidation => _value.invalidation;

  @_i3.override
  $Res call({_i3.Object? invalidation = _sentinel}) {
    return ($RawTestInvalidationAllOfModel(
      invalidation: _i3.identical(invalidation, _sentinel)
          ? this.invalidation
          : (invalidation as _i4.Invalidation),
    ) as $Res);
  }
}

typedef TestInvalidationAllOfModel = $RawTestInvalidationAllOfModel?;
