// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/app_outdated_problem_model.dart' as _i5;
import 'package:himo_api/src/model/problem.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// **Example**:
/// ```json
/// {
///   "type": "about:blank",
///   "title": "Upgrade Required",
///   "status": 426,
///   "code": "app_outdated",
///   "min_app_version": "0.7.0"
/// }
/// ```
@_i2.immutable
class AppOutdatedProblem implements _i1.ParameterEncodable, _i1.UriEncodable {
  const AppOutdatedProblem({
    required this.problem,
    required this.appOutdatedProblemModel,
  });

  factory AppOutdatedProblem.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    return AppOutdatedProblem(
      problem: _i4.Problem.fromSimple(value, explode: explode),
      appOutdatedProblemModel: _i5.AppOutdatedProblemModel.fromSimple(
        value,
        explode: explode,
      ),
    );
  }

  factory AppOutdatedProblem.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    return AppOutdatedProblem(
      problem: _i4.Problem.fromForm(value, explode: explode),
      appOutdatedProblemModel: _i5.AppOutdatedProblemModel.fromForm(
        value,
        explode: explode,
      ),
    );
  }

  factory AppOutdatedProblem.fromJson(_i3.Object? json) {
    return AppOutdatedProblem(
      problem: _i4.Problem.fromJson(json),
      appOutdatedProblemModel: _i5.AppOutdatedProblemModel.fromJson(json),
    );
  }

  final _i4.Problem problem;

  final _i5.AppOutdatedProblemModel appOutdatedProblemModel;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Object? toJson() {
    final _$map = <_i3.String, _i3.Object?>{};
    final _$problemJson = problem.toJson();
    if (_$problemJson is! _i3.Map<_i3.String, _i3.Object?>) {
      throw _i1.EncodingException(
        'Expected problem.toJson() to return Map<String, Object?>, got ${_$problemJson.runtimeType}',
      );
    }
    _$map.addAll(_$problemJson);
    final _$appOutdatedProblemModelJson = appOutdatedProblemModel.toJson();
    if (_$appOutdatedProblemModelJson is! _i3.Map<_i3.String, _i3.Object?>) {
      throw _i1.EncodingException(
        'Expected appOutdatedProblemModel.toJson() to return Map<String, Object?>, got ${_$appOutdatedProblemModelJson.runtimeType}',
      );
    }
    _$map.addAll(_$appOutdatedProblemModelJson);
    return _$map;
  }

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$mergedProperties = <_i3.String, _i1.PropertyValue>{};
    _$mergedProperties.addAll(
      problem.parameterProperties(allowEmpty: allowEmpty),
    );
    _$mergedProperties.addAll(
      appOutdatedProblemModel.parameterProperties(allowEmpty: allowEmpty),
    );
    return _$mergedProperties;
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
      r'Cannot uriEncode AppOutdatedProblem: contains complex types',
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AppOutdatedProblem &&
        other.problem == this.problem &&
        other.appOutdatedProblemModel == this.appOutdatedProblemModel;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([problem, appOutdatedProblemModel]);
  }

  $$AppOutdatedProblemCopyWith<AppOutdatedProblem> get copyWith =>
      _AppOutdatedProblemCopyWith(this);
}

abstract class $$AppOutdatedProblemCopyWith<$Res> {
  factory $$AppOutdatedProblemCopyWith(AppOutdatedProblem value) =
      _AppOutdatedProblemCopyWith<$Res>;

  $Res call({
    _i4.Problem? problem,
    _i5.AppOutdatedProblemModel? appOutdatedProblemModel,
  });
  _i4.Problem get problem;
  _i5.AppOutdatedProblemModel get appOutdatedProblemModel;
}

class _AppOutdatedProblemCopyWith<$Res>
    implements $$AppOutdatedProblemCopyWith<$Res> {
  _AppOutdatedProblemCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final AppOutdatedProblem _value;

  @_i3.override
  _i4.Problem get problem => _value.problem;

  @_i3.override
  _i5.AppOutdatedProblemModel get appOutdatedProblemModel =>
      _value.appOutdatedProblemModel;

  @_i3.override
  $Res call({
    _i3.Object? problem = _sentinel,
    _i3.Object? appOutdatedProblemModel = _sentinel,
  }) {
    return (AppOutdatedProblem(
      problem: _i3.identical(problem, _sentinel)
          ? this.problem
          : (problem as _i4.Problem),
      appOutdatedProblemModel: _i3.identical(appOutdatedProblemModel, _sentinel)
          ? this.appOutdatedProblemModel
          : (appOutdatedProblemModel as _i5.AppOutdatedProblemModel),
    ) as $Res);
  }
}
