// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/nickname.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class UpdateProfileRequest implements _i1.ParameterEncodable, _i1.UriEncodable {
  const UpdateProfileRequest({required this.nickname});

  factory UpdateProfileRequest.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'nickname'},
      listKeys: {},
      context: r'UpdateProfileRequest',
    );
    return UpdateProfileRequest(
      nickname: _$values[r'nickname'].decodeSimpleString(
        context: r'UpdateProfileRequest.nickname',
      ),
    );
  }

  factory UpdateProfileRequest.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'UpdateProfileRequest');
    return UpdateProfileRequest(
      nickname: _$map[r'nickname'].decodeJsonString(
        context: r'UpdateProfileRequest.nickname',
      ),
    );
  }

  factory UpdateProfileRequest.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'nickname'},
      listKeys: {},
      context: r'UpdateProfileRequest',
    );
    return UpdateProfileRequest(
      nickname: _$values[r'nickname'].decodeFormString(
        context: r'UpdateProfileRequest.nickname',
      ),
    );
  }

  final _i4.Nickname nickname;

  @_i3.override
  _i3.Object? toJson() => {r'nickname': nickname};

  $$UpdateProfileRequestCopyWith<UpdateProfileRequest> get copyWith =>
      _UpdateProfileRequestCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is UpdateProfileRequest && other.nickname == this.nickname;
  }

  @_i3.override
  _i3.int get hashCode => nickname.hashCode;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'nickname'] = _i1.PropertyValue.scalar(nickname);
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
      r'Cannot uriEncode UpdateProfileRequest: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$UpdateProfileRequestCopyWith<$Res> {
  factory $$UpdateProfileRequestCopyWith(UpdateProfileRequest value) =
      _UpdateProfileRequestCopyWith<$Res>;

  $Res call({_i4.Nickname? nickname});
  _i4.Nickname get nickname;
}

class _UpdateProfileRequestCopyWith<$Res>
    implements $$UpdateProfileRequestCopyWith<$Res> {
  _UpdateProfileRequestCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final UpdateProfileRequest _value;

  @_i3.override
  _i4.Nickname get nickname => _value.nickname;

  @_i3.override
  $Res call({_i3.Object? nickname = _sentinel}) {
    return (UpdateProfileRequest(
      nickname: _i3.identical(nickname, _sentinel)
          ? this.nickname
          : (nickname as _i4.Nickname),
    ) as $Res);
  }
}
