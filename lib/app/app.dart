import 'package:flutter/material.dart';
import 'package:hay_chat/app/app_strings.dart';
import 'package:hay_chat/auth/presentation/screens/intorduction.dart';
import 'package:hay_chat/auth/presentation/screens/sign_in_screen.dart';
import 'package:hay_chat/shared/presentation/data/nav_bar_provider.dart';
import 'package:hay_chat/shared/presentation/screens/homepage_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

import 'app_routes.dart';
import 'app_themes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomepageMainNavProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,

        initialRoute: HomepageBottomNavBar.routeName,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
