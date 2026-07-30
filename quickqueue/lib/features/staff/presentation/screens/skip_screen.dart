import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';
import '../bloc/staff_state.dart';
import '../widgets/staff_colors.dart';
import '../widgets/staff_header.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SkipScreen extends StatelessWidget {
  const SkipScreen({
    super.key,
    required this.ticketId,
    required this.queueId,
    this.staffBloc,
  });

  final String ticketId;
  final String queueId;

  /// Injectable for tests; defaults to a real Firestore-backed bloc.
  final StaffBloc? staffBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => staffBloc ?? StaffBloc(firestore: FirebaseFirestore.instance),
      child: _SkipView(ticketId: ticketId, queueId: queueId),
    );
  }
}

class _SkipView extends StatefulWidget {
  const _SkipView({required this.ticketId, required this.queueId});

  final String ticketId;
  final String queueId;

  @override
  State<_SkipView> createState() => _SkipViewState();
}

class _SkipViewState extends State<_SkipView> {
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

  void _confirmSkip() {
    if (_selectedReason == null) return;
    context.read<StaffBloc>().add(SkipPatientEvent(
          ticketId: widget.ticketId,
          queueId: widget.queueId,
          reason: _selectedReason!,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffBloc, StaffState>(
      listener: (context, state) {
        if (state is PatientSkippedSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Patient skipped: $_selectedReason')),
          );
        } else if (state is StaffError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state is StaffLoading;
        return Scaffold(
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
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: StaffColors.danger, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'This patient did not respond after being called.',
                              style: TextStyle(
                                  color: StaffColors.textPrimary,
                                  fontSize: 13,
                                  height: 1.4),
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
                            onTap: () =>
                                setState(() => _selectedReason = reason),
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
                      text: isSubmitting ? 'Confirming...' : 'Confirm skip',
                      onPressed:
                          (_selectedReason == null || isSubmitting)
                              ? null
                              : _confirmSkip,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
