// lib/screens/staff/pause_queue_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';

class PauseQueueScreen extends StatefulWidget {
  const PauseQueueScreen({super.key});

  @override
  State<PauseQueueScreen> createState() => _PauseQueueScreenState();
}

class _PauseQueueScreenState extends State<PauseQueueScreen> {
  int _selectedDuration = 5; // minutes
  String? _selectedReason;
  final List<String> _reasons = [
    'Break time',
    'Technical issue',
    'Meeting',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pause Queue'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Pause Duration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [5, 10, 15, 30].map((mins) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('$mins min'),
                      selected: _selectedDuration == mins,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedDuration = mins);
                        }
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Reason for Pause',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._reasons.map((reason) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RadioListTile<String>(
                title: Text(reason),
                value: reason,
                groupValue: _selectedReason,
                onChanged: (value) {
                  setState(() => _selectedReason = value);
                },
              ),
            )),
            const Spacer(),
            CustomButton(
              text: 'Pause Queue',
              onPressed: _selectedReason != null
                  ? () {
                      // Handle pause logic
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Queue paused for $_selectedDuration minutes: $_selectedReason',
                          ),
                        ),
                      );
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}