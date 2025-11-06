import 'package:flutter/material.dart';

enum HistoryViewMode { monthly, weekly }

class HistoryViewSelector extends StatelessWidget {
  final HistoryViewMode selectedMode;
  final Function(HistoryViewMode) onModeChanged;

  const HistoryViewSelector({
    Key? key,
    required this.selectedMode,
    required this.onModeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _OptionButton(
              label: 'Mensual',
              isSelected: selectedMode == HistoryViewMode.monthly,
              onTap: () => onModeChanged(HistoryViewMode.monthly),
            ),
          ),
          Expanded(
            child: _OptionButton(
              label: 'Semanal',
              isSelected: selectedMode == HistoryViewMode.weekly,
              onTap: () => onModeChanged(HistoryViewMode.weekly),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionButton({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}