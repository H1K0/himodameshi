// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/cable.dart' as _i2;
import 'package:himo_api/src/model/problem.dart' as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class UnarchiveCableResponse {
  const UnarchiveCableResponse();
}

@_i1.immutable
class UnarchiveCableResponse200 extends UnarchiveCableResponse {
  const UnarchiveCableResponse200({required this.body});

  final _i2.Cable body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is UnarchiveCableResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class UnarchiveCableResponse401 extends UnarchiveCableResponse {
  const UnarchiveCableResponse401({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is UnarchiveCableResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class UnarchiveCableResponse404 extends UnarchiveCableResponse {
  const UnarchiveCableResponse404({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is UnarchiveCableResponse404 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}
