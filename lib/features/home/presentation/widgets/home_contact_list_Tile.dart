import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../app/app_colors.dart';
import '../../../../app/asset_paths.dart';
import '../../../../app/models/user_model.dart';

class HomeContactTile extends StatefulWidget {
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

  @override
  State<HomeContactTile> createState() => _HomeContactTileState();
}

class _HomeContactTileState extends State<HomeContactTile> {
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
  ImageProvider _getImage() {
    final profilePicture = widget.user.profilePicture;

    if (profilePicture != null && profilePicture.startsWith('http')) {
      return Image.network(profilePicture).image;
    }

    return AssetImage(AssetPaths.illustration);
  }





  @override
  Widget build(BuildContext context) {
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final bool isMe = widget.lastMessageSenderId == currentUid;

    return ListTile(
      onTap: widget.onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.surface,
        backgroundImage: _getImage(),
      ),
      title: Text(
        widget.user.name ?? "User",
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          if (isMe && widget.lastMessage != null) ...[
            Icon(
              widget.isSeen ? Icons.done_all : (widget.isReceived ? Icons.done_all : Icons.done),
              size: 16,
              color: widget.isSeen ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              widget.lastMessage ?? widget.user.email,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: widget.lastMessage != null ? AppColors.textSecondary : AppColors.textHint,
                    fontWeight: widget.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
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
            _formatTimestamp(widget.timestamp),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: widget.unreadCount > 0 ? AppColors.primary : AppColors.textHint,
                  fontWeight: widget.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                ),
          ),
          const SizedBox(height: 6),
          if (widget.unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                widget.unreadCount > 99 ? '99+' : widget.unreadCount.toString(),
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
