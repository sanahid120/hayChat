import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  static const String routeName = '/sign-in';

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: .start,
            children: [
              const SizedBox(height: 46),
              Text(
                'Welcome Back 👋',
                style: TextTheme.of(
                  context,
                ).headlineLarge?.copyWith(color: AppColors.textPrimary),
              ),

              Text(
                'Sign in to continue',
                style: TextTheme.of(
                  context,
                ).headlineSmall?.copyWith(color: AppColors.textHint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
