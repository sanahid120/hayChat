import 'package:flutter/material.dart';

import '../auth/presentation/screens/forget_password.dart';
import '../auth/presentation/screens/intorduction.dart';
import '../auth/presentation/screens/sign_in_screen.dart';
import '../auth/presentation/screens/sign_up_screen.dart';
import '../auth/presentation/screens/splash_screen.dart';
import '../shared/presentation/screens/homepage_bottom_nav_bar.dart';

class AppRoutes {
  static MaterialPageRoute<dynamic> onGenerateRoute(RouteSettings settings) {
    Widget widget = SizedBox();
    switch (settings.name) {
      case SplashScreen.routeName:
        widget = SplashScreen();
        break;

      case IntroductionScreen.routeName:
        widget = IntroductionScreen();
        break;

      case SignInScreen.routeName:
        widget = SignInScreen();
        break;

      case SignUpScreen.routeName:
        widget = SignUpScreen();
        break;

      case ForgetPasswordScreen.routeName:
        widget = ForgetPasswordScreen();
        break;

      case HomepageBottomNavBar.routeName:
        widget = HomepageBottomNavBar();
        break;

      default:
        widget = SplashScreen();
        break;
    }

    return MaterialPageRoute(builder: (context) => widget);
  }
}
