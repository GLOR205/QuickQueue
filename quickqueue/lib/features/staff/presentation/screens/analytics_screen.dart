import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/entities/staff_ticket_record.dart';
import '../../domain/usecases/get_queue_ticket_history.dart';
import '../widgets/staff_colors.dart';
import '../widgets/staff_header.dart';
import '../../widgets/custom_button.dart';
import 'staff_profile_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key, required this.staff});

  final StaffEntity staff;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _loading = true;
  List<StaffTicketRecord> _todayRecords = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final history = await sl<GetQueueTicketHistory>()(widget.staff.queueId);
    if (!mounted) return;
    final now = DateTime.now();
    setState(() {
      _todayRecords = history.where((r) {
        final time = r.createdAt;
        return time != null &&
            time.year == now.year &&
            time.month == now.month &&
            time.day == now.day;
      }).toList();
      _loading = false;
    });
  }

  void _onNavTap(int index) {
    if (index == 0) {
      Navigator.pop(context);
    } else if (index == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => StaffProfileScreen(staff: widget.staff)),
      );
    }
  }

  String _hourRangeLabel(int hour) {
    final endHour = (hour + 1) % 24;
    final startPeriod = hour < 12 ? 'AM' : 'PM';
    final endPeriod = endHour < 12 ? 'AM' : 'PM';
    final startDisplay = hour % 12 == 0 ? 12 : hour % 12;
    final endDisplay = endHour % 12 == 0 ? 12 : endHour % 12;
    return startPeriod == endPeriod
        ? '$startDisplay - $endDisplay $endPeriod'
        : '$startDisplay $startPeriod - $endDisplay $endPeriod';
  }

  String _hourOfDayLabel(int hour) {
    final period = hour < 12 ? 'AM' : 'PM';
    final display = hour % 12 == 0 ? 12 : hour % 12;
    return '$display $period';
  }

  @override
  Widget build(BuildContext context) {
    final servedRecords = _todayRecords.where((r) => r.status == 'served').toList();
    final skippedCount = _todayRecords.where((r) => r.status == 'skipped').length;
    final avgWait = _todayRecords.isEmpty
        ? 0
        : (_todayRecords.fold<int>(0, (total, r) => total + r.estimatedWaitMinutes) /
                _todayRecords.length)
            .round();

    final hourlyCounts = <int, int>{};
    for (final record in servedRecords) {
      final hour = record.createdAt!.hour;
      hourlyCounts[hour] = (hourlyCounts[hour] ?? 0) + 1;
    }
    final sortedHours = hourlyCounts.keys.toList()..sort();
    final hourlyData = sortedHours.map((hour) => (_hourRangeLabel(hour), hourlyCounts[hour]!)).toList();
    final maxCount = hourlyCounts.values.isEmpty ? 1 : hourlyCounts.values.reduce((a, b) => a > b ? a : b);

    int? peakHour;
    var peakCount = 0;
    hourlyCounts.forEach((hour, count) {
      if (count > peakCount) {
        peakCount = count;
        peakHour = hour;
      }
    });
    final peakHourLabel = peakHour == null ? '—' : _hourOfDayLabel(peakHour!);

    return Theme(
      data: StaffColors.themeData,
      child: Scaffold(
        backgroundColor: StaffColors.background,
        body: Column(
          children: [
            StaffHeader(
              title: "Today's summary",
              subtitle: widget.staff.counterLabel,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: StaffColors.primary))
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _StatTile(
                                  label: 'Total served',
                                  value: '${servedRecords.length}',
                                  color: StaffColors.success),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatTile(
                                  label: 'Skipped',
                                  value: '$skippedCount',
                                  color: StaffColors.danger),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatTile(label: 'Avg wait (min)', value: '$avgWait'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatTile(label: 'Peak hour', value: peakHourLabel),
                            ),
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
                        if (hourlyData.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'No patients served yet today',
                              style: TextStyle(color: StaffColors.textMuted),
                            ),
                          )
                        else
                          ...hourlyData.map((entry) {
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
                                              color: StaffColors.textSecondary))),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: fraction,
                                        minHeight: 14,
                                        backgroundColor: StaffColors.background,
                                        valueColor:
                                            const AlwaysStoppedAnimation(StaffColors.primary),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: 20,
                                    child: Text('$count',
                                        style: const TextStyle(
                                            fontSize: 12, fontWeight: FontWeight.w600)),
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
                              const SnackBar(content: Text('Report exported')),
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
            BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: 'Queue'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Stats'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
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
          Text(label, style: const TextStyle(fontSize: 12, color: StaffColors.textMuted)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color ?? StaffColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
