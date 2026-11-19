// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/problem.dart' as _i4;
import 'package:himo_api/src/model/user.dart' as _i2;
import 'package:meta/meta.dart' as _i1;

sealed class LinkTelegramResponse {
  const LinkTelegramResponse();
}

@_i1.immutable
class LinkTelegramResponse200 extends LinkTelegramResponse {
  const LinkTelegramResponse200({required this.body});

  final _i2.User body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LinkTelegramResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class LinkTelegramResponse400 extends LinkTelegramResponse {
  const LinkTelegramResponse400({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LinkTelegramResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class LinkTelegramResponse401 extends LinkTelegramResponse {
  const LinkTelegramResponse401({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LinkTelegramResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class LinkTelegramResponse409 extends LinkTelegramResponse {
  const LinkTelegramResponse409({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LinkTelegramResponse409 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}
