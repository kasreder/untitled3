// 파일 경로: lib/features/board/widgets/ckeditor5_platform_interface.dart
// 파일 설명: 플랫폼별 CKEditor 구현을 위한 추상 인터페이스와 기본 폴백 UI.

import 'package:flutter/material.dart';

/// 플랫폼 구현이 HTML 동기화 콜백을 등록할 때 사용하는 시그니처입니다.
typedef CkeditorRegisterCallbacks = void Function({
  required Future<void> Function(String html) setHtml,
  required Future<String> Function() getHtml,
});

/// 에디터 로드 완료를 알리는 콜백입니다.
typedef CkeditorReadyCallback = void Function();

/// HTML 변경 시 호출되는 콜백입니다.
typedef CkeditorChangedCallback = void Function(String html);

/// 지원되지 않는 플랫폼에서 보여줄 폴백 에디터 위젯입니다.
Widget buildPlatformEditor({
  required double minHeight,
  required String initialHtml,
  required CkeditorRegisterCallbacks registerCallbacks,
  required CkeditorReadyCallback onReady,
  required CkeditorChangedCallback onChanged,
}) {
  return Container(
    constraints: BoxConstraints(minHeight: minHeight),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade400),
      borderRadius: const BorderRadius.all(Radius.circular(12)),
    ),
    alignment: Alignment.center,
    child: const Text('현재 플랫폼에서는 CKEditor 5를 사용할 수 없습니다.'),
  );
}
