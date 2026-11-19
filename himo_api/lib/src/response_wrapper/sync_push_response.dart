// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/app_outdated_problem.dart' as _i5;
import 'package:himo_api/src/model/problem.dart' as _i4;
import 'package:himo_api/src/model/push_response.dart' as _i2;
import 'package:meta/meta.dart' as _i1;

sealed class SyncPushResponse {
  const SyncPushResponse();
}

@_i1.immutable
class SyncPushResponse200 extends SyncPushResponse {
  const SyncPushResponse200({required this.body});

  final _i2.PushResponse body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is SyncPushResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class SyncPushResponse400 extends SyncPushResponse {
  const SyncPushResponse400({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is SyncPushResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class SyncPushResponse401 extends SyncPushResponse {
  const SyncPushResponse401({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is SyncPushResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class SyncPushResponse426 extends SyncPushResponse {
  const SyncPushResponse426({required this.body});

  final _i5.AppOutdatedProblem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is SyncPushResponse426 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}
