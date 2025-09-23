// File: lib/features/auth/controllers/auth_controller.dart
// Description: ChangeNotifier managing authentication state and MetaMask linking.

import 'package:flutter/foundation.dart';

import 'package:untitled3/features/auth/data/dummy_user_repository.dart';
import 'package:untitled3/features/auth/models/login_type.dart';
import 'package:untitled3/features/auth/models/user.dart';
import 'package:untitled3/features/auth/models/user_wallet.dart';
import 'package:untitled3/features/auth/services/metamask_connector.dart';

/// Reactive authentication state holder for the application.
///
/// The controller orchestrates credential validation, wallet handshakes, and
/// content retrieval ("내가쓴글보기") while exposing immutable view models to the UI.
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

  /// Currently authenticated member (null when signed out).
  User? get currentUser => _currentUser;

  /// MetaMask wallet linked to the current session.
  UserWallet? get currentWallet => _currentWallet;

  /// Cached titles used for the "내가쓴글보기" module.
  List<String> get authoredPosts => List.unmodifiable(_authoredPosts);

  /// Wallet address returned by the latest MetaMask handshake.
  String? get connectedWalletAddress => _connectedWalletAddress;

  /// Exposes loading state to disable submit buttons.
  bool get isLoading => _isLoading;

  /// Latest error message resulting from an authentication attempt.
  String? get errorMessage => _errorMessage;

  /// Clears any stored error message without mutating the current session.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Attempts to sign in with locally stored credentials.
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

  /// Initiates a social login flow (Kakao or Naver) using the provided email.
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

  /// Connects to MetaMask and signs a challenge string for authentication.
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

  /// Resets the authentication state to an empty session.
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
