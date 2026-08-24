import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  audio,
  video,
  file,
}

class ChatModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final String type;

  final DateTime? sentAt;
  final DateTime? clientSentAt;
  final DateTime? deliveredAt;
  final DateTime? seenAt;

  const ChatModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.type,
    this.sentAt,
    this.clientSentAt,
    this.deliveredAt,
    this.seenAt,
  });

  bool isMine(String currentUserId) {
    return senderId == currentUserId;
  }

  bool get isDelivered => deliveredAt != null;

  bool get isSeen => seenAt != null;

  DateTime? get displayTime => sentAt ?? clientSentAt;

  factory ChatModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data() ?? {};

    return ChatModel(
      id: document.id,
      senderId: data['senderId'] as String? ?? '',
      receiverId: data['receiverId'] as String? ?? '',
      message: data['message'] as String? ?? '',
      type: data['type'] as String? ?? MessageType.text.name,
      sentAt: _dateFromTimestamp(data['sentAt']),
      clientSentAt: _dateFromTimestamp(data['clientSentAt']),
      deliveredAt: _dateFromTimestamp(data['deliveredAt']),
      seenAt: _dateFromTimestamp(data['seenAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'type': type,
      'sentAt': FieldValue.serverTimestamp(),
      'clientSentAt': clientSentAt == null
          ? Timestamp.now()
          : Timestamp.fromDate(clientSentAt!),
      'deliveredAt': deliveredAt == null
          ? null
          : Timestamp.fromDate(deliveredAt!),
      'seenAt': seenAt == null
          ? null
          : Timestamp.fromDate(seenAt!),
    };
  }

  static DateTime? _dateFromTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}