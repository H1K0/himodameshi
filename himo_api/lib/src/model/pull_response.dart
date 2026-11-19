// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i7;
import 'package:himo_api/src/model/cable.dart' as _i4;
import 'package:himo_api/src/model/test.dart' as _i5;
import 'package:himo_api/src/model/uuid.dart' as _i6;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class PullResponse implements _i1.ParameterEncodable, _i1.UriEncodable {
  const PullResponse({
    required this.cables,
    required this.tests,
    required this.deletedCables,
    required this.cursor,
    required this.hasMore,
  });

  factory PullResponse.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for PullResponse: contains complex types',
    );
  }

  factory PullResponse.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'PullResponse');
    return PullResponse(
      cables: _$map[r'cables']
          .decodeJsonList<_i3.Object?>(context: r'PullResponse.cables')
          .map(_i4.Cable.fromJson)
          .toList(),
      tests: _$map[r'tests']
          .decodeJsonList<_i3.Object?>(context: r'PullResponse.tests')
          .map(_i5.Test.fromJson)
          .toList(),
      deletedCables: _$map[r'deleted_cables'].decodeJsonList<_i6.Uuid>(
        context: r'PullResponse.deleted_cables',
      ),
      cursor: _$map[r'cursor'].decodeJsonInt(context: r'PullResponse.cursor'),
      hasMore: _$map[r'has_more'].decodeJsonBool(
        context: r'PullResponse.has_more',
      ),
    );
  }

  factory PullResponse.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for PullResponse: contains complex types',
    );
  }

  /// Отслеживаемые кабели, изменённые после курсора
  final _i3.List<_i4.Cable> cables;

  /// Новые и изменённые тесты отслеживаемых кабелей, по возрастанию номера изменения, до 100
  final _i3.List<_i5.Test> tests;

  /// Отслеживаемые кабели, которых в команде больше нет
  final _i3.List<_i6.Uuid> deletedCables;

  /// Новый курсор
  ///
  /// **Example**:
  /// ```json
  /// 5
  /// ```
  final _i3.int cursor;

  /// Есть ещё изменения — повторить запрос с новым курсором
  final _i3.bool hasMore;

  @_i3.override
  _i3.Object? toJson() => {
    r'cables': cables.map((e) => e.toJson()).toList(),
    r'tests': tests.map((e) => e.toJson()).toList(),
    r'deleted_cables': deletedCables,
    r'cursor': cursor,
    r'has_more': hasMore,
  };

  $$PullResponseCopyWith<PullResponse> get copyWith =>
      _PullResponseCopyWith(this);

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i7.DeepCollectionEquality();
    return other is PullResponse &&
        _$deepEquals.equals(other.cables, this.cables) &&
        _$deepEquals.equals(other.tests, this.tests) &&
        _$deepEquals.equals(other.deletedCables, this.deletedCables) &&
        other.cursor == this.cursor &&
        other.hasMore == this.hasMore;
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i7.DeepCollectionEquality();
    return _i3.Object.hashAll([
      deepEquals.hash(cables),
      deepEquals.hash(tests),
      deepEquals.hash(deletedCables),
      cursor,
      hasMore,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for PullResponse: contains complex types',
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
      r'Cannot uriEncode PullResponse: complex types cannot be URI-encoded',
    );
  }
}

abstract class $$PullResponseCopyWith<$Res> {
  factory $$PullResponseCopyWith(PullResponse value) =
      _PullResponseCopyWith<$Res>;

  $Res call({
    _i3.List<_i4.Cable>? cables,
    _i3.List<_i5.Test>? tests,
    _i3.List<_i6.Uuid>? deletedCables,
    _i3.int? cursor,
    _i3.bool? hasMore,
  });
  _i3.List<_i4.Cable> get cables;
  _i3.List<_i5.Test> get tests;
  _i3.List<_i6.Uuid> get deletedCables;
  _i3.int get cursor;
  _i3.bool get hasMore;
}

class _PullResponseCopyWith<$Res> implements $$PullResponseCopyWith<$Res> {
  _PullResponseCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final PullResponse _value;

  @_i3.override
  _i3.List<_i4.Cable> get cables => _value.cables;

  @_i3.override
  _i3.List<_i5.Test> get tests => _value.tests;

  @_i3.override
  _i3.List<_i6.Uuid> get deletedCables => _value.deletedCables;

  @_i3.override
  _i3.int get cursor => _value.cursor;

  @_i3.override
  _i3.bool get hasMore => _value.hasMore;

  @_i3.override
  $Res call({
    _i3.Object? cables = _sentinel,
    _i3.Object? tests = _sentinel,
    _i3.Object? deletedCables = _sentinel,
    _i3.Object? cursor = _sentinel,
    _i3.Object? hasMore = _sentinel,
  }) {
    return (PullResponse(
      cables: _i3.identical(cables, _sentinel)
          ? this.cables
          : (cables as _i3.List<_i4.Cable>),
      tests: _i3.identical(tests, _sentinel)
          ? this.tests
          : (tests as _i3.List<_i5.Test>),
      deletedCables: _i3.identical(deletedCables, _sentinel)
          ? this.deletedCables
          : (deletedCables as _i3.List<_i6.Uuid>),
      cursor: _i3.identical(cursor, _sentinel)
          ? this.cursor
          : (cursor as _i3.int),
      hasMore: _i3.identical(hasMore, _sentinel)
          ? this.hasMore
          : (hasMore as _i3.bool),
    ) as $Res);
  }
}
