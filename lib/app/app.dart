import 'package:flutter/material.dart';
import 'package:hay_chat/app/app_strings.dart';
import 'package:hay_chat/auth/presentation/screens/splash_screen.dart';
import 'package:hay_chat/features/contacts/presentation/providers/contact_screen_provider.dart';
import 'package:hay_chat/features/home/presentation/providers/homescreen_provider.dart';
import 'package:hay_chat/shared/presentation/data/nav_bar_provider.dart';
import 'package:provider/provider.dart';

import '../auth/presentation/providers/sign_in_provider.dart';
import '../auth/presentation/providers/sign_up_provider.dart';
import '../features/chat/presentation/providers/chat_provider.dart';
import 'app_routes.dart';
import 'app_themes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomepageMainNavProvider()),
        ChangeNotifierProvider(create: (_) => SignInProvider()),
        ChangeNotifierProvider(create: (_) => SignUpProvider()),
        ChangeNotifierProvider(create: (_) => HomescreenProvider()),
        ChangeNotifierProvider(create: (_) => ContactScreenProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,

        initialRoute: SplashScreen.routeName,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
