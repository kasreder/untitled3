// 파일 경로: lib/features/board/widgets/comment_utils.dart
// 파일 설명: 댓글 관련 공통 유틸리티 함수 모음.

import '../models/board_comment.dart';

/// 댓글과 모든 대댓글 수를 재귀적으로 합산합니다.
int countComments(List<BoardComment> comments) {
  var total = 0;
  for (final comment in comments) {
    total += 1 + countComments(comment.replies);
  }
  return total;
}
