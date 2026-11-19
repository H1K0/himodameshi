// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/uuid.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class NewTestModel implements _i1.ParameterEncodable, _i1.UriEncodable {
  const NewTestModel({required this.id, required this.cableId});

  factory NewTestModel.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'id', r'cable_id'},
      listKeys: {},
      context: r'NewTestModel',
    );
    return NewTestModel(
      id: _$values[r'id'].decodeSimpleString(context: r'NewTestModel.id'),
      cableId: _$values[r'cable_id'].decodeSimpleString(
        context: r'NewTestModel.cable_id',
      ),
    );
  }

  factory NewTestModel.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'NewTestModel');
    return NewTestModel(
      id: _$map[r'id'].decodeJsonString(context: r'NewTestModel.id'),
      cableId: _$map[r'cable_id'].decodeJsonString(
        context: r'NewTestModel.cable_id',
      ),
    );
  }

  factory NewTestModel.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'id', r'cable_id'},
      listKeys: {},
      context: r'NewTestModel',
    );
    return NewTestModel(
      id: _$values[r'id'].decodeFormString(context: r'NewTestModel.id'),
      cableId: _$values[r'cable_id'].decodeFormString(
        context: r'NewTestModel.cable_id',
      ),
    );
  }

  final _i4.Uuid id;

  final _i4.Uuid cableId;

  @_i3.override
  _i3.Object? toJson() => {r'id': id, r'cable_id': cableId};

  $$NewTestModelCopyWith<NewTestModel> get copyWith =>
      _NewTestModelCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is NewTestModel &&
        other.id == this.id &&
        other.cableId == this.cableId;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([id, cableId]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(id);
    _$result[r'cable_id'] = _i1.PropertyValue.scalar(cableId);
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
      r'Cannot uriEncode NewTestModel: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$NewTestModelCopyWith<$Res> {
  factory $$NewTestModelCopyWith(NewTestModel value) =
      _NewTestModelCopyWith<$Res>;

  $Res call({_i4.Uuid? id, _i4.Uuid? cableId});
  _i4.Uuid get id;
  _i4.Uuid get cableId;
}

class _NewTestModelCopyWith<$Res> implements $$NewTestModelCopyWith<$Res> {
  _NewTestModelCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final NewTestModel _value;

  @_i3.override
  _i4.Uuid get id => _value.id;

  @_i3.override
  _i4.Uuid get cableId => _value.cableId;

  @_i3.override
  $Res call({_i3.Object? id = _sentinel, _i3.Object? cableId = _sentinel}) {
    return (NewTestModel(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i4.Uuid),
      cableId: _i3.identical(cableId, _sentinel)
          ? this.cableId
          : (cableId as _i4.Uuid),
    ) as $Res);
  }
}
