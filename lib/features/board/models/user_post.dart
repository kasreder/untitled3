import 'package:flutter/foundation.dart';

import 'post_comment.dart';

enum PostLayoutMode { list, gallery }

class UserPost {
  UserPost({
    required this.id,
    required this.title,
    required this.nickname,
    required this.summary,
    required this.content,
    required this.thumbnail,
    required this.attachments,
    required this.tags,
    required this.views,
    required this.likes,
    required this.dislikes,
    required this.createdAt,
    required this.updatedAt,
    List<PostComment>? comments,
  }) : comments = List.unmodifiable(comments ?? const []);

  factory UserPost.fromJson(Map<String, dynamic> json) {
    return UserPost(
      id: json['id'] as String,
      title: json['title'] as String,
      nickname: json['nickname'] as String,
      summary: json['summary'] as String,
      content: json['content'] as String,
      thumbnail: json['thumbnail'] as String,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          const <String>[],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          const <String>[],
      views: json['views'] as int,
      likes: json['likes'] as int,
      dislikes: json['dislikes'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      comments: (json['comments'] as List<dynamic>?)
              ?.map((comment) =>
                  PostComment.fromJson(comment as Map<String, dynamic>))
              .toList() ??
          const <PostComment>[],
    );
  }

  final String id;
  final String title;
  final String nickname;
  final String summary;
  final String content;
  final String thumbnail;
  final List<String> attachments;
  final List<String> tags;
  final int views;
  final int likes;
  final int dislikes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PostComment> comments;

  String get sharePath => '/free/post/$id';

  String get plainSummary =>
      summary.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '').trim();

  UserPost copyWith({
    String? id,
    String? title,
    String? nickname,
    String? summary,
    String? content,
    String? thumbnail,
    List<String>? attachments,
    List<String>? tags,
    int? views,
    int? likes,
    int? dislikes,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PostComment>? comments,
  }) {
    return UserPost(
      id: id ?? this.id,
      title: title ?? this.title,
      nickname: nickname ?? this.nickname,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      thumbnail: thumbnail ?? this.thumbnail,
      attachments: attachments ?? this.attachments,
      tags: tags ?? this.tags,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      comments: comments ?? this.comments,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'nickname': nickname,
      'summary': summary,
      'content': content,
      'thumbnail': thumbnail,
      'attachments': attachments,
      'tags': tags,
      'views': views,
      'likes': likes,
      'dislikes': dislikes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPost &&
          id == other.id &&
          title == other.title &&
          nickname == other.nickname &&
          summary == other.summary &&
          content == other.content &&
          thumbnail == other.thumbnail &&
          listEquals(attachments, other.attachments) &&
          listEquals(tags, other.tags) &&
          views == other.views &&
          likes == other.likes &&
          dislikes == other.dislikes &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          listEquals(comments, other.comments);

  @override
  int get hashCode => Object.hash(
        id,
        title,
        nickname,
        summary,
        content,
        thumbnail,
        Object.hashAll(attachments),
        Object.hashAll(tags),
        views,
        likes,
        dislikes,
        createdAt,
        updatedAt,
        Object.hashAll(comments),
      );
}
