import 'package:flutter/material.dart';
import '../models/sleep_data.dart';

class HistoryCalendar extends StatelessWidget {
  final DateTime selectedMonth;
  final Map<DateTime, SleepQuality> sleepDays; // Map de días con calidad de sueño
  final Function(DateTime) onDaySelected;

  const HistoryCalendar({
    Key? key,
    required this.selectedMonth,
    required this.sleepDays,
    required this.onDaySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del mes
          Text(
            _getMonthYearText(selectedMonth),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Headers de días de la semana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['L', 'M', 'X', 'J', 'V', 'S', 'D'].map((day) {
              return SizedBox(
                width: 40,
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Calendario
          ..._buildCalendarWeeks(context),
        ],
      ),
    );
  }

  List<Widget> _buildCalendarWeeks(BuildContext context) {
    final theme = Theme.of(context);
    final firstDayOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

    // Ajustar para que lunes sea 0
    int startWeekday = firstDayOfMonth.weekday - 1;

    List<Widget> weeks = [];
    List<Widget> currentWeek = [];

    // Espacios vacíos antes del primer día
    for (int i = 0; i < startWeekday; i++) {
      currentWeek.add(const SizedBox(width: 40, height: 56));
    }

    // Días del mes
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(selectedMonth.year, selectedMonth.month, day);
      final quality = sleepDays[_dateOnly(date)];

      currentWeek.add(_DayCircle(
        day: day,
        quality: quality,
        isToday: _isToday(date),
        onTap: () => onDaySelected(date),
      ));

      // Si completamos una semana, agregarla
      if (currentWeek.length == 7) {
        weeks.add(Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: currentWeek,
          ),
        ));
        currentWeek = [];
      }
    }

    // Agregar última semana si tiene días
    if (currentWeek.isNotEmpty) {
      // Rellenar con espacios vacíos
      while (currentWeek.length < 7) {
        currentWeek.add(const SizedBox(width: 40, height: 56));
      }
      weeks.add(Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: currentWeek,
        ),
      ));
    }

    return weeks;
  }

  String _getMonthYearText(DateTime date) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}

// Widget para cada día del calendario
class _DayCircle extends StatelessWidget {
  final int day;
  final SleepQuality? quality;
  final bool isToday;
  final VoidCallback onTap;

  const _DayCircle({
    Key? key,
    required this.day,
    this.quality,
    required this.isToday,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color indicatorColor;
    if (quality == null) {
      indicatorColor = theme.colorScheme.surfaceContainerHighest;
    } else {
      switch (quality!) {
        case SleepQuality.excellent:
          indicatorColor = const Color(0xFF4CAF50); // Verde
          break;
        case SleepQuality.good:
          indicatorColor = const Color(0xFF2196F3); // Azul
          break;
        case SleepQuality.fair:
          indicatorColor = const Color(0xFFFFC107); // Amarillo
          break;
        case SleepQuality.poor:
          indicatorColor = const Color(0xFFFF5722); // Naranja
          break;
      }
    }

    return GestureDetector(
      onTap: quality != null ? onTap : null,
      child: Container(
        width: 40,
        height: 56,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: quality != null
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enum para calidad de sueño
enum SleepQuality {
  excellent,
  good,
  fair,
  poor,
}