// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/problem.dart' as _i4;
import 'package:himo_api/src/model/team.dart' as _i2;
import 'package:meta/meta.dart' as _i1;

sealed class AcceptInvitationResponse {
  const AcceptInvitationResponse();
}

@_i1.immutable
class AcceptInvitationResponse200 extends AcceptInvitationResponse {
  const AcceptInvitationResponse200({required this.body});

  final _i2.Team body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AcceptInvitationResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class AcceptInvitationResponse401 extends AcceptInvitationResponse {
  const AcceptInvitationResponse401({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AcceptInvitationResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class AcceptInvitationResponse404 extends AcceptInvitationResponse {
  const AcceptInvitationResponse404({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AcceptInvitationResponse404 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class AcceptInvitationResponse409 extends AcceptInvitationResponse {
  const AcceptInvitationResponse409({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AcceptInvitationResponse409 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}
