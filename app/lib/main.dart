import 'package:flutter/material.dart';
import 'presentation/startup_screen.dart';
import 'presentation/collection_screen.dart';
import 'presentation/app_settings_screen.dart';
import 'presentation/health_score_check_temp.dart';
import 'presentation/bottom_nav_bar.dart';

void main() {
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
          background: Color(0xFF0A0A0A),
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
      const HealthScoreCheckTemp(), // ВРЕМЕННЫЙ ЭКРАН ДЛЯ ПРОВЕРКИ
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