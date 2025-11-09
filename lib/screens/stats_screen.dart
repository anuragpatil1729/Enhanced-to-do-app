import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/todo_provider.dart';
import '../services/export_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _touchedIndex = -1;
  final ExportService _exportService = ExportService();

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<TodoProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productivity Stats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _showExportDialog(context, prov),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.8,
            children: [
              _buildStatCard('Completed', prov.completedTasks.toString(), Icons.check_circle, Colors.green, theme),
              _buildStatCard('Active', prov.activeTasks.toString(), Icons.pending, Colors.orange, theme),
              _buildStatCard('Overdue', prov.overdueTasks.toString(), Icons.error, Colors.red, theme),
              _buildStatCard('Total', prov.totalTasks.toString(), Icons.list_alt, theme.colorScheme.primary, theme),
            ],
          ),
          const SizedBox(height: 24),
          _buildChartCard(
            theme,
            title: 'Task Breakdown',
            child: SizedBox(
              height: 220,
              child: _buildPieChart(prov, theme),
            ),
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            theme,
            title: 'Due This Week',
            child: SizedBox(
              height: 220,
              child: _buildBarChart(prov, theme),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showExportDialog(BuildContext context, TodoProvider prov) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Export Tasks'),
          content: const Text('Choose the format to export your tasks.'),
          actions: <Widget>[
            TextButton(
              child: const Text('JSON'),
              onPressed: () {
                _exportService.exportTasks(prov.todos, 'json');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('CSV'),
              onPressed: () {
                _exportService.exportTasks(prov.todos, 'csv');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                Icon(icon, color: color, size: 28),
              ],
            ),
            Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(ThemeData theme, {required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(TodoProvider prov, ThemeData theme) {
    final completed = prov.completedTasks.toDouble();
    final active = prov.activeTasks.toDouble();
    final overdue = prov.overdueTasks.toDouble();
    final total = completed + active + overdue;

    if (total == 0) {
      return const Center(child: Text('No data to display.'));
    }

    final sections = [
      PieChartSectionData(
        color: Colors.green.shade400,
        value: completed,
        title: '${(completed / total * 100).toStringAsFixed(0)}%',
        radius: _touchedIndex == 0 ? 60 : 50,
        titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.orange.shade400,
        value: active,
        title: '${(active / total * 100).toStringAsFixed(0)}%',
        radius: _touchedIndex == 1 ? 60 : 50,
        titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.red.shade400,
        value: overdue,
        title: '${(overdue / total * 100).toStringAsFixed(0)}%',
        radius: _touchedIndex == 2 ? 60 : 50,
        titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ];

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                _touchedIndex = -1;
                return;
              }
              _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        sectionsSpace: 4,
        centerSpaceRadius: 60,
        sections: sections,
      ),
    );
  }

  Widget _buildBarChart(TodoProvider prov, ThemeData theme) {
    return BarChart(
      BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final style = TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  );
                  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  return SideTitleWidget(axisSide: meta.axisSide, space: 4, child: Text(days[value.toInt()], style: style));
                },
                reservedSize: 24,
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: prov.tasksByWeekday.entries.map((entry) {
            final index = _getWeekdayIndex(entry.key);
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  color: theme.colorScheme.primary,
                  width: 16,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                ),
              ],
            );
          }).toList()),
    );
  }

  int _getWeekdayIndex(String weekday) {
    switch (weekday) {
      case 'Mon': return 0;
      case 'Tue': return 1;
      case 'Wed': return 2;
      case 'Thu': return 3;
      case 'Fri': return 4;
      case 'Sat': return 5;
      case 'Sun': return 6;
      default: return -1;
    }
  }
}
