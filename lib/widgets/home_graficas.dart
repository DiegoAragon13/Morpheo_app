import 'package:flutter/material.dart';
import '../models/sleep_data.dart';

class HomeGraficas extends StatefulWidget {
  final SleepGraphData? ronquidosData;
  final SleepGraphData? humedadData;
  final SleepGraphData? temperaturaData;

  const HomeGraficas({
    Key? key,
    this.ronquidosData,
    this.humedadData,
    this.temperaturaData,
  }) : super(key: key);

  @override
  State<HomeGraficas> createState() => _HomeGraficasState();
}

class _HomeGraficasState extends State<HomeGraficas> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _debugPrintData();
  }

  void _debugPrintData() {
    print('🎨 HomeGraficas - Datos recibidos:');
    print(
        '   - Temperatura: ${widget.temperaturaData != null} (${widget.temperaturaData?.values.length ?? 0} valores)');
    print(
        '   - Humedad: ${widget.humedadData != null} (${widget.humedadData?.values.length ?? 0} valores)');
    print(
        '   - Ronquidos: ${widget.ronquidosData != null} (${widget.ronquidosData?.values.length ?? 0} valores)');

    if (widget.ronquidosData != null) {
      print('   - Ronquidos values: ${widget.ronquidosData!.values}');
      print('   - Ronquidos labels: ${widget.ronquidosData!.labels}');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 280,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Sin datos de gráficas',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Esperando datos históricos...',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Si no hay ningún dato, mostrar placeholder
    if (widget.temperaturaData == null &&
        widget.humedadData == null &&
        widget.ronquidosData == null) {
      print('⚠️ Mostrando placeholder - sin datos');
      return _buildPlaceholder(context);
    }

    // Lista de gráficas disponibles
    final graficas = <Widget>[];

    // Agregar temperatura si hay datos
    if (widget.temperaturaData != null &&
        widget.temperaturaData!.values.isNotEmpty) {
      print('✅ Agregando gráfica de temperatura');
      graficas.add(_GraficaCard(
        data: widget.temperaturaData!,
        color: const Color(0xFFFFD600),
      ));
    }

    // Agregar humedad si hay datos
    if (widget.humedadData != null && widget.humedadData!.values.isNotEmpty) {
      print('✅ Agregando gráfica de humedad');
      graficas.add(_GraficaCard(
        data: widget.humedadData!,
        color: const Color(0xFF40C4FF),
      ));
    }

    // Agregar ronquidos si hay datos
    if (widget.ronquidosData != null &&
        widget.ronquidosData!.values.isNotEmpty) {
      print('✅ Agregando gráfica de ronquidos');
      graficas.add(_GraficaCard(
        data: widget.ronquidosData!,
        color: const Color(0xFF7C4DFF),
      ));
    } else {
      print('⚠️ No se agregó gráfica de ronquidos');
      if (widget.ronquidosData != null) {
        print(
            '   - Tiene objeto pero está vacío: ${widget.ronquidosData!.values.isEmpty}');
      }
    }

    print('📊 Total de gráficas a mostrar: ${graficas.length}');

    // Si no hay gráficas con datos, mostrar placeholder
    if (graficas.isEmpty) {
      print('⚠️ No hay gráficas para mostrar');
      return _buildPlaceholder(context);
    }

    return Column(
      children: [
        // Carrusel de gráficas
        SizedBox(
          height: 280,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: graficas,
          ),
        ),
        const SizedBox(height: 16),

        // Indicadores de página
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(graficas.length, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? theme.colorScheme.tertiary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// Widget de card para cada gráfica
class _GraficaCard extends StatelessWidget {
  final SleepGraphData data;
  final Color color;

  const _GraficaCard({
    Key? key,
    required this.data,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Detectar si son ronquidos
    final isSnoring = data.title == 'Ronquidos' || data.unit.isEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.surfaceContainerHighest,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con título y promedio/info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Para ronquidos mostrar contador, para otros mostrar promedio
              if (data.values.isNotEmpty)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isSnoring
                        ? '${data.values.where((v) => v > 0).length} detectados'
                        : 'Prom: ${data.average.toStringAsFixed(1)}${data.unit}',
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Gráfica
          Expanded(
            child: _BarChart(
              data: data,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget de gráfica de barras
class _BarChart extends StatelessWidget {
  final SleepGraphData data;
  final Color color;

  const _BarChart({
    Key? key,
    required this.data,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (data.values.isEmpty) {
      return Center(
        child: Text(
          'Sin datos disponibles',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    // Detectar si son datos de ronquidos (valores binarios 0 o 1)
    final isSnoring = data.title == 'Ronquidos' || data.unit.isEmpty;

    // Para ronquidos, usar el valor máximo como 1.0 para mejor visualización
    final maxValue =
    isSnoring ? 1.0 : (data.maxValue > 0 ? data.maxValue : 1.0);

    // Mostrar máximo 8 valores
    final displayValues =
    data.values.length > 8 ? data.values.sublist(0, 8) : data.values;
    final displayLabels =
    data.labels.length > 5 ? _selectLabels(data.labels, 5) : data.labels;

    return Column(
      children: [
        // Gráfica
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: displayValues.map((value) {
              // Para ronquidos: 0 = barra pequeña, 1 = barra grande
              double normalizedHeight;

              if (isSnoring) {
                // Para ronquidos: 0 = barra pequeña, 1 = barra grande
                normalizedHeight = value > 0 ? 120.0 : 10.0;
              } else {
                // Para otros datos: escalar normalmente
                normalizedHeight = ((value / maxValue) * 150)
                    .toDouble()
                    .clamp(5.0, 150.0);
              }

              return Container(
                width: 20,
                height: normalizedHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      color,
                      color.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),

        // Labels de horas
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: displayLabels.map((label) {
            return Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Seleccionar labels uniformemente distribuidos
  List<String> _selectLabels(List<String> labels, int count) {
    if (labels.length <= count) return labels;

    final result = <String>[];
    final step = (labels.length - 1) / (count - 1);

    for (int i = 0; i < count; i++) {
      final index = (i * step).round().clamp(0, labels.length - 1);
      result.add(labels[index]);
    }

    return result;
  }
}