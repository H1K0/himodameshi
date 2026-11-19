// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/invitation.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class CreatedInvitation implements _i1.ParameterEncodable, _i1.UriEncodable {
  const CreatedInvitation({required this.invitation, required this.token});

  factory CreatedInvitation.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for CreatedInvitation: contains complex types',
    );
  }

  factory CreatedInvitation.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'CreatedInvitation');
    return CreatedInvitation(
      invitation: _i4.Invitation.fromJson(_$map[r'invitation']),
      token: _$map[r'token'].decodeJsonString(
        context: r'CreatedInvitation.token',
      ),
    );
  }

  factory CreatedInvitation.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for CreatedInvitation: contains complex types',
    );
  }

  final _i4.Invitation invitation;

  /// Токен для ссылки; показывается один раз
  ///
  /// **Example**:
  /// ```
  /// invitation-token-example
  /// ```
  final _i3.String token;

  @_i3.override
  _i3.Object? toJson() => {r'invitation': invitation.toJson(), r'token': token};

  $$CreatedInvitationCopyWith<CreatedInvitation> get copyWith =>
      _CreatedInvitationCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CreatedInvitation &&
        other.invitation == this.invitation &&
        other.token == this.token;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([invitation, token]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for CreatedInvitation: contains complex types',
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
      r'Cannot uriEncode CreatedInvitation: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$CreatedInvitationCopyWith<$Res> {
  factory $$CreatedInvitationCopyWith(CreatedInvitation value) =
      _CreatedInvitationCopyWith<$Res>;

  $Res call({_i4.Invitation? invitation, _i3.String? token});
  _i4.Invitation get invitation;
  _i3.String get token;
}

class _CreatedInvitationCopyWith<$Res>
    implements $$CreatedInvitationCopyWith<$Res> {
  _CreatedInvitationCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final CreatedInvitation _value;

  @_i3.override
  _i4.Invitation get invitation => _value.invitation;

  @_i3.override
  _i3.String get token => _value.token;

  @_i3.override
  $Res call({
    _i3.Object? invitation = _sentinel,
    _i3.Object? token = _sentinel,
  }) {
    return (CreatedInvitation(
      invitation: _i3.identical(invitation, _sentinel)
          ? this.invitation
          : (invitation as _i4.Invitation),
      token: _i3.identical(token, _sentinel)
          ? this.token
          : (token as _i3.String),
    ) as $Res);
  }
}
