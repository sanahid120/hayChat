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
      ) {
    final data = document.data();
    final timestamp = data['lastMessageAt'] as Timestamp?;

    return ConversationSummary(
      conversationId:
      data['conversationId'] as String? ?? document.id,
      otherUserUid: data['otherUserUid'] as String? ?? '',
      otherUserName: data['otherUserName'] as String? ?? 'User',
      otherUserEmail: data['otherUserEmail'] as String? ?? '',
      otherUserProfile: data['otherUserProfile'] as String?,
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageId: data['lastMessageId'] as String?,
      lastMessageAt: timestamp?.toDate(),
      lastMessageSenderId:
      data['lastMessageSenderId'] as String? ?? '',
      unreadCount: (data['unreadCount'] as num?)?.toInt() ?? 0,
      lastMessageIsSeen:
      data['lastMessageIsSeen'] as bool? ?? false,
      lastMessageIsDelivered:
      data['lastMessageIsDelivered'] as bool? ?? false,
    );
  }
}