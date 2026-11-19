// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/insight.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// Привязанный ИИ-комментарий или `null`
@_i2.immutable
class $RawTestInsightAllOfModel
    implements _i1.ParameterEncodable, _i1.UriEncodable {
  const $RawTestInsightAllOfModel({required this.insight});

  factory $RawTestInsightAllOfModel.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    return $RawTestInsightAllOfModel(
      insight: _i4.Insight.fromSimple(value, explode: explode),
    );
  }

  factory $RawTestInsightAllOfModel.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    return $RawTestInsightAllOfModel(
      insight: _i4.Insight.fromForm(value, explode: explode),
    );
  }

  factory $RawTestInsightAllOfModel.fromJson(_i3.Object? json) {
    return $RawTestInsightAllOfModel(insight: _i4.Insight.fromJson(json));
  }

  final _i4.Insight insight;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Object? toJson() {
    final _$map = <_i3.String, _i3.Object?>{};
    final _$insightJson = insight.toJson();
    if (_$insightJson is! _i3.Map<_i3.String, _i3.Object?>) {
      throw _i1.EncodingException(
        'Expected insight.toJson() to return Map<String, Object?>, got ${_$insightJson.runtimeType}',
      );
    }
    _$map.addAll(_$insightJson);
    return _$map;
  }

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$mergedProperties = <_i3.String, _i1.PropertyValue>{};
    _$mergedProperties.addAll(
      insight.parameterProperties(allowEmpty: allowEmpty),
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
      r'Cannot uriEncode $RawTestInsightAllOfModel: contains complex types',
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is $RawTestInsightAllOfModel && other.insight == this.insight;
  }

  @_i3.override
  _i3.int get hashCode => insight.hashCode;

  $$$RawTestInsightAllOfModelCopyWith<$RawTestInsightAllOfModel> get copyWith =>
      _$RawTestInsightAllOfModelCopyWith(this);
}

abstract class $$$RawTestInsightAllOfModelCopyWith<$Res> {
  factory $$$RawTestInsightAllOfModelCopyWith($RawTestInsightAllOfModel value) =
      _$RawTestInsightAllOfModelCopyWith<$Res>;

  $Res call({_i4.Insight? insight});
  _i4.Insight get insight;
}

class _$RawTestInsightAllOfModelCopyWith<$Res>
    implements $$$RawTestInsightAllOfModelCopyWith<$Res> {
  _$RawTestInsightAllOfModelCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final $RawTestInsightAllOfModel _value;

  @_i3.override
  _i4.Insight get insight => _value.insight;

  @_i3.override
  $Res call({_i3.Object? insight = _sentinel}) {
    return ($RawTestInsightAllOfModel(
      insight: _i3.identical(insight, _sentinel)
          ? this.insight
          : (insight as _i4.Insight),
    ) as $Res);
  }
}

typedef TestInsightAllOfModel = $RawTestInsightAllOfModel?;
