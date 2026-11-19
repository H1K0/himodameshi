// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/cable.dart' as _i6;
import 'package:himo_api/src/model/item_error.dart' as _i5;
import 'package:himo_api/src/model/item_status.dart' as _i4;
import 'package:himo_api/src/model/uuid.dart' as _i7;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// Результат по новому кабелю или правке. `cable` — состояние кабеля на сервере:
/// при `accepted` и при отказе `version_conflict`.
///
@_i2.immutable
class PushCableResult implements _i1.ParameterEncodable, _i1.UriEncodable {
  const PushCableResult({
    required this.id,
    required this.status,
    this.error,
    this.cable,
  });

  factory PushCableResult.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for PushCableResult: contains complex types',
    );
  }

  factory PushCableResult.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'PushCableResult');
    return PushCableResult(
      id: _$map[r'id'].decodeJsonString(context: r'PushCableResult.id'),
      status: _i4.ItemStatus.fromJson(_$map[r'status']),
      error: _$map[r'error'] == null
          ? null
          : _i5.ItemError.fromJson(_$map[r'error']),
      cable: _$map[r'cable'] == null
          ? null
          : _i6.Cable.fromJson(_$map[r'cable']),
    );
  }

  factory PushCableResult.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for PushCableResult: contains complex types',
    );
  }

  final _i7.Uuid id;

  final _i4.ItemStatus status;

  final _i5.ItemError? error;

  final _i6.Cable? cable;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': id,
    r'status': status.toJson(),
    if (error != null) r'error': error?.toJson(),
    if (cable != null) r'cable': cable?.toJson(),
  };

  $$PushCableResultCopyWith<PushCableResult> get copyWith =>
      _PushCableResultCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is PushCableResult &&
        other.id == this.id &&
        other.status == this.status &&
        other.error == this.error &&
        other.cable == this.cable;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([id, status, error, cable]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for PushCableResult: contains complex types',
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
      r'Cannot uriEncode PushCableResult: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$PushCableResultCopyWith<$Res> {
  factory $$PushCableResultCopyWith(PushCableResult value) =
      _PushCableResultCopyWith<$Res>;

  $Res call({
    _i7.Uuid? id,
    _i4.ItemStatus? status,
    _i5.ItemError? error,
    _i6.Cable? cable,
  });
  _i7.Uuid get id;
  _i4.ItemStatus get status;
  _i5.ItemError? get error;
  _i6.Cable? get cable;
}

class _PushCableResultCopyWith<$Res>
    implements $$PushCableResultCopyWith<$Res> {
  _PushCableResultCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final PushCableResult _value;

  @_i3.override
  _i7.Uuid get id => _value.id;

  @_i3.override
  _i4.ItemStatus get status => _value.status;

  @_i3.override
  _i5.ItemError? get error => _value.error;

  @_i3.override
  _i6.Cable? get cable => _value.cable;

  @_i3.override
  $Res call({
    _i3.Object? id = _sentinel,
    _i3.Object? status = _sentinel,
    _i3.Object? error = _sentinel,
    _i3.Object? cable = _sentinel,
  }) {
    return (PushCableResult(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i7.Uuid),
      status: _i3.identical(status, _sentinel)
          ? this.status
          : (status as _i4.ItemStatus),
      error: _i3.identical(error, _sentinel)
          ? this.error
          : (error as _i5.ItemError?),
      cable: _i3.identical(cable, _sentinel)
          ? this.cable
          : (cable as _i6.Cable?),
    ) as $Res);
  }
}
