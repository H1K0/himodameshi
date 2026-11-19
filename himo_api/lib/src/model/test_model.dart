// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/test_insight_all_of_model.dart' as _i6;
import 'package:himo_api/src/model/test_invalidation_all_of_model.dart' as _i5;
import 'package:himo_api/src/model/user_ref.dart' as _i4;
import 'package:himo_api/src/model/uuid.dart' as _i7;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class TestModel implements _i1.ParameterEncodable, _i1.UriEncodable {
  const TestModel({
    required this.id,
    required this.cableId,
    required this.author,
    required this.receivedAt,
    required this.invalidation,
    required this.insight,
  });

  factory TestModel.fromSimple(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for TestModel: contains complex types',
    );
  }

  factory TestModel.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'TestModel');
    return TestModel(
      id: _$map[r'id'].decodeJsonString(context: r'TestModel.id'),
      cableId: _$map[r'cable_id'].decodeJsonString(
        context: r'TestModel.cable_id',
      ),
      author: _i4.UserRef.fromJson(_$map[r'author']),
      receivedAt: _$map[r'received_at'].decodeJsonDateTime(
        context: r'TestModel.received_at',
      ),
      invalidation: _$map[r'invalidation'] == null
          ? null
          : _i5.TestInvalidationAllOfModel.fromJson(_$map[r'invalidation']),
      insight: _$map[r'insight'] == null
          ? null
          : _i6.TestInsightAllOfModel.fromJson(_$map[r'insight']),
    );
  }

  factory TestModel.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for TestModel: contains complex types',
    );
  }

  final _i7.Uuid id;

  final _i7.Uuid cableId;

  final _i4.UserRef author;

  /// Время приёма сервером
  final _i3.DateTime receivedAt;

  /// Пометка «недействительный» или `null`
  final _i5.TestInvalidationAllOfModel? invalidation;

  /// Привязанный ИИ-комментарий или `null`
  final _i6.TestInsightAllOfModel? insight;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': id,
    r'cable_id': cableId,
    r'author': author.toJson(),
    r'received_at': receivedAt.toTimeZonedIso8601String(),
    r'invalidation': invalidation?.toJson(),
    r'insight': insight?.toJson(),
  };

  $$TestModelCopyWith<TestModel> get copyWith => _TestModelCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is TestModel &&
        other.id == this.id &&
        other.cableId == this.cableId &&
        other.author == this.author &&
        other.receivedAt == this.receivedAt &&
        other.invalidation == this.invalidation &&
        other.insight == this.insight;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      id,
      cableId,
      author,
      receivedAt,
      invalidation,
      insight,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for TestModel: contains complex types',
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
      r'Cannot uriEncode TestModel: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$TestModelCopyWith<$Res> {
  factory $$TestModelCopyWith(TestModel value) = _TestModelCopyWith<$Res>;

  $Res call({
    _i7.Uuid? id,
    _i7.Uuid? cableId,
    _i4.UserRef? author,
    _i3.DateTime? receivedAt,
    _i5.TestInvalidationAllOfModel? invalidation,
    _i6.TestInsightAllOfModel? insight,
  });
  _i7.Uuid get id;
  _i7.Uuid get cableId;
  _i4.UserRef get author;
  _i3.DateTime get receivedAt;
  _i5.TestInvalidationAllOfModel? get invalidation;
  _i6.TestInsightAllOfModel? get insight;
}

class _TestModelCopyWith<$Res> implements $$TestModelCopyWith<$Res> {
  _TestModelCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final TestModel _value;

  @_i3.override
  _i7.Uuid get id => _value.id;

  @_i3.override
  _i7.Uuid get cableId => _value.cableId;

  @_i3.override
  _i4.UserRef get author => _value.author;

  @_i3.override
  _i3.DateTime get receivedAt => _value.receivedAt;

  @_i3.override
  _i5.TestInvalidationAllOfModel? get invalidation => _value.invalidation;

  @_i3.override
  _i6.TestInsightAllOfModel? get insight => _value.insight;

  @_i3.override
  $Res call({
    _i3.Object? id = _sentinel,
    _i3.Object? cableId = _sentinel,
    _i3.Object? author = _sentinel,
    _i3.Object? receivedAt = _sentinel,
    _i3.Object? invalidation = _sentinel,
    _i3.Object? insight = _sentinel,
  }) {
    return (TestModel(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i7.Uuid),
      cableId: _i3.identical(cableId, _sentinel)
          ? this.cableId
          : (cableId as _i7.Uuid),
      author: _i3.identical(author, _sentinel)
          ? this.author
          : (author as _i4.UserRef),
      receivedAt: _i3.identical(receivedAt, _sentinel)
          ? this.receivedAt
          : (receivedAt as _i3.DateTime),
      invalidation: _i3.identical(invalidation, _sentinel)
          ? this.invalidation
          : (invalidation as _i5.TestInvalidationAllOfModel?),
      insight: _i3.identical(insight, _sentinel)
          ? this.insight
          : (insight as _i6.TestInsightAllOfModel?),
    ) as $Res);
  }
}
