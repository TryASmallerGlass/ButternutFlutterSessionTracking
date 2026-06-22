import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../database/database.dart';
import '../models/dashboard_stats.dart';

class AnalysisScreen extends StatefulWidget {
  final AppDatabase database;

  const AnalysisScreen({super.key, required this.database});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  late DateTime _fromDate;
  late DateTime _toDate;
  late Future<List<Session>> _sessionsFuture;
  late Future<DashboardStats> _statsFuture;
  String? _exportMessage;

  static final _dateFormat = DateFormat('EEE d MMM yyyy');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _fromDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
    _toDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    _loadData();
  }

  void _loadData() {
    _sessionsFuture = widget.database.sessionsBetween(_fromDate, _toDate);
    _statsFuture = _sessionsFuture
        .then((sessions) => DashboardStats.compute(widget.database, sessions));
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2020),
      lastDate: _toDate,
    );
    if (picked == null) return;
    setState(() {
      _fromDate = DateTime(picked.year, picked.month, picked.day);
      _loadData();
    });
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: _fromDate,
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _toDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
      _loadData();
    });
  }

  String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  Future<void> _exportCsv() async {
    final sessions = await _sessionsFuture;
    final sessionIds = sessions.map((s) => s.id).toList();
    final groups = await widget.database.groupsForSessionIds(sessionIds);

    final groupsBySession = <int, Map<MuscleGroup, int>>{};
    for (final g in groups) {
      final group = MuscleGroup.values.firstWhere((m) => m.name == g.muscleGroup);
      final map = groupsBySession.putIfAbsent(g.sessionId, () => {});
      map[group] = g.hitCount;
    }

    final headers = [
      'Date',
      'Time',
      ...MuscleGroup.values.map(muscleGroupLabel),
      'CV Duration (min)',
      'CV Level',
      'Comment',
    ];
    final buffer = StringBuffer()..writeln(headers.map(_csvEscape).join(','));

    for (final session in sessions) {
      final groupCounts = groupsBySession[session.id] ?? {};
      final row = [
        DateFormat('yyyy-MM-dd').format(session.sessionDateTime),
        DateFormat('HH:mm').format(session.sessionDateTime),
        ...MuscleGroup.values.map((g) => '${groupCounts[g] ?? 0}'),
        session.cvDurationMinutes?.toString() ?? '',
        session.cvLevel?.toString() ?? '',
        session.comment,
      ];
      buffer.writeln(row.map(_csvEscape).join(','));
    }

    final directory =
        await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    final filename = 'workout_sessions_'
        '${DateFormat('yyyyMMdd').format(_fromDate)}_'
        '${DateFormat('yyyyMMdd').format(_toDate)}.csv';
    final file = File('${directory.path}/$filename');
    await file.writeAsString(buffer.toString());

    setState(() {
      _exportMessage = 'Exported ${sessions.length} session'
          '${sessions.length == 1 ? '' : 's'} to ${file.path}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analysis')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('From'),
                  subtitle: Text(_dateFormat.format(_fromDate)),
                  trailing: const Icon(Icons.edit_calendar),
                  onTap: _pickFromDate,
                ),
              ),
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('To'),
                  subtitle: Text(_dateFormat.format(_toDate)),
                  trailing: const Icon(Icons.edit_calendar),
                  onTap: _pickToDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<DashboardStats>(
            future: _statsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final stats = snapshot.data!;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sessions: ${stats.sessionCount}'),
                      const SizedBox(height: 8),
                      Text(
                        'Avg hits per session by group:',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      ...MuscleGroup.values.map((g) => Text(
                          '${muscleGroupLabel(g)}: ${stats.avgHitsPerSession[g]!.toStringAsFixed(1)} '
                          '(total ${stats.totalHits[g]})')),
                      const SizedBox(height: 8),
                      Text(
                        stats.avgCvDurationMinutes == null
                            ? 'Avg CV duration: no cardio logged'
                            : 'Avg CV duration: ${stats.avgCvDurationMinutes!.toStringAsFixed(1)} min '
                                '(${stats.cvSessionCount} session${stats.cvSessionCount == 1 ? '' : 's'})',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _exportCsv,
            icon: const Icon(Icons.download),
            label: const Text('Export to CSV'),
          ),
          if (_exportMessage != null) ...[
            const SizedBox(height: 12),
            Text(_exportMessage!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
