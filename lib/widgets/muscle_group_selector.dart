import 'package:flutter/material.dart';

import '../database/database.dart';

class MuscleGroupSelector extends StatelessWidget {
  final Set<MuscleGroup> selected;
  final ValueChanged<Set<MuscleGroup>> onChanged;

  const MuscleGroupSelector({
    super.key,
    required this.selected,
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

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: MuscleGroup.values.map((group) {
        final isSelected = selected.contains(group);
        return FilterChip(
          label: Text(_label(group)),
          selected: isSelected,
          onSelected: (value) {
            final updated = Set<MuscleGroup>.from(selected);
            if (value) {
              updated.add(group);
            } else {
              updated.remove(group);
            }
            onChanged(updated);
          },
        );
      }).toList(),
    );
  }
}
