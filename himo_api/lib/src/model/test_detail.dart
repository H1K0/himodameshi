// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/test.dart' as _i4;
import 'package:himo_api/src/model/test_detail_model.dart' as _i5;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// Тест с ID тестов для сравнения
@_i2.immutable
class TestDetail implements _i1.ParameterEncodable, _i1.UriEncodable {
  const TestDetail({required this.test, required this.testDetailModel});

  factory TestDetail.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    return TestDetail(
      test: _i4.Test.fromSimple(value, explode: explode),
      testDetailModel: _i5.TestDetailModel.fromSimple(value, explode: explode),
    );
  }

  factory TestDetail.fromForm(_i3.String? value, {required _i3.bool explode}) {
    return TestDetail(
      test: _i4.Test.fromForm(value, explode: explode),
      testDetailModel: _i5.TestDetailModel.fromForm(value, explode: explode),
    );
  }

  factory TestDetail.fromJson(_i3.Object? json) {
    return TestDetail(
      test: _i4.Test.fromJson(json),
      testDetailModel: _i5.TestDetailModel.fromJson(json),
    );
  }

  final _i4.Test test;

  final _i5.TestDetailModel testDetailModel;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Object? toJson() {
    final _$map = <_i3.String, _i3.Object?>{};
    final _$testJson = test.toJson();
    if (_$testJson is! _i3.Map<_i3.String, _i3.Object?>) {
      throw _i1.EncodingException(
        'Expected test.toJson() to return Map<String, Object?>, got ${_$testJson.runtimeType}',
      );
    }
    _$map.addAll(_$testJson);
    final _$testDetailModelJson = testDetailModel.toJson();
    if (_$testDetailModelJson is! _i3.Map<_i3.String, _i3.Object?>) {
      throw _i1.EncodingException(
        'Expected testDetailModel.toJson() to return Map<String, Object?>, got ${_$testDetailModelJson.runtimeType}',
      );
    }
    _$map.addAll(_$testDetailModelJson);
    return _$map;
  }

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$mergedProperties = <_i3.String, _i1.PropertyValue>{};
    _$mergedProperties.addAll(test.parameterProperties(allowEmpty: allowEmpty));
    _$mergedProperties.addAll(
      testDetailModel.parameterProperties(allowEmpty: allowEmpty),
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
      r'Cannot uriEncode TestDetail: contains complex types',
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is TestDetail &&
        other.test == this.test &&
        other.testDetailModel == this.testDetailModel;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([test, testDetailModel]);
  }

  $$TestDetailCopyWith<TestDetail> get copyWith => _TestDetailCopyWith(this);
}

abstract class $$TestDetailCopyWith<$Res> {
  factory $$TestDetailCopyWith(TestDetail value) = _TestDetailCopyWith<$Res>;

  $Res call({_i4.Test? test, _i5.TestDetailModel? testDetailModel});
  _i4.Test get test;
  _i5.TestDetailModel get testDetailModel;
}

class _TestDetailCopyWith<$Res> implements $$TestDetailCopyWith<$Res> {
  _TestDetailCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final TestDetail _value;

  @_i3.override
  _i4.Test get test => _value.test;

  @_i3.override
  _i5.TestDetailModel get testDetailModel => _value.testDetailModel;

  @_i3.override
  $Res call({
    _i3.Object? test = _sentinel,
    _i3.Object? testDetailModel = _sentinel,
  }) {
    return (TestDetail(
      test: _i3.identical(test, _sentinel) ? this.test : (test as _i4.Test),
      testDetailModel: _i3.identical(testDetailModel, _sentinel)
          ? this.testDetailModel
          : (testDetailModel as _i5.TestDetailModel),
    ) as $Res);
  }
}
