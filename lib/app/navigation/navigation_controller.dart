// 파일 경로: lib/app/navigation/navigation_controller.dart
// 파일 설명: 현재 라우트에 맞춰 탐색 인덱스 상태를 동기화하는 컨트롤러.
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
      (destination) {
        if (destination.location == location) {
          return true;
        }
        if (destination.location == '/') {
          return false;
        }
        return location.startsWith('${destination.location}/');
      },
    );
    if (matchIndex != -1 && matchIndex != _selectedIndex) {
      _selectedIndex = matchIndex;
      notifyListeners();
    }
  }
}
