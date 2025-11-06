import 'package:flutter/material.dart';
import 'package:morpheo_app/services/device_service.dart';
import 'dart:async';

class DispositivoPage extends StatefulWidget {
  const DispositivoPage({Key? key}) : super(key: key);

  @override
  State<DispositivoPage> createState() => _DispositivoPageState();
}

class _DispositivoPageState extends State<DispositivoPage> {
  bool _isConnected = false;
  bool _ledsEnabled = true;
  Color _selectedColor = const Color(0xFF8B7CFF);
  bool _isLoading = false;
  Timer? _connectionTimer;

  double? _temperature;
  double? _humidity;

  final List<Color> _availableColors = [
    const Color(0xFF8B7CFF), // Morado
    const Color(0xFF4A9FFF), // Azul
    const Color(0xFF4AEDC4), // Verde agua
    const Color(0xFFFFB347), // Naranja
    const Color(0xFFFF5C5C), // Rojo
  ];

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _connectionTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => _checkConnection());
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    final connected = await DeviceService.isConnected();
    if (mounted) {
      setState(() => _isConnected = connected);
      if (connected) _loadCurrentState();
    }
  }

  Future<void> _loadCurrentState() async {
    final state = await DeviceService.getStatus();
    if (state != null && mounted) {
      setState(() {
        _ledsEnabled = state['ledEnabled'] ?? true;
        _temperature = state['temperature']?.toDouble();
        _humidity = state['humidity']?.toDouble();
        if (state['ledColor'] != null) {
          final color = state['ledColor'];
          _selectedColor = Color.fromRGBO(
            color['r'],
            color['g'],
            color['b'],
            1,
          );
        }
      });
    }
  }

  Future<void> _sendLedCommand() async {
    if (!_isConnected) return;

    setState(() => _isLoading = true);

    final success = await DeviceService.updateLed(
      enabled: _ledsEnabled,
      r: _selectedColor.red,
      g: _selectedColor.green,
      b: _selectedColor.blue,
    );

    setState(() => _isLoading = false);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al enviar comando al dispositivo'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _selectColor(Color color) {
    setState(() => _selectedColor = color);
    _sendLedCommand();
  }

  void _toggleLeds() {
    setState(() => _ledsEnabled = !_ledsEnabled);
    _sendLedCommand();
  }

  void _showIpDialog() {
    final controller = TextEditingController(text: DeviceService.esp32Ip);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Configurar IP del ESP32',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '192.168.43.234',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF8B7CFF)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              DeviceService.setEsp32Ip(controller.text);
              Navigator.pop(context);
              _checkConnection();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B7CFF),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.phone_android, size: 28, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Control de Dispositivo',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: _showIpDialog,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Configura tu Morpheo',
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
              const SizedBox(height: 24),
              _buildConnectionCard(),
              const SizedBox(height: 16),
              if (_isConnected && (_temperature != null || _humidity != null))
                _buildSensorCard(),
              if (_isConnected && (_temperature != null || _humidity != null))
                const SizedBox(height: 16),
              _buildLedControlCard(),
            ],
          ),
        ),
      ),
    );
  }

  // CARD DE CONEXIÓN
  Widget _buildConnectionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isConnected
              ? const Color(0xFF4AEDC4).withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _isConnected
                  ? const Color(0xFF4AEDC4).withOpacity(0.2)
                  : Colors.grey[900],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi,
              color: _isConnected ? const Color(0xFF4AEDC4) : Colors.grey[600],
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isConnected ? 'Morpheo conectado' : 'Morpheo desconectado',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isConnected
                      ? 'IP: ${DeviceService.esp32Ip}'
                      : 'Dispositivo sin conexión',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _isConnected ? const Color(0xFF4AEDC4) : Colors.grey[700],
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  // CARD DE SENSORES
  Widget _buildSensorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          if (_temperature != null)
            Expanded(
              child: Column(
                children: [
                  const Icon(Icons.thermostat,
                      color: Color(0xFFFF5C5C), size: 32),
                  const SizedBox(height: 8),
                  Text(
                    '${_temperature!.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text('Temperatura',
                      style:
                      TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
          if (_temperature != null && _humidity != null)
            Container(width: 1, height: 60, color: Colors.grey[800]),
          if (_humidity != null)
            Expanded(
              child: Column(
                children: [
                  const Icon(Icons.water_drop,
                      color: Color(0xFF4A9FFF), size: 32),
                  const SizedBox(height: 8),
                  Text(
                    '${_humidity!.toStringAsFixed(0)}%',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text('Humedad',
                      style:
                      TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // CARD DE CONTROL DE LED — corregido con brillo suave sin overflow
  Widget _buildLedControlCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline,
                  color: Colors.white, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Luces LED',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const Spacer(),
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Color(0xFF8B7CFF)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Selector de colores con efecto limpio
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _availableColors.map((color) {
              final isSelected = color == _selectedColor;
              return GestureDetector(
                onTap: _ledsEnabled && _isConnected
                    ? () => _selectColor(color)
                    : null,
                child: Opacity(
                  opacity: _ledsEnabled && _isConnected ? 1.0 : 0.3,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isSelected && _ledsEnabled)
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withOpacity(0.25),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.6),
                                blurRadius: 15,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Botón ON/OFF
          GestureDetector(
            onTap: _isConnected ? _toggleLeds : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _ledsEnabled && _isConnected
                    ? _selectedColor.withOpacity(0.2)
                    : Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _ledsEnabled && _isConnected
                      ? _selectedColor.withOpacity(0.5)
                      : Colors.grey[800]!,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _ledsEnabled ? Icons.power_settings_new : Icons.power_off,
                    color: _ledsEnabled && _isConnected
                        ? _selectedColor
                        : Colors.grey[600],
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _ledsEnabled ? 'Apagar LEDs' : 'Encender LEDs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _ledsEnabled && _isConnected
                          ? Colors.white
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Vista previa del color
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: _ledsEnabled && _isConnected
                  ? _selectedColor
                  : Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
              boxShadow: _ledsEnabled && _isConnected
                  ? [
                BoxShadow(
                  color: _selectedColor.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
                  : null,
            ),
            child: !_ledsEnabled || !_isConnected
                ? Center(
              child: Icon(
                _isConnected ? Icons.power_off : Icons.wifi_off,
                color: Colors.grey[700],
                size: 48,
              ),
            )
                : null,
          ),
        ],
      ),
    );
  }
}
