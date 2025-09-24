// 파일 경로: lib/features/auth/data/dummy_user_repository.dart
// 파일 설명: 데모 회원과 암호화된 자격 증명을 보관하는 인메모리 저장소.

import 'dart:async';
import '../models/login_type.dart';
import '../models/user.dart';
import '../models/user_grade.dart';
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
            name: '김청록',
            email: 'cheongrok@cheongnok.kr',
            encryptedPassword: _cryptoService.encryptSensitive('S@feLocalPass!1'),
            loginType: LoginType.local,
            nickname: '청록고래',
            grade: UserGrade.admin2,
            points: 1820,
            joinedAt: DateTime(now.year - 2, 4, 8, 9, 30),
            updatedAt: DateTime(now.year, 1, 12, 11, 5),
            nicknameUpdatedAt: DateTime(now.year - 1, 11, 20, 15, 45),
            authoredPostTitles: const ['웹3 커뮤니티 온보딩 꿀팁', '온체인 거버넌스 워크숍'],
          ),
          wallet: UserWallet(
            userId: 'USR-2024001',
            metamaskAddress: '0x1fB2a489E1d7c2F4e3A1B8C9d0E2F3a4B5C6d7E8',
            createdAt: DateTime(now.year - 2, 6, 14, 12, 0),
            lastSyncedAt: now.subtract(const Duration(hours: 12)),
            isActive: true,
          ),
        ),
      )
      ..add(
        _UserBundle(
          user: User(
            id: 'USR-2024002',
            name: '이메타',
            email: 'meta@cheongnok.kr',
            encryptedPassword: _cryptoService.encryptSensitive('EncryptedTokenForKakao'),
            loginType: LoginType.kakao,
            nickname: '메타연구원',
            grade: UserGrade.expert,
            points: 1260,
            joinedAt: DateTime(now.year - 3, 3, 10, 8, 0),
            updatedAt: DateTime(now.year - 1, 12, 25, 16, 35),
            nicknameUpdatedAt: DateTime(now.year - 1, 11, 2, 18, 10),
            authoredPostTitles: const ['DAO 투표 시스템 실험 후기', '거버넌스 참여율 데이터 노트'],
          ),
          wallet: UserWallet(
            userId: 'USR-2024002',
            metamaskAddress: '0x9aE4b5C6d7E8F9a0B1C2d3E4F5a6B7c8D9E0F1A2',
            createdAt: DateTime(now.year - 3, 8, 17, 11, 5),
            lastSyncedAt: now.subtract(const Duration(days: 3, hours: 4)),
            isActive: true,
          ),
        ),
      )
      ..add(
        _UserBundle(
          user: User(
            id: 'USR-2024003',
            name: '박인터',
            email: 'ui@cheongnok.kr',
            encryptedPassword: _cryptoService.encryptSensitive('EncryptedTokenForNaver'),
            loginType: LoginType.naver,
            nickname: 'UI코더',
            grade: UserGrade.semiExpert,
            points: 980,
            joinedAt: DateTime(now.year - 2, 9, 30, 19, 50),
            updatedAt: DateTime(now.year - 1, 6, 1, 9, 42),
            nicknameUpdatedAt: DateTime(now.year - 1, 5, 9, 7, 13),
            authoredPostTitles: const ['커뮤니티 디자인 시스템 업데이트', '디자인 QA 체크리스트'],
          ),
          wallet: UserWallet(
            userId: 'USR-2024003',
            metamaskAddress: '0x7bC8d9E0F1A2b3C4d5E6f7A8B9c0D1E2F3A4B5C6',
            createdAt: DateTime(now.year - 2, 10, 1, 8, 45),
            lastSyncedAt: now.subtract(const Duration(days: 10)),
            isActive: false,
          ),
        ),
      )
      ..add(
        _UserBundle(
          user: User(
            id: 'USR-2024004',
            name: '장다리',
            email: 'bridge@cheongnok.kr',
            encryptedPassword: _cryptoService.encryptSensitive('S@feLocalPass!1'),
            loginType: LoginType.local,
            nickname: '브릿지메이커',
            grade: UserGrade.regular,
            points: 720,
            joinedAt: DateTime(now.year - 1, 2, 12, 9, 15),
            updatedAt: DateTime(now.year, 2, 22, 14, 10),
            nicknameUpdatedAt: DateTime(now.year - 1, 12, 1, 17, 20),
            authoredPostTitles: const ['생태계 파트너십 제안서', '협업 파트너 체크리스트'],
          ),
          wallet: UserWallet(
            userId: 'USR-2024004',
            metamaskAddress: '0x5cD7e8F9012a3b4C5d6E7f8A9B0c1D2E3f4A5B6',
            createdAt: DateTime(now.year - 1, 3, 5, 10, 20),
            lastSyncedAt: now.subtract(const Duration(days: 5, hours: 6)),
            isActive: true,
          ),
        ),
      )
      ..add(
        _UserBundle(
          user: User(
            id: 'USR-2024005',
            name: '문소식',
            email: 'newsletter@cheongnok.kr',
            encryptedPassword: _cryptoService.encryptSensitive('S@feLocalPass!1'),
            loginType: LoginType.local,
            nickname: '뉴스레터장인',
            grade: UserGrade.semiExpert,
            points: 1540,
            joinedAt: DateTime(now.year - 2, 7, 18, 13, 5),
            updatedAt: DateTime(now.year - 1, 9, 14, 10, 0),
            nicknameUpdatedAt: DateTime(now.year - 1, 9, 1, 8, 45),
            authoredPostTitles: const ['제휴 뉴스레터 배포 결과', '콘텐츠 캘린더 초안'],
          ),
          wallet: UserWallet(
            userId: 'USR-2024005',
            metamaskAddress: '0x4bA6c7D8e9F0123A4b5C6d7E8F9a0B1C2d3E4f5',
            createdAt: DateTime(now.year - 2, 8, 20, 9, 30),
            lastSyncedAt: now.subtract(const Duration(days: 2, hours: 8)),
            isActive: true,
          ),
        ),
      )
      ..add(
        _UserBundle(
          user: User(
            id: 'USR-2024006',
            name: '정가드',
            email: 'guardian@cheongnok.kr',
            encryptedPassword: _cryptoService.encryptSensitive('S@feLocalPass!1'),
            loginType: LoginType.local,
            nickname: '커뮤니티가드',
            grade: UserGrade.admin1,
            points: 2100,
            joinedAt: DateTime(now.year - 3, 5, 14, 7, 40),
            updatedAt: DateTime(now.year, 3, 2, 9, 5),
            nicknameUpdatedAt: DateTime(now.year - 1, 8, 19, 20, 15),
            authoredPostTitles: const ['커뮤니티 가이드라인 개정', '신규 멤버 온보딩 체크'],
          ),
          wallet: UserWallet(
            userId: 'USR-2024006',
            metamaskAddress: '0x3a95b6C7d8E9f0A1B2c3D4e5F6a7B8c9D0e1F2a',
            createdAt: DateTime(now.year - 3, 6, 11, 18, 25),
            lastSyncedAt: now.subtract(const Duration(hours: 3, minutes: 30)),
            isActive: true,
          ),
        ),
      )
      ..add(
        _UserBundle(
          user: User(
            id: 'USR-2024007',
            name: '최멘토',
            email: 'mentor@cheongnok.kr',
            encryptedPassword: _cryptoService.encryptSensitive('EncryptedTokenForKakao'),
            loginType: LoginType.kakao,
            nickname: '멘토링리드',
            grade: UserGrade.expert,
            points: 990,
            joinedAt: DateTime(now.year - 1, 4, 3, 11, 25),
            updatedAt: DateTime(now.year, 1, 28, 15, 0),
            nicknameUpdatedAt: DateTime(now.year - 1, 10, 12, 9, 0),
            authoredPostTitles: const ['커뮤니티 멘토링 프로그램', '멘토 피드백 수집법'],
          ),
          wallet: UserWallet(
            userId: 'USR-2024007',
            metamaskAddress: '0x2b84c5D6e7F8091A2b3C4d5E6F7a8B9c0D1E2f3',
            createdAt: DateTime(now.year - 1, 5, 8, 13, 40),
            lastSyncedAt: now.subtract(const Duration(days: 7)),
            isActive: true,
          ),
        ),
      )
      ..add(
        _UserBundle(
          user: User(
            id: 'USR-2024008',
            name: '권토큰',
            email: 'token@cheongnok.kr',
            encryptedPassword: _cryptoService.encryptSensitive('S@feLocalPass!1'),
            loginType: LoginType.local,
            nickname: '토큰디자이너',
            grade: UserGrade.developer,
            points: 1750,
            joinedAt: DateTime(now.year - 2, 11, 22, 14, 55),
            updatedAt: DateTime(now.year - 1, 10, 2, 19, 30),
            nicknameUpdatedAt: DateTime(now.year - 1, 7, 21, 16, 5),
            authoredPostTitles: const ['탈중앙 보상 시스템 설계', '보상 토큰 시뮬레이션'],
          ),
          wallet: UserWallet(
            userId: 'USR-2024008',
            metamaskAddress: '0x8cD1e2F3a4B5c6D7e8F9012A3b4C5d6E7f8A9b0',
            createdAt: DateTime(now.year - 2, 12, 2, 10, 10),
            lastSyncedAt: now.subtract(const Duration(hours: 18)),
            isActive: true,
          ),
        ),
      )
      ..add(
        _UserBundle(
          user: User(
            id: 'USR-2024009',
            name: '신운영',
            email: 'operation@cheongnok.kr',
            encryptedPassword: _cryptoService.encryptSensitive('S@feLocalPass!1'),
            loginType: LoginType.local,
            nickname: '운영리더',
            grade: UserGrade.admin2,
            points: 2380,
            joinedAt: DateTime(now.year - 4, 1, 15, 9, 0),
            updatedAt: DateTime(now.year, 2, 5, 8, 20),
            nicknameUpdatedAt: DateTime(now.year - 1, 3, 28, 17, 45),
            authoredPostTitles: const ['월간 운영 보고서', '운영 현황 점검 회의록'],
          ),
          wallet: UserWallet(
            userId: 'USR-2024009',
            metamaskAddress: '0x6dE0f1A2b3C4d5E6f7A8b9C0D1e2F3A4b5C6d7E',
            createdAt: DateTime(now.year - 4, 2, 1, 14, 30),
            lastSyncedAt: now.subtract(const Duration(hours: 1, minutes: 45)),
            isActive: true,
          ),
        ),
      )
      ..add(
        _UserBundle(
          user: User(
            id: 'USR-2024010',
            name: '서가이드',
            email: 'sherpa@cheongnok.kr',
            encryptedPassword: _cryptoService.encryptSensitive('EncryptedTokenForNaver'),
            loginType: LoginType.naver,
            nickname: '콘텐츠셰르파',
            grade: UserGrade.regular,
            points: 880,
            joinedAt: DateTime(now.year - 2, 5, 6, 16, 10),
            updatedAt: DateTime(now.year - 1, 4, 14, 9, 50),
            nicknameUpdatedAt: DateTime(now.year - 1, 2, 20, 7, 35),
            authoredPostTitles: const ['콘텐츠 큐레이션 방법', '추천 아티클 아카이브'],
          ),
          wallet: UserWallet(
            userId: 'USR-2024010',
            metamaskAddress: '0x9eF0123A4b5C6d7E8f9A0B1c2D3e4F5A6b7C8d9',
            createdAt: DateTime(now.year - 2, 6, 1, 9, 25),
            lastSyncedAt: now.subtract(const Duration(days: 14)),
            isActive: false,
          ),
        ),
      )
      ..add(
        _UserBundle(
          user: User(
            id: 'USR-2024011',
            name: '안커넥',
            email: 'connector@cheongnok.kr',
            encryptedPassword: _cryptoService.encryptSensitive('S@feLocalPass!1'),
            loginType: LoginType.local,
            nickname: '커넥터',
            grade: UserGrade.semiExpert,
            points: 1330,
            joinedAt: DateTime(now.year - 2, 1, 9, 10, 45),
            updatedAt: DateTime(now.year - 1, 8, 30, 11, 25),
            nicknameUpdatedAt: DateTime(now.year - 1, 5, 18, 9, 15),
            authoredPostTitles: const ['네트워킹 데이 리캡', '파트너십 문의 로그'],
          ),
          wallet: UserWallet(
            userId: 'USR-2024011',
            metamaskAddress: '0x1a23b45C6d7E8f9A0b1C2d3E4f5A6b7C8d9E0f1',
            createdAt: DateTime(now.year - 2, 2, 4, 15, 10),
            lastSyncedAt: now.subtract(const Duration(days: 1, hours: 6)),
            isActive: true,
          ),
        ),
      )
      ..add(
        _UserBundle(
          user: User(
            id: 'USR-2024012',
            name: '백데이터',
            email: 'data@cheongnok.kr',
            encryptedPassword: _cryptoService.encryptSensitive('S@feLocalPass!1'),
            loginType: LoginType.local,
            nickname: '데이터관리자',
            grade: UserGrade.expert,
            points: 1680,
            joinedAt: DateTime(now.year - 3, 10, 12, 9, 5),
            updatedAt: DateTime(now.year - 1, 11, 22, 12, 40),
            nicknameUpdatedAt: DateTime(now.year - 1, 7, 8, 18, 0),
            authoredPostTitles: const ['데이터 품질 점검 보고', '대시보드 사용 가이드'],
          ),
          wallet: UserWallet(
            userId: 'USR-2024012',
            metamaskAddress: '0x2c34d56E7f8A9b0C1d2E3f4A5b6C7d8E9f0A1b2',
            createdAt: DateTime(now.year - 3, 11, 1, 11, 55),
            lastSyncedAt: now.subtract(const Duration(hours: 5, minutes: 20)),
            isActive: true,
          ),
        ),
      )
      ..add(
        _UserBundle(
          user: User(
            id: 'USR-2024013',
            name: '류릴리즈',
            email: 'release@cheongnok.kr',
            encryptedPassword: _cryptoService.encryptSensitive('EncryptedTokenForKakao'),
            loginType: LoginType.kakao,
            nickname: '릴리즈매니저',
            grade: UserGrade.admin1,
            points: 1900,
            joinedAt: DateTime(now.year - 2, 3, 22, 14, 30),
            updatedAt: DateTime(now.year, 1, 14, 10, 20),
            nicknameUpdatedAt: DateTime(now.year - 1, 9, 6, 8, 10),
            authoredPostTitles: const ['릴리즈 체크리스트', '릴리즈 회고 노트'],
          ),
          wallet: UserWallet(
            userId: 'USR-2024013',
            metamaskAddress: '0x3d45e67F8a9B0c1D2e3F4a5B6c7D8e9F0a1B2c3',
            createdAt: DateTime(now.year - 2, 4, 2, 9, 15),
            lastSyncedAt: now.subtract(const Duration(hours: 2)),
            isActive: true,
          ),
        ),
      )
      ..add(
        _UserBundle(
          user: User(
            id: 'USR-2024014',
            name: '한마켓',
            email: 'market@cheongnok.kr',
            encryptedPassword: _cryptoService.encryptSensitive('S@feLocalPass!1'),
            loginType: LoginType.local,
            nickname: '마켓플래너',
            grade: UserGrade.regular,
            points: 860,
            joinedAt: DateTime(now.year - 1, 6, 15, 10, 5),
            updatedAt: DateTime(now.year, 2, 10, 16, 35),
            nicknameUpdatedAt: DateTime(now.year - 1, 12, 20, 11, 0),
            authoredPostTitles: const ['캠페인 A/B 테스트', '시장 조사 인사이트'],
          ),
          wallet: UserWallet(
            userId: 'USR-2024014',
            metamaskAddress: '0x4e56f7801A2b3C4d5E6f7A8B9c0D1e2F3a4B5c6',
            createdAt: DateTime(now.year - 1, 7, 1, 13, 30),
            lastSyncedAt: now.subtract(const Duration(days: 9)),
            isActive: true,
          ),
        ),
      )
      ..add(
        _UserBundle(
          user: User(
            id: 'USR-2024015',
            name: '표무대',
            email: 'stage@cheongnok.kr',
            encryptedPassword: _cryptoService.encryptSensitive('EncryptedTokenForNaver'),
            loginType: LoginType.naver,
            nickname: '스테이지디렉터',
            grade: UserGrade.admin2,
            points: 2050,
            joinedAt: DateTime(now.year - 3, 1, 18, 15, 20),
            updatedAt: DateTime(now.year - 1, 5, 30, 10, 45),
            nicknameUpdatedAt: DateTime(now.year - 1, 4, 4, 14, 55),
            authoredPostTitles: const ['행사 운영 매뉴얼', '프로덕션 체크리스트'],
          ),
          wallet: UserWallet(
            userId: 'USR-2024015',
            metamaskAddress: '0x5f67012A3b4C5d6E7f8A9b0C1d2E3f4A5b6C7d8',
            createdAt: DateTime(now.year - 3, 2, 9, 17, 0),
            lastSyncedAt: now.subtract(const Duration(days: 4, hours: 6)),
            isActive: true,
          ),
        ),
      )
      ..add(
        _UserBundle(
          user: User(
            id: 'USR-2024016',
            name: '노자동',
            email: 'auto@cheongnok.kr',
            encryptedPassword: _cryptoService.encryptSensitive('S@feLocalPass!1'),
            loginType: LoginType.local,
            nickname: '오토메이터',
            grade: UserGrade.developer,
            points: 1720,
            joinedAt: DateTime(now.year - 2, 8, 4, 9, 55),
            updatedAt: DateTime(now.year - 1, 10, 14, 12, 25),
            nicknameUpdatedAt: DateTime(now.year - 1, 7, 2, 10, 5),
            authoredPostTitles: const ['자동화 스크립트 모음', '워크플로 모니터링'],
          ),
          wallet: UserWallet(
            userId: 'USR-2024016',
            metamaskAddress: '0x6a78123A4b5C6d7E8f9A0b1C2d3E4f5A6b7C8d9',
            createdAt: DateTime(now.year - 2, 9, 12, 16, 40),
            lastSyncedAt: now.subtract(const Duration(hours: 7, minutes: 10)),
            isActive: true,
          ),
        ),
      )
      ..add(
        _UserBundle(
          user: User(
            id: 'USR-2024017',
            name: '송디아이',
            email: 'did@cheongnok.kr',
            encryptedPassword: _cryptoService.encryptSensitive('EncryptedTokenForKakao'),
            loginType: LoginType.kakao,
            nickname: 'DID탐험가',
            grade: UserGrade.semiExpert,
            points: 940,
            joinedAt: DateTime(now.year - 1, 9, 23, 8, 35),
            updatedAt: DateTime(now.year, 1, 5, 11, 50),
            nicknameUpdatedAt: DateTime(now.year - 1, 12, 18, 14, 15),
            authoredPostTitles: const ['DID 서비스 실험기', '분산 신원 도입 제안'],
          ),
          wallet: UserWallet(
            userId: 'USR-2024017',
            metamaskAddress: '0x7b89234A5b6C7d8E9f0A1b2C3d4E5f6A7b8C9d0',
            createdAt: DateTime(now.year - 1, 10, 10, 9, 30),
            lastSyncedAt: now.subtract(const Duration(days: 6)),
            isActive: true,
          ),
        ),
      )
      ..add(
        _UserBundle(
          user: User(
            id: 'USR-2024018',
            name: '임시스',
            email: 'system@cheongnok.kr',
            encryptedPassword: _cryptoService.encryptSensitive('S@feLocalPass!1'),
            loginType: LoginType.local,
            nickname: '시스템설계자',
            grade: UserGrade.expert,
            points: 1620,
            joinedAt: DateTime(now.year - 3, 4, 27, 13, 15),
            updatedAt: DateTime(now.year - 1, 9, 9, 18, 5),
            nicknameUpdatedAt: DateTime(now.year - 1, 6, 30, 9, 40),
            authoredPostTitles: const ['신규 멤버 온체인 인증 흐름', '시스템 구조 리팩토링'],
          ),
          wallet: UserWallet(
            userId: 'USR-2024018',
            metamaskAddress: '0x8c9a345B6c7D8e9F0a1B2c3D4e5F6a7B8c9D0e1',
            createdAt: DateTime(now.year - 3, 5, 6, 15, 50),
            lastSyncedAt: now.subtract(const Duration(hours: 9)),
            isActive: true,
          ),
        ),
      )
      ..add(
        _UserBundle(
          user: User(
            id: 'USR-2024019',
            name: '주체크',
            email: 'checkpoint@cheongnok.kr',
            encryptedPassword: _cryptoService.encryptSensitive('EncryptedTokenForNaver'),
            loginType: LoginType.naver,
            nickname: '체크포인트',
            grade: UserGrade.regular,
            points: 810,
            joinedAt: DateTime(now.year - 1, 3, 14, 10, 20),
            updatedAt: DateTime(now.year - 1, 12, 28, 15, 5),
            nicknameUpdatedAt: DateTime(now.year - 1, 11, 10, 13, 15),
            authoredPostTitles: const ['QA 체크포인트 공유', '업데이트 체커'],
          ),
          wallet: UserWallet(
            userId: 'USR-2024019',
            metamaskAddress: '0x9dab456C7d8E9f0A1b2C3d4E5f6A7b8C9d0E1f2',
            createdAt: DateTime(now.year - 1, 4, 5, 12, 30),
            lastSyncedAt: now.subtract(const Duration(days: 3)),
            isActive: true,
          ),
        ),
      )
      ..add(
        _UserBundle(
          user: User(
            id: 'USR-2024020',
            name: '배언어',
            email: 'language@cheongnok.kr',
            encryptedPassword: _cryptoService.encryptSensitive('S@feLocalPass!1'),
            loginType: LoginType.local,
            nickname: '언어마스터',
            grade: UserGrade.expert,
            points: 1470,
            joinedAt: DateTime(now.year - 2, 4, 1, 8, 10),
            updatedAt: DateTime(now.year - 1, 5, 25, 19, 35),
            nicknameUpdatedAt: DateTime(now.year - 1, 5, 10, 14, 45),
            authoredPostTitles: const ['다국어 번역 가이드', '용어집 관리 전략'],
          ),
          wallet: UserWallet(
            userId: 'USR-2024020',
            metamaskAddress: '0xaebc567D8e9F0a1B2c3D4e5F6a7B8c9D0e1F2a3',
            createdAt: DateTime(now.year - 2, 4, 20, 10, 5),
            lastSyncedAt: now.subtract(const Duration(hours: 12, minutes: 20)),
            isActive: true,
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
