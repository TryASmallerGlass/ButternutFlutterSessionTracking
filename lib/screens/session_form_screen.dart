import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../database/database.dart';
import '../widgets/cv_input.dart';
import '../widgets/muscle_group_selector.dart';

class SessionFormScreen extends StatefulWidget {
  final AppDatabase database;
  final Session? existingSession;
  final Set<MuscleGroup> existingGroups;

  const SessionFormScreen({
    super.key,
    required this.database,
    this.existingSession,
    this.existingGroups = const {},
  });

  @override
  State<SessionFormScreen> createState() => _SessionFormScreenState();
}

class _SessionFormScreenState extends State<SessionFormScreen> {
  late DateTime _dateTime;
  late Set<MuscleGroup> _selectedGroups;
  late TextEditingController _commentController;
  bool _cvEnabled = false;
  int? _cvDuration;
  int? _cvLevel = 10;

  bool get _isEditing => widget.existingSession != null;

  @override
  void initState() {
    super.initState();
    final session = widget.existingSession;
    _dateTime = session?.sessionDateTime ?? DateTime.now();
    _selectedGroups = Set<MuscleGroup>.from(widget.existingGroups);
    _commentController = TextEditingController(text: session?.comment ?? '');
    _cvEnabled = session?.cvDurationMinutes != null || session?.cvLevel != null;
    _cvDuration = session?.cvDurationMinutes;
    _cvLevel = session?.cvLevel ?? 10;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (time == null) return;
    setState(() {
      _dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    if (_selectedGroups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one muscle group')),
      );
      return;
    }

    final groups = _selectedGroups.toList();

    if (_isEditing) {
      final updated = widget.existingSession!.copyWith(
        sessionDateTime: _dateTime,
        cvDurationMinutes: Value(_cvEnabled ? _cvDuration : null),
        cvLevel: Value(_cvEnabled ? _cvLevel : null),
        comment: _commentController.text,
      );
      await widget.database.updateSession(updated, groups);
    } else {
      final id = await widget.database.insertSession(
        SessionsCompanion.insert(
          sessionDateTime: _dateTime,
          cvDurationMinutes: Value(_cvEnabled ? _cvDuration : null),
          cvLevel: Value(_cvEnabled ? _cvLevel : null),
          comment: _commentController.text,
        ),
      );
      await widget.database.insertMuscleGroups(id, groups);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Session' : 'New Session'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date & time'),
            subtitle: Text(_dateTime.toString()),
            trailing: const Icon(Icons.edit_calendar),
            onTap: _pickDateTime,
          ),
          const SizedBox(height: 16),
          const Text('Muscle groups hit', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          MuscleGroupSelector(
            selected: _selectedGroups,
            onChanged: (value) => setState(() => _selectedGroups = value),
          ),
          const SizedBox(height: 16),
          CvInput(
            enabled: _cvEnabled,
            durationMinutes: _cvDuration,
            level: _cvLevel,
            onEnabledChanged: (value) => setState(() => _cvEnabled = value),
            onDurationChanged: (value) => setState(() => _cvDuration = value),
            onLevelChanged: (value) => setState(() => _cvLevel = value),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Comments',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
        ],
      ),
    );
  }
}
