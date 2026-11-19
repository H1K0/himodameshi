// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i6;
import 'package:himo_api/src/model/push_cable_result.dart' as _i4;
import 'package:himo_api/src/model/push_test_result.dart' as _i5;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// Результаты в том же порядке, что объекты в запросе
@_i2.immutable
class PushResponse implements _i1.ParameterEncodable, _i1.UriEncodable {
  const PushResponse({
    required this.cables,
    required this.cableUpdates,
    required this.tests,
  });

  factory PushResponse.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for PushResponse: contains complex types',
    );
  }

  factory PushResponse.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'PushResponse');
    return PushResponse(
      cables: _$map[r'cables']
          .decodeJsonList<_i3.Object?>(context: r'PushResponse.cables')
          .map(_i4.PushCableResult.fromJson)
          .toList(),
      cableUpdates: _$map[r'cable_updates']
          .decodeJsonList<_i3.Object?>(context: r'PushResponse.cable_updates')
          .map(_i4.PushCableResult.fromJson)
          .toList(),
      tests: _$map[r'tests']
          .decodeJsonList<_i3.Object?>(context: r'PushResponse.tests')
          .map(_i5.PushTestResult.fromJson)
          .toList(),
    );
  }

  factory PushResponse.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for PushResponse: contains complex types',
    );
  }

  final _i3.List<_i4.PushCableResult> cables;

  final _i3.List<_i4.PushCableResult> cableUpdates;

  final _i3.List<_i5.PushTestResult> tests;

  @_i3.override
  _i3.Object? toJson() => {
    r'cables': cables.map((e) => e.toJson()).toList(),
    r'cable_updates': cableUpdates.map((e) => e.toJson()).toList(),
    r'tests': tests.map((e) => e.toJson()).toList(),
  };

  $$PushResponseCopyWith<PushResponse> get copyWith =>
      _PushResponseCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i6.DeepCollectionEquality();
    return other is PushResponse &&
        _$deepEquals.equals(other.cables, this.cables) &&
        _$deepEquals.equals(other.cableUpdates, this.cableUpdates) &&
        _$deepEquals.equals(other.tests, this.tests);
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i6.DeepCollectionEquality();
    return _i3.Object.hashAll([
      deepEquals.hash(cables),
      deepEquals.hash(cableUpdates),
      deepEquals.hash(tests),
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for PushResponse: contains complex types',
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
      r'Cannot uriEncode PushResponse: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$PushResponseCopyWith<$Res> {
  factory $$PushResponseCopyWith(PushResponse value) =
      _PushResponseCopyWith<$Res>;

  $Res call({
    _i3.List<_i4.PushCableResult>? cables,
    _i3.List<_i4.PushCableResult>? cableUpdates,
    _i3.List<_i5.PushTestResult>? tests,
  });
  _i3.List<_i4.PushCableResult> get cables;
  _i3.List<_i4.PushCableResult> get cableUpdates;
  _i3.List<_i5.PushTestResult> get tests;
}

class _PushResponseCopyWith<$Res> implements $$PushResponseCopyWith<$Res> {
  _PushResponseCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final PushResponse _value;

  @_i3.override
  _i3.List<_i4.PushCableResult> get cables => _value.cables;

  @_i3.override
  _i3.List<_i4.PushCableResult> get cableUpdates => _value.cableUpdates;

  @_i3.override
  _i3.List<_i5.PushTestResult> get tests => _value.tests;

  @_i3.override
  $Res call({
    _i3.Object? cables = _sentinel,
    _i3.Object? cableUpdates = _sentinel,
    _i3.Object? tests = _sentinel,
  }) {
    return (PushResponse(
      cables: _i3.identical(cables, _sentinel)
          ? this.cables
          : (cables as _i3.List<_i4.PushCableResult>),
      cableUpdates: _i3.identical(cableUpdates, _sentinel)
          ? this.cableUpdates
          : (cableUpdates as _i3.List<_i4.PushCableResult>),
      tests: _i3.identical(tests, _sentinel)
          ? this.tests
          : (tests as _i3.List<_i5.PushTestResult>),
    ) as $Res);
  }
}
