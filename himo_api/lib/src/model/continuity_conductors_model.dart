// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/conductor.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class ContinuityConductorsModel
    implements _i1.ParameterEncodable, _i1.UriEncodable {
  const ContinuityConductorsModel({
    this.tip,
    this.ring,
    this.sleeve,
    this.pin1,
    this.pin2,
    this.pin3,
  });

  factory ContinuityConductorsModel.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for ContinuityConductorsModel: contains complex types',
    );
  }

  factory ContinuityConductorsModel.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'ContinuityConductorsModel');
    return ContinuityConductorsModel(
      tip: _$map[r'tip'] == null ? null : _i4.Conductor.fromJson(_$map[r'tip']),
      ring: _$map[r'ring'] == null
          ? null
          : _i4.Conductor.fromJson(_$map[r'ring']),
      sleeve: _$map[r'sleeve'] == null
          ? null
          : _i4.Conductor.fromJson(_$map[r'sleeve']),
      pin1: _$map[r'pin1'] == null
          ? null
          : _i4.Conductor.fromJson(_$map[r'pin1']),
      pin2: _$map[r'pin2'] == null
          ? null
          : _i4.Conductor.fromJson(_$map[r'pin2']),
      pin3: _$map[r'pin3'] == null
          ? null
          : _i4.Conductor.fromJson(_$map[r'pin3']),
    );
  }

  factory ContinuityConductorsModel.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for ContinuityConductorsModel: contains complex types',
    );
  }

  final _i4.Conductor? tip;

  final _i4.Conductor? ring;

  final _i4.Conductor? sleeve;

  final _i4.Conductor? pin1;

  final _i4.Conductor? pin2;

  final _i4.Conductor? pin3;

  @_i3.override
  _i3.Object? toJson() => {
    if (tip != null) r'tip': tip?.toJson(),
    if (ring != null) r'ring': ring?.toJson(),
    if (sleeve != null) r'sleeve': sleeve?.toJson(),
    if (pin1 != null) r'pin1': pin1?.toJson(),
    if (pin2 != null) r'pin2': pin2?.toJson(),
    if (pin3 != null) r'pin3': pin3?.toJson(),
  };

  $$ContinuityConductorsModelCopyWith<ContinuityConductorsModel> get copyWith =>
      _ContinuityConductorsModelCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ContinuityConductorsModel &&
        other.tip == this.tip &&
        other.ring == this.ring &&
        other.sleeve == this.sleeve &&
        other.pin1 == this.pin1 &&
        other.pin2 == this.pin2 &&
        other.pin3 == this.pin3;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([tip, ring, sleeve, pin1, pin2, pin3]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for ContinuityConductorsModel: contains complex types',
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
      r'Cannot uriEncode ContinuityConductorsModel: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$ContinuityConductorsModelCopyWith<$Res> {
  factory $$ContinuityConductorsModelCopyWith(ContinuityConductorsModel value) =
      _ContinuityConductorsModelCopyWith<$Res>;

  $Res call({
    _i4.Conductor? tip,
    _i4.Conductor? ring,
    _i4.Conductor? sleeve,
    _i4.Conductor? pin1,
    _i4.Conductor? pin2,
    _i4.Conductor? pin3,
  });
  _i4.Conductor? get tip;
  _i4.Conductor? get ring;
  _i4.Conductor? get sleeve;
  _i4.Conductor? get pin1;
  _i4.Conductor? get pin2;
  _i4.Conductor? get pin3;
}

class _ContinuityConductorsModelCopyWith<$Res>
    implements $$ContinuityConductorsModelCopyWith<$Res> {
  _ContinuityConductorsModelCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final ContinuityConductorsModel _value;

  @_i3.override
  _i4.Conductor? get tip => _value.tip;

  @_i3.override
  _i4.Conductor? get ring => _value.ring;

  @_i3.override
  _i4.Conductor? get sleeve => _value.sleeve;

  @_i3.override
  _i4.Conductor? get pin1 => _value.pin1;

  @_i3.override
  _i4.Conductor? get pin2 => _value.pin2;

  @_i3.override
  _i4.Conductor? get pin3 => _value.pin3;

  @_i3.override
  $Res call({
    _i3.Object? tip = _sentinel,
    _i3.Object? ring = _sentinel,
    _i3.Object? sleeve = _sentinel,
    _i3.Object? pin1 = _sentinel,
    _i3.Object? pin2 = _sentinel,
    _i3.Object? pin3 = _sentinel,
  }) {
    return (ContinuityConductorsModel(
      tip: _i3.identical(tip, _sentinel) ? this.tip : (tip as _i4.Conductor?),
      ring: _i3.identical(ring, _sentinel)
          ? this.ring
          : (ring as _i4.Conductor?),
      sleeve: _i3.identical(sleeve, _sentinel)
          ? this.sleeve
          : (sleeve as _i4.Conductor?),
      pin1: _i3.identical(pin1, _sentinel)
          ? this.pin1
          : (pin1 as _i4.Conductor?),
      pin2: _i3.identical(pin2, _sentinel)
          ? this.pin2
          : (pin2 as _i4.Conductor?),
      pin3: _i3.identical(pin3, _sentinel)
          ? this.pin3
          : (pin3 as _i4.Conductor?),
    ) as $Res);
  }
}
