import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/sign_in_staff.dart';
import '../../../auth/presentaton/bloc/auth_bloc.dart';
import '../../../auth/presentaton/bloc/auth_event.dart';
import '../../../auth/presentaton/bloc/auth_state.dart';
import '../widgets/staff_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'queue_dashboard_screen.dart';
import 'staff_sign_up_screen.dart';

/// Staff sign-in entry point. Matches the "Staff - login" design: a
/// dedicated portal separate from the customer-facing sign-in, gated by
/// staff ID/email, password, and the counter the staff member is working.
class StaffLoginScreen extends StatelessWidget {
  const StaffLoginScreen({super.key, this.authBloc});

  /// Injectable for tests; defaults to a real Firebase-backed bloc.
  final AuthBloc? authBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          authBloc ??
          AuthBloc(
            firebaseAuth: FirebaseAuth.instance,
            googleSignIn: GoogleSignIn(),
          ),
      child: const _StaffLoginView(),
    );
  }
}

class _StaffLoginView extends StatefulWidget {
  const _StaffLoginView();

  @override
  State<_StaffLoginView> createState() => _StaffLoginViewState();
}

class _StaffLoginViewState extends State<_StaffLoginView> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  final _counterController =
      TextEditingController(text: 'Room R2 - General consultation');

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _isSubmitting = true);
    try {
      final staff = await sl<SignInStaff>()(
        email: _idController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => QueueDashboardScreen(staff: staff)),
        (route) => false,
      );
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
    context.read<AuthBloc>().add(SignInWithEmailEvent(
          email: _idController.text.trim(),
          password: _passwordController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: StaffColors.themeData,
      child: Scaffold(
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
                    const SizedBox(height: 28),
                    CustomButton(
                      text: _isSubmitting ? 'Signing in...' : 'Sign in',
                      onPressed: _isSubmitting ? null : _signIn,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const StaffSignUpScreen()),
                        ),
                        child: const Text.rich(
                          TextSpan(
                            text: 'New staff member? ',
                            style: TextStyle(
                                color: StaffColors.textSecondary, fontSize: 13),
                            children: [
                              TextSpan(
                                text: 'Sign up',
                                style: TextStyle(
                                    color: StaffColors.primary,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => QueueDashboardScreen(
                queueId: _counterController.text.trim(),
              ),
            ),
            (route) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state is AuthLoading;
        return Scaffold(
          backgroundColor: StaffColors.background,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
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
                        validator: (value) =>
                            (value == null || value.isEmpty)
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
                        text: isSubmitting ? 'Signing in...' : 'Sign in',
                        onPressed: isSubmitting ? null : _signIn,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
