// 파일 경로: lib/features/board/widgets/ckeditor5_platform_io.dart
// 파일 설명: 모바일/데스크톱에서 WebView 기반 CKEditor 5를 제공하는 구현.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'ckeditor5_platform_interface.dart' hide buildPlatformEditor;

/// WebView를 생성해 CKEditor 5를 로드하고 콜백을 등록합니다.
Widget buildPlatformEditor({
  required double minHeight,
  required String initialHtml,
  required CkeditorRegisterCallbacks registerCallbacks,
  required CkeditorReadyCallback onReady,
  required CkeditorChangedCallback onChanged,
}) {
  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(Colors.transparent);

  Completer<String>? pendingContentRequest;

  controller.addJavaScriptChannel(
    'FlutterEditorChannel',
    onMessageReceived: (JavaScriptMessage message) {
      final Map<String, dynamic> payload =
          json.decode(message.message) as Map<String, dynamic>;
      switch (payload['type'] as String? ?? '') {
        case 'ready':
          onReady();
          break;
        case 'change':
          onChanged(payload['data'] as String? ?? '');
          break;
        case 'data':
          pendingContentRequest?.complete(payload['data'] as String? ?? '');
          pendingContentRequest = null;
          break;
      }
    },
  );

  controller.loadHtmlString(_buildEditorHtml(initialHtml));

  registerCallbacks(
    setHtml: (String value) async {
      final encoded = jsonEncode(<String, dynamic>{
        'type': 'setData',
        'data': value,
      });
      await controller.runJavaScript('window.handleMessage($encoded);');
    },
    getHtml: () {
      pendingContentRequest = Completer<String>();
      controller.runJavaScript('window.handleMessage({"type":"getData"});');
      return pendingContentRequest!.future;
    },
  );

  return Container(
    constraints: BoxConstraints(minHeight: minHeight),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade400),
      borderRadius: const BorderRadius.all(Radius.circular(12)),
    ),
    clipBehavior: Clip.antiAlias,
    child: WebViewWidget(controller: controller),
  );
}

/// WebView에서 실행할 CKEditor 5 HTML 템플릿을 생성합니다.
String _buildEditorHtml(String initialHtml) {
  final escapedInitial = jsonEncode(initialHtml);
  return '''
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <style>
    body { margin: 0; padding: 0; background: transparent; }
    #editor { min-height: 280px; }
  </style>
  <script src="https://cdn.ckeditor.com/ckeditor5/41.2.0/classic/ckeditor.js"></script>
</head>
<body>
  <div id="editor"></div>
  <script>
    const channelName = 'FlutterEditorChannel';
    let editorInstance = null;

    function postMessage(payload) {
      if (window[channelName] && window[channelName].postMessage) {
        window[channelName].postMessage(JSON.stringify(payload));
      }
      if (window.parent !== window && window.parent.postMessage) {
        window.parent.postMessage(payload, '*');
      }
    }

    function applyInitialData(data) {
      if (editorInstance) {
        editorInstance.setData(data || '');
      }
    }

    window.handleMessage = function(payload) {
      if (!editorInstance) {
        return null;
      }
      if (payload.type === 'setData') {
        editorInstance.setData(payload.data || '');
      }
      if (payload.type === 'getData') {
        postMessage({ type: 'data', data: editorInstance.getData() });
      }
      return null;
    };

    ClassicEditor.create(document.querySelector('#editor'), {
      toolbar: {
        shouldNotGroupWhenFull: true
      }
    }).then(editor => {
      editorInstance = editor;
      editor.model.document.on('change:data', () => {
        postMessage({ type: 'change', data: editor.getData() });
      });
      applyInitialData(${escapedInitial});
      postMessage({ type: 'ready' });
    }).catch(error => {
      console.error(error);
    });
  </script>
</body>
</html>
''';
}
