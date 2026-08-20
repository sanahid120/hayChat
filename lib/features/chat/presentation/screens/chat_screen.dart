import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hay_chat/app/app_colors.dart';
import 'package:hay_chat/app/models/user_model.dart';
import 'package:hay_chat/features/chat/presentation/data/models/chat_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/date_header_widget.dart';
import '../widgets/message_input_area_widget.dart';

class ChatScreen extends StatefulWidget {
  final UserModel? receiverUser;

  const ChatScreen({super.key, this.receiverUser});

  static const String routeName = '/ChatScreen';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  late final ChatProvider _chatProvider;
  String? _lastRenderedMessageId;
  String? _lastSeenMessageId;
  bool _hasRenderedMessages = false;
  bool _scrollScheduled = false;
  bool _seenMarkScheduled = false;

  @override
  void initState() {
    super.initState();
    _chatProvider = context.read<ChatProvider>();
    _chatProvider.setActiveChatUser(widget.receiverUser?.uid);
    _chatProvider.fetchCurrentUserName();
    _markMessagesAsSeen();
  }

  Future<void> _markMessagesAsSeen() async {
    final receiverUid = widget.receiverUser?.uid;
    if (receiverUid == null || receiverUid.isEmpty) return;

    await _chatProvider.markMessagesAsSeen(receiverUid);
  }

  void _markNewMessagesAsSeen(String? latestMessageId, String? senderId) {
    if (latestMessageId == null ||
        latestMessageId == _lastSeenMessageId ||
        senderId == _currentUid ||
        _seenMarkScheduled) {
      return;
    }

    _lastSeenMessageId = latestMessageId;
    _seenMarkScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _seenMarkScheduled = false;
      if (!mounted) return;
      await _markMessagesAsSeen();
    });
  }

  @override
  void dispose() {
    _chatProvider.setActiveChatUser(null);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    final receiverUid = widget.receiverUser?.uid;
    if (text.isEmpty || receiverUid == null || receiverUid.isEmpty) return;

    _messageController.clear();

    await _chatProvider.sendMessage(
      receiverUid: receiverUid,
      text: text,
      receiverName: widget.receiverUser?.name ?? 'User',
      receiverProfile: widget.receiverUser?.profilePicture,
      receiverEmail: widget.receiverUser?.email,
    );

    _scrollToBottom();
  }

  void _scrollToBottom({bool force = false}) {
    if (_scrollScheduled) return;
    if (!force) {
      if (!_scrollController.hasClients) return;
      final position = _scrollController.position;
      if (position.maxScrollExtent - position.pixels > 160) return;
    }

    _scrollScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollScheduled = false;
      if (!mounted || !_scrollController.hasClients) return;
      final maxScroll = _scrollController.position.maxScrollExtent;
      if (maxScroll <= 0) return;
      _scrollController.animateTo(
        maxScroll,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  int _compareMessageDocs(
    QueryDocumentSnapshot<Object?> left,
    QueryDocumentSnapshot<Object?> right,
  ) {
    final leftData = left.data() as Map<String, dynamic>;
    final rightData = right.data() as Map<String, dynamic>;
    final leftTimestamp =
        leftData['dateTimestamp'] ?? leftData['clientTimestamp'];
    final rightTimestamp =
        rightData['dateTimestamp'] ?? rightData['clientTimestamp'];
    final leftMillis = leftTimestamp is Timestamp
        ? leftTimestamp.millisecondsSinceEpoch
        : -1;
    final rightMillis = rightTimestamp is Timestamp
        ? rightTimestamp.millisecondsSinceEpoch
        : -1;
    final timestampComparison = leftMillis.compareTo(rightMillis);
    return timestampComparison == 0
        ? left.id.compareTo(right.id)
        : timestampComparison;
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final receiverUid = widget.receiverUser?.uid;

    if (receiverUid == null || receiverUid.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Chat user not available.')),
      );
    }

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
              stream: _chatProvider.getChatStream(receiverUid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Unable to load messages: ${snapshot.error}'),
                  );
                }

                final messageDocs = snapshot.data?.docs.toList() ?? [];
                messageDocs.sort(_compareMessageDocs);
                final messages = messageDocs
                    .map(
                      (doc) =>
                          ChatModel.fromMap(doc.data() as Map<String, dynamic>),
                    )
                    .toList();

                final lastMessageId = messageDocs.isEmpty
                    ? null
                    : messageDocs.last.id;
                final latestMessage = messages.isEmpty ? null : messages.last;
                _markNewMessagesAsSeen(
                  lastMessageId,
                  latestMessage?.sender,
                );
                if (lastMessageId != _lastRenderedMessageId) {
                  _lastRenderedMessageId = lastMessageId;
                  _scrollToBottom(force: !_hasRenderedMessages);
                  _hasRenderedMessages = true;
                }

                if (messages.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }

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
                      if (msg.dateTimestamp != null &&
                          prevMsg.dateTimestamp != null) {
                        if (msg.dateTimestamp!.day !=
                                prevMsg.dateTimestamp!.day ||
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
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
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
            Text(
              msg.message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(msg.dateTimestamp),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.isSeen
                        ? Icons.done_all
                        : (msg.isReceived ? Icons.done_all : Icons.done),
                    size: 14,
                    color: msg.isSeen ? Colors.blue : Colors.grey,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
