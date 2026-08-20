import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hay_chat/core/services/notification_service.dart';

import '../data/models/chat_model.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _currentUserName;
  String? get currentUserName => _currentUserName;

  // Track which chat is currently active to filter notifications
  String? _activeChatUserId;
  String? get activeChatUserId => _activeChatUserId;

  StreamSubscription? _globalMessageSubscription;
  final Map<String, StreamSubscription> _conversationMessageSubscriptions = {};

  String get currentUserDisplayName =>
      _currentUserName ?? _auth.currentUser?.displayName ?? 'User';

  void setActiveChatUser(String? userId) {
    if (_activeChatUserId == userId) return;
    _activeChatUserId = userId;
  }

  /// Starts listening to ALL incoming messages for the current user.
  /// This should be called once the user is logged in (e.g., in HomeScreen).
  void startGlobalMessageListener() {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null || _globalMessageSubscription != null) return;

    // Listen below the current user's conversations to avoid collection-group
    // indexes and keep the listener scoped to this user's data.
    _globalMessageSubscription = _firestore
        .collection('conversation')
        .doc(currentUid)
        .collection('messages')
        .snapshots()
        .listen(
          (snapshot) {
            final senderIds = snapshot.docs.map((doc) => doc.id).toSet();
            for (final senderId in senderIds) {
              _listenToConversationMessages(senderId, currentUid);
            }

            for (final senderId
                in _conversationMessageSubscriptions.keys.toList()) {
              if (!senderIds.contains(senderId)) {
                _conversationMessageSubscriptions.remove(senderId)?.cancel();
              }
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            debugPrint('Global message listener error: $error');
          },
        );
  }

  void _listenToConversationMessages(String senderId, String currentUid) {
    if (_conversationMessageSubscriptions.containsKey(senderId)) return;

    final messagesRef = _firestore
        .collection('conversation')
        .doc(currentUid)
        .collection('messages')
        .doc(senderId)
        .collection('chats');

    _conversationMessageSubscriptions[senderId] = messagesRef
        .snapshots()
        .listen(
          (snapshot) {
            for (final change in snapshot.docChanges) {
              if (change.type != DocumentChangeType.added) continue;

              final data = change.doc.data();
              if (data?['isSeen'] != false) continue;

              final messageSenderId = data?['sender'] as String?;
              final messageText = data?['message'] as String?;
              if (messageSenderId == null ||
                  messageText == null ||
                  messageText.isEmpty) {
                continue;
              }

              if (messageSenderId != _activeChatUserId &&
                  messageSenderId != currentUid) {
                _triggerNotification(messageSenderId, messageText);
              }
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            debugPrint('Messages listener error for $senderId: $error');
          },
        );
  }

  Future<void> _triggerNotification(String senderId, String message) async {
    try {
        // Fetch the sender name for the notification title.
      final senderDoc = await _firestore
          .collection('users')
          .doc(senderId)
          .get();
      final senderData = senderDoc.data();
      final senderName = senderData?['name'] ?? 'New Message';

      await NotificationService.instance.showMessageNotification(
        id: _notificationIdForSender(senderId),
        senderUid: senderId,
        title: senderName,
        body: message,
      );
    } catch (e) {
      debugPrint('Error triggering notification: $e');
    }
  }

  int _notificationIdForSender(String senderUid) {
    var hash = 0;
    for (final codeUnit in senderUid.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash == 0 ? 1 : hash;
  }

  void stopGlobalMessageListener() {
    _globalMessageSubscription?.cancel();
    _globalMessageSubscription = null;
    for (final subscription in _conversationMessageSubscriptions.values) {
      subscription.cancel();
    }
    _conversationMessageSubscriptions.clear();
  }

  Future<void> fetchCurrentUserName() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final name = doc.data()?['name'] as String?;
        if (name != null && name != _currentUserName) {
          _currentUserName = name;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error fetching current user name: $e');
    }
  }

  Future<void> markMessagesAsSeen(String receiverUid) async {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null || receiverUid.isEmpty) return;

    try {
      final batch = _firestore.batch();

      final myMetaRef = _firestore
          .collection('conversation')
          .doc(currentUid)
          .collection('messages')
          .doc(receiverUid);
      batch.set(myMetaRef, {
        'unreadCount': 0,
        'isSeen': true,
      }, SetOptions(merge: true));

      final incomingMessages = await _firestore
          .collection('conversation')
          .doc(currentUid)
          .collection('messages')
          .doc(receiverUid)
          .collection('chats')
          .get();

      for (final doc in incomingMessages.docs) {
        final data = doc.data();
        if (data['sender'] == receiverUid && data['isSeen'] == false) {
          batch.update(doc.reference, {'isSeen': true, 'isReceived': true});
        }
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error marking messages as seen: $e');
    }
  }

  Future<void> sendMessage({
    required String receiverUid,
    required String text,
    required String receiverName,
    String? receiverProfile,
    String? receiverEmail,
  }) async {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null || receiverUid.isEmpty || text.trim().isEmpty) {
      return;
    }

    try {
      final chatMessage = ChatModel(
        sender: currentUid,
        receiver: receiverUid,
        message: text.trim(),
        type: MessageType.text.name,
        dateTimestamp: DateTime.now(),
        isSeen: false,
        isReceived: true,
      );

      final batch = _firestore.batch();
      final messageData = chatMessage.toMap()
        ..['dateTimestamp'] = FieldValue.serverTimestamp();

      final senderChatRef = _firestore
          .collection('conversation')
          .doc(currentUid)
          .collection('messages')
          .doc(receiverUid)
          .collection('chats')
          .doc();
      final msgId = senderChatRef.id;

      final receiverChatRef = _firestore
          .collection('conversation')
          .doc(receiverUid)
          .collection('messages')
          .doc(currentUid)
          .collection('chats')
          .doc(msgId);

      batch.set(senderChatRef, messageData);
      batch.set(receiverChatRef, messageData);

      final metaDataSender = {
        'lastMessage': text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'otherUserUid': receiverUid,
        'otherUserName': receiverName,
        'otherUserEmail': receiverEmail,
        'otherUserProfile': receiverProfile,
        'lastMessageSenderId': currentUid,
        'isSeen': false,
        'isReceived': true,
      };

      final metaDataReceiver = {
        'lastMessage': text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'otherUserUid': currentUid,
        'otherUserName': currentUserDisplayName,
        'otherUserEmail': _auth.currentUser?.email,
        'otherUserProfile': _auth.currentUser?.photoURL,
        'lastMessageSenderId': currentUid,
        'isSeen': false,
        'isReceived': true,
        'unreadCount': FieldValue.increment(1),
      };

      batch.set(
        senderChatRef.parent.parent!,
        metaDataSender,
        SetOptions(merge: true),
      );
      batch.set(
        receiverChatRef.parent.parent!,
        metaDataReceiver,
        SetOptions(merge: true),
      );

      await batch.commit();
    } catch (e) {
      debugPrint('Send error: $e');
    }
  }

  Stream<QuerySnapshot> getChatStream(String receiverUid) {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null || receiverUid.isEmpty) {
      return const Stream.empty();
    }

    return _firestore
        .collection('conversation')
        .doc(currentUid)
        .collection('messages')
        .doc(receiverUid)
        .collection('chats')
        .orderBy('dateTimestamp', descending: false)
        .snapshots();
  }

  @override
  void dispose() {
    stopGlobalMessageListener();
    super.dispose();
  }
}
