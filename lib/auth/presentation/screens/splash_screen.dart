import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hay_chat/auth/presentation/screens/sign_in_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_strings.dart';
import 'intorduction.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _nextScreen();
  }

  void _nextScreen() {
      Future.delayed(const Duration(seconds: 3), () async {
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        bool isFirstTime = sharedPreferences.getBool('isFirstTimeUser') ?? true;
        if (!mounted) return;
        if (isFirstTime) {
          Navigator.pushReplacementNamed(context, IntroductionScreen.routeName);
          sharedPreferences.setBool('isFirstTimeUser', false);
        } else {
          Navigator.pushReplacementNamed(context, SignInScreen.routeName);
        }
      });
    }


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
