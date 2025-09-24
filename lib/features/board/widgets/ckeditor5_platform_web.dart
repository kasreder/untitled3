import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';

import 'ckeditor5_platform_interface.dart' hide buildPlatformEditor;

Widget buildPlatformEditor({
  required double minHeight,
  required String initialHtml,
  required CkeditorRegisterCallbacks registerCallbacks,
  required CkeditorReadyCallback onReady,
  required CkeditorChangedCallback onChanged,
}) {
  final editorId = 'ck-${DateTime.now().microsecondsSinceEpoch}';
  final viewType = 'ckeditor5-view-$editorId';
  final iframe = html.IFrameElement()
    ..style.border = '0'
    ..style.width = '100%'
    ..style.height = '100%'
    ..srcdoc = _buildEditorHtml(initialHtml, editorId);

  ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) => iframe);

  Completer<String>? pendingContentRequest;

  html.window.onMessage.listen((event) {
    final data = event.data;
    Map<String, dynamic>? payload;
    if (data is String) {
      try {
        payload = json.decode(data) as Map<String, dynamic>;
      } catch (_) {
        payload = null;
      }
    } else if (data is Map) {
      payload = <String, dynamic>{
        for (final entry in data.entries)
          if (entry.key is String) entry.key as String: entry.value,
      };
    }
    if (payload == null || payload['editorId'] != editorId) {
      return;
    }
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
  });

  registerCallbacks(
    setHtml: (String value) async {
      final message = jsonEncode(<String, dynamic>{
        'editorId': editorId,
        'type': 'setData',
        'data': value,
      });
      iframe.contentWindow?.postMessage(message, '*');
    },
    getHtml: () {
      pendingContentRequest = Completer<String>();
      final message = jsonEncode(<String, dynamic>{
        'editorId': editorId,
        'type': 'getData',
      });
      iframe.contentWindow?.postMessage(message, '*');
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
    child: HtmlElementView(viewType: viewType, onPlatformViewCreated: (_) {
      // no-op, subscription already active
    }),
  );
}

String _buildEditorHtml(String initialHtml, String editorId) {
  final escapedInitial = jsonEncode(initialHtml);
  final escapedId = jsonEncode(editorId);
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
    const editorId = ${escapedId};
    let editorInstance = null;

    function postMessage(payload) {
      payload.editorId = editorId;
      if (window.parent && window.parent !== window) {
        window.parent.postMessage(JSON.stringify(payload), '*');
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
      },
      image: {
        resizeUnit: '%',
        resizeOptions: [
          {
            name: 'resizeImage:original',
            label: 'Original',
            value: null
          },
          {
            name: 'resizeImage:25',
            label: '25%',
            value: '25'
          },
          {
            name: 'resizeImage:50',
            label: '50%',
            value: '50'
          },
          {
            name: 'resizeImage:75',
            label: '75%',
            value: '75'
          }
        ],
        toolbar: [
          'imageStyle:inline',
          'imageStyle:block',
          'imageStyle:side',
          '|',
          'resizeImage',
          'imageTextAlternative'
        ]
      }
    }).then(editor => {
      editorInstance = editor;
      editor.model.document.on('change:data', () => {
        postMessage({ type: 'change', data: editor.getData() });
      });
      editor.setData(${escapedInitial} || '');
      postMessage({ type: 'ready' });
      window.addEventListener('message', event => {
        let payload = event.data;
        if (typeof payload === 'string') {
          try {
            payload = JSON.parse(payload);
          } catch (error) {
            payload = null;
          }
        }
        if (payload && payload.editorId === editorId) {
          window.handleMessage(payload);
        }
      });
    }).catch(error => {
      console.error(error);
    });
  </script>
</body>
</html>
''';
}
