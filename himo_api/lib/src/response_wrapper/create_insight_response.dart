// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/insight.dart' as _i2;
import 'package:himo_api/src/model/problem.dart' as _i4;
import 'package:himo_api/src/response/too_many_requests.dart' as _i5;
import 'package:meta/meta.dart' as _i1;

sealed class CreateInsightResponse {
  const CreateInsightResponse();
}

@_i1.immutable
class CreateInsightResponse200 extends CreateInsightResponse {
  const CreateInsightResponse200({required this.body});

  final _i2.Insight body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CreateInsightResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class CreateInsightResponse400 extends CreateInsightResponse {
  const CreateInsightResponse400({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CreateInsightResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class CreateInsightResponse429 extends CreateInsightResponse {
  const CreateInsightResponse429({required this.body});

  final _i5.TooManyRequests body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CreateInsightResponse429 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}

@_i1.immutable
class CreateInsightResponse503 extends CreateInsightResponse {
  const CreateInsightResponse503({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CreateInsightResponse503 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => body.hashCode;
}
