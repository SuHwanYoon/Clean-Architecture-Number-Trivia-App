import 'dart:convert';

import 'package:clean_architecture_app/core/error/exceptions.dart';
import 'package:clean_architecture_app/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_architecture_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockSharedPreferences;
  late NumberTriviaLocalDataSourceImpl numberTriviaLocalDataSource;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    numberTriviaLocalDataSource = NumberTriviaLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('NumberTriviaLocalDataSource', () {
    // 테스트용 숫자 정보 모델을 정의합니다.
    // JSON 파일로부터 읽어온 데이터를 기반으로 NumberTriviaModel 인스턴스를 생성합니다.
    final testNumberTriviaModel = NumberTriviaModel.fromJson(
      json.decode(fixture('trivia_cached.json')),
    );

    test('should return NumberTrivia from SharedPreferences when there is one in the cache', () async {
      // Arrange
      // mockSharedPreferences의 getString 메서드가 호출될 때, fixture 데이터를 반환하도록 설정합니다.
      when(() => mockSharedPreferences.getString(any()))
          .thenReturn(fixture('trivia_cached.json'));

      // Act
      final result = await numberTriviaLocalDataSource.getLastNumberTrivia();

      // Assert
      // 결과가 예상한 NumberTriviaModel과 일치하는지 검증합니다.
      // mockSharedPreferences의 getString 메서드가 "CACHED_NUMBER_TRIVIA" 키로 호출되었는지 검증합니다.
      expect(result, equals(testNumberTriviaModel));
      verify(() => mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA))
          .called(1);
    });
    test(
      'should throw a CacheExeption when there is not a cached value',
      () async {
        // Arrange
        // mockSharedPreferences의 getString 메서드가 호출될 때, null을 반환하도록 설정합니다.
        when(() => mockSharedPreferences.getString(any())).thenReturn(null);
        // act
        // getLastNumberTrivia를 호출하여 예외가 발생하는지 확인합니다.
        final call = numberTriviaLocalDataSource.getLastNumberTrivia;
        // Assert
        // 예외가 발생하는지 검증합니다.
        // throwA는 특정 예외가 발생하는지 검증하는 데 사용됩니다.
        expect(() => call(), throwsA(isA<CacheException>()));
      },
    );
  });

  group('cacheNumberTrivia', () {
    // 테스트용 숫자 정보 모델을 정의합니다.
    final testNumberTriviaModel = NumberTriviaModel(
      number: 1,
      text: 'test trivia',
    );
    test('should call SharedPreferences to cache the data', () async {
      // Arrange
      // mockSharedPreferences의 setString 메서드가 호출될 때, true를 반환하도록 설정합니다.
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);
      // Act
      // cacheNumberTrivia를 호출하여 데이터를 캐시합니다.
      await numberTriviaLocalDataSource.cacheNumberTrivia(
        testNumberTriviaModel,
      );

      // Assert
      final expectedJsonString = json.encode(testNumberTriviaModel.toJson());
      // mockSharedPreferences의 setString 메서드가 호출되었는지 검증합니다.
      verify(
        () => mockSharedPreferences.setString(
          CACHED_NUMBER_TRIVIA,
          expectedJsonString,
        ),
      ).called(1);
    });
  });
}
