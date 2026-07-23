// lib/screens/staff/analytics_screen.dart
import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary cards
            Row(
              children: [
                _buildStatCard('Total Served', '45', Icons.check_circle),
                const SizedBox(width: 12),
                _buildStatCard('Avg Wait Time', '12 min', Icons.timer),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard('Skipped', '3', Icons.skip_next),
                const SizedBox(width: 12),
                _buildStatCard('Paused', '2', Icons.pause),
              ],
            ),
            const SizedBox(height: 24),

            // Chart placeholder
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 48, color: Colors.blue.shade300),
                    const SizedBox(height: 8),
                    Text(
                      'Queue Performance Over Time',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Recent activity
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildActivityItem('Served Customer A', '2 min ago', Colors.green),
            _buildActivityItem('Skipped Customer B', '15 min ago', Colors.orange),
            _buildActivityItem('Queue Paused', '1 hour ago', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String action, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}