import 'package:flutter/material.dart';
import '../../../../app/app_colors.dart';
import '../../../../app/asset_paths.dart';
import '../../../../app/models/user_model.dart';

class AppBarWidget extends StatelessWidget {
  const AppBarWidget({super.key, required this.onTap, this.user});

  final VoidCallback onTap;
  final UserModel? user;
  ImageProvider _getProfileImage() {

    if (user?.profilePicture != null &&
        user!.profilePicture!.startsWith('https')) {
      return NetworkImage(
        user!.profilePicture!,
      );
    } else {
      return const AssetImage(AssetPaths.illustration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: _getProfileImage(),

          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user?.name ?? "Chat",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Online",
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
