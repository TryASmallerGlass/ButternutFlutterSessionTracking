import '../database/database.dart';

class DashboardStats {
  final int sessionCount;
  final Map<MuscleGroup, double> avgHitsPerSession;
  final Map<MuscleGroup, int> totalHits;
  final int totalCvDurationMinutes;
  final int cvSessionCount;

  DashboardStats({
    required this.sessionCount,
    required this.avgHitsPerSession,
    required this.totalHits,
    required this.totalCvDurationMinutes,
    required this.cvSessionCount,
  });

  static Future<DashboardStats> compute(
      AppDatabase database, List<Session> sessions) async {
    final sessionIds = sessions.map((s) => s.id).toList();
    final groups = await database.groupsForSessionIds(sessionIds);

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
    final totalCv = cvSessions.isEmpty
        ? 0
        : cvSessions.map((s) => s.cvDurationMinutes!).reduce((a, b) => a + b);

    return DashboardStats(
      sessionCount: sessionCount,
      avgHitsPerSession: avgHitsPerSession,
      totalHits: {for (final group in MuscleGroup.values) group: hitTotals[group] ?? 0},
      totalCvDurationMinutes: totalCv,
      cvSessionCount: cvSessions.length,
    );
  }
}

String muscleGroupLabel(MuscleGroup group) {
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
