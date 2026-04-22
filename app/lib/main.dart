import 'package:flutter/material.dart';
import 'presentation/startup_screen.dart';
import 'presentation/bottom_nav_bar.dart';
import 'presentation/cable_passport_screen.dart';
import 'presentation/collection_screen.dart';
import 'presentation/app_settings_screen.dart';
import 'presentation/device_settings_screen.dart';
import 'presentation/testing_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Кабельный помощник',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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

  // Список экранов (заглушек)
  final List<Widget> _screens = const [
    StartupScreen(),
    TestingScreen(),
    CablePassportScreen(),
    CollectionScreen(),
    DeviceSettingsScreen(),
    AppSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
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