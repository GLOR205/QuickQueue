import 'package:flutter/material.dart';

import '../widgets/staff_colors.dart';
import '../widgets/staff_header.dart';
import '../../widgets/custom_button.dart';

class PauseQueueScreen extends StatefulWidget {
  const PauseQueueScreen({super.key});

  @override
  State<PauseQueueScreen> createState() => _PauseQueueScreenState();
}

class _PauseQueueScreenState extends State<PauseQueueScreen> {
  bool _counterOpen = true;
  String? _selectedBreak;
  final int _waitingCount = 12;

  final List<_BreakOption> _breaks = const [
    _BreakOption('Lunch break (1hr)', 'Queue paused, patients notified'),
    _BreakOption('Short break (10 min)', null),
    _BreakOption('End of day', null),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: StaffColors.themeData,
      child: Scaffold(
        backgroundColor: StaffColors.background,
        body: Column(
          children: [
            StaffHeader(
              title: 'Queue control',
              subtitle: 'Manage your counter status',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: StaffColors.successLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: StaffColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _counterOpen
                                    ? 'Counter is open'
                                    : 'Counter is closed',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: StaffColors.success),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _counterOpen
                                    ? 'Accepting patients now'
                                    : 'Not accepting patients',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: StaffColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _counterOpen,
                          activeThumbColor: StaffColors.success,
                          onChanged: (value) =>
                              setState(() => _counterOpen = value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Break options',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: StaffColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  ..._breaks.map((option) {
                    final selected = _selectedBreak == option.title;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: selected
                            ? StaffColors.primaryLight
                            : StaffColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () =>
                              setState(() => _selectedBreak = option.title),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? StaffColors.primary
                                    : StaffColors.border,
                                width: selected ? 1.4 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? StaffColors.primary
                                        : StaffColors.textPrimary,
                                  ),
                                ),
                                if (option.subtitle != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    option.subtitle!,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: StaffColors.textMuted),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Pause queue',
                    outlined: true,
                    onPressed: _selectedBreak == null
                        ? null
                        : () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Queue paused: $_selectedBreak')),
                            );
                          },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: StaffColors.warningLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$_waitingCount patients are currently waiting. They will be notified automatically.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 12, color: StaffColors.warning),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakOption {
  const _BreakOption(this.title, this.subtitle);
  final String title;
  final String? subtitle;
}
