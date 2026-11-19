// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/user_ref.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class Invalidation implements _i1.ParameterEncodable, _i1.UriEncodable {
  const Invalidation({
    required this.at,
    required this.by,
    required this.reason,
  });

  factory Invalidation.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for Invalidation: contains complex types',
    );
  }

  factory Invalidation.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Invalidation');
    return Invalidation(
      at: _$map[r'at'].decodeJsonDateTime(context: r'Invalidation.at'),
      by: _i4.UserRef.fromJson(_$map[r'by']),
      reason: _$map[r'reason'].decodeJsonString(
        context: r'Invalidation.reason',
      ),
    );
  }

  factory Invalidation.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for Invalidation: contains complex types',
    );
  }

  final _i3.DateTime at;

  final _i4.UserRef by;

  /// **Example**:
  /// ```
  /// Перепутан кабель
  /// ```
  final _i3.String reason;

  @_i3.override
  _i3.Object? toJson() => {
    r'at': at.toTimeZonedIso8601String(),
    r'by': by.toJson(),
    r'reason': reason,
  };

  $$InvalidationCopyWith<Invalidation> get copyWith =>
      _InvalidationCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is Invalidation &&
        other.at == this.at &&
        other.by == this.by &&
        other.reason == this.reason;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([at, by, reason]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for Invalidation: contains complex types',
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
      r'Cannot uriEncode Invalidation: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$InvalidationCopyWith<$Res> {
  factory $$InvalidationCopyWith(Invalidation value) =
      _InvalidationCopyWith<$Res>;

  $Res call({_i3.DateTime? at, _i4.UserRef? by, _i3.String? reason});
  _i3.DateTime get at;
  _i4.UserRef get by;
  _i3.String get reason;
}

class _InvalidationCopyWith<$Res> implements $$InvalidationCopyWith<$Res> {
  _InvalidationCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final Invalidation _value;

  @_i3.override
  _i3.DateTime get at => _value.at;

  @_i3.override
  _i4.UserRef get by => _value.by;

  @_i3.override
  _i3.String get reason => _value.reason;

  @_i3.override
  $Res call({
    _i3.Object? at = _sentinel,
    _i3.Object? by = _sentinel,
    _i3.Object? reason = _sentinel,
  }) {
    return (Invalidation(
      at: _i3.identical(at, _sentinel) ? this.at : (at as _i3.DateTime),
      by: _i3.identical(by, _sentinel) ? this.by : (by as _i4.UserRef),
      reason: _i3.identical(reason, _sentinel)
          ? this.reason
          : (reason as _i3.String),
    ) as $Res);
  }
}
