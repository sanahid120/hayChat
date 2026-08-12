import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF19C7B5);
  static const Color primaryDark = Color(0xFF07998F);
  static const Color primaryLight = Color(0xFF5EE2D4);

  // Background colors
  static const Color background = Color(0xFF020F1C);
  static const Color scaffoldBackground = Color(0xFF061522);
  static const Color appBarBackground = Color(0xFF061522);

  // Surface colors
  static const Color surface = Color(0xFF102130);
  static const Color surfaceLight = Color(0xFF182B3A);
  static const Color inputBackground = Color(0xFF142534);
  static const Color divider = Color(0xFF243746);

  // Text colors
  static const Color textPrimary = Color(0xFFF5F7F8);
  static const Color textSecondary = Color(0xFFA7B1BA);
  static const Color textHint = Color(0xFF71808D);
  static const Color textOnPrimary = Colors.white;

  // Chat message colors
  static const Color senderBubble = Color(0xFF087F79);
  static const Color receiverBubble = Color(0xFF172938);
  static const Color messageTime = Color(0xFF91A1AC);

  // Status colors
  static const Color success = Color(0xFF19C7B5);
  static const Color error = Color(0xFFFF625A);
  static const Color warning = Color(0xFFFFB74D);
  static const Color online = Color(0xFF31D69B);

  // Icons and navigation
  static const Color iconPrimary = Color(0xFFE9F0F2);
  static const Color iconSecondary = Color(0xFF8D9AA5);
  static const Color selectedNavigation = primary;
  static const Color unselectedNavigation = Color(0xFF87949E);

  // Other colors
  static const Color border = Color(0xFF2A3B49);
  static const Color overlay = Color(0x99020F1C);
  static const Color transparent = Colors.transparent;

  // Prevent object creation
  const AppColors._();
}