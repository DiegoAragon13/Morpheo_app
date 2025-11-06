import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/sleep_service.dart';
import '../services/gemini_service.dart';

class HomeIaInsights extends StatefulWidget {
  final String? userId;

  const HomeIaInsights({
    Key? key,
    this.userId,
  }) : super(key: key);

  @override
  State<HomeIaInsights> createState() => _HomeIaInsightsState();
}

class _HomeIaInsightsState extends State<HomeIaInsights> {
  final SleepService _sleepService = SleepService();

  String? _aiInsight;
  bool _isLoading = false;
  int _updatesToday = 0;
  DateTime? _lastUpdateDate;

  static const int maxUpdatesPerDay = 7;
  static const String _prefsKeyInsight = 'last_sleep_insight';
  static const String _prefsKeyDate = 'insight_update_date';
  static const String _prefsKeyCount = 'insight_update_count';

  @override
  void initState() {
    super.initState();
    GeminiService.initialize();
    _loadSavedState();
  }

  /// Cargar estado guardado (insights previos y contador de actualizaciones)
  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    final storedDate = prefs.getString(_prefsKeyDate);
    final today = DateTime.now();

    // Cargar último insight guardado
    final savedInsight = prefs.getString(_prefsKeyInsight);

    if (storedDate != null) {
      final lastDate = DateTime.parse(storedDate);
      if (_isSameDay(today, lastDate)) {
        _updatesToday = prefs.getInt(_prefsKeyCount) ?? 0;
      } else {
        // Nuevo día, resetear contador
        _updatesToday = 0;
        await prefs.setInt(_prefsKeyCount, 0);
        await prefs.setString(_prefsKeyDate, today.toIso8601String());
      }
    } else {
      await prefs.setString(_prefsKeyDate, today.toIso8601String());
      await prefs.setInt(_prefsKeyCount, 0);
    }

    setState(() {
      _aiInsight = savedInsight;
      _lastUpdateDate = today;
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Verificar si puede actualizar (límite de 7 por día)
  Future<bool> _canUpdateInsights() async {
    if (_updatesToday >= maxUpdatesPerDay) return false;

    final prefs = await SharedPreferences.getInstance();
    _updatesToday += 1;
    await prefs.setInt(_prefsKeyCount, _updatesToday);
    return true;
  }

  /// Generar nuevos insights con IA
  Future<void> _generateInsights() async {
    // Validar que tengamos userId
    if (widget.userId == null || widget.userId!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se puede generar análisis sin usuario activo'),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    final canUpdate = await _canUpdateInsights();
    if (!canUpdate) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Has alcanzado el límite de $maxUpdatesPerDay actualizaciones de IA por día.'),
            duration: const Duration(seconds: 3),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Obtener insights de IA (últimas 24 horas)
      final insights = await _sleepService.generateAIInsights(
        widget.userId!,
        hours: 24,
      );

      // Guardar insights
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKeyInsight, insights);

      if (mounted) {
        setState(() {
          _aiInsight = insights;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✨ Análisis actualizado con IA'),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      print('❌ Error al generar insights: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al generar el análisis. Intenta nuevamente.'),
            duration: const Duration(seconds: 3),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título con botón de actualización
        Row(
          children: [
            Icon(
              Icons.psychology_outlined,
              color: theme.colorScheme.tertiary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Insights de IA',
              style: theme.textTheme.titleLarge,
            ),
            const Spacer(),
            if (!_isLoading)
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: _generateInsights,
                tooltip: 'Actualizar análisis',
                color: theme.colorScheme.tertiary,
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Card de IA
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.primary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.tertiary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: _isLoading
              ? _LoadingState(theme: theme)
              : _aiInsight != null && _aiInsight!.isNotEmpty
              ? _InsightContent(insight: _aiInsight!, theme: theme)
              : _PlaceholderState(
            theme: theme,
            onGenerate: _generateInsights,
          ),
        ),

        // Contador de actualizaciones
        if (_updatesToday > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Actualizaciones hoy: $_updatesToday/$maxUpdatesPerDay',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
      ],
    );
  }
}

// Estado de carga
class _LoadingState extends StatelessWidget {
  final ThemeData theme;

  const _LoadingState({
    Key? key,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            color: theme.colorScheme.tertiary,
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Analizando tus datos...',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Gemini está generando insights personalizados',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

// Estado con insight generado
class _InsightContent extends StatelessWidget {
  final String insight;
  final ThemeData theme;

  const _InsightContent({
    Key? key,
    required this.insight,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 20,
                color: theme.colorScheme.tertiary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Análisis de Gemini',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          insight,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// Estado placeholder
class _PlaceholderState extends StatelessWidget {
  final ThemeData theme;
  final VoidCallback onGenerate;

  const _PlaceholderState({
    Key? key,
    required this.theme,
    required this.onGenerate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.auto_awesome,
          size: 48,
          color: theme.colorScheme.tertiary,
        ),
        const SizedBox(height: 12),
        Text(
          'Análisis de IA',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Genera insights personalizados sobre tu sueño con Gemini',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onGenerate,
          icon: const Icon(Icons.psychology, size: 18),
          label: const Text('Generar Análisis'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.tertiary,
            foregroundColor: theme.colorScheme.onTertiary,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}