import 'package:flutter/material.dart';

import '../database/database.dart';
import '../models/dashboard_stats.dart';
import '../screens/analysis_screen.dart';

class DashboardSummary extends StatefulWidget {
  final AppDatabase database;
  final int refreshToken;

  const DashboardSummary({
    super.key,
    required this.database,
    this.refreshToken = 0,
  });

  @override
  State<DashboardSummary> createState() => _DashboardSummaryState();
}

class _DashboardSummaryState extends State<DashboardSummary> {
  int _rangeDays = 7;
  late Future<DashboardStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  @override
  void didUpdateWidget(DashboardSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      setState(() => _statsFuture = _loadStats());
    }
  }

  void _setRange(int days) {
    setState(() {
      _rangeDays = days;
      _statsFuture = _loadStats();
    });
  }

  Future<DashboardStats> _loadStats() async {
    final from = DateTime.now().subtract(Duration(days: _rangeDays));
    final sessions = await widget.database.sessionsSince(from);
    return DashboardStats.compute(widget.database, sessions);
  }

  void _openAnalysis() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AnalysisScreen(database: widget.database),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Summary', style: Theme.of(context).textTheme.titleMedium),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 7, label: Text('7 days')),
                    ButtonSegment(value: 28, label: Text('28 days')),
                  ],
                  selected: {_rangeDays},
                  onSelectionChanged: (selection) => _setRange(selection.first),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<DashboardStats>(
              future: _statsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final stats = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sessions: ${stats.sessionCount}'),
                    const SizedBox(height: 8),
                    Text(
                      'Avg hits per session by group:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 16,
                      runSpacing: 4,
                      children: MuscleGroup.values
                          .map((g) => Text(
                              '${muscleGroupLabel(g)}: ${stats.avgHitsPerSession[g]!.toStringAsFixed(1)}'))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stats.avgCvDurationMinutes == null
                          ? 'Avg CV duration: no cardio logged'
                          : 'Avg CV duration: ${stats.avgCvDurationMinutes!.toStringAsFixed(1)} min '
                              '(${stats.cvSessionCount} session${stats.cvSessionCount == 1 ? '' : 's'})',
                    ),
                  ],
                );
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _openAnalysis,
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('Detail / Custom'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
