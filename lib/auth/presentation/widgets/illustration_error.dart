import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';

class IllustrationError extends StatelessWidget {
  const IllustrationError({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
        ),
      ),
      child: const Icon(
        Icons.chat_bubble_rounded,
        color: AppColors.primary,
        size: 90,
      ),
    );
  }
}