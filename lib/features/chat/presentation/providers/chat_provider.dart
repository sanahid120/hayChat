import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/models/chat_model.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
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
    return _currentUserName ?? _auth.currentUser?.displayName ?? 'User';
  }

  String? get currentUserId => _auth.currentUser?.uid;

  String? get activeConversationId => _activeConversationId;

  void setActiveConversation(String? conversationId) {
    _activeConversationId = conversationId;
  }

  String createConversationId(String firstUserId, String secondUserId) {
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

  Stream<List<ChatModel>> getChatStream(String receiverUserId) {
    final currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null || receiverUserId.isEmpty) {
      return Stream.value([]);
    }

    final conversationId = createConversationId(currentUserId, receiverUserId);

    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('clientSentAt')
        .snapshots()
        .map((snapshot) {
          final messages = snapshot.docs.map(ChatModel.fromFirestore).toList();

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
      final conversationId = createConversationId(currentUserId, receiverUid);
      final currentUserSnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();
      final currentUserData = currentUserSnapshot.data() ?? <String, dynamic>{};

      final conversationReference = _firestore
          .collection('conversations')
          .doc(conversationId);

      final messageReference = conversationReference
          .collection('messages')
          .doc();

      final messageId = messageReference.id;

      final message = ChatModel(
        id: messageId,
        senderId: currentUserId,
        receiverId: receiverUid,
        message: cleanedText,
        type: MessageType.text.name,
        clientSentAt: DateTime.now(),
      );

      await _firestore.runTransaction((transaction) async {
        final conversationSnapshot = await transaction.get(
          conversationReference,
        );
        final existing = conversationSnapshot.data() ?? <String, dynamic>{};
        final unreadCounts = Map<String, dynamic>.from(
          existing['unreadCounts'] ?? const {},
        );
        final participants = Map<String, dynamic>.from(
          existing['participants'] ?? const {},
        );
        unreadCounts[currentUserId] = unreadCounts[currentUserId] ?? 0;
        unreadCounts[receiverUid] =
            ((unreadCounts[receiverUid] as num?)?.toInt() ?? 0) + 1;
        participants[currentUserId] = {
          'name': currentUserData['name'] ?? currentUserDisplayName,
          'email': currentUserData['email'] ?? currentUser?.email ?? '',
          'profilePicture':
              currentUserData['profilePicture'] ?? currentUser?.photoURL,
        };
        participants[receiverUid] = {
          'name': receiverName,
          'email': receiverEmail ?? '',
          'profilePicture': receiverProfile,
        };

        transaction.set(messageReference, message.toFirestore());
        transaction.set(conversationReference, {
          'memberIds': ([currentUserId, receiverUid]..sort()),
          'participants': participants,
          'unreadCounts': unreadCounts,
          'seenBy': {currentUserId: true, receiverUid: false},
          'deliveredTo': {currentUserId: true, receiverUid: false},
          'lastMessageId': messageId,
          'lastMessage': cleanedText,
          'lastMessageAt': FieldValue.serverTimestamp(),
          'lastMessageSenderId': currentUserId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });

      return true;
    } on FirebaseException catch (error, stackTrace) {
      debugPrint(
        'Send message Firebase error: '
        '${error.code} ${error.message}\n$stackTrace',
      );

      _errorMessage = error.message ?? 'Unable to send message.';

      return false;
    } catch (error, stackTrace) {
      debugPrint('Send message error: $error\n$stackTrace');

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
  Future<void> markMessagesAsSeen(String otherUserId) async {
    final currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null ||
        otherUserId.isEmpty ||
        currentUserId == otherUserId) {
      return;
    }

    final conversationId = createConversationId(currentUserId, otherUserId);

    try {
      final conversationReference = _firestore
          .collection('conversations')
          .doc(conversationId);
      final conversationDocument = await conversationReference.get();
      if (!conversationDocument.exists) return;
      final conversationData = conversationDocument.data();

      while (true) {
        final unreadMessagesSnapshot = await conversationReference
            .collection('messages')
            .where('receiverId', isEqualTo: currentUserId)
            .where('seenAt', isNull: true)
            .limit(400)
            .get();
        if (unreadMessagesSnapshot.docs.isEmpty) break;

        final batch = _firestore.batch();
        for (final document in unreadMessagesSnapshot.docs) {
          batch.update(document.reference, {
            'deliveredAt': FieldValue.serverTimestamp(),
            'seenAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
        if (unreadMessagesSnapshot.docs.length < 400) break;
      }

      final batch = _firestore.batch();

      final unreadCounts = Map<String, dynamic>.from(
        conversationData?['unreadCounts'] ?? const {},
      )..[currentUserId] = 0;
      final seenBy = Map<String, dynamic>.from(
        conversationData?['seenBy'] ?? const {},
      );
      final deliveredTo = Map<String, dynamic>.from(
        conversationData?['deliveredTo'] ?? const {},
      );
      seenBy[currentUserId] = true;
      deliveredTo[currentUserId] = true;

      batch.set(conversationReference, {
        'unreadCounts': unreadCounts,
        'seenBy': seenBy,
        'deliveredTo': deliveredTo,
      }, SetOptions(merge: true));

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
