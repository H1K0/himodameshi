// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i6;
import 'package:himo_api/src/model/continuity_conductors_model.dart' as _i5;
import 'package:himo_api/src/model/continuity_status_model.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// Целостность. Состав проводников зависит от типа кабеля:
/// `jack_ts` — tip, sleeve; `jack_trs` — tip, ring, sleeve; `xlr` — pin1, pin2, pin3.
///
@_i2.immutable
class Continuity implements _i1.ParameterEncodable, _i1.UriEncodable {
  const Continuity({
    required this.status,
    required this.conductors,
    this.additionalProperties = const {},
  });

  factory Continuity.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for Continuity: contains complex types',
    );
  }

  factory Continuity.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Continuity');
    const _$knownKeys = {r'status', r'conductors'};
    final _$additional = <_i3.String, _i3.Object?>{};
    for (final _$entry in _$map.entries) {
      if (!_$knownKeys.contains(_$entry.key)) {
        _$additional[_$entry.key] = _$entry.value;
      }
    }
    return Continuity(
      status: _i4.ContinuityStatusModel.fromJson(_$map[r'status']),
      conductors: _i5.ContinuityConductorsModel.fromJson(_$map[r'conductors']),
      additionalProperties: _$additional,
    );
  }

  factory Continuity.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for Continuity: contains complex types',
    );
  }

  final _i4.ContinuityStatusModel status;

  final _i5.ContinuityConductorsModel conductors;

  final _i3.Map<_i3.String, _i3.Object?> additionalProperties;

  @_i3.override
  _i3.Object? toJson() {
    final _$map = <_i3.String, _i3.Object?>{
      r'status': status.toJson(),
      r'conductors': conductors.toJson(),
    };
    const _$knownKeys = {r'status', r'conductors'};
    for (final _$k in additionalProperties.keys) {
      if (_$knownKeys.contains(_$k)) {
        throw _i1.EncodingException(
          r'Additional property keys must not collide with declared wire keys of Continuity',
        );
      }
    }
    _$map.addAll(
      additionalProperties.map(
        (k, v) => _i3.MapEntry(
          k,
          _i1.encodeUnknownJson(v, context: r'Continuity.additionalProperties'),
        ),
      ),
    );
    return _$map;
  }

  $$ContinuityCopyWith<Continuity> get copyWith => _ContinuityCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i6.DeepCollectionEquality();
    return other is Continuity &&
        other.status == this.status &&
        other.conductors == this.conductors &&
        _$deepEquals.equals(
          other.additionalProperties,
          this.additionalProperties,
        );
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i6.DeepCollectionEquality();
    return _i3.Object.hashAll([
      status,
      conductors,
      deepEquals.hash(additionalProperties),
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for Continuity: contains complex types',
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
      r'Cannot uriEncode Continuity: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$ContinuityCopyWith<$Res> {
  factory $$ContinuityCopyWith(Continuity value) = _ContinuityCopyWith<$Res>;

  $Res call({
    _i4.ContinuityStatusModel? status,
    _i5.ContinuityConductorsModel? conductors,
    _i3.Map<_i3.String, _i3.Object?>? additionalProperties,
  });
  _i4.ContinuityStatusModel get status;
  _i5.ContinuityConductorsModel get conductors;
  _i3.Map<_i3.String, _i3.Object?> get additionalProperties;
}

class _ContinuityCopyWith<$Res> implements $$ContinuityCopyWith<$Res> {
  _ContinuityCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final Continuity _value;

  @_i3.override
  _i4.ContinuityStatusModel get status => _value.status;

  @_i3.override
  _i5.ContinuityConductorsModel get conductors => _value.conductors;

  @_i3.override
  _i3.Map<_i3.String, _i3.Object?> get additionalProperties =>
      _value.additionalProperties;

  @_i3.override
  $Res call({
    _i3.Object? status = _sentinel,
    _i3.Object? conductors = _sentinel,
    _i3.Object? additionalProperties = _sentinel,
  }) {
    return (Continuity(
      status: _i3.identical(status, _sentinel)
          ? this.status
          : (status as _i4.ContinuityStatusModel),
      conductors: _i3.identical(conductors, _sentinel)
          ? this.conductors
          : (conductors as _i5.ContinuityConductorsModel),
      additionalProperties: _i3.identical(additionalProperties, _sentinel)
          ? this.additionalProperties
          : (additionalProperties as _i3.Map<_i3.String, _i3.Object?>),
    ) as $Res);
  }
}
