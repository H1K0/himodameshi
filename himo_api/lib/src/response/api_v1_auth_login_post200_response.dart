// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/session.dart' as _i2;
import 'package:meta/meta.dart' as _i1;

@_i1.immutable
class ApiV1AuthLoginPost200Response {
  const ApiV1AuthLoginPost200Response({required this.body, this.setCookie});

  final _i2.Session body;

  final _i3.String? setCookie;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ApiV1AuthLoginPost200Response &&
        other.body == this.body &&
        other.setCookie == this.setCookie;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([body, setCookie]);
  }

  $$ApiV1AuthLoginPost200ResponseCopyWith<ApiV1AuthLoginPost200Response>
  get copyWith => _ApiV1AuthLoginPost200ResponseCopyWith(this);
}

abstract class $$ApiV1AuthLoginPost200ResponseCopyWith<$Res> {
  factory $$ApiV1AuthLoginPost200ResponseCopyWith(
    ApiV1AuthLoginPost200Response value,
  ) = _ApiV1AuthLoginPost200ResponseCopyWith<$Res>;

  $Res call({_i2.Session? body, _i3.String? setCookie});
  _i2.Session get body;
  _i3.String? get setCookie;
}

class _ApiV1AuthLoginPost200ResponseCopyWith<$Res>
    implements $$ApiV1AuthLoginPost200ResponseCopyWith<$Res> {
  _ApiV1AuthLoginPost200ResponseCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final ApiV1AuthLoginPost200Response _value;

  @_i3.override
  _i2.Session get body => _value.body;

  @_i3.override
  _i3.String? get setCookie => _value.setCookie;

  @_i3.override
  $Res call({_i3.Object? body = _sentinel, _i3.Object? setCookie = _sentinel}) {
    return (ApiV1AuthLoginPost200Response(
      body: _i3.identical(body, _sentinel) ? this.body : (body as _i2.Session),
      setCookie: _i3.identical(setCookie, _sentinel)
          ? this.setCookie
          : (setCookie as _i3.String?),
    ) as $Res);
  }
}
