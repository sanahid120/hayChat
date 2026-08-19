import 'package:flutter/material.dart';
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
  ImageProvider _getProfileImage() {
    if (widget.user!.profilePicture != null && widget.user!.profilePicture!.startsWith('https')) {
      return Image.network(widget.user!.profilePicture!).image;
    } else {
      return const AssetImage(AssetPaths.illustration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Row(
        children: [
          CircleAvatar(radius: 20, backgroundImage: _getProfileImage()),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.user?.name ?? "User",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "online",
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
