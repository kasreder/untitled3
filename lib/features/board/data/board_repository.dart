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
        BoardPost.fromJson(post as Map<String, dynamic>),
    ];
  }
}
