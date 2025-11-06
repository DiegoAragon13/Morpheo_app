import 'package:flutter/material.dart';
import '../models/alarm.dart';

class AlarmDialog extends StatefulWidget {
  final Alarm? alarm; // null = crear nueva, con valor = editar

  const AlarmDialog({Key? key, this.alarm}) : super(key: key);

  @override
  State<AlarmDialog> createState() => _AlarmDialogState();
}

class _AlarmDialogState extends State<AlarmDialog> {
  late TimeOfDay _selectedTime;
  late TextEditingController _labelController;
  late List<int> _selectedDays;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();

    // Si estamos editando, usar valores existentes
    if (widget.alarm != null) {
      _selectedTime = widget.alarm!.time;
      _labelController = TextEditingController(text: widget.alarm!.label);
      _selectedDays = List.from(widget.alarm!.days);
      _isEnabled = widget.alarm!.isEnabled;
    } else {
      // Valores por defecto para nueva alarma
      _selectedTime = const TimeOfDay(hour: 7, minute: 0);
      _labelController = TextEditingController(text: 'Alarma');
      _selectedDays = [1, 2, 3, 4, 5]; // Lun-Vie por defecto
      _isEnabled = true;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF3D5AFE),
              onPrimary: Colors.white,
              surface: Color(0xFF2C2C34),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
        _selectedDays.sort(); // Mantener orden
      }
    });
  }

  void _save() {
    // Validar que haya al menos un día seleccionado
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecciona al menos un día'),
          backgroundColor: Colors.red[900],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Crear o actualizar alarma
    final alarm = Alarm(
      id: widget.alarm?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      time: _selectedTime,
      label: _labelController.text.trim().isEmpty
          ? 'Alarma'
          : _labelController.text.trim(),
      days: _selectedDays,
      isEnabled: _isEnabled,
    );

    Navigator.pop(context, alarm);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.alarm != null;

    return Dialog(
      backgroundColor: const Color(0xFF2C2C34),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                isEditing ? 'Editar Alarma' : 'Nueva Alarma',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Selector de hora
              _buildTimeSelector(),
              const SizedBox(height: 24),

              // Campo de etiqueta
              _buildLabelField(),
              const SizedBox(height: 24),

              // Selector de días
              _buildDaySelector(),
              const SizedBox(height: 24),

              // Switch de activar/desactivar
              _buildEnabledSwitch(),
              const SizedBox(height: 32),

              // Botones
              _buildActionButtons(isEditing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF3D5AFE).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time, color: Color(0xFF3D5AFE), size: 24),
                SizedBox(width: 8),
                Text(
                  'Hora',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelField() {
    return TextField(
      controller: _labelController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Etiqueta',
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.label_outline, color: Color(0xFF3D5AFE)),
        filled: true,
        fillColor: const Color(0xFF1C1C24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: const Color(0xFF3D5AFE).withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF3D5AFE),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    const days = [
      {'label': 'L', 'value': 1},
      {'label': 'M', 'value': 2},
      {'label': 'M', 'value': 3},
      {'label': 'J', 'value': 4},
      {'label': 'V', 'value': 5},
      {'label': 'S', 'value': 6},
      {'label': 'D', 'value': 7},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Repetir',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: days.map((day) {
            final isSelected = _selectedDays.contains(day['value']);
            return GestureDetector(
              onTap: () => _toggleDay(day['value'] as int),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF3D5AFE)
                      : const Color(0xFF1C1C24),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF3D5AFE)
                        : Colors.white.withOpacity(0.1),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    day['label'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.white54,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEnabledSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3D5AFE).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Activar alarma',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          Switch(
            value: _isEnabled,
            onChanged: (value) {
              setState(() {
                _isEnabled = value;
              });
            },
            activeColor: const Color(0xFF3D5AFE),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isEditing) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D5AFE),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isEditing ? 'Guardar' : 'Crear',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}