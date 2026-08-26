import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hay_chat/app/app_colors.dart';
import 'package:hay_chat/app/models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../app/methods/video_call.dart';
import '../data/models/chat_model.dart';
import '../providers/chat_provider.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/date_header_widget.dart';
import '../widgets/message_input_area_widget.dart';

class ChatScreen extends StatefulWidget {
  final UserModel receiverUser;

  const ChatScreen({
    super.key,
    required this.receiverUser,
  });

  static const String routeName = '/ChatScreen';

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with WidgetsBindingObserver {
  final TextEditingController _messageController =
  TextEditingController();

  final ScrollController _scrollController =
  ScrollController();

  late final ChatProvider _chatProvider;
  late final String _conversationId;

  String? _lastSeenMessageId;
  String? _lastRenderedMessageId;

  bool _seenUpdateScheduled = false;
  bool _scrollUpdateScheduled = false;
  bool _initialScrollCompleted = false;

  String get _currentUserId {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  String get _receiverUserId {
    return widget.receiverUser.uid!;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _chatProvider = context.read<ChatProvider>();

    _conversationId =
        _chatProvider.createConversationId(
          _currentUserId,
          _receiverUserId!,
        );

    _chatProvider.setActiveConversation(
      _conversationId,
    );

    _chatProvider.fetchCurrentUserName();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatProvider.markMessagesAsSeen(
        _receiverUserId!,
      );
    });
  }

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state,
      ) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _chatProvider.markMessagesAsSeen(
        _receiverUserId!,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _chatProvider.setActiveConversation(null);

    _messageController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    _messageController.clear();

    final success = await _chatProvider.sendMessage(
      receiverUid: _receiverUserId,
      text: text,
      receiverName: widget.receiverUser.name!,
      receiverEmail: widget.receiverUser.email,
      receiverProfile:
      widget.receiverUser.profilePicture,
    );

    if (!mounted) return;

    if (!success) {
      _messageController.text = text;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              _chatProvider.errorMessage ??
                  'Unable to send message.',
            ),
          ),
        );

      return;
    }

    _scheduleScrollToBottom(force: true);
  }

  void _scheduleMarkAsSeen(
      List<ChatModel> messages,
      ) {
    if (messages.isEmpty ||
        _seenUpdateScheduled) {
      return;
    }

    ChatModel? latestIncomingMessage;

    for (final message in messages.reversed) {
      if (message.receiverId == _currentUserId &&
          !message.isSeen) {
        latestIncomingMessage = message;
        break;
      }
    }

    if (latestIncomingMessage == null ||
        latestIncomingMessage.id ==
            _lastSeenMessageId) {
      return;
    }

    _lastSeenMessageId =
        latestIncomingMessage.id;
    _seenUpdateScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback(
          (_) async {
        _seenUpdateScheduled = false;

        if (!mounted) return;

        await _chatProvider.markMessagesAsSeen(
          _receiverUserId,
        );
      },
    );
  }

  void _scheduleScrollToBottom({
    bool force = false,
  }) {
    if (_scrollUpdateScheduled) return;

    if (!force &&
        _scrollController.hasClients) {
      final position =
          _scrollController.position;

      final distanceFromBottom =
          position.maxScrollExtent -
              position.pixels;

      if (distanceFromBottom > 200) {
        return;
      }
    }

    _scrollUpdateScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        _scrollUpdateScheduled = false;

        if (!mounted ||
            !_scrollController.hasClients) {
          return;
        }

        final maxScrollExtent =
            _scrollController
                .position
                .maxScrollExtent;

        if (!_initialScrollCompleted) {
          _initialScrollCompleted = true;

          _scrollController.jumpTo(
            maxScrollExtent,
          );

          return;
        }

        _scrollController.animateTo(
          maxScrollExtent,
          duration:
          const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId.isEmpty ||
        _receiverUserId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Chat user is not available.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor:
        AppColors.scaffoldBackground,
        titleSpacing: 0,
        title: AppBarWidget(
          user: widget.receiverUser,
          onTap: () {},
        ),
        actions: [
          IconButton(
            onPressed: () {
              VideoCall.startVideoCall(context, _currentUserId, _conversationId );

            },
            icon: const Icon(
              Icons.videocam_rounded,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<ChatModel>>(
                stream: _chatProvider.getChatStream(
                  _receiverUserId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildErrorState(
                      snapshot.error,
                    );
                  }

                  if (snapshot.connectionState ==
                      ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(
                      child:
                      CircularProgressIndicator(),
                    );
                  }

                  final messages =
                      snapshot.data ?? [];

                  _scheduleMarkAsSeen(messages);

                  final lastMessageId =
                  messages.isEmpty
                      ? null
                      : messages.last.id;

                  if (lastMessageId !=
                      _lastRenderedMessageId) {
                    _lastRenderedMessageId =
                        lastMessageId;

                    _scheduleScrollToBottom(
                      force:
                      !_initialScrollCompleted,
                    );
                  }

                  if (messages.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior
                        .onDrag,
                    padding: const EdgeInsets.only(
                      top: 12,
                      bottom: 12,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message =
                      messages[index];

                      final showDateHeader =
                      _shouldShowDateHeader(
                        messages,
                        index,
                      );

                      return Column(
                        children: [
                          if (showDateHeader &&
                              message.displayTime !=
                                  null)
                            DateHeaderWidget(
                              date:
                              message.displayTime!,
                            ),
                          _buildMessageBubble(
                            message,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Consumer<ChatProvider>(
              builder: (context, provider, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (provider.isSending)
                      const LinearProgressIndicator(
                        minHeight: 2,
                      ),
                    MessageInputAreaWidget(
                      controller:
                      _messageController,
                      onSend: _sendMessage,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowDateHeader(
      List<ChatModel> messages,
      int index,
      ) {
    final currentDate =
        messages[index].displayTime;

    if (currentDate == null) {
      return false;
    }

    if (index == 0) {
      return true;
    }

    final previousDate =
        messages[index - 1].displayTime;

    if (previousDate == null) {
      return true;
    }

    return currentDate.year !=
        previousDate.year ||
        currentDate.month !=
            previousDate.month ||
        currentDate.day !=
            previousDate.day;
  }

  Widget _buildMessageBubble(
      ChatModel message,
      ) {
    final isMine =
        message.senderId == _currentUserId;

    return Align(
      alignment: isMine
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
          MediaQuery.sizeOf(context).width *
              0.78,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        padding: const EdgeInsets.fromLTRB(
          14,
          10,
          10,
          6,
        ),
        decoration: BoxDecoration(
          color: isMine
              ? AppColors.senderBubble
              : AppColors.receiverBubble,
          borderRadius: BorderRadius.only(
            topLeft:
            const Radius.circular(16),
            topRight:
            const Radius.circular(16),
            bottomLeft: Radius.circular(
              isMine ? 16 : 4,
            ),
            bottomRight: Radius.circular(
              isMine ? 4 : 16,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment:
              MainAxisAlignment.end,
              children: [
                Text(
                  _formatTime(
                    message.displayTime,
                  ),
                  style: const TextStyle(
                    color:
                    AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  _buildMessageStatus(message),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageStatus(
      ChatModel message,
      ) {
    if (message.isSeen) {
      return const Icon(
        Icons.done_all,
        size: 15,
        color: Colors.blue,
      );
    }

    if (message.isDelivered) {
      return const Icon(
        Icons.done_all,
        size: 15,
        color: Colors.grey,
      );
    }

    return const Icon(
      Icons.done,
      size: 15,
      color: Colors.grey,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'Start a conversation with '
                  '${widget.receiverUser.name}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    debugPrint(
      'Chat stream error: $error',
    );

    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Unable to load messages.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.error,
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    return DateFormat('hh:mm a').format(
      dateTime.toLocal(),
    );
  }
}