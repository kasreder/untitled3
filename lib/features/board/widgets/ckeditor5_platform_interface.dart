import 'package:flutter/material.dart';

typedef CkeditorRegisterCallbacks = void Function({
  required Future<void> Function(String html) setHtml,
  required Future<String> Function() getHtml,
});

typedef CkeditorReadyCallback = void Function();
typedef CkeditorChangedCallback = void Function(String html);

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
