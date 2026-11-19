// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/cable_update.dart' as _i4;
import 'package:himo_api/src/model/cable_update_item_model.dart' as _i5;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// Правка атрибутов кабеля в пакете выгрузки
@_i2.immutable
class CableUpdateItem implements _i1.ParameterEncodable, _i1.UriEncodable {
  const CableUpdateItem({
    required this.cableUpdate,
    required this.cableUpdateItemModel,
  });

  factory CableUpdateItem.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    return CableUpdateItem(
      cableUpdate: _i4.CableUpdate.fromSimple(value, explode: explode),
      cableUpdateItemModel: _i5.CableUpdateItemModel.fromSimple(
        value,
        explode: explode,
      ),
    );
  }

  factory CableUpdateItem.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    return CableUpdateItem(
      cableUpdate: _i4.CableUpdate.fromForm(value, explode: explode),
      cableUpdateItemModel: _i5.CableUpdateItemModel.fromForm(
        value,
        explode: explode,
      ),
    );
  }

  factory CableUpdateItem.fromJson(_i3.Object? json) {
    return CableUpdateItem(
      cableUpdate: _i4.CableUpdate.fromJson(json),
      cableUpdateItemModel: _i5.CableUpdateItemModel.fromJson(json),
    );
  }

  final _i4.CableUpdate cableUpdate;

  final _i5.CableUpdateItemModel cableUpdateItemModel;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Object? toJson() {
    final _$map = <_i3.String, _i3.Object?>{};
    final _$cableUpdateJson = cableUpdate.toJson();
    if (_$cableUpdateJson is! _i3.Map<_i3.String, _i3.Object?>) {
      throw _i1.EncodingException(
        'Expected cableUpdate.toJson() to return Map<String, Object?>, got ${_$cableUpdateJson.runtimeType}',
      );
    }
    _$map.addAll(_$cableUpdateJson);
    final _$cableUpdateItemModelJson = cableUpdateItemModel.toJson();
    if (_$cableUpdateItemModelJson is! _i3.Map<_i3.String, _i3.Object?>) {
      throw _i1.EncodingException(
        'Expected cableUpdateItemModel.toJson() to return Map<String, Object?>, got ${_$cableUpdateItemModelJson.runtimeType}',
      );
    }
    _$map.addAll(_$cableUpdateItemModelJson);
    return _$map;
  }

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$mergedProperties = <_i3.String, _i1.PropertyValue>{};
    _$mergedProperties.addAll(
      cableUpdate.parameterProperties(allowEmpty: allowEmpty),
    );
    _$mergedProperties.addAll(
      cableUpdateItemModel.parameterProperties(allowEmpty: allowEmpty),
    );
    return _$mergedProperties;
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
      r'Cannot uriEncode CableUpdateItem: contains complex types',
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CableUpdateItem &&
        other.cableUpdate == this.cableUpdate &&
        other.cableUpdateItemModel == this.cableUpdateItemModel;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([cableUpdate, cableUpdateItemModel]);
  }

  $$CableUpdateItemCopyWith<CableUpdateItem> get copyWith =>
      _CableUpdateItemCopyWith(this);
}

abstract class $$CableUpdateItemCopyWith<$Res> {
  factory $$CableUpdateItemCopyWith(CableUpdateItem value) =
      _CableUpdateItemCopyWith<$Res>;

  $Res call({
    _i4.CableUpdate? cableUpdate,
    _i5.CableUpdateItemModel? cableUpdateItemModel,
  });
  _i4.CableUpdate get cableUpdate;
  _i5.CableUpdateItemModel get cableUpdateItemModel;
}

class _CableUpdateItemCopyWith<$Res>
    implements $$CableUpdateItemCopyWith<$Res> {
  _CableUpdateItemCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final CableUpdateItem _value;

  @_i3.override
  _i4.CableUpdate get cableUpdate => _value.cableUpdate;

  @_i3.override
  _i5.CableUpdateItemModel get cableUpdateItemModel =>
      _value.cableUpdateItemModel;

  @_i3.override
  $Res call({
    _i3.Object? cableUpdate = _sentinel,
    _i3.Object? cableUpdateItemModel = _sentinel,
  }) {
    return (CableUpdateItem(
      cableUpdate: _i3.identical(cableUpdate, _sentinel)
          ? this.cableUpdate
          : (cableUpdate as _i4.CableUpdate),
      cableUpdateItemModel: _i3.identical(cableUpdateItemModel, _sentinel)
          ? this.cableUpdateItemModel
          : (cableUpdateItemModel as _i5.CableUpdateItemModel),
    ) as $Res);
  }
}
