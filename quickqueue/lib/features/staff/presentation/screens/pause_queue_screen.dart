import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';
import '../bloc/staff_state.dart';
import '../widgets/staff_colors.dart';
import '../widgets/staff_header.dart';
import '../../widgets/custom_button.dart';

class PauseQueueScreen extends StatelessWidget {
  const PauseQueueScreen({super.key, required this.queueId, this.staffBloc});

  final String queueId;

  /// Injectable for tests; defaults to a real Firestore-backed bloc.
  final StaffBloc? staffBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => staffBloc ?? StaffBloc(firestore: FirebaseFirestore.instance),
      child: _PauseQueueView(queueId: queueId),
    );
  }
}

class _PauseQueueView extends StatefulWidget {
  const _PauseQueueView({required this.queueId});

  final String queueId;

  @override
  State<_PauseQueueView> createState() => _PauseQueueViewState();
}

class _PauseQueueViewState extends State<_PauseQueueView> {
  bool _counterOpen = true;
  String? _selectedBreak;
  final int _waitingCount = 12;

  final List<_BreakOption> _breaks = const [
    _BreakOption('Lunch break (1hr)', 'Queue paused, patients notified'),
    _BreakOption('Short break (10 min)', null),
    _BreakOption('End of day', null),
  ];

  void _toggleCounter(bool open) {
    setState(() => _counterOpen = open);
    final bloc = context.read<StaffBloc>();
    if (open) {
      bloc.add(ResumeQueueEvent(queueId: widget.queueId));
    } else {
      bloc.add(PauseQueueEvent(
        queueId: widget.queueId,
        reason: 'Counter closed',
      ));
    }
  }

  void _pauseQueue() {
    if (_selectedBreak == null) return;
    context.read<StaffBloc>().add(PauseQueueEvent(
          queueId: widget.queueId,
          reason: _selectedBreak!,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffBloc, StaffState>(
      listener: (context, state) {
        if (state is QueuePausedSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Queue paused: $_selectedBreak')),
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
                            onChanged: isSubmitting ? null : _toggleCounter,
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
                      text: isSubmitting ? 'Pausing...' : 'Pause queue',
                      outlined: true,
                      onPressed: (_selectedBreak == null || isSubmitting)
                          ? null
                          : _pauseQueue,
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
        );
      },
    );
  }
}

class _BreakOption {
  const _BreakOption(this.title, this.subtitle);
  final String title;
  final String? subtitle;
}
