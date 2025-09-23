// 파일 경로: lib/features/auth/controllers/auth_controller.dart
// 파일 설명: 인증 상태와 메타마스크 연동을 관리하는 상태 알림 컨트롤러.

import 'package:flutter/foundation.dart';

import 'package:untitled3/features/auth/data/dummy_user_repository.dart';
import 'package:untitled3/features/auth/models/login_type.dart';
import 'package:untitled3/features/auth/models/user.dart';
import 'package:untitled3/features/auth/models/user_wallet.dart';
import 'package:untitled3/features/auth/services/metamask_connector.dart';

/// 애플리케이션에서 인증 상태를 보관하고 갱신하는 반응형 컨트롤러.
///
/// 자격 증명 검증, 지갑 연동, 게시글 불러오기를 조율하면서 화면에는 불변 뷰모델만 노출한다.
class AuthController extends ChangeNotifier {
  AuthController({
    required DummyUserRepository userRepository,
    required MetamaskConnector metamaskConnector,
  })  : _userRepository = userRepository,
        _metamaskConnector = metamaskConnector;

  final DummyUserRepository _userRepository;
  final MetamaskConnector _metamaskConnector;

  User? _currentUser;
  UserWallet? _currentWallet;
  List<String> _authoredPosts = <String>[];
  String? _connectedWalletAddress;

  bool _isLoading = false;
  String? _errorMessage;

  /// 현재 로그인한 회원(로그아웃 시 null).
  User? get currentUser => _currentUser;

  /// 현재 세션과 연결된 메타마스크 지갑.
  UserWallet? get currentWallet => _currentWallet;

  /// "내가쓴글보기" 모듈에서 사용하는 게시글 제목 캐시.
  List<String> get authoredPosts => List.unmodifiable(_authoredPosts);

  /// 최근 메타마스크 연동에서 확인된 지갑 주소.
  String? get connectedWalletAddress => _connectedWalletAddress;

  /// 제출 버튼 비활성화를 위한 로딩 상태.
  bool get isLoading => _isLoading;

  /// 인증 시도 중 발생한 최신 오류 메시지.
  String? get errorMessage => _errorMessage;

  /// 현재 세션을 변경하지 않고 저장된 오류 메시지를 초기화한다.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 로컬에 저장된 자격 증명으로 로그인한다.
  Future<void> loginWithLocal({
    required String email,
    required String password,
  }) async {
    await _guardedExecution(() async {
      final user = await _userRepository.authenticateLocal(
        email: email,
        password: password,
      );
      await _hydrateSession(user);
    });
  }

  /// 주어진 이메일을 활용해 카카오 또는 네이버 소셜 로그인을 시작한다.
  Future<void> loginWithSocial({
    required LoginType loginType,
    required String email,
  }) async {
    await _guardedExecution(() async {
      final user = await _userRepository.authenticateSocial(
        loginType: loginType,
        email: email,
      );
      await _hydrateSession(user);
    });
  }

  /// 메타마스크 지갑을 연결하고 인증용 메시지에 서명한다.
  Future<void> loginWithMetamask() async {
    await _guardedExecution(() async {
      final walletAddress = await _metamaskConnector.connectWallet();
      final signed = await _metamaskConnector
          .signAuthenticationMessage('CHEONGNOK_SECURE_LOGIN');
      if (!signed) {
        throw StateError('메타마스크 서명이 확인되지 않았습니다.');
      }
      final user = await _userRepository.findByWalletAddress(walletAddress);
      if (user == null) {
        throw StateError('연동된 회원이 없어 신규 가입이 필요합니다.');
      }
      await _hydrateSession(user, walletAddress: walletAddress);
    });
  }

  /// 인증 상태를 초기화해 빈 세션으로 되돌린다.
  void logout() {
    _currentUser = null;
    _currentWallet = null;
    _authoredPosts = <String>[];
    _connectedWalletAddress = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _guardedExecution(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
    } on StateError catch (error) {
      _errorMessage = error.message;
    } catch (error) {
      _errorMessage = '예기치 못한 오류가 발생했습니다: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _hydrateSession(User user, {String? walletAddress}) async {
    _currentUser = user;
    _currentWallet = await _userRepository.fetchWallet(user.id);
    _authoredPosts = await _userRepository.fetchAuthoredPosts(user.id);
    _connectedWalletAddress = walletAddress ?? _currentWallet?.metamaskAddress;
  }
}
