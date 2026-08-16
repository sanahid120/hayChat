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
  final ScrollController _scrollController = ScrollController();
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  String? _currentUserName;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserName();
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
    _scrollController.dispose();
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
      
      // Scroll to bottom after sending
      _scrollToBottom();
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

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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
        title: AppBarWidget(
          user: widget.receiverUser,
          onTap: () {},
        ),
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.more_vert_rounded)),
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
                  .orderBy('dateTimestamp', descending: false)
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
                final messages = docs
                    .map((doc) =>
                        ChatModel.fromMap(doc.data() as Map<String, dynamic>))
                    .toList();

                // Scroll to bottom on new messages if we are near bottom
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final bool isMe = msg.sender == _currentUid;

                    bool showDateHeader = false;
                    if (index == 0) {
                      showDateHeader = true;
                    } else {
                      final prevMsg = messages[index - 1];
                      if (msg.dateTimestamp != null &&
                          prevMsg.dateTimestamp != null) {
                        if (msg.dateTimestamp!.day != prevMsg.dateTimestamp!.day ||
                            msg.dateTimestamp!.month !=
                                prevMsg.dateTimestamp!.month ||
                            msg.dateTimestamp!.year !=
                                prevMsg.dateTimestamp!.year) {
                          showDateHeader = true;
                        }
                      }
                    }

                    return Column(
                      children: [
                        if (showDateHeader && msg.dateTimestamp != null)
                          DateHeaderWidget(date: msg.dateTimestamp!),
                        Align(
                          alignment:
                              isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
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
                                  color: AppColors.textPrimary, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
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

class DateHeaderWidget extends StatelessWidget {
  final DateTime date;
  const DateHeaderWidget({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 18),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _formatDate(date),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }
    return "${date.day}/${date.month}/${date.year}";
  }
}
