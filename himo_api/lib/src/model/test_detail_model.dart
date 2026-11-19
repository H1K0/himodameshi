// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/test_detail_previous_test_id_all_of_model.dart'
    as _i4;
import 'package:himo_api/src/model/test_detail_reference_test_id_all_of_model.dart'
    as _i5;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class TestDetailModel implements _i1.ParameterEncodable, _i1.UriEncodable {
  const TestDetailModel({
    required this.previousTestId,
    required this.referenceTestId,
  });

  factory TestDetailModel.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'previous_test_id', r'reference_test_id'},
      listKeys: {},
      context: r'TestDetailModel',
    );
    return TestDetailModel(
      previousTestId: _$values[r'previous_test_id'] == null
          ? null
          : _i4.TestDetailPreviousTestIdAllOfModel.fromSimple(
              _$values[r'previous_test_id'],
              explode: explode,
            ),
      referenceTestId: _$values[r'reference_test_id'] == null
          ? null
          : _i5.TestDetailReferenceTestIdAllOfModel.fromSimple(
              _$values[r'reference_test_id'],
              explode: explode,
            ),
    );
  }

  factory TestDetailModel.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'TestDetailModel');
    return TestDetailModel(
      previousTestId: _$map[r'previous_test_id'] == null
          ? null
          : _i4.TestDetailPreviousTestIdAllOfModel.fromJson(
              _$map[r'previous_test_id'],
            ),
      referenceTestId: _$map[r'reference_test_id'] == null
          ? null
          : _i5.TestDetailReferenceTestIdAllOfModel.fromJson(
              _$map[r'reference_test_id'],
            ),
    );
  }

  factory TestDetailModel.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'previous_test_id', r'reference_test_id'},
      listKeys: {},
      context: r'TestDetailModel',
    );
    return TestDetailModel(
      previousTestId: _$values[r'previous_test_id'] == null
          ? null
          : _i4.TestDetailPreviousTestIdAllOfModel.fromForm(
              _$values[r'previous_test_id'],
              explode: explode,
            ),
      referenceTestId: _$values[r'reference_test_id'] == null
          ? null
          : _i5.TestDetailReferenceTestIdAllOfModel.fromForm(
              _$values[r'reference_test_id'],
              explode: explode,
            ),
    );
  }

  /// Предыдущий действительный тест кабеля или `null`
  final _i4.TestDetailPreviousTestIdAllOfModel? previousTestId;

  /// Эталонный — первый действительный тест кабеля; `null`, если это он сам
  /// или действительных тестов нет
  ///
  final _i5.TestDetailReferenceTestIdAllOfModel? referenceTestId;

  @_i3.override
  _i3.Object? toJson() => {
    r'previous_test_id': previousTestId?.toJson(),
    r'reference_test_id': referenceTestId?.toJson(),
  };

  $$TestDetailModelCopyWith<TestDetailModel> get copyWith =>
      _TestDetailModelCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is TestDetailModel &&
        other.previousTestId == this.previousTestId &&
        other.referenceTestId == this.referenceTestId;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([previousTestId, referenceTestId]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    if (previousTestId != null) {
      _$result[r'previous_test_id'] = _i1.PropertyValue.scalar(
        _i1.encodeAnyValueToString(
          previousTestId!.toJson(),
          allowEmpty: allowEmpty,
        ),
      );
    }
    if (referenceTestId != null) {
      _$result[r'reference_test_id'] = _i1.PropertyValue.scalar(
        _i1.encodeAnyValueToString(
          referenceTestId!.toJson(),
          allowEmpty: allowEmpty,
        ),
      );
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
      r'Cannot uriEncode TestDetailModel: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$TestDetailModelCopyWith<$Res> {
  factory $$TestDetailModelCopyWith(TestDetailModel value) =
      _TestDetailModelCopyWith<$Res>;

  $Res call({
    _i4.TestDetailPreviousTestIdAllOfModel? previousTestId,
    _i5.TestDetailReferenceTestIdAllOfModel? referenceTestId,
  });
  _i4.TestDetailPreviousTestIdAllOfModel? get previousTestId;
  _i5.TestDetailReferenceTestIdAllOfModel? get referenceTestId;
}

class _TestDetailModelCopyWith<$Res>
    implements $$TestDetailModelCopyWith<$Res> {
  _TestDetailModelCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final TestDetailModel _value;

  @_i3.override
  _i4.TestDetailPreviousTestIdAllOfModel? get previousTestId =>
      _value.previousTestId;

  @_i3.override
  _i5.TestDetailReferenceTestIdAllOfModel? get referenceTestId =>
      _value.referenceTestId;

  @_i3.override
  $Res call({
    _i3.Object? previousTestId = _sentinel,
    _i3.Object? referenceTestId = _sentinel,
  }) {
    return (TestDetailModel(
      previousTestId: _i3.identical(previousTestId, _sentinel)
          ? this.previousTestId
          : (previousTestId as _i4.TestDetailPreviousTestIdAllOfModel?),
      referenceTestId: _i3.identical(referenceTestId, _sentinel)
          ? this.referenceTestId
          : (referenceTestId as _i5.TestDetailReferenceTestIdAllOfModel?),
    ) as $Res);
  }
}
