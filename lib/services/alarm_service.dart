import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/alarm.dart';

class AlarmService {
  // 🌐 URL de tu API en AWS
  static const String _baseUrl = 'your_URL_AWS';

  // 👤 ID del usuario (por ahora hardcodeado, luego será con Cognito)
  static const String _userId = 'Diego';

  /// Obtener todas las alarmas desde AWS
  Future<List<Alarm>> getAlarms() async {
    try {
      print(' Obteniendo alarmas desde AWS...');

      final response = await http.get(
        Uri.parse('$_baseUrl/alarms?userId=$_userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> alarmsList = data['alarms'];

        final alarms = alarmsList.map((json) => Alarm.fromJson(json)).toList();
        print(' ${alarms.length} alarmas cargadas desde AWS');

        return alarms;
      } else {
        print(' Error al obtener alarmas: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error de conexión: $e');
      return [];
    }
  }

  /// Crear una nueva alarma en AWS
  Future<bool> addAlarm(Alarm alarm) async {
    try {
      print('📡 Creando alarma en AWS...');

      final body = jsonEncode({
        'time': {
          'hour': alarm.time.hour,
          'minute': alarm.time.minute,
        },
        'label': alarm.label,
        'days': alarm.days,
        'isEnabled': alarm.isEnabled,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/alarms?userId=$_userId'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('📤 Status: ${response.statusCode}');
      print('📤 Response: ${response.body}');

      if (response.statusCode == 201) {
        print('Alarma creada exitosamente');
        return true;
      } else {
        print('❌ Error al crear alarma: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error de conexión: $e');
      return false;
    }
  }

  /// Actualizar una alarma existente en AWS
  Future<bool> updateAlarm(Alarm alarm) async {
    try {
      print('📡 Actualizando alarma en AWS...');

      final body = jsonEncode({
        'alarmId': alarm.id,
        'time': {
          'hour': alarm.time.hour,
          'minute': alarm.time.minute,
        },
        'label': alarm.label,
        'days': alarm.days,
        'isEnabled': alarm.isEnabled,
      });

      final response = await http.put(
        Uri.parse('$_baseUrl/alarms?userId=$_userId'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('📤 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Alarma actualizada exitosamente');
        return true;
      } else {
        print('❌ Error al actualizar alarma: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error de conexión: $e');
      return false;
    }
  }

  /// Eliminar una alarma de AWS
  Future<bool> deleteAlarm(String alarmId) async {
    try {
      print('📡 Eliminando alarma de AWS...');

      final response = await http.delete(
        Uri.parse('$_baseUrl/alarms?userId=$_userId&alarmId=$alarmId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📤 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Alarma eliminada exitosamente');
        return true;
      } else {
        print('❌ Error al eliminar alarma: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error de conexión: $e');
      return false;
    }
  }

  /// Toggle estado de alarma (activar/desactivar)
  Future<bool> toggleAlarm(Alarm alarm) async {
    // Cambiamos el estado localmente
    alarm.isEnabled = !alarm.isEnabled;

    // Actualizamos en AWS
    return await updateAlarm(alarm);
  }

  /// Generar ID único (ya no se usa, AWS genera el ID)
  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
