
import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../../../shared/utils/validators.dart';

class DateHeaderWidget extends StatelessWidget {
  final DateTime date;
  const DateHeaderWidget({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 18),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          Validators.formatDate(date),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }


}
