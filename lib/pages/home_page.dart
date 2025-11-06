import 'package:flutter/material.dart';
import '../widgets/home_graficas.dart';
import '../widgets/home_ia_insights.dart';
import '../widgets/home_sleep_score.dart';
import '../models/sleep_data.dart';
import '../services/sleep_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SleepService _sleepService = SleepService();

  // Estados
  bool _isLoading = true;
  String? _errorMessage;

  // Datos
  SleepData? _latestData;
  List<SleepData> _historyData = [];
  SleepGraphData? _temperaturaData;
  SleepGraphData? _humedadData;
  SleepGraphData? _ronquidosData; // AGREGAR ESTA LÍNEA

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Cargar datos desde AWS
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Obtener último dato
      final latestData = await _sleepService.getLatestData('Diego');

      // Obtener historial (últimas 24 horas)
      final historyData = await _sleepService.getHistoryData('Diego', hours: 24);

      // Procesar datos para gráficas
      SleepGraphData? temperaturaData;
      SleepGraphData? humedadData;
      SleepGraphData? ronquidosData; // AGREGAR

      if (historyData.isNotEmpty) {
        temperaturaData = SleepGraphData.temperature(historyData);
        humedadData = SleepGraphData.humidity(historyData);
        ronquidosData = SleepGraphData.snoring(historyData); // AGREGAR ESTA LÍNEA
      }

      setState(() {
        _latestData = latestData;
        _historyData = historyData;
        _temperaturaData = temperaturaData;
        _humedadData = humedadData;
        _ronquidosData = ronquidosData; // AGREGAR
        _isLoading = false;
      });

      print('✅ Datos cargados correctamente');
      print('📊 Último dato: $_latestData');
      print('📊 Historial: ${_historyData.length} registros');

    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar datos: $e';
        _isLoading = false;
      });
      print('❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mostrar loading
    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'Cargando tus datos de sueño...',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    // Mostrar error
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar datos',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    // Mostrar datos
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Saludo
                Text(
                  'Buenos días, Diego',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(DateTime.now()),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Score de sueño (con datos reales)
                HomeSleepScore(
                  sleepData: _latestData,
                  duration: _calculateDuration(),
                ),
                const SizedBox(height: 24),

                // Gráficas en carrusel (con datos reales)
                HomeGraficas(
                  temperaturaData: _temperaturaData,
                  humedadData: _humedadData,
                  ronquidosData: _ronquidosData, // AGREGAR ESTA LÍNEA
                ),
                const SizedBox(height: 24),

                // Insights de IA
                const HomeIaInsights(userId: 'Diego'),
                const SizedBox(height: 24),

                // Botón ver historial
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implementar navegación al historial
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Historial completo próximamente'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: theme.colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Ver historial completo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    const days = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
    ];

    final dayName = days[date.weekday - 1];
    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;

    return '$dayName, $day de $month de $year';
  }

  String _calculateDuration() {
    if (_historyData.isEmpty) return '0h 0min de descanso';

    final oldest = _historyData.first.timestamp;
    final newest = _historyData.last.timestamp;
    final duration = newest.difference(oldest);

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return '${hours}h ${minutes}min de descanso';
  }
}