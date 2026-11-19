// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/test_results.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// Данные теста, которые передаёт приложение
@_i2.immutable
class TestMeta implements _i1.ParameterEncodable, _i1.UriEncodable {
  const TestMeta({
    required this.measuredAt,
    required this.deviceId,
    required this.pv,
    required this.appVersion,
    required this.rulesVersion,
    required this.firmwareVersion,
    required this.healthScore,
    required this.healthIncomplete,
    required this.note,
    required this.results,
  });

  factory TestMeta.fromSimple(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for TestMeta: contains complex types',
    );
  }

  factory TestMeta.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'TestMeta');
    return TestMeta(
      measuredAt: _$map[r'measured_at'].decodeJsonDateTime(
        context: r'TestMeta.measured_at',
      ),
      deviceId: _$map[r'device_id'].decodeJsonString(
        context: r'TestMeta.device_id',
      ),
      pv: _$map[r'pv'].decodeJsonInt(context: r'TestMeta.pv'),
      appVersion: _$map[r'app_version'].decodeJsonString(
        context: r'TestMeta.app_version',
      ),
      rulesVersion: _$map[r'rules_version'].decodeJsonString(
        context: r'TestMeta.rules_version',
      ),
      firmwareVersion: _$map[r'firmware_version'].decodeJsonNullableString(
        context: r'TestMeta.firmware_version',
      ),
      healthScore: _$map[r'health_score'].decodeJsonNullableInt(
        context: r'TestMeta.health_score',
      ),
      healthIncomplete: _$map[r'health_incomplete'].decodeJsonBool(
        context: r'TestMeta.health_incomplete',
      ),
      note: _$map[r'note'].decodeJsonNullableString(context: r'TestMeta.note'),
      results: _i4.TestResults.fromJson(_$map[r'results']),
    );
  }

  factory TestMeta.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for TestMeta: contains complex types',
    );
  }

  /// Время измерения по часам приложения
  final _i3.DateTime measuredAt;

  /// ID прибора (MAC или UUID BLE-устройства)
  ///
  /// **Example**:
  /// ```
  /// A4:CF:12:8B:3E:01
  /// ```
  final _i3.String deviceId;

  /// Версия BLE-протокола
  ///
  /// **Example**:
  /// ```json
  /// 1
  /// ```
  final _i3.int pv;

  /// **Example**:
  /// ```
  /// 0.7.0
  /// ```
  final _i3.String appVersion;

  /// Версия правил расчёта вердиктов и Health Score
  ///
  /// **Example**:
  /// ```
  /// 1
  /// ```
  final _i3.String rulesVersion;

  final _i3.String? firmwareVersion;

  /// **Example**:
  /// ```json
  /// 92
  /// ```
  final _i3.int? healthScore;

  /// Health Score неполный — выполнены не все применимые измерения (ADR-011)
  final _i3.bool healthIncomplete;

  final _i3.String? note;

  final _i4.TestResults results;

  @_i3.override
  _i3.Object? toJson() => {
    r'measured_at': measuredAt.toTimeZonedIso8601String(),
    r'device_id': deviceId,
    r'pv': pv,
    r'app_version': appVersion,
    r'rules_version': rulesVersion,
    r'firmware_version': firmwareVersion,
    r'health_score': healthScore,
    r'health_incomplete': healthIncomplete,
    r'note': note,
    r'results': results.toJson(),
  };

  $$TestMetaCopyWith<TestMeta> get copyWith => _TestMetaCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is TestMeta &&
        other.measuredAt == this.measuredAt &&
        other.deviceId == this.deviceId &&
        other.pv == this.pv &&
        other.appVersion == this.appVersion &&
        other.rulesVersion == this.rulesVersion &&
        other.firmwareVersion == this.firmwareVersion &&
        other.healthScore == this.healthScore &&
        other.healthIncomplete == this.healthIncomplete &&
        other.note == this.note &&
        other.results == this.results;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      measuredAt,
      deviceId,
      pv,
      appVersion,
      rulesVersion,
      firmwareVersion,
      healthScore,
      healthIncomplete,
      note,
      results,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for TestMeta: contains complex types',
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
      r'Cannot uriEncode TestMeta: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$TestMetaCopyWith<$Res> {
  factory $$TestMetaCopyWith(TestMeta value) = _TestMetaCopyWith<$Res>;

  $Res call({
    _i3.DateTime? measuredAt,
    _i3.String? deviceId,
    _i3.int? pv,
    _i3.String? appVersion,
    _i3.String? rulesVersion,
    _i3.String? firmwareVersion,
    _i3.int? healthScore,
    _i3.bool? healthIncomplete,
    _i3.String? note,
    _i4.TestResults? results,
  });
  _i3.DateTime get measuredAt;
  _i3.String get deviceId;
  _i3.int get pv;
  _i3.String get appVersion;
  _i3.String get rulesVersion;
  _i3.String? get firmwareVersion;
  _i3.int? get healthScore;
  _i3.bool get healthIncomplete;
  _i3.String? get note;
  _i4.TestResults get results;
}

