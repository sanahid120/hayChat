import 'package:flutter/material.dart';

class ScaffoldMessage {
  static void showMessage(
    String msg,
    BuildContext context,
    Color textColor,
    Color? backgroundColor,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: textColor),
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
