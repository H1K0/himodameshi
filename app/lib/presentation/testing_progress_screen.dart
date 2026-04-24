import 'package:flutter/material.dart';
import '/data/test_models.dart';

class TestingProgressScreen extends StatelessWidget {
  final CableType cableType;
  final List<TestType> selectedTests;
  final int totalDuration;

  const TestingProgressScreen({
    super.key,
    required this.cableType,
    required this.selectedTests,
    required this.totalDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF888888)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Тестирование',
          style: TextStyle(color: Color(0xFFFAFAFA)),
        ),
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.science,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Тестирование в процессе',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Тип кабеля: ${cableType.displayName}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Выбрано тестов: ${selectedTests.length}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Примерное время: ${totalDuration ~/ 60} мин ${totalDuration % 60} сек',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: Color(0xFFEF9F27),
            ),
          ],
        ),
      ),
    );
  }
}