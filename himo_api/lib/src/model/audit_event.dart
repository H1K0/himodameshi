// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i8;
import 'package:himo_api/src/model/audit_event_cable_id_all_of_model.dart'
    as _i5;
import 'package:himo_api/src/model/audit_event_subject_user_all_of_model.dart'
    as _i7;
import 'package:himo_api/src/model/audit_event_test_id_all_of_model.dart'
    as _i6;
import 'package:himo_api/src/model/user_ref.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class AuditEvent implements _i1.ParameterEncodable, _i1.UriEncodable {
  const AuditEvent({
    required this.id,
    required this.event,
    required this.actor,
    required this.cableId,
    required this.testId,
    required this.subjectUser,
    required this.details,
    required this.createdAt,
  });

  factory AuditEvent.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for AuditEvent: contains complex types',
    );
  }

  factory AuditEvent.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'AuditEvent');
    return AuditEvent(
      id: _$map[r'id'].decodeJsonInt(context: r'AuditEvent.id'),
      event: _$map[r'event'].decodeJsonString(context: r'AuditEvent.event'),
      actor: _i4.UserRef.fromJson(_$map[r'actor']),
      cableId: _$map[r'cable_id'] == null
          ? null
          : _i5.AuditEventCableIdAllOfModel.fromJson(_$map[r'cable_id']),
      testId: _$map[r'test_id'] == null
          ? null
          : _i6.AuditEventTestIdAllOfModel.fromJson(_$map[r'test_id']),
      subjectUser: _$map[r'subject_user'] == null
          ? null
          : _i7.AuditEventSubjectUserAllOfModel.fromJson(
              _$map[r'subject_user'],
            ),
      details: _$map[r'details'].decodeJsonMap(
        (v) => v,
        context: r'AuditEvent.details',
      ),
      createdAt: _$map[r'created_at'].decodeJsonDateTime(
        context: r'AuditEvent.created_at',
      ),
    );
  }

  factory AuditEvent.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for AuditEvent: contains complex types',
    );
  }

  final _i3.int id;

  /// Тип события — `docs/spec/hub/data-model.md`, раздел 3.6
  ///
  /// **Example**:
  /// ```
  /// cable.updated
  /// ```
  final _i3.String event;

  final _i4.UserRef actor;

  /// Кабель; может ссылаться на уже удалённый кабель
  final _i5.AuditEventCableIdAllOfModel? cableId;

  final _i6.AuditEventTestIdAllOfModel? testId;

  /// Кого пригласили, исключили, назначили
  final _i7.AuditEventSubjectUserAllOfModel? subjectUser;

  /// Подробности события, например «было / стало»
  ///
  /// **Example**:
  /// ```json
  /// {
  ///   "cable_name": "XLR 5 м",
  ///   "changes": {
  ///     "name": {
  ///       "from": "XLR 5м",
  ///       "to": "XLR 5 м"
  ///     }
  ///   }
  /// }
  /// ```
  final _i3.Map<_i3.String, _i3.Object?> details;

  final _i3.DateTime createdAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': id,
    r'event': event,
    r'actor': actor.toJson(),
    r'cable_id': cableId?.toJson(),
    r'test_id': testId?.toJson(),
    r'subject_user': subjectUser?.toJson(),
    r'details': details.map(
      (k, v) => _i3.MapEntry(
        k,
        _i1.encodeUnknownJson(v, context: r'AuditEvent.details'),
      ),
    ),
    r'created_at': createdAt.toTimeZonedIso8601String(),
  };

  $$AuditEventCopyWith<AuditEvent> get copyWith => _AuditEventCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i8.DeepCollectionEquality();
    return other is AuditEvent &&
        other.id == this.id &&
        other.event == this.event &&
        other.actor == this.actor &&
        other.cableId == this.cableId &&
        other.testId == this.testId &&
        other.subjectUser == this.subjectUser &&
        _$deepEquals.equals(other.details, this.details) &&
        other.createdAt == this.createdAt;
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i8.DeepCollectionEquality();
    return _i3.Object.hashAll([
      id,
      event,
      actor,
      cableId,
      testId,
      subjectUser,
      deepEquals.hash(details),
      createdAt,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for AuditEvent: contains complex types',
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
      r'Cannot uriEncode AuditEvent: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$AuditEventCopyWith<$Res> {
  factory $$AuditEventCopyWith(AuditEvent value) = _AuditEventCopyWith<$Res>;

  $Res call({
    _i3.int? id,
    _i3.String? event,
    _i4.UserRef? actor,
    _i5.AuditEventCableIdAllOfModel? cableId,
    _i6.AuditEventTestIdAllOfModel? testId,
    _i7.AuditEventSubjectUserAllOfModel? subjectUser,
    _i3.Map<_i3.String, _i3.Object?>? details,
    _i3.DateTime? createdAt,
  });
  _i3.int get id;
  _i3.String get event;
  _i4.UserRef get actor;
  _i5.AuditEventCableIdAllOfModel? get cableId;
  _i6.AuditEventTestIdAllOfModel? get testId;
  _i7.AuditEventSubjectUserAllOfModel? get subjectUser;
  _i3.Map<_i3.String, _i3.Object?> get details;
  _i3.DateTime get createdAt;
}

class _AuditEventCopyWith<$Res> implements $$AuditEventCopyWith<$Res> {
  _AuditEventCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final AuditEvent _value;

  @_i3.override
  _i3.int get id => _value.id;

  @_i3.override
  _i3.String get event => _value.event;

  @_i3.override
  _i4.UserRef get actor => _value.actor;

  @_i3.override
  _i5.AuditEventCableIdAllOfModel? get cableId => _value.cableId;

  @_i3.override
  _i6.AuditEventTestIdAllOfModel? get testId => _value.testId;

  @_i3.override
  _i7.AuditEventSubjectUserAllOfModel? get subjectUser => _value.subjectUser;

  @_i3.override
  _i3.Map<_i3.String, _i3.Object?> get details => _value.details;

  @_i3.override
  _i3.DateTime get createdAt => _value.createdAt;

  @_i3.override
  $Res call({
    _i3.Object? id = _sentinel,
    _i3.Object? event = _sentinel,
    _i3.Object? actor = _sentinel,
    _i3.Object? cableId = _sentinel,
    _i3.Object? testId = _sentinel,
    _i3.Object? subjectUser = _sentinel,
    _i3.Object? details = _sentinel,
    _i3.Object? createdAt = _sentinel,
  }) {
    return (AuditEvent(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i3.int),
      event: _i3.identical(event, _sentinel)
          ? this.event
          : (event as _i3.String),
      actor: _i3.identical(actor, _sentinel)
          ? this.actor
          : (actor as _i4.UserRef),
      cableId: _i3.identical(cableId, _sentinel)
          ? this.cableId
          : (cableId as _i5.AuditEventCableIdAllOfModel?),
      testId: _i3.identical(testId, _sentinel)
          ? this.testId
          : (testId as _i6.AuditEventTestIdAllOfModel?),
      subjectUser: _i3.identical(subjectUser, _sentinel)
          ? this.subjectUser
          : (subjectUser as _i7.AuditEventSubjectUserAllOfModel?),
      details: _i3.identical(details, _sentinel)
          ? this.details
          : (details as _i3.Map<_i3.String, _i3.Object?>),
      createdAt: _i3.identical(createdAt, _sentinel)
          ? this.createdAt
          : (createdAt as _i3.DateTime),
    ) as $Res);
  }
}
