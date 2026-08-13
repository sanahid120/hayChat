import 'package:flutter/material.dart';
import 'package:hay_chat/app/app_strings.dart';
import 'package:hay_chat/auth/presentation/widgets/input_field_widget.dart';

import '../../../app/app_colors.dart';
import '../../../app/asset_paths.dart';
import '../widgets/home_contact_list_Tile.dart';

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
        backgroundColor: AppColors.background,
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))],

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

      body: Column(
        children: [
          SizedBox(height: 20),

          Expanded(

            child: SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.vertical,
                itemCount: 20,
                itemBuilder: (context, index) {
                  return HomepageContactsCard();
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: 10);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

