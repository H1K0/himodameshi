// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// Тариф команды; лимиты задаются конфигурацией сервера
@_i2.immutable
class Plan implements _i1.ParameterEncodable, _i1.UriEncodable {
  const Plan({required this.key, required this.maxMembers});

  factory Plan.fromSimple(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'key', r'max_members'},
      listKeys: {},
      context: r'Plan',
    );
    return Plan(
      key: _$values[r'key'].decodeSimpleString(context: r'Plan.key'),
      maxMembers: _$values[r'max_members'].decodeSimpleInt(
        context: r'Plan.max_members',
      ),
    );
  }

  factory Plan.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Plan');
    return Plan(
      key: _$map[r'key'].decodeJsonString(context: r'Plan.key'),
      maxMembers: _$map[r'max_members'].decodeJsonInt(
        context: r'Plan.max_members',
      ),
    );
  }

  factory Plan.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'key', r'max_members'},
      listKeys: {},
      context: r'Plan',
    );
    return Plan(
      key: _$values[r'key'].decodeFormString(context: r'Plan.key'),
      maxMembers: _$values[r'max_members'].decodeFormInt(
        context: r'Plan.max_members',
      ),
    );
  }

  /// **Example**:
  /// ```
  /// free
  /// ```
  final _i3.String key;

  /// **Example**:
  /// ```json
  /// 5
  /// ```
  final _i3.int maxMembers;

  @_i3.override
  _i3.Object? toJson() => {r'key': key, r'max_members': maxMembers};

  $$PlanCopyWith<Plan> get copyWith => _PlanCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is Plan &&
        other.key == this.key &&
        other.maxMembers == this.maxMembers;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([key, maxMembers]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'key'] = _i1.PropertyValue.scalar(key);
    _$result[r'max_members'] = _i1.PropertyValue.scalar(maxMembers.toString());
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
      r'Cannot uriEncode Plan: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$PlanCopyWith<$Res> {
  factory $$PlanCopyWith(Plan value) = _PlanCopyWith<$Res>;

  $Res call({_i3.String? key, _i3.int? maxMembers});
  _i3.String get key;
  _i3.int get maxMembers;
}

class _PlanCopyWith<$Res> implements $$PlanCopyWith<$Res> {
  _PlanCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final Plan _value;

  @_i3.override
  _i3.String get key => _value.key;

  @_i3.override
  _i3.int get maxMembers => _value.maxMembers;

  @_i3.override
  $Res call({_i3.Object? key = _sentinel, _i3.Object? maxMembers = _sentinel}) {
    return (Plan(
      key: _i3.identical(key, _sentinel) ? this.key : (key as _i3.String),
      maxMembers: _i3.identical(maxMembers, _sentinel)
          ? this.maxMembers
          : (maxMembers as _i3.int),
    ) as $Res);
  }
}
