// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class CreateInvitationRequest
    implements _i1.ParameterEncodable, _i1.UriEncodable {
  const CreateInvitationRequest({this.expiresInDays = expiresInDaysDefault});

  factory CreateInvitationRequest.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'expires_in_days'},
      listKeys: {},
      context: r'CreateInvitationRequest',
    );
    return CreateInvitationRequest(
      expiresInDays: _$values.containsKey(r'expires_in_days')
          ? _$values[r'expires_in_days'].decodeSimpleInt(
              context: r'CreateInvitationRequest.expires_in_days',
            )
          : expiresInDaysDefault,
    );
  }

  factory CreateInvitationRequest.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'CreateInvitationRequest');
    return CreateInvitationRequest(
      expiresInDays: _$map.containsKey(r'expires_in_days')
          ? _$map[r'expires_in_days'].decodeJsonInt(
              context: r'CreateInvitationRequest.expires_in_days',
            )
          : expiresInDaysDefault,
    );
  }

  factory CreateInvitationRequest.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'expires_in_days'},
      listKeys: {},
      context: r'CreateInvitationRequest',
    );
    return CreateInvitationRequest(
      expiresInDays: _$values.containsKey(r'expires_in_days')
          ? _$values[r'expires_in_days'].decodeFormInt(
              context: r'CreateInvitationRequest.expires_in_days',
            )
          : expiresInDaysDefault,
    );
  }

  static const _i3.int expiresInDaysDefault = 7;

  final _i3.int? expiresInDays;

  @_i3.override
  _i3.Object? toJson() => {
    if (expiresInDays != null) r'expires_in_days': expiresInDays,
  };

  $$CreateInvitationRequestCopyWith<CreateInvitationRequest> get copyWith =>
      _CreateInvitationRequestCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CreateInvitationRequest &&
        other.expiresInDays == this.expiresInDays;
  }

  @_i3.override
  _i3.int get hashCode => expiresInDays.hashCode;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    if (expiresInDays != null) {
      _$result[r'expires_in_days'] = _i1.PropertyValue.scalar(
        expiresInDays!.toString(),
      );
    }
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
      r'Cannot uriEncode CreateInvitationRequest: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$CreateInvitationRequestCopyWith<$Res> {
  factory $$CreateInvitationRequestCopyWith(CreateInvitationRequest value) =
      _CreateInvitationRequestCopyWith<$Res>;

  $Res call({_i3.int? expiresInDays});
  _i3.int? get expiresInDays;
}

class _CreateInvitationRequestCopyWith<$Res>
    implements $$CreateInvitationRequestCopyWith<$Res> {
  _CreateInvitationRequestCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final CreateInvitationRequest _value;

  @_i3.override
  _i3.int? get expiresInDays => _value.expiresInDays;

  @_i3.override
  $Res call({_i3.Object? expiresInDays = _sentinel}) {
    return (CreateInvitationRequest(
      expiresInDays: _i3.identical(expiresInDays, _sentinel)
          ? this.expiresInDays
          : (expiresInDays as _i3.int?),
    ) as $Res);
  }
}
