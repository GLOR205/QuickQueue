import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../auth/presentaton/screens/index_screen.dart';
import '../../../queue/presentation/screens/notifications_screen.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/submit_rating.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.status == ProfileStatus.loading || state.status == ProfileStatus.initial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final profile = state.profile;
          if (profile == null) {
            return Center(child: Text(state.errorMessage ?? 'Something went wrong'));
          }
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
