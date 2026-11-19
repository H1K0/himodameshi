// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/uuid.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class CableUpdateItemModel implements _i1.ParameterEncodable, _i1.UriEncodable {
  const CableUpdateItemModel({required this.id});

  factory CableUpdateItemModel.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'id'},
      listKeys: {},
      context: r'CableUpdateItemModel',
    );
    return CableUpdateItemModel(
      id: _$values[r'id'].decodeSimpleString(
        context: r'CableUpdateItemModel.id',
      ),
    );
  }

  factory CableUpdateItemModel.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'CableUpdateItemModel');
    return CableUpdateItemModel(
      id: _$map[r'id'].decodeJsonString(context: r'CableUpdateItemModel.id'),
    );
  }

  factory CableUpdateItemModel.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'id'},
      listKeys: {},
      context: r'CableUpdateItemModel',
    );
    return CableUpdateItemModel(
      id: _$values[r'id'].decodeFormString(context: r'CableUpdateItemModel.id'),
    );
  }

  final _i4.Uuid id;

  @_i3.override
  _i3.Object? toJson() => {r'id': id};

  $$CableUpdateItemModelCopyWith<CableUpdateItemModel> get copyWith =>
      _CableUpdateItemModelCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CableUpdateItemModel && other.id == this.id;
  }

  @_i3.override
  _i3.int get hashCode => id.hashCode;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(id);
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
      r'Cannot uriEncode CableUpdateItemModel: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$CableUpdateItemModelCopyWith<$Res> {
  factory $$CableUpdateItemModelCopyWith(CableUpdateItemModel value) =
      _CableUpdateItemModelCopyWith<$Res>;

  $Res call({_i4.Uuid? id});
  _i4.Uuid get id;
}

class _CableUpdateItemModelCopyWith<$Res>
    implements $$CableUpdateItemModelCopyWith<$Res> {
  _CableUpdateItemModelCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final CableUpdateItemModel _value;

  @_i3.override
  _i4.Uuid get id => _value.id;

  @_i3.override
  $Res call({_i3.Object? id = _sentinel}) {
    return (CableUpdateItemModel(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i4.Uuid),
    ) as $Res);
  }
}
