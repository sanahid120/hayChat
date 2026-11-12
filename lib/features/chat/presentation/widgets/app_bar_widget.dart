import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/asset_paths.dart';
import '../../../../app/models/user_model.dart';
import '../../../../core/services/presence_service.dart';

class AppBarWidget extends StatefulWidget {
  const AppBarWidget({super.key, required this.onTap, this.user});

  final VoidCallback onTap;
  final UserModel? user;

  @override
  State<AppBarWidget> createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {
  String? _userId;
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _profileStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _presenceStream;
  Timer? _statusRefreshTimer;

  @override
  void initState() {
    super.initState();
    _userId = widget.user?.uid;
    final userId = _userId;
    if (userId != null && userId.isNotEmpty) {
      final userReference = FirebaseFirestore.instance
          .collection('users')
          .doc(userId);
      _profileStream = userReference.snapshots();
      _presenceStream = userReference.collection('presence').snapshots();
      // Re-evaluate heartbeat freshness even if a disconnected client cannot
      // send a final offline update.
      _statusRefreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _statusRefreshTimer?.cancel();
    super.dispose();
  }

  ImageProvider _getProfileImage(String? profilePicture) {
    if (profilePicture != null && profilePicture.startsWith('http')) {
      return NetworkImage(profilePicture);
    }
    return const AssetImage(AssetPaths.illustration);
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final userId = _userId;
    if (userId == null || userId.isEmpty) {
      return _buildContent(
        context,
        user?.name,
        user?.profilePicture,
        isOnline: false,
        status: 'offline',
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _profileStream,
      builder: (context, profileSnapshot) {
        final profile = profileSnapshot.data?.data();
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _presenceStream,
          builder: (context, presenceSnapshot) {
            final presence = _readPresence(presenceSnapshot.data?.docs ?? []);
            return _buildContent(
              context,
              profile?['name'] as String? ?? user?.name,
              profile?['profilePicture'] as String? ?? user?.profilePicture,
              isOnline: presence.isOnline,
              status: presence.status,
            );
          },
        );
      },
    );
  }

  _PresenceDisplay _readPresence(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> sessions,
  ) {
    DateTime? latestActiveAt;
    var isOnline = false;
    final now = DateTime.now();

    for (final session in sessions) {
      final data = session.data();
      final timestamp = data['lastActiveAt'];
      if (timestamp is! Timestamp) continue;

      final lastActiveAt = timestamp.toDate();
      if (latestActiveAt == null || lastActiveAt.isAfter(latestActiveAt)) {
        latestActiveAt = lastActiveAt;
      }
      final age = now.difference(lastActiveAt);
      if (data['isOnline'] == true && age <= PresenceService.staleAfter) {
        isOnline = true;
      }
    }

    return _PresenceDisplay(
      isOnline: isOnline,
      status: isOnline ? 'online' : _formatLastActive(latestActiveAt),
    );
  }

  String _formatLastActive(DateTime? lastActiveAt) {
    if (lastActiveAt == null) return 'offline';

    final age = DateTime.now().difference(lastActiveAt);
    if (age.isNegative || age.inSeconds < 60) return 'last active just now';
    if (age.inMinutes < 60) {
      return 'last active ${age.inMinutes}m ago';
    }
    if (age.inHours < 24) return 'last active ${age.inHours}h ago';
    return 'last active ${DateFormat('MMM d, h:mm a').format(lastActiveAt)}';
  }

  Widget _buildContent(
    BuildContext context,
    String? name,
    String? image, {
    required bool isOnline,
    required String status,
  }) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: _getProfileImage(image),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: isOnline ? AppColors.online : AppColors.textHint,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
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
                  status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isOnline ? AppColors.online : AppColors.textHint,
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

class _PresenceDisplay {
  const _PresenceDisplay({required this.isOnline, required this.status});

  final bool isOnline;
  final String status;
}
