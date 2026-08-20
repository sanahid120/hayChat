import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hay_chat/app/app_strings.dart';
import 'package:hay_chat/app/models/user_model.dart';
import 'package:hay_chat/features/chat/presentation/screens/chat_screen.dart';
import 'package:hay_chat/features/chat/presentation/providers/chat_provider.dart';
import 'package:hay_chat/shared/presentation/data/nav_bar_provider.dart';
import 'package:provider/provider.dart';

import '../../../../app/app_colors.dart';
import '../../../../auth/presentation/screens/sign_in_screen.dart';
import '../providers/homescreen_provider.dart';
import '../widgets/home_contact_list_Tile.dart';
import '../widgets/no_conversation_screen_widget.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final TextEditingController searchController = TextEditingController();
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomescreenProvider>().listenToConversations(_currentUid);
      context.read<ChatProvider>().startGlobalMessageListener();
    });
  }

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
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                context.read<HomescreenProvider>().searchConversations(value);
              },
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
      body: Consumer<HomescreenProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }

          if (provider.conversations.isEmpty) {
            return const NoConversationWidget();
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.conversations.length,
            separatorBuilder: (context, index) =>
                const Divider(color: AppColors.divider, indent: 80, height: 1),
            itemBuilder: (context, index) {
              final data = provider.conversations[index].data() as Map<String, dynamic>;
              final otherUserId = data['otherUserUid'] as String;

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(otherUserId).snapshots(),
                builder: (context, userSnapshot) {
                  UserModel user;
                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    user = UserModel.fromJson(userSnapshot.data!.data() as Map<String, dynamic>, otherUserId);
                  } else {
                    user = UserModel(
                      uid: otherUserId,
                      name: data['otherUserName'] ?? 'User',
                      email: data['otherUserEmail'] ?? '',
                      profilePicture: data['otherUserProfile'],
                    );
                  }

                  return HomeContactTile(
                    user: user,
                    lastMessage: data['lastMessage'],
                    timestamp: data['timestamp'] as Timestamp?,
                    isSeen: data['isSeen'] ?? false,
                    isReceived: data['isReceived'] ?? false,
                    lastMessageSenderId: data['lastMessageSenderId'],
                    unreadCount: data['unreadCount'] ?? 0,
                    onTap: () async {
                      await context
                          .read<ChatProvider>()
                          .markMessagesAsSeen(otherUserId);
                      if (!context.mounted) return;
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
