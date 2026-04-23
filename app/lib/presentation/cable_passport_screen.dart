import 'package:flutter/material.dart';

class CablePassportScreen extends StatelessWidget {
  final String cableId;
  final VoidCallback onBack;

  const CablePassportScreen({
    super.key,
    required this.cableId,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF888888)),
          onPressed: onBack,
        ),
        title: const Text(
          'Паспорт кабеля',
          style: TextStyle(color: Color(0xFFFAFAFA)),
        ),
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Паспорт кабеля',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Color(0xFFFAFAFA),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ID кабеля: $cableId',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Здесь будет информация о кабеле',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            // TODO: передать данные для идентификации кабеля
          ],
        ),
      ),
    );
  }
}