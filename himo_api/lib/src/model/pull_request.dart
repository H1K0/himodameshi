// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i5;
import 'package:himo_api/src/model/uuid.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class PullRequest implements _i1.ParameterEncodable, _i1.UriEncodable {
  const PullRequest({
    required this.teamId,
    required this.cursor,
    required this.cables,
  });

  factory PullRequest.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'team_id', r'cursor', r'cables'},
      listKeys: {r'cables'},
      context: r'PullRequest',
    );
    return PullRequest(
      teamId: _$values[r'team_id'].decodeSimpleString(
        context: r'PullRequest.team_id',
      ),
      cursor: _$values[r'cursor'].decodeSimpleInt(
        context: r'PullRequest.cursor',
      ),
      cables: _$values[r'cables'].decodeSimpleStringList(
        context: r'PullRequest.cables',
      ),
    );
  }

  factory PullRequest.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'PullRequest');
    return PullRequest(
      teamId: _$map[r'team_id'].decodeJsonString(
        context: r'PullRequest.team_id',
      ),
      cursor: _$map[r'cursor'].decodeJsonInt(context: r'PullRequest.cursor'),
      cables: _$map[r'cables'].decodeJsonList<_i4.Uuid>(
        context: r'PullRequest.cables',
      ),
    );
  }

  factory PullRequest.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'team_id', r'cursor', r'cables'},
      listKeys: {r'cables'},
      context: r'PullRequest',
    );
    return PullRequest(
      teamId: _$values[r'team_id'].decodeFormString(
        context: r'PullRequest.team_id',
      ),
      cursor: _$values[r'cursor'].decodeFormInt(context: r'PullRequest.cursor'),
      cables: _$values[r'cables'].decodeFormStringList(
        context: r'PullRequest.cables',
      ),
    );
  }

  final _i4.Uuid teamId;

  /// Курсор команды из прошлого ответа; `0` — с начала
  ///
  /// **Example**:
  /// ```json
  /// 3
  /// ```
  final _i3.int cursor;

  /// Отслеживаемые кабели команды
  final _i3.List<_i4.Uuid> cables;

  @_i3.override
  _i3.Object? toJson() => {
    r'team_id': teamId,
    r'cursor': cursor,
    r'cables': cables,
  };

  $$PullRequestCopyWith<PullRequest> get copyWith => _PullRequestCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i5.DeepCollectionEquality();
    return other is PullRequest &&
        other.teamId == this.teamId &&
        other.cursor == this.cursor &&
        _$deepEquals.equals(other.cables, this.cables);
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i5.DeepCollectionEquality();
    return _i3.Object.hashAll([teamId, cursor, deepEquals.hash(cables)]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'team_id'] = _i1.PropertyValue.scalar(teamId);
    _$result[r'cursor'] = _i1.PropertyValue.scalar(cursor.toString());
    _$result[r'cables'] = _i1.PropertyValue.array(cables);
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
      r'Cannot uriEncode PullRequest: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$PullRequestCopyWith<$Res> {
  factory $$PullRequestCopyWith(PullRequest value) = _PullRequestCopyWith<$Res>;

  $Res call({_i4.Uuid? teamId, _i3.int? cursor, _i3.List<_i4.Uuid>? cables});
  _i4.Uuid get teamId;
  _i3.int get cursor;
  _i3.List<_i4.Uuid> get cables;
}

class _PullRequestCopyWith<$Res> implements $$PullRequestCopyWith<$Res> {
  _PullRequestCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final PullRequest _value;

  @_i3.override
  _i4.Uuid get teamId => _value.teamId;

  @_i3.override
  _i3.int get cursor => _value.cursor;

  @_i3.override
  _i3.List<_i4.Uuid> get cables => _value.cables;

  @_i3.override
  $Res call({
    _i3.Object? teamId = _sentinel,
    _i3.Object? cursor = _sentinel,
    _i3.Object? cables = _sentinel,
  }) {
    return (PullRequest(
      teamId: _i3.identical(teamId, _sentinel)
          ? this.teamId
          : (teamId as _i4.Uuid),
      cursor: _i3.identical(cursor, _sentinel)
          ? this.cursor
          : (cursor as _i3.int),
      cables: _i3.identical(cables, _sentinel)
          ? this.cables
          : (cables as _i3.List<_i4.Uuid>),
    ) as $Res);
  }
}
