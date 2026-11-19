// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class AppOutdatedProblemModel
    implements _i1.ParameterEncodable, _i1.UriEncodable {
  const AppOutdatedProblemModel({required this.minAppVersion});

  factory AppOutdatedProblemModel.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'min_app_version'},
      listKeys: {},
      context: r'AppOutdatedProblemModel',
    );
    return AppOutdatedProblemModel(
      minAppVersion: _$values[r'min_app_version'].decodeSimpleString(
        context: r'AppOutdatedProblemModel.min_app_version',
      ),
    );
  }

  factory AppOutdatedProblemModel.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'AppOutdatedProblemModel');
    return AppOutdatedProblemModel(
      minAppVersion: _$map[r'min_app_version'].decodeJsonString(
        context: r'AppOutdatedProblemModel.min_app_version',
      ),
    );
  }

  factory AppOutdatedProblemModel.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'min_app_version'},
      listKeys: {},
      context: r'AppOutdatedProblemModel',
    );
    return AppOutdatedProblemModel(
      minAppVersion: _$values[r'min_app_version'].decodeFormString(
        context: r'AppOutdatedProblemModel.min_app_version',
      ),
    );
  }

  /// **Example**:
  /// ```
  /// 0.7.0
  /// ```
  final _i3.String minAppVersion;

  @_i3.override
  _i3.Object? toJson() => {r'min_app_version': minAppVersion};

  $$AppOutdatedProblemModelCopyWith<AppOutdatedProblemModel> get copyWith =>
      _AppOutdatedProblemModelCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AppOutdatedProblemModel &&
        other.minAppVersion == this.minAppVersion;
  }

  @_i3.override
  _i3.int get hashCode => minAppVersion.hashCode;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'min_app_version'] = _i1.PropertyValue.scalar(minAppVersion);
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
      r'Cannot uriEncode AppOutdatedProblemModel: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$AppOutdatedProblemModelCopyWith<$Res> {
  factory $$AppOutdatedProblemModelCopyWith(AppOutdatedProblemModel value) =
      _AppOutdatedProblemModelCopyWith<$Res>;

  $Res call({_i3.String? minAppVersion});
  _i3.String get minAppVersion;
}

class _AppOutdatedProblemModelCopyWith<$Res>
    implements $$AppOutdatedProblemModelCopyWith<$Res> {
  _AppOutdatedProblemModelCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final AppOutdatedProblemModel _value;

  @_i3.override
  _i3.String get minAppVersion => _value.minAppVersion;

  @_i3.override
  $Res call({_i3.Object? minAppVersion = _sentinel}) {
    return (AppOutdatedProblemModel(
      minAppVersion: _i3.identical(minAppVersion, _sentinel)
          ? this.minAppVersion
          : (minAppVersion as _i3.String),
    ) as $Res);
  }
}
