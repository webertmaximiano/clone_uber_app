import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Widget reutilizável para exibir um gráfico de barras.
class BarChartWidget extends StatefulWidget {
  final List<String> labels;
  final List<double> values;
  final String title;
  final Color barColor;
  final double maxY;

  const BarChartWidget({
    required this.labels,
    required this.values,
    required this.title,
    this.barColor = Colors.deepPurple,
    required this.maxY,
    super.key,
  });

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  gridData: GridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < widget.labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                widget.labels[index],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  minY: 0,
                  maxY: widget.maxY,
                  barGroups: List.generate(
                    widget.values.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: widget.values[index],
                          color: widget.barColor,
                          width: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
