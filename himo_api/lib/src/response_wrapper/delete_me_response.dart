// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i2;

import 'package:himo_api/src/model/problem.dart' as _i3;
import 'package:meta/meta.dart' as _i1;

sealed class DeleteMeResponse {
  const DeleteMeResponse();
}

@_i1.immutable
class DeleteMeResponse204 extends DeleteMeResponse {
  const DeleteMeResponse204();

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is DeleteMeResponse204;
  }

  @_i2.override
  _i2.int get hashCode => runtimeType.hashCode;
}

@_i1.immutable
class DeleteMeResponse401 extends DeleteMeResponse {
  const DeleteMeResponse401({required this.body});

  final _i3.Problem body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is DeleteMeResponse401 && other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => body.hashCode;
}

@_i1.immutable
class DeleteMeResponse409 extends DeleteMeResponse {
  const DeleteMeResponse409({required this.body});

  final _i3.Problem body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is DeleteMeResponse409 && other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => body.hashCode;
}
