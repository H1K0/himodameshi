// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/cmrr.dart' as _i5;
import 'package:himo_api/src/model/continuity.dart' as _i4;
import 'package:himo_api/src/model/freq_response.dart' as _i6;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// Результаты в формате BLE-протокола; ключ есть, только если измерение выполнено,
/// хотя бы одно обязательно. Незнакомые поля внутри измерений сохраняются без изменений.
///
@_i2.immutable
class TestResults implements _i1.ParameterEncodable, _i1.UriEncodable {
  const TestResults({this.continuity, this.cmrr, this.freqResponse});

  factory TestResults.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for TestResults: contains complex types',
    );
  }

  factory TestResults.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'TestResults');
    return TestResults(
      continuity: _$map[r'continuity'] == null
          ? null
          : _i4.Continuity.fromJson(_$map[r'continuity']),
      cmrr: _$map[r'cmrr'] == null ? null : _i5.Cmrr.fromJson(_$map[r'cmrr']),
      freqResponse: _$map[r'freq_response'] == null
          ? null
          : _i6.FreqResponse.fromJson(_$map[r'freq_response']),
    );
  }

  factory TestResults.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for TestResults: contains complex types',
    );
  }

  final _i4.Continuity? continuity;

  final _i5.Cmrr? cmrr;

  final _i6.FreqResponse? freqResponse;

  @_i3.override
  _i3.Object? toJson() => {
    if (continuity != null) r'continuity': continuity?.toJson(),
    if (cmrr != null) r'cmrr': cmrr?.toJson(),
    if (freqResponse != null) r'freq_response': freqResponse?.toJson(),
  };

  $$TestResultsCopyWith<TestResults> get copyWith => _TestResultsCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is TestResults &&
        other.continuity == this.continuity &&
        other.cmrr == this.cmrr &&
        other.freqResponse == this.freqResponse;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([continuity, cmrr, freqResponse]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for TestResults: contains complex types',
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
      r'Cannot uriEncode TestResults: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$TestResultsCopyWith<$Res> {
  factory $$TestResultsCopyWith(TestResults value) = _TestResultsCopyWith<$Res>;

  $Res call({
    _i4.Continuity? continuity,
    _i5.Cmrr? cmrr,
    _i6.FreqResponse? freqResponse,
  });
  _i4.Continuity? get continuity;
  _i5.Cmrr? get cmrr;
  _i6.FreqResponse? get freqResponse;
}

class _TestResultsCopyWith<$Res> implements $$TestResultsCopyWith<$Res> {
  _TestResultsCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final TestResults _value;

  @_i3.override
  _i4.Continuity? get continuity => _value.continuity;

  @_i3.override
  _i5.Cmrr? get cmrr => _value.cmrr;

  @_i3.override
  _i6.FreqResponse? get freqResponse => _value.freqResponse;

  @_i3.override
  $Res call({
    _i3.Object? continuity = _sentinel,
    _i3.Object? cmrr = _sentinel,
    _i3.Object? freqResponse = _sentinel,
  }) {
    return (TestResults(
      continuity: _i3.identical(continuity, _sentinel)
          ? this.continuity
          : (continuity as _i4.Continuity?),
      cmrr: _i3.identical(cmrr, _sentinel) ? this.cmrr : (cmrr as _i5.Cmrr?),
      freqResponse: _i3.identical(freqResponse, _sentinel)
          ? this.freqResponse
          : (freqResponse as _i6.FreqResponse?),
    ) as $Res);
  }
}
