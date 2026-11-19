// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:himo_api/src/model/problem.dart' as _i2;
import 'package:meta/meta.dart' as _i1;

@_i1.immutable
class TooManyRequests {
  const TooManyRequests({required this.body, this.retryAfter});

  final _i2.Problem body;

  final _i3.int? retryAfter;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is TooManyRequests &&
        other.body == this.body &&
        other.retryAfter == this.retryAfter;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([body, retryAfter]);
  }

  $$TooManyRequestsCopyWith<TooManyRequests> get copyWith =>
      _TooManyRequestsCopyWith(this);
}

abstract class $$TooManyRequestsCopyWith<$Res> {
  factory $$TooManyRequestsCopyWith(TooManyRequests value) =
      _TooManyRequestsCopyWith<$Res>;

  $Res call({_i2.Problem? body, _i3.int? retryAfter});
  _i2.Problem get body;
  _i3.int? get retryAfter;
}

class _TooManyRequestsCopyWith<$Res>
    implements $$TooManyRequestsCopyWith<$Res> {
  _TooManyRequestsCopyWith(this._value);

  static const _sentinel = _i3.Object();

  final TooManyRequests _value;

  @_i3.override
  _i2.Problem get body => _value.body;

  @_i3.override
  _i3.int? get retryAfter => _value.retryAfter;

  @_i3.override
  $Res call({
    _i3.Object? body = _sentinel,
    _i3.Object? retryAfter = _sentinel,
  }) {
    return (TooManyRequests(
      body: _i3.identical(body, _sentinel) ? this.body : (body as _i2.Problem),
      retryAfter: _i3.identical(retryAfter, _sentinel)
          ? this.retryAfter
          : (retryAfter as _i3.int?),
    ) as $Res);
  }
}
