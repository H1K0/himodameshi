// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i2;

import 'package:himo_api/src/model/problem.dart' as _i3;
import 'package:meta/meta.dart' as _i1;

sealed class RevokeInvitationResponse {
  const RevokeInvitationResponse();
}

@_i1.immutable
class RevokeInvitationResponse204 extends RevokeInvitationResponse {
  const RevokeInvitationResponse204();

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is RevokeInvitationResponse204;
  }

  @_i2.override
  _i2.int get hashCode => runtimeType.hashCode;
}

@_i1.immutable
class RevokeInvitationResponse401 extends RevokeInvitationResponse {
  const RevokeInvitationResponse401({required this.body});

  final _i3.Problem body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is RevokeInvitationResponse401 && other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => body.hashCode;
}

@_i1.immutable
class RevokeInvitationResponse403 extends RevokeInvitationResponse {
  const RevokeInvitationResponse403({required this.body});

  final _i3.Problem body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is RevokeInvitationResponse403 && other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => body.hashCode;
}

@_i1.immutable
class RevokeInvitationResponse404 extends RevokeInvitationResponse {
  const RevokeInvitationResponse404({required this.body});

  final _i3.Problem body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is RevokeInvitationResponse404 && other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => body.hashCode;
}
