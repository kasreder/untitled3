// 파일 경로: lib/features/board/widgets/ckeditor5.dart
// 파일 설명: CKEditor 5를 플랫폼별로 임베드하기 위한 컨트롤러와 위젯 정의.

import 'package:flutter/material.dart';

import 'ckeditor5_platform_interface.dart'
    if (dart.library.html) 'ckeditor5_platform_web.dart'
    if (dart.library.io) 'ckeditor5_platform_io.dart';
/// 에디터와 상호 작용하기 위한 컨트롤러입니다.
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

  /// 에디터 State와 컨트롤러를 연결합니다.
  void _bind(_Ckeditor5State state) {
    _state = state;
  }

  /// 현재 연결된 State가 동일할 때만 연결을 해제합니다.
  void _unbind(_Ckeditor5State state) {
    if (identical(_state, state)) {
      _state = null;
    }
  }

  /// 컨트롤러에서 HTML을 설정하고 에디터에도 반영합니다.
  Future<void> setHtml(String html) async {
    _html = html;
    htmlListenable.value = html;
    if (_state != null) {
      await _state!.setHtmlFromController(html);
    }
  }

  /// 에디터에서 최신 HTML을 읽어옵니다.
  Future<String> getHtml() async {
    if (_state != null) {
      _html = await _state!.getHtmlFromEditor();
      htmlListenable.value = _html;
    }
    return _html;
  }

  /// 에디터에서 전달된 HTML 변경을 반영합니다.
  void _handleHtmlChanged(String html) {
    _html = html;
    htmlListenable.value = html;
  }

  /// 에디터 준비 완료 상태를 알립니다.
  void _markReady() {
    readyListenable.value = true;
  }

  /// 내부적으로 생성한 리스너들을 정리합니다.
  void dispose() {
    htmlListenable.dispose();
    readyListenable.dispose();
  }
}

/// CKEditor 5를 표시하고 컨트롤러와 동기화하는 위젯입니다.
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

/// 플랫폼별 구현과 통신하는 State 클래스입니다.
class _Ckeditor5State extends State<Ckeditor5> {
  Future<void> Function(String html)? _setHtmlCallback;
  Future<String> Function()? _getHtmlCallback;

  /// 위젯이 마운트되면 컨트롤러와 연결합니다.
  @override
  void initState() {
    super.initState();
    widget.controller._bind(this);
  }

  /// 컨트롤러가 바뀌었을 때 기존 연결을 정리합니다.
  @override
  void didUpdateWidget(Ckeditor5 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller._unbind(this);
      widget.controller._bind(this);
    }
  }

  /// 위젯이 사라질 때 컨트롤러와의 연결을 해제합니다.
  @override
  void dispose() {
    widget.controller._unbind(this);
    super.dispose();
  }

  /// 플랫폼별 구현에서 호출할 콜백을 등록합니다.
  void registerCallbacks({
    required Future<void> Function(String html) setHtml,
    required Future<String> Function() getHtml,
  }) {
    _setHtmlCallback = setHtml;
    _getHtmlCallback = getHtml;
  }

  /// 컨트롤러에서 전달된 HTML을 플랫폼 구현에 반영합니다.
  Future<void> setHtmlFromController(String html) async {
    if (_setHtmlCallback != null) {
      await _setHtmlCallback!(html);
    }
  }

  /// 플랫폼 구현에서 HTML을 읽어옵니다.
  Future<String> getHtmlFromEditor() async {
    if (_getHtmlCallback != null) {
      return _getHtmlCallback!();
    }
    return widget.controller.initialHtml;
  }

  /// 에디터 로드 완료 시 초기 HTML을 세팅합니다.
  void handleEditorReady() {
    widget.controller._markReady();
    if (widget.controller.initialHtml.isNotEmpty) {
      setHtmlFromController(widget.controller.initialHtml);
    }
  }

  /// 플랫폼 구현으로부터 전달된 HTML 변화를 컨트롤러에 반영합니다.
  void handleHtmlChanged(String html) {
    widget.controller._handleHtmlChanged(html);
  }

  /// 플랫폼별 위젯을 생성해 렌더링합니다.
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
