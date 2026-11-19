// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i5;
import 'package:himo_api/src/model/freq_response_status_model.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// АЧХ — отклонения относительно 1 кГц в точках таблицы частот версии протокола `pv`
@_i2.immutable
class FreqResponse implements _i1.ParameterEncodable, _i1.UriEncodable {
  const FreqResponse({
    required this.status,
    required this.v,
    this.f,
    this.additionalProperties = const {},
  });

  factory FreqResponse.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'status', r'v', r'f'},
      listKeys: {r'v', r'f'},
      context: r'FreqResponse',
      captureAdditionalKeys: true,
    );
    const _$knownKeys = {r'status', r'v', r'f'};
    final _$additional = <_i3.String, _i3.Object?>{};
    for (final _$entry in _$values.entries) {
      if (!_$knownKeys.contains(_$entry.key)) {
        _$additional[_$entry.key] = _$entry.value;
      }
    }
    return FreqResponse(
      status: _i4.FreqResponseStatusModel.fromSimple(
        _$values[r'status'],
        explode: explode,
      ),
      v: _$values[r'v']
          .decodeSimpleStringList(context: r'FreqResponse.v')
          .map((e) => e.decodeSimpleDouble(context: r'FreqResponse.v'))
          .toList(),
      f: _$values[r'f']
          .decodeSimpleNullableStringList(context: r'FreqResponse.f')
          ?.map((e) => e.decodeSimpleInt(context: r'FreqResponse.f'))
          .toList(),
      additionalProperties: _$additional,
    );
  }

  factory FreqResponse.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'FreqResponse');
    const _$knownKeys = {r'status', r'v', r'f'};
    final _$additional = <_i3.String, _i3.Object?>{};
    for (final _$entry in _$map.entries) {
      if (!_$knownKeys.contains(_$entry.key)) {
        _$additional[_$entry.key] = _$entry.value;
      }
    }
    return FreqResponse(
      status: _i4.FreqResponseStatusModel.fromJson(_$map[r'status']),
      v: _$map[r'v'].decodeJsonList<_i3.num>(context: r'FreqResponse.v'),
      f: _$map[r'f'].decodeJsonNullableList<_i3.int>(
        context: r'FreqResponse.f',
      ),
      additionalProperties: _$additional,
    );
  }

  factory FreqResponse.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'status', r'v', r'f'},
      listKeys: {r'v', r'f'},
      context: r'FreqResponse',
      captureAdditionalKeys: true,
    );
    const _$knownKeys = {r'status', r'v', r'f'};
    final _$additional = <_i3.String, _i3.Object?>{};
    for (final _$entry in _$values.entries) {
      if (!_$knownKeys.contains(_$entry.key)) {
        _$additional[_$entry.key] = _$entry.value.decodeFormString(
          context: r'FreqResponse.additionalProperties',
        );
      }
    }
    return FreqResponse(
      status: _i4.FreqResponseStatusModel.fromForm(
        _$values[r'status'],
        explode: explode,
      ),
      v: _$values[r'v']
          .decodeFormStringList(context: r'FreqResponse.v')
          .map((e) => e.decodeFormDouble(context: r'FreqResponse.v'))
          .toList(),
      f: _$values[r'f']
          .decodeFormNullableStringList(context: r'FreqResponse.f')
          ?.map((e) => e.decodeFormInt(context: r'FreqResponse.f'))
          .toList(),
      additionalProperties: _$additional,
    );
  }

  final _i4.FreqResponseStatusModel status;

  /// Отклонения, дБ; для `pv = 1` — 30 точек
  final _i3.List<_i3.num> v;

  /// Частоты, Гц, в том же порядке, что `v`; добавляет сервер по `pv` теста
  final _i3.List<_i3.int>? f;

  final _i3.Map<_i3.String, _i3.Object?> additionalProperties;

  @_i3.override
  _i3.Object? toJson() {
    final _$map = <_i3.String, _i3.Object?>{
      r'status': status.toJson(),
      r'v': v,
    };
    const _$knownKeys = {r'status', r'v', r'f'};
    for (final _$k in additionalProperties.keys) {
      if (_$knownKeys.contains(_$k)) {
        throw _i1.EncodingException(
          r'Additional property keys must not collide with declared wire keys of FreqResponse',
        );
      }
    }
    _$map.addAll(
      additionalProperties.map(
        (k, v) => _i3.MapEntry(
          k,
          _i1.encodeUnknownJson(
            v,
            context: r'FreqResponse.additionalProperties',
          ),
        ),
      ),
    );
    return _$map;
  }

  $$FreqResponseCopyWith<FreqResponse> get copyWith =>
      _FreqResponseCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i5.DeepCollectionEquality();
    return other is FreqResponse &&
        other.status == this.status &&
        _$deepEquals.equals(other.v, this.v) &&
        _$deepEquals.equals(other.f, this.f) &&
        _$deepEquals.equals(
          other.additionalProperties,
          this.additionalProperties,
        );
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i5.DeepCollectionEquality();
    return _i3.Object.hashAll([
      status,
      deepEquals.hash(v),
      deepEquals.hash(f),
      deepEquals.hash(additionalProperties),
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'status'] = _i1.PropertyValue.scalar(status.toJson());
    _$result[r'v'] = _i1.PropertyValue.array(
      v.map((e) => e.toString()).toList(),
    );
    const _$knownKeys = {r'status', r'v', r'f'};
    for (final _$e in additionalProperties.entries) {
      if (_$knownKeys.contains(_$e.key)) {
        throw _i1.EncodingException(
          r'Additional property keys must not collide with declared wire keys of FreqResponse',
        );
      }
      final _$v = _$e.value;
      if (_$v == null) continue;
      _$result[_$e.key] = _i1.PropertyValue.scalar(
        _i1.encodeUnknownFlatScalar(
          _$v,
          context: r'FreqResponse.additionalProperties',
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
      r'Cannot uriEncode FreqResponse: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$FreqResponseCopyWith<$Res> {
  factory $$FreqResponseCopyWith(FreqResponse value) =
      _FreqResponseCopyWith<$Res>;

  $Res call({
    _i4.FreqResponseStatusModel? status,
    _i3.List<_i3.num>? v,
    _i3.List<_i3.int>? f,
    _i3.Map<_i3.String, _i3.Object?>? additionalProperties,
  });
  _i4.FreqResponseStatusModel get status;
  _i3.List<_i3.num> get v;
  _i3.List<_i3.int>? get f;
  _i3.Map<_i3.String, _i3.Object?> get additionalProperties;
}

class _FreqResponseCopyWith<$Res> implements $$FreqResponseCopyWith<$Res> {
  _FreqResponseCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final FreqResponse _value;

  @_i3.override
  _i4.FreqResponseStatusModel get status => _value.status;

  @_i3.override
  _i3.List<_i3.num> get v => _value.v;

  @_i3.override
  _i3.List<_i3.int>? get f => _value.f;

  @_i3.override
  _i3.Map<_i3.String, _i3.Object?> get additionalProperties =>
      _value.additionalProperties;

  @_i3.override
  $Res call({
    _i3.Object? status = _sentinel,
    _i3.Object? v = _sentinel,
    _i3.Object? f = _sentinel,
    _i3.Object? additionalProperties = _sentinel,
  }) {
    return (FreqResponse(
      status: _i3.identical(status, _sentinel)
          ? this.status
          : (status as _i4.FreqResponseStatusModel),
      v: _i3.identical(v, _sentinel) ? this.v : (v as _i3.List<_i3.num>),
      f: _i3.identical(f, _sentinel) ? this.f : (f as _i3.List<_i3.int>?),
      additionalProperties: _i3.identical(additionalProperties, _sentinel)
          ? this.additionalProperties
          : (additionalProperties as _i3.Map<_i3.String, _i3.Object?>),
    ) as $Res);
  }
}
