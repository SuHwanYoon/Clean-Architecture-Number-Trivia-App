// NetworkInfo는 네트워크 연결 상태를 확인하는 추상 클래스입니다.
// 이 클래스는 네트워크 연결 상태를 확인하는 기능을 제공합니다.
// 예를 들어, 인터넷 연결 여부를 확인할 수 있습니다.
// 이 추상 클래스를 구현하는 구체적인 클래스는 실제 네트워크 상태를 확인하는 로직을 포함해야 합니다.

abstract class NetworkInfo {
  Future<bool> get isConnected;
}
