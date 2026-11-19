// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class InvalidationRequest implements _i1.ParameterEncodable, _i1.UriEncodable {
  const InvalidationRequest({required this.reason});

  factory InvalidationRequest.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'reason'},
      listKeys: {},
      context: r'InvalidationRequest',
    );
    return InvalidationRequest(
      reason: _$values[r'reason'].decodeSimpleString(
        context: r'InvalidationRequest.reason',
      ),
    );
  }

  factory InvalidationRequest.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'InvalidationRequest');
    return InvalidationRequest(
      reason: _$map[r'reason'].decodeJsonString(
        context: r'InvalidationRequest.reason',
      ),
    );
  }

  factory InvalidationRequest.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'reason'},
      listKeys: {},
      context: r'InvalidationRequest',
    );
    return InvalidationRequest(
      reason: _$values[r'reason'].decodeFormString(
        context: r'InvalidationRequest.reason',
      ),
    );
  }

  final _i3.String reason;

  @_i3.override
  _i3.Object? toJson() => {r'reason': reason};

  $$InvalidationRequestCopyWith<InvalidationRequest> get copyWith =>
      _InvalidationRequestCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is InvalidationRequest && other.reason == this.reason;
  }

  @_i3.override
  _i3.int get hashCode => reason.hashCode;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'reason'] = _i1.PropertyValue.scalar(reason);
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
      r'Cannot uriEncode InvalidationRequest: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$InvalidationRequestCopyWith<$Res> {
  factory $$InvalidationRequestCopyWith(InvalidationRequest value) =
      _InvalidationRequestCopyWith<$Res>;

  $Res call({_i3.String? reason});
  _i3.String get reason;
}

class _InvalidationRequestCopyWith<$Res>
    implements $$InvalidationRequestCopyWith<$Res> {
  _InvalidationRequestCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final InvalidationRequest _value;

  @_i3.override
  _i3.String get reason => _value.reason;

  @_i3.override
  $Res call({_i3.Object? reason = _sentinel}) {
    return (InvalidationRequest(
      reason: _i3.identical(reason, _sentinel)
          ? this.reason
          : (reason as _i3.String),
    ) as $Res);
  }
}
