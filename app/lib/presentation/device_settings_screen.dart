import 'package:flutter/material.dart';

class DeviceSettingsScreen extends StatelessWidget {
  final VoidCallback onBack;

  const DeviceSettingsScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF888888)),
          onPressed: onBack,
        ),
        title: const Text(
          'Устройство',
          style: TextStyle(color: Color(0xFFFAFAFA)),
        ),
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.devices, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Настройки устройства',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Color(0xFFFAFAFA)),
            ),
            SizedBox(height: 8),
            Text(
              'Здесь будут настройки оборудования',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}