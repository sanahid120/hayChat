import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:flutter/material.dart';

import '../../../app/urls.dart';
class CallPage extends StatelessWidget {
  const CallPage({super.key, required this.user, required this.callId});
  final DocumentSnapshot user;
  final String callId;
  static const String routeName = '/CallPage';


  @override
  Widget build(BuildContext context) {
     String name = user['name'];
     String uid = user['uid'];

    return ZegoUIKitPrebuiltCall(
      appID: Urls.appId,
      appSign: Urls.appSign,
      userID: uid,
      userName: name,
      callID: callId,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
    );
  }
}