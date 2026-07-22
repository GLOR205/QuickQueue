import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../auth/presentaton/screens/index_screen.dart';
import '../../../queue/presentation/screens/notifications_screen.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/change_password.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/submit_rating.dart';
import '../../domain/usecases/update_preferences.dart';
import '../../domain/usecases/update_profile.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/change_password_sheet.dart';
import '../widgets/edit_profile_sheet.dart';

const _languageNames = {'en': 'English', 'rw': 'Kinyarwanda', 'fr': 'Français'};

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final repository = ProfileRepositoryImpl(MockProfileRemoteDataSource());
        return ProfileBloc(
          getUserProfile: GetUserProfile(repository),
          submitRating: SubmitRating(repository),
          updateProfile: UpdateProfile(repository),
          changePassword: ChangePassword(repository),
          updatePreferences: UpdatePreferences(repository),
        )..add(const ProfileRequested());
      },
      child: const _UserProfileView(),
    );
  }
}

class _UserProfileView extends StatelessWidget {
  const _UserProfileView();

  void _switchTab(BuildContext context, QQNavTab tab) {
    if (tab == QQNavTab.profile) return;
    if (tab == QQNavTab.alerts) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const IndexScreen()),
      (route) => false,
    );
  }

  Future<void> _pickLanguage(BuildContext context, ProfileBloc bloc, ProfileEntity profile) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Language'),
        children: [
          RadioGroup<String>(
            groupValue: profile.languageCode,
            onChanged: (value) => Navigator.of(dialogContext).pop(value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _languageNames.entries
                  .map((entry) => RadioListTile<String>(value: entry.key, title: Text(entry.value)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
    if (selected != null && selected != profile.languageCode) {
      bloc.add(PreferencesUpdateRequested(
        notificationsEnabled: profile.notificationsEnabled,
        languageCode: selected,
      ));
    }
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: '1.0.0',
      applicationLegalese: 'Skip the wait. Join your queue from anywhere, anytime.',
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
          'Need a hand? Reach us at support@quickqueue.rw or +250 788 123 456, '
          'available weekdays 8am-6pm.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listenWhen: (previous, current) => current.status != previous.status,
        listener: (context, state) {
          if (state.status == ProfileStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.status == ProfileStatus.loading || state.status == ProfileStatus.initial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final profile = state.profile;
          if (profile == null) {
            return Center(child: Text(state.errorMessage ?? 'Something went wrong'));
          }
          final bloc = context.read<ProfileBloc>();
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              const QQHeader(title: AppStrings.myProfile, subtitle: AppStrings.myProfileSubtitle),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text(
                        profile.avatarLetter,
                        style: AppStyles.displayTitle.copyWith(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(profile.name, style: AppStyles.sectionTitle.copyWith(fontSize: 17)),
                    const SizedBox(height: 2),
                    Text(profile.phone, style: AppStyles.bodyMuted),
                    Text(profile.email, style: AppStyles.bodyMuted),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () => _logout(context),
                      style: TextButton.styleFrom(foregroundColor: AppColors.error, padding: EdgeInsets.zero),
                      child: Text(AppStrings.logout, style: AppStyles.label.copyWith(color: AppColors.error)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _StatBox(label: 'Queues joined', value: '${profile.queuesJoined}')),
                        const SizedBox(width: 10),
                        Expanded(child: _StatBox(label: 'Avg wait', value: '${profile.avgWaitMinutes} min')),
                        const SizedBox(width: 10),
                        Expanded(child: _StatBox(label: 'Time saved', value: '${profile.timeSavedHours} hrs')),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SectionCard(
                      title: 'Account',
                      children: [
                        _SettingsRow(
                          icon: Icons.edit_outlined,
                          label: 'Edit profile',
                          onTap: () => showEditProfileSheet(context, bloc, profile),
                        ),
                        _SettingsRow(
                          icon: Icons.lock_outline,
                          label: 'Change password',
                          onTap: () => showChangePasswordSheet(context, bloc),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Appearance',
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: BlocBuilder<ThemeCubit, ThemeMode>(
                            builder: (context, mode) {
                              return SegmentedButton<ThemeMode>(
                                segments: const [
                                  ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode_outlined)),
                                  ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode_outlined)),
                                  ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.settings_suggest_outlined)),
                                ],
                                selected: {mode},
                                onSelectionChanged: (selection) =>
                                    context.read<ThemeCubit>().setMode(selection.first),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Preferences',
                      children: [
                        SwitchListTile(
                          value: profile.notificationsEnabled,
                          onChanged: (value) => bloc.add(PreferencesUpdateRequested(
                            notificationsEnabled: value,
                            languageCode: profile.languageCode,
                          )),
                          activeThumbColor: AppColors.primary,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                          title: Text('Push notifications', style: AppStyles.body),
                          subtitle: Text('Get notified as your turn gets close', style: AppStyles.caption),
                        ),
                        _SettingsRow(
                          icon: Icons.language,
                          label: 'Language',
                          trailingText: _languageNames[profile.languageCode],
                          onTap: () => _pickLanguage(context, bloc, profile),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Support',
                      children: [
                        _SettingsRow(
                          icon: Icons.help_outline,
                          label: 'Help & Support',
                          onTap: () => _showHelp(context),
                        ),
                        _SettingsRow(
                          icon: Icons.info_outline,
                          label: 'About Quick Queue',
                          onTap: () => _showAbout(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(AppStrings.recentQueueHistory, style: AppStyles.sectionTitle),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: profile.history.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _HistoryCard(entry: profile.history[index]),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: QQBottomNav(
        current: QQNavTab.profile,
        onTabSelected: (tab) => _switchTab(context, tab),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: AppStyles.cardTitle.copyWith(color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(label, style: AppStyles.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
              child: Text(title, style: AppStyles.label),
            ),
            ...children,
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.icon, required this.label, required this.onTap, this.trailingText});

  final IconData icon;
  final String label;
  final String? trailingText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(label, style: AppStyles.body),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) ...[
            Text(trailingText!, style: AppStyles.bodyMuted),
            const SizedBox(width: 6),
          ],
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entry});

  final ProfileHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final accent = Color(entry.colorValue);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: Text(entry.avatarLetter, style: AppStyles.cardTitle.copyWith(color: accent)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${entry.locationName} - ${entry.serviceName}', style: AppStyles.cardTitle),
                const SizedBox(height: 2),
                Text(entry.dateLabel, style: AppStyles.caption),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(20)),
            child: Text('Served', style: AppStyles.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
