// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/uuid.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class TransferOwnershipRequest
    implements _i1.ParameterEncodable, _i1.UriEncodable {
  const TransferOwnershipRequest({required this.userId});

  factory TransferOwnershipRequest.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'user_id'},
      listKeys: {},
      context: r'TransferOwnershipRequest',
    );
    return TransferOwnershipRequest(
      userId: _$values[r'user_id'].decodeSimpleString(
        context: r'TransferOwnershipRequest.user_id',
      ),
    );
  }

  factory TransferOwnershipRequest.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'TransferOwnershipRequest');
    return TransferOwnershipRequest(
      userId: _$map[r'user_id'].decodeJsonString(
        context: r'TransferOwnershipRequest.user_id',
      ),
    );
  }

  factory TransferOwnershipRequest.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'user_id'},
      listKeys: {},
      context: r'TransferOwnershipRequest',
    );
    return TransferOwnershipRequest(
      userId: _$values[r'user_id'].decodeFormString(
        context: r'TransferOwnershipRequest.user_id',
      ),
    );
  }

  final _i4.Uuid userId;

  @_i3.override
  _i3.Object? toJson() => {r'user_id': userId};

  $$TransferOwnershipRequestCopyWith<TransferOwnershipRequest> get copyWith =>
      _TransferOwnershipRequestCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is TransferOwnershipRequest && other.userId == this.userId;
  }

  @_i3.override
  _i3.int get hashCode => userId.hashCode;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'user_id'] = _i1.PropertyValue.scalar(userId);
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
      r'Cannot uriEncode TransferOwnershipRequest: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$TransferOwnershipRequestCopyWith<$Res> {
  factory $$TransferOwnershipRequestCopyWith(TransferOwnershipRequest value) =
      _TransferOwnershipRequestCopyWith<$Res>;

  $Res call({_i4.Uuid? userId});
  _i4.Uuid get userId;
}

class _TransferOwnershipRequestCopyWith<$Res>
    implements $$TransferOwnershipRequestCopyWith<$Res> {
  _TransferOwnershipRequestCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final TransferOwnershipRequest _value;

  @_i3.override
  _i4.Uuid get userId => _value.userId;

  @_i3.override
  $Res call({_i3.Object? userId = _sentinel}) {
    return (TransferOwnershipRequest(
      userId: _i3.identical(userId, _sentinel)
          ? this.userId
          : (userId as _i4.Uuid),
    ) as $Res);
  }
}
