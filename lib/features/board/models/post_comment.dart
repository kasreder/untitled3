import 'package:flutter/foundation.dart';

class PostComment {
  PostComment({
    required this.id,
    required this.nickname,
    required this.content,
    required this.createdAt,
    List<PostComment>? children,
  }) : children = List.unmodifiable(children ?? const []);

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      children: (json['children'] as List<dynamic>?)
          ?.map((child) => PostComment.fromJson(child as Map<String, dynamic>))
          .toList(),
    );
  }

  final String id;
  final String nickname;
  final String content;
  final DateTime createdAt;
  final List<PostComment> children;

  PostComment copyWith({
    String? id,
    String? nickname,
    String? content,
    DateTime? createdAt,
    List<PostComment>? children,
  }) {
    return PostComment(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      children: children ?? this.children,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'nickname': nickname,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'children': children.map((child) => child.toJson()).toList(),
    };
  }

  @override
  String toString() =>
      'PostComment(id: $id, nickname: $nickname, replies: ${children.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostComment &&
          id == other.id &&
          nickname == other.nickname &&
          content == other.content &&
          createdAt == other.createdAt &&
          listEquals(children, other.children);

  @override
  int get hashCode => Object.hash(
        id,
        nickname,
        content,
        createdAt,
        Object.hashAll(children),
      );
}
