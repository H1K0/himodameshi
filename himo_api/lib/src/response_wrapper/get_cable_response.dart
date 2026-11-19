// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/cable.dart' as _i2;
import 'package:himo_api/src/model/problem.dart' as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class GetCableResponse {
  const GetCableResponse();
}

@_i1.immutable
class GetCableResponse200 extends GetCableResponse {
  const GetCableResponse200({required this.body});

  final _i2.Cable body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetCableResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class GetCableResponse401 extends GetCableResponse {
  const GetCableResponse401({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetCableResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class GetCableResponse404 extends GetCableResponse {
  const GetCableResponse404({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetCableResponse404 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}
