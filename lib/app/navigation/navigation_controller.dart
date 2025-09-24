// 파일 경로: lib/app/navigation/navigation_controller.dart
// 파일 설명: 현재 라우트에 맞춰 탐색 인덱스 상태를 동기화하는 컨트롤러.
import 'package:flutter/foundation.dart';

import 'app_destinations.dart';

/// 라우터와 하단 내비게이션 상태를 연결하는 컨트롤러.
class NavigationController extends ChangeNotifier {
  int _selectedIndex = 0;
  String _location = appDestinations.first.location;

  /// 현재 선택된 목적지 인덱스.
  int get selectedIndex => _selectedIndex;

  /// 인덱스를 변경하고 리스너에게 알린다.
  void selectIndex(int index) {
    if (index == _selectedIndex) {
      return;
    }
    _selectedIndex = index;
    _location = appDestinations[index].location;
    notifyListeners();
  }

  /// 라우터 위치와 내부 상태를 동기화한다.
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
