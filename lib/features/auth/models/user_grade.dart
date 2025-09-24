// 파일 경로: lib/features/auth/models/user_grade.dart
// 파일 설명: 회원 권한 및 라벨 정보를 담은 열거형.

/// 회원 등급을 정의한 열거형.
enum UserGrade {
  all('모두', 0),
  regular('일반', 1),
  semiExpert('준문가', 2),
  expert('전문가', 3),
  admin1('관리자1', 4),
  admin2('관리자2', 5),
  developer('개발자', 6),
  master('마스터', 7);

  const UserGrade(this.label, this.rank);

  /// 화면에 노출할 한글 등급명.
  final String label;

  /// 권한 비교에 사용할 정수 랭크. 값이 클수록 높은 등급이다.
  final int rank;

  /// 운영자(관리자1) 이상 등급인지 여부.
  bool get isOperator => rank >= UserGrade.admin1.rank;

  /// 등급명을 통해 [UserGrade]를 조회한다.
  static UserGrade fromLabel(String label) {
    return UserGrade.values.firstWhere(
      (grade) => grade.label == label,
      orElse: () => UserGrade.regular,
    );
  }
}
