// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/member_list.dart' as _i2;
import 'package:himo_api/src/model/problem.dart' as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class ListMembersResponse {
  const ListMembersResponse();
}

@_i1.immutable
class ListMembersResponse200 extends ListMembersResponse {
  const ListMembersResponse200({required this.body});

  final _i2.MemberList body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListMembersResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class ListMembersResponse401 extends ListMembersResponse {
  const ListMembersResponse401({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListMembersResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class ListMembersResponse403 extends ListMembersResponse {
  const ListMembersResponse403({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListMembersResponse403 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}
