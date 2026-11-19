// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/app_outdated_problem.dart' as _i5;
import 'package:himo_api/src/model/problem.dart' as _i4;
import 'package:himo_api/src/model/pull_response.dart' as _i2;
import 'package:meta/meta.dart' as _i1;

sealed class SyncPullResponse {
  const SyncPullResponse();
}

@_i1.immutable
class SyncPullResponse200 extends SyncPullResponse {
  const SyncPullResponse200({required this.body});

  final _i2.PullResponse body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is SyncPullResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class SyncPullResponse400 extends SyncPullResponse {
  const SyncPullResponse400({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is SyncPullResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class SyncPullResponse401 extends SyncPullResponse {
  const SyncPullResponse401({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is SyncPullResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class SyncPullResponse403 extends SyncPullResponse {
  const SyncPullResponse403({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is SyncPullResponse403 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class SyncPullResponse426 extends SyncPullResponse {
  const SyncPullResponse426({required this.body});

  final _i5.AppOutdatedProblem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is SyncPullResponse426 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}
