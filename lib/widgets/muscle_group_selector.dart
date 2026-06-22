import 'package:flutter/material.dart';

import '../database/database.dart';

class MuscleGroupSelector extends StatelessWidget {
  final Map<MuscleGroup, int> counts;
  final ValueChanged<Map<MuscleGroup, int>> onChanged;

  const MuscleGroupSelector({
    super.key,
    required this.counts,
    required this.onChanged,
  });

  String _label(MuscleGroup group) {
    switch (group) {
      case MuscleGroup.front:
        return 'Front (chest/shoulders/triceps)';
      case MuscleGroup.back:
        return 'Back (incl. biceps)';
      case MuscleGroup.legs:
        return 'Legs';
      case MuscleGroup.core:
        return 'Core (abs/lower back/glutes)';
    }
  }

  void _setCount(MuscleGroup group, int value) {
    final updated = Map<MuscleGroup, int>.from(counts);
    updated[group] = value < 0 ? 0 : value;
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: MuscleGroup.values.map((group) {
        final count = counts[group] ?? 0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(child: Text(_label(group))),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: count > 0
                    ? () => _setCount(group, count - 1)
                    : null,
              ),
              SizedBox(
                width: 28,
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => _setCount(group, count + 1),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
