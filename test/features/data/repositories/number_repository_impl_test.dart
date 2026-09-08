import 'package:clean_architecture_app/core/platform/network_info.dart';
import 'package:clean_architecture_app/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_architecture_app/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_app/features/number_trivia/data/repositories/number_trivia_reposiotry_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Mockito를 사용하여 원격 및 로컬 데이터 소스를 모킹하는 클래스 정의
// 원격 데이터 소스와 로컬 데이터 소스를 모킹하여 테스트에서 사용할 수 있도록 합니다.
class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

// NumberTriviaRepositoryImpl의 테스트를 위한 모킹된 의존성 설정
void main() {
  // 테스트에서 사용할 모킹된 의존성 초기화
  NumberTriviaRepositoryImpl repository;
  MockRemoteDataSource mockRemoteDataSource;
  MockLocalDataSource mockLocalDataSource;
  MockNetworkInfo mockNetworkInfo;

  // 각 테스트 전에 실행되는 초기화 코드 설정
  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    // 모킹된 의존성을 사용하여 NumberTriviaRepositoryImpl 인스턴스 생성
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });
}
