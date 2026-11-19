// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/problem.dart' as _i4;
import 'package:himo_api/src/model/team.dart' as _i2;
import 'package:meta/meta.dart' as _i1;

sealed class GetTeamResponse {
  const GetTeamResponse();
}

@_i1.immutable
class GetTeamResponse200 extends GetTeamResponse {
  const GetTeamResponse200({required this.body});

  final _i2.Team body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetTeamResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class GetTeamResponse401 extends GetTeamResponse {
  const GetTeamResponse401({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetTeamResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class GetTeamResponse403 extends GetTeamResponse {
  const GetTeamResponse403({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetTeamResponse403 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}
