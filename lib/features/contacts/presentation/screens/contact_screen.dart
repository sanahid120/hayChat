import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hay_chat/app/models/user_model.dart';
import 'package:hay_chat/features/chat/presentation/providers/chat_provider.dart';
import 'package:provider/provider.dart';

import '../../../../app/app_colors.dart';
import '../../../../auth/presentation/screens/sign_in_screen.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../home/presentation/providers/homescreen_provider.dart';
import '../providers/contact_screen_provider.dart';
import '../widgets/contact_scree_list_Tile.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId != null) {
      context.read<HomescreenProvider>().listenToConversations(currentUserId);
    }
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
          'Contacts',
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
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Consumer<ContactScreenProvider>(
              builder: (context, provider, child) {
                return TextField(
                  controller: _searchController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.search,
                  autocorrect: false,
                  style: const TextStyle(color: AppColors.textPrimary),
                  onChanged: provider.updateSearchQuery,
                  onSubmitted: provider.searchEmail,
                  decoration: InputDecoration(
                    hintText: 'Search by email',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.primary,
                    ),
                    suffixIcon: provider.query.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              provider.clearSearch();
                            },
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: Consumer<ContactScreenProvider>(
        builder: (context, provider, child) {
          if (provider.isSearching) {
            return _buildSearchResults(provider);
          }

          return _buildRecentContacts();
        },
      ),
    );
  }

  Widget _buildSearchResults(ContactScreenProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                provider.error!,
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  provider.searchEmail(provider.query);
                },
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.searchResults.isEmpty) {
      return const Center(
        child: Text(
          'No users found',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: provider.searchResults.length,
      separatorBuilder: (context, index) {
        return const Divider(color: AppColors.divider, indent: 80);
      },
      itemBuilder: (context, index) {
        final user = provider.searchResults[index];

        return HomepageContactsCard(
          user: user,
          onTap: () {
            _openChat(user);
          },
        );
      },
    );
  }

  Widget _buildRecentContacts() {
    return Consumer<HomescreenProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.conversations.isEmpty) {
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

        final conversations = provider.conversations;

        if (conversations.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: AppColors.textHint,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No contacts yet',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Search for users by email to start chatting.',
                    style: TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: conversations.length,
          separatorBuilder: (context, index) {
            return const Divider(color: AppColors.divider, indent: 80);
          },
          itemBuilder: (context, index) {
            final conversation = conversations[index];
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

                return HomepageContactsCard(
                  user: user,
                  timestamp: timestamp,
                  onTap: () {
                    _openChat(user);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _openChat(UserModel user) {
    Navigator.pushNamed(context, ChatScreen.routeName, arguments: user);
  }

  void _onMenuSelected(int value) {
    if (value == 1) {
      _logout();
    }
  }

  Future<void> _logout() async {
    final chatProvider = context.read<ChatProvider>();
    final homeProvider = context.read<HomescreenProvider>();
    final contactProvider = context.read<ContactScreenProvider>();

    chatProvider.stopGlobalMessageListener();
    contactProvider.clearSearch();
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
