import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database.dart';
import 'session_detail_screen.dart';
import 'session_form_screen.dart';

class SessionListScreen extends StatefulWidget {
  final AppDatabase database;

  const SessionListScreen({super.key, required this.database});

  @override
  State<SessionListScreen> createState() => _SessionListScreenState();
}

class _SessionListScreenState extends State<SessionListScreen> {
  late Future<List<Session>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _sessionsFuture = widget.database.allSessions();
  }

  Future<void> _openForm() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SessionFormScreen(database: widget.database),
      ),
    );
    setState(_refresh);
  }

  Future<void> _openDetail(Session session) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SessionDetailScreen(
          database: widget.database,
          session: session,
        ),
      ),
    );
    setState(_refresh);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Sessions')),
      body: FutureBuilder<List<Session>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final sessions = snapshot.data!;
          if (sessions.isEmpty) {
            return const Center(child: Text('No sessions yet. Tap + to add one.'));
          }
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final dateLabel =
                  DateFormat('EEE d MMM yyyy, HH:mm').format(session.sessionDateTime);
              return ListTile(
                title: Text(dateLabel),
                subtitle: session.comment.isNotEmpty ? Text(session.comment) : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openDetail(session),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
