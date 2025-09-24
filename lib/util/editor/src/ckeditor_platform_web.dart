// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'ckeditor_platform.dart';

CkEditorPlatform getPlatform() => _WebCkEditorPlatform();

class _WebCkEditorPlatform implements CkEditorPlatform {
  @override
  Widget build({
    required String initialValue,
    required ValueChanged<String> onChanged,
    required double height,
  }) {
    return _CkEditorWebView(
      initialValue: initialValue,
      onChanged: onChanged,
      height: height,
    );
  }
}

class _CkEditorWebView extends StatefulWidget {
  const _CkEditorWebView({
    required this.initialValue,
    required this.onChanged,
    required this.height,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final double height;

  @override
  State<_CkEditorWebView> createState() => _CkEditorWebViewState();
}

class _CkEditorWebViewState extends State<_CkEditorWebView> {
  late final String _viewType =
      'ckeditor-view-${DateTime.now().microsecondsSinceEpoch}';
  html.IFrameElement? _iframeElement;
  StreamSubscription<html.MessageEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    ui.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..srcdoc = _buildHtml(widget.initialValue);
      _iframeElement = iframe;
      _subscription = html.window.onMessage.listen(_handleMessage);
      return iframe;
    });
  }

  @override
  void didUpdateWidget(covariant _CkEditorWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _postMessage({'type': 'set-data', 'payload': widget.initialValue});
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }

  void _handleMessage(html.MessageEvent event) {
    final data = event.data;
    if (data is Map && data['type'] == 'ckeditor-change') {
      widget.onChanged((data['payload'] as String?) ?? '');
    }
  }

  void _postMessage(Object message) {
    _iframeElement?.contentWindow?.postMessage(message, '*');
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
      body { font-family: system-ui, sans-serif; background: transparent; }
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
          window.parent.postMessage({ type: 'ckeditor-change', payload: editor.getData() }, '*');
        });
      });
      window.addEventListener('message', (event) => {
        if (!editorRef) {
          return;
        }
        const data = event.data || {};
        if (data.type === 'set-data') {
          editorRef.setData(data.payload || '');
        }
      });
    </script>
  </body>
</html>
''';
  }
}
