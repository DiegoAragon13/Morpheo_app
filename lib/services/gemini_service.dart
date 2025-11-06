import 'package:flutter_gemini/flutter_gemini.dart';
import '../models/sleep_data.dart';

class GeminiService {
  static const String _apiKey = 'Your_api_key';
  static Gemini? _instance;

  static void initialize() {
    Gemini.init(apiKey: _apiKey);
    _instance = Gemini.instance;
  }

  // Generar insights de sueño
  Future<String> generateSleepInsights(List<SleepData> historyData) async {
    if (_instance == null) {
      GeminiService.initialize();
    }

    try {
      final sleepContext = _buildSleepContext(historyData);
      final prompt = _buildSleepInsightsPrompt(sleepContext);

      final response = await _instance!.text(prompt);
      return response?.output ?? 'No se pudo generar el análisis en este momento.';
    } catch (e) {
      print('Error al generar insights de sueño: $e');
      return 'Error al conectar con el servicio de IA. Intente más tarde.';
    }
  }

  // Generar recomendación rápida
  Future<String> generateQuickRecommendation(SleepData data) async {
    if (_instance == null) {
      GeminiService.initialize();
    }

    try {
      final prompt = _buildQuickRecommendationPrompt(data);
      final response = await _instance!.text(prompt);
      return response?.output ?? 'Mantén un ambiente fresco y oscuro para mejor descanso.';
    } catch (e) {
      print('Error al generar recomendación rápida: $e');
      return 'Mantén un ambiente fresco y oscuro para mejor descanso.';
    }
  }

  // Construir contexto de datos de sueño
  String _buildSleepContext(List<SleepData> historyData) {
    if (historyData.isEmpty) {
      return 'No hay datos suficientes para análisis.';
    }

    // Calcular promedios y estadísticas solo con los datos disponibles
    final temps = historyData.map((d) => d.temperature).whereType<double>().toList();
    final humidities = historyData.map((d) => d.humidity).whereType<double>().toList();

    final conRonquidos = historyData.where((d) => d.ronquidos == true).length;
    final totalRegistros = historyData.length;
    final porcentajeRonquidos = (conRonquidos / totalRegistros * 100).toStringAsFixed(1);

    StringBuffer context = StringBuffer();
    context.writeln('ANÁLISIS DE SUEÑO - Últimas ${historyData.length} mediciones');
    context.writeln('Período: ${_formatDateTime(historyData.last.timestamp)} a ${_formatDateTime(historyData.first.timestamp)}');
    context.writeln('\nCONDICIONES AMBIENTALES:');

    if (temps.isNotEmpty) {
      final avgTemp = temps.reduce((a, b) => a + b) / temps.length;
      final minTemp = temps.reduce((a, b) => a < b ? a : b);
      final maxTemp = temps.reduce((a, b) => a > b ? a : b);
      context.writeln('- Temperatura: ${avgTemp.toStringAsFixed(1)}°C promedio (min: ${minTemp.toStringAsFixed(1)}°C, max: ${maxTemp.toStringAsFixed(1)}°C)');
    }

    if (humidities.isNotEmpty) {
      final avgHumidity = humidities.reduce((a, b) => a + b) / humidities.length;
      final minHumidity = humidities.reduce((a, b) => a < b ? a : b);
      final maxHumidity = humidities.reduce((a, b) => a > b ? a : b);
      context.writeln('- Humedad: ${avgHumidity.toStringAsFixed(1)}% promedio (min: ${minHumidity.toStringAsFixed(1)}%, max: ${maxHumidity.toStringAsFixed(1)}%)');
    }

    context.writeln('\nPATRONES DE SUEÑO:');
    context.writeln('- Ronquidos detectados en $porcentajeRonquidos% de las mediciones ($conRonquidos de $totalRegistros)');

    // Detectar patrones preocupantes
    if (temps.isNotEmpty && temps.any((t) => t > 24 || t < 18)) {
      context.writeln('- Temperatura fuera del rango óptimo (18-24°C) detectada');
    }

    if (humidities.isNotEmpty && humidities.any((h) => h > 60 || h < 30)) {
      context.writeln('- Humedad fuera del rango óptimo (30-60%) detectada');
    }

    // Analizar tendencias de temperatura
    if (temps.length > 1) {
      final firstHalf = temps.sublist(0, temps.length ~/ 2);
      final secondHalf = temps.sublist(temps.length ~/ 2);
      final avgFirst = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
      final avgSecond = secondHalf.reduce((a, b) => a + b) / secondHalf.length;

      if ((avgSecond - avgFirst).abs() > 2) {
        context.writeln('- Variación significativa de temperatura durante el período');
      }
    }

    return context.toString();
  }

  // Prompt para insights detallados
  String _buildSleepInsightsPrompt(String sleepContext) {
    return '''
Eres un experto en análisis de sueño y salud del descanso. Analiza los siguientes datos de monitoreo de sueño y proporciona insights valiosos y accionables.

DATOS DEL USUARIO:
$sleepContext

INSTRUCCIONES:
1. Analiza las condiciones ambientales y métricas de salud
2. Identifica patrones que puedan afectar la calidad del sueño
3. Proporciona 3-5 insights específicos y personalizados
4. Incluye tanto observaciones como recomendaciones
5. Usa un tono amigable y motivador
6. Prioriza la salud y el bienestar
7. Menciona tanto aspectos positivos como áreas de mejora

FORMATO DE RESPUESTA:
Proporciona un análisis en formato de párrafo continuo, bien estructurado, mencionando:
- Estado general del ambiente de sueño
- Observaciones sobre métricas de salud
- Patrones identificados
- Recomendaciones específicas para mejorar

Mantén el análisis conciso (máximo 150 palabras) pero informativo y personalizado.
''';
  }

  // Prompt para recomendación rápida
  String _buildQuickRecommendationPrompt(SleepData data) {
    StringBuffer context = StringBuffer();
    context.writeln('LECTURA ACTUAL:');
    if (data.temperature != null) context.writeln('- Temperatura: ${data.temperature}°C');
    if (data.humidity != null) context.writeln('- Humedad: ${data.humidity}%');
    if (data.ronquidos != null) context.writeln('- Ronquidos: ${data.ronquidos! ? "Sí" : "No"}');

    return '''
Eres un experto en calidad de sueño. Basándote en la siguiente lectura actual, proporciona UNA recomendación breve y específica (máximo 25 palabras).

$context

Proporciona solo la recomendación, sin introducción ni explicación adicional.
''';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
