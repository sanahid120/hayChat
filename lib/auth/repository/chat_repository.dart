import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../app/models/user_model.dart';
import '../presentation/models/conversation_summary.dart';

class ChatRepository {
  ChatRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<ConversationSummary>> watchConversations(String userId) {
    return _firestore
        .collection('userChats')
        .doc(userId)
        .collection('conversations')
        .orderBy('lastMessageAt', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ConversationSummary.fromFirestore)
              .toList(growable: false),
        );
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
