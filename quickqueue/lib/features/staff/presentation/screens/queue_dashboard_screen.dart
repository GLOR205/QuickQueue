import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../queue/domain/entities/ticket_entity.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/usecases/get_queue_ticket_history.dart';
import '../../domain/usecases/get_queue_tickets.dart';
import '../../domain/usecases/mark_served.dart';
import '../../domain/usecases/skip_patient.dart';
import '../widgets/staff_colors.dart';
import '../../widgets/queue_card.dart';
import 'analytics_screen.dart';
import 'skip_screen.dart';
import 'staff_alerts_screen.dart';
import 'staff_profile_screen.dart';

class QueueDashboardScreen extends StatefulWidget {
  const QueueDashboardScreen({super.key, required this.staff});

  final StaffEntity staff;

  @override
  State<QueueDashboardScreen> createState() => _QueueDashboardScreenState();
}

class _QueueDashboardScreenState extends State<QueueDashboardScreen> {
  int _currentIndex = 0;
  int _servedToday = 0;
  int _skippedToday = 0;
  bool _loading = true;
  List<TicketEntity> _tickets = const [];

  @override
  void initState() {
    super.initState();
    _loadTickets();
    _loadTodayStats();
  }

  Future<void> _loadTickets() async {
    setState(() => _loading = true);
    final tickets = await sl<GetQueueTickets>()(widget.staff.queueId);
    if (!mounted) return;
    setState(() {
      _tickets = tickets;
      _loading = false;
    });
  }

  bool _isToday(DateTime? time) {
    if (time == null) return false;
    final now = DateTime.now();
    return time.year == now.year && time.month == now.month && time.day == now.day;
  }

  Future<void> _loadTodayStats() async {
    final history = await sl<GetQueueTicketHistory>()(widget.staff.queueId);
    if (!mounted) return;
    setState(() {
      _servedToday = history.where((r) => r.status == 'served' && _isToday(r.createdAt)).length;
      _skippedToday = history.where((r) => r.status == 'skipped' && _isToday(r.createdAt)).length;
    });
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    if (index == 1) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => AnalyticsScreen(staff: widget.staff)))
          .then((_) => setState(() => _currentIndex = 0));
    } else if (index == 2) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => StaffProfileScreen(staff: widget.staff)))
          .then((_) => setState(() => _currentIndex = 0));
    }
  }

  Future<void> _markServed() async {
    if (_tickets.isEmpty) return;
    final ticket = _tickets.first;
    await sl<MarkServed>()(ticket.ticketNumber);
    if (!mounted) return;
    setState(() {
      _tickets = _tickets.skip(1).toList();
      _servedToday++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Patient marked as served')),
    );
  }

  Future<void> _skip() async {
    if (_tickets.isEmpty) return;
    final ticket = _tickets.first;
    final confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => SkipScreen(ticketNumber: ticket.ticketNumber)),
    );
    if (confirmed != true) return;
    await sl<SkipPatient>()(ticket.ticketNumber);
    if (!mounted) return;
    setState(() {
      _tickets = _tickets.skip(1).toList();
      _skippedToday++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final avgWait = _tickets.isEmpty
        ? 0
        : (_tickets.fold<int>(0, (total, t) => total + t.estimatedWaitMinutes) /
                _tickets.length)
            .round();
    return Theme(
      data: StaffColors.themeData,
      child: Scaffold(
        backgroundColor: StaffColors.background,
        body: Column(
          children: [
            _DashboardHeader(
              staffName: widget.staff.name,
              counterLabel: widget.staff.counterLabel,
              onAlertsTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => StaffAlertsScreen(queueId: widget.staff.queueId)),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: StaffColors.primary))
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _StatTile(
                                  label: 'Waiting now',
                                  value: '${_tickets.length}'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatTile(
                                  label: 'Served today',
                                  value: '$_servedToday'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatTile(
                                  label: 'Avg wait (min)', value: '$avgWait'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatTile(
                                  label: 'Skipped', value: '$_skippedToday'),
                            ),
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
                        if (_tickets.isEmpty)
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
                            _tickets.length,
                            (index) => QueueCard(
                              customer:
                                  '${_tickets[index].ticketNumber} - ${index == 0 ? 'Current patient' : (index == 1 ? 'Next patient' : 'Waiting')}',
                              position: index + 1,
                              onTap: () {},
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed:
                                      _tickets.isEmpty ? null : _markServed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: StaffColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
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
                                  onPressed: _tickets.isEmpty ? null : _skip,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: StaffColors.primary,
                                    side: const BorderSide(
                                        color: StaffColors.primary),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
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
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.staffName,
    required this.counterLabel,
    required this.onAlertsTap,
  });

  final String staffName;
  final String counterLabel;
  final VoidCallback onAlertsTap;

  @override
  Widget build(BuildContext context) {
    final initials = staffName.trim().isEmpty
        ? 'S'
        : staffName
            .trim()
            .split(RegExp(r'\s+'))
            .map((w) => w[0])
            .take(2)
            .join()
            .toUpperCase();
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
              child: Text(initials,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    counterLabel.isEmpty ? 'Counter' : counterLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    staffName.isEmpty ? 'Staff' : staffName,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onAlertsTap,
              icon: const Icon(Icons.notifications_none, color: Colors.white70),
            ),
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
