import 'package:flutter/widgets.dart';

import 'ckeditor_platform_stub.dart'
    if (dart.library.html) 'ckeditor_platform_web.dart'
    if (dart.library.io) 'ckeditor_platform_mobile.dart';

abstract class CkEditorPlatform {
  Widget build({
    required String initialValue,
    required ValueChanged<String> onChanged,
    required double height,
  });

  static CkEditorPlatform get instance => getPlatform();
}
