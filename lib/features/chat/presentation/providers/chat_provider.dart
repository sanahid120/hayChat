import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/models/chat_model.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  bool _isSending = false;
  String? _errorMessage;
  String? _currentUserName;
  String? _activeConversationId;
  bool _disposed = false;

  bool get isSending => _isSending;

  String? get errorMessage => _errorMessage;

  String? get currentUserName => _currentUserName;

  String get currentUserDisplayName {
    return _currentUserName ??
        _auth.currentUser?.displayName ??
        'User';
  }

  String? get currentUserId => _auth.currentUser?.uid;

  String? get activeConversationId => _activeConversationId;

  void setActiveConversation(String? conversationId) {
    _activeConversationId = conversationId;
  }

  String createConversationId(
      String firstUserId,
      String secondUserId,
      ) {
    final userIds = [firstUserId, secondUserId]..sort();

    return '${userIds[0]}_${userIds[1]}';
  }

  Future<void> fetchCurrentUserName() async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) return;

    try {
      final userDocument = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      final name = userDocument.data()?['name'] as String?;

      if (name != null && name.trim().isNotEmpty) {
        _currentUserName = name.trim();
        _safeNotify();
      }
    } catch (error, stackTrace) {
      debugPrint(
        'Unable to fetch current user name: '
            '$error\n$stackTrace',
      );
    }
  }

  Stream<List<ChatModel>> getChatStream(
      String receiverUserId,
      ) {
    final currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null ||
        receiverUserId.isEmpty) {
      return Stream.value([]);
    }

    final conversationId = createConversationId(
      currentUserId,
      receiverUserId,
    );

    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('clientSentAt')
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs
          .map(ChatModel.fromFirestore)
          .toList();

      messages.sort((first, second) {
        final firstTime = first.displayTime;
        final secondTime = second.displayTime;

        if (firstTime == null && secondTime == null) {
          return first.id.compareTo(second.id);
        }

        if (firstTime == null) return -1;
        if (secondTime == null) return 1;

        final result = firstTime.compareTo(secondTime);

        if (result == 0) {
          return first.id.compareTo(second.id);
        }

        return result;
      });

      return messages;
    });
  }

  Future<bool> sendMessage({
    required String receiverUid,
    required String text,
    required String receiverName,
    String? receiverEmail,
    String? receiverProfile,
  }) async {
    final currentUser = _auth.currentUser;
    final currentUserId = currentUser?.uid;
    final cleanedText = text.trim();

    if (currentUserId == null ||
        receiverUid.isEmpty ||
        cleanedText.isEmpty ||
        currentUserId == receiverUid) {
      return false;
    }

    _isSending = true;
    _errorMessage = null;
    _safeNotify();

    try {
      final conversationId = createConversationId(
        currentUserId,
        receiverUid,
      );

      final conversationReference = _firestore
          .collection('conversations')
          .doc(conversationId);

      final messageReference = conversationReference
          .collection('messages')
          .doc();

      final messageId = messageReference.id;

      final senderSummaryReference = _firestore
          .collection('userChats')
          .doc(currentUserId)
          .collection('conversations')
          .doc(conversationId);

      final receiverSummaryReference = _firestore
          .collection('userChats')
          .doc(receiverUid)
          .collection('conversations')
          .doc(conversationId);

      final batch = _firestore.batch();

      final message = ChatModel(
        id: messageId,
        senderId: currentUserId,
        receiverId: receiverUid,
        message: cleanedText,
        type: MessageType.text.name,
        clientSentAt: DateTime.now(),
      );

      batch.set(
        messageReference,
        message.toFirestore(),
      );

      batch.set(
        conversationReference,
        {
          'conversationId': conversationId,
          'memberIds': [currentUserId, receiverUid],
          'lastMessageId': messageId,
          'lastMessage': cleanedText,
          'lastMessageAt': FieldValue.serverTimestamp(),
          'lastMessageSenderId': currentUserId,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      batch.set(
        senderSummaryReference,
        {
          'conversationId': conversationId,
          'otherUserUid': receiverUid,
          'otherUserName': receiverName,
          'otherUserEmail': receiverEmail ?? '',
          'otherUserProfile': receiverProfile,
          'lastMessage': cleanedText,
          'lastMessageId': messageId,
          'lastMessageAt': FieldValue.serverTimestamp(),
          'lastMessageSenderId': currentUserId,
          'lastMessageIsDelivered': false,
          'lastMessageIsSeen': false,
          'unreadCount': 0,
        },
        SetOptions(merge: true),
      );

      batch.set(
        receiverSummaryReference,
        {
          'conversationId': conversationId,
          'otherUserUid': currentUserId,
          'otherUserName': currentUserDisplayName,
          'otherUserEmail': currentUser?.email ?? '',
          'otherUserProfile': currentUser?.photoURL,
          'lastMessage': cleanedText,
          'lastMessageId': messageId,
          'lastMessageAt': FieldValue.serverTimestamp(),
          'lastMessageSenderId': currentUserId,
          'lastMessageIsDelivered': false,
          'lastMessageIsSeen': false,
          'unreadCount': FieldValue.increment(1),
        },
        SetOptions(merge: true),
      );

      await batch.commit();

      return true;
    } on FirebaseException catch (error, stackTrace) {
      debugPrint(
        'Send message Firebase error: '
            '${error.code} ${error.message}\n$stackTrace',
      );

      _errorMessage =
          error.message ?? 'Unable to send message.';

      return false;
    } catch (error, stackTrace) {
      debugPrint(
        'Send message error: $error\n$stackTrace',
      );

      _errorMessage = 'Unable to send message.';

      return false;
    } finally {
      _isSending = false;
      _safeNotify();
    }
  }

  /// Call this only when the receiver actually opens the chat.
  ///
  /// This is the method that fixes the incorrect blue-tick issue.
  Future<void> markMessagesAsSeen(
      String otherUserId,
      ) async {
    final currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null ||
        otherUserId.isEmpty ||
        currentUserId == otherUserId) {
      return;
    }

    final conversationId = createConversationId(
      currentUserId,
      otherUserId,
    );

    try {
      final conversationReference = _firestore
          .collection('conversations')
          .doc(conversationId);

      final conversationDocument =
      await conversationReference.get();

      final conversationData =
      conversationDocument.data();

      final lastMessageId =
      conversationData?['lastMessageId'] as String?;

      final unreadMessagesSnapshot =
      await conversationReference
          .collection('messages')
          .where(
        'receiverId',
        isEqualTo: currentUserId,
      )
          .where('seenAt', isNull: true)
          .limit(400)
          .get();

      final batch = _firestore.batch();
      final updatedMessageIds = <String>{};

      for (final document
      in unreadMessagesSnapshot.docs) {
        updatedMessageIds.add(document.id);

        batch.update(
          document.reference,
          {
            'deliveredAt':
            FieldValue.serverTimestamp(),
            'seenAt': FieldValue.serverTimestamp(),
          },
        );
      }

      final mySummaryReference = _firestore
          .collection('userChats')
          .doc(currentUserId)
          .collection('conversations')
          .doc(conversationId);

      batch.set(
        mySummaryReference,
        {
          'unreadCount': 0,
          'lastMessageIsDelivered': true,
          'lastMessageIsSeen': true,
        },
        SetOptions(merge: true),
      );

      /*
       * Only change the sender's last-message tick when the
       * last message is one of the messages being marked.
       *
       * This prevents an older received message from making
       * a newer outgoing message appear seen.
       */
      if (lastMessageId != null &&
          updatedMessageIds.contains(lastMessageId)) {
        final senderSummaryReference = _firestore
            .collection('userChats')
            .doc(otherUserId)
            .collection('conversations')
            .doc(conversationId);

        batch.set(
          senderSummaryReference,
          {
            'lastMessageIsDelivered': true,
            'lastMessageIsSeen': true,
          },
          SetOptions(merge: true),
        );
      }

      await batch.commit();
    } on FirebaseException catch (error, stackTrace) {
      debugPrint(
        'Mark seen Firebase error: '
            '${error.code} ${error.message}\n$stackTrace',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Mark messages as seen error: '
            '$error\n$stackTrace',
      );
    }
  }

  void clearError() {
    _errorMessage = null;
    _safeNotify();
  }

  /*
   * Keep these temporarily if HomeScreen already calls them.
   *
   * Firestore local listeners should not be your production
   * background notification system. Use Firebase Messaging
   * and a trusted backend/Cloud Function instead.
   */
  void startGlobalMessageListener() {}

  void stopGlobalMessageListener() {}

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}