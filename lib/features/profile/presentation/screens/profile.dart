import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hay_chat/app/app_colors.dart';
import 'package:hay_chat/app/models/user_model.dart';
import 'package:provider/provider.dart';

import '../../../../app/asset_paths.dart';
import '../../../../shared/presentation/data/nav_bar_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (doc.exists && mounted) {
          setState(() {
            _user = UserModel.fromJson(doc.data()!, doc.id);
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint('Error fetching profile: $e');
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_,_) => context.read<HomepageMainNavProvider>().updateIndex(0),
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.iconPrimary),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // Profile Image Section
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 65,
                              backgroundColor: AppColors.surface,
                              backgroundImage: (_user?.profilePicture != null &&
                                      _user?.profilePicture != 'null currently' &&
                                      _user!.profilePicture!.startsWith('http'))
                                  ? NetworkImage(_user!.profilePicture!)
                                  : const AssetImage(AssetPaths.illustration) as ImageProvider,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Name and Bio Section
                      Text(
                        _user?.name ?? 'User Name',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Hey there! I am using HayChat.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 35),
                      // Settings Menu Section
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _buildOption(
                              context,
                              icon: Icons.person_outline,
                              title: 'Account',
                              subtitle: 'Edit your information',
                            ),
                            _buildDivider(),
                            _buildOption(
                              context,
                              icon: Icons.lock_outline,
                              title: 'Privacy',
                              subtitle: 'Manage your privacy',
                            ),
                            _buildDivider(),
                            _buildOption(
                              context,
                              icon: Icons.notifications_none,
                              title: 'Notifications',
                              subtitle: 'Manage notification settings',
                            ),
                            _buildDivider(),
                            _buildOption(
                              context,
                              icon: Icons.wb_sunny_outlined,
                              title: 'Appearance',
                              subtitle: 'Theme, wallpaper',
                            ),
                            _buildDivider(),
                            _buildOption(
                              context,
                              icon: Icons.data_usage_outlined,
                              title: 'Data and Storage',
                              subtitle: 'Network usage, auto-download',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildOption(BuildContext context,
      {required IconData icon, required String title, required String subtitle}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: AppColors.iconSecondary, size: 26),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.iconSecondary),
      onTap: () {},
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: AppColors.divider,
      height: 1,
      indent: 65,
      endIndent: 20,
    );
  }
}
