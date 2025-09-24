// 파일 경로: lib/features/board/data/board_repository.dart
// 파일 설명: 로컬 JSON 자산에서 게시글 데이터를 불러오는 저장소 구현.

import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/board_post.dart';

/// 자유 게시판 게시글을 로컬 자산에서 읽어오는 리포지토리입니다.
class BoardRepository {
  /// 자산 경로와 번들을 주입해 테스트하기 쉽게 구성합니다.
  BoardRepository({
    this.assetPath = 'assets/data/free_board.json',
    AssetBundle? bundle,
  }) : bundle = bundle ?? rootBundle;

  final String assetPath;
  final AssetBundle bundle;

  /// JSON 파일을 읽고 `BoardPost` 모델 리스트로 변환합니다.
  Future<List<BoardPost>> loadPosts() async {
    final raw = await bundle.loadString(assetPath);
    final Map<String, dynamic> jsonMap = json.decode(raw) as Map<String, dynamic>;
    final posts = jsonMap['posts'] as List<dynamic>? ?? <dynamic>[];
    return [
      for (final post in posts)
        _embedImages(BoardPost.fromJson(post as Map<String, dynamic>)),
    ];
  }

  /// 본문에 누락된 이미지를 `<figure>` 태그로 삽입해 일관성을 유지합니다.
  BoardPost _embedImages(BoardPost post) {
    if (post.images.isEmpty) {
      return post;
    }
    final content = post.content;
    final buffer = StringBuffer(content.trim());
    var modified = false;
    for (final image in post.images) {
      if (!content.contains(image)) {
        if (buffer.isNotEmpty) {
          buffer.write('\n');
        }
        buffer.write('<figure class="image"><img src="$image" alt="첨부 이미지" /></figure>');
        modified = true;
      }
    }
    if (!modified) {
      return post;
    }
    return post.copyWith(content: buffer.toString());
  }
}
