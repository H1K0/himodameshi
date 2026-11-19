// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i2;

import 'package:dio/dio.dart' as _i1;
import 'package:himo_api/src/model/api_v1_teams_team_id_cables_parameters_model.dart'
    as _i9;
import 'package:himo_api/src/model/api_v1_teams_team_id_cables_parameters_model2.dart'
    as _i3;
import 'package:himo_api/src/model/cable_page.dart' as _i11;
import 'package:himo_api/src/model/cable_type.dart' as _i7;
import 'package:himo_api/src/model/color.dart' as _i8;
import 'package:himo_api/src/model/problem.dart' as _i12;
import 'package:himo_api/src/model/sort_order.dart' as _i10;
import 'package:himo_api/src/model/uuid.dart' as _i6;
import 'package:himo_api/src/response_wrapper/list_cables_response.dart' as _i5;
import 'package:tonik_util/tonik_util.dart' as _i4;

class ListCables {
  ListCables(this._dio);

  final _i1.Dio _dio;

  static const _i2.bool archivedDefault = false;

  static const _i3.ApiV1TeamsTeamIdCablesParametersModel2 sortDefault =
      _i3.ApiV1TeamsTeamIdCablesParametersModel2.lastTestAt;

  static const _i2.int limitDefault = 50;

  static const _i2.int offsetDefault = 0;

  _i2.Future<_i4.TonikResult<_i5.ListCablesResponse>> call({
    required _i6.Uuid teamId,
    _i2.String? q,
    _i7.CableType? cableType,
    _i8.Color? color,
    _i9.ApiV1TeamsTeamIdCablesParametersModel? health,
    _i2.String? assignee,
    _i2.bool archived = archivedDefault,
    _i3.ApiV1TeamsTeamIdCablesParametersModel2 sort = sortDefault,
    _i10.SortOrder? order,
    _i2.int limit = limitDefault,
    _i2.int offset = offsetDefault,
    _i1.CancelToken? cancelToken,
  }) async {
    late final _i2.Uri _$uri;
    late final _i2.Object? _$data;
    late final _i1.Options _$options;
    try {
      final _$baseUri = _i2.Uri.parse(_dio.options.baseUrl);
      final _$pathResult = _path(teamId: teamId);
      final _$newPath = _$baseUri.path.endsWith('/')
          ? '${_$baseUri.path.substring(0, _$baseUri.path.length - 1)}/${_$pathResult.join('/')}'
          : '${_$baseUri.path}/${_$pathResult.join('/')}';
      _$uri = _$baseUri.replace(
        path: _$newPath,
        query: _queryParameters(
          q: q,
          cableType: cableType,
          color: color,
          health: health,
          assignee: assignee,
          archived: archived,
          sort: sort,
          order: order,
          limit: limit,
          offset: offset,
        ),
      );
      _$data = _data();
      _$options = _options();
    } on _i2.Object catch (exception, stackTrace) {
      return _i4.TonikError(
        exception,
        stackTrace: stackTrace,
        type: _i4.TonikErrorType.encoding,
        response: null,
      );
    }

    final _i1.Response<_i2.List<_i2.int>> _$response;
    try {
      _$response = await _dio.requestUri<_i2.List<_i2.int>>(
        _$uri,
        data: _$data,
        options: _$options,
        cancelToken: cancelToken,
      );
    } on _i1.DioException catch (exception, stackTrace) {
      if (exception.type == _i1.DioExceptionType.cancel) {
        return _i4.TonikError(
          exception,
          stackTrace: stackTrace,
          type: _i4.TonikErrorType.cancelled,
          response: exception.response,
        );
      }
      return _i4.TonikError(
        exception,
        stackTrace: stackTrace,
        type: _i4.TonikErrorType.network,
        response: exception.response,
      );
    } on _i2.Object catch (exception, stackTrace) {
      return _i4.TonikError(
        exception,
        stackTrace: stackTrace,
        type: _i4.TonikErrorType.network,
        response: null,
      );
    }

    final _i5.ListCablesResponse _$parsedResponse;
    try {
      _$parsedResponse = _parseResponse(_$response);
    } on _i2.Object catch (exception, stackTrace) {
      return _i4.TonikError(
        exception,
        stackTrace: stackTrace,
        type: _i4.TonikErrorType.decoding,
        response: _$response,
      );
    }

    return _i4.TonikSuccess(_$parsedResponse, _$response);
  }

