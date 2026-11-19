// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i2;

import 'package:himo_api/src/model/problem.dart' as _i3;
import 'package:meta/meta.dart' as _i1;

sealed class LeaveTeamResponse {
  const LeaveTeamResponse();
}

@_i1.immutable
class LeaveTeamResponse204 extends LeaveTeamResponse {
  const LeaveTeamResponse204();

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is LeaveTeamResponse204;
  }

  @_i2.override
  _i2.int get hashCode => runtimeType.hashCode;
}

@_i1.immutable
class LeaveTeamResponse401 extends LeaveTeamResponse {
  const LeaveTeamResponse401({required this.body});

  final _i3.Problem body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is LeaveTeamResponse401 && other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => body.hashCode;
}

@_i1.immutable
class LeaveTeamResponse403 extends LeaveTeamResponse {
  const LeaveTeamResponse403({required this.body});

  final _i3.Problem body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is LeaveTeamResponse403 && other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => body.hashCode;
}

@_i1.immutable
class LeaveTeamResponse409 extends LeaveTeamResponse {
  const LeaveTeamResponse409({required this.body});

  final _i3.Problem body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is LeaveTeamResponse409 && other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => body.hashCode;
}
