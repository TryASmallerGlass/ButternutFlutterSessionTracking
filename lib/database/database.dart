import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

enum MuscleGroup { front, back, legs, core }

class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get sessionDateTime => dateTime()();
  IntColumn get cvDurationMinutes => integer().nullable()();
  IntColumn get cvLevel => integer().nullable()();
  TextColumn get comment => text()();
}

class SessionMuscleGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer()();
  TextColumn get muscleGroup => text()();
  IntColumn get hitCount => integer().withDefault(const Constant(1))();
}

@DriftDatabase(tables: [Sessions, SessionMuscleGroups])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<Session>> allSessions() =>
      (select(sessions)
            ..orderBy([(s) => OrderingTerm.desc(s.sessionDateTime)]))
          .get();

  Future<List<SessionMuscleGroup>> groupsForSession(int sessionId) =>
      (select(sessionMuscleGroups)
            ..where((g) => g.sessionId.equals(sessionId)))
          .get();

  Future<int> insertSession(SessionsCompanion session) =>
      into(sessions).insert(session);

  Future<void> insertMuscleGroups(
      int sessionId, Map<MuscleGroup, int> groupCounts) {
    final entries = groupCounts.entries.where((e) => e.value > 0);
    return batch((batch) {
      batch.insertAll(
        sessionMuscleGroups,
        entries
            .map((e) => SessionMuscleGroupsCompanion.insert(
                  sessionId: sessionId,
                  muscleGroup: e.key.name,
                  hitCount: Value(e.value),
                ))
            .toList(),
      );
    });
  }

  Future<void> updateSession(
      Session session, Map<MuscleGroup, int> groupCounts) async {
    await update(sessions).replace(session);
    await (delete(sessionMuscleGroups)
          ..where((g) => g.sessionId.equals(session.id)))
        .go();
    await insertMuscleGroups(session.id, groupCounts);
  }

  Future<void> deleteSession(int sessionId) async {
    await (delete(sessionMuscleGroups)
          ..where((g) => g.sessionId.equals(sessionId)))
        .go();
    await (delete(sessions)..where((s) => s.id.equals(sessionId))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'session_tracking.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
