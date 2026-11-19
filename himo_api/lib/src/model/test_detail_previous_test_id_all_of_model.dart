// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/uuid.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// Предыдущий действительный тест кабеля или `null`
@_i2.immutable
class $RawTestDetailPreviousTestIdAllOfModel
    implements _i1.ParameterEncodable, _i1.UriEncodable {
  const $RawTestDetailPreviousTestIdAllOfModel({required this.uuid});

  factory $RawTestDetailPreviousTestIdAllOfModel.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    return $RawTestDetailPreviousTestIdAllOfModel(
      uuid: value.decodeSimpleString(
        context: r'$RawTestDetailPreviousTestIdAllOfModel.uuid',
      ),
    );
  }

  factory $RawTestDetailPreviousTestIdAllOfModel.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    return $RawTestDetailPreviousTestIdAllOfModel(
      uuid: value.decodeFormString(
        context: r'$RawTestDetailPreviousTestIdAllOfModel.uuid',
      ),
    );
  }

  factory $RawTestDetailPreviousTestIdAllOfModel.fromJson(_i3.Object? json) {
    return $RawTestDetailPreviousTestIdAllOfModel(
      uuid: json.decodeJsonString(
        context: r'$RawTestDetailPreviousTestIdAllOfModel',
      ),
    );
  }

  final _i4.Uuid uuid;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.simple;

  @_i3.override
  _i3.Object? toJson() => uuid;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    throw _i1.EncodingException(
      r'parameterProperties not supported for $RawTestDetailPreviousTestIdAllOfModel: contains primitive types',
    );
  }

  @_i3.override
  _i3.String toSimple({
    required _i3.bool explode,
    required _i3.bool allowEmpty,
    _i3.bool literal = false,
  }) {
    return uuid.toSimple(
      explode: explode,
      allowEmpty: allowEmpty,
      literal: literal,
    );
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
    return uuid.toForm(
      paramName,
      explode: explode,
      allowEmpty: allowEmpty,
      useQueryComponent: useQueryComponent,
      allowReserved: allowReserved,
    );
  }

  @_i3.override
  _i3.String toLabel({
    required _i3.bool explode,
    required _i3.bool allowEmpty,
  }) {
    return uuid.toLabel(explode: explode, allowEmpty: allowEmpty);
  }

  @_i3.override
  _i3.String toMatrix(
    _i3.String paramName, {
    required _i3.bool explode,
    required _i3.bool allowEmpty,
  }) {
    final _$values = <_i3.String>{};
    final _$uuidMatrix = uuid.toMatrix(
      paramName,
      explode: explode,
      allowEmpty: allowEmpty,
    );
    _$values.add(_$uuidMatrix);
    if (_$values.length > 1) {
      throw _i1.EncodingException(
        r'Inconsistent allOf matrix encoding for $RawTestDetailPreviousTestIdAllOfModel: all values must encode to the same result',
      );
    }
    return _$values.first;
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
    final _$values = <_i3.String>{};
    final _$uuidEncoded = uuid.uriEncode(
      allowEmpty: allowEmpty,
      useQueryComponent: useQueryComponent,
      allowReserved: allowReserved,
    );
    _$values.add(_$uuidEncoded);
    if (_$values.length > 1) {
      throw _i1.EncodingException(
        r'Inconsistent allOf encoding for $RawTestDetailPreviousTestIdAllOfModel: all values must encode to the same result',
      );
    }
    return _$values.first;
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is $RawTestDetailPreviousTestIdAllOfModel &&
        other.uuid == this.uuid;
  }

  @_i3.override
  _i3.int get hashCode => uuid.hashCode;

  $$$RawTestDetailPreviousTestIdAllOfModelCopyWith<
    $RawTestDetailPreviousTestIdAllOfModel
  >
  get copyWith => _$RawTestDetailPreviousTestIdAllOfModelCopyWith(this);
}

abstract class $$$RawTestDetailPreviousTestIdAllOfModelCopyWith<$Res> {
  factory $$$RawTestDetailPreviousTestIdAllOfModelCopyWith(
    $RawTestDetailPreviousTestIdAllOfModel value,
  ) = _$RawTestDetailPreviousTestIdAllOfModelCopyWith<$Res>;

  $Res call({_i4.Uuid? uuid});
  _i4.Uuid get uuid;
}

class _$RawTestDetailPreviousTestIdAllOfModelCopyWith<$Res>
    implements $$$RawTestDetailPreviousTestIdAllOfModelCopyWith<$Res> {
  _$RawTestDetailPreviousTestIdAllOfModelCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final $RawTestDetailPreviousTestIdAllOfModel _value;

  @_i3.override
  _i4.Uuid get uuid => _value.uuid;

  @_i3.override
  $Res call({_i3.Object? uuid = _sentinel}) {
    return ($RawTestDetailPreviousTestIdAllOfModel(
      uuid: _i3.identical(uuid, _sentinel) ? this.uuid : (uuid as _i4.Uuid),
    ) as $Res);
  }
}

typedef TestDetailPreviousTestIdAllOfModel =
    $RawTestDetailPreviousTestIdAllOfModel?;
