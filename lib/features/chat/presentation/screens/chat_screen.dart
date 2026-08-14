import 'package:flutter/material.dart';
import 'package:hay_chat/app/app_colors.dart';

import '../widgets/app_bar_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  static const String routeName = "/ChatScreen";

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        title: AppBarWidget(onTap: () {}),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert_rounded)),
        ],
      ),

      body: Column(
        children: [

        ],
      ),
    );
  }
}
