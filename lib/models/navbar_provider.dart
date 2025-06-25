import 'package:flutter/material.dart';

class BottomNavProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int unreadNotificationCount = 0; // you update this when fetching


  int get currentIndex => _currentIndex;

  void changeIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }


  void resetToHome() {  // Add this new method
    _currentIndex = 0;
    notifyListeners();
  }

  void updateUnreadCount(int count) {
    unreadNotificationCount = count;
    notifyListeners();
  }

}