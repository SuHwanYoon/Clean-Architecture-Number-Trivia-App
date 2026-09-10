import 'package:clean_architecture_app/core/platform/network_info.dart';
import 'package:clean_architecture_app/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_architecture_app/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture_app/features/number_trivia/data/repositories/number_trivia_reposiotry_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mocktail을 사용하여 원격 및 로컬 데이터 소스를 모킹하는 클래스 정의
// 원격 데이터 소스와 로컬 데이터 소스를 모킹하여 테스트에서 사용할 수 있도록 합니다.
class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

// NumberTriviaRepositoryImpl의 테스트를 위한 모킹된 의존성 설정
void main() {
  // 테스트에서 사용할 모킹된 의존성 초기화
  late NumberTriviaRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

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
  // 테스트 케이스를 여기에 추가
  final tNumber = 1;
  final tNumberTriviaModel = NumberTriviaModel(
    number: tNumber,
    text: 'Test trivia',
  );

  group('getConcreteNumberTrivia', () {
    // 테스트: 온라인 상태의 케이스
    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
            .thenAnswer((_) async {});
      });

      // 테스트: 원격 데이터 소스 호출이 성공하면 원격 데이터를 반환해야 함
      test('should return remote data when the call to remote data source is successful', () async {
        // arrange
        when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
            .thenAnswer((_) async => tNumberTriviaModel);
        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // assert
        expect(result, Right(tNumberTriviaModel));
        verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
            .called(1);
      });
      // 테스트: 원격 데이터 소스 호출이 실해하면 로컬 캐쉬 데이터를 반환해야 함
      test('should cache the data locally when the call to remote data source is successful', () async {
        // arrange
        when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
            .thenAnswer((_) async => tNumberTriviaModel);
        // act
        await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verify(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
            .called(1);
      });
    });
    group('device is offline', () {
      // 오프라인 상태에서의 테스트 케이스를 여기에 추가
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
    });
  });
}
