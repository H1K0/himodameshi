// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/cable_name.dart' as _i6;
import 'package:himo_api/src/model/cable_note.dart' as _i8;
import 'package:himo_api/src/model/cable_type.dart' as _i4;
import 'package:himo_api/src/model/cable_update_assignee_id_all_of_model.dart'
    as _i5;
import 'package:himo_api/src/model/color.dart' as _i7;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// Все изменяемые атрибуты кабеля и версия, от которой сделана правка
@_i2.immutable
class CableUpdate implements _i1.ParameterEncodable, _i1.UriEncodable {
  const CableUpdate({
    required this.version,
    required this.name,
    required this.cableType,
    required this.color,
    required this.note,
    required this.assigneeId,
  });

  factory CableUpdate.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {
        r'version',
        r'name',
        r'cable_type',
        r'color',
        r'note',
        r'assignee_id',
      },
      listKeys: {},
      context: r'CableUpdate',
    );
    return CableUpdate(
      version: _$values[r'version'].decodeSimpleInt(
        context: r'CableUpdate.version',
      ),
      name: _$values[r'name'].decodeSimpleString(context: r'CableUpdate.name'),
      cableType: _i4.CableType.fromSimple(
        _$values[r'cable_type'],
        explode: explode,
      ),
      color: _$values[r'color'].decodeSimpleString(
        context: r'CableUpdate.color',
      ),
      note: _$values[r'note'].decodeSimpleNullableString(
        context: r'CableUpdate.note',
      ),
      assigneeId: _$values[r'assignee_id'] == null
          ? null
          : _i5.CableUpdateAssigneeIdAllOfModel.fromSimple(
              _$values[r'assignee_id'],
              explode: explode,
            ),
    );
  }

  factory CableUpdate.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'CableUpdate');
    return CableUpdate(
      version: _$map[r'version'].decodeJsonInt(context: r'CableUpdate.version'),
      name: _$map[r'name'].decodeJsonString(context: r'CableUpdate.name'),
      cableType: _i4.CableType.fromJson(_$map[r'cable_type']),
      color: _$map[r'color'].decodeJsonString(context: r'CableUpdate.color'),
      note: _$map[r'note'].decodeJsonNullableString(
        context: r'CableUpdate.note',
      ),
      assigneeId: _$map[r'assignee_id'] == null
          ? null
          : _i5.CableUpdateAssigneeIdAllOfModel.fromJson(_$map[r'assignee_id']),
    );
  }

  factory CableUpdate.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'version',
        r'name',
        r'cable_type',
        r'color',
        r'note',
        r'assignee_id',
      },
      listKeys: {},
      context: r'CableUpdate',
    );
    return CableUpdate(
      version: _$values[r'version'].decodeFormInt(
        context: r'CableUpdate.version',
      ),
      name: _$values[r'name'].decodeFormString(context: r'CableUpdate.name'),
      cableType: _i4.CableType.fromForm(
        _$values[r'cable_type'],
        explode: explode,
      ),
      color: _$values[r'color'].decodeFormString(context: r'CableUpdate.color'),
      note: _$values[r'note'].decodeFormNullableString(
        context: r'CableUpdate.note',
      ),
      assigneeId: _$values[r'assignee_id'] == null
          ? null
          : _i5.CableUpdateAssigneeIdAllOfModel.fromForm(
              _$values[r'assignee_id'],
              explode: explode,
            ),
    );
  }

  /// **Example**:
  /// ```json
  /// 2
  /// ```
  final _i3.int version;

  final _i6.CableName name;

  final _i4.CableType cableType;

  final _i7.Color color;

  final _i8.CableNote note;

  /// Ответственный или `null` — не назначен
  final _i5.CableUpdateAssigneeIdAllOfModel? assigneeId;

  @_i3.override
  _i3.Object? toJson() => {
    r'version': version,
    r'name': name,
    r'cable_type': cableType.toJson(),
    r'color': color,
    r'note': note,
    r'assignee_id': assigneeId?.toJson(),
  };

  $$CableUpdateCopyWith<CableUpdate> get copyWith => _CableUpdateCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CableUpdate &&
        other.version == this.version &&
        other.name == this.name &&
        other.cableType == this.cableType &&
        other.color == this.color &&
        other.note == this.note &&
        other.assigneeId == this.assigneeId;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      version,
      name,
      cableType,
      color,
      note,
      assigneeId,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'version'] = _i1.PropertyValue.scalar(version.toString());
    _$result[r'name'] = _i1.PropertyValue.scalar(name);
    _$result[r'cable_type'] = _i1.PropertyValue.scalar(cableType.toJson());
    _$result[r'color'] = _i1.PropertyValue.scalar(color);
    if (note != null) {
      _$result[r'note'] = _i1.PropertyValue.scalar(note!);
    }
    if (assigneeId != null) {
      _$result[r'assignee_id'] = _i1.PropertyValue.scalar(
        _i1.encodeAnyValueToString(
          assigneeId!.toJson(),
          allowEmpty: allowEmpty,
        ),
      );
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
      r'Cannot uriEncode CableUpdate: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$CableUpdateCopyWith<$Res> {
  factory $$CableUpdateCopyWith(CableUpdate value) = _CableUpdateCopyWith<$Res>;

  $Res call({
    _i3.int? version,
    _i6.CableName? name,
    _i4.CableType? cableType,
    _i7.Color? color,
    _i8.CableNote? note,
    _i5.CableUpdateAssigneeIdAllOfModel? assigneeId,
  });
  _i3.int get version;
  _i6.CableName get name;
  _i4.CableType get cableType;
  _i7.Color get color;
  _i8.CableNote get note;
  _i5.CableUpdateAssigneeIdAllOfModel? get assigneeId;
}

class _CableUpdateCopyWith<$Res> implements $$CableUpdateCopyWith<$Res> {
  _CableUpdateCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final CableUpdate _value;

  @_i3.override
  _i3.int get version => _value.version;

  @_i3.override
  _i6.CableName get name => _value.name;

  @_i3.override
  _i4.CableType get cableType => _value.cableType;

  @_i3.override
  _i7.Color get color => _value.color;

  @_i3.override
  _i8.CableNote get note => _value.note;

  @_i3.override
  _i5.CableUpdateAssigneeIdAllOfModel? get assigneeId => _value.assigneeId;

  @_i3.override
  $Res call({
    _i3.Object? version = _sentinel,
    _i3.Object? name = _sentinel,
    _i3.Object? cableType = _sentinel,
    _i3.Object? color = _sentinel,
    _i3.Object? note = _sentinel,
    _i3.Object? assigneeId = _sentinel,
  }) {
    return (CableUpdate(
      version: _i3.identical(version, _sentinel)
          ? this.version
          : (version as _i3.int),
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
      assigneeId: _i3.identical(assigneeId, _sentinel)
          ? this.assigneeId
          : (assigneeId as _i5.CableUpdateAssigneeIdAllOfModel?),
    ) as $Res);
  }
}
