import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hay_chat/core/services/notification_service.dart';

import 'app/app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.initialize();

  runApp(const MyApp());
}
