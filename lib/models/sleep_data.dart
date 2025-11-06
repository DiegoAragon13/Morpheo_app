class SleepData {
  final String userId;
  final DateTime timestamp;
  final double temperature;
  final double humidity;
  final bool light;
  final bool? ronquidos;

  SleepData({
    required this.userId,
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    required this.light,
    this.ronquidos,
  });

  // Crear desde JSON (de DynamoDB/AWS)
  factory SleepData.fromJson(Map<String, dynamic> json) {
    // Parsear el timestamp y convertir a hora local
    DateTime parsedTimestamp = DateTime.parse(json['timestamp'] as String);

    // Si el timestamp viene en UTC, convertirlo a hora local
    if (!parsedTimestamp.isUtc) {
      parsedTimestamp = parsedTimestamp.toUtc();
    }

    return SleepData(
      userId: json['userId'] as String,
      timestamp: parsedTimestamp.toLocal(), // CONVERTIR A HORA LOCAL
      temperature: _parseNumber(json['temperature']),
      humidity: _parseNumber(json['humidity']),
      light: json['light'] as bool,
      ronquidos: json['ronquidos'] as bool?,
    );
  }

  // Método auxiliar para parsear números (maneja int y double)
  static double _parseNumber(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.parse(value);
    return 0.0;
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'timestamp': timestamp.toUtc().toIso8601String(), // GUARDAR EN UTC
      'temperature': temperature,
      'humidity': humidity,
      'light': light,
      if (ronquidos != null) 'ronquidos': ronquidos,
    };
  }

  // Calcular score de sueño basado en los factores
  int calculateSleepScore() {
    int score = 0;

    // Factor temperatura (0-40 puntos)
    // Ideal: 18-22°C
    if (temperature >= 18 && temperature <= 22) {
      score += 40; // Perfecto
    } else if (temperature >= 16 && temperature <= 24) {
      score += 30; // Bueno
    } else if (temperature >= 14 && temperature <= 26) {
      score += 20; // Regular
    } else {
      score += 10; // Malo
    }

    // Factor humedad (0-40 puntos)
    // Ideal: 40-60%
    if (humidity >= 40 && humidity <= 60) {
      score += 40; // Perfecto
    } else if (humidity >= 30 && humidity <= 70) {
      score += 30; // Bueno
    } else if (humidity >= 20 && humidity <= 80) {
      score += 20; // Regular
    } else {
      score += 10; // Malo
    }

    // Factor luz (0-10 puntos)
    // Ideal: apagada (false)
    if (!light) {
      score += 10; // Perfecto - oscuridad total
    } else {
      score += 2; // Con luz encendida
    }

    // Factor ronquidos (0-10 puntos)
    if (ronquidos != null) {
      if (!ronquidos!) {
        score += 10; // Sin ronquidos
      } else {
        score += 3; // Con ronquidos
      }
    }

    return score.clamp(0, 100);
  }

  // Obtener el color según el score
  String getScoreColorHex() {
    final score = calculateSleepScore();
    if (score >= 80) return '#00E676'; // Verde - Excelente
    if (score >= 60) return '#FFD600'; // Amarillo - Bueno
    return '#FF5252'; // Rojo - Necesita mejorar
  }

  // Obtener texto descriptivo del score
  String getScoreDescription() {
    final score = calculateSleepScore();
    if (score >= 80) return 'Excelente';
    if (score >= 70) return 'Muy bueno';
    if (score >= 60) return 'Bueno';
    if (score >= 50) return 'Regular';
    return 'Necesita mejorar';
  }

  // Obtener emoji según el score
  String getScoreEmoji() {
    final score = calculateSleepScore();
    if (score >= 80) return '😴';
    if (score >= 70) return '😊';
    if (score >= 60) return '😐';
    if (score >= 50) return '😕';
    return '😩';
  }

  // Copiar con modificaciones
  SleepData copyWith({
    String? userId,
    DateTime? timestamp,
    double? temperature,
    double? humidity,
    bool? light,
    bool? ronquidos,
  }) {
    return SleepData(
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      light: light ?? this.light,
      ronquidos: ronquidos ?? this.ronquidos,
    );
  }

  @override
  String toString() {
    return 'SleepData(userId: $userId, timestamp: $timestamp, '
        'temp: $temperature°C, humidity: $humidity%, light: $light, ronquidos: $ronquidos)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SleepData &&
        other.userId == userId &&
        other.timestamp == timestamp &&
        other.temperature == temperature &&
        other.humidity == humidity &&
        other.light == light &&
        other.ronquidos == ronquidos;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
    timestamp.hashCode ^
    temperature.hashCode ^
    humidity.hashCode ^
    light.hashCode ^
    (ronquidos?.hashCode ?? 0);
  }
}

