import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_colors.dart';
import '../../../features/home/presentation/screens/homescreen.dart';
import '../data/nav_bar_provider.dart';

class HomepageBottomNavBar extends StatefulWidget {
  const HomepageBottomNavBar({super.key});
  static const String routeName = "/HomepageBottomNavBar";

  @override
  State<HomepageBottomNavBar> createState() => _HomepageBottomNavBarState();
}

class _HomepageBottomNavBarState extends State<HomepageBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomepageMainNavProvider>(
      builder: (context, mainNavProvider, _) {
        return Scaffold(
          extendBody: false,

          body: IndexedStack(
            index: mainNavProvider.selectedIndex,
            children: [Homescreen(), SizedBox(), SizedBox()],
          ),

          bottomNavigationBar: BottomNavigationBar(
            onTap: (int index) {
              mainNavProvider.updateIndex(index);
            },

            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,

            backgroundColor: AppColors.scaffoldBackground,
            elevation: 5,
            currentIndex: mainNavProvider.selectedIndex,
            selectedItemColor: AppColors.primary,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.wechat_outlined),
                label: "Chats",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.contacts),
                label: "Contacts",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          ),
        );
      },
    );
  }
}
