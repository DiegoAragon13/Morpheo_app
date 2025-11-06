import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/sleep_data.dart';

class HomeSleepScore extends StatelessWidget {
  final SleepData? sleepData;
  final String duration;

  const HomeSleepScore({
    Key? key,
    this.sleepData,
    this.duration = '0h 0min de descanso',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Si no hay datos, mostrar valores por defecto
    if (sleepData == null) {
      return _buildPlaceholder(context);
    }

    // Usar el método del modelo para calcular el score
    final score = sleepData!.calculateSleepScore();
    final scoreColor = _hexToColor(sleepData!.getScoreColorHex());

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.surfaceContainerHighest,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Círculo con el score
          SizedBox(
            width: 200,
            height: 200,
            child: CustomPaint(
              painter: _SleepScorePainter(
                score: score,
                color: scoreColor,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      sleepData!.getScoreEmoji(),
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      score.toString(),
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      sleepData!.getScoreDescription(),
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Texto de calidad
          Text(
            'Calidad de tu sueño anoche',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            duration,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // Indicadores de métricas en 2 filas
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MetricIndicator(
                    icon: Icons.thermostat,
                    value: '${sleepData!.temperature.toStringAsFixed(1)}°C',
                    label: 'Temperatura',
                    color: scoreColor,
                  ),
                  _MetricIndicator(
                    icon: Icons.water_drop,
                    value: '${sleepData!.humidity.toStringAsFixed(1)}%',
                    label: 'Humedad',
                    color: scoreColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MetricIndicator(
                    icon: sleepData!.light ? Icons.lightbulb : Icons.lightbulb_outline,
                    value: sleepData!.light ? 'Encendida' : 'Apagada',
                    label: 'Luz',
                    color: scoreColor,
                  ),
                  if (sleepData!.ronquidos != null)
                    _MetricIndicator(
                      icon: sleepData!.ronquidos! ? Icons.volume_up : Icons.volume_off,
                      value: sleepData!.ronquidos! ? 'Sí' : 'No',
                      label: 'Ronquidos',
                      color: scoreColor,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.surfaceContainerHighest,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.bedtime_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Sin datos disponibles',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Esperando datos de sueño...',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 7) buffer.write('FF');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

class _MetricIndicator extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MetricIndicator({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SleepScorePainter extends CustomPainter {
  final int score;
  final Color color;
  final Color backgroundColor;

  _SleepScorePainter({
    required this.score,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Círculo de fondo
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Círculo de progreso
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / 100) * 2 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}