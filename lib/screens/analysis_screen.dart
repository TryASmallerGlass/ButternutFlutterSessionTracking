import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../database/database.dart';
import '../models/dashboard_stats.dart';
import '../services/csv_import.dart';
import '../utils/csv_codec.dart';

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
  File? _lastExportedFile;
  bool _dataChanged = false;

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
    final buffer = StringBuffer()..writeln(headers.map(csvEscape).join(','));

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
      buffer.writeln(row.map(csvEscape).join(','));
    }

    final directory =
        await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    final filename = 'workout_sessions_'
        '${DateFormat('yyyyMMdd').format(_fromDate)}_'
        '${DateFormat('yyyyMMdd').format(_toDate)}.csv';
    final file = File('${directory.path}/$filename');
    await file.writeAsString(buffer.toString());

    setState(() {
      _lastExportedFile = file;
      _exportMessage = 'Exported ${sessions.length} session'
          '${sessions.length == 1 ? '' : 's'} to ${file.path}';
    });
  }

  Future<void> _shareCsv() async {
    final file = _lastExportedFile;
    if (file == null) return;
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Workout sessions export',
    );
  }

  Future<void> _importCsv() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final content = await file.readAsString();
    final importResult = await importSessionsFromCsv(widget.database, content);

    if (!mounted) return;

    if (importResult.hasFatalError) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import failed'),
          content: Text(importResult.fatalError!),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (importResult.importedCount > 0) {
      _dataChanged = true;
      setState(_loadData);
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import complete'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Imported ${importResult.importedCount} session'
                  '${importResult.importedCount == 1 ? '' : 's'}.'),
              if (importResult.issues.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Warnings:', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: ListView(
                    shrinkWrap: true,
                    children: importResult.issues
                        .map((issue) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                'Row ${issue.rowNumber}: ${issue.message}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_dataChanged);
      },
      child: Scaffold(
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
                          stats.cvSessionCount == 0
                              ? 'Total CV time: no cardio logged'
                              : 'Total CV time: ${stats.totalCvDurationMinutes} min '
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
            if (_lastExportedFile != null) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _shareCsv,
                icon: const Icon(Icons.share),
                label: const Text('Share / Save to Drive'),
              ),
            ],
            if (_exportMessage != null) ...[
              const SizedBox(height: 12),
              Text(_exportMessage!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const Divider(height: 32),
            OutlinedButton.icon(
              onPressed: _importCsv,
              icon: const Icon(Icons.upload),
              label: const Text('Import from CSV'),
            ),
          ],
        ),
      ),
    );
  }
}
