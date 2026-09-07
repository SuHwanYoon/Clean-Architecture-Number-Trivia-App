import 'package:clean_architecture_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testNumberTriviaModel = NumberTriviaModel(
    number: 1,
    text: 'Test trivia for number 1',
  );

  test('should be a subclass of NumberTrivia entity', () async {
    // assert
    // testNumberTriviaModel이 NumberTrivia의 하위 클래스인지 확인합니다.
    expect(testNumberTriviaModel, isA<NumberTrivia>());
  });
}