// Clase para datos de gráficas agrupados por hora
class SleepGraphData {
  final List<double> values;
  final List<String> labels;
  final String title;
  final String unit;

  SleepGraphData({
    required this.values,
    required this.labels,
    required this.title,
    required this.unit,
  });

  // Crear datos de temperatura para gráfica
  factory SleepGraphData.temperature(List<SleepData> data) {
    if (data.isEmpty) {
      return SleepGraphData(
        values: [],
        labels: [],
        title: 'Temperatura',
        unit: '°C',
      );
    }

    return SleepGraphData(
      values: data.map((d) => d.temperature).toList(),
      labels: _generateTimeLabels(data),
      title: 'Temperatura',
      unit: '°C',
    );
  }

  // Crear datos de humedad para gráfica
  factory SleepGraphData.humidity(List<SleepData> data) {
    if (data.isEmpty) {
      return SleepGraphData(
        values: [],
        labels: [],
        title: 'Humedad',
        unit: '%',
      );
    }

    return SleepGraphData(
      values: data.map((d) => d.humidity).toList(),
      labels: _generateTimeLabels(data),
      title: 'Humedad',
      unit: '%',
    );
  }

  // Crear datos de ronquidos
  factory SleepGraphData.snoring([List<SleepData>? data]) {
    if (data == null || data.isEmpty) {
      return SleepGraphData(
        values: [],
        labels: [],
        title: 'Ronquidos',
        unit: '',
      );
    }

    // Convertir bool a double (1.0 = ronquido, 0.0 = sin ronquido)
    final values = data.map((d) => d.ronquidos == true ? 1.0 : 0.0).toList();

    return SleepGraphData(
      values: values,
      labels: _generateTimeLabels(data),
      title: 'Ronquidos',
      unit: '',
    );
  }

  // Generar labels de tiempo en hora local
  static List<String> _generateTimeLabels(List<SleepData> data) {
    return data.map((d) {
      // El timestamp ya está en hora local gracias al fromJson
      final hour = d.timestamp.hour.toString().padLeft(2, '0');
      final minute = d.timestamp.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }).toList();
  }

  // Obtener valor máximo para escalar la gráfica
  double get maxValue {
    if (values.isEmpty) return 100;
    return values.reduce((a, b) => a > b ? a : b);
  }

  // Obtener valor mínimo
  double get minValue {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a < b ? a : b);
  }

  // Obtener promedio
  double get average {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  // Método helper para crear gráfica vacía
  factory SleepGraphData.empty(String title, String unit) {
    return SleepGraphData(
      values: [],
      labels: [],
      title: title,
      unit: unit,
    );
  }
}

// Clase para resumen de sesión de sueño
class SleepSession {
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final List<SleepData> dataPoints;

  SleepSession({
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.dataPoints,
  });

  // Duración total del sueño
  Duration get duration => endTime.difference(startTime);

  // Duración en formato legible
  String get durationFormatted {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}min';
  }

  // Score promedio de la sesión
  int get averageScore {
    if (dataPoints.isEmpty) return 0;
    final scores = dataPoints.map((d) => d.calculateSleepScore());
    return (scores.reduce((a, b) => a + b) / scores.length).round();
  }

  // Temperatura promedio
  double get averageTemperature {
    if (dataPoints.isEmpty) return 0;
    final temps = dataPoints.map((d) => d.temperature);
    return temps.reduce((a, b) => a + b) / temps.length;
  }

  // Humedad promedio
  double get averageHumidity {
    if (dataPoints.isEmpty) return 0;
    final humidities = dataPoints.map((d) => d.humidity);
    return humidities.reduce((a, b) => a + b) / humidities.length;
  }

  // Porcentaje de tiempo con luz encendida
  double get lightOnPercentage {
    if (dataPoints.isEmpty) return 0;
    final lightOnCount = dataPoints.where((d) => d.light).length;
    return (lightOnCount / dataPoints.length) * 100;
  }

  // Porcentaje de tiempo roncando
  double get snoringPercentage {
    if (dataPoints.isEmpty) return 0;
    final snoringCount = dataPoints.where((d) => d.ronquidos == true).length;
    return (snoringCount / dataPoints.length) * 100;
  }

  // Crear desde lista de datos
  factory SleepSession.fromDataList(List<SleepData> data) {
    if (data.isEmpty) {
      throw ArgumentError('La lista de datos no puede estar vacía');
    }

    // Ordenar por timestamp
    final sortedData = List<SleepData>.from(data)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return SleepSession(
      userId: sortedData.first.userId,
      startTime: sortedData.first.timestamp,
      endTime: sortedData.last.timestamp,
      dataPoints: sortedData,
    );
  }
}