import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'ckeditor_platform.dart';

CkEditorPlatform getPlatform() => _MobileCkEditorPlatform();

class _MobileCkEditorPlatform implements CkEditorPlatform {
  @override
  Widget build({
    required String initialValue,
    required ValueChanged<String> onChanged,
    required double height,
  }) {
    return _MobileCkEditorView(
      initialValue: initialValue,
      onChanged: onChanged,
    );
  }
}

class _MobileCkEditorView extends StatefulWidget {
  const _MobileCkEditorView({
    required this.initialValue,
    required this.onChanged,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_MobileCkEditorView> createState() => _MobileCkEditorViewState();
}

class _MobileCkEditorViewState extends State<_MobileCkEditorView> {
  late final WebViewController _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..addJavaScriptChannel('EditorBridge', onMessageReceived: (message) {
      widget.onChanged(message.message);
    })
    ..loadHtmlString(_buildHtml(widget.initialValue));

  @override
  void didUpdateWidget(covariant _MobileCkEditorView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      final escaped = jsonEncode(widget.initialValue);
      _controller.runJavaScript('window.__setData($escaped);');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }

  String _buildHtml(String initialValue) {
    final escaped = jsonEncode(initialValue);
    return '''
<!DOCTYPE html>
<html lang="ko">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style>
      html, body { height: 100%; margin: 0; }
      body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; }
      #editor { min-height: 100%; }
    </style>
    <script src="https://cdn.ckeditor.com/ckeditor5/41.4.2/classic/ckeditor.js"></script>
  </head>
  <body>
    <div id="editor"></div>
    <script>
      const initialData = JSON.parse($escaped);
      let editorRef = null;
      ClassicEditor.create(document.querySelector('#editor'), {
        toolbar: {
          shouldNotGroupWhenFull: true
        }
      }).then(editor => {
        editorRef = editor;
        if (initialData) {
          editor.setData(initialData);
        }
        editor.model.document.on('change:data', () => {
          EditorBridge.postMessage(editor.getData());
        });
      });
      window.__setData = (value) => {
        if (editorRef) {
          editorRef.setData(value || '');
        }
      };
    </script>
  </body>
</html>
''';
  }
}
