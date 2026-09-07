import 'dart:convert';

import 'package:clean_architecture_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/fixture_reader.dart';

void main() {
  final testNumberTriviaModel = NumberTriviaModel(
    number: 1,
    text: 'Test trivia for number 1',
  );

  // test는 개별적인 테스트 케이스를 정의할 때 사용하는 함수입니다.
  test('should be a subclass of NumberTrivia entity', () async {
    // assert
    // testNumberTriviaModel이 NumberTrivia의 하위 클래스인지 확인합니다.
    expect(testNumberTriviaModel, isA<NumberTrivia>());
  });

  // group는 관련된 테스트들을 묶어서 관리할 수 있게 해주는 함수입니다.
  // fromJson 그룹은 JSON 데이터를 모델로 변환하는 기능을 테스트합니다.
  group('fromJson', () {
    test(
      'should return a valid model when the JSON number is an integer',
      () async {
        // arrange
        // decode는 JSON 문자열을 Dart의 Map<String, dynamic> 객체로 변환하는 함수입니다.
        final Map<String, dynamic> jsonMap = json.decode(
          fixture('trivia_double.json'),
        );
        // act
        final result = NumberTriviaModel.fromJson(jsonMap);
        // assert
        expect(result, equals(testNumberTriviaModel));
      },
    );
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () async {
      // act
      final result = testNumberTriviaModel.toJson();
      // assert
      final expectedMap = {'number': 1, 'text': 'Test trivia for number 1'};
      expect(result, equals(expectedMap));
    });
  });
}
