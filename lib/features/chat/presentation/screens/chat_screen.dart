import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hay_chat/app/app_colors.dart';
import 'package:hay_chat/app/methods/scaffold_message.dart';
import 'package:hay_chat/app/models/user_model.dart';
import 'package:hay_chat/features/chat/presentation/data/models/chat_model.dart';

import '../widgets/app_bar_widget.dart';
import '../widgets/message_input_area_widget.dart';

class ChatScreen extends StatefulWidget {
  final UserModel? receiverUser;

  const ChatScreen({super.key, this.receiverUser});

  static const String routeName = "/ChatScreen";

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  String? _currentUserName;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCurrentUserName();
    });
  }

  Future<void> _fetchCurrentUserName() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _currentUserName = doc.data()?['name'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching current user name: $e");
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final receiverUid = widget.receiverUser?.uid;
    if (receiverUid == null) {
      if (mounted) {
        ScaffoldMessage.showMessage(
          "Recipient ID missing. Try searching for them again.",
          context,
          AppColors.textPrimary,
          AppColors.error,
        );
      }
      return;
    }

    try {
      final chatMessage = ChatModel(
        sender: _currentUid,
        receiver: receiverUid,
        message: text,
        type: MessageType.text.name,
        dateTimestamp: DateTime.now(),
      );

      _messageController.clear();

      final batch = FirebaseFirestore.instance.batch();

      // Path for both users
      final senderChatRef = FirebaseFirestore.instance
          .collection('conversation')
          .doc(_currentUid)
          .collection('messages')
          .doc(receiverUid)
          .collection('chats')
          .doc();

      final receiverChatRef = FirebaseFirestore.instance
          .collection('conversation')
          .doc(receiverUid)
          .collection('messages')
          .doc(_currentUid)
          .collection('chats')
          .doc();

      batch.set(senderChatRef, chatMessage.toMap());
      batch.set(receiverChatRef, chatMessage.toMap());

      // Metadata for chat lists
      final currentUser = FirebaseAuth.instance.currentUser;
      final metaDataSender = {
        'lastMessage': text,
        'timestamp': FieldValue.serverTimestamp(),
        'otherUserUid': receiverUid,
        'otherUserName': widget.receiverUser?.name ?? 'User',
        'otherUserEmail': widget.receiverUser?.email,
        'otherUserProfile': widget.receiverUser?.profilePicture,
      };

      final metaDataReceiver = {
        'lastMessage': text,
        'timestamp': FieldValue.serverTimestamp(),
        'otherUserUid': _currentUid,
        'otherUserName': _currentUserName ?? currentUser?.displayName ?? 'User',
        'otherUserEmail': currentUser?.email,
        'otherUserProfile': currentUser?.photoURL,
      };

      batch.set(
        FirebaseFirestore.instance
            .collection('conversation')
            .doc(_currentUid)
            .collection('messages')
            .doc(receiverUid),
        metaDataSender,
        SetOptions(merge: true),
      );

      batch.set(
        FirebaseFirestore.instance
            .collection('conversation')
            .doc(receiverUid)
            .collection('messages')
            .doc(_currentUid),
        metaDataReceiver,
        SetOptions(merge: true),
      );

      await batch.commit();
    } catch (e) {
      if (mounted) {
        ScaffoldMessage.showMessage(
          "Failed to send: $e",
          context,
          AppColors.textPrimary,
          AppColors.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.receiverUser == null || widget.receiverUser!.uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Chat")),
        body: const Center(child: Text("Error: User information missing")),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        title: AppBarWidget(user: widget.receiverUser, onTap: () {}),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('conversation')
                  .doc(_currentUid)
                  .collection('messages')
                  .doc(widget.receiverUser!.uid)
                  .collection('chats')
                  .orderBy('dateTimestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "Start chatting with ${widget.receiverUser!.name}!",
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final msg = ChatModel.fromMap(
                      docs[index].data() as Map<String, dynamic>,
                    );
                    final bool isMe = msg.sender == _currentUid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? AppColors.senderBubble
                              : AppColors.receiverBubble,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 16),
                          ),
                        ),
                        child: Text(
                          msg.message,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          MessageInputAreaWidget(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}
