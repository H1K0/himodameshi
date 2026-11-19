// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i5;
import 'package:himo_api/src/model/conductor_status.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class Conductor implements _i1.ParameterEncodable, _i1.UriEncodable {
  const Conductor({
    required this.r,
    required this.s,
    this.additionalProperties = const {},
  });

  factory Conductor.fromSimple(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'r', r's'},
      listKeys: {},
      context: r'Conductor',
      captureAdditionalKeys: true,
    );
    const _$knownKeys = {r'r', r's'};
    final _$additional = <_i3.String, _i3.Object?>{};
    for (final _$entry in _$values.entries) {
      if (!_$knownKeys.contains(_$entry.key)) {
        _$additional[_$entry.key] = _$entry.value;
      }
    }
    return Conductor(
      r: _$values[r'r'].decodeSimpleDouble(context: r'Conductor.r'),
      s: _i4.ConductorStatus.fromSimple(_$values[r's'], explode: explode),
      additionalProperties: _$additional,
    );
  }

  factory Conductor.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Conductor');
    const _$knownKeys = {r'r', r's'};
    final _$additional = <_i3.String, _i3.Object?>{};
    for (final _$entry in _$map.entries) {
      if (!_$knownKeys.contains(_$entry.key)) {
        _$additional[_$entry.key] = _$entry.value;
      }
    }
    return Conductor(
      r: _$map[r'r'].decodeJsonNum(context: r'Conductor.r'),
      s: _i4.ConductorStatus.fromJson(_$map[r's']),
      additionalProperties: _$additional,
    );
  }

  factory Conductor.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'r', r's'},
      listKeys: {},
      context: r'Conductor',
      captureAdditionalKeys: true,
    );
    const _$knownKeys = {r'r', r's'};
    final _$additional = <_i3.String, _i3.Object?>{};
    for (final _$entry in _$values.entries) {
      if (!_$knownKeys.contains(_$entry.key)) {
        _$additional[_$entry.key] = _$entry.value.decodeFormString(
          context: r'Conductor.additionalProperties',
        );
      }
    }
    return Conductor(
      r: _$values[r'r'].decodeFormDouble(context: r'Conductor.r'),
      s: _i4.ConductorStatus.fromForm(_$values[r's'], explode: explode),
      additionalProperties: _$additional,
    );
  }

  /// Сопротивление, Ом
  ///
  /// **Example**:
  /// ```json
  /// 0.91
  /// ```
  final _i3.num r;

  final _i4.ConductorStatus s;

  final _i3.Map<_i3.String, _i3.Object?> additionalProperties;

  @_i3.override
  _i3.Object? toJson() {
    final _$map = <_i3.String, _i3.Object?>{r'r': r, r's': s.toJson()};
    const _$knownKeys = {r'r', r's'};
    for (final _$k in additionalProperties.keys) {
      if (_$knownKeys.contains(_$k)) {
        throw _i1.EncodingException(
          r'Additional property keys must not collide with declared wire keys of Conductor',
        );
      }
    }
    _$map.addAll(
      additionalProperties.map(
        (k, v) => _i3.MapEntry(
          k,
          _i1.encodeUnknownJson(v, context: r'Conductor.additionalProperties'),
        ),
      ),
    );
    return _$map;
  }

  $$ConductorCopyWith<Conductor> get copyWith => _ConductorCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i5.DeepCollectionEquality();
    return other is Conductor &&
        other.r == this.r &&
        other.s == this.s &&
        _$deepEquals.equals(
          other.additionalProperties,
          this.additionalProperties,
        );
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i5.DeepCollectionEquality();
    return _i3.Object.hashAll([r, s, deepEquals.hash(additionalProperties)]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'r'] = _i1.PropertyValue.scalar(r.toString());
    _$result[r's'] = _i1.PropertyValue.scalar(s.toJson());
    const _$knownKeys = {r'r', r's'};
    for (final _$e in additionalProperties.entries) {
      if (_$knownKeys.contains(_$e.key)) {
        throw _i1.EncodingException(
          r'Additional property keys must not collide with declared wire keys of Conductor',
        );
      }
      final _$v = _$e.value;
      if (_$v == null) continue;
      _$result[_$e.key] = _i1.PropertyValue.scalar(
        _i1.encodeUnknownFlatScalar(
          _$v,
          context: r'Conductor.additionalProperties',
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
      r'Cannot uriEncode Conductor: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$ConductorCopyWith<$Res> {
  factory $$ConductorCopyWith(Conductor value) = _ConductorCopyWith<$Res>;

  $Res call({
    _i3.num? r,
    _i4.ConductorStatus? s,
    _i3.Map<_i3.String, _i3.Object?>? additionalProperties,
  });
  _i3.num get r;
  _i4.ConductorStatus get s;
  _i3.Map<_i3.String, _i3.Object?> get additionalProperties;
}

class _ConductorCopyWith<$Res> implements $$ConductorCopyWith<$Res> {
  _ConductorCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final Conductor _value;

  @_i3.override
  _i3.num get r => _value.r;

  @_i3.override
  _i4.ConductorStatus get s => _value.s;

  @_i3.override
  _i3.Map<_i3.String, _i3.Object?> get additionalProperties =>
      _value.additionalProperties;

  @_i3.override
  $Res call({
    _i3.Object? r = _sentinel,
    _i3.Object? s = _sentinel,
    _i3.Object? additionalProperties = _sentinel,
  }) {
    return (Conductor(
      r: _i3.identical(r, _sentinel) ? this.r : (r as _i3.num),
      s: _i3.identical(s, _sentinel) ? this.s : (s as _i4.ConductorStatus),
      additionalProperties: _i3.identical(additionalProperties, _sentinel)
          ? this.additionalProperties
          : (additionalProperties as _i3.Map<_i3.String, _i3.Object?>),
    ) as $Res);
  }
}