class _TestMetaCopyWith<$Res> implements $$TestMetaCopyWith<$Res> {
  _TestMetaCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final TestMeta _value;

  @_i3.override
  _i3.DateTime get measuredAt => _value.measuredAt;

  @_i3.override
  _i3.String get deviceId => _value.deviceId;

  @_i3.override
  _i3.int get pv => _value.pv;

  @_i3.override
  _i3.String get appVersion => _value.appVersion;

  @_i3.override
  _i3.String get rulesVersion => _value.rulesVersion;

  @_i3.override
  _i3.String? get firmwareVersion => _value.firmwareVersion;

  @_i3.override
  _i3.int? get healthScore => _value.healthScore;

  @_i3.override
  _i3.bool get healthIncomplete => _value.healthIncomplete;

  @_i3.override
  _i3.String? get note => _value.note;

  @_i3.override
  _i4.TestResults get results => _value.results;

  @_i3.override
  $Res call({
    _i3.Object? measuredAt = _sentinel,
    _i3.Object? deviceId = _sentinel,
    _i3.Object? pv = _sentinel,
    _i3.Object? appVersion = _sentinel,
    _i3.Object? rulesVersion = _sentinel,
    _i3.Object? firmwareVersion = _sentinel,
    _i3.Object? healthScore = _sentinel,
    _i3.Object? healthIncomplete = _sentinel,
    _i3.Object? note = _sentinel,
    _i3.Object? results = _sentinel,
  }) {
    return (TestMeta(
      measuredAt: _i3.identical(measuredAt, _sentinel)
          ? this.measuredAt
          : (measuredAt as _i3.DateTime),
      deviceId: _i3.identical(deviceId, _sentinel)
          ? this.deviceId
          : (deviceId as _i3.String),
      pv: _i3.identical(pv, _sentinel) ? this.pv : (pv as _i3.int),
      appVersion: _i3.identical(appVersion, _sentinel)
          ? this.appVersion
          : (appVersion as _i3.String),
      rulesVersion: _i3.identical(rulesVersion, _sentinel)
          ? this.rulesVersion
          : (rulesVersion as _i3.String),
      firmwareVersion: _i3.identical(firmwareVersion, _sentinel)
          ? this.firmwareVersion
          : (firmwareVersion as _i3.String?),
      healthScore: _i3.identical(healthScore, _sentinel)
          ? this.healthScore
          : (healthScore as _i3.int?),
      healthIncomplete: _i3.identical(healthIncomplete, _sentinel)
          ? this.healthIncomplete
          : (healthIncomplete as _i3.bool),
      note: _i3.identical(note, _sentinel) ? this.note : (note as _i3.String?),
      results: _i3.identical(results, _sentinel)
          ? this.results
          : (results as _i4.TestResults),
    ) as $Res);
  }
}
