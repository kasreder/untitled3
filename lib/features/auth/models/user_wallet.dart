// File: lib/features/auth/models/user_wallet.dart
// Description: Describes a user's linked wallet metadata for blockchain operations.

/// Immutable snapshot of the wallet integration for a specific user.
class UserWallet {
  /// Builds a wallet model.
  const UserWallet({
    required this.userId,
    required this.metamaskAddress,
    required this.createdAt,
    required this.lastSyncedAt,
    required this.isActive,
  });

  /// Foreign key referencing the owning [User.id].
  final String userId;

  /// Ethereum-compatible address retrieved from the MetaMask provider.
  final String metamaskAddress;

  /// Timestamp when the wallet was first linked.
  final DateTime createdAt;

  /// Timestamp of the last handshake with MetaMask.
  final DateTime lastSyncedAt;

  /// Flag indicating whether the wallet is available for transactions.
  final bool isActive;

  /// Returns a new [UserWallet] with updated fields.
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
