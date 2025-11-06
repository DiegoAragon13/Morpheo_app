import 'package:flutter/material.dart';
import '../models/alarm.dart';

class AlarmCard extends StatelessWidget {
  final Alarm alarm;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AlarmCard({
    Key? key,
    required this.alarm,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hora y controles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Hora y etiqueta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alarm.timeString,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: alarm.isEnabled
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant
                            .withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alarm.label,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: alarm.isEnabled
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurfaceVariant
                            .withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),

              // Controles
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón editar
                  IconButton(
                    onPressed: onEdit,
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 22,
                      color: theme.colorScheme.onTertiary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  // Botón eliminar
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      size: 22,
                      color: theme.colorScheme.onTertiary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  // Switch
                  Switch(
                    value: alarm.isEnabled,
                    onChanged: (_) => onToggle(),
                    activeColor: theme.colorScheme.onTertiary,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Días de la semana
          AlarmDaysChips(
            selectedDays: alarm.days,
            isEnabled: alarm.isEnabled,
          ),
        ],
      ),
    );
  }
}

// Widget para los chips de días
class AlarmDaysChips extends StatelessWidget {
  final List<int> selectedDays;
  final bool isEnabled;

  const AlarmDaysChips({
    Key? key,
    required this.selectedDays,
    required this.isEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [1, 2, 3, 4, 5, 6, 7].map((day) {
        final isSelected = selectedDays.contains(day);
        return DayChip(
          day: day,
          isSelected: isSelected,
          isEnabled: isEnabled,
        );
      }).toList(),
    );
  }
}

// Chip individual de día
class DayChip extends StatelessWidget {
  final int day;
  final bool isSelected;
  final bool isEnabled;

  const DayChip({
    Key? key,
    required this.day,
    required this.isSelected,
    required this.isEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const labels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    final backgroundColor = isSelected
        ? theme.colorScheme.tertiary.withOpacity(isEnabled ? 0.2 : 0.1)
        : theme.colorScheme.surfaceContainerHighest;

    final textColor = isSelected
        ? (isEnabled ? theme.colorScheme.tertiary : theme.colorScheme.onSurfaceVariant.withOpacity(0.5))
        : theme.colorScheme.onSurfaceVariant.withOpacity(0.5);

    final borderColor = isSelected && isEnabled
        ? theme.colorScheme.tertiary.withOpacity(0.5)
        : Colors.transparent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: Text(
        labels[day - 1],
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: textColor,
        ),
      ),
    );
  }
}