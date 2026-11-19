// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i5;
import 'package:himo_api/src/model/cmrr_status_model.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// CMRR — только для `jack_trs` и `xlr`
@_i2.immutable
class Cmrr implements _i1.ParameterEncodable, _i1.UriEncodable {
  const Cmrr({
    required this.status,
    required this.cmrrDb,
    this.additionalProperties = const {},
  });

  factory Cmrr.fromSimple(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'status', r'cmrr_db'},
      listKeys: {},
      context: r'Cmrr',
      captureAdditionalKeys: true,
    );
    const _$knownKeys = {r'status', r'cmrr_db'};
    final _$additional = <_i3.String, _i3.Object?>{};
    for (final _$entry in _$values.entries) {
      if (!_$knownKeys.contains(_$entry.key)) {
        _$additional[_$entry.key] = _$entry.value;
      }
    }
    return Cmrr(
      status: _i4.CmrrStatusModel.fromSimple(
        _$values[r'status'],
        explode: explode,
      ),
      cmrrDb: _$values[r'cmrr_db'].decodeSimpleDouble(context: r'Cmrr.cmrr_db'),
      additionalProperties: _$additional,
    );
  }

  factory Cmrr.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Cmrr');
    const _$knownKeys = {r'status', r'cmrr_db'};
    final _$additional = <_i3.String, _i3.Object?>{};
    for (final _$entry in _$map.entries) {
      if (!_$knownKeys.contains(_$entry.key)) {
        _$additional[_$entry.key] = _$entry.value;
      }
    }
    return Cmrr(
      status: _i4.CmrrStatusModel.fromJson(_$map[r'status']),
      cmrrDb: _$map[r'cmrr_db'].decodeJsonNum(context: r'Cmrr.cmrr_db'),
      additionalProperties: _$additional,
    );
  }

  factory Cmrr.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'status', r'cmrr_db'},
      listKeys: {},
      context: r'Cmrr',
      captureAdditionalKeys: true,
    );
    const _$knownKeys = {r'status', r'cmrr_db'};
    final _$additional = <_i3.String, _i3.Object?>{};
    for (final _$entry in _$values.entries) {
      if (!_$knownKeys.contains(_$entry.key)) {
        _$additional[_$entry.key] = _$entry.value.decodeFormString(
          context: r'Cmrr.additionalProperties',
        );
      }
    }
    return Cmrr(
      status: _i4.CmrrStatusModel.fromForm(
        _$values[r'status'],
        explode: explode,
      ),
      cmrrDb: _$values[r'cmrr_db'].decodeFormDouble(context: r'Cmrr.cmrr_db'),
      additionalProperties: _$additional,
    );
  }

  /// `excellent` — более 60 дБ, `ok` — 40–60 дБ, `fail` — менее 40 дБ
  final _i4.CmrrStatusModel status;

  /// **Example**:
  /// ```json
  /// 72.4
  /// ```
  final _i3.num cmrrDb;

  final _i3.Map<_i3.String, _i3.Object?> additionalProperties;

  @_i3.override
  _i3.Object? toJson() {
    final _$map = <_i3.String, _i3.Object?>{
      r'status': status.toJson(),
      r'cmrr_db': cmrrDb,
    };
    const _$knownKeys = {r'status', r'cmrr_db'};
    for (final _$k in additionalProperties.keys) {
      if (_$knownKeys.contains(_$k)) {
        throw _i1.EncodingException(
          r'Additional property keys must not collide with declared wire keys of Cmrr',
        );
      }
    }
    _$map.addAll(
      additionalProperties.map(
        (k, v) => _i3.MapEntry(
          k,
          _i1.encodeUnknownJson(v, context: r'Cmrr.additionalProperties'),
        ),
      ),
    );
    return _$map;
  }

  $$CmrrCopyWith<Cmrr> get copyWith => _CmrrCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i5.DeepCollectionEquality();
    return other is Cmrr &&
        other.status == this.status &&
        other.cmrrDb == this.cmrrDb &&
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
      cmrrDb,
      deepEquals.hash(additionalProperties),
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'status'] = _i1.PropertyValue.scalar(status.toJson());
    _$result[r'cmrr_db'] = _i1.PropertyValue.scalar(cmrrDb.toString());
    const _$knownKeys = {r'status', r'cmrr_db'};
    for (final _$e in additionalProperties.entries) {
      if (_$knownKeys.contains(_$e.key)) {
        throw _i1.EncodingException(
          r'Additional property keys must not collide with declared wire keys of Cmrr',
        );
      }
      final _$v = _$e.value;
      if (_$v == null) continue;
      _$result[_$e.key] = _i1.PropertyValue.scalar(
        _i1.encodeUnknownFlatScalar(_$v, context: r'Cmrr.additionalProperties'),
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
      r'Cannot uriEncode Cmrr: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$CmrrCopyWith<$Res> {
  factory $$CmrrCopyWith(Cmrr value) = _CmrrCopyWith<$Res>;

  $Res call({
    _i4.CmrrStatusModel? status,
    _i3.num? cmrrDb,
    _i3.Map<_i3.String, _i3.Object?>? additionalProperties,
  });
  _i4.CmrrStatusModel get status;
  _i3.num get cmrrDb;
  _i3.Map<_i3.String, _i3.Object?> get additionalProperties;
}

class _CmrrCopyWith<$Res> implements $$CmrrCopyWith<$Res> {
  _CmrrCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final Cmrr _value;

  @_i3.override
  _i4.CmrrStatusModel get status => _value.status;

  @_i3.override
  _i3.num get cmrrDb => _value.cmrrDb;

  @_i3.override
  _i3.Map<_i3.String, _i3.Object?> get additionalProperties =>
      _value.additionalProperties;

  @_i3.override
  $Res call({
    _i3.Object? status = _sentinel,
    _i3.Object? cmrrDb = _sentinel,
    _i3.Object? additionalProperties = _sentinel,
  }) {
    return (Cmrr(
      status: _i3.identical(status, _sentinel)
          ? this.status
          : (status as _i4.CmrrStatusModel),
      cmrrDb: _i3.identical(cmrrDb, _sentinel)
          ? this.cmrrDb
          : (cmrrDb as _i3.num),
      additionalProperties: _i3.identical(additionalProperties, _sentinel)
          ? this.additionalProperties
          : (additionalProperties as _i3.Map<_i3.String, _i3.Object?>),
    ) as $Res);
  }
}
