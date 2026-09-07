import 'package:clean_architecture_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

import 'get_concrete_number_trivia_test.mocks.dart';

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
    // when 메서드는 mockito 패키지에서 제공하는 기능으로, 특정 메서드 호출에 대한 동작을 정의할 수 있습니다.
    // 여기서는 mockNumberTriviaRepository의 getConcreteNumberTrivia 메서드가 호출될 때, Right(testNumberTrivia)를 반환하도록 설정합니다.
    // Right는 dartz 패키지에서 제공하는 타입으로, 성공적인 결과를 나타냅니다. 여기서는 testNumberTrivia 객체를 성공적인 결과로 반환하도록 설정합니다.
    // any는 mockito 패키지에서 제공하는 기능으로, 어떤 값이든 상관없이 해당 메서드가 호출될 때 동작을 정의할 수 있습니다.
    // 따라서, getConcreteNumberTrivia 메서드가 어떤 숫자에 대해 호출되더라도 Right(testNumberTrivia)를 반환하도록 설정됩니다.
    when(mockNumberTriviaRepository.getConcreteNumberTrivia(any))
        .thenAnswer((_) async => Right(testNumberTrivia));

    // Act
    // excute 메서드를 호출하여 실제 테스트를 수행합니다. 여기서는 testNumber를 매개변수로 전달합니다.
    final result = await usecase.call(Params(number: testNumber));
    // Assert
    // expect 메서드는 테스트 결과를 검증하는 역할을 합니다. 여기서는 result가 Right(testNumberTrivia)와 동일한지 확인합니다.
    expect(result, Right(testNumberTrivia));
    // verify 메서드는 mockito 패키지에서 제공하는 기능으로, 특정 메서드가 호출되었는지 검증할 수 있습니다.
    // 여기서는 mockNumberTriviaRepository의 getConcreteNumberTrivia 메서드가 testNumber
    verify(mockNumberTriviaRepository.getConcreteNumberTrivia(testNumber));
    // verifyNoMoreInteractions 메서드는 mock 객체에 대해 더 이상 상호작용이 없음을 검증합니다.
    // 즉, getConcreteNumberTrivia 메서드 외에는 다른 메서드가 호출되지 않았음을 확인합니다.
    verifyNoMoreInteractions(mockNumberTriviaRepository);
  });
}
