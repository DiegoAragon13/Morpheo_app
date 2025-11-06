import 'package:flutter/material.dart';
import 'dart:math' as math;

class HistoryTrendChart extends StatelessWidget {
  final List<double> scores;
  final String title;

  const HistoryTrendChart({
    Key? key,
    required this.scores,
    this.title = 'Tendencia',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (scores.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Icon(
              Icons.show_chart,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin datos suficientes',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los datos aparecerán aquí',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // Calcular estadísticas
    final avgScore = scores.reduce((a, b) => a + b) / scores.length;
    final maxScore = scores.reduce(math.max);
    final minScore = scores.reduce(math.min);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y estadísticas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildScoreBadge(avgScore, theme),
            ],
          ),
          const SizedBox(height: 16),

          // Estadísticas resumidas
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatChip(
                label: 'Máx',
                value: maxScore.toStringAsFixed(0),
                color: theme.colorScheme.primary,
              ),
              _StatChip(
                label: 'Min',
                value: minScore.toStringAsFixed(0),
                color: theme.colorScheme.error,
              ),
              _StatChip(
                label: 'Días',
                value: '${scores.length}',
                color: theme.colorScheme.tertiary,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Gráfica
          SizedBox(
            height: 200,
            child: _LineChart(
              scores: scores,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBadge(double score, ThemeData theme) {
    Color badgeColor;
    String label;

    if (score >= 85) {
      badgeColor = const Color(0xFF4CAF50);
      label = 'Excelente';
    } else if (score >= 70) {
      badgeColor = const Color(0xFF2196F3);
      label = 'Bueno';
    } else if (score >= 50) {
      badgeColor = const Color(0xFFFFC107);
      label = 'Regular';
    } else {
      badgeColor = const Color(0xFFFF5722);
      label = 'Bajo';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            score.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    Key? key,
    required this.label,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  final List<double> scores;
  final Color color;

  const _LineChart({
    Key? key,
    required this.scores,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomPaint(
      size: Size.infinite,
      painter: _LineChartPainter(
        scores: scores,
        color: color,
        gridColor: theme.colorScheme.surfaceContainerHighest,
        textColor: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> scores;
  final Color color;
  final Color gridColor;
  final Color textColor;

  _LineChartPainter({
    required this.scores,
    required this.color,
    required this.gridColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.3),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final innerCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Padding ajustado
    const leftPadding = 35.0;
    const rightPadding = 20.0;
    const topPadding = 10.0;
    const bottomPadding = 30.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    // Encontrar min y max
    final minScore = scores.reduce(math.min);
    final maxScore = scores.reduce(math.max);
    final range = maxScore - minScore;
    final adjustedMin = range > 0
        ? (minScore - range * 0.1).clamp(0, 100)
        : (minScore - 10).clamp(0, 100);
    final adjustedMax = range > 0
        ? (maxScore + range * 0.1).clamp(0, 100)
        : (maxScore + 10).clamp(0, 100);
    final adjustedRange = adjustedMax - adjustedMin;

    // Dibujar líneas de grid horizontales
    final yLabels = [adjustedMin, (adjustedMin + adjustedMax) / 2, adjustedMax];
    for (var label in yLabels) {
      final y = topPadding + chartHeight - ((label - adjustedMin) / adjustedRange * chartHeight);

      // Línea
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );

      // Etiqueta
      final textSpan = TextSpan(
        text: label.toStringAsFixed(0),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - textPainter.height / 2));
    }

    // Dibujar etiquetas del eje X (adaptativo según cantidad de días)
    final totalDays = scores.length;
    List<int> xLabels;

    if (totalDays <= 7) {
      // Semanal: mostrar todos los días
      xLabels = List.generate(totalDays, (i) => i + 1);
    } else if (totalDays <= 14) {
      // 2 semanas: cada 2 días
      xLabels = List.generate((totalDays / 2).ceil(), (i) => (i * 2) + 1);
    } else {
      // Mensual: cada 5 días
      xLabels = [1, 5, 10, 15, 20, 25, 30].where((d) => d <= totalDays).toList();
    }

    for (var day in xLabels) {
      if (day <= scores.length) {
        final normalizedX = scores.length > 1
            ? (day - 1) / (scores.length - 1)
            : 0.5;
        final x = leftPadding + normalizedX * chartWidth;

        // Etiqueta
        final textSpan = TextSpan(
          text: '$day',
          style: TextStyle(
            color: textColor,
            fontSize: 10,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, size.height - bottomPadding + 8),
        );
      }
    }

    // Dibujar área bajo la línea
    final fillPath = Path();
    for (int i = 0; i < scores.length; i++) {
      final normalizedX = scores.length > 1
          ? i / (scores.length - 1)
          : 0.5;
      final x = leftPadding + normalizedX * chartWidth;
      final normalizedScore = (scores[i] - adjustedMin) / adjustedRange;
      final y = topPadding + chartHeight - (normalizedScore * chartHeight);

      if (i == 0) {
        fillPath.moveTo(x, size.height - bottomPadding);
        fillPath.lineTo(x, y);
      } else {
        fillPath.lineTo(x, y);
      }
    }
    final lastX = scores.length > 1
        ? leftPadding + chartWidth
        : leftPadding + chartWidth / 2;
    fillPath.lineTo(lastX, size.height - bottomPadding);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Dibujar línea principal
    final path = Path();
    for (int i = 0; i < scores.length; i++) {
      final normalizedX = scores.length > 1
          ? i / (scores.length - 1)
          : 0.5;
      final x = leftPadding + normalizedX * chartWidth;
      final normalizedScore = (scores[i] - adjustedMin) / adjustedRange;
      final y = topPadding + chartHeight - (normalizedScore * chartHeight);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    // Dibujar puntos (solo si no hay demasiados)
    if (scores.length <= 30) {
      for (int i = 0; i < scores.length; i++) {
        final normalizedX = scores.length > 1
            ? i / (scores.length - 1)
            : 0.5;
        final x = leftPadding + normalizedX * chartWidth;
        final normalizedScore = (scores[i] - adjustedMin) / adjustedRange;
        final y = topPadding + chartHeight - (normalizedScore * chartHeight);

        // Círculo exterior
        canvas.drawCircle(Offset(x, y), 5, circlePaint);
        // Círculo interior (blanco)
        canvas.drawCircle(Offset(x, y), 3, innerCirclePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}