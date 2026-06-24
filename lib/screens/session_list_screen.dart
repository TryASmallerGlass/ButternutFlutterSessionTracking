import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database.dart';
import '../widgets/dashboard_summary.dart';
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
  int _dashboardRefreshToken = 0;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _sessionsFuture = widget.database.allSessions();
    _dashboardRefreshToken++;
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

  Future<bool> _confirmDelete(Session session) async {
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
    if (confirmed != true) return false;
    await widget.database.deleteSession(session.id);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset('assets/icon/source_logo.png'),
        ),
        title: const Text('Workout Sessions'),
      ),
      body: Column(
        children: [
          DashboardSummary(
            database: widget.database,
            refreshToken: _dashboardRefreshToken,
            onDataChanged: () => setState(_refresh),
          ),
          Expanded(
            child: FutureBuilder<List<Session>>(
              future: _sessionsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final sessions = snapshot.data!;
                if (sessions.isEmpty) {
                  return const Center(
                      child: Text('No sessions yet. Tap + to add one.'));
                }
                return ListView.builder(
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    final dateLabel = DateFormat('EEE d MMM yyyy, HH:mm')
                        .format(session.sessionDateTime);
                    return Dismissible(
                      key: ValueKey(session.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Theme.of(context).colorScheme.error,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) => _confirmDelete(session),
                      onDismissed: (_) => setState(_refresh),
                      child: ListTile(
                        title: Text(dateLabel),
                        subtitle: session.comment.isNotEmpty
                            ? Text(session.comment)
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            if (await _confirmDelete(session)) {
                              setState(_refresh);
                            }
                          },
                        ),
                        onTap: () => _openDetail(session),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
