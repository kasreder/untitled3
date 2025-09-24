import 'package:equatable/equatable.dart';

import 'board_comment.dart';

enum BoardViewMode {
  list,
  gallery,
}

class BoardPost extends Equatable {
  const BoardPost({
    required this.id,
    required this.title,
    required this.nickname,
    required this.summary,
    required this.content,
    required this.coverImage,
    required this.createdAt,
    required this.updatedAt,
    required this.views,
    required this.likes,
    required this.dislikes,
    this.images = const <String>[],
    this.comments = const <BoardComment>[],
  });

  final String id;
  final String title;
  final String nickname;
  final String summary;
  final String content;
  final String coverImage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int views;
  final int likes;
  final int dislikes;
  final List<String> images;
  final List<BoardComment> comments;

  BoardPost copyWith({
    String? id,
    String? title,
    String? nickname,
    String? summary,
    String? content,
    String? coverImage,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? views,
    int? likes,
    int? dislikes,
    List<String>? images,
    List<BoardComment>? comments,
  }) {
    return BoardPost(
      id: id ?? this.id,
      title: title ?? this.title,
      nickname: nickname ?? this.nickname,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      coverImage: coverImage ?? this.coverImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      images: images ?? this.images,
      comments: comments ?? this.comments,
    );
  }

  factory BoardPost.fromJson(Map<String, dynamic> json) {
    return BoardPost(
      id: json['id'] as String,
      title: json['title'] as String,
      nickname: json['nickname'] as String,
      summary: json['summary'] as String? ?? '',
      content: json['content'] as String,
      coverImage: json['coverImage'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      views: json['views'] as int? ?? 0,
      likes: json['likes'] as int? ?? 0,
      dislikes: json['dislikes'] as int? ?? 0,
      images: [
        for (final image in json['images'] as List<dynamic>? ?? <dynamic>[])
          image as String,
      ],
      comments: [
        for (final comment in json['comments'] as List<dynamic>? ?? <dynamic>[])
          BoardComment.fromJson(comment as Map<String, dynamic>),
      ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'nickname': nickname,
      'summary': summary,
      'content': content,
      'coverImage': coverImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'views': views,
      'likes': likes,
      'dislikes': dislikes,
      'images': images,
      'comments': [
        for (final comment in comments) comment.toJson(),
      ],
    };
  }

  String get shareMessage => '[청록 네트워크] $title';

  @override
  List<Object?> get props => [
        id,
        title,
        nickname,
        summary,
        content,
        coverImage,
        createdAt,
        updatedAt,
        views,
        likes,
        dislikes,
        images,
        comments,
      ];
}
