// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i5;
import 'package:himo_api/src/model/field_error.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// Ошибка по RFC 9457 с машиночитаемым кодом
@_i2.immutable
class Problem implements _i1.ParameterEncodable, _i1.UriEncodable {
  const Problem({
    required this.$type,
    required this.title,
    required this.status,
    required this.code,
    this.detail,
    this.instance,
    this.errors,
  });

  factory Problem.fromSimple(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for Problem: contains complex types',
    );
  }

  factory Problem.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Problem');
    return Problem(
      $type: _$map[r'type'].decodeJsonString(context: r'Problem.type'),
      title: _$map[r'title'].decodeJsonString(context: r'Problem.title'),
      status: _$map[r'status'].decodeJsonInt(context: r'Problem.status'),
      detail: _$map[r'detail'].decodeJsonNullableString(
        context: r'Problem.detail',
      ),
      instance: _$map[r'instance'].decodeJsonNullableString(
        context: r'Problem.instance',
      ),
      code: _$map[r'code'].decodeJsonString(context: r'Problem.code'),
      errors: _$map[r'errors']
          .decodeJsonNullableList<_i3.Object?>(context: r'Problem.errors')
          ?.map(_i4.FieldError.fromJson)
          .toList(),
    );
  }

  factory Problem.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for Problem: contains complex types',
    );
  }

  /// **Example**:
  /// ```
  /// about:blank
  /// ```
  final _i3.String $type;

  /// **Example**:
  /// ```
  /// Conflict
  /// ```
  final _i3.String title;

  /// **Example**:
  /// ```json
  /// 409
  /// ```
  final _i3.int status;

  /// Пояснение для человека; не предназначено для разбора
  final _i3.String? detail;

  final _i3.String? instance;

  /// Машиночитаемый код ошибки, таблица — в описании API
  ///
  /// **Example**:
  /// ```
  /// cable_archived
  /// ```
  final _i3.String code;

  /// Ошибки проверки по полям — только для `validation_error`
  final _i3.List<_i4.FieldError>? errors;

  @_i3.override
  _i3.Object? toJson() => {
    r'type': $type,
    r'title': title,
    r'status': status,
    if (detail != null) r'detail': detail,
    if (instance != null) r'instance': instance,
    r'code': code,
    if (errors != null) r'errors': errors?.map((e) => e.toJson()).toList(),
  };

  $$ProblemCopyWith<Problem> get copyWith => _ProblemCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i5.DeepCollectionEquality();
    return other is Problem &&
        other.$type == this.$type &&
        other.title == this.title &&
        other.status == this.status &&
        other.detail == this.detail &&
        other.instance == this.instance &&
        other.code == this.code &&
        _$deepEquals.equals(other.errors, this.errors);
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i5.DeepCollectionEquality();
    return _i3.Object.hashAll([
      $type,
      title,
      status,
      detail,
      instance,
      code,
      deepEquals.hash(errors),
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for Problem: contains complex types',
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
      r'Cannot uriEncode Problem: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$ProblemCopyWith<$Res> {
  factory $$ProblemCopyWith(Problem value) = _ProblemCopyWith<$Res>;

  $Res call({
    _i3.String? $type,
    _i3.String? title,
    _i3.int? status,
    _i3.String? detail,
    _i3.String? instance,
    _i3.String? code,
    _i3.List<_i4.FieldError>? errors,
  });
  _i3.String get $type;
  _i3.String get title;
  _i3.int get status;
  _i3.String? get detail;
  _i3.String? get instance;
  _i3.String get code;
  _i3.List<_i4.FieldError>? get errors;
}

class _ProblemCopyWith<$Res> implements $$ProblemCopyWith<$Res> {
  _ProblemCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final Problem _value;

  @_i3.override
  _i3.String get $type => _value.$type;

  @_i3.override
  _i3.String get title => _value.title;

  @_i3.override
  _i3.int get status => _value.status;

  @_i3.override
  _i3.String? get detail => _value.detail;

  @_i3.override
  _i3.String? get instance => _value.instance;

  @_i3.override
  _i3.String get code => _value.code;

  @_i3.override
  _i3.List<_i4.FieldError>? get errors => _value.errors;

  @_i3.override
  $Res call({
    _i3.Object? $type = _sentinel,
    _i3.Object? title = _sentinel,
    _i3.Object? status = _sentinel,
    _i3.Object? detail = _sentinel,
    _i3.Object? instance = _sentinel,
    _i3.Object? code = _sentinel,
    _i3.Object? errors = _sentinel,
  }) {
    return (Problem(
      $type: _i3.identical($type, _sentinel)
          ? this.$type
          : ($type as _i3.String),
      title: _i3.identical(title, _sentinel)
          ? this.title
          : (title as _i3.String),
      status: _i3.identical(status, _sentinel)
          ? this.status
          : (status as _i3.int),
      detail: _i3.identical(detail, _sentinel)
          ? this.detail
          : (detail as _i3.String?),
      instance: _i3.identical(instance, _sentinel)
          ? this.instance
          : (instance as _i3.String?),
      code: _i3.identical(code, _sentinel) ? this.code : (code as _i3.String),
      errors: _i3.identical(errors, _sentinel)
          ? this.errors
          : (errors as _i3.List<_i4.FieldError>?),
    ) as $Res);
  }
}
