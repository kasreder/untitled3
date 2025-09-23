// 파일 경로: lib/features/auth/data/dummy_user_repository.dart
// 파일 설명: 데모 회원과 암호화된 자격 증명을 보관하는 인메모리 저장소.

import 'dart:async';

import '../models/login_type.dart';
import '../models/user.dart';
import '../models/user_wallet.dart';
import '../services/crypto_service.dart';

/// 실제 데이터베이스 대신 프로토타입에서 회원·지갑 데이터를 함께 제공하는 저장소.
class DummyUserRepository {
  DummyUserRepository({required CryptoService cryptoService})
      : _cryptoService = cryptoService {
    _seedData();
  }

  final CryptoService _cryptoService;
  final List<_UserBundle> _bundles = <_UserBundle>[];
  bool _initialised = false;

  void _seedData() {
    if (_initialised) {
      return;
    }
    final now = DateTime.now();
    _bundles
      ..add(
        _UserBundle(
          user: User(
            id: 'USR-2024001',
            name: '청록 회원',
            email: 'member@cheongnok.kr',
            encryptedPassword: _cryptoService.encryptSensitive('S@feLocalPass!1'),
            loginType: LoginType.local,
            nickname: '푸른바람',
            points: 1250,
            joinedAt: DateTime(now.year - 1, 5, 20, 10, 24),
            updatedAt: DateTime(now.year, 2, 12, 9, 15),
            nicknameUpdatedAt: DateTime(now.year, 1, 5, 20, 40),
            authoredPostTitles: const [
              '웹3 지갑 연동 가이드',
              '자유게시판 규칙 정리',
              '이번 주 실험실 소식',
            ],
          ),
          wallet: UserWallet(
            userId: 'USR-2024001',
            metamaskAddress: '0x1fB2a489E1d7c2F4e3A1B8C9d0E2F3a4B5C6d7E8',
            createdAt: DateTime(now.year - 1, 7, 2, 14, 12),
            lastSyncedAt: now.subtract(const Duration(hours: 12)),
            isActive: true,
          ),
        ),
      )
      ..add(
        _UserBundle(
          user: User(
            id: 'USR-2024002',
            name: '카카오 손님',
            email: 'kakao-user@cheongnok.kr',
            encryptedPassword: _cryptoService.encryptSensitive('EncryptedTokenForKakao'),
            loginType: LoginType.kakao,
            nickname: '노란행성',
            points: 480,
            joinedAt: DateTime(now.year - 2, 3, 10, 8, 0),
            updatedAt: DateTime(now.year - 1, 12, 25, 16, 35),
            nicknameUpdatedAt: DateTime(now.year - 1, 11, 2, 18, 10),
            authoredPostTitles: const [
              '카카오 로그인 연동 후기',
              '포인트로 굿즈 사는 법',
            ],
          ),
          wallet: UserWallet(
            userId: 'USR-2024002',
            metamaskAddress: '0x9aE4b5C6d7E8F9a0B1C2d3E4F5a6B7c8D9E0F1A2',
            createdAt: DateTime(now.year - 2, 8, 17, 11, 5),
            lastSyncedAt: now.subtract(const Duration(days: 3, hours: 4)),
            isActive: true,
          ),
        ),
      )
      ..add(
        _UserBundle(
          user: User(
            id: 'USR-2024003',
            name: '네이버 손님',
            email: 'naver-user@cheongnok.kr',
            encryptedPassword: _cryptoService.encryptSensitive('EncryptedTokenForNaver'),
            loginType: LoginType.naver,
            nickname: '초록이슬',
            points: 960,
            joinedAt: DateTime(now.year - 3, 9, 30, 19, 50),
            updatedAt: DateTime(now.year - 1, 6, 1, 9, 42),
            nicknameUpdatedAt: DateTime(now.year - 1, 5, 9, 7, 13),
            authoredPostTitles: const [
              '네이버 로그인 Q&A',
              '정보 게시판 필독 공지',
              '내가쓴글보기 기능 제안',
            ],
          ),
          wallet: UserWallet(
            userId: 'USR-2024003',
            metamaskAddress: '0x7bC8d9E0F1A2b3C4d5E6f7A8B9c0D1E2F3A4B5C6',
            createdAt: DateTime(now.year - 3, 10, 1, 8, 45),
            lastSyncedAt: now.subtract(const Duration(days: 10)),
            isActive: false,
          ),
        ),
      );
    _initialised = true;
  }

  /// 암호화된 비밀번호 저장소를 활용해 로컬 자격 증명을 검증한다.
  Future<User> authenticateLocal({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final bundle = _findByEmail(email);
    if (bundle == null || !bundle.user.isLocalLogin) {
      throw StateError('등록되지 않은 로컬 계정입니다.');
    }
    final matches = _cryptoService.verifySecret(
      rawSecret: password,
      encryptedSecret: bundle.user.encryptedPassword,
    );
    if (!matches) {
      throw StateError('비밀번호가 일치하지 않습니다.');
    }
    return bundle.user;
  }

  /// 카카오 또는 네이버 소셜 로그인에 연동된 프로필을 반환한다.
  Future<User> authenticateSocial({
    required LoginType loginType,
    required String email,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    final bundle = _findByEmail(email);
    if (bundle == null || bundle.user.loginType != loginType) {
      throw StateError('연동된 소셜 계정을 찾을 수 없습니다.');
    }
    return bundle.user;
  }

  /// 지정된 회원의 지갑 정보를 조회한다.
  Future<UserWallet?> fetchWallet(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
    try {
      return _bundles
          .firstWhere((bundle) => bundle.user.id == userId)
          .wallet;
    } on StateError {
      return null;
    }
  }

  /// 연결된 메타마스크 지갑 주소로 회원을 찾는다.
  Future<User?> findByWalletAddress(String walletAddress) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    try {
      final bundle = _bundles.firstWhere(
        (entry) =>
            entry.wallet.metamaskAddress.toLowerCase() == walletAddress.toLowerCase(),
      );
      return bundle.user;
    } on StateError {
      return null;
    }
  }

  /// "내가쓴글보기"에 사용할 회원 작성 글 제목 목록을 불러온다.
  Future<List<String>> fetchAuthoredPosts(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 210));
    try {
      final bundle = _bundles.firstWhere(
        (entry) => entry.user.id == userId,
      );
      return List<String>.from(bundle.user.authoredPostTitles);
    } on StateError {
      return <String>[];
    }
  }

  _UserBundle? _findByEmail(String email) {
    try {
      return _bundles.firstWhere(
        (bundle) => bundle.user.email.toLowerCase() == email.toLowerCase(),
      );
    } on StateError {
      return null;
    }
  }
}

class _UserBundle {
  const _UserBundle({required this.user, required this.wallet});

  final User user;
  final UserWallet wallet;
}
