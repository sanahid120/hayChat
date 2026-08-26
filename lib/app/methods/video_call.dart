import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:hay_chat/app/models/user_model.dart';

import '../../features/chat/presentation/ui_call_kit_screen.dart';

class VideoCall {
  static Future<void> startVideoCall(
    BuildContext context,
    String currentUser,
    String callId,
  ) async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser)
        .get();

    if (!userSnapshot.exists || !context.mounted) return;

    Navigator.pushNamed(
      context,
      CallPage.routeName,
      arguments: {'user': userSnapshot, 'callId': callId},
    );
  }
}
