import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hay_chat/app/app_strings.dart';
import 'package:hay_chat/app/models/user_model.dart';
import 'package:hay_chat/features/chat/presentation/providers/chat_provider.dart';
import 'package:hay_chat/features/chat/presentation/screens/chat_screen.dart';
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId != null) {
      context.read<HomescreenProvider>().listenToConversations(currentUserId);
    }

    context.read<ChatProvider>().startGlobalMessageListener();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          AppStrings.appName,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<int>(
            onSelected: _onMenuSelected,
            itemBuilder: (context) => const [
              PopupMenuItem<int>(value: 1, child: Text('Log out')),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: context.read<HomescreenProvider>().searchConversations,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search conversations',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: Consumer<HomescreenProvider>(
                  builder: (context, provider, child) {
                    if (provider.searchQuery.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return IconButton(
                      onPressed: () {
                        _searchController.clear();

                        context.read<HomescreenProvider>().searchConversations(
                          '',
                        );
                      },
                      icon: const Icon(Icons.close),
                    );
                  },
                ),
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
        builder: (context, provider, child) {
          if (provider.isLoading && provider.conversations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return _buildErrorState(provider.errorMessage!);
          }

          if (provider.conversations.isEmpty) {
            if (provider.searchQuery.isNotEmpty) {
              return const Center(
                child: Text(
                  'No matching conversations found.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            return const NoConversationWidget();
          }

          return RefreshIndicator(
            onRefresh: () async {
              final currentUserId = FirebaseAuth.instance.currentUser?.uid;

              if (currentUserId != null) {
                provider.listenToConversations(currentUserId);
              }
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: provider.conversations.length,
              separatorBuilder: (context, index) {
                return const Divider(
                  color: AppColors.divider,
                  indent: 80,
                  height: 1,
                );
              },
              itemBuilder: (context, index) {
                final conversation = provider.conversations[index];

                final conversationUser = UserModel(
                  uid: conversation.otherUserUid,
                  name: conversation.otherUserName,
                  email: conversation.otherUserEmail,
                  profilePicture: conversation.otherUserProfile,
                );

                final timestamp = conversation.lastMessageAt == null
                    ? null
                    : Timestamp.fromDate(conversation.lastMessageAt!);

                return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(conversation.otherUserUid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final user = snapshot.hasData && snapshot.data!.exists
                        ? UserModel.fromJson(
                            snapshot.data!.data()!,
                            snapshot.data!.id,
                          )
                        : conversationUser;

                    return HomeContactTile(
                      user: user,
                      lastMessage: conversation.lastMessage,
                      timestamp: timestamp,
                      isSeen: conversation.lastMessageIsSeen,
                      isReceived: conversation.lastMessageIsDelivered,
                      lastMessageSenderId: conversation.lastMessageSenderId,
                      unreadCount: conversation.unreadCount,
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
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final currentUserId = FirebaseAuth.instance.currentUser?.uid;

                if (currentUserId != null) {
                  context.read<HomescreenProvider>().listenToConversations(
                    currentUserId,
                  );
                }
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  void _onMenuSelected(int value) {
    if (value == 1) {
      _logout();
    }
  }

  Future<void> _logout() async {
    final homeProvider = context.read<HomescreenProvider>();
    final chatProvider = context.read<ChatProvider>();

    chatProvider.stopGlobalMessageListener();
    await homeProvider.stopListening();
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      SignInScreen.routeName,
      (route) => false,
    );
  }
}
