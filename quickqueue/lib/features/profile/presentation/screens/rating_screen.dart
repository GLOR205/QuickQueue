import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../location/presentation/screens/locations_screen.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/submit_rating.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class RatingScreen extends StatelessWidget {
  const RatingScreen({
    super.key,
    required this.serviceName,
    required this.roomLabel,
    this.timeSavedHours = 4.2,
  });

  final String serviceName;
  final String roomLabel;
  final double timeSavedHours;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final repository = ProfileRepositoryImpl(MockProfileRemoteDataSource());
        return ProfileBloc(
          getUserProfile: GetUserProfile(repository),
          submitRating: SubmitRating(repository),
        );
      },
      child: _RatingView(serviceName: serviceName, roomLabel: roomLabel, timeSavedHours: timeSavedHours),
    );
  }
}

class _RatingView extends StatefulWidget {
  const _RatingView({required this.serviceName, required this.roomLabel, required this.timeSavedHours});

  final String serviceName;
  final String roomLabel;
  final double timeSavedHours;

  @override
  State<_RatingView> createState() => _RatingViewState();
}

class _RatingViewState extends State<_RatingView> {
  int _stars = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _finish(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LocationsScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.submitted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Thanks for your feedback!')));
            _finish(context);
          } else if (state.status == ProfileStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              const QQHeader(
                title: AppStrings.youWereServed,
                subtitle: AppStrings.rateExperienceSubtitle,
                color: AppColors.success,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: const Icon(Icons.check_rounded, color: AppColors.success, size: 36),
                    ),
                    const SizedBox(height: 16),
                    Text(AppStrings.serviceCompleted, style: AppStyles.sectionTitle.copyWith(fontSize: 17)),
                    const SizedBox(height: 4),
                    Text('${widget.serviceName} - ${widget.roomLabel}', style: AppStyles.bodyMuted),
                    const SizedBox(height: 8),
                    Text(
                      'Time Saved: ${widget.timeSavedHours}hrs',
                      style: AppStyles.cardTitle.copyWith(color: AppColors.success),
                    ),
                    const SizedBox(height: 24),
                    Text(AppStrings.rateYourWaitExperience, style: AppStyles.bodyMuted),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final filled = index < _stars;
                        return IconButton(
                          onPressed: () => setState(() => _stars = index + 1),
                          icon: Icon(
                            filled ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: AppColors.star,
                            size: 34,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _commentController,
                      maxLines: 3,
                      style: AppStyles.body,
                      decoration: InputDecoration(
                        hintText: 'Share your experience (optional)',
                        hintStyle: AppStyles.body.copyWith(color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.success, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    QQButton(
                      label: AppStrings.submitFeedback,
                      color: AppColors.success,
                      isLoading: state.status == ProfileStatus.submitting,
                      onPressed: _stars == 0
                          ? null
                          : () => context.read<ProfileBloc>().add(RatingSubmitted(
                                stars: _stars,
                                comment: _commentController.text.trim(),
                                serviceName: widget.serviceName,
                              )),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _finish(context),
                      child: Text(AppStrings.cancel, style: AppStyles.bodyMuted),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
