import 'package:flutter/material.dart';

import '../widgets/staff_colors.dart';
import '../widgets/staff_header.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SkipScreen extends StatefulWidget {
  const SkipScreen({super.key, required this.ticketNumber});

  final String ticketNumber;

  @override
  State<SkipScreen> createState() => _SkipScreenState();
}

class _SkipScreenState extends State<SkipScreen> {
  String? _selectedReason;
  final _counterController =
      TextEditingController(text: 'Counter C3 - General consultation');
  final List<String> _reasons = [
    'Patient not present',
    'Patient requested delay',
    'Wrong service selected',
  ];

  @override
  void dispose() {
    _counterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: StaffColors.themeData,
      child: Scaffold(
        backgroundColor: StaffColors.background,
        body: Column(
          children: [
            StaffHeader(title: 'Skip', onBack: () => Navigator.pop(context)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: StaffColors.dangerLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: StaffColors.danger.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: StaffColors.danger, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  color: StaffColors.textPrimary,
                                  fontSize: 13,
                                  height: 1.4),
                              children: [
                                const TextSpan(
                                    text: 'Alert\n',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text:
                                        'Patient ${widget.ticketNumber} did not respond after being called.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Reason for skip',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: StaffColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  ..._reasons.map((reason) {
                    final selected = _selectedReason == reason;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: selected
                            ? StaffColors.primaryLight
                            : StaffColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => setState(() => _selectedReason = reason),
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
                            child: Text(
                              reason,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? StaffColors.primary
                                    : StaffColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _counterController,
                    label: 'Transfer to counter',
                    icon: Icons.meeting_room_outlined,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Confirm skip',
                    onPressed: _selectedReason == null
                        ? null
                        : () {
                            Navigator.pop(context, true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Patient skipped: $_selectedReason')),
                            );
                          },
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
