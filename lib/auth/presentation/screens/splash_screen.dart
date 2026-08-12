import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_strings.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const String routeName = '/';

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FaIcon(
                FontAwesomeIcons.commentDots,
                size: 100,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'Chat Simply',
                style: TextTheme.of(
                  context,
                ).titleMedium?.copyWith(color: AppColors.primaryLight),
              ),
              Text(
                'Stay Connected',
                style: TextTheme.of(
                  context,
                ).titleMedium?.copyWith(color: AppColors.primaryLight),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
