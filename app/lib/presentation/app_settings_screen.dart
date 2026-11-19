import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '/data/auth_store.dart';
import '/data/sync/himo_client.dart';
import '/data/sync/sync_engine.dart';

/// Экран настроек: профиль/логин, синхронизация с Himo Hub, о приложении.
///
/// Логин и регистрация — инлайн (POST /api/v1/auth/login|register с
/// client:"app"), без отдельных экранов. Синхронизация — статус, ручной запуск,
/// конфликты атрибутов кабеля (sync.md §4).
class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  final AuthStore _auth = AuthStore();
  final HimoClient _client = HimoClient();
  final HimoSync _sync = HimoSync();

  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _authBusy = false;

  final String _appVersion = '0.3';
  final String _websiteUrl = 'https://git.hakoniwa.ru/tech/himodameshi';

  @override
  void initState() {
    super.initState();
    _auth.load().then((_) {
      if (mounted) setState(() {});
    });
    _sync.status.addListener(_onSyncChanged);
    _sync.lastSyncAt.addListener(_onSyncChanged);
    _sync.lastError.addListener(_onSyncChanged);
    _sync.conflicts.addListener(_onSyncChanged);
  }

  @override
  void dispose() {
    _sync.status.removeListener(_onSyncChanged);
    _sync.lastSyncAt.removeListener(_onSyncChanged);
    _sync.lastError.removeListener(_onSyncChanged);
    _sync.conflicts.removeListener(_onSyncChanged);
    _nicknameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSyncChanged() {
    if (mounted) setState(() {});
  }

  // ---------- auth ----------

  Future<void> _doAuth({required bool register}) async {
    final nickname = _nicknameController.text.trim();
    final password = _passwordController.text;
    if (nickname.isEmpty || password.isEmpty) {
      _snack('Введите ник и пароль');
      return;
    }
    setState(() => _authBusy = true);
    try {
      final err = register
          ? await _auth.register(nickname, password)
          : await _auth.login(nickname, password);
      if (err != null) {
        _snack('${register ? "Регистрация" : "Вход"} не удалась: $err');
        return;
      }
      _passwordController.clear();
      if (mounted) setState(() {});
    } catch (e) {
      _snack('Ошибка: $e');
    } finally {
      if (mounted) setState(() => _authBusy = false);
    }
  }

  Future<void> _doLogout() async {
    await _auth.logout();
    if (mounted) setState(() {});
  }

  // ---------- sync ----------

  Future<void> _doSync() async {
    final out = await _sync.run();
    if (!mounted) return;
    if (out.authRequired) {
      _snack('Войдите, чтобы синхронизироваться');
    } else if (out.appOutdated) {
      _snack('Обновите приложение — версия ниже минимальной');
    } else if (out.errors.isNotEmpty) {
      _snack('Синхронизация завершена с ошибками: ${out.errors.length}');
    } else if (out.conflicts.isNotEmpty) {
      _snack('Конфликтов атрибутов: ${out.conflicts.length}');
    } else if (out.ok) {
      final pushed = out.cablesPushed + out.updatesPushed + out.testsPushed;
      final pulled = out.cablesPulled + out.testsPulled;
      if (pushed == 0 && pulled == 0 && out.deletedCables == 0) {
        _snack('Уже всё синхронизировано');
      } else {
        _snack(
          'Синхронизировано: ↑${out.cablesPushed + out.updatesPushed} каб, '
          '${out.testsPushed} тест · ↓${out.cablesPulled} каб, '
          '${out.testsPulled} тест',
        );
      }
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF1F1F1F),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _statusText() {
    if (!_client.configured) return 'Не настроено';
    switch (_sync.status.value) {
      case SyncStatus.syncing:
        return 'Синхронизация…';
      case SyncStatus.needsAuth:
        return 'Нужен вход';
      case SyncStatus.appOutdated:
        return 'Приложение устарело';
      case SyncStatus.error:
        return 'Ошибка';
      case SyncStatus.idle:
        if (!_auth.isLoggedIn) return 'Выкл (нет входа)';
        if (_sync.lastSyncAt.value == null) return 'Готово к запуску';
        return 'Готово';
    }
  }

  Color _statusColor() {
    switch (_sync.status.value) {
      case SyncStatus.syncing:
        return const Color(0xFFEF9F27);
      case SyncStatus.needsAuth:
      case SyncStatus.appOutdated:
      case SyncStatus.error:
        return const Color(0xFFE24B4A);
      case SyncStatus.idle:
        return const Color(0xFF97C459);
    }
  }

  String _lastSyncText() {
    final t = _sync.lastSyncAt.value;
    if (t == null) return '—';
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'только что';
    if (d.inMinutes < 60) return '${d.inMinutes} мин назад';
    if (d.inHours < 24) return '${d.inHours} ч назад';
    return '${t.day}.${t.month.toString().padLeft(2, '0')} ${t.hour}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _snack('Не удалось открыть: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'Настройки',
          style: TextStyle(color: Color(0xFFFAFAFA)),
        ),
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(),
            _buildSyncSection(),
            _buildAboutSection(),
            _buildFeedbackSection(),
          ],
        ),
      ),
    );
  }

  // ---------- профиль / логин ----------

  Widget _buildProfileSection() {
    if (!_auth.isLoggedIn) {
      return _buildLoginCard();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ПРОФИЛЬ',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF666666),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1F1F1F)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF9F27).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(21),
                    border: Border.all(
                      color: const Color(0xFFEF9F27).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(_auth.nickname ?? '?'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFEF9F27),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _auth.nickname ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFAFAFA),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Himo Hub',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _doLogout,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    side: const BorderSide(color: Color(0xFF2A2A2A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Выйти',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFAAAAAA),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ВХОД В HIMO HUB',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF666666),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1F1F1F)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _nicknameController,
                  style: const TextStyle(
                    color: Color(0xFFFAFAFA),
                    fontSize: 13,
                  ),
                  decoration: _fieldDecoration('Ник'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(
                    color: Color(0xFFFAFAFA),
                    fontSize: 13,
                  ),
                  decoration: _fieldDecoration('Пароль'),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _authBusy
                            ? null
                            : () => _doAuth(register: false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF9F27),
                          foregroundColor: const Color(0xFF2A1A00),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Войти',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _authBusy
                            ? null
                            : () => _doAuth(register: true),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: const BorderSide(color: Color(0xFF2A2A2A)),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Регистрация',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFAAAAAA),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Без учётной записи приложение работает полностью — синхронизация выключена.',
                  style: TextStyle(fontSize: 10, color: Color(0xFF666666)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Color(0xFF888888)),
    filled: true,
    fillColor: const Color(0xFF111111),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF1F1F1F)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF1F1F1F)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFEF9F27)),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );

  // ---------- синхронизация ----------

  Widget _buildSyncSection() {
    final conflicts = _sync.conflicts.value;
    final lastError = _sync.lastError.value;
    final canSync = _client.configured && _auth.isLoggedIn && !_sync.isRunning;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'СИНХРОНИЗАЦИЯ',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF666666),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1F1F1F)),
            ),
            child: Column(
              children: [
                _buildSettingsRow(
                  label: 'Статус',
                  value: _statusText(),
                  valueColor: _statusColor(),
                ),
                const Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: Color(0xFF1A1A1A),
                ),
                _buildSettingsRow(
                  label: 'Последняя синхр.',
                  value: _lastSyncText(),
                ),
                if (lastError != null) ...[
                  const Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: Color(0xFF1A1A1A),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 14,
                          color: Color(0xFFE24B4A),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            lastError,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFE24B4A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (conflicts.isNotEmpty) ...[
                  const Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: Color(0xFF1A1A1A),
                  ),
                  _buildSettingsButtonRow(
                    label: 'Конфликты атрибутов',
                    value: '${conflicts.length} ›',
                    onTap: _showConflictsSheet,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canSync ? _doSync : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF9F27),
                foregroundColor: const Color(0xFF2A1A00),
                disabledBackgroundColor: const Color(0xFF2A2A2A),
                disabledForegroundColor: const Color(0xFF666666),
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _sync.isRunning
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF2A1A00),
                      ),
                    )
                  : const Text(
                      'Синхронизировать',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConflictsSheet() {
    final conflicts = _sync.conflicts.value;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F0F0F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Конфликты атрибутов кабеля',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFAFAFA),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Кабель изменили в Hub после вашей правки. Выберите версию.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF888888)),
                ),
                const SizedBox(height: 14),
                ...conflicts.map((c) => _conflictTile(c)),
                if (conflicts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'Конфликтов нет',
                      style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _conflictTile(CableConflict c) {
    final s = c.serverCable;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Кабель ${c.cableId.substring(0, 8)}…',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFFFAFAFA),
            ),
          ),
          const SizedBox(height: 8),
          _diffRow('Имя', s.name),
          _diffRow('Тип', s.cableType as String),
          _diffRow('Цвет', s.color),
          _diffRow('Заметка', s.note ?? '—'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await _sync.resolveConflictWithServer(c.cableId);
                    if (mounted) Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF97C459),
                    side: const BorderSide(color: Color(0xFF2A3A1A)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Версия Hub',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await _sync.resolveConflictWithLocal(c.cableId);
                    if (mounted) Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF9F27),
                    side: const BorderSide(color: Color(0xFF3A2A00)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Моя версия',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _diffRow(String label, String serverValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
            ),
          ),
          Expanded(
            child: Text(
              'Hub: $serverValue',
              style: const TextStyle(fontSize: 11, color: Color(0xFFE8E8E8)),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- о приложении / обратная связь (без изменений) ----------

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'О ПРИЛОЖЕНИИ',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF666666),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1F1F1F)),
            ),
            child: Column(
              children: [
                _buildSettingsRow(label: 'Версия', value: _appVersion),
                const Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: Color(0xFF1A1A1A),
                ),
                _buildSettingsButtonRow(
                  label: 'Сайт проекта',
                  value: 'himo.app ↗',
                  onTap: () => _launchUrl(_websiteUrl),
                ),
                const Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: Color(0xFF1A1A1A),
                ),
                _buildSettingsButtonRow(
                  label: 'Политика приватности',
                  value: '›',
                  onTap: () => _launchUrl(_websiteUrl),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ОБРАТНАЯ СВЯЗЬ',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF666666),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1F1F1F)),
            ),
            child: Column(
              children: [
                _buildFeedbackRow(
                  icon: Icons.error_outline,
                  iconColor: const Color(0xFFE24B4A),
                  label: 'Сообщить об ошибке',
                  onTap: () => _launchUrl(_websiteUrl),
                ),
                const Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: Color(0xFF1A1A1A),
                ),
                _buildFeedbackRow(
                  icon: Icons.lightbulb_outline,
                  iconColor: const Color(0xFFEF9F27),
                  label: 'Предложить идею',
                  onTap: () => _launchUrl(_websiteUrl),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Widget _buildSettingsRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: valueColor ?? const Color(0xFFE8E8E8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsButtonRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFFE8E8E8)),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, size: 12, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFFFAFAFA)),
              ),
            ),
            const Icon(Icons.chevron_right, size: 12, color: Color(0xFF444444)),
          ],
        ),
      ),
    );
  }
}
