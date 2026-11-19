// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/cable_type.dart' as _i4;
import 'package:himo_api/src/model/test_results.dart' as _i5;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// Данные для комментария. Ключ кэша — хеш канонического представления этого объекта
/// вместе с версией промпта и моделью.
///
@_i2.immutable
class InsightRequest implements _i1.ParameterEncodable, _i1.UriEncodable {
  const InsightRequest({
    required this.cableType,
    required this.pv,
    required this.healthScore,
    required this.healthIncomplete,
    required this.results,
  });

  factory InsightRequest.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for InsightRequest: contains complex types',
    );
  }

  factory InsightRequest.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'InsightRequest');
    return InsightRequest(
      cableType: _i4.CableType.fromJson(_$map[r'cable_type']),
      pv: _$map[r'pv'].decodeJsonInt(context: r'InsightRequest.pv'),
      healthScore: _$map[r'health_score'].decodeJsonNullableInt(
        context: r'InsightRequest.health_score',
      ),
      healthIncomplete: _$map[r'health_incomplete'].decodeJsonBool(
        context: r'InsightRequest.health_incomplete',
      ),
      results: _i5.TestResults.fromJson(_$map[r'results']),
    );
  }

  factory InsightRequest.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for InsightRequest: contains complex types',
    );
  }

  final _i4.CableType cableType;

  /// **Example**:
  /// ```json
  /// 1
  /// ```
  final _i3.int pv;

  final _i3.int? healthScore;

  final _i3.bool healthIncomplete;

  final _i5.TestResults results;

  @_i3.override
  _i3.Object? toJson() => {
    r'cable_type': cableType.toJson(),
    r'pv': pv,
    r'health_score': healthScore,
    r'health_incomplete': healthIncomplete,
    r'results': results.toJson(),
  };

  $$InsightRequestCopyWith<InsightRequest> get copyWith =>
      _InsightRequestCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is InsightRequest &&
        other.cableType == this.cableType &&
        other.pv == this.pv &&
        other.healthScore == this.healthScore &&
        other.healthIncomplete == this.healthIncomplete &&
        other.results == this.results;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      cableType,
      pv,
      healthScore,
      healthIncomplete,
      results,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for InsightRequest: contains complex types',
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
      r'Cannot uriEncode InsightRequest: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$InsightRequestCopyWith<$Res> {
  factory $$InsightRequestCopyWith(InsightRequest value) =
      _InsightRequestCopyWith<$Res>;

  $Res call({
    _i4.CableType? cableType,
    _i3.int? pv,
    _i3.int? healthScore,
    _i3.bool? healthIncomplete,
    _i5.TestResults? results,
  });
  _i4.CableType get cableType;
  _i3.int get pv;
  _i3.int? get healthScore;
  _i3.bool get healthIncomplete;
  _i5.TestResults get results;
}

class _InsightRequestCopyWith<$Res> implements $$InsightRequestCopyWith<$Res> {
  _InsightRequestCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final InsightRequest _value;

  @_i3.override
  _i4.CableType get cableType => _value.cableType;

  @_i3.override
  _i3.int get pv => _value.pv;

  @_i3.override
  _i3.int? get healthScore => _value.healthScore;

  @_i3.override
  _i3.bool get healthIncomplete => _value.healthIncomplete;

  @_i3.override
  _i5.TestResults get results => _value.results;

  @_i3.override
  $Res call({
    _i3.Object? cableType = _sentinel,
    _i3.Object? pv = _sentinel,
    _i3.Object? healthScore = _sentinel,
    _i3.Object? healthIncomplete = _sentinel,
    _i3.Object? results = _sentinel,
  }) {
    return (InsightRequest(
      cableType: _i3.identical(cableType, _sentinel)
          ? this.cableType
          : (cableType as _i4.CableType),
      pv: _i3.identical(pv, _sentinel) ? this.pv : (pv as _i3.int),
      healthScore: _i3.identical(healthScore, _sentinel)
          ? this.healthScore
          : (healthScore as _i3.int?),
      healthIncomplete: _i3.identical(healthIncomplete, _sentinel)
          ? this.healthIncomplete
          : (healthIncomplete as _i3.bool),
      results: _i3.identical(results, _sentinel)
          ? this.results
          : (results as _i5.TestResults),
    ) as $Res);
  }
}
