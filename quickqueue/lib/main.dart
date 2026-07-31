import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_colors.dart';
import 'core/navigation/nav_tab_cubit.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/presentaton/screens/index_screen.dart';
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/usecases/change_password.dart';
import 'features/profile/domain/usecases/get_user_profile.dart';
import 'features/profile/domain/usecases/submit_rating.dart';
import 'features/profile/domain/usecases/update_preferences.dart';
import 'features/profile/domain/usecases/update_profile.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/queue/data/datasources/queue_remote_datasource.dart';
import 'features/queue/data/repositories/queue_repository_impl.dart';
import 'features/queue/domain/usecases/get_notifications.dart';
import 'features/queue/domain/usecases/get_queue_position.dart';
import 'features/queue/domain/usecases/get_queues.dart';
import 'features/queue/domain/usecases/join_queue.dart';
import 'features/queue/domain/usecases/leave_queue.dart';
import 'features/queue/presentation/bloc/queue_bloc.dart';

void main() {
  runApp(const QuickQueueApp());
}

class QuickQueueApp extends StatelessWidget {
  const QuickQueueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => NavTabCubit()),
        // Session-scoped: one QueueBloc/ProfileBloc for the whole
        // authenticated session so the active ticket, its live position
        // updates, and profile data survive navigating between the
        // Locations/Services flow and the Ticket/Alerts/Profile shell tabs.
        BlocProvider(create: (_) {
          final repository = QueueRepositoryImpl(MockQueueRemoteDataSource());
          return QueueBloc(
            getQueues: GetQueues(repository),
            joinQueue: JoinQueue(repository),
            getQueuePosition: GetQueuePosition(repository),
            leaveQueue: LeaveQueue(repository),
            getNotifications: GetNotifications(repository),
          );
        }),
        BlocProvider(create: (_) {
          final repository = ProfileRepositoryImpl(MockProfileRemoteDataSource());
          return ProfileBloc(
            getUserProfile: GetUserProfile(repository),
            submitRating: SubmitRating(repository),
            updateProfile: UpdateProfile(repository),
            changePassword: ChangePassword(repository),
            updatePreferences: UpdatePreferences(repository),
          );
        }),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Quick Queue',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: AppColorsExt.light.primary),
              scaffoldBackgroundColor: AppColorsExt.light.background,
              extensions: const [AppColorsExt.light],
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColorsExt.dark.primary,
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: AppColorsExt.dark.background,
              extensions: const [AppColorsExt.dark],
            ),
            home: const IndexScreen(),
          );
        },
      ),
    );
  }
}
