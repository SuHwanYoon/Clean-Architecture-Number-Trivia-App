import 'package:clean_architecture_app/core/network/network_info.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockInternetConnectionChecker extends Mock
    implements InternetConnection {}

void main() {
  late NetworkInfoImpl networkInfoImpl;
  late MockInternetConnectionChecker mockInternetConnectionChecker;

  setUp(() {
    mockInternetConnectionChecker = MockInternetConnectionChecker();
    networkInfoImpl = NetworkInfoImpl(
      internetConnectionChecker: mockInternetConnectionChecker,
    );
  });

  group('isConnected', () {
    test(
      'should forward the call to InternetConnectionChecker.hasInternetAccess',
      () async {
        // arrange
        // mockInternetConnectionChecker의 hasInternetAccess를 true로 설정
        when(() => mockInternetConnectionChecker.hasInternetAccess)
            .thenAnswer((_) async => true);

        // act
        // act: networkInfoImpl의 isConnected를 호출하여 실제 결과를 가져옴
        final result = await networkInfoImpl.isConnected;

        // assert
        // assert: 실제 결과가 true인지 확인하고, InternetConnectionChecker.hasInternetAccess가 호출되었는지 검증
        expect(result, true);
        verify(() => mockInternetConnectionChecker.hasInternetAccess).called(1);
      },
    );
  });
}
