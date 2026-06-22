import 'package:flutter/material.dart';

class CvInput extends StatelessWidget {
  final bool enabled;
  final int? durationMinutes;
  final int? level;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<int?> onDurationChanged;
  final ValueChanged<int?> onLevelChanged;

  const CvInput({
    super.key,
    required this.enabled,
    required this.durationMinutes,
    required this.level,
    required this.onEnabledChanged,
    required this.onDurationChanged,
    required this.onLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Include cardio (CV)'),
          value: enabled,
          onChanged: onEnabledChanged,
        ),
        if (enabled) ...[
          TextFormField(
            initialValue: durationMinutes?.toString() ?? '',
            decoration: const InputDecoration(labelText: 'Duration (minutes)'),
            keyboardType: TextInputType.number,
            onChanged: (value) => onDurationChanged(int.tryParse(value)),
          ),
          const SizedBox(height: 12),
          Text('Level: ${level ?? 1}'),
          Slider(
            value: (level ?? 1).toDouble(),
            min: 1,
            max: 20,
            divisions: 19,
            label: '${level ?? 1}',
            onChanged: (value) => onLevelChanged(value.round()),
          ),
        ],
      ],
    );
  }
}
