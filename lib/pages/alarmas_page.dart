import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../services/alarm_service.dart';
import '../widgets/alarm_card.dart';
import '../widgets/alarm_empty.dart';
import '../widgets/alarm_dialog.dart';

class AlarmasPage extends StatefulWidget {
  const AlarmasPage({Key? key}) : super(key: key);

  @override
  State<AlarmasPage> createState() => _AlarmasPageState();
}

class _AlarmasPageState extends State<AlarmasPage> {
  final AlarmService _alarmService = AlarmService();
  List<Alarm> _alarms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  /// Cargar alarmas desde AWS
  Future<void> _loadAlarms() async {
    setState(() => _isLoading = true);

    final alarms = await _alarmService.getAlarms();

    setState(() {
      _alarms = alarms;
      _isLoading = false;
    });
  }

  void _toggleAlarm(Alarm alarm) async {
    // Actualizar UI inmediatamente
    setState(() {
      alarm.isEnabled = !alarm.isEnabled;
    });

    // Sincronizar con AWS
    final success = await _alarmService.toggleAlarm(alarm);

    if (!success) {
      // Si falla, revertir cambio
      setState(() {
        alarm.isEnabled = !alarm.isEnabled;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error al actualizar alarma'),
          backgroundColor: Colors.red[900],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _deleteAlarm(Alarm alarm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C34),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '¿Eliminar alarma?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Esta acción no se puede deshacer.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Eliminar de la lista localmente
              setState(() {
                _alarms.removeWhere((a) => a.id == alarm.id);
              });

              // Eliminar de AWS
              final success = await _alarmService.deleteAlarm(alarm.id);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Alarma eliminada'),
                    backgroundColor: const Color(0xFF2C2C34),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              } else {
                // Si falla, recargar alarmas
                _loadAlarms();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Error al eliminar alarma'),
                    backgroundColor: Colors.red[900],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.deepPurple),
            ),
          ),
        ],
      ),
    );
  }

  void _editAlarm(Alarm alarm) async {
    final Alarm? updatedAlarm = await showDialog<Alarm>(
      context: context,
      builder: (context) => AlarmDialog(alarm: alarm),
    );

    if (updatedAlarm != null) {
      // Actualizar en la lista localmente
      setState(() {
        final index = _alarms.indexWhere((a) => a.id == alarm.id);
        if (index != -1) {
          _alarms[index] = updatedAlarm;
        }
      });

      // Sincronizar con AWS
      final success = await _alarmService.updateAlarm(updatedAlarm);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Alarma actualizada'),
            backgroundColor: const Color(0xFF2C2C34),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        // Si falla, recargar alarmas
        _loadAlarms();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('❌ Error al actualizar alarma'),
            backgroundColor: Colors.red[900],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _addAlarm() async {
    final Alarm? newAlarm = await showDialog<Alarm>(
      context: context,
      builder: (context) => const AlarmDialog(),
    );

    if (newAlarm != null) {
      // Agregar a la lista localmente
      setState(() {
        _alarms.add(newAlarm);
      });

      // Sincronizar con AWS
      final success = await _alarmService.addAlarm(newAlarm);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Alarma creada'),
            backgroundColor: const Color(0xFF2C2C34),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        // Recargar para obtener el ID real de AWS
        _loadAlarms();
      } else {
        // Si falla, remover de la lista
        setState(() {
          _alarms.removeWhere((a) => a.id == newAlarm.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('❌ Error al crear alarma'),
            backgroundColor: Colors.red[900],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gestiona tus alarmas de sueño',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Lista de alarmas
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF3D5AFE),
                ),
              )
                  : _alarms.isEmpty
                  ? const AlarmEmptyState()
                  : RefreshIndicator(
                onRefresh: _loadAlarms,
                color: const Color(0xFF3D5AFE),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _alarms.length,
                  separatorBuilder: (context, index) =>
                  const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final alarm = _alarms[index];
                    return AlarmCard(
                      alarm: alarm,
                      onToggle: () => _toggleAlarm(alarm),
                      onEdit: () => _editAlarm(alarm),
                      onDelete: () => _deleteAlarm(alarm),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        backgroundColor: const Color(0xFF3D5AFE),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}