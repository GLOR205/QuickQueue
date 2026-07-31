import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/constants/app_colors.dart';
import 'core/di/service_locator.dart';
import 'core/navigation/nav_tab_cubit.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/presentaton/screens/index_screen.dart';
import 'features/profile/domain/usecases/change_password.dart';
import 'features/profile/domain/usecases/get_user_profile.dart';
import 'features/profile/domain/usecases/submit_rating.dart';
import 'features/profile/domain/usecases/update_preferences.dart';
import 'features/profile/domain/usecases/update_profile.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/queue/domain/usecases/get_notifications.dart';
import 'features/queue/domain/usecases/get_queue_position.dart';
import 'features/queue/domain/usecases/get_queues.dart';
import 'features/queue/domain/usecases/join_queue.dart';
import 'features/queue/domain/usecases/leave_queue.dart';
import 'features/queue/presentation/bloc/queue_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupServiceLocator();
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
        BlocProvider(create: (_) => QueueBloc(
          getQueues: sl<GetQueues>(),
          joinQueue: sl<JoinQueue>(),
          getQueuePosition: sl<GetQueuePosition>(),
          leaveQueue: sl<LeaveQueue>(),
          getNotifications: sl<GetNotifications>(),
        )),
        BlocProvider(create: (_) => ProfileBloc(
          getUserProfile: sl<GetUserProfile>(),
          submitRating: sl<SubmitRating>(),
          updateProfile: sl<UpdateProfile>(),
          changePassword: sl<ChangePassword>(),
          updatePreferences: sl<UpdatePreferences>(),
        )),
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
