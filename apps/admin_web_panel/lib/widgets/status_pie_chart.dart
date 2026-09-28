import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Widget reutilizável para exibir um gráfico de pizza (Pie Chart).
class StatusPieChart extends StatefulWidget {
  final Map<String, int> dataMap; // {'status': count}
  final String title;
  final Map<String, Color>? colorMap; // {'status': color}

  const StatusPieChart({
    required this.dataMap,
    required this.title,
    this.colorMap,
    super.key,
  });

  @override
  State<StatusPieChart> createState() => _StatusPieChartState();
}

class _StatusPieChartState extends State<StatusPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    // Definir cores padrão
    final colors = widget.colorMap ??
        {
          'pending': Colors.orange,
          'in_progress': Colors.blue,
          'completed': Colors.green,
          'cancelled': Colors.red,
          'active': Colors.green,
          'inactive': Colors.grey,
        };

    final entries = widget.dataMap.entries.toList();
    final total = widget.dataMap.values.fold<int>(0, (a, b) => a + b);

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
              height: 250,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (event is FlLongPressEnd || event is FlPanEndEvent) {
                          touchedIndex = -1;
                        } else if (pieTouchResponse != null && pieTouchResponse.touchedSection != null) {
                          touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        }
                      });
                    },
                  ),
                  sections: List.generate(
                    entries.length,
                    (index) {
                      final entry = entries[index];
                      final isTouched = index == touchedIndex;
                      final fontSize = isTouched ? 16.0 : 12.0;
                      final radius = isTouched ? 120.0 : 100.0;
                      final percentage = (entry.value / total * 100);

                      return PieChartSectionData(
                        color: colors[entry.key] ?? Colors.grey,
                        value: entry.value.toDouble(),
                        title: '${percentage.toStringAsFixed(1)}%',
                        radius: radius,
                        titleStyle: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  centerSpaceRadius: 0,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legenda
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: entries.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[entry.key] ?? Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${entry.key}: ${entry.value}'),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
