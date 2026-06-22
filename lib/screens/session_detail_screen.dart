import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database.dart';
import 'session_form_screen.dart';

class SessionDetailScreen extends StatefulWidget {
  final AppDatabase database;
  final Session session;

  const SessionDetailScreen({
    super.key,
    required this.database,
    required this.session,
  });

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  late Future<List<SessionMuscleGroup>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _groupsFuture = widget.database.groupsForSession(widget.session.id);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete session?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.database.deleteSession(widget.session.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final dateLabel = DateFormat('EEE d MMM yyyy, HH:mm').format(session.sessionDateTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final groups = await _groupsFuture;
              if (!mounted) return;
              await navigator.push(
                MaterialPageRoute(
                  builder: (context) => SessionFormScreen(
                    database: widget.database,
                    existingSession: session,
                    existingGroupCounts: {
                      for (final g in groups)
                        MuscleGroup.values
                                .firstWhere((m) => m.name == g.muscleGroup):
                            g.hitCount,
                    },
                  ),
                ),
              );
              if (mounted) navigator.pop();
            },
          ),
          IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
      ),
      body: FutureBuilder<List<SessionMuscleGroup>>(
        future: _groupsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final groups = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(dateLabel, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              const Text('Muscle groups', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: groups
                    .map((g) => Chip(label: Text('${g.muscleGroup} x${g.hitCount}')))
                    .toList(),
              ),
              const SizedBox(height: 16),
              if (session.cvDurationMinutes != null || session.cvLevel != null) ...[
                const Text('Cardio', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${session.cvDurationMinutes ?? '-'} min, level ${session.cvLevel ?? '-'}/20',
                ),
                const SizedBox(height: 16),
              ],
              if (session.comment.isNotEmpty) ...[
                const Text('Comment', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(session.comment),
              ],
            ],
          );
        },
      ),
    );
  }
}
