// 파일 경로: lib/features/auth/services/metamask_connector.dart
// 파일 설명: 프로토타입과 테스트용 메타마스크 연동을 모의 구현.

/// 호스팅 환경(웹 또는 모바일 딥링크)의 메타마스크 공급자와 플러터 앱을 연결하는 어댑터.
class MetamaskConnector {
  /// 보안 기본 설정을 적용해 커넥터를 생성한다. 실제 구현에서는 플랫폼 채널이나 자바스크립트 브리지를 주입한다.
  MetamaskConnector.secure();

  /// 지갑 연결을 요청한다. 더미 구현은 지연 이후 고정된 지갑 주소를 반환한다.
  Future<String> connectWallet() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return '0xA1B2c3D4e5F6a7B8c9D0E1F2a3B4C5D6E7F8A9B0';
  }

  /// 사용자 인증을 위한 검증 메시지 서명을 모의한다.
  Future<bool> signAuthenticationMessage(String message) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return message.isNotEmpty;
  }
}
