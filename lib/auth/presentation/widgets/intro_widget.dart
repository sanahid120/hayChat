import '../../../app/app_colors.dart';
import 'package:flutter/material.dart';

import '../models/onboarding_model.dart';
import 'illustration_error.dart';
class IntroductionPage extends StatelessWidget {
  final IntroductionModel introduction;

  const IntroductionPage({
    super.key,
    required this.introduction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
      child: Column(
        children: [
          Text(
            introduction.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            introduction.highlightedTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            introduction.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Image.asset(
                introduction.imagePath,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (
                    BuildContext context,
                    Object error,
                    StackTrace? stackTrace,
                    ) {
                  return const IllustrationError();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}