// File: lib/features/auth/models/user.dart
// Description: Immutable domain model describing a signed-in member profile.

import 'login_type.dart';

/// Represents a registered member of the platform with metadata needed for
/// authentication, auditing, and content personalization.
class User {
  /// Creates a new [User] instance.
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

  /// Stable primary key for the member record.
  final String id;

  /// Legal name used for identity verification and settlement.
  final String name;

  /// Login identifier. Stored in clear text for uniqueness checks, while
  /// credentials are encrypted according to AES-256 requirements.
  final String email;

  /// AES-256 encrypted password for members who authenticate locally.
  ///
  /// Kakao/Naver users retain an encrypted refresh token instead of a password.
  final String encryptedPassword;

  /// Channel the member used during onboarding (local, Kakao, or Naver).
  final LoginType loginType;

  /// Nickname displayed on bulletin board posts.
  final String nickname;

  /// Current reward point balance for the member.
  final int points;

  /// Timestamp of the initial registration event.
  final DateTime joinedAt;

  /// Timestamp of the most recent profile modification (excluding nickname).
  final DateTime updatedAt;

  /// Timestamp of the latest nickname change.
  final DateTime nicknameUpdatedAt;

  /// Cached titles for the member's recent posts, used for "내가쓴글보기" listings.
  final List<String> authoredPostTitles;

  /// Convenience flag indicating whether the member uses local credentials.
  bool get isLocalLogin => loginType == LoginType.local;

  /// Returns an anonymised representation of the member's email for UI display.
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

  /// Generates a new [User] copy with selective overrides.
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
