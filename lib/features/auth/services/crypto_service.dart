// 파일 경로: lib/features/auth/services/crypto_service.dart
// 파일 설명: 금융권 기준을 충족하는 AES-256 암호화 유틸리티를 제공.

import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;

/// 금융권 요구사항(AES-256/CBC + PKCS7 패딩)에 맞춘 기본값으로 `encrypt` 패키지를 감싼다.
class CryptoService {
  CryptoService._(this._encrypter, this._iv);

  /// 강화된 기본 설정으로 서비스를 초기화하는 팩터리 생성자.
  factory CryptoService.withSecureDefaults() {
    // 실제 환경에서는 키 자료를 HSM(하드웨어 보안 모듈) 등 회전 정책을 강제하는 보안 금고에서 가져와야 한다.
    // 아래 정적 문자열은 데모 환경을 위한 자리표시자이다.
    const secretKey = 'F1F3C7A9D4E6B8C1F0E2D4C6A8B0F2E4';
    const initializationVector = '1A3C5E7G9I1K3M5O';
    final key = encrypt.Key.fromUtf8(secretKey.substring(0, 32));
    final iv = encrypt.IV.fromUtf8(initializationVector.substring(0, 16));
    final aes = encrypt.AES(key, mode: encrypt.AESMode.cbc);
    return CryptoService._(encrypt.Encrypter(aes), iv);
  }

  final encrypt.Encrypter _encrypter;
  final encrypt.IV _iv;

  /// 전달된 [plaintext]를 암호화해 Base64 문자열로 반환한다.

  String encryptSensitive(String plaintext) {
    final encrypted = _encrypter.encrypt(plaintext, iv: _iv);
    return encrypted.base64;
  }

  /// [encryptSensitive]로 생성된 Base64 문자열 [cipherText]를 복호화한다.

  String decryptSensitive(String cipherText) {
    final encrypted = encrypt.Encrypted(base64Decode(cipherText));
    return _encrypter.decrypt(encrypted, iv: _iv);
  }

  /// [rawSecret]이 저장된 [encryptedSecret]과 일치하는지 검증한다.

  bool verifySecret({
    required String rawSecret,
    required String encryptedSecret,
  }) {
    return decryptSensitive(encryptedSecret) == rawSecret;
  }
}
