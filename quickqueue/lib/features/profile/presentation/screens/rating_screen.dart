import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/navigation/nav_tab_cubit.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../queue/presentation/bloc/queue_bloc.dart';
import '../../../queue/presentation/bloc/queue_event.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class RatingScreen extends StatefulWidget {
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
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _stars = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _finish(BuildContext context) {
    context.read<QueueBloc>().add(const QueueLeaveRequested());
    context.read<NavTabCubit>().select(QQNavTab.ticket);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
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
              QQHeader(
                title: AppStrings.youWereServed,
                subtitle: AppStrings.rateExperienceSubtitle,
                color: colors.success,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(color: colors.successLight, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Icon(Icons.check_rounded, color: colors.success, size: 36),
                    ),
                    const SizedBox(height: 16),
                    Text(AppStrings.serviceCompleted, style: AppStyles.sectionTitle(context).copyWith(fontSize: 17)),
                    const SizedBox(height: 4),
                    Text('${widget.serviceName} - ${widget.roomLabel}', style: AppStyles.bodyMuted(context)),
                    const SizedBox(height: 8),
                    Text(
                      'Time Saved: ${widget.timeSavedHours}hrs',
                      style: AppStyles.cardTitle(context).copyWith(color: colors.success),
                    ),
                    const SizedBox(height: 24),
                    Text(AppStrings.rateYourWaitExperience, style: AppStyles.bodyMuted(context)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final filled = index < _stars;
                        return IconButton(
                          onPressed: () => setState(() => _stars = index + 1),
                          icon: Icon(
                            filled ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: colors.star,
                            size: 34,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _commentController,
                      maxLines: 3,
                      style: AppStyles.body(context),
                      decoration: InputDecoration(
                        hintText: 'Share your experience (optional)',
                        hintStyle: AppStyles.body(context).copyWith(color: colors.textMuted),
                        filled: true,
                        fillColor: colors.surface,
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.success, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    QQButton(
                      label: AppStrings.submitFeedback,
                      color: colors.success,
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
                      child: Text(AppStrings.cancel, style: AppStyles.bodyMuted(context)),
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