  _i2.List<_i2.String> _path({required _i6.Uuid teamId}) {
    return [
      r'api',
      r'v1',
      r'teams',
      teamId.toSimple(explode: false, allowEmpty: false),
      r'cables',
    ];
  }

  _i2.Object? _data() {
    return null;
  }

  _i2.String? _queryParameters({
    _i2.String? q,
    _i7.CableType? cableType,
    _i8.Color? color,
    _i9.ApiV1TeamsTeamIdCablesParametersModel? health,
    _i2.String? assignee,
    _i2.bool? archived,
    _i3.ApiV1TeamsTeamIdCablesParametersModel2? sort,
    _i10.SortOrder? order,
    _i2.int? limit,
    _i2.int? offset,
  }) {
    final _$entries = <_i4.ParameterEntry>[];
    if (q != null) {
      _$entries.addAll(q.toForm(r'q', explode: true, allowEmpty: false));
    }
    if (cableType != null) {
      _$entries.addAll(
        cableType.toForm(r'cable_type', explode: true, allowEmpty: false),
      );
    }
    if (color != null) {
      _$entries.addAll(
        color.toForm(r'color', explode: true, allowEmpty: false),
      );
    }
    if (health != null) {
      _$entries.addAll(
        health.toForm(r'health', explode: true, allowEmpty: false),
      );
    }
    if (assignee != null) {
      _$entries.addAll(
        assignee.toForm(r'assignee', explode: true, allowEmpty: false),
      );
    }
    if (archived != null) {
      _$entries.addAll(
        archived.toForm(r'archived', explode: true, allowEmpty: false),
      );
    }
    if (sort != null) {
      _$entries.addAll(sort.toForm(r'sort', explode: true, allowEmpty: false));
    }
    if (order != null) {
      _$entries.addAll(
        order.toForm(r'order', explode: true, allowEmpty: false),
      );
    }
    if (limit != null) {
      _$entries.addAll(
        limit.toForm(r'limit', explode: true, allowEmpty: false),
      );
    }
    if (offset != null) {
      _$entries.addAll(
        offset.toForm(r'offset', explode: true, allowEmpty: false),
      );
    }
    if (_$entries.isEmpty) {
      return null;
    }
    return _$entries
        .map((e) => e.name.isEmpty ? e.value : '${e.name}=${e.value}')
        .join('&');
  }

  _i1.Options _options() {
    final _$headers = <_i2.String, _i2.dynamic>{};
    _$headers['Accept'] = r'application/json';
    return _i1.Options(
      method: 'GET',
      headers: _$headers,
      responseType: _i1.ResponseType.bytes,
      validateStatus: (_) => true,
    );
  }

  _i5.ListCablesResponse _parseResponse(
    _i1.Response<_i2.List<_i2.int>> response,
  ) {
    final _$mediaType = _i4.extractMediaType(
      response.headers.value('content-type'),
    );
    switch ((response.statusCode, _$mediaType)) {
      case (200, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i2.Object?>(response.data);
        final _$body = _i11.CablePage.fromJson(_$json);
        return _i5.ListCablesResponse200(body: _$body);
      case (400, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i2.Object?>(response.data);
        final _$body = _i12.Problem.fromJson(_$json);
        return _i5.ListCablesResponse400(body: _$body);
      case (401, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i2.Object?>(response.data);
        final _$body = _i12.Problem.fromJson(_$json);
        return _i5.ListCablesResponse401(body: _$body);
      case (403, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i2.Object?>(response.data);
        final _$body = _i12.Problem.fromJson(_$json);
        return _i5.ListCablesResponse403(body: _$body);
      default:
        final _$content =
            response.headers.value('content-type') ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
    }
  }
}
