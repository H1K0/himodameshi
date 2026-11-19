// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/uuid.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class Insight implements _i1.ParameterEncodable, _i1.UriEncodable {
  const Insight({
    required this.id,
    required this.body,
    required this.model,
    required this.createdAt,
  });

  factory Insight.fromSimple(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'id', r'body', r'model', r'created_at'},
      listKeys: {},
      context: r'Insight',
    );
    return Insight(
      id: _$values[r'id'].decodeSimpleString(context: r'Insight.id'),
      body: _$values[r'body'].decodeSimpleString(context: r'Insight.body'),
      model: _$values[r'model'].decodeSimpleString(context: r'Insight.model'),
      createdAt: _$values[r'created_at'].decodeSimpleDateTime(
        context: r'Insight.created_at',
      ),
    );
  }

  factory Insight.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Insight');
    return Insight(
      id: _$map[r'id'].decodeJsonString(context: r'Insight.id'),
      body: _$map[r'body'].decodeJsonString(context: r'Insight.body'),
      model: _$map[r'model'].decodeJsonString(context: r'Insight.model'),
      createdAt: _$map[r'created_at'].decodeJsonDateTime(
        context: r'Insight.created_at',
      ),
    );
  }

  factory Insight.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'id', r'body', r'model', r'created_at'},
      listKeys: {},
      context: r'Insight',
    );
    return Insight(
      id: _$values[r'id'].decodeFormString(context: r'Insight.id'),
      body: _$values[r'body'].decodeFormString(context: r'Insight.body'),
      model: _$values[r'model'].decodeFormString(context: r'Insight.model'),
      createdAt: _$values[r'created_at'].decodeFormDateTime(
        context: r'Insight.created_at',
      ),
    );
  }

  final _i4.Uuid id;

  /// Текст комментария
  ///
  /// **Example**:
  /// ```
  /// Все три проводника в норме, синфазные помехи подавляются отлично. Небольшой спад АЧХ выше 20 кГц за пределами слышимого диапазона.
  /// ```
  final _i3.String body;

  /// **Example**:
  /// ```
  /// glm-4.7-flash
  /// ```
  final _i3.String model;

  final _i3.DateTime createdAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': id,
    r'body': body,
    r'model': model,
    r'created_at': createdAt.toTimeZonedIso8601String(),
  };

  $$InsightCopyWith<Insight> get copyWith => _InsightCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is Insight &&
        other.id == this.id &&
        other.body == this.body &&
        other.model == this.model &&
        other.createdAt == this.createdAt;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([id, body, model, createdAt]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(id);
    _$result[r'body'] = _i1.PropertyValue.scalar(body);
    _$result[r'model'] = _i1.PropertyValue.scalar(model);
    _$result[r'created_at'] = _i1.PropertyValue.scalar(
      createdAt.toTimeZonedIso8601String(),
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
      r'Cannot uriEncode Insight: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$InsightCopyWith<$Res> {
  factory $$InsightCopyWith(Insight value) = _InsightCopyWith<$Res>;

  $Res call({
    _i4.Uuid? id,
    _i3.String? body,
    _i3.String? model,
    _i3.DateTime? createdAt,
  });
  _i4.Uuid get id;
  _i3.String get body;
  _i3.String get model;
  _i3.DateTime get createdAt;
}

class _InsightCopyWith<$Res> implements $$InsightCopyWith<$Res> {
  _InsightCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final Insight _value;

  @_i3.override
  _i4.Uuid get id => _value.id;

  @_i3.override
  _i3.String get body => _value.body;

  @_i3.override
  _i3.String get model => _value.model;

  @_i3.override
  _i3.DateTime get createdAt => _value.createdAt;

  @_i3.override
  $Res call({
    _i3.Object? id = _sentinel,
    _i3.Object? body = _sentinel,
    _i3.Object? model = _sentinel,
    _i3.Object? createdAt = _sentinel,
  }) {
    return (Insight(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i4.Uuid),
      body: _i3.identical(body, _sentinel) ? this.body : (body as _i3.String),
      model: _i3.identical(model, _sentinel)
          ? this.model
          : (model as _i3.String),
      createdAt: _i3.identical(createdAt, _sentinel)
          ? this.createdAt
          : (createdAt as _i3.DateTime),
    ) as $Res);
  }
}
