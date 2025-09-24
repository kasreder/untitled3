import 'package:flutter/material.dart';

import 'ckeditor_platform.dart';

CkEditorPlatform getPlatform() => _StubCkEditorPlatform();

class _StubCkEditorPlatform implements CkEditorPlatform {
  @override
  Widget build({
    required String initialValue,
    required ValueChanged<String> onChanged,
    required double height,
  }) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: null,
      expands: true,
      onChanged: onChanged,
      decoration: const InputDecoration(
        filled: true,
        hintText: '콘텐츠를 입력하세요 (CKEditor 로딩 대기 중)',
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(16),
      ),
    );
  }
}
