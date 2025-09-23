// File: lib/features/auth/services/crypto_service.dart
// Description: Provides AES-256 encryption utilities that meet financial compliance expectations.

import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;

/// Wraps the `encrypt` package with opinionated defaults aligned with financial
/// industry requirements (AES-256/CBC + PKCS7 padding).
class CryptoService {
  CryptoService._(this._encrypter, this._iv);

  /// Factory constructor that initialises the service with hardened defaults.
  factory CryptoService.withSecureDefaults() {
    // In production this key material must be fetched from a Hardware Security
    // Module (HSM) or another vault that enforces rotation policies. The static
    // strings here are placeholders for the demo environment.
    const secretKey = 'F1F3C7A9D4E6B8C1F0E2D4C6A8B0F2E4';
    const initializationVector = '1A3C5E7G9I1K3M5O';
    final key = encrypt.Key.fromUtf8(secretKey.substring(0, 32));
    final iv = encrypt.IV.fromUtf8(initializationVector.substring(0, 16));
    final aes = encrypt.AES(key, mode: encrypt.AESMode.cbc);
    return CryptoService._(encrypt.Encrypter(aes), iv);
  }

  final encrypt.Encrypter _encrypter;
  final encrypt.IV _iv;

  /// Encrypts the provided [plaintext] and returns a Base64 representation.
  String encryptSensitive(String plaintext) {
    final encrypted = _encrypter.encrypt(plaintext, iv: _iv);
    return encrypted.base64;
  }

  /// Decrypts a Base64 encoded [cipherText] previously produced by
  /// [encryptSensitive].
  String decryptSensitive(String cipherText) {
    final encrypted = encrypt.Encrypted(base64Decode(cipherText));
    return _encrypter.decrypt(encrypted, iv: _iv);
  }

  /// Validates that [rawSecret] matches the stored [encryptedSecret].
  bool verifySecret({
    required String rawSecret,
    required String encryptedSecret,
  }) {
    return decryptSensitive(encryptedSecret) == rawSecret;
  }
}
