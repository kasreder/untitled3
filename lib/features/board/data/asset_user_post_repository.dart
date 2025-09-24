import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/user_post.dart';

abstract class UserPostRepository {
  Future<List<UserPost>> fetchPosts();
}

class AssetUserPostRepository implements UserPostRepository {
  AssetUserPostRepository({
    this.assetPath = 'assets/data/user_posts.json',
  });

  final String assetPath;

  @override
  Future<List<UserPost>> fetchPosts() async {
    final jsonString = await rootBundle.loadString(assetPath);
    final List<dynamic> rawList = json.decode(jsonString) as List<dynamic>;
    return rawList
        .map((item) => UserPost.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
