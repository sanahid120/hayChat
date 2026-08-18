import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hay_chat/app/app_strings.dart';
import 'package:hay_chat/app/models/user_model.dart';
import 'package:hay_chat/features/chat/presentation/screens/chat_screen.dart';
import 'package:hay_chat/shared/presentation/data/nav_bar_provider.dart';
import 'package:provider/provider.dart';

import '../../../../app/app_colors.dart';
import '../../../../auth/presentation/screens/sign_in_screen.dart';
import '../widgets/home_contact_list_Tile.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final TextEditingController searchController = TextEditingController();
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.appName,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        actions: [
          PopupMenuButton<int>(
            onSelected: onMenuSelected,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 1, child: Text('LogOut')),
              const PopupMenuItem(value: 2, child: Text('New Secret Chat')),
              const PopupMenuItem(value: 3, child: Text('Linked Devices')),
              const PopupMenuItem(value: 4, child: Text('Settings')),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search Conversation',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('conversation')
            .doc(_currentUid)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading chats: ${snapshot.error}",
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No conversations yet",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<HomepageMainNavProvider>().moveToContacts();
                    },
                    child: const Text("Start chatting"),
                  ),
                ],
              ),
            );
          }

          final conversations = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: conversations.length,
            separatorBuilder: (context, index) =>
                const Divider(color: AppColors.divider, indent: 80, height: 1),
            itemBuilder: (context, index) {
              final data = conversations[index].data() as Map<String, dynamic>;
              final user = UserModel(
                uid: data['otherUserUid'],
                name: data['otherUserName'] ,
                email: data['otherUserEmail'] ,
                profilePicture: data['otherUserProfile'],
              );

              return HomeContactTile(
                user: user,
                lastMessage: data['lastMessage'],
                timestamp: data['timestamp'] as Timestamp?,
                isSeen: data['isSeen'] ?? false,
                isReceived: data['isReceived'] ?? false,
                lastMessageSenderId: data['lastMessageSenderId'],
                unreadCount: data['unreadCount'] ?? 0,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    ChatScreen.routeName,
                    arguments: user,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void onMenuSelected(int value) {
    if (value == 1) logout();
  }

  void logout() {
    FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(
      context,
      SignInScreen.routeName,
      (route) => false,
    );
  }
}
