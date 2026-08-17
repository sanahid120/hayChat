import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hay_chat/app/app_colors.dart';
import 'package:hay_chat/app/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../app/asset_paths.dart';
import '../../../../app/urls.dart';
import '../../../../shared/presentation/data/nav_bar_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _isLoading = true;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

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
        if (mounted) {
          setState(() => _isLoading = false);
          // Show error to user if network fails
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to connect. Please check your internet.'),
            ),
          );
        }
      }
    }
  }

  Future<String?> _uploadToCloudinary(File file) async {
    String cloudName = Urls.cloudName;
    String uploadPreset = "haychat";

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonResponse = jsonDecode(responseString);
        return jsonResponse['secure_url'] as String;
      } else {
        debugPrint('Cloudinary upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _imageFile = pickedFile;
          _isUploading = true;
        });

        final String? imageUrl = await _uploadToCloudinary(
          File(pickedFile.path),
        );

        if (imageUrl != null && mounted) {
          // Update Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .update({'profilePicture': imageUrl});

          setState(() {
            _user?.profilePicture = imageUrl;
          });
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated!')),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Upload failed. Check your connection.'),
            ),
          );
        }

        if (mounted) setState(() => _isUploading = false);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_, __) =>
          context.read<HomepageMainNavProvider>().updateIndex(0),
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
                      Center(
                        child: InkWell(
                          onTap: _isUploading ? null : _pickImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 65,
                                backgroundColor: AppColors.surface,
                                backgroundImage: _getProfileImage(),
                                child: _isUploading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              if (!_isUploading)
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
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _user?.name ?? 'User Name',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
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

  ImageProvider _getProfileImage() {
    if (_imageFile != null) {
      return FileImage(File(_imageFile!.path));
    }
    if (_user?.profilePicture != null &&
        _user!.profilePicture!.startsWith('https')) {
      return Image.network(
        _user!.profilePicture!,
        cacheHeight: 100,
        cacheWidth: 100,
      ).image;
    } else {
      return const AssetImage(AssetPaths.illustration);
    }
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
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
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
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
