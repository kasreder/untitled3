// 파일 경로: lib/features/simple_page/simple_page.dart
// 파일 설명: 개발 중인 섹션을 위한 플레이스홀더 페이지.

import 'package:flutter/material.dart';

/// 특정 기능이 준비되지 않았을 때 안내 메시지를 보여주는 단순 페이지.
class SimplePage extends StatelessWidget {
  const SimplePage({
    required this.message,
    super.key,
  });

  final String message;

  /// 전달받은 메시지를 중앙 정렬 텍스트로 출력한다.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
