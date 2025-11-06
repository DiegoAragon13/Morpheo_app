import 'package:flutter/material.dart';

class AlarmEmptyState extends StatelessWidget {
  const AlarmEmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.alarm_off,
            size: 80,
            color: Colors.grey[800],
          ),
          const SizedBox(height: 24),
          Text(
            'No hay alarmas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca + para agregar una alarma',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}