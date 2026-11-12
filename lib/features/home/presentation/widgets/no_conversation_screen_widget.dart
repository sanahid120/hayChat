import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/app_colors.dart';
import '../../../../shared/presentation/data/nav_bar_provider.dart';

class NoConversationWidget extends StatelessWidget {
  const NoConversationWidget({super.key});

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
            'No conversations yet',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Go to Contacts to find people and start chatting.',
            style: TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: () =>
                context.read<HomepageMainNavProvider>().moveToContacts(),
            child: const Text('Go to Contacts'),
          ),
        ],
      ),
    );
  }
}
