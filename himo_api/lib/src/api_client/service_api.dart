// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/operation/health_operation.dart' as _i2;
import 'package:himo_api/src/response_wrapper/health_operation_response.dart'
    as _i5;
import 'package:himo_api/src/server/server.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i4;

/// Служебные эндпоинты
class ServiceApi {
  ServiceApi(_i1.Server server)
    : _healthOperation = _i2.HealthOperation(server.dio);

  final _i2.HealthOperation _healthOperation;

  /// Проверка сервера и БД
  _i3.Future<_i4.TonikResult<_i5.HealthOperationResponse>>
  healthOperation() async => _healthOperation();
}
