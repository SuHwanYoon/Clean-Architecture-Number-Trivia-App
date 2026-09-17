// NetworkInfo는 네트워크 연결 상태를 확인하는 추상 클래스입니다.
// 이 클래스는 네트워크 연결 상태를 확인하는 기능을 제공합니다.
// 예를 들어, 인터넷 연결 여부를 확인할 수 있습니다.
// 이 추상 클래스를 구현하는 구체적인 클래스는 실제 네트워크 상태를 확인하는 로직을 포함해야 합니다.

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

// NetworkInfo는 네트워크 연결 상태를 확인하는 기능을 제공하는 추상 클래스입니다.
// get키워드는 속성처럼 접근할 수 있는 메서드를 정의할 때 사용됩니다.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

// NetworkInfoImpl은 NetworkInfo를 구현한 구체적인 클래스입니다.
// 실제로 인터넷 연결 상태를 확인하기 위해 InternetConnectionChecker를 사용합니다.
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnection internetConnectionChecker;

  NetworkInfoImpl({required this.internetConnectionChecker});

  @override
  Future<bool> get isConnected => internetConnectionChecker.hasInternetAccess;
}
