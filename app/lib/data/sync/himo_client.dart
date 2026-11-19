import 'package:dio/dio.dart';
import 'package:himo_api/himo_api.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tonik_util/tonik_util.dart';

/// Синглтон-обёртка над сгенерированным клиентом `himo_api` (ADR-025, tonik).
///
/// Настраивает [CustomServer] базовым URL из `HIMO_API_BASE_URL`
/// (`--dart-define-from-file=config/dev.json`) и навешивает на Dio перехватчик,
/// который добавляет на каждый запрос заголовки `Authorization: Bearer <токен>`
/// и `X-App-Version` (из PackageInfo).
///
/// Токен пробрасывается через [setToken] — так клиент не импортирует `AuthStore`
/// и цикл импортов не возникает: `AuthStore` зависит от клиента (вызывает
/// `authApi.login`), а клиент читает токен из поля, которое `AuthStore` пишет.
class HimoClient {
  static final HimoClient _instance = HimoClient._internal();
  factory HimoClient() => _instance;
  HimoClient._internal();

  static const String _kNoUrl = '__no_himo_api_base_url__';

  /// Базовый URL Hub API из конфига приложения.
  final String baseUrl = const String.fromEnvironment(
    'HIMO_API_BASE_URL',
    defaultValue: _kNoUrl,
  );

  /// true, если `HIMO_API_BASE_URL` задан в конфиге запуска.
  bool get configured => baseUrl != _kNoUrl && baseUrl.isNotEmpty;

  String _appVersion = '0.0.0';

  /// Версия приложения для заголовка `X-App-Version` и поля `NewTest.app_version`.
  String get appVersion => _appVersion;

  String? _token;

  /// Токен сеанса для заголовка `Authorization`. Вызывается `AuthStore`-ом после
  /// login/register/load/clear.
  void setToken(String? token) => _token = token;

  late final Server _server;
  late final AuthApi authApi;
  late final SyncApi syncApi;
  late final TeamsApi teamsApi;
  late final CablesApi cablesApi;
  bool _initialized = false;

  /// Грузит PackageInfo (→ `X-App-Version`) и строит API-клиенты. Идемпотентно.
  /// Должно быть вызвано на старте приложения до первого запроса к Hub.
  Future<void> init() async {
    if (_initialized) return;
    final info = await PackageInfo.fromPlatform();
    _appVersion = '${info.version}+${info.buildNumber}';
    _server = CustomServer(baseUrl: configured ? baseUrl : '/');
    _installAuthInterceptor();
    authApi = AuthApi(_server);
    syncApi = SyncApi(_server);
    teamsApi = TeamsApi(_server);
    cablesApi = CablesApi(_server);
    _initialized = true;
  }

  void _installAuthInterceptor() {
    // server.dio — публичный геттер сгенерированного Server: создаёт Dio один
    // раз и конфигурирует baseUrl через ServerConfig.configureDio.
    final dio = _server.dio;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final t = _token;
          if (t != null && t.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $t';
          }
          options.headers['X-App-Version'] = _appVersion;
          handler.next(options);
        },
      ),
    );
  }

  /// Мои команды (`GET /api/v1/teams`). При ошибке/потере сеанса — пустой список:
  /// выбор команды — UI-фича, синхронизация от неё не зависит.
  Future<List<Team>> listTeams() async {
    if (!configured) return [];
    final res = await teamsApi.listTeams();
    switch (res) {
      case TonikSuccess(:final value):
        switch (value) {
          case ListTeamsResponse200(:final body):
            return body.items;
          case ListTeamsResponse401(body: _):
            return [];
        }
      case TonikError():
        return [];
    }
  }

  /// Кабели команды (`GET /api/v1/teams/{teamId}/cables`) — каталог для первой
  /// загрузки кабеля (sync.md §6): пользователь выбирает кабель, затем
  /// `HimoSync().loadCableFromCatalog(teamId, cableId)` тянет его в локальную БД.
  /// При ошибке/потере сеанса — пустой список.
  Future<List<Cable>> listTeamCables(String teamId) async {
    if (!configured) return [];
    final res = await cablesApi.listCables(teamId: teamId, limit: 100);
    switch (res) {
      case TonikSuccess(:final value):
        switch (value) {
          case ListCablesResponse200(:final body):
            return body.items;
          case ListCablesResponse400(body: _):
            return [];
          case ListCablesResponse401(body: _):
            return [];
          case ListCablesResponse403(body: _):
            return [];
        }
      case TonikError():
        return [];
    }
  }
}
