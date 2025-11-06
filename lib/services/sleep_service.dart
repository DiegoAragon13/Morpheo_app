import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/sleep_data.dart';
import 'gemini_service.dart'; // AGREGAR

class SleepService {
  static const String baseUrl =
      'https://wmzcp7fbfa.execute-api.us-east-2.amazonaws.com/prod';
  static const Duration timeout = Duration(seconds: 10);

  final GeminiService _geminiService = GeminiService(); // AGREGAR

  /// Obtener el último dato registrado
  Future<SleepData?> getLatestData(String userId) async {
    try {
      print('🔍 Obteniendo último dato para: $userId');

      final response = await http
          .get(
        Uri.parse('$baseUrl/latest/$userId'),
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(timeout);

      print('📡 Status Code: ${response.statusCode}');
      print('📦 Response: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final sleepData = SleepData.fromJson(json);
        print('✅ Dato parseado: $sleepData');
        return sleepData;
      } else {
        print('❌ Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error en getLatestData: $e');
      return null;
    }
  }

  /// Obtener datos históricos por rango de horas
  Future<List<SleepData>> getHistoryData(
      String userId, {
        int hours = 24,
      }) async {
    try {
      print('🔍 Obteniendo historial para: $userId (últimas $hours horas)');

      final response = await http
          .get(
        Uri.parse('$baseUrl/history/$userId?hours=$hours'),
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(timeout);

      print('📡 Status Code: ${response.statusCode}');
      print('📦 Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        print('📊 Total registros recibidos: ${jsonList.length}');

        final List<SleepData> dataList = jsonList.map((json) {
          final data = SleepData.fromJson(json);
          return data;
        }).toList();

        // Debug: mostrar algunos datos
        if (dataList.isNotEmpty) {
          print('📋 Primer registro:');
          print('   - timestamp: ${dataList.first.timestamp}');
          print('   - temperature: ${dataList.first.temperature}');
          print('   - humidity: ${dataList.first.humidity}');
          print('   - ronquidos: ${dataList.first.ronquidos}');

          // Contar cuántos tienen ronquidos
          final conRonquidos =
              dataList.where((d) => d.ronquidos == true).length;
          final sinRonquidos =
              dataList.where((d) => d.ronquidos == false).length;
          final sinDato = dataList.where((d) => d.ronquidos == null).length;

          print('📊 Estadísticas de ronquidos:');
          print('   - Con ronquidos: $conRonquidos');
          print('   - Sin ronquidos: $sinRonquidos');
          print('   - Sin dato: $sinDato');
        }

        return dataList;
      } else {
        print('❌ Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error en getHistoryData: $e');
      return [];
    }
  }

  /// Generar insights de IA con Gemini - NUEVO MÉTODO
  Future<String> generateAIInsights(String userId, {int hours = 24}) async {
    try {
      print('🤖 Generando insights de IA para: $userId');

      // Obtener datos históricos
      final historyData = await getHistoryData(userId, hours: hours);

      if (historyData.isEmpty) {
        return 'No hay suficientes datos para generar un análisis. Registra más datos de sueño para obtener insights personalizados.';
      }

      // Generar insights con Gemini
      final insights = await _geminiService.generateSleepInsights(historyData);

      return insights;

    } catch (e) {
      print('❌ Error al generar insights: $e');
      return 'No se pudo generar el análisis en este momento.';
    }
  }

  /// Generar recomendación rápida - NUEVO MÉTODO
  Future<String> generateQuickRecommendation(SleepData data) async {
    try {
      return await _geminiService.generateQuickRecommendation(data);
    } catch (e) {
      print('❌ Error al generar recomendación: $e');
      return 'Mantén un ambiente fresco y oscuro para mejor descanso.';
    }
  }
}