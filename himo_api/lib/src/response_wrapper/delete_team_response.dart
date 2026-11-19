// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i2;

import 'package:himo_api/src/model/problem.dart' as _i3;
import 'package:meta/meta.dart' as _i1;

sealed class DeleteTeamResponse {
  const DeleteTeamResponse();
}

@_i1.immutable
class DeleteTeamResponse204 extends DeleteTeamResponse {
  const DeleteTeamResponse204();

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is DeleteTeamResponse204;
  }

  @_i2.override
  _i2.int get hashCode => runtimeType.hashCode;
}

@_i1.immutable
class DeleteTeamResponse401 extends DeleteTeamResponse {
  const DeleteTeamResponse401({required this.body});

  final _i3.Problem body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is DeleteTeamResponse401 && other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => body.hashCode;
}

@_i1.immutable
class DeleteTeamResponse403 extends DeleteTeamResponse {
  const DeleteTeamResponse403({required this.body});

  final _i3.Problem body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is DeleteTeamResponse403 && other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => body.hashCode;
}

@_i1.immutable
class DeleteTeamResponse409 extends DeleteTeamResponse {
  const DeleteTeamResponse409({required this.body});

  final _i3.Problem body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is DeleteTeamResponse409 && other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => body.hashCode;
}
