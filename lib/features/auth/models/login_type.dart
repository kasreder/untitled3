// File: lib/features/auth/models/login_type.dart
// Description: Defines the supported authentication providers for the platform.

/// Enumerates the supported login channels for a user account.
///
/// The value is persisted alongside the member profile to describe how
/// the user authenticated during account creation. When a member uses a
/// third-party service (Kakao or Naver), the platform maintains only a
/// reference token, while sensitive profile data is encrypted before
/// storage.
enum LoginType {
  /// Local authentication handled by the platform with encrypted credentials.
  local,

  /// Kakao social login flow, which exchanges authorization codes for tokens.
  kakao,

  /// Naver social login flow, mirroring the Kakao OAuth dance.
  naver,
}
