import 'package:flutter/material.dart';

import 'ckeditor5_platform_interface.dart'
    if (dart.library.html) 'ckeditor5_platform_web.dart'
    if (dart.library.io) 'ckeditor5_platform_io.dart';

class Ckeditor5Controller {
  Ckeditor5Controller({String initialHtml = ''})
      : _html = initialHtml,
        htmlListenable = ValueNotifier<String>(initialHtml),
        readyListenable = ValueNotifier<bool>(false);

  final ValueNotifier<String> htmlListenable;
  final ValueNotifier<bool> readyListenable;

  String _html;
  _Ckeditor5State? _state;

  String get initialHtml => _html;

  void _bind(_Ckeditor5State state) {
    _state = state;
  }

  void _unbind(_Ckeditor5State state) {
    if (identical(_state, state)) {
      _state = null;
    }
  }

  Future<void> setHtml(String html) async {
    _html = html;
    htmlListenable.value = html;
    if (_state != null) {
      await _state!.setHtmlFromController(html);
    }
  }

  Future<String> getHtml() async {
    if (_state != null) {
      _html = await _state!.getHtmlFromEditor();
      htmlListenable.value = _html;
    }
    return _html;
  }

  void _handleHtmlChanged(String html) {
    _html = html;
    htmlListenable.value = html;
  }

  void _markReady() {
    readyListenable.value = true;
  }

  void dispose() {
    htmlListenable.dispose();
    readyListenable.dispose();
  }
}

class Ckeditor5 extends StatefulWidget {
  const Ckeditor5({
    required this.controller,
    this.minHeight = 320,
    super.key,
  });

  final Ckeditor5Controller controller;
  final double minHeight;

  @override
  State<Ckeditor5> createState() => _Ckeditor5State();
}

class _Ckeditor5State extends State<Ckeditor5> {
  Future<void> Function(String html)? _setHtmlCallback;
  Future<String> Function()? _getHtmlCallback;

  @override
  void initState() {
    super.initState();
    widget.controller._bind(this);
  }

  @override
  void didUpdateWidget(Ckeditor5 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller._unbind(this);
      widget.controller._bind(this);
    }
  }

  @override
  void dispose() {
    widget.controller._unbind(this);
    super.dispose();
  }

  void registerCallbacks({
    required Future<void> Function(String html) setHtml,
    required Future<String> Function() getHtml,
  }) {
    _setHtmlCallback = setHtml;
    _getHtmlCallback = getHtml;
  }

  Future<void> setHtmlFromController(String html) async {
    if (_setHtmlCallback != null) {
      await _setHtmlCallback!(html);
    }
  }

  Future<String> getHtmlFromEditor() async {
    if (_getHtmlCallback != null) {
      return _getHtmlCallback!();
    }
    return widget.controller.initialHtml;
  }

  void handleEditorReady() {
    widget.controller._markReady();
    if (widget.controller.initialHtml.isNotEmpty) {
      setHtmlFromController(widget.controller.initialHtml);
    }
  }

  void handleHtmlChanged(String html) {
    widget.controller._handleHtmlChanged(html);
  }

  @override
  Widget build(BuildContext context) {
    return buildPlatformEditor(
      minHeight: widget.minHeight,
      initialHtml: widget.controller.initialHtml,
      registerCallbacks: registerCallbacks,
      onReady: handleEditorReady,
      onChanged: handleHtmlChanged,
    );
  }
}
