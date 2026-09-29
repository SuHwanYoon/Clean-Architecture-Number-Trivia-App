// 테스트할 실제 DataSource 구현체를 import합니다.
import 'dart:convert';

import 'package:clean_architecture_app/core/error/exceptions.dart';
import 'package:clean_architecture_app/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_app/features/number_trivia/data/models/number_trivia_model.dart';

// test(), group(), setUp() 등 Flutter 테스트 기능을 제공합니다.
import 'package:flutter_test/flutter_test.dart';

// Mock 객체를 만들고, 특정 메서드 호출을 가짜로 설정/검증하는 패키지입니다.
import 'package:mocktail/mocktail.dart';

// Dio, Response, Options 등의 타입을 사용하기 위해 import합니다.
import 'package:dio/dio.dart';

import '../../../fixtures/fixture_reader.dart';

// 실제 네트워크 요청을 보내지 않기 위한 가짜 Dio입니다.
// Mocktail이 Dio의 get() 호출을 기록하고, 원하는 응답을 반환하게 합니다.
class MockDio extends Mock implements Dio {}

void main() {
  // 테스트 대상입니다.
  // 실제 NumberTriviaRemoteDataSourceImpl을 생성해서 테스트합니다.
  late NumberTriviaRemoteDataSourceImpl numberTriviaRemoteDataSource;

  // 실제 Dio 대신 사용할 가짜 Dio입니다.
  late MockDio mockDio;
  // 테스트에 사용할 숫자입니다.
  const testNumber = 1;
  // getConcreteNumberTrivia 호출해야 하는 예상 URL입니다.
  final url = 'http://number-trivia.com/$testNumber';
  // getRandomNumberTrivia 호출해야 하는 예상 URL입니다.
  final randomUrl = 'http://number-trivia.com/random';
  // 각 test()가 실행되기 전에 항상 실행됩니다.
  // 따라서 테스트끼리 mock 호출 기록 등이 섞이지 않습니다.
  setUp(() {
    // 가짜 Dio 객체를 생성합니다.
    mockDio = MockDio();

    // 실제 DataSource를 생성합니다.
    // 이때 생성자 DI를 통해 실제 Dio()가 아닌 mockDio를 주입합니다.
    numberTriviaRemoteDataSource = NumberTriviaRemoteDataSourceImpl(
      client: mockDio,
    );
  });
  // Dio가 200 응답을 반환하도록 설정하는 헬퍼 메서드입니다.
  void setUpMockDioSuccess200(String requestUrl) {
    when(() => mockDio.get(requestUrl, options: any(named: 'options')))
        .thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: requestUrl),
            statusCode: 200,
            // fixture의 JSON 문자열을 Map으로 변환해서 전달합니다.
            // Dio는 실제로도 JSON을 Map으로 자동 파싱해서 data에 넣어줍니다.
            data: jsonDecode(fixture('trivia.json')),
          ),
        );
  }

  // Dio가 404 응답을 반환하도록 설정하는 헬퍼 메서드입니다.
  void setUpMockDioFailure404(String requestUrl) {
    when(() => mockDio.get(requestUrl, options: any(named: 'options')))
        .thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: requestUrl),
            statusCode: 404,
            data: 'Not Found',
          ),
        );
  }

  void runGetNumberTriviaTests({
    required String requestUrl,
    required Future<NumberTriviaModel> Function() call,
  }) {
    // 테스트에 사용할 모델이며  프로젝트에 정의해둔 fixture를 사용
    final testNumberTriviaModel = NumberTriviaModel.fromJson(
      jsonDecode(fixture('trivia.json')),
    );

    test('should perform a GET request with the correct endpoint and application/json header', () async {
      // --------------------
      // arrange: 테스트 준비
      // --------------------

      // "mockDio.get()이 아래 조건으로 호출되면" 가짜 응답을 반환하도록 설정합니다.
      setUpMockDioSuccess200(requestUrl);
      // --------------------
      // act: 테스트 대상 실행
      // --------------------

      // 실제 DataSource 메서드를 호출합니다.
      //
      // DataSource 내부에서는 client.get(...)을 호출하는데,
      // client에는 mockDio가 주입되어 있으므로 실제 네트워크 요청은 발생하지 않습니다.
      await call();

      // --------------------
      // assert: 결과 검증
      // --------------------

      // mockDio.get()이 아래 조건으로 호출되었는지 검증합니다.
      verify(
        () => mockDio.get(
          // URL이 http://numbersapi.com/1 인지 검증합니다.
          requestUrl,

          // Content-Type 헤더가 application/json인지 검증합니다.
          options: any(
            named: 'options',
            that: isA<Options>().having(
              (options) => options.headers?['Content-Type'],
              'Content-Type header',
              'application/json',
            ),
          ),
        ),
      )
      // 정확히 한 번 호출되어야 테스트가 통과합니다.
      .called(1);
    });

    test(
      'should return NumberTriviaModel when the response code is 200',
      () async {
        // arrange: 200 응답을 반환하도록 설정
        setUpMockDioSuccess200(requestUrl);

        // act: 테스트 대상 실행
        final result = await call();
        // assert: 결과 검증
        expect(result, testNumberTriviaModel);
      },
    );

    // response code가 404일 때 예외를 던지는지 테스트
    test(
      'should throw a ServerException when the response code is 404',
      () async {
        // arrange: 404 응답을 반환하도록 설정
        setUpMockDioFailure404(requestUrl);

        // assert
        expect(call, throwsA(isA<ServerException>()));
      },
    );
  }

  group('getConcreteNumberTrivia', () {
    runGetNumberTriviaTests(
      requestUrl: url,
      call: () =>
          numberTriviaRemoteDataSource.getConcreteNumberTrivia(testNumber),
    );
  });

  group('getRandomNumberTrivia', () {
    runGetNumberTriviaTests(
      requestUrl: randomUrl,
      call: () => numberTriviaRemoteDataSource.getRandomNumberTrivia(),
    );
  });
}
