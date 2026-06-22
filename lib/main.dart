import 'package:flutter/material.dart';

import 'database/database.dart';
import 'screens/session_list_screen.dart';

void main() {
  runApp(const MuscleTrackerApp());
}

class MuscleTrackerApp extends StatefulWidget {
  const MuscleTrackerApp({super.key});

  @override
  State<MuscleTrackerApp> createState() => _MuscleTrackerAppState();
}

class _MuscleTrackerAppState extends State<MuscleTrackerApp> {
  final AppDatabase _database = AppDatabase();

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muscle Group Tracker',
      theme: ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
      home: SessionListScreen(database: _database),
    );
  }
}
