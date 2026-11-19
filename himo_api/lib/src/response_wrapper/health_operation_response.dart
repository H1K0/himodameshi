// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/health.dart' as _i2;
import 'package:meta/meta.dart' as _i1;

sealed class HealthOperationResponse {
  const HealthOperationResponse();
}

@_i1.immutable
class HealthOperationResponse200 extends HealthOperationResponse {
  const HealthOperationResponse200({required this.body});

  final _i2.Health body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is HealthOperationResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class HealthOperationResponse503 extends HealthOperationResponse {
  const HealthOperationResponse503({required this.body});

  final _i2.Health body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is HealthOperationResponse503 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}
