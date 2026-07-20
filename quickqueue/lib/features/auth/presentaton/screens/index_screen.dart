import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/sign_in_sheet.dart';
import 'register_screen.dart';

class IndexScreen extends StatelessWidget {
  const IndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final repository = AuthRepositoryImpl(MockAuthRemoteDataSource());
        return AuthBloc(
          signInWithEmail: SignInWithEmail(repository),
          signInWithGoogle: SignInWithGoogle(repository),
          signUpWithEmail: SignUpWithEmail(repository),
          signOut: SignOut(repository),
        );
      },
      child: const _IndexView(),
    );
  }
}

class _IndexView extends StatelessWidget {
  const _IndexView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text('QQ', style: AppStyles.headerTitle.copyWith(fontSize: 28)),
              ),
              const SizedBox(height: 24),
              Text(AppStrings.appName, style: AppStyles.displayTitle),
              const SizedBox(height: 10),
              Text(
                AppStrings.appTagline,
                textAlign: TextAlign.center,
                style: AppStyles.bodyMuted,
              ),
              const Spacer(flex: 4),
              QQButton(
                label: AppStrings.getStarted,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
              ),
              const SizedBox(height: 12),
              QQButton(
                label: AppStrings.signIn,
                variant: QQButtonVariant.outlined,
                onPressed: () => showSignInSheet(context, context.read<AuthBloc>()),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {},
                child: Text(AppStrings.forgotPassword, style: AppStyles.bodyMuted),
              ),
              const Spacer(flex: 2),
              Text(AppStrings.availableOn, style: AppStyles.caption),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
