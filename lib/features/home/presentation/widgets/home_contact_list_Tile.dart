import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../app/app_colors.dart';
import '../../../../app/asset_paths.dart';
import '../../../../app/models/user_model.dart';

class HomeContactTile extends StatelessWidget {
  const HomeContactTile({
    super.key,
    required this.onTap,
    required this.user,
    this.lastMessage,
    this.timestamp,
  });

  final VoidCallback onTap;
  final UserModel user;
  final String? lastMessage;
  final Timestamp? timestamp;

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      final hour = date.hour > 12
          ? date.hour - 12
          : (date.hour == 0 ? 12 : date.hour);
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
        backgroundImage: user.profilePicture !=null && user.profilePicture!.startsWith('https')
            ? Image.network(
                user.profilePicture!,
                fit: BoxFit.cover,
                cacheHeight: 100,
                cacheWidth: 100,
              ).image
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
        lastMessage ?? user.email,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: lastMessage != null
              ? AppColors.textSecondary
              : AppColors.textHint,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTimestamp(timestamp),
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.textHint),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
