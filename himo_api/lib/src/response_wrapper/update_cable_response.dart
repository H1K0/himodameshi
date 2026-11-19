// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/cable.dart' as _i2;
import 'package:himo_api/src/model/problem.dart' as _i4;
import 'package:himo_api/src/model/version_conflict_problem.dart' as _i5;
import 'package:meta/meta.dart' as _i1;

sealed class UpdateCableResponse {
  const UpdateCableResponse();
}

@_i1.immutable
class UpdateCableResponse200 extends UpdateCableResponse {
  const UpdateCableResponse200({required this.body});

  final _i2.Cable body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is UpdateCableResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class UpdateCableResponse400 extends UpdateCableResponse {
  const UpdateCableResponse400({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is UpdateCableResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class UpdateCableResponse401 extends UpdateCableResponse {
  const UpdateCableResponse401({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is UpdateCableResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class UpdateCableResponse404 extends UpdateCableResponse {
  const UpdateCableResponse404({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is UpdateCableResponse404 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class UpdateCableResponse409 extends UpdateCableResponse {
  const UpdateCableResponse409({required this.body});

  final _i5.VersionConflictProblem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is UpdateCableResponse409 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}
