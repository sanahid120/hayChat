import 'package:flutter/material.dart';
import '../../../../app/app_colors.dart';

class ChatInputWidget extends StatelessWidget {
  final TextEditingController controller;
  const ChatInputWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
      minLines: 1,
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        hintText: 'Write a message...',
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Emoji',
              color: AppColors.primaryDark,
              onPressed: () {
                // Add an emoji picker here.
              },
              icon: const Icon(Icons.emoji_emotions_outlined),
            ),
            IconButton(
              tooltip: 'Attach file',
              onPressed: () {
                // Add image_picker or file_picker here.
              },
              color: AppColors.primaryDark,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
