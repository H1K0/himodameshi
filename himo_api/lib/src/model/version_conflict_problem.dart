// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/problem.dart' as _i4;
import 'package:himo_api/src/model/version_conflict_problem_model.dart' as _i5;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// Ошибка `409`; при `version_conflict` в поле `cable` — актуальный кабель
@_i2.immutable
class VersionConflictProblem
    implements _i1.ParameterEncodable, _i1.UriEncodable {
  const VersionConflictProblem({
    required this.problem,
    required this.versionConflictProblemModel,
  });

  factory VersionConflictProblem.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    return VersionConflictProblem(
      problem: _i4.Problem.fromSimple(value, explode: explode),
      versionConflictProblemModel: _i5.VersionConflictProblemModel.fromSimple(
        value,
        explode: explode,
      ),
    );
  }

  factory VersionConflictProblem.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    return VersionConflictProblem(
      problem: _i4.Problem.fromForm(value, explode: explode),
      versionConflictProblemModel: _i5.VersionConflictProblemModel.fromForm(
        value,
        explode: explode,
      ),
    );
  }

  factory VersionConflictProblem.fromJson(_i3.Object? json) {
    return VersionConflictProblem(
      problem: _i4.Problem.fromJson(json),
      versionConflictProblemModel: _i5.VersionConflictProblemModel.fromJson(
        json,
      ),
    );
  }

  final _i4.Problem problem;

  final _i5.VersionConflictProblemModel versionConflictProblemModel;

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
    final _$versionConflictProblemModelJson = versionConflictProblemModel
        .toJson();
    if (_$versionConflictProblemModelJson
        is! _i3.Map<_i3.String, _i3.Object?>) {
      throw _i1.EncodingException(
        'Expected versionConflictProblemModel.toJson() to return Map<String, Object?>, got ${_$versionConflictProblemModelJson.runtimeType}',
      );
    }
    _$map.addAll(_$versionConflictProblemModelJson);
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
      versionConflictProblemModel.parameterProperties(allowEmpty: allowEmpty),
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
      r'Cannot uriEncode VersionConflictProblem: contains complex types',
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is VersionConflictProblem &&
        other.problem == this.problem &&
        other.versionConflictProblemModel == this.versionConflictProblemModel;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([problem, versionConflictProblemModel]);
  }

  $$VersionConflictProblemCopyWith<VersionConflictProblem> get copyWith =>
      _VersionConflictProblemCopyWith(this);
}

abstract class $$VersionConflictProblemCopyWith<$Res> {
  factory $$VersionConflictProblemCopyWith(VersionConflictProblem value) =
      _VersionConflictProblemCopyWith<$Res>;

  $Res call({
    _i4.Problem? problem,
    _i5.VersionConflictProblemModel? versionConflictProblemModel,
  });
  _i4.Problem get problem;
  _i5.VersionConflictProblemModel get versionConflictProblemModel;
}

class _VersionConflictProblemCopyWith<$Res>
    implements $$VersionConflictProblemCopyWith<$Res> {
  _VersionConflictProblemCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final VersionConflictProblem _value;

  @_i3.override
  _i4.Problem get problem => _value.problem;

  @_i3.override
  _i5.VersionConflictProblemModel get versionConflictProblemModel =>
      _value.versionConflictProblemModel;

  @_i3.override
  $Res call({
    _i3.Object? problem = _sentinel,
    _i3.Object? versionConflictProblemModel = _sentinel,
  }) {
    return (VersionConflictProblem(
      problem: _i3.identical(problem, _sentinel)
          ? this.problem
          : (problem as _i4.Problem),
      versionConflictProblemModel:
          _i3.identical(versionConflictProblemModel, _sentinel)
          ? this.versionConflictProblemModel
          : (versionConflictProblemModel as _i5.VersionConflictProblemModel),
    ) as $Res);
  }
}
