// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i6;

import 'package:himo_api/src/model/invalidation_request.dart' as _i13;
import 'package:himo_api/src/model/sort_order.dart' as _i10;
import 'package:himo_api/src/model/uuid.dart' as _i9;
import 'package:himo_api/src/operation/get_test.dart' as _i3;
import 'package:himo_api/src/operation/invalidate_test.dart' as _i4;
import 'package:himo_api/src/operation/list_cable_tests.dart' as _i2;
import 'package:himo_api/src/operation/revalidate_test.dart' as _i5;
import 'package:himo_api/src/response_wrapper/get_test_response.dart' as _i11;
import 'package:himo_api/src/response_wrapper/invalidate_test_response.dart'
    as _i12;
import 'package:himo_api/src/response_wrapper/list_cable_tests_response.dart'
    as _i8;
import 'package:himo_api/src/response_wrapper/revalidate_test_response.dart'
    as _i14;
import 'package:himo_api/src/server/server.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i7;

/// Тесты (HUB-5, HUB-6)
class TestsApi {
  TestsApi(_i1.Server server)
    : _listCableTests = _i2.ListCableTests(server.dio),
      _getTest = _i3.GetTest(server.dio),
      _invalidateTest = _i4.InvalidateTest(server.dio),
      _revalidateTest = _i5.RevalidateTest(server.dio);

  final _i2.ListCableTests _listCableTests;

  final _i3.GetTest _getTest;

  final _i4.InvalidateTest _invalidateTest;

  final _i5.RevalidateTest _revalidateTest;

  /// История тестов кабеля
  /// Упорядочена по времени измерения, при совпадении — по ID. По умолчанию — сначала новые.
  /// Тесты отдаются с результатами: по ним строятся лента и графики динамики.
  ///
  ///
  /// Response 400 (application/problem+json):
  /// **Example**:
  /// ```json
  /// {
  ///   "type": "about:blank",
  ///   "title": "Bad Request",
  ///   "status": 400,
  ///   "code": "validation_error",
  ///   "detail": "Запрос не прошёл проверку",
  ///   "errors": [
  ///     {
  ///       "field": "name",
  ///       "message": "не может быть пустым"
  ///     }
  ///   ]
  /// }
  /// ```
  ///
  /// Response 401 (application/problem+json):
  /// **Example**:
  /// ```json
  /// {
  ///   "type": "about:blank",
  ///   "title": "Unauthorized",
  ///   "status": 401,
  ///   "code": "unauthorized"
  /// }
  /// ```
  ///
  /// Response 404 (application/problem+json):
  /// **Example**:
  /// ```json
  /// {
  ///   "type": "about:blank",
  ///   "title": "Not Found",
  ///   "status": 404,
  ///   "code": "not_found"
  /// }
  /// ```
  _i6.Future<_i7.TonikResult<_i8.ListCableTestsResponse>> listCableTests({
    required _i9.Uuid cableId,
    _i10.SortOrder? order,
    _i6.int limit = _i2.ListCableTests.limitDefault,
    _i6.int offset = _i2.ListCableTests.offsetDefault,
  }) async => _listCableTests(
    cableId: cableId,
    order: order,
    limit: limit,
    offset: offset,
  );

  /// Тест
  /// Вместе с тестом — ID предыдущего действительного и эталонного (первого действительного)
  /// тестов кабеля для сравнения. Сравнение строит клиент.
  ///
  ///
  /// Response 401 (application/problem+json):
  /// **Example**:
  /// ```json
  /// {
  ///   "type": "about:blank",
  ///   "title": "Unauthorized",
  ///   "status": 401,
  ///   "code": "unauthorized"
  /// }
  /// ```
  ///
  /// Response 404 (application/problem+json):
  /// **Example**:
  /// ```json
  /// {
  ///   "type": "about:blank",
  ///   "title": "Not Found",
  ///   "status": 404,
  ///   "code": "not_found"
  /// }
  /// ```
  _i6.Future<_i7.TonikResult<_i11.GetTestResponse>> getTest({
    required _i9.Uuid testId,
  }) async => _getTest(testId: testId);

  /// Пометить тест недействительным
  /// Тест остаётся в истории, но не учитывается в Health Score кабеля и в сравнениях.
  /// Повтор для уже помеченного теста заменяет причину. Архивный кабель — `cable_archived`.
  ///
  ///
  /// Response 400 (application/problem+json):
  /// **Example**:
  /// ```json
  /// {
  ///   "type": "about:blank",
  ///   "title": "Bad Request",
  ///   "status": 400,
  ///   "code": "validation_error",
  ///   "detail": "Запрос не прошёл проверку",
  ///   "errors": [
  ///     {
  ///       "field": "name",
  ///       "message": "не может быть пустым"
  ///     }
  ///   ]
  /// }
  /// ```
  ///
  /// Response 401 (application/problem+json):
  /// **Example**:
  /// ```json
  /// {
  ///   "type": "about:blank",
  ///   "title": "Unauthorized",
  ///   "status": 401,
  ///   "code": "unauthorized"
  /// }
  /// ```
  ///
  /// Response 404 (application/problem+json):
  /// **Example**:
  /// ```json
  /// {
  ///   "type": "about:blank",
  ///   "title": "Not Found",
  ///   "status": 404,
  ///   "code": "not_found"
  /// }
  /// ```
  ///
  /// Response 409 (application/problem+json):
  /// **Example**:
  /// ```json
  /// {
  ///   "type": "about:blank",
  ///   "title": "Conflict",
  ///   "status": 409,
  ///   "code": "member_limit_reached",
  ///   "detail": "В команде уже 5 участников — это лимит бесплатного тарифа"
  /// }
  /// ```
  _i6.Future<_i7.TonikResult<_i12.InvalidateTestResponse>> invalidateTest({
    required _i13.InvalidationRequest body,
    required _i9.Uuid testId,
  }) async => _invalidateTest(body: body, testId: testId);

  /// Снять пометку «недействительный»
  /// Повтор для теста без пометки ничего не меняет. Архивный кабель — `cable_archived`.
  ///
  /// Response 401 (application/problem+json):
  /// **Example**:
  /// ```json
  /// {
  ///   "type": "about:blank",
  ///   "title": "Unauthorized",
  ///   "status": 401,
  ///   "code": "unauthorized"
  /// }
  /// ```
  ///
  /// Response 404 (application/problem+json):
  /// **Example**:
  /// ```json
  /// {
  ///   "type": "about:blank",
  ///   "title": "Not Found",
  ///   "status": 404,
  ///   "code": "not_found"
  /// }
  /// ```
  ///
  /// Response 409 (application/problem+json):
  /// **Example**:
  /// ```json
  /// {
  ///   "type": "about:blank",
  ///   "title": "Conflict",
  ///   "status": 409,
  ///   "code": "member_limit_reached",
  ///   "detail": "В команде уже 5 участников — это лимит бесплатного тарифа"
  /// }
  /// ```
  _i6.Future<_i7.TonikResult<_i14.RevalidateTestResponse>> revalidateTest({
    required _i9.Uuid testId,
  }) async => _revalidateTest(testId: testId);
}
