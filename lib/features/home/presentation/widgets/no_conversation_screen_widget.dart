import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/methods/scaffold_message.dart';
import '../../../../shared/presentation/data/nav_bar_provider.dart';

class NoConversationWidget extends StatelessWidget {
  const NoConversationWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          const Text(
            "No conversations yet",
            style: TextStyle(color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessage.showMessage(
                "Go To Contacts to start Conversation",
                context,
                AppColors.textPrimary,
                AppColors.success,
              );
        },
            child: const Text("Start chatting"),
          ),
        ],
      ),
    );
  }
}
