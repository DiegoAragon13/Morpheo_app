import 'package:flutter/material.dart';

class Alarm {
  final String id;
  final TimeOfDay time;
  final String label;
  final List<int> days; // 1=Lun, 2=Mar, 3=Mié, 4=Jue, 5=Vie, 6=Sáb, 7=Dom
  bool isEnabled;

  Alarm({
    required this.id,
    required this.time,
    required this.label,
    required this.days,
    this.isEnabled = true,
  });

  String get timeString {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  List<String> get dayLabels {
    const labels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days.map((d) => labels[d - 1]).toList();
  }

  // Copiar con cambios
  Alarm copyWith({
    String? id,
    TimeOfDay? time,
    String? label,
    List<int>? days,
    bool? isEnabled,
  }) {
    return Alarm(
      id: id ?? this.id,
      time: time ?? this.time,
      label: label ?? this.label,
      days: days ?? this.days,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  // Convertir a JSON para AWS
  Map<String, dynamic> toJson() {
    return {
      'alarmId': id,
      'time': {
        'hour': time.hour,
        'minute': time.minute,
      },
      'label': label,
      'days': days,
      'isEnabled': isEnabled,
    };
  }

  // Crear desde JSON (compatible con AWS DynamoDB)
  factory Alarm.fromJson(Map<String, dynamic> json) {
    // AWS guarda el time como objeto anidado
    final timeData = json['time'] ?? {};
    final hour = timeData['hour'] ?? 0;
    final minute = timeData['minute'] ?? 0;

    // AWS usa 'alarmId' en lugar de 'id'
    final id = json['alarmId'] ?? json['id'] ?? '';

    // Parsear días (puede venir como lista de enteros o como objetos DynamoDB)
    List<int> parseDays(dynamic daysData) {
      if (daysData == null) return [];

      if (daysData is List) {
        return daysData.map((day) {
          if (day is int) return day;
          if (day is Map && day.containsKey('N')) {
            return int.parse(day['N'].toString());
          }
          return int.tryParse(day.toString()) ?? 0;
        }).where((day) => day > 0).toList();
      }

      return [];
    }

    return Alarm(
      id: id,
      time: TimeOfDay(hour: hour, minute: minute),
      label: json['label'] ?? 'Alarma',
      days: parseDays(json['days']),
      isEnabled: json['isEnabled'] ?? true,
    );
  }
}