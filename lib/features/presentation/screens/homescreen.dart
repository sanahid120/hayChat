import 'package:flutter/material.dart';
import 'package:hay_chat/app/app_strings.dart';
import 'package:hay_chat/auth/presentation/widgets/input_field_widget.dart';

import '../../../app/app_colors.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.appName,
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(color: AppColors.textPrimary),
        ),
        actions: [Icon(Icons.search), SizedBox(width: 20)],
        backgroundColor: AppColors.background,

        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: InputField(
              controller: searchController,
              hintText: 'Search Conversation',
              icon: Icons.search,
            ),
          ),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Column(children: [Text('Hello')]),
      ),
    );
  }
}
