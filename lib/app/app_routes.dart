import 'package:flutter/material.dart';

import '../auth/presentation/screens/intorduction.dart';
import '../auth/presentation/screens/splash_screen.dart';

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

      default:
        widget = SplashScreen();
        break;
    }

    return MaterialPageRoute(builder: (context) => widget);
  }
}
