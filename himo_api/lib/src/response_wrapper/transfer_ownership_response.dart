// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/problem.dart' as _i4;
import 'package:himo_api/src/model/team.dart' as _i2;
import 'package:meta/meta.dart' as _i1;

sealed class TransferOwnershipResponse {
  const TransferOwnershipResponse();
}

@_i1.immutable
class TransferOwnershipResponse200 extends TransferOwnershipResponse {
  const TransferOwnershipResponse200({required this.body});

  final _i2.Team body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is TransferOwnershipResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class TransferOwnershipResponse400 extends TransferOwnershipResponse {
  const TransferOwnershipResponse400({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is TransferOwnershipResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class TransferOwnershipResponse401 extends TransferOwnershipResponse {
  const TransferOwnershipResponse401({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is TransferOwnershipResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class TransferOwnershipResponse403 extends TransferOwnershipResponse {
  const TransferOwnershipResponse403({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is TransferOwnershipResponse403 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class TransferOwnershipResponse409 extends TransferOwnershipResponse {
  const TransferOwnershipResponse409({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is TransferOwnershipResponse409 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}
