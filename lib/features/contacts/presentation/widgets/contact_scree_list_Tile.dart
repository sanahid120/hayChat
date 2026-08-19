import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hay_chat/shared/utils/validators.dart';
import '../../../../app/app_colors.dart';
import '../../../../app/asset_paths.dart';
import '../../../../app/models/user_model.dart';

class HomepageContactsCard extends StatelessWidget {
  const HomepageContactsCard({
    super.key,
    required this.onTap,
    required this.user,
    this.timestamp,
  });

  final VoidCallback onTap;
  final UserModel user;
  final Timestamp? timestamp;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 28,
        backgroundImage:
            (user.profilePicture != null &&
                user.profilePicture != 'null currently' &&
                user.profilePicture!.startsWith('http'))
            ? Image.network(user.profilePicture!).image
            : AssetImage(AssetPaths.illustration),
      ),
      title: Text(
        user.name ?? "User",
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        user.email,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (timestamp != null)
            Text(
              Validators.formatTimestamp(timestamp),
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.textHint),
            ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.iconSecondary,
            size: 18,
          ),
        ],
      ),
    );
  }
}
