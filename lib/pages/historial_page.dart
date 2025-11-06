import 'package:flutter/material.dart';
import '../models/sleep_data.dart';
import '../services/sleep_service.dart';
import '../widgets/historial_calendario.dart';
import '../widgets/historial_trent_chart.dart';
import '../widgets/historial_view.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final SleepService _sleepService = SleepService();

  // Estados
  bool _isLoading = true;
  HistoryViewMode _viewMode = HistoryViewMode.monthly;
  DateTime _selectedMonth = DateTime.now();

  // Datos
  List<SleepData> _historyData = [];
  Map<DateTime, SleepQuality> _sleepDays = {};
  List<double> _scores = [];

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  /// Obtener horas según el modo de vista
  int _getHoursForMode() {
    switch (_viewMode) {
      case HistoryViewMode.weekly:
        return 24 * 7; // 7 días
      case HistoryViewMode.monthly:
        return 24 * 30; // 30 días
    }
  }

  /// Cargar datos históricos según el modo seleccionado
  Future<void> _loadHistoryData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final hours = _getHoursForMode();

      // Obtener datos del endpoint
      final historyData = await _sleepService.getHistoryData(
        'Diego',
        hours: hours,
      );

      // Procesar datos
      final sleepDays = _processSleepDays(historyData);
      final scores = _calculateDailyScores(historyData);

      setState(() {
        _historyData = historyData;
        _sleepDays = sleepDays;
        _scores = scores;
        _isLoading = false;
      });

      print('✅ Historial cargado: ${historyData.length} registros');
      print('📅 Días con datos: ${sleepDays.length}');
      print('📊 Scores calculados: ${scores.length}');

    } catch (e) {
      print('❌ Error al cargar historial: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Procesar datos para el calendario (agrupar por día y calcular calidad)
  Map<DateTime, SleepQuality> _processSleepDays(List<SleepData> data) {
    final Map<DateTime, List<SleepData>> dayGroups = {};

    // Agrupar por día
    for (var record in data) {
      final dateOnly = DateTime(
        record.timestamp.year,
        record.timestamp.month,
        record.timestamp.day,
      );

      dayGroups.putIfAbsent(dateOnly, () => []).add(record);
    }

    // Calcular calidad para cada día
    final Map<DateTime, SleepQuality> result = {};
    dayGroups.forEach((date, records) {
      final score = _calculateDayScore(records);
      result[date] = _scoreToQuality(score);
    });

    return result;
  }

  /// Calcular score de un día basado en sus registros
  double _calculateDayScore(List<SleepData> records) {
    if (records.isEmpty) return 0;

    double totalScore = 0;
    int count = 0;

    for (var record in records) {
      double score = 100;

      // Penalizar por temperatura
      if (record.temperature != null) {
        final temp = record.temperature!;
        if (temp < 18 || temp > 24) {
          score -= 10;
        } else if (temp < 19 || temp > 23) {
          score -= 5;
        }
      }

      // Penalizar por humedad
      if (record.humidity != null) {
        final humidity = record.humidity!;
        if (humidity < 30 || humidity > 60) {
          score -= 10;
        } else if (humidity < 35 || humidity > 55) {
          score -= 5;
        }
      }

      // Penalizar por ronquidos
      if (record.ronquidos == true) {
        score -= 15;
      }

      totalScore += score.clamp(0, 100);
      count++;
    }

    return count > 0 ? totalScore / count : 0;
  }

  /// Convertir score a calidad
  SleepQuality _scoreToQuality(double score) {
    if (score >= 85) return SleepQuality.excellent;
    if (score >= 70) return SleepQuality.good;
    if (score >= 50) return SleepQuality.fair;
    return SleepQuality.poor;
  }

  /// Calcular scores diarios para la gráfica de tendencia
  List<double> _calculateDailyScores(List<SleepData> data) {
    if (data.isEmpty) return [];

    // Agrupar por día
    final Map<DateTime, List<SleepData>> dayGroups = {};
    for (var record in data) {
      final dateOnly = DateTime(
        record.timestamp.year,
        record.timestamp.month,
        record.timestamp.day,
      );
      dayGroups.putIfAbsent(dateOnly, () => []).add(record);
    }

    // Ordenar días
    final sortedDays = dayGroups.keys.toList()..sort();

    // Calcular score para cada día
    return sortedDays.map((day) {
      return _calculateDayScore(dayGroups[day]!);
    }).toList();
  }

  void _onDaySelected(DateTime date) {
    // Filtrar registros del día seleccionado
    final dayRecords = _historyData.where((record) {
      return record.timestamp.year == date.year &&
          record.timestamp.month == date.month &&
          record.timestamp.day == date.day;
    }).toList();

    if (dayRecords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No hay datos para este día'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Calcular estadísticas del día
    final avgTemp = dayRecords
        .where((r) => r.temperature != null)
        .map((r) => r.temperature!)
        .fold(0.0, (a, b) => a + b) / dayRecords.length;

    final avgHum = dayRecords
        .where((r) => r.humidity != null)
        .map((r) => r.humidity!)
        .fold(0.0, (a, b) => a + b) / dayRecords.length;

    final snoreCount = dayRecords.where((r) => r.ronquidos == true).length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${date.day}/${date.month}/${date.year}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Registros: ${dayRecords.length}'),
            const SizedBox(height: 8),
            Text('Temp. promedio: ${avgTemp.toStringAsFixed(1)}°C'),
            Text('Humedad promedio: ${avgHum.toStringAsFixed(1)}%'),
            Text('Ronquidos detectados: $snoreCount'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  /// Cambiar modo de vista
  void _onViewModeChanged(HistoryViewMode newMode) {
    setState(() {
      _viewMode = newMode;
    });
    _loadHistoryData(); // Recargar datos con nuevo rango
  }

  String _getTrendTitle() {
    switch (_viewMode) {
      case HistoryViewMode.weekly:
        return 'Tendencia últimos 7 días';
      case HistoryViewMode.monthly:
        return 'Tendencia últimos 30 días';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'Cargando historial...',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        )
            : RefreshIndicator(
          onRefresh: _loadHistoryData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 28,
                      color: theme.colorScheme.onSurface,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Historial de Sueño',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Revisa tu progreso y patrones',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Selector de vista
                HistoryViewSelector(
                  selectedMode: _viewMode,
                  onModeChanged: _onViewModeChanged,
                ),
                const SizedBox(height: 24),

                // Estadísticas rápidas
                if (_historyData.isNotEmpty)
                  _buildQuickStats(theme),
                const SizedBox(height: 24),

                // Calendario
                HistoryCalendar(
                  selectedMonth: _selectedMonth,
                  sleepDays: _sleepDays,
                  onDaySelected: _onDaySelected,
                ),
                const SizedBox(height: 24),

                // Gráfica de tendencia
                HistoryTrendChart(
                  scores: _scores,
                  title: _getTrendTitle(),
                ),
                const SizedBox(height: 24),

                // Leyenda de colores
                _buildLegend(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(ThemeData theme) {
    final avgScore = _scores.isEmpty
        ? 0.0
        : _scores.reduce((a, b) => a + b) / _scores.length;

    final daysWithData = _sleepDays.length;

    final excellentDays = _sleepDays.values
        .where((q) => q == SleepQuality.excellent)
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: 'Promedio',
            value: avgScore.toStringAsFixed(0),
            icon: Icons.analytics_outlined,
          ),
          _StatItem(
            label: 'Días',
            value: '$daysWithData',
            icon: Icons.calendar_today,
          ),
          _StatItem(
            label: 'Excelente',
            value: '$excellentDays',
            icon: Icons.star_outline,

          ),
        ],
      ),
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calidad de sueño',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _LegendItem(
                color: const Color(0xFF4CAF50),
                label: 'Excelente',
              ),
              _LegendItem(
                color: const Color(0xFF2196F3),
                label: 'Bueno',
              ),
              _LegendItem(
                color: const Color(0xFFFFC107),
                label: 'Regular',
              ),
              _LegendItem(
                color: const Color(0xFFFF5722),
                label: 'Malo',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [

        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    Key? key,
    required this.color,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}