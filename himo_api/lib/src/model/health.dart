// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/health_status_model.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class Health implements _i1.ParameterEncodable, _i1.UriEncodable {
  const Health({required this.status});

  factory Health.fromSimple(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'status'},
      listKeys: {},
      context: r'Health',
    );
    return Health(
      status: _i4.HealthStatusModel.fromSimple(
        _$values[r'status'],
        explode: explode,
      ),
    );
  }

  factory Health.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Health');
    return Health(status: _i4.HealthStatusModel.fromJson(_$map[r'status']));
  }

  factory Health.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'status'},
      listKeys: {},
      context: r'Health',
    );
    return Health(
      status: _i4.HealthStatusModel.fromForm(
        _$values[r'status'],
        explode: explode,
      ),
    );
  }

  final _i4.HealthStatusModel status;

  @_i3.override
  _i3.Object? toJson() => {r'status': status.toJson()};

  $$HealthCopyWith<Health> get copyWith => _HealthCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is Health && other.status == this.status;
  }

  @_i3.override
  _i3.int get hashCode => status.hashCode;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'status'] = _i1.PropertyValue.scalar(status.toJson());
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
      r'Cannot uriEncode Health: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$HealthCopyWith<$Res> {
  factory $$HealthCopyWith(Health value) = _HealthCopyWith<$Res>;

  $Res call({_i4.HealthStatusModel? status});
  _i4.HealthStatusModel get status;
}

class _HealthCopyWith<$Res> implements $$HealthCopyWith<$Res> {
  _HealthCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final Health _value;

  @_i3.override
  _i4.HealthStatusModel get status => _value.status;

  @_i3.override
  $Res call({_i3.Object? status = _sentinel}) {
    return (Health(
      status: _i3.identical(status, _sentinel)
          ? this.status
          : (status as _i4.HealthStatusModel),
    ) as $Res);
  }
}
