import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/di/service_locator.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/usecases/sign_out_staff.dart';
import '../../../auth/presentaton/bloc/auth_bloc.dart';
import '../../../auth/presentaton/bloc/auth_event.dart';
import '../../../auth/presentaton/bloc/auth_state.dart';
import '../widgets/staff_colors.dart';
import '../widgets/staff_header.dart';
import 'pause_queue_screen.dart';
import 'staff_login_screen.dart';

class StaffProfileScreen extends StatefulWidget {
  const StaffProfileScreen({super.key, required this.staff});

  final StaffEntity staff;
class StaffProfileScreen extends StatelessWidget {
  const StaffProfileScreen({super.key, this.queueId, this.authBloc});

  /// The counter/queue this staff member is working, if known. Optional
  /// because this screen can also be reached without an active session.
  final String? queueId;

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
      child: _StaffProfileView(queueId: queueId),
    );
  }
}

class _StaffProfileView extends StatefulWidget {
  const _StaffProfileView({this.queueId});

  final String? queueId;

  @override
  State<_StaffProfileView> createState() => _StaffProfileViewState();
}

class _StaffProfileViewState extends State<_StaffProfileView> {
  bool _soundAlerts = true;
  bool _autoCallNext = false;
  bool _vibrationAlerts = true;

  void _onNavTap(int index) {
    if (index == 0) {
      Navigator.pop(context);
    }
  }

  Future<void> _signOut() async {
    await sl<SignOutStaff>()();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const StaffLoginScreen()),
      (route) => false,
    );
    if (index == 0 && widget.queueId != null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => QueueDashboardScreen(queueId: widget.queueId!)));
    }
  }

  void _signOut() {
    context.read<AuthBloc>().add(const SignOutEvent());
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.staff.name.trim().isEmpty ? 'Staff' : widget.staff.name.trim();
    final initials = name
        .split(RegExp(r'\s+'))
        .map((w) => w[0])
        .take(2)
        .join()
        .toUpperCase();
    return Theme(
      data: StaffColors.themeData,
      child: Scaffold(
        backgroundColor: StaffColors.background,
        body: Column(
          children: [
            const StaffHeader(
                title: 'My Profile', subtitle: 'Account and preferences'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: StaffColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: StaffColors.primary,
                          child: Text(initials,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              const SizedBox(height: 2),
                              GestureDetector(
                                onTap: () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Edit profile is coming soon')),
                                ),
                                child: const Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                      color: StaffColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Counter preferences',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: StaffColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  _ToggleRow(
                    label: 'Sound alerts',
                    value: _soundAlerts,
                    onChanged: (v) => setState(() => _soundAlerts = v),
                  ),
                  _ToggleRow(
                    label: 'Auto-call next patient',
                    value: _autoCallNext,
                    onChanged: (v) => setState(() => _autoCallNext = v),
                  ),
                  _ToggleRow(
                    label: 'Vibration alerts',
                    value: _vibrationAlerts,
                    onChanged: (v) => setState(() => _vibrationAlerts = v),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Account',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: StaffColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  _ActionRow(
                    label: 'Change password',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Change password is coming soon')),
                    ),
                  ),
                  _ActionRow(
                    label: 'Queue Control',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const PauseQueueScreen())),
                  ),
                  const SizedBox(height: 20),
                  Material(
                    color: StaffColors.dangerLight,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _signOut,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'Sign out',
                            style: TextStyle(
                                color: StaffColors.danger,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 2,
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
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const StaffLoginScreen()),
            (route) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isSigningOut = state is AuthLoading;
        return Scaffold(
          backgroundColor: StaffColors.background,
          body: Column(
            children: [
              const StaffHeader(
                  title: 'My Profile', subtitle: 'Account and preferences'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: StaffColors.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            backgroundColor: StaffColors.primary,
                            child: Text('S1',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Staff1',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                const SizedBox(height: 2),
                                GestureDetector(
                                  onTap: () =>
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Edit profile is coming soon')),
                                  ),
                                  child: const Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                        color: StaffColors.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Counter preferences',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: StaffColors.textSecondary),
                    ),
                    const SizedBox(height: 10),
                    _ToggleRow(
                      label: 'Sound alerts',
                      value: _soundAlerts,
                      onChanged: (v) => setState(() => _soundAlerts = v),
                    ),
                    _ToggleRow(
                      label: 'Auto-call next patient',
                      value: _autoCallNext,
                      onChanged: (v) => setState(() => _autoCallNext = v),
                    ),
                    _ToggleRow(
                      label: 'Vibration alerts',
                      value: _vibrationAlerts,
                      onChanged: (v) => setState(() => _vibrationAlerts = v),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Account',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: StaffColors.textSecondary),
                    ),
                    const SizedBox(height: 10),
                    _ActionRow(
                      label: 'Change password',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Change password is coming soon')),
                      ),
                    ),
                    if (widget.queueId != null)
                      _ActionRow(
                        label: 'Queue Control',
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => PauseQueueScreen(
                                    queueId: widget.queueId!))),
                      ),
                    const SizedBox(height: 20),
                    Material(
                      color: StaffColors.dangerLight,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: isSigningOut ? null : _signOut,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              isSigningOut ? 'Signing out...' : 'Sign out',
                              style: const TextStyle(
                                  color: StaffColors.danger,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 2,
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

class _ToggleRow extends StatelessWidget {
  const _ToggleRow(
      {required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: StaffColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StaffColors.border),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Switch(
              value: value,
              activeThumbColor: StaffColors.primary,
              onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: StaffColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StaffColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                    child: Text(label, style: const TextStyle(fontSize: 14))),
                const Icon(Icons.chevron_right, color: StaffColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
