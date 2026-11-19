// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i5;
import 'package:himo_api/src/model/cable.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class CablePage implements _i1.ParameterEncodable, _i1.UriEncodable {
  const CablePage({required this.items, required this.total});

  factory CablePage.fromSimple(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for CablePage: contains complex types',
    );
  }

  factory CablePage.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'CablePage');
    return CablePage(
      items: _$map[r'items']
          .decodeJsonList<_i3.Object?>(context: r'CablePage.items')
          .map(_i4.Cable.fromJson)
          .toList(),
      total: _$map[r'total'].decodeJsonInt(context: r'CablePage.total'),
    );
  }

  factory CablePage.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for CablePage: contains complex types',
    );
  }

  final _i3.List<_i4.Cable> items;

  final _i3.int total;

  @_i3.override
  _i3.Object? toJson() => {
    r'items': items.map((e) => e.toJson()).toList(),
    r'total': total,
  };

  $$CablePageCopyWith<CablePage> get copyWith => _CablePageCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i5.DeepCollectionEquality();
    return other is CablePage &&
        _$deepEquals.equals(other.items, this.items) &&
        other.total == this.total;
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i5.DeepCollectionEquality();
    return _i3.Object.hashAll([deepEquals.hash(items), total]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for CablePage: contains complex types',
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
      r'Cannot uriEncode CablePage: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$CablePageCopyWith<$Res> {
  factory $$CablePageCopyWith(CablePage value) = _CablePageCopyWith<$Res>;

  $Res call({_i3.List<_i4.Cable>? items, _i3.int? total});
  _i3.List<_i4.Cable> get items;
  _i3.int get total;
}

class _CablePageCopyWith<$Res> implements $$CablePageCopyWith<$Res> {
  _CablePageCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final CablePage _value;

  @_i3.override
  _i3.List<_i4.Cable> get items => _value.items;

  @_i3.override
  _i3.int get total => _value.total;

  @_i3.override
  $Res call({_i3.Object? items = _sentinel, _i3.Object? total = _sentinel}) {
    return (CablePage(
      items: _i3.identical(items, _sentinel)
          ? this.items
          : (items as _i3.List<_i4.Cable>),
      total: _i3.identical(total, _sentinel) ? this.total : (total as _i3.int),
    ) as $Res);
  }
}
