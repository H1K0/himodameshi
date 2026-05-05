import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'ble_data_source.dart';

/// Mock-источник данных (читает из JSON файла)
class BleMockDataSource implements BleDataSource {
  final String sequenceName;
  StreamController<Map<String, dynamic>>? _controller;
  bool _isActive = false;

  BleMockDataSource({required this.sequenceName});

  @override
  Stream<Map<String, dynamic>> get dataStream {
    if (_controller == null) {
      _controller = StreamController<Map<String, dynamic>>.broadcast();
      _startMockStream();
    }
    return _controller!.stream;
  }

  void _startMockStream() async {
    if (_isActive) return;
    _isActive = true;

    try {
      final jsonString = await rootBundle.loadString('mock/ble_mock_packets.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      final sequences = jsonData['sequences'] as Map<String, dynamic>;
      if (!sequences.containsKey(sequenceName)) {
        _controller?.addError('Sequence "$sequenceName" not found');
        return;
      }

      final packets = sequences[sequenceName]['packets'] as List;

      for (final packet in packets) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!_isActive) break;
        _controller?.add(packet as Map<String, dynamic>);
      }

      _controller?.add({'type': 'finished', 'message': 'Mock sequence completed'});
    } catch (e) {
      _controller?.addError(e);
    } finally {
      _isActive = false;
    }
  }

  @override
  Future<bool> sendCommand(Map<String, dynamic> command) async {
    print('[MOCK] Sending command: $command');
    // В мок-режиме просто возвращаем успех
    return true;
  }

  @override
  bool get isConnected => true; // В мок-режиме всегда "подключены"

  @override
  Future<void> disconnect() async {
    _isActive = false;
    await _controller?.close();
    _controller = null;
  }

  @override
  void dispose() {
    _isActive = false;
    _controller?.close();
  }
}