import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationSummary {
  final String conversationId;
  final String otherUserUid;
  final String otherUserName;
  final String otherUserEmail;
  final String? otherUserProfile;
  final String lastMessage;
  final String? lastMessageId;
  final DateTime? lastMessageAt;
  final String lastMessageSenderId;
  final int unreadCount;
  final bool lastMessageIsSeen;
  final bool lastMessageIsDelivered;

  const ConversationSummary({
    required this.conversationId,
    required this.otherUserUid,
    required this.otherUserName,
    required this.otherUserEmail,
    required this.lastMessage,
    required this.lastMessageSenderId,
    required this.unreadCount,
    required this.lastMessageIsSeen,
    required this.lastMessageIsDelivered,
    this.otherUserProfile,
    this.lastMessageId,
    this.lastMessageAt,
  });

  factory ConversationSummary.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
    String currentUserId,
  ) {
    final data = document.data();
    final memberIds = List<String>.from(data['memberIds'] ?? const []);
    final otherUserUid = memberIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    final participants = Map<String, dynamic>.from(
      data['participants'] ?? const {},
    );
    final otherUser = Map<String, dynamic>.from(
      participants[otherUserUid] ?? const {},
    );
    final unreadCounts = Map<String, dynamic>.from(
      data['unreadCounts'] ?? const {},
    );
    final seenBy = Map<String, dynamic>.from(data['seenBy'] ?? const {});
    final deliveredTo = Map<String, dynamic>.from(
      data['deliveredTo'] ?? const {},
    );
    final lastMessageAt = data['lastMessageAt'];

    return ConversationSummary(
      conversationId: document.id,
      otherUserUid: otherUserUid,
      otherUserName: otherUser['name'] as String? ?? 'User',
      otherUserEmail: otherUser['email'] as String? ?? '',
      otherUserProfile: otherUser['profilePicture'] as String?,
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageId: data['lastMessageId'] as String?,
      lastMessageAt: lastMessageAt is Timestamp ? lastMessageAt.toDate() : null,
      lastMessageSenderId: data['lastMessageSenderId'] as String? ?? '',
      unreadCount: (unreadCounts[currentUserId] as num?)?.toInt() ?? 0,
      lastMessageIsSeen: seenBy[otherUserUid] == true,
      lastMessageIsDelivered: deliveredTo[otherUserUid] == true,
    );
  }
}
