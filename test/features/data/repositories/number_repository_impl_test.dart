import 'package:clean_architecture_app/core/network/network_info.dart';
import 'package:clean_architecture_app/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_architecture_app/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture_app/features/number_trivia/data/repositories/number_trivia_reposiotry_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clean_architecture_app/core/error/exceptions.dart';
import 'package:clean_architecture_app/core/error/failures.dart';

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
    when(() => mockLocalDataSource.cacheNumberTrivia(any()))
        .thenAnswer((_) async {});
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

  setUpAll(() {
    registerFallbackValue(NumberTriviaModel(number: 0, text: ''));
  });

  // 온라인 상태에서 실행되는 테스트를 그룹화하는 헬퍼 함수 정의
  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      body();
    });
  }

  // 오프라인 상태에서 실행되는 테스트를 그룹화하는 헬퍼 함수 정의
  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    // 테스트: 온라인 상태의 케이스
    runTestsOnline(() {
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
      // 테스트: remote data source를 호출성공했을때 로컬 데이터를 캐싱해야 함
      test('should call local data source to cache the data when remote data source call is successful', () async {
        // arrange
        when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
            .thenAnswer((_) async => tNumberTriviaModel);
        // act
        await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verify(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
            .called(1);
      });

      // 테스트: remote data source 호출이 실패하면 예외를 던져야 함
      test('should throw an exception when the call to remote data source is unsuccessful', () async {
        // arrange
        when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
            .thenThrow(Exception());
        // act
        final call = repository.getConcreteNumberTrivia;
        // assert
        verifyNoMoreInteractions(mockRemoteDataSource);
        await expectLater(call(tNumber), throwsA(isA<Exception>()));
      });

      test('should return server failure when the call to remote data source is unsuccessful', () async {
        // arrange
        when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
            .thenThrow(ServerException());

        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);

        // assert
        expect(result, Left(ServerFailure()));
      });
    });

    runTestsOffline(() {
      // 오프라인 상태에서의 테스트 케이스를 여기에 추가

      test('should return last locally cached data when the cached data is present', () async {
        // arrange
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verify(() => mockLocalDataSource.getLastNumberTrivia()).called(1);
        expect(result, Right(tNumberTriviaModel));
      });

      test(
        'should return cache failure when there is no cached data present',
        () async {
          // arrange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());
          // act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          // assert
          verify(() => mockLocalDataSource.getLastNumberTrivia()).called(1);
          expect(result, Left(CacheFailure()));
        },
      );
    });
  });

  // 테스트: getRandomNumberTrivia 메서드에 대한 테스트 케이스를 여기에 추가
  group('getRandomNumberTrivia', () {
    // 테스트: 온라인 상태의 케이스
    runTestsOnline(() {
      // 테스트: 원격 데이터 소스 호출이 성공하면 원격 데이터를 반환해야 함
      test('should return remote data when the call to remote data source is successful', () async {
        // arrange
        when(() => mockRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        // act
        final result = await repository.getRandomNumberTrivia();
        // assert
        expect(result, Right(tNumberTriviaModel));
        verify(() => mockRemoteDataSource.getRandomNumberTrivia()).called(1);
      });
      // 테스트: 원격 데이터 소스 호출이 실해하면 로컬 캐쉬 데이터를 반환해야 함
      test('should cache the data locally when the call to remote data source is successful', () async {
        // arrange
        when(() => mockRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        // act
        await repository.getRandomNumberTrivia();
        // assert
        verify(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
            .called(1);
      });
      // 테스트: remote data source를 호출성공했을때 로컬 데이터를 캐싱해야 함
      test('should call local data source to cache the data when remote data source call is successful', () async {
        // arrange
        when(() => mockRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        // act
        await repository.getRandomNumberTrivia();
        // assert
        verify(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
            .called(1);
      });

      // 테스트: remote data source 호출이 실패하면 예외를 던져야 함
      test('should throw an exception when the call to remote data source is unsuccessful', () async {
        // arrange
        when(() => mockRemoteDataSource.getRandomNumberTrivia())
            .thenThrow(Exception());
        // act
        final call = repository.getRandomNumberTrivia;
        // assert
        verifyNoMoreInteractions(mockRemoteDataSource);
        await expectLater(call(), throwsA(isA<Exception>()));
      });

      test('should return server failure when the call to remote data source is unsuccessful', () async {
        // arrange
        when(() => mockRemoteDataSource.getRandomNumberTrivia())
            .thenThrow(ServerException());

        // act
        final result = await repository.getRandomNumberTrivia();

        // assert
        expect(result, Left(ServerFailure()));
      });
    });

    runTestsOffline(() {
      // 오프라인 상태에서의 테스트 케이스를 여기에 추가

      test('should return last locally cached data when the cached data is present', () async {
        // arrange
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        // act
        final result = await repository.getRandomNumberTrivia();
        // assert
        verify(() => mockLocalDataSource.getLastNumberTrivia()).called(1);
        expect(result, Right(tNumberTriviaModel));
      });

      test(
        'should return cache failure when there is no cached data present',
        () async {
          // arrange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());
          // act
          final result = await repository.getRandomNumberTrivia();
          // assert
          verify(() => mockLocalDataSource.getLastNumberTrivia()).called(1);
          expect(result, Left(CacheFailure()));
        },
      );
    });
  });
}
