import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Widget reutilizável para exibir um gráfico de linhas.
class RevenueLineChart extends StatefulWidget {
  final List<FlSpot> dataPoints;
  final String title;
  final String yAxisLabel;
  final double maxY;

  const RevenueLineChart({
    required this.dataPoints,
    required this.title,
    required this.yAxisLabel,
    required this.maxY,
    super.key,
  });

  @override
  State<RevenueLineChart> createState() => _RevenueLineChartState();
}

class _RevenueLineChartState extends State<RevenueLineChart> {
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
              child: LineChart(
                LineChartData(
                  gridData: GridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            'R\$ ${value.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            'Dia ${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: (widget.dataPoints.isEmpty
                      ? 10
                      : widget.dataPoints.last.x),
                  minY: 0,
                  maxY: widget.maxY,
                  lineBarsData: [
                    LineBarData(
                      spots: widget.dataPoints,
                      isCurved: true,
                      color: Colors.deepPurple,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.deepPurple.withOpacity(0.2),
                      ),
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
