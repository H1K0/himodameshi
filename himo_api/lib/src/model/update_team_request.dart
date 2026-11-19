// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class UpdateTeamRequest implements _i1.ParameterEncodable, _i1.UriEncodable {
  const UpdateTeamRequest({this.name, this.description});

  factory UpdateTeamRequest.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'name', r'description'},
      listKeys: {},
      context: r'UpdateTeamRequest',
    );
    return UpdateTeamRequest(
      name: _$values[r'name'].decodeSimpleNullableString(
        context: r'UpdateTeamRequest.name',
      ),
      description: _$values[r'description'].decodeSimpleNullableString(
        context: r'UpdateTeamRequest.description',
      ),
    );
  }

  factory UpdateTeamRequest.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'UpdateTeamRequest');
    return UpdateTeamRequest(
      name: _$map[r'name'].decodeJsonNullableString(
        context: r'UpdateTeamRequest.name',
      ),
      description: _$map[r'description'].decodeJsonNullableString(
        context: r'UpdateTeamRequest.description',
      ),
    );
  }

  factory UpdateTeamRequest.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'name', r'description'},
      listKeys: {},
      context: r'UpdateTeamRequest',
    );
    return UpdateTeamRequest(
      name: _$values[r'name'].decodeFormNullableString(
        context: r'UpdateTeamRequest.name',
      ),
      description: _$values[r'description'].decodeFormNullableString(
        context: r'UpdateTeamRequest.description',
      ),
    );
  }

  final _i3.String? name;

  final _i3.String? description;

  @_i3.override
  _i3.Object? toJson() => {
    if (name != null) r'name': name,
    if (description != null) r'description': description,
  };

  $$UpdateTeamRequestCopyWith<UpdateTeamRequest> get copyWith =>
      _UpdateTeamRequestCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is UpdateTeamRequest &&
        other.name == this.name &&
        other.description == this.description;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([name, description]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    if (name != null) {
      _$result[r'name'] = _i1.PropertyValue.scalar(name!);
    }
    if (description != null) {
      _$result[r'description'] = _i1.PropertyValue.scalar(description!);
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
      r'Cannot uriEncode UpdateTeamRequest: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$UpdateTeamRequestCopyWith<$Res> {
  factory $$UpdateTeamRequestCopyWith(UpdateTeamRequest value) =
      _UpdateTeamRequestCopyWith<$Res>;

  $Res call({_i3.String? name, _i3.String? description});
  _i3.String? get name;
  _i3.String? get description;
}

class _UpdateTeamRequestCopyWith<$Res>
    implements $$UpdateTeamRequestCopyWith<$Res> {
  _UpdateTeamRequestCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final UpdateTeamRequest _value;

  @_i3.override
  _i3.String? get name => _value.name;

  @_i3.override
  _i3.String? get description => _value.description;

  @_i3.override
  $Res call({
    _i3.Object? name = _sentinel,
    _i3.Object? description = _sentinel,
  }) {
    return (UpdateTeamRequest(
      name: _i3.identical(name, _sentinel) ? this.name : (name as _i3.String?),
      description: _i3.identical(description, _sentinel)
          ? this.description
          : (description as _i3.String?),
    ) as $Res);
  }
}
