// 파일 경로: lib/features/auth/models/user_wallet.dart
// 파일 설명: 블록체인 연동을 위한 회원 지갑 메타데이터 모델.

/// 특정 회원의 지갑 연동 상태를 표현하는 불변 스냅샷.
class UserWallet {
  /// 지갑 모델을 생성한다.
  const UserWallet({
    required this.userId,
    required this.metamaskAddress,
    required this.createdAt,
    required this.lastSyncedAt,
    required this.isActive,
  });

  /// 소유 회원의 [User.id]를 참조하는 외래 키.
  final String userId;

  /// 메타마스크 제공자로부터 받은 이더리움 호환 주소.
  final String metamaskAddress;

  /// 지갑이 최초로 연동된 시각.
  final DateTime createdAt;

  /// 메타마스크와 마지막으로 동기화한 시각.
  final DateTime lastSyncedAt;

  /// 지갑을 거래에 사용할 수 있는지 나타내는 플래그.
  final bool isActive;

  /// 일부 값을 변경한 새로운 [UserWallet] 인스턴스를 반환한다.
  UserWallet copyWith({
    String? metamaskAddress,
    DateTime? lastSyncedAt,
    bool? isActive,
  }) {
    return UserWallet(
      userId: userId,
      metamaskAddress: metamaskAddress ?? this.metamaskAddress,
      createdAt: createdAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
