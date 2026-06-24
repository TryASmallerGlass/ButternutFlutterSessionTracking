import 'package:drift/drift.dart' show Value;
import 'package:intl/intl.dart';

import '../database/database.dart';
import '../models/dashboard_stats.dart' show muscleGroupLabel;
import '../utils/csv_codec.dart';

const csvHeaders = [
  'Date',
  'Time',
  'Front',
  'Back',
  'Legs',
  'Core',
  'CV Duration (min)',
  'CV Level',
  'Comment',
];

class ImportRowIssue {
  final int rowNumber;
  final String message;

  ImportRowIssue(this.rowNumber, this.message);
}

class ImportResult {
  final int importedCount;
  final List<ImportRowIssue> issues;
  final String? fatalError;

  ImportResult({
    required this.importedCount,
    required this.issues,
    this.fatalError,
  });

  bool get hasFatalError => fatalError != null;
}

final _dateFormat = DateFormat('yyyy-MM-dd');
final _timeFormat = DateFormat('HH:mm');

int? _parseNonNegativeInt(String raw) {
  if (raw.trim().isEmpty) return null;
  final value = int.tryParse(raw.trim());
  if (value == null || value < 0) return null;
  return value;
}

Future<ImportResult> importSessionsFromCsv(
    AppDatabase database, String content) async {
  final rows = parseCsv(content);
  if (rows.isEmpty) {
    return ImportResult(
      importedCount: 0,
      issues: const [],
      fatalError: 'The file is empty.',
    );
  }

  final header = rows.first.map((h) => h.trim()).toList();
  if (header.length != csvHeaders.length ||
      !List.generate(csvHeaders.length,
          (i) => header[i].toLowerCase() == csvHeaders[i].toLowerCase())
          .every((match) => match)) {
    return ImportResult(
      importedCount: 0,
      issues: const [],
      fatalError: 'Unrecognized CSV header. Expected columns: '
          '${csvHeaders.join(', ')}.',
    );
  }

  final issues = <ImportRowIssue>[];
  var importedCount = 0;

  for (var i = 1; i < rows.length; i++) {
    final rowNumber = i + 1; // 1-indexed, matching a spreadsheet's row count
    final row = rows[i];

    if (row.length != csvHeaders.length) {
      issues.add(ImportRowIssue(rowNumber,
          'Expected ${csvHeaders.length} columns, found ${row.length} — row skipped.'));
      continue;
    }

    final dateRaw = row[0].trim();
    final timeRaw = row[1].trim();
    DateTime date;
    DateTime time;
    try {
      date = _dateFormat.parseStrict(dateRaw);
    } catch (_) {
      issues.add(ImportRowIssue(
          rowNumber, "Invalid date '$dateRaw' (expected yyyy-MM-dd) — row skipped."));
      continue;
    }
    try {
      time = _timeFormat.parseStrict(timeRaw);
    } catch (_) {
      issues.add(ImportRowIssue(
          rowNumber, "Invalid time '$timeRaw' (expected HH:mm) — row skipped."));
      continue;
    }

    final groupCounts = <MuscleGroup, int>{};
    var groupParseFailed = false;
    for (var g = 0; g < MuscleGroup.values.length; g++) {
      final group = MuscleGroup.values[g];
      final raw = row[2 + g].trim();
      final value = raw.isEmpty ? 0 : _parseNonNegativeInt(raw);
      if (value == null) {
        issues.add(ImportRowIssue(rowNumber,
            "Invalid ${muscleGroupLabel(group)} count '$raw' (expected a non-negative whole number) — row skipped."));
        groupParseFailed = true;
        break;
      }
      groupCounts[group] = value;
    }
    if (groupParseFailed) continue;

    final cvDurationRaw = row[6].trim();
    final cvDuration =
        cvDurationRaw.isEmpty ? null : _parseNonNegativeInt(cvDurationRaw);
    if (cvDurationRaw.isNotEmpty && cvDuration == null) {
      issues.add(ImportRowIssue(rowNumber,
          "Invalid CV Duration '$cvDurationRaw' (expected a non-negative whole number) — row skipped."));
      continue;
    }

    final cvLevelRaw = row[7].trim();
    int? cvLevel;
    if (cvLevelRaw.isNotEmpty) {
      cvLevel = int.tryParse(cvLevelRaw);
      if (cvLevel == null || cvLevel < 1 || cvLevel > 20) {
        issues.add(ImportRowIssue(rowNumber,
            "Invalid CV Level '$cvLevelRaw' (expected a whole number from 1 to 20) — row skipped."));
        continue;
      }
    }

    final comment = row[8];

    if (groupCounts.values.every((c) => c == 0)) {
      issues.add(ImportRowIssue(
          rowNumber, 'No muscle group hits recorded — row imported anyway.'));
    }

    final sessionDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    final id = await database.insertSession(
      SessionsCompanion.insert(
        sessionDateTime: sessionDateTime,
        cvDurationMinutes: Value(cvDuration),
        cvLevel: Value(cvLevel),
        comment: comment,
      ),
    );
    await database.insertMuscleGroups(id, groupCounts);
    importedCount++;
  }

  return ImportResult(importedCount: importedCount, issues: issues);
}
