import 'package:flutter/material.dart';

class HomepageMainNavProvider extends ChangeNotifier{
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void updateIndex(int index){
    _selectedIndex = index;
    notifyListeners();
  }

  void moveToContacts(){
    updateIndex(1);
  }
  void moveToHomepage(){
    updateIndex(0);
  }
}