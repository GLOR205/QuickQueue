import 'package:flutter/material.dart';

import '../widgets/staff_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'queue_dashboard_screen.dart';

/// Staff sign-in entry point. Matches the "Staff - login" design: a
/// dedicated portal separate from the customer-facing sign-in, gated by
/// staff ID/email, password, and the counter the staff member is working.
class StaffLoginScreen extends StatefulWidget {
  const StaffLoginScreen({super.key});

  @override
  State<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends State<StaffLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _counterController =
      TextEditingController(text: 'Room R2 - General consultation');
  bool _isSubmitting = false;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _counterController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const QueueDashboardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StaffColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: StaffColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'QQ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Quick Queue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: StaffColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Staff portal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14, color: StaffColors.textSecondary),
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    controller: _idController,
                    label: 'Staff ID or email',
                    hint: 'staff@hospital.rw',
                    icon: Icons.badge_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Enter your staff ID or email'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Enter your password'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _counterController,
                    label: 'Select your counter',
                    icon: Icons.meeting_room_outlined,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Select your counter'
                            : null,
                  ),
                  const SizedBox(height: 28),
                  CustomButton(
                    text: _isSubmitting ? 'Signing in...' : 'Sign in',
                    onPressed: _isSubmitting ? null : _signIn,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
