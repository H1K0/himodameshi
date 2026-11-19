// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/test_meta.dart' as _i4;
import 'package:himo_api/src/model/test_model.dart' as _i5;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// **Example**:
/// ```json
/// {
///   "id": "0192f1a2-7d10-7c3a-a1b2-4c5d6e7f8091",
///   "cable_id": "0192f1a0-5c3e-7a21-9b4d-3e8f12a7c901",
///   "author": {
///     "id": "0192d000-0000-7000-8000-000000000001",
///     "nickname": "vlad"
///   },
///   "measured_at": "2026-10-19T09:12:45Z",
///   "received_at": "2026-10-19T09:20:03Z",
///   "device_id": "A4:CF:12:8B:3E:01",
///   "pv": 1,
///   "app_version": "0.7.0",
///   "rules_version": "1",
///   "firmware_version": null,
///   "health_score": 92,
///   "health_incomplete": false,
///   "note": null,
///   "results": {
///     "continuity": {
///       "status": "ok",
///       "conductors": {
///         "pin1": {
///           "r": 0.91,
///           "s": "ok"
///         },
///         "pin2": {
///           "r": 1.02,
///           "s": "ok"
///         },
///         "pin3": {
///           "r": 0.95,
///           "s": "ok"
///         }
///       }
///     },
///     "cmrr": {
///       "status": "excellent",
///       "cmrr_db": 72.4
///     },
///     "freq_response": {
///       "status": "ok",
///       "v": [
///         0.1,
///         0.1,
///         0.1,
///         0.0,
///         0.0,
///         0.0,
///         0.0,
///         0.0,
///         0.0,
///         0.0,
///         0.0,
///         0.0,
///         0.0,
///         0.0,
///         0.0,
///         0.0,
///         0.0,
///         0.0,
///         0.0,
///         0.0,
///         0.0,
///         -0.1,
///         -0.2,
///         -0.3,
///         -0.5,
///         -0.7,
///         -1.0,
///         -1.5,
///         -2.3,
///         -3.8
///       ],
///       "f": [
///         10,
///         13,
///         18,
///         24,
///         31,
///         42,
///         56,
///         74,
///         99,
///         131,
///         175,
///         232,
///         309,
///         412,
///         548,
///         730,
///         1000,
///         1293,
///         1721,
///         2291,
///         3050,
///         4060,
///         5404,
///         7192,
///         9574,
///         12742,
///         16959,
///         22573,
///         30043,
///         40000
///       ]
///     }
///   },
///   "invalidation": null,
///   "insight": null
/// }
/// ```
@_i2.immutable
class Test implements _i1.ParameterEncodable, _i1.UriEncodable {
  const Test({required this.testMeta, required this.testModel});

  factory Test.fromSimple(_i3.String? value, {required _i3.bool explode}) {
    return Test(
      testMeta: _i4.TestMeta.fromSimple(value, explode: explode),
      testModel: _i5.TestModel.fromSimple(value, explode: explode),
    );
  }

  factory Test.fromForm(_i3.String? value, {required _i3.bool explode}) {
    return Test(
      testMeta: _i4.TestMeta.fromForm(value, explode: explode),
      testModel: _i5.TestModel.fromForm(value, explode: explode),
    );
  }

  factory Test.fromJson(_i3.Object? json) {
    return Test(
      testMeta: _i4.TestMeta.fromJson(json),
      testModel: _i5.TestModel.fromJson(json),
    );
  }

  final _i4.TestMeta testMeta;

  final _i5.TestModel testModel;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Object? toJson() {
    final _$map = <_i3.String, _i3.Object?>{};
    final _$testMetaJson = testMeta.toJson();
    if (_$testMetaJson is! _i3.Map<_i3.String, _i3.Object?>) {
      throw _i1.EncodingException(
        'Expected testMeta.toJson() to return Map<String, Object?>, got ${_$testMetaJson.runtimeType}',
      );
    }
    _$map.addAll(_$testMetaJson);
    final _$testModelJson = testModel.toJson();
    if (_$testModelJson is! _i3.Map<_i3.String, _i3.Object?>) {
      throw _i1.EncodingException(
        'Expected testModel.toJson() to return Map<String, Object?>, got ${_$testModelJson.runtimeType}',
      );
    }
    _$map.addAll(_$testModelJson);
    return _$map;
  }

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$mergedProperties = <_i3.String, _i1.PropertyValue>{};
    _$mergedProperties.addAll(
      testMeta.parameterProperties(allowEmpty: allowEmpty),
    );
    _$mergedProperties.addAll(
      testModel.parameterProperties(allowEmpty: allowEmpty),
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
      r'Cannot uriEncode Test: contains complex types',
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is Test &&
        other.testMeta == this.testMeta &&
        other.testModel == this.testModel;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([testMeta, testModel]);
  }

  $$TestCopyWith<Test> get copyWith => _TestCopyWith(this);
}

abstract class $$TestCopyWith<$Res> {
  factory $$TestCopyWith(Test value) = _TestCopyWith<$Res>;

  $Res call({_i4.TestMeta? testMeta, _i5.TestModel? testModel});
  _i4.TestMeta get testMeta;
  _i5.TestModel get testModel;
}

class _TestCopyWith<$Res> implements $$TestCopyWith<$Res> {
  _TestCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final Test _value;

  @_i3.override
  _i4.TestMeta get testMeta => _value.testMeta;

  @_i3.override
  _i5.TestModel get testModel => _value.testModel;

  @_i3.override
  $Res call({
    _i3.Object? testMeta = _sentinel,
    _i3.Object? testModel = _sentinel,
  }) {
    return (Test(
      testMeta: _i3.identical(testMeta, _sentinel)
          ? this.testMeta
          : (testMeta as _i4.TestMeta),
      testModel: _i3.identical(testModel, _sentinel)
          ? this.testModel
          : (testModel as _i5.TestModel),
    ) as $Res);
  }
}
