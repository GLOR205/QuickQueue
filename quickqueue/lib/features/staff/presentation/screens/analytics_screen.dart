import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';
import '../bloc/staff_state.dart';
import '../widgets/staff_colors.dart';
import '../widgets/staff_header.dart';
import '../../widgets/custom_button.dart';
import 'staff_profile_screen.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({
    super.key,
    required this.queueId,
    this.staffBloc,
    this.firestore,
  });

  final String queueId;

  /// Injectable for tests; default to real Firebase-backed instances.
  final StaffBloc? staffBloc;
  final FirebaseFirestore? firestore;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => staffBloc ?? StaffBloc(firestore: FirebaseFirestore.instance),
      child: _AnalyticsView(
        queueId: queueId,
        firestore: firestore ?? FirebaseFirestore.instance,
      ),
    );
  }
}

class _AnalyticsView extends StatefulWidget {
  const _AnalyticsView({required this.queueId, required this.firestore});

  final String queueId;
  final FirebaseFirestore firestore;

  @override
  State<_AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<_AnalyticsView> {
  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    // Analytics is tracked per location/service in Firestore, but a staff
    // counter only knows its queueId, so resolve the queue document first.
    final queueDoc =
        await widget.firestore.collection('queues').doc(widget.queueId).get();
    final data = queueDoc.data();
    if (!mounted) return;
    context.read<StaffBloc>().add(LoadAnalyticsEvent(
          locationId: data?['locationId'] as String? ?? '',
          serviceId: data?['serviceId'] as String? ?? '',
        ));
  }

  void _onNavTap(int index) {
    if (index == 0) {
      Navigator.pop(context);
    } else if (index == 2) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => StaffProfileScreen(queueId: widget.queueId)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StaffBloc, StaffState>(
      builder: (context, state) {
        final isLoading = state is StaffInitial || state is StaffLoading;
        final analytics = state is AnalyticsLoaded ? state : null;
        final errorMessage = state is StaffError ? state.message : null;

        final hourly = <(String, int)>[];
        if (analytics != null) {
          final hours = analytics.hourlyData.keys.toList()
            ..sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));
          for (final hour in hours) {
            final count = analytics.hourlyData[hour];
            hourly.add(('$hour:00', count is num ? count.toInt() : 0));
          }
        }
        final maxCount = hourly.isEmpty
            ? 1
            : hourly.map((e) => e.$2).reduce((a, b) => a > b ? a : b).clamp(1, 1 << 30);

        return Scaffold(
          backgroundColor: StaffColors.background,
          body: Column(
            children: [
              StaffHeader(
                title: "Today's summary",
                subtitle: 'Counter C2',
                onBack: () => Navigator.pop(context),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                        ? Center(
                            child: Text(errorMessage,
                                style: const TextStyle(
                                    color: StaffColors.danger)))
                        : ListView(
                            padding: const EdgeInsets.all(20),
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _StatTile(
                                        label: 'Total served',
                                        value: '${analytics?.totalServed ?? 0}',
                                        color: StaffColors.success),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _StatTile(
                                        label: 'Skipped',
                                        value: '${analytics?.totalSkipped ?? 0}',
                                        color: StaffColors.danger),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                      child: _StatTile(
                                          label: 'Avg wait (min)',
                                          value:
                                              '${analytics?.avgWaitTime.round() ?? 0}')),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: _StatTile(
                                          label: 'Peak hour',
                                          value: analytics?.peakHour ?? 'N/A')),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Patients served per hour',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: StaffColors.textPrimary),
                              ),
                              const SizedBox(height: 14),
                              if (hourly.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text('No hourly data yet',
                                      style: TextStyle(
                                          color: StaffColors.textMuted)),
                                )
                              else
                                ...hourly.map((entry) {
                                  final (label, count) = entry;
                                  final fraction = count / maxCount;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                            width: 76,
                                            child: Text(label,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: StaffColors
                                                        .textSecondary))),
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            child: LinearProgressIndicator(
                                              value: fraction,
                                              minHeight: 14,
                                              backgroundColor:
                                                  StaffColors.background,
                                              valueColor:
                                                  const AlwaysStoppedAnimation(
                                                      StaffColors.primary),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          width: 20,
                                          child: Text('$count',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight.w600)),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              const SizedBox(height: 20),
                              CustomButton(
                                text: 'Export report',
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Report exported')),
                                  );
                                },
                              ),
                            ],
                          ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 1,
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

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

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
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color ?? StaffColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
