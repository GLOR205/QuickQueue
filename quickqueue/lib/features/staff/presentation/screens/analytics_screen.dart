import 'package:flutter/material.dart';

import '../widgets/staff_colors.dart';
import '../widgets/staff_header.dart';
import '../../widgets/custom_button.dart';
import 'staff_profile_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  static const _hourly = [
    ('8 - 9 AM', 6),
    ('9 - 10 AM', 12),
    ('10 - 11 AM', 10),
    ('11 - 12 PM', 9),
    ('2 - 3 PM', 6),
    ('3 - 4 PM', 4),
  ];

  void _onNavTap(int index) {
    if (index == 0) {
      Navigator.pop(context);
    } else if (index == 2) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const StaffProfileScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxCount = _hourly.map((e) => e.$2).reduce((a, b) => a > b ? a : b);
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
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                          label: 'Total served',
                          value: '47',
                          color: StaffColors.success),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                          label: 'Skipped',
                          value: '1',
                          color: StaffColors.danger),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Expanded(
                        child: _StatTile(label: 'Avg wait (min)', value: '13')),
                    SizedBox(width: 12),
                    Expanded(
                        child: _StatTile(label: 'Peak hour', value: '9 AM')),
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
                ..._hourly.map((entry) {
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
                              valueColor: const AlwaysStoppedAnimation(
                                  StaffColors.primary),
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
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined), label: 'Queue'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined), label: 'Stats'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
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
