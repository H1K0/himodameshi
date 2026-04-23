// collection_screen.dart
import 'package:flutter/material.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.collections_bookmark, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Коллекция',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Color(0xFFFAFAFA)),
          ),
          SizedBox(height: 8),
          Text(
            'Здесь будут сохранённые кабели',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}