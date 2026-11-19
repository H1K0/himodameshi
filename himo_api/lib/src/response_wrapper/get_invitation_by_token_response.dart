// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/invitation_preview.dart' as _i2;
import 'package:himo_api/src/model/problem.dart' as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class GetInvitationByTokenResponse {
  const GetInvitationByTokenResponse();
}

@_i1.immutable
class GetInvitationByTokenResponse200 extends GetInvitationByTokenResponse {
  const GetInvitationByTokenResponse200({required this.body});

  final _i2.InvitationPreview body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetInvitationByTokenResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class GetInvitationByTokenResponse404 extends GetInvitationByTokenResponse {
  const GetInvitationByTokenResponse404({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetInvitationByTokenResponse404 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}
