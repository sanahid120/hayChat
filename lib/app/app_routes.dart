import 'package:flutter/material.dart';
import 'package:hay_chat/app/models/user_model.dart';
import 'package:hay_chat/features/chat/presentation/screens/chat_screen.dart';

import '../auth/presentation/screens/forget_password.dart';
import '../auth/presentation/screens/intorduction.dart';
import '../auth/presentation/screens/sign_in_screen.dart';
import '../auth/presentation/screens/sign_up_screen.dart';
import '../auth/presentation/screens/splash_screen.dart';
import '../shared/presentation/screens/homepage_bottom_nav_bar.dart';

class AppRoutes {
  static MaterialPageRoute<dynamic> onGenerateRoute(RouteSettings settings) {
    Widget widget = const SizedBox();
    switch (settings.name) {
      case SplashScreen.routeName:
        widget = const SplashScreen();
        break;

      case IntroductionScreen.routeName:
        widget = const IntroductionScreen();
        break;

      case SignInScreen.routeName:
        widget = const SignInScreen();
        break;

      case SignUpScreen.routeName:
        widget = const SignUpScreen();
        break;

      case ForgetPasswordScreen.routeName:
        widget = ForgetPasswordScreen();
        break;

      case HomepageBottomNavBar.routeName:
        widget = const HomepageBottomNavBar();
        break;

      case ChatScreen.routeName:
        final user = settings.arguments as UserModel?;
        widget = ChatScreen(receiverUser: user);
        break;

      default:
        widget = const SplashScreen();
        break;
    }

    return MaterialPageRoute(builder: (context) => widget);
  }
}
