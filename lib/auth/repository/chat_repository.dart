import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../app/models/user_model.dart';
import '../presentation/models/conversation_summary.dart';

class ChatRepository {
  ChatRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<ConversationSummary>> watchConversations(String userId) {
    return _firestore
        .collection('conversations')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          final conversations = snapshot.docs
              .map(
                (document) =>
                    ConversationSummary.fromFirestore(document, userId),
              )
              .where((summary) => summary.otherUserUid.isNotEmpty)
              .toList();
          // Sort on the client so this listener only needs Firestore's
          // automatic memberIds array index on fresh Firebase projects.
          conversations.sort((a, b) {
            final aTime = a.lastMessageAt;
            final bTime = b.lastMessageAt;
            if (aTime == null) return bTime == null ? 0 : 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });
          return conversations;
        });
  }

  /// Copies the old per-user conversation previews into the shared conversation
  /// documents, then removes the redundant preview after each successful copy.
  Future<void> migrateLegacyConversationSummaries(String userId) async {
    final legacy = await _firestore
        .collection('userChats')
        .doc(userId)
        .collection('conversations')
        .get();
    if (legacy.docs.isEmpty) return;

    final currentUserSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .get();
    final currentUser = currentUserSnapshot.data() ?? <String, dynamic>{};

    for (final summary in legacy.docs) {
      final data = summary.data();
      final conversationId = data['conversationId'] as String? ?? summary.id;
      final otherUserId = data['otherUserUid'] as String? ?? '';
      if (otherUserId.isEmpty) continue;

      final otherUserSnapshot = await _firestore
          .collection('users')
          .doc(otherUserId)
          .get();
      final otherUser = otherUserSnapshot.data() ?? <String, dynamic>{};
      final reference = _firestore
          .collection('conversations')
          .doc(conversationId);

      await _firestore.runTransaction((transaction) async {
        final current = await transaction.get(reference);
        final existing = current.data() ?? <String, dynamic>{};
        final members = <String>{
          ...List<String>.from(existing['memberIds'] ?? const []),
          userId,
          otherUserId,
        }.toList()..sort();
        final unreadCounts = Map<String, dynamic>.from(
          existing['unreadCounts'] ?? const {},
        );
        unreadCounts.putIfAbsent(userId, () => data['unreadCount'] ?? 0);
        final seenBy = Map<String, dynamic>.from(
          existing['seenBy'] ?? const {},
        );
        final deliveredTo = Map<String, dynamic>.from(
          existing['deliveredTo'] ?? const {},
        );
        if (data['lastMessageSenderId'] == userId) {
          seenBy[otherUserId] = data['lastMessageIsSeen'] == true;
          deliveredTo[otherUserId] = data['lastMessageIsDelivered'] == true;
        }
        final participants = Map<String, dynamic>.from(
          existing['participants'] ?? const {},
        );
        participants[userId] = {
          'name': currentUser['name'] ?? '',
          'email': currentUser['email'] ?? '',
          'profilePicture': currentUser['profilePicture'],
        };
        participants[otherUserId] = {
          'name': otherUser['name'] ?? data['otherUserName'] ?? 'User',
          'email': otherUser['email'] ?? data['otherUserEmail'] ?? '',
          'profilePicture':
              otherUser['profilePicture'] ?? data['otherUserProfile'],
        };

        transaction.set(reference, {
          'memberIds': members,
          'participants': participants,
          'unreadCounts': unreadCounts,
          'seenBy': seenBy,
          'deliveredTo': deliveredTo,
          if (existing['lastMessage'] == null) ...{
            'lastMessage': data['lastMessage'] ?? '',
            'lastMessageId': data['lastMessageId'],
            'lastMessageAt': data['lastMessageAt'],
            'lastMessageSenderId': data['lastMessageSenderId'] ?? '',
          },
        }, SetOptions(merge: true));
      });
      await summary.reference.delete();
    }
  }

  Future<List<UserModel>> searchUsersByEmail({
    required String email,
    required String currentUserId,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromJson(doc.data(), doc.id))
        .where((user) => user.uid != currentUserId)
        .toList(growable: false);
  }
}
