// File: lib/app/navigation/navigation_controller.dart
// Description: Synchronises navigation index state with the current route.

import 'package:flutter/foundation.dart';

import 'app_destinations.dart';

class NavigationController extends ChangeNotifier {
  int _selectedIndex = 0;
  String _location = appDestinations.first.location;

  int get selectedIndex => _selectedIndex;

  void selectIndex(int index) {
    if (index == _selectedIndex) {
      return;
    }
    _selectedIndex = index;
    _location = appDestinations[index].location;
    notifyListeners();
  }

  void syncWithLocation(String location) {
    if (_location == location) {
      return;
    }
    _location = location;
    final matchIndex = appDestinations.indexWhere(
      (destination) => destination.location == location,
    );
    if (matchIndex != -1 && matchIndex != _selectedIndex) {
      _selectedIndex = matchIndex;
      notifyListeners();
    }
  }
}
