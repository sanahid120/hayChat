import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../app/app_colors.dart';
import '../../../../app/asset_paths.dart';
import '../../../../app/models/user_model.dart';

class AppBarWidget extends StatefulWidget {
  const AppBarWidget({super.key, required this.onTap, this.user});

  final VoidCallback onTap;
  final UserModel? user;

  @override
  State<AppBarWidget> createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {
  ImageProvider _getProfileImage(String? profilePicture) {
    if (profilePicture != null && profilePicture.startsWith('http')) {
      return NetworkImage(profilePicture);
    }
    return const AssetImage(AssetPaths.illustration);
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    if (user?.uid == null || user!.uid!.isEmpty) {
      return _buildContent(context, user?.name, user?.profilePicture);
    }
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final profile = snapshot.data?.data();
        return _buildContent(
          context,
          profile?['name'] as String? ?? user.name,
          profile?['profilePicture'] as String? ?? user.profilePicture,
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, String? name, String? image) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Row(
        children: [
          CircleAvatar(radius: 20, backgroundImage: _getProfileImage(image)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name ?? 'User',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'online',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.online,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
