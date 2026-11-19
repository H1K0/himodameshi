import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:himo_api/himo_api.dart';
import 'package:tonik_util/tonik_util.dart';
import 'package:app/data/sync/himo_client.dart';

/// Сеанс пользователя Himo Hub.
///
/// Токен получается на `POST /api/v1/auth/login` с `client: "app"` — в этом
/// случае сервер кладёт токен в тело ответа (`Session.token`), а не в cookie
/// (ADR-022). Хранится в `flutter_secure_storage`.
///
/// Сервер ничего не помнит о клиенте между запросами (sync.md §1), поэтому
/// токен — единственное, что связывает приложение с сеансом.
class HimoSession {
  final String token;
  final String userId;
  final String nickname;
  final DateTime expiresAt;

  HimoSession({
    required this.token,
    required this.userId,
    required this.nickname,
    required this.expiresAt,
  });
}

/// Синглтон-хранилище сеанса и выбранной команды.
///
/// Вход/регистрация идут через сгенерированный `AuthApi` (`himo_api`):
/// ответ разбирается по `TonikResult` / sealed-вариантам `LoginResponse` /
/// `RegisterResponse`, из `Session` берётся токен. Команда (`team_id`)
/// хранится здесь же — пользователь выбирает её при первой выгрузке кабеля
/// (sync.md §2, §6). Курсор команды живёт в SQLite (`team_cursors`).
class AuthStore {
  static final AuthStore _instance = AuthStore._internal();
  factory AuthStore() => _instance;
  AuthStore._internal();

  static const String _kToken = 'himo_token';
  static const String _kUserId = 'himo_user_id';
  static const String _kNickname = 'himo_nickname';
  static const String _kExpiresAt = 'himo_expires_at';
  static const String _kTeamId = 'himo_team_id';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  String? _token;
  String? _userId;
  String? _nickname;
  DateTime? _expiresAt;
  String? _teamId;
  bool _loaded = false;

  String? get token => _token;
  String? get userId => _userId;
  String? get nickname => _nickname;
  DateTime? get expiresAt => _expiresAt;
  String? get teamId => _teamId;

  /// true, если есть токен и он не просрочен с запасом. Сервер продлевает TTL
  /// при использовании (sliding), поэтому просроченный по времени токен может
  /// быть валиден — финальное слово за `401` от сервера.
  bool get isLoggedIn {
    final t = _token;
    if (t == null || t.isEmpty) return false;
    final exp = _expiresAt;
    if (exp == null) return true;
    return DateTime.now().isBefore(exp);
  }

  /// Загрузить сеанс из secure storage в память и прокинуть токен в [HimoClient].
  /// Идемпотентно.
  Future<void> load() async {
    if (_loaded) return;
    _token = await _storage.read(key: _kToken);
    _userId = await _storage.read(key: _kUserId);
    _nickname = await _storage.read(key: _kNickname);
    final exp = await _storage.read(key: _kExpiresAt);
    _expiresAt = exp != null ? DateTime.tryParse(exp) : null;
    _teamId = await _storage.read(key: _kTeamId);
    HimoClient().setToken(_token);
    _loaded = true;
  }

  /// Вход по нику и паролю. `null` — успех, иначе сообщение об ошибке для UI.
  Future<String?> login(String nickname, String password) async {
    final res = await HimoClient().authApi.login(
      body: LoginRequest(
        nickname: nickname,
        password: password,
        client: ClientType.app,
      ),
    );
    return switch (res) {
      TonikSuccess(:final value) => switch (value) {
        LoginResponse200(:final body) => await _saveSession(body.body),
        LoginResponse400(:final body) => _problemMsg(body),
        LoginResponse401(:final body) => _problemMsg(body),
        LoginResponse426(:final body) =>
          'Приложение устарело: обновите до ${body.appOutdatedProblemModel.minAppVersion}',
        LoginResponse429() => 'Слишком много попыток, попробуйте позже',
      },
      TonikError() => 'Нет связи с сервером',
    };
  }

  /// Регистрация. `null` — успех, иначе сообщение об ошибке для UI.
  Future<String?> register(String nickname, String password) async {
    final res = await HimoClient().authApi.register(
      body: RegisterRequest(
        nickname: nickname,
        password: password,
        client: ClientType.app,
      ),
    );
    return switch (res) {
      TonikSuccess(:final value) => switch (value) {
        RegisterResponse201(:final body) => await _saveSession(body.body),
        RegisterResponse400(:final body) => _problemMsg(body),
        RegisterResponse409(:final body) => _problemMsg(body),
        RegisterResponse429() => 'Слишком много попыток, попробуйте позже',
      },
      TonikError() => 'Нет связи с сервером',
    };
  }

  /// Завершить сеанс: серверный logout (best-effort) + локальная очистка.
  Future<void> logout() async {
    if (HimoClient().configured) {
      // Результат игнорируем: даже при ошибке сети локальный сеанс чистим.
      await HimoClient().authApi.logout();
    }
    await clear();
  }

  Future<String?> _saveSession(Session s) async {
    final token = s.token;
    if (token == null) return 'Сервер не вернул токен сеанса';
    await saveSession(
      HimoSession(
        token: token,
        userId: s.user.id,
        nickname: s.user.nickname,
        expiresAt: s.expiresAt,
      ),
    );
    HimoClient().setToken(token);
    return null;
  }

  /// Человекочитаемое сообщение по коду ошибки (RFC 9457 `Problem`).
  String _problemMsg(Problem p) => switch (p.code) {
    'invalid_credentials' || 'unauthorized' => 'Неверный ник или пароль',
    'nickname_taken' => 'Этот ник уже занят',
    'validation_error' => p.detail ?? 'Проверьте введённые данные',
    'rate_limited' => 'Слишком много попыток, попробуйте позже',
    _ => p.detail != null ? '${p.code}: ${p.detail}' : p.code,
  };

  /// Сохранить сеанс после login/register.
  Future<void> saveSession(HimoSession session) async {
    _token = session.token;
    _userId = session.userId;
    _nickname = session.nickname;
    _expiresAt = session.expiresAt;
    await _storage.write(key: _kToken, value: session.token);
    await _storage.write(key: _kUserId, value: session.userId);
    await _storage.write(key: _kNickname, value: session.nickname);
    await _storage.write(
      key: _kExpiresAt,
      value: session.expiresAt.toUtc().toIso8601String(),
    );
    _loaded = true;
  }

  /// Запомнить выбранную команду (scope выгрузки/загрузки).
  Future<void> setTeamId(String? teamId) async {
    _teamId = teamId;
    if (teamId == null || teamId.isEmpty) {
      await _storage.delete(key: _kTeamId);
    } else {
      await _storage.write(key: _kTeamId, value: teamId);
    }
  }

  /// Очистить токен и команду. Локальные данные (кабели, тесты) остаются — без
  /// учётной записи приложение работает полностью (sync.md §1).
  Future<void> clear() async {
    _token = null;
    _userId = null;
    _nickname = null;
    _expiresAt = null;
    _teamId = null;
    HimoClient().setToken(null);
    await _storage.delete(key: _kToken);
    await _storage.delete(key: _kUserId);
    await _storage.delete(key: _kNickname);
    await _storage.delete(key: _kExpiresAt);
    await _storage.delete(key: _kTeamId);
    _loaded = true;
  }
}
