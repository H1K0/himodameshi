// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i2;

import 'package:himo_api/src/model/problem.dart' as _i3;
import 'package:meta/meta.dart' as _i1;

sealed class DeleteCableResponse {
  const DeleteCableResponse();
}

@_i1.immutable
class DeleteCableResponse204 extends DeleteCableResponse {
  const DeleteCableResponse204();

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is DeleteCableResponse204;
  }

  @_i2.override
  _i2.int get hashCode => runtimeType.hashCode;
}

@_i1.immutable
class DeleteCableResponse401 extends DeleteCableResponse {
  const DeleteCableResponse401({required this.body});

  final _i3.Problem body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is DeleteCableResponse401 && other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => body.hashCode;
}

@_i1.immutable
class DeleteCableResponse403 extends DeleteCableResponse {
  const DeleteCableResponse403({required this.body});

  final _i3.Problem body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is DeleteCableResponse403 && other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => body.hashCode;
}

@_i1.immutable
class DeleteCableResponse404 extends DeleteCableResponse {
  const DeleteCableResponse404({required this.body});

  final _i3.Problem body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is DeleteCableResponse404 && other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => body.hashCode;
}
