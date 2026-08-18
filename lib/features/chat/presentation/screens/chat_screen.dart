import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hay_chat/app/app_colors.dart';
import 'package:hay_chat/app/methods/scaffold_message.dart';
import 'package:hay_chat/app/models/user_model.dart';
import 'package:hay_chat/features/chat/presentation/data/models/chat_model.dart';
import 'package:intl/intl.dart';

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
    _markMessagesAsSeen();
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

  /// Marks incoming messages as seen so the sender gets the blue ticks
  Future<void> _markMessagesAsSeen() async {
    final receiverUid = widget.receiverUser?.uid;
    if (receiverUid == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();

      // 1. Reset my local unread count metadata
      final myMetaRef = FirebaseFirestore.instance
          .collection('conversation')
          .doc(_currentUid)
          .collection('messages')
          .doc(receiverUid);
      batch.set(myMetaRef, {'unreadCount': 0, 'isSeen': true}, SetOptions(merge: true));

      // 2. Mark "isSeen" in the OTHER person's collection (so THEY see blue ticks)
      final otherMessagesQuery = await FirebaseFirestore.instance
          .collection('conversation')
          .doc(receiverUid)
          .collection('messages')
          .doc(_currentUid)
          .collection('chats')
          .where('sender', isEqualTo: receiverUid)
          .where('isSeen', isEqualTo: false)
          .get();

      if (otherMessagesQuery.docs.isNotEmpty) {
        for (var doc in otherMessagesQuery.docs) {
          batch.update(doc.reference, {'isSeen': true, 'isReceived': true});
        }
        
        // 3. Update the metadata for the sender as well
        final senderMetaRef = FirebaseFirestore.instance
            .collection('conversation')
            .doc(receiverUid)
            .collection('messages')
            .doc(_currentUid);
        batch.set(senderMetaRef, {'isSeen': true, 'isReceived': true}, SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      debugPrint("Error marking messages as seen: $e");
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
    if (receiverUid == null) return;

    try {
      // Use a consistent ID for both copies
      final String msgId = DateTime.now().millisecondsSinceEpoch.toString() + _currentUid.substring(0, 3);

      final chatMessage = ChatModel(
        sender: _currentUid,
        receiver: receiverUid,
        message: text,
        type: MessageType.text.name,
        dateTimestamp: DateTime.now(),
        isSeen: false,
        isReceived: true,
      );

      _messageController.clear();
      final batch = FirebaseFirestore.instance.batch();

      final senderChatRef = FirebaseFirestore.instance
          .collection('conversation')
          .doc(_currentUid)
          .collection('messages')
          .doc(receiverUid)
          .collection('chats')
          .doc(msgId);

      final receiverChatRef = FirebaseFirestore.instance
          .collection('conversation')
          .doc(receiverUid)
          .collection('messages')
          .doc(_currentUid)
          .collection('chats')
          .doc(msgId);

      batch.set(senderChatRef, chatMessage.toMap());
      batch.set(receiverChatRef, chatMessage.toMap());

      final currentUser = FirebaseAuth.instance.currentUser;

      final metaDataSender = {
        'lastMessage': text,
        'timestamp': FieldValue.serverTimestamp(),
        'otherUserUid': receiverUid,
        'otherUserName': widget.receiverUser?.name ?? 'User',
        'otherUserProfile': widget.receiverUser?.profilePicture,
        'lastMessageSenderId': _currentUid,
        'isSeen': false,
        'isReceived': true,
      };

      final metaDataReceiver = {
        'lastMessage': text,
        'timestamp': FieldValue.serverTimestamp(),
        'otherUserUid': _currentUid,
        'otherUserName': _currentUserName ?? currentUser?.displayName ?? 'User',
        'otherUserProfile': currentUser?.photoURL,
        'lastMessageSenderId': _currentUid,
        'isSeen': false,
        'isReceived': true,
        'unreadCount': FieldValue.increment(1),
      };

      batch.set(senderChatRef.parent.parent!, metaDataSender, SetOptions(merge: true));
      batch.set(receiverChatRef.parent.parent!, metaDataReceiver, SetOptions(merge: true));

      await batch.commit();
      _scrollToBottom();
    } catch (e) {
      debugPrint("Send error: $e");
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return "";
    return DateFormat('hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        title: AppBarWidget(user: widget.receiverUser, onTap: () {}),
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

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  final lastDocData = snapshot.data!.docs.last.data() as Map<String, dynamic>;
                  if (lastDocData['sender'] != _currentUid && lastDocData['isSeen'] == false) {
                    _markMessagesAsSeen();
                  }
                }

                final messages = snapshot.data!.docs
                    .map((doc) => ChatModel.fromMap(doc.data() as Map<String, dynamic>))
                    .toList();

                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final bool isMe = msg.sender == _currentUid;

                    bool showDateHeader = false;
                    if (index == 0) {
                      showDateHeader = true;
                    } else {
                      final prevMsg = messages[index - 1];
                      if (msg.dateTimestamp != null && prevMsg.dateTimestamp != null) {
                        if (msg.dateTimestamp!.day != prevMsg.dateTimestamp!.day ||
                            msg.dateTimestamp!.month != prevMsg.dateTimestamp!.month ||
                            msg.dateTimestamp!.year != prevMsg.dateTimestamp!.year) {
                          showDateHeader = true;
                        }
                      }
                    }

                    return Column(
                      children: [
                        if (showDateHeader && msg.dateTimestamp != null)
                          DateHeaderWidget(date: msg.dateTimestamp!),
                        _buildMessageBubble(msg, isMe),
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

  Widget _buildMessageBubble(ChatModel msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 6),
        decoration: BoxDecoration(
          color: isMe ? AppColors.senderBubble : AppColors.receiverBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(msg.message, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_formatTime(msg.dateTimestamp),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.isSeen ? Icons.done_all : (msg.isReceived ? Icons.done_all : Icons.done),
                    size: 14,
                    color: msg.isSeen ? Colors.blue : Colors.grey,
                  ),
                ]
              ],
            ),
          ],
        ),
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
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Yesterday';
    }
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
