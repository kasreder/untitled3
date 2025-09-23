// 파일 경로: lib/features/auth/models/user.dart
// 파일 설명: 로그인한 회원 프로필을 표현하는 불변 도메인 모델.

import 'login_type.dart';

/// 인증·감사·콘텐츠 개인화에 필요한 메타데이터를 담은 플랫폼 회원 모델.
class User {
  /// 새로운 [User] 인스턴스를 생성한다.
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.encryptedPassword,
    required this.loginType,
    required this.nickname,
    required this.points,
    required this.joinedAt,
    required this.updatedAt,
    required this.nicknameUpdatedAt,
    required this.authoredPostTitles,
  });

  /// 회원 레코드의 안정적인 기본 키.
  final String id;

  /// 본인 확인과 정산에 사용하는 실명.
  final String name;

  /// 로그인에 사용하는 식별자. 중복 검사를 위해 평문으로 저장하며,
  /// 자격 증명은 AES-256 요건에 맞춰 암호화된다.
  final String email;

  /// 로컬 인증 회원을 위한 AES-256 암호화 비밀번호.
  ///
  /// 카카오·네이버 사용자는 비밀번호 대신 암호화된 리프레시 토큰을 보관한다.
  final String encryptedPassword;

  /// 회원이 가입 시 선택한 인증 채널(로컬, 카카오, 네이버).
  final LoginType loginType;

  /// 게시글에 표시되는 닉네임.
  final String nickname;

  /// 회원의 현재 포인트 잔액.
  final int points;

  /// 최초 가입 시각.
  final DateTime joinedAt;

  /// 닉네임을 제외한 최근 프로필 수정 시각.
  final DateTime updatedAt;

  /// 최근 닉네임 변경 시각.
  final DateTime nicknameUpdatedAt;

  /// "내가쓴글보기" 목록에 사용하는 최근 게시글 제목 캐시.
  final List<String> authoredPostTitles;

  /// 회원이 로컬 자격 증명을 사용하는지 나타내는 편의 플래그.
  bool get isLocalLogin => loginType == LoginType.local;

  /// 화면 표시에 활용할 익명화된 이메일 문자열을 반환한다.
  String get maskedEmail {
    final parts = email.split('@');
    if (parts.length != 2) {
      return email;
    }
    final username = parts.first;
    if (username.isEmpty) {
      return email;
    }
    final masked = username.length <= 2
        ? '${username[0]}***'
        : '${username.substring(0, 2)}***';
    return '$masked@${parts.last}';
  }

  /// 선택한 값만 변경한 새로운 [User] 복사본을 생성한다.
  User copyWith({
    String? name,
    String? email,
    String? encryptedPassword,
    LoginType? loginType,
    String? nickname,
    int? points,
    DateTime? joinedAt,
    DateTime? updatedAt,
    DateTime? nicknameUpdatedAt,
    List<String>? authoredPostTitles,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      loginType: loginType ?? this.loginType,
      nickname: nickname ?? this.nickname,
      points: points ?? this.points,
      joinedAt: joinedAt ?? this.joinedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nicknameUpdatedAt: nicknameUpdatedAt ?? this.nicknameUpdatedAt,
      authoredPostTitles:
          authoredPostTitles ?? List<String>.from(this.authoredPostTitles),
    );
  }
}
