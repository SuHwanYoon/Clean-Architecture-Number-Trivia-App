import 'package:clean_architecture_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

import 'get_concrete_number_trivia_test_test.mocks.dart';

@GenerateMocks([NumberTriviaRepository])
void main() {
  // late 키워드는 변수가 나중에 초기화될 것임을 나타냅니다. 이는 테스트 환경에서 종속성을 주입하거나 설정할 때 유용합니다.
  late GetConcreteNumberTrivia usecase;
  late MockNumberTriviaRepository mockNumberTriviaRepository;

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetConcreteNumberTrivia(mockNumberTriviaRepository);
  });

  final testNumber = 1;
  final testNumberTrivia = NumberTrivia(
    number: testNumber,
    text: 'Test trivia for number $testNumber',
  );

  test('should get trivia for the number from the repository', () async {
    // Arrange
    when(mockNumberTriviaRepository.getConcreteNumberTrivia(any))
        .thenAnswer((_) async => Right(testNumberTrivia));

    // Act
    final result = await usecase.excute(number: testNumber);
    // Assert
    expect(result, Right(testNumberTrivia));
    verify(mockNumberTriviaRepository.getConcreteNumberTrivia(testNumber));
    verifyNoMoreInteractions(mockNumberTriviaRepository);
  });
}
