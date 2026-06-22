import 'package:flutter/material.dart';

import '../database/database.dart';

class DashboardStats {
  final int sessionCount;
  final Map<MuscleGroup, double> avgHitsPerSession;
  final double? avgCvDurationMinutes;
  final int cvSessionCount;

  DashboardStats({
    required this.sessionCount,
    required this.avgHitsPerSession,
    required this.avgCvDurationMinutes,
    required this.cvSessionCount,
  });
}

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
    final sessionIds = sessions.map((s) => s.id).toList();
    final groups = await widget.database.groupsForSessionIds(sessionIds);

    final hitTotals = <MuscleGroup, int>{};
    for (final g in groups) {
      final group = MuscleGroup.values.firstWhere((m) => m.name == g.muscleGroup);
      hitTotals[group] = (hitTotals[group] ?? 0) + g.hitCount;
    }

    final sessionCount = sessions.length;
    final avgHitsPerSession = {
      for (final group in MuscleGroup.values)
        group: sessionCount == 0 ? 0.0 : (hitTotals[group] ?? 0) / sessionCount,
    };

    final cvSessions = sessions.where((s) => s.cvDurationMinutes != null).toList();
    final avgCv = cvSessions.isEmpty
        ? null
        : cvSessions.map((s) => s.cvDurationMinutes!).reduce((a, b) => a + b) /
            cvSessions.length;

    return DashboardStats(
      sessionCount: sessionCount,
      avgHitsPerSession: avgHitsPerSession,
      avgCvDurationMinutes: avgCv,
      cvSessionCount: cvSessions.length,
    );
  }

  String _label(MuscleGroup group) {
    switch (group) {
      case MuscleGroup.front:
        return 'Front';
      case MuscleGroup.back:
        return 'Back';
      case MuscleGroup.legs:
        return 'Legs';
      case MuscleGroup.core:
        return 'Core';
    }
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
                              '${_label(g)}: ${stats.avgHitsPerSession[g]!.toStringAsFixed(1)}'))
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
          ],
        ),
      ),
    );
  }
}
