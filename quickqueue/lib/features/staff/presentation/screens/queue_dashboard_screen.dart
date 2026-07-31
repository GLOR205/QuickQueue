import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';
import '../bloc/staff_state.dart';
import '../widgets/staff_colors.dart';
import '../../widgets/queue_card.dart';
import 'analytics_screen.dart';
import 'skip_screen.dart';
import 'staff_profile_screen.dart';

class QueueDashboardScreen extends StatelessWidget {
  const QueueDashboardScreen({super.key, required this.queueId, this.staffBloc});

  final String queueId;

  /// Injectable for tests; defaults to a real Firestore-backed bloc.
  final StaffBloc? staffBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => staffBloc ?? StaffBloc(firestore: FirebaseFirestore.instance),
      child: _QueueDashboardView(queueId: queueId),
    );
  }
}

class _QueueDashboardView extends StatefulWidget {
  const _QueueDashboardView({required this.queueId});

  final String queueId;

  @override
  State<_QueueDashboardView> createState() => _QueueDashboardViewState();
}

class _QueueDashboardViewState extends State<_QueueDashboardView> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    context
        .read<StaffBloc>()
        .add(LoadQueueDashboardEvent(queueId: widget.queueId));
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    if (index == 1) {
      Navigator.of(context)
          .push(MaterialPageRoute(
              builder: (_) => AnalyticsScreen(queueId: widget.queueId)))
          .then((_) => setState(() => _currentIndex = 0));
    } else if (index == 2) {
      Navigator.of(context)
          .push(MaterialPageRoute(
              builder: (_) => StaffProfileScreen(queueId: widget.queueId)))
          .then((_) => setState(() => _currentIndex = 0));
    }
  }

  void _markServed(String ticketId) {
    context.read<StaffBloc>().add(MarkServedEvent(
          ticketId: ticketId,
          queueId: widget.queueId,
        ));
  }

  Future<void> _skip(String ticketId) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SkipScreen(ticketId: ticketId, queueId: widget.queueId),
    ));
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffBloc, StaffState>(
      listener: (context, state) {
        if (state is StaffError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is PatientServedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Patient marked as served')),
          );
          _reload();
        }
      },
      builder: (context, state) {
        final queueList =
            state is QueueDashboardLoaded ? state.queueList : const [];
        final servedToday = state is QueueDashboardLoaded
            ? state.totalServed
            : 0;
        final isLoading = state is StaffLoading;

        return Scaffold(
          backgroundColor: StaffColors.background,
          body: Column(
            children: [
              _DashboardHeader(waiting: queueList.length, served: servedToday),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _StatTile(
                                    label: 'Waiting now',
                                    value: '${queueList.length}'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: _StatTile(
                                      label: 'Served today',
                                      value: '$servedToday')),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Queue list',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: StaffColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (queueList.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text('Queue is empty',
                                    style:
                                        TextStyle(color: StaffColors.textMuted)),
                              ),
                            )
                          else
                            ...List.generate(
                              queueList.length,
                              (index) {
                                final ticket = queueList[index];
                                return QueueCard(
                                  customer: '${ticket['ticketNumber'] ?? ''}',
                                  position: index + 1,
                                  onTap: () {},
                                );
                              },
                            ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: queueList.isEmpty
                                        ? null
                                        : () => _markServed(
                                            queueList.first['ticketId']
                                                as String),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: StaffColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Text('Mark Served',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 52,
                                  child: OutlinedButton(
                                    onPressed: queueList.isEmpty
                                        ? null
                                        : () => _skip(queueList.first['ticketId']
                                            as String),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: StaffColors.primary,
                                      side: const BorderSide(
                                          color: StaffColors.primary),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Text('Skip',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onNavTap,
            selectedItemColor: StaffColors.primary,
            unselectedItemColor: StaffColors.textMuted,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.list_alt_outlined), label: 'Queue'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_outlined), label: 'Stats'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.waiting, required this.served});

  final int waiting;
  final int served;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: StaffColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: const Text('S1',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Room R2',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Staff-1 · General consult',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.notifications_none, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StaffColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: StaffColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 12, color: StaffColors.textMuted)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: StaffColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
