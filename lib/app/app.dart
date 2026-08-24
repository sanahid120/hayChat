import 'package:flutter/material.dart';
import 'package:hay_chat/app/app_strings.dart';
import 'package:hay_chat/auth/presentation/screens/splash_screen.dart';
import 'package:hay_chat/auth/repository/chat_repository.dart';
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

        Provider<ChatRepository>(
          create: (_) => ChatRepository(),
        ),

        ChangeNotifierProvider<HomepageMainNavProvider>(
          create: (_) => HomepageMainNavProvider(),
        ),

        ChangeNotifierProvider<SignInProvider>(
          create: (_) => SignInProvider(),
        ),

        ChangeNotifierProvider<SignUpProvider>(
          create: (_) => SignUpProvider(),
        ),

        ChangeNotifierProvider<ChatProvider>(
          create: (_) => ChatProvider(),
        ),

        ChangeNotifierProvider<HomescreenProvider>(
          create: (context) => HomescreenProvider(
            repository: context.read<ChatRepository>(),
          ),
        ),

        ChangeNotifierProvider<ContactScreenProvider>(
          create: (context) => ContactScreenProvider(
            repository: context.read<ChatRepository>(),
          ),
        ),
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