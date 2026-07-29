// lib/screens/staff/skip_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';

class SkipScreen extends StatefulWidget {
  const SkipScreen({super.key});

  @override
  State<SkipScreen> createState() => _SkipScreenState();
}

class _SkipScreenState extends State<SkipScreen> {
  String? _selectedReason;
  final List<String> _reasons = [
    'Customer not present',
    'Customer requested to skip',
    'Duplicate ticket',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skip Customer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Why are you skipping this customer?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
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
              text: 'Confirm Skip',
              onPressed: _selectedReason != null
                  ? () {
                      // Handle skip logic
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Customer skipped: $_selectedReason')),
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