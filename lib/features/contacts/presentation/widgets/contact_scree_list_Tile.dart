import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final period = date.hour >= 12 ? 'PM' : 'AM';
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute $period';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: (user.profilePicture != null && 
                          user.profilePicture != 'null currently' && 
                          user.profilePicture!.startsWith('http'))
            ? Image.network(user.profilePicture!).image
            : AssetImage(AssetPaths.illustration) ,
      ),
      title: Text(
        user.name ?? "No Name",
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        user.email,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (timestamp != null)
            Text(
              _formatTimestamp(timestamp),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textHint,
                  ),
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
