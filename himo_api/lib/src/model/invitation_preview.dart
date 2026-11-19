// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class InvitationPreview implements _i1.ParameterEncodable, _i1.UriEncodable {
  const InvitationPreview({required this.teamName, required this.expiresAt});

  factory InvitationPreview.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'team_name', r'expires_at'},
      listKeys: {},
      context: r'InvitationPreview',
    );
    return InvitationPreview(
      teamName: _$values[r'team_name'].decodeSimpleString(
        context: r'InvitationPreview.team_name',
      ),
      expiresAt: _$values[r'expires_at'].decodeSimpleDateTime(
        context: r'InvitationPreview.expires_at',
      ),
    );
  }

  factory InvitationPreview.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'InvitationPreview');
    return InvitationPreview(
      teamName: _$map[r'team_name'].decodeJsonString(
        context: r'InvitationPreview.team_name',
      ),
      expiresAt: _$map[r'expires_at'].decodeJsonDateTime(
        context: r'InvitationPreview.expires_at',
      ),
    );
  }

  factory InvitationPreview.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'team_name', r'expires_at'},
      listKeys: {},
      context: r'InvitationPreview',
    );
    return InvitationPreview(
      teamName: _$values[r'team_name'].decodeFormString(
        context: r'InvitationPreview.team_name',
      ),
      expiresAt: _$values[r'expires_at'].decodeFormDateTime(
        context: r'InvitationPreview.expires_at',
      ),
    );
  }

  /// **Example**:
  /// ```
  /// Студия «Подвал»
  /// ```
  final _i3.String teamName;

  final _i3.DateTime expiresAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'team_name': teamName,
    r'expires_at': expiresAt.toTimeZonedIso8601String(),
  };

  $$InvitationPreviewCopyWith<InvitationPreview> get copyWith =>
      _InvitationPreviewCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is InvitationPreview &&
        other.teamName == this.teamName &&
        other.expiresAt == this.expiresAt;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([teamName, expiresAt]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'team_name'] = _i1.PropertyValue.scalar(teamName);
    _$result[r'expires_at'] = _i1.PropertyValue.scalar(
      expiresAt.toTimeZonedIso8601String(),
    );
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
      r'Cannot uriEncode InvitationPreview: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$InvitationPreviewCopyWith<$Res> {
  factory $$InvitationPreviewCopyWith(InvitationPreview value) =
      _InvitationPreviewCopyWith<$Res>;

  $Res call({_i3.String? teamName, _i3.DateTime? expiresAt});
  _i3.String get teamName;
  _i3.DateTime get expiresAt;
}

class _InvitationPreviewCopyWith<$Res>
    implements $$InvitationPreviewCopyWith<$Res> {
  _InvitationPreviewCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final InvitationPreview _value;

  @_i3.override
  _i3.String get teamName => _value.teamName;

  @_i3.override
  _i3.DateTime get expiresAt => _value.expiresAt;

  @_i3.override
  $Res call({
    _i3.Object? teamName = _sentinel,
    _i3.Object? expiresAt = _sentinel,
  }) {
    return (InvitationPreview(
      teamName: _i3.identical(teamName, _sentinel)
          ? this.teamName
          : (teamName as _i3.String),
      expiresAt: _i3.identical(expiresAt, _sentinel)
          ? this.expiresAt
          : (expiresAt as _i3.DateTime),
    ) as $Res);
  }
}
