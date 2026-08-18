import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    this.isSeen = false,
    this.isReceived = false,
    this.lastMessageSenderId,
    this.unreadCount = 0,
  });

  final VoidCallback onTap;
  final UserModel user;
  final String? lastMessage;
  final Timestamp? timestamp;
  final bool isSeen;
  final bool isReceived;
  final String? lastMessageSenderId;
  final int unreadCount;

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
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final bool isMe = lastMessageSenderId == currentUid;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: user.profilePicture != null && user.profilePicture!.startsWith('https')
            ? Image.network(user.profilePicture!).image
            : const AssetImage(AssetPaths.illustration) as ImageProvider,
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
      subtitle: Row(
        children: [
          if (isMe && lastMessage != null) ...[
            Icon(
              isSeen ? Icons.done_all : (isReceived ? Icons.done_all : Icons.done),
              size: 16,
              color: isSeen ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              lastMessage ?? user.email,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: lastMessage != null ? AppColors.textSecondary : AppColors.textHint,
                    fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTimestamp(timestamp),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: unreadCount > 0 ? AppColors.primary : AppColors.textHint,
                  fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                ),
          ),
          const SizedBox(height: 6),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const SizedBox(height: 22),
        ],
      ),
    );
  }
}
