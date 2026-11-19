// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class FieldError implements _i1.ParameterEncodable, _i1.UriEncodable {
  const FieldError({required this.field, required this.message});

  factory FieldError.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'field', r'message'},
      listKeys: {},
      context: r'FieldError',
    );
    return FieldError(
      field: _$values[r'field'].decodeSimpleString(
        context: r'FieldError.field',
      ),
      message: _$values[r'message'].decodeSimpleString(
        context: r'FieldError.message',
      ),
    );
  }

  factory FieldError.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'FieldError');
    return FieldError(
      field: _$map[r'field'].decodeJsonString(context: r'FieldError.field'),
      message: _$map[r'message'].decodeJsonString(
        context: r'FieldError.message',
      ),
    );
  }

  factory FieldError.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'field', r'message'},
      listKeys: {},
      context: r'FieldError',
    );
    return FieldError(
      field: _$values[r'field'].decodeFormString(context: r'FieldError.field'),
      message: _$values[r'message'].decodeFormString(
        context: r'FieldError.message',
      ),
    );
  }

  /// Путь к полю
  ///
  /// **Example**:
  /// ```
  /// tests[2].results.continuity.conductors
  /// ```
  final _i3.String field;

  /// **Example**:
  /// ```
  /// для xlr ожидаются pin1, pin2, pin3
  /// ```
  final _i3.String message;

  @_i3.override
  _i3.Object? toJson() => {r'field': field, r'message': message};

  $$FieldErrorCopyWith<FieldError> get copyWith => _FieldErrorCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is FieldError &&
        other.field == this.field &&
        other.message == this.message;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([field, message]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'field'] = _i1.PropertyValue.scalar(field);
    _$result[r'message'] = _i1.PropertyValue.scalar(message);
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
      r'Cannot uriEncode FieldError: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$FieldErrorCopyWith<$Res> {
  factory $$FieldErrorCopyWith(FieldError value) = _FieldErrorCopyWith<$Res>;

  $Res call({_i3.String? field, _i3.String? message});
  _i3.String get field;
  _i3.String get message;
}

class _FieldErrorCopyWith<$Res> implements $$FieldErrorCopyWith<$Res> {
  _FieldErrorCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final FieldError _value;

  @_i3.override
  _i3.String get field => _value.field;

  @_i3.override
  _i3.String get message => _value.message;

  @_i3.override
  $Res call({_i3.Object? field = _sentinel, _i3.Object? message = _sentinel}) {
    return (FieldError(
      field: _i3.identical(field, _sentinel)
          ? this.field
          : (field as _i3.String),
      message: _i3.identical(message, _sentinel)
          ? this.message
          : (message as _i3.String),
    ) as $Res);
  }
}
