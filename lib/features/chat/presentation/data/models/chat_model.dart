import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String sender;
  final String message;
  final String type;
  final String receiver;
  final DateTime? dateTimestamp;
  final bool isSeen;
  final bool isReceived;

  ChatModel({
    required this.sender,
    required this.message,
    required this.type,
    required this.receiver,
    this.dateTimestamp,
    this.isSeen = false,
    this.isReceived = false,
  });

  bool isSentBy(String uid) => sender == uid;

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      sender: map['sender'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'text',
      receiver: map['receiver'] ?? '',
      dateTimestamp: (map['dateTimestamp'] as Timestamp?)?.toDate(),
      isSeen: map['isSeen'] ?? false,
      isReceived: map['isReceived'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'message': message,
      'type': type,
      'receiver': receiver,
      'dateTimestamp': dateTimestamp != null ? Timestamp.fromDate(dateTimestamp!) : FieldValue.serverTimestamp(),
      'isSeen': isSeen,
      'isReceived': isReceived,
    };
  }
}

enum MessageType {
  text,
  image,
}
