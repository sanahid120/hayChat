import 'package:flutter/material.dart';
import 'package:hay_chat/app/app_strings.dart';
import 'package:hay_chat/auth/presentation/screens/intorduction.dart';
import 'package:hay_chat/auth/presentation/screens/sign_in_screen.dart';

import '../auth/presentation/screens/splash_screen.dart';
import 'app_routes.dart';
import 'app_themes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      initialRoute: SignInScreen.routeName,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
