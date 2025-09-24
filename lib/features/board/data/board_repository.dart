import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/board_post.dart';

class BoardRepository {
  BoardRepository({
    this.assetPath = 'assets/data/free_board.json',
    AssetBundle? bundle,
  }) : bundle = bundle ?? rootBundle;

  final String assetPath;
  final AssetBundle bundle;

  Future<List<BoardPost>> loadPosts() async {
    final raw = await bundle.loadString(assetPath);
    final Map<String, dynamic> jsonMap = json.decode(raw) as Map<String, dynamic>;
    final posts = jsonMap['posts'] as List<dynamic>? ?? <dynamic>[];
    return [
      for (final post in posts)
        _embedImages(BoardPost.fromJson(post as Map<String, dynamic>)),
    ];
  }

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
