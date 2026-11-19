// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/new_test_model.dart' as _i5;
import 'package:himo_api/src/model/test_meta.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// Тест в пакете выгрузки
@_i2.immutable
class NewTest implements _i1.ParameterEncodable, _i1.UriEncodable {
  const NewTest({required this.testMeta, required this.newTestModel});

  factory NewTest.fromSimple(_i3.String? value, {required _i3.bool explode}) {
    return NewTest(
      testMeta: _i4.TestMeta.fromSimple(value, explode: explode),
      newTestModel: _i5.NewTestModel.fromSimple(value, explode: explode),
    );
  }

  factory NewTest.fromForm(_i3.String? value, {required _i3.bool explode}) {
    return NewTest(
      testMeta: _i4.TestMeta.fromForm(value, explode: explode),
      newTestModel: _i5.NewTestModel.fromForm(value, explode: explode),
    );
  }

  factory NewTest.fromJson(_i3.Object? json) {
    return NewTest(
      testMeta: _i4.TestMeta.fromJson(json),
      newTestModel: _i5.NewTestModel.fromJson(json),
    );
  }

  final _i4.TestMeta testMeta;

  final _i5.NewTestModel newTestModel;

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
    final _$newTestModelJson = newTestModel.toJson();
    if (_$newTestModelJson is! _i3.Map<_i3.String, _i3.Object?>) {
      throw _i1.EncodingException(
        'Expected newTestModel.toJson() to return Map<String, Object?>, got ${_$newTestModelJson.runtimeType}',
      );
    }
    _$map.addAll(_$newTestModelJson);
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
      newTestModel.parameterProperties(allowEmpty: allowEmpty),
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
      r'Cannot uriEncode NewTest: contains complex types',
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is NewTest &&
        other.testMeta == this.testMeta &&
        other.newTestModel == this.newTestModel;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([testMeta, newTestModel]);
  }

  $$NewTestCopyWith<NewTest> get copyWith => _NewTestCopyWith(this);
}

abstract class $$NewTestCopyWith<$Res> {
  factory $$NewTestCopyWith(NewTest value) = _NewTestCopyWith<$Res>;

  $Res call({_i4.TestMeta? testMeta, _i5.NewTestModel? newTestModel});
  _i4.TestMeta get testMeta;
  _i5.NewTestModel get newTestModel;
}

class _NewTestCopyWith<$Res> implements $$NewTestCopyWith<$Res> {
  _NewTestCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final NewTest _value;

  @_i3.override
  _i4.TestMeta get testMeta => _value.testMeta;

  @_i3.override
  _i5.NewTestModel get newTestModel => _value.newTestModel;

  @_i3.override
  $Res call({
    _i3.Object? testMeta = _sentinel,
    _i3.Object? newTestModel = _sentinel,
  }) {
    return (NewTest(
      testMeta: _i3.identical(testMeta, _sentinel)
          ? this.testMeta
          : (testMeta as _i4.TestMeta),
      newTestModel: _i3.identical(newTestModel, _sentinel)
          ? this.newTestModel
          : (newTestModel as _i5.NewTestModel),
    ) as $Res);
  }
}
