import 'package:flutter/material.dart';
import '../../../../app/app_colors.dart';
import 'chat_input_widget.dart';

class MessageInputAreaWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const MessageInputAreaWidget({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
        decoration: const BoxDecoration(
          color: AppColors.scaffoldBackground,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: ChatInputWidget(controller: controller),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: onSend,
                icon: const Icon(Icons.send_rounded),
                color: Colors.white,
                iconSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
