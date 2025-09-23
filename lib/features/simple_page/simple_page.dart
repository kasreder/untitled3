// 파일 경로: lib/features/simple_page/simple_page.dart
// 파일 설명: 개발 중인 섹션을 위한 플레이스홀더 페이지.

import 'package:flutter/material.dart';

class SimplePage extends StatelessWidget {
  const SimplePage({
    required this.message,
    super.key,
  });

  final String message;

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
