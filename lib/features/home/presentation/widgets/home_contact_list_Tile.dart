
import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/asset_paths.dart';


class HomepageContactsCard extends StatelessWidget {
  const HomepageContactsCard({
    super.key,
    required this.onTap,
  });
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        title: Text(
          "S A NAHID",
          style: TextTheme.of(context).titleLarge?.copyWith(
            color: AppColors.textPrimary,
            overflow: .ellipsis,
          ),
        ),
        subtitle: Text(
          "S A NAHID",
          style: TextTheme.of(context).titleSmall?.copyWith(
            color: AppColors.textSecondary,
            overflow: .ellipsis,
          ),
        ),
        trailing: Column(
          children: [
            Text(
              '10.30 AM',
              style: TextTheme.of(
                context,
              ).bodyLarge?.copyWith(color: AppColors.textHint),
            ),
            SizedBox(height: 10),

            Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('10'),
            ),
          ],
        ),
        leading: CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage(AssetPaths.illustration),
        ),
      ),
    );
  }
}
