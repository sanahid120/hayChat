import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';

class AppBarWidget extends StatelessWidget {
  const AppBarWidget({
    super.key,
    required this.onTap,
  });
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:onTap,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage("assets/images/illustration.png"),
              ),
            ],
          ),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "S A N A H I D",
                style: TextTheme.of(
                  context,
                ).titleLarge?.copyWith(color: AppColors.textPrimary),
              ),
              Text(
                "Online",
                style: TextTheme.of(
                  context,
                ).titleLarge?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
