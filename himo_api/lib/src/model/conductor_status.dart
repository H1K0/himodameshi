// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i2;

import 'package:tonik_util/tonik_util.dart' as _i1;

/// `ok` — менее 5 Ом, `warning` — 5–50 Ом, `open` — обрыв, `short` — короткое замыкание
enum ConductorStatus
    implements
        _i1.MatrixEncodable,
        _i1.LabelEncodable,
        _i1.SimpleEncodable,
        _i1.FormEncodable,
        _i1.JsonEncodable,
        _i1.UriEncodable {
  ok(r'ok'),
  warning(r'warning'),
  open(r'open'),
  short(r'short');

  const ConductorStatus(this._$rawValue);

  factory ConductorStatus.fromJson(_i2.dynamic value) {
    if (value is! _i2.String) {
      throw _i1.JsonDecodingException(
        r'Expected String for ConductorStatus, got ${value.runtimeType}',
      );
    }
    return values.firstWhere(
      (e) => e._$rawValue == value,
      orElse: () => throw _i1.JsonDecodingException(
        r'No matching ConductorStatus for value: $value',
      ),
    );
  }

  factory ConductorStatus.fromSimple(
    _i2.String? value, {
    required _i2.bool explode,
    _i2.String? context,
  }) {
    return ConductorStatus.fromJson(value.decodeSimpleString(context: context));
  }

  factory ConductorStatus.fromForm(
    _i2.String? value, {
    required _i2.bool explode,
    _i2.String? context,
  }) {
    return ConductorStatus.fromJson(value.decodeFormString(context: context));
  }

  final _i2.String _$rawValue;

  @_i2.override
  _i2.String toJson() => _$rawValue;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.simple;

  @_i2.override
  _i2.String toSimple({
    required _i2.bool explode,
    required _i2.bool allowEmpty,
    _i2.bool literal = false,
  }) => _$rawValue.toSimple(
    explode: explode,
    allowEmpty: allowEmpty,
    literal: literal,
  );

  @_i2.override
  _i2.List<_i1.ParameterEntry> toForm(
    _i2.String paramName, {
    required _i2.bool explode,
    required _i2.bool allowEmpty,
    _i2.bool useQueryComponent = false,
    _i2.bool allowReserved = false,
    _i2.Map<_i2.String, _i1.FormFieldEncoding> fieldEncodings = const {},
  }) => _$rawValue.toForm(
    paramName,
    explode: explode,
    allowEmpty: allowEmpty,
    useQueryComponent: useQueryComponent,
    allowReserved: allowReserved,
  );

  @_i2.override
  _i2.String toLabel({
    required _i2.bool explode,
    required _i2.bool allowEmpty,
  }) => _$rawValue.toLabel(explode: explode, allowEmpty: allowEmpty);

  @_i2.override
  _i2.String uriEncode({
    required _i2.bool allowEmpty,
    _i2.bool useQueryComponent = false,
    _i2.bool allowReserved = false,
  }) => _$rawValue.uriEncode(
    allowEmpty: allowEmpty,
    useQueryComponent: useQueryComponent,
    allowReserved: allowReserved,
  );

  @_i2.override
  _i2.String toMatrix(
    _i2.String paramName, {
    required _i2.bool explode,
    required _i2.bool allowEmpty,
  }) =>
      _$rawValue.toMatrix(paramName, explode: explode, allowEmpty: allowEmpty);
}
