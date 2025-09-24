import '../models/board_comment.dart';

int countComments(List<BoardComment> comments) {
  var total = 0;
  for (final comment in comments) {
    total += 1 + countComments(comment.replies);
  }
  return total;
}
