import 'package:flutter/material.dart';

import 'core/constants/app_colors.dart';
import 'features/auth/presentaton/screens/index_screen.dart';

void main() {
  runApp(const QuickQueueApp());
}

class QuickQueueApp extends StatelessWidget {
  const QuickQueueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Queue',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const IndexScreen(),
    );
  }
}
