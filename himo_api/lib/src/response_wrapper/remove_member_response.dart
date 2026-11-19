// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i2;

import 'package:himo_api/src/model/problem.dart' as _i3;
import 'package:meta/meta.dart' as _i1;

sealed class RemoveMemberResponse {
  const RemoveMemberResponse();
}

@_i1.immutable
class RemoveMemberResponse204 extends RemoveMemberResponse {
  const RemoveMemberResponse204();

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is RemoveMemberResponse204;
  }

  @_i2.override
  _i2.int get hashCode => runtimeType.hashCode;
}

@_i1.immutable
class RemoveMemberResponse401 extends RemoveMemberResponse {
  const RemoveMemberResponse401({required this.body});

  final _i3.Problem body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is RemoveMemberResponse401 && other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => body.hashCode;
}

@_i1.immutable
class RemoveMemberResponse403 extends RemoveMemberResponse {
  const RemoveMemberResponse403({required this.body});

  final _i3.Problem body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is RemoveMemberResponse403 && other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => body.hashCode;
}

@_i1.immutable
class RemoveMemberResponse404 extends RemoveMemberResponse {
  const RemoveMemberResponse404({required this.body});

  final _i3.Problem body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is RemoveMemberResponse404 && other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => body.hashCode;
}

@_i1.immutable
class RemoveMemberResponse409 extends RemoveMemberResponse {
  const RemoveMemberResponse409({required this.body});

  final _i3.Problem body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is RemoveMemberResponse409 && other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => body.hashCode;
}
