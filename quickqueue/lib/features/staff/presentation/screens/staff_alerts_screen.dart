import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../domain/entities/staff_ticket_record.dart';
import '../../domain/usecases/get_queue_ticket_history.dart';
import '../widgets/staff_colors.dart';
import '../widgets/staff_header.dart';

/// Staff's "notifications" — every ticket ever created for their queue,
/// newest first, read straight from the same `tickets` collection the
/// customer side writes to when someone joins. No separate
/// notifications-for-staff collection needed: a new ticket for this queue
/// *is* the "a patient joined" event.
class StaffAlertsScreen extends StatefulWidget {
  const StaffAlertsScreen({super.key, required this.queueId});

  final String queueId;

  @override
  State<StaffAlertsScreen> createState() => _StaffAlertsScreenState();
}

class _StaffAlertsScreenState extends State<StaffAlertsScreen> {
  bool _loading = true;
  List<StaffTicketRecord> _records = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final records = await sl<GetQueueTicketHistory>()(widget.queueId);
    if (!mounted) return;
    setState(() {
      _records = records;
      _loading = false;
    });
  }

  String _relativeTimeLabel(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 2) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: StaffColors.themeData,
      child: Scaffold(
        backgroundColor: StaffColors.background,
        body: Column(
          children: [
            StaffHeader(
              title: 'Alerts',
              subtitle: 'Patients who joined your queue',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: StaffColors.primary))
                  : _records.isEmpty
                      ? const Center(
                          child: Text('No alerts yet', style: TextStyle(color: StaffColors.textMuted)),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: _records.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) => _AlertCard(
                            record: _records[index],
                            timeLabel: _relativeTimeLabel(_records[index].createdAt),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.record, required this.timeLabel});

  final StaffTicketRecord record;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StaffColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: StaffColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(color: StaffColors.primaryLight, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Icon(Icons.person_add_alt_1, size: 16, color: StaffColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'New patient joined',
                  style: TextStyle(fontWeight: FontWeight.w600, color: StaffColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ticket ${record.ticketNumber}',
                  style: const TextStyle(fontSize: 12, color: StaffColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(timeLabel, style: const TextStyle(fontSize: 12, color: StaffColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
