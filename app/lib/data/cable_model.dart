import 'dart:ui';

class CableModel {
  final String id;
  final String name;
  final String cableType;
  final String status;
  final double cmrrDb;

  CableModel({
    required this.id,
    required this.name,
    required this.cableType,
    required this.status,
    required this.cmrrDb,
  });

  Color get statusColor {
    switch (status) {
      case 'excellent':
        return const Color(0xFF639922);
      case 'ok':
        return const Color(0xFFEF9F27);
      case 'fail':
        return const Color(0xFFE24B4A);
      default:
        return const Color(0xFF888888);
    }
  }

  String get displayName => '$name · ${cableType.toUpperCase()}';
  String get displaySubtitle => 'cmrr $cmrrDb дБ';
}
