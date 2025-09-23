// File: lib/features/auth/services/metamask_connector.dart
// Description: Simulates MetaMask connectivity for prototype and testing flows.

/// Thin adapter that would bridge the Flutter application with the MetaMask
/// provider available in the hosting environment (Web or mobile deep link).
class MetamaskConnector {
  /// Builds a connector with secure defaults. The real implementation would
  /// inject platform channels or JavaScript bridges.
  MetamaskConnector.secure();

  /// Requests a wallet connection. The dummy implementation returns a fixed
  /// wallet address after a simulated delay.
  Future<String> connectWallet() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return '0xA1B2c3D4e5F6a7B8c9D0E1F2a3B4C5D6E7F8A9B0';
  }

  /// Simulates signing a verification message for user authentication.
  Future<bool> signAuthenticationMessage(String message) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return message.isNotEmpty;
  }
}
