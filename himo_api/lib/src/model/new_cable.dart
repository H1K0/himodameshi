// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/cable_name.dart' as _i6;
import 'package:himo_api/src/model/cable_note.dart' as _i8;
import 'package:himo_api/src/model/cable_type.dart' as _i4;
import 'package:himo_api/src/model/color.dart' as _i7;
import 'package:himo_api/src/model/uuid.dart' as _i5;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class NewCable implements _i1.ParameterEncodable, _i1.UriEncodable {
  const NewCable({
    required this.id,
    required this.teamId,
    required this.name,
    required this.cableType,
    required this.color,
    required this.note,
    required this.createdAt,
  });

  factory NewCable.fromSimple(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {
        r'id',
        r'team_id',
        r'name',
        r'cable_type',
        r'color',
        r'note',
        r'created_at',
      },
      listKeys: {},
      context: r'NewCable',
    );
    return NewCable(
      id: _$values[r'id'].decodeSimpleString(context: r'NewCable.id'),
      teamId: _$values[r'team_id'].decodeSimpleString(
        context: r'NewCable.team_id',
      ),
      name: _$values[r'name'].decodeSimpleString(context: r'NewCable.name'),
      cableType: _i4.CableType.fromSimple(
        _$values[r'cable_type'],
        explode: explode,
      ),
      color: _$values[r'color'].decodeSimpleString(context: r'NewCable.color'),
      note: _$values[r'note'].decodeSimpleNullableString(
        context: r'NewCable.note',
      ),
      createdAt: _$values[r'created_at'].decodeSimpleDateTime(
        context: r'NewCable.created_at',
      ),
    );
  }

  factory NewCable.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'NewCable');
    return NewCable(
      id: _$map[r'id'].decodeJsonString(context: r'NewCable.id'),
      teamId: _$map[r'team_id'].decodeJsonString(context: r'NewCable.team_id'),
      name: _$map[r'name'].decodeJsonString(context: r'NewCable.name'),
      cableType: _i4.CableType.fromJson(_$map[r'cable_type']),
      color: _$map[r'color'].decodeJsonString(context: r'NewCable.color'),
      note: _$map[r'note'].decodeJsonNullableString(context: r'NewCable.note'),
      createdAt: _$map[r'created_at'].decodeJsonDateTime(
        context: r'NewCable.created_at',
      ),
    );
  }

  factory NewCable.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'id',
        r'team_id',
        r'name',
        r'cable_type',
        r'color',
        r'note',
        r'created_at',
      },
      listKeys: {},
      context: r'NewCable',
    );
    return NewCable(
      id: _$values[r'id'].decodeFormString(context: r'NewCable.id'),
      teamId: _$values[r'team_id'].decodeFormString(
        context: r'NewCable.team_id',
      ),
      name: _$values[r'name'].decodeFormString(context: r'NewCable.name'),
      cableType: _i4.CableType.fromForm(
        _$values[r'cable_type'],
        explode: explode,
      ),
      color: _$values[r'color'].decodeFormString(context: r'NewCable.color'),
      note: _$values[r'note'].decodeFormNullableString(
        context: r'NewCable.note',
      ),
      createdAt: _$values[r'created_at'].decodeFormDateTime(
        context: r'NewCable.created_at',
      ),
    );
  }

  final _i5.Uuid id;

  final _i5.Uuid teamId;

  final _i6.CableName name;

  final _i4.CableType cableType;

  final _i7.Color color;

  final _i8.CableNote note;

  /// Время создания в приложении
  final _i3.DateTime createdAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': id,
    r'team_id': teamId,
    r'name': name,
    r'cable_type': cableType.toJson(),
    r'color': color,
    r'note': note,
    r'created_at': createdAt.toTimeZonedIso8601String(),
  };

  $$NewCableCopyWith<NewCable> get copyWith => _NewCableCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is NewCable &&
        other.id == this.id &&
        other.teamId == this.teamId &&
        other.name == this.name &&
        other.cableType == this.cableType &&
        other.color == this.color &&
        other.note == this.note &&
        other.createdAt == this.createdAt;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      id,
      teamId,
      name,
      cableType,
      color,
      note,
      createdAt,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(id);
    _$result[r'team_id'] = _i1.PropertyValue.scalar(teamId);
    _$result[r'name'] = _i1.PropertyValue.scalar(name);
    _$result[r'cable_type'] = _i1.PropertyValue.scalar(cableType.toJson());
    _$result[r'color'] = _i1.PropertyValue.scalar(color);
    if (note != null) {
      _$result[r'note'] = _i1.PropertyValue.scalar(note!);
    }
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
      r'Cannot uriEncode NewCable: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$NewCableCopyWith<$Res> {
  factory $$NewCableCopyWith(NewCable value) = _NewCableCopyWith<$Res>;

  $Res call({
    _i5.Uuid? id,
    _i5.Uuid? teamId,
    _i6.CableName? name,
    _i4.CableType? cableType,
    _i7.Color? color,
    _i8.CableNote? note,
    _i3.DateTime? createdAt,
  });
  _i5.Uuid get id;
  _i5.Uuid get teamId;
  _i6.CableName get name;
  _i4.CableType get cableType;
  _i7.Color get color;
  _i8.CableNote get note;
  _i3.DateTime get createdAt;
}

class _NewCableCopyWith<$Res> implements $$NewCableCopyWith<$Res> {
  _NewCableCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final NewCable _value;

  @_i3.override
  _i5.Uuid get id => _value.id;

  @_i3.override
  _i5.Uuid get teamId => _value.teamId;

  @_i3.override
  _i6.CableName get name => _value.name;

  @_i3.override
  _i4.CableType get cableType => _value.cableType;

  @_i3.override
  _i7.Color get color => _value.color;

  @_i3.override
  _i8.CableNote get note => _value.note;

  @_i3.override
  _i3.DateTime get createdAt => _value.createdAt;

  @_i3.override
  $Res call({
    _i3.Object? id = _sentinel,
    _i3.Object? teamId = _sentinel,
    _i3.Object? name = _sentinel,
    _i3.Object? cableType = _sentinel,
    _i3.Object? color = _sentinel,
    _i3.Object? note = _sentinel,
    _i3.Object? createdAt = _sentinel,
  }) {
    return (NewCable(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i5.Uuid),
      teamId: _i3.identical(teamId, _sentinel)
          ? this.teamId
          : (teamId as _i5.Uuid),
      name: _i3.identical(name, _sentinel)
          ? this.name
          : (name as _i6.CableName),
      cableType: _i3.identical(cableType, _sentinel)
          ? this.cableType
          : (cableType as _i4.CableType),
      color: _i3.identical(color, _sentinel)
          ? this.color
          : (color as _i7.Color),
      note: _i3.identical(note, _sentinel)
          ? this.note
          : (note as _i8.CableNote),
      createdAt: _i3.identical(createdAt, _sentinel)
          ? this.createdAt
          : (createdAt as _i3.DateTime),
    ) as $Res);
  }
}
