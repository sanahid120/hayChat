import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hay_chat/app/models/user_model.dart';
import '../../../../app/app_colors.dart';
import '../../../../auth/presentation/screens/sign_in_screen.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../widgets/contact_scree_list_Tile.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TextEditingController searchController = TextEditingController();
  List<UserModel> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUser(String email) async {
    final query = email.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
        _error = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoading = true;
      _error = null;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: query)
          .get();

      final results = querySnapshot.docs.map((doc) {
        return UserModel.fromJson(doc.data(), doc.id);
      }).where((user) => user.uid != _currentUid).toList();

      setState(() {
        _searchResults = results;
        if (results.isEmpty) {
          _error = "No user found with this email.";
        }
      });
    } catch (e) {
      setState(() {
        _error = "An error occurred during search.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Contacts",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: AppColors.textPrimary),
              onChanged: (value) {
                if (value.isEmpty && _isSearching) {
                  setState(() {
                    _isSearching = false;
                    _error = null;
                  });
                }
              },
              onSubmitted: _searchUser,
              decoration: InputDecoration(
                hintText: 'Search by email...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
                  onPressed: () => _searchUser(searchController.text),
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
      body: _isSearching ? _buildSearchResults() : _buildRecentContacts(),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: AppColors.textSecondary)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => const Divider(color: AppColors.divider, indent: 80),
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return HomepageContactsCard(
          user: user,
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
  }

  Widget _buildRecentContacts() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('conversation')
          .doc(_currentUid)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_outline, size: 80, color: AppColors.textHint),
                const SizedBox(height: 16),
                const Text(
                  "No contacts yet",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Search for users by email to start chatting",
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final conversations = snapshot.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: conversations.length,
          separatorBuilder: (context, index) => const Divider(color: AppColors.divider, indent: 80),
          itemBuilder: (context, index) {
            final data = conversations[index].data() as Map<String, dynamic>;
            final user = UserModel(
              uid: data['otherUserUid'],
              name: data['otherUserName'] ?? 'User',
              email: data['otherUserEmail'] ?? '',
              profilePicture: data['otherUserProfile'],
            );

            return HomepageContactsCard(
              user: user,
              timestamp: data['timestamp'] as Timestamp?,
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
