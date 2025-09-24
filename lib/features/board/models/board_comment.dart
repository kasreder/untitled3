import 'package:equatable/equatable.dart';

class BoardComment extends Equatable {
  const BoardComment({
    required this.id,
    required this.nickname,
    required this.content,
    required this.createdAt,
    this.replies = const <BoardComment>[],
  });

  final String id;
  final String nickname;
  final String content;
  final DateTime createdAt;
  final List<BoardComment> replies;

  BoardComment copyWith({
    String? id,
    String? nickname,
    String? content,
    DateTime? createdAt,
    List<BoardComment>? replies,
  }) {
    return BoardComment(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      replies: replies ?? this.replies,
    );
  }

  factory BoardComment.fromJson(Map<String, dynamic> json) {
    return BoardComment(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      replies: [
        for (final reply in json['replies'] as List<dynamic>? ?? <dynamic>[])
          BoardComment.fromJson(reply as Map<String, dynamic>),
      ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'replies': [
        for (final reply in replies) reply.toJson(),
      ],
    };
  }

  @override
  List<Object?> get props => [id, nickname, content, createdAt, replies];
}
