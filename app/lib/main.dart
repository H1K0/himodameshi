import 'package:flutter/material.dart';
import 'data/ble_data_manager.dart';
import 'presentation/startup_screen.dart';
import 'presentation/collection_screen.dart';
import 'presentation/app_settings_screen.dart';
import 'presentation/bottom_nav_bar.dart';
import 'presentation/ble_data_test_screen.dart';
import 'data/database_helper.dart';
import 'dart:io';

class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) {
        return host == 'api.z.ai'; // доверяем только Zhipu
      };
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ← обеспечиваем работу асинхронных операций
  HttpOverrides.global = _DevHttpOverrides();
  // Инициализируем БД и добавляем мок-данные при первом запуске
  final dbHelper = DatabaseHelper();
  await dbHelper.importMockDataIfEmpty();
  await BleDataManager().switchTo(DataSourceType.mock);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Himo',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFEF9F27),
          surface: Color(0xFF0A0A0A),
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _mainScreens;

  @override
  void initState() {
    super.initState();
    _mainScreens = [
      StartupScreen(
        onNavigateToCollection: () {
          setState(() {
            _selectedIndex = 1;
          });
        },
      ),
      const CollectionScreen(),
      const AppSettingsScreen(),
      const BleDataTestScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _mainScreens[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
