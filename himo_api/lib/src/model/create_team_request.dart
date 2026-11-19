// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class CreateTeamRequest implements _i1.ParameterEncodable, _i1.UriEncodable {
  const CreateTeamRequest({
    required this.name,
    this.description = descriptionDefault,
  });

  factory CreateTeamRequest.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'name', r'description'},
      listKeys: {},
      context: r'CreateTeamRequest',
    );
    return CreateTeamRequest(
      name: _$values[r'name'].decodeSimpleString(
        context: r'CreateTeamRequest.name',
      ),
      description: _$values.containsKey(r'description')
          ? _$values[r'description'].decodeSimpleString(
              context: r'CreateTeamRequest.description',
            )
          : descriptionDefault,
    );
  }

  factory CreateTeamRequest.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'CreateTeamRequest');
    return CreateTeamRequest(
      name: _$map[r'name'].decodeJsonString(context: r'CreateTeamRequest.name'),
      description: _$map.containsKey(r'description')
          ? _$map[r'description'].decodeJsonString(
              context: r'CreateTeamRequest.description',
            )
          : descriptionDefault,
    );
  }

  factory CreateTeamRequest.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'name', r'description'},
      listKeys: {},
      context: r'CreateTeamRequest',
    );
    return CreateTeamRequest(
      name: _$values[r'name'].decodeFormString(
        context: r'CreateTeamRequest.name',
      ),
      description: _$values.containsKey(r'description')
          ? _$values[r'description'].decodeFormString(
              context: r'CreateTeamRequest.description',
            )
          : descriptionDefault,
    );
  }

  static const _i3.String descriptionDefault = r'';

  final _i3.String name;

  final _i3.String? description;

  @_i3.override
  _i3.Object? toJson() => {
    r'name': name,
    if (description != null) r'description': description,
  };

  $$CreateTeamRequestCopyWith<CreateTeamRequest> get copyWith =>
      _CreateTeamRequestCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CreateTeamRequest &&
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
    _$result[r'name'] = _i1.PropertyValue.scalar(name);
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
      r'Cannot uriEncode CreateTeamRequest: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$CreateTeamRequestCopyWith<$Res> {
  factory $$CreateTeamRequestCopyWith(CreateTeamRequest value) =
      _CreateTeamRequestCopyWith<$Res>;

  $Res call({_i3.String? name, _i3.String? description});
  _i3.String get name;
  _i3.String? get description;
}

class _CreateTeamRequestCopyWith<$Res>
    implements $$CreateTeamRequestCopyWith<$Res> {
  _CreateTeamRequestCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final CreateTeamRequest _value;

  @_i3.override
  _i3.String get name => _value.name;

  @_i3.override
  _i3.String? get description => _value.description;

  @_i3.override
  $Res call({
    _i3.Object? name = _sentinel,
    _i3.Object? description = _sentinel,
  }) {
    return (CreateTeamRequest(
      name: _i3.identical(name, _sentinel) ? this.name : (name as _i3.String),
      description: _i3.identical(description, _sentinel)
          ? this.description
          : (description as _i3.String?),
    ) as $Res);
  }
}
