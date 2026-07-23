// lib/screens/staff/queue_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/queue_card.dart';

class QueueDashboardScreen extends StatefulWidget {
  const QueueDashboardScreen({super.key});

  @override
  State<QueueDashboardScreen> createState() => _QueueDashboardScreenState();
}

class _QueueDashboardScreenState extends State<QueueDashboardScreen> {
  int _currentIndex = 0;
  final List<String> _queueItems = [
    'Customer A - Ticket #001',
    'Customer B - Ticket #002',
    'Customer C - Ticket #003',
    'Customer D - Ticket #004',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.pushNamed(context, '/analytics');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Current serving card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Now Serving',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 32, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer A',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Ticket #001',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_next, color: Colors.orange),
                          onPressed: () {
                            Navigator.pushNamed(context, '/skip');
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.pause, color: Colors.red),
                          onPressed: () {
                            Navigator.pushNamed(context, '/pause');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Queue list
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Waiting Queue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _queueItems.length,
                      itemBuilder: (context, index) {
                        return QueueCard(
                          customer: _queueItems[index],
                          position: index + 1,
                          onTap: () {
                            // Handle queue item tap
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Queue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}