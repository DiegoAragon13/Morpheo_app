// lib/services/device_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class DeviceService {
  // ✅ IP de tu ESP32
  static String esp32Ip = '192.168.43.234';

  static String get baseUrl => 'http://$esp32Ip';

  // Configurar la IP del ESP32
  static void setEsp32Ip(String ip) {
    esp32Ip = ip;
  }

  // Obtener estado actual del dispositivo
  static Future<Map<String, dynamic>?> getStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/status'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error al obtener estado: $e');
    }
    return null;
  }

  // Actualizar LED
  static Future<bool> updateLed({
    required bool enabled,
    required int r,
    required int g,
    required int b,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/led'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'enabled': enabled,
          'color': {'r': r, 'g': g, 'b': b},
        }),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar LED: $e');
      return false;
    }
  }

  // Verificar si el dispositivo está conectado
  static Future<bool> isConnected() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/status'),
      ).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
