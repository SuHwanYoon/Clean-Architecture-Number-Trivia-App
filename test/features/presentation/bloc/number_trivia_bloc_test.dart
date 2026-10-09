import 'package:clean_architecture_app/core/error/failures.dart';
import 'package:clean_architecture_app/core/usecases/usecase.dart';
import 'package:clean_architecture_app/core/util/result.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_app/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clean_architecture_app/core/util/input_converter.dart';

class MockInputConverter extends Mock implements InputConverter {}

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

void main() {
  late NumberTriviaBloc numberTriviaBloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUpAll(() {
    registerFallbackValue(const Params(number: 0));
    registerFallbackValue(NoParams());
  });

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    numberTriviaBloc = NumberTriviaBloc(
      getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
      getRandomNumberTrivia: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  tearDown(() async {
    await numberTriviaBloc.close();
  });

  // 이 테스트는 NumberTriviaBloc의 초기 상태가 Empty인지 확인합니다.
  test('initial state should be Empty', () {
    expect(numberTriviaBloc.state, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    // 여기에 GetTriviaForConcreteNumber 이벤트에 대한 테스트를 작성합니다.
    final testNumberString = '1';
    final testNumberParsed = 1;
    final testNumberTrivia = NumberTrivia(number: 1, text: 'Test trivia');

    test('should call the InputConverter to validate and convert the string to an integer', () async {
      // arrange
      when(() => mockInputConverter.stringToUnsignedInteger(any()))
          .thenReturn(Success(testNumberParsed));
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((_) async => Success(testNumberTrivia));

      final stateExpectation = expectLater(
        numberTriviaBloc.stream,
        emitsInOrder([Loading(), Loaded(testNumberTrivia)]),
      );

      // act
      numberTriviaBloc.add(GetTriviaForConcreteNumber(testNumberString));

      // assert
      await untilCalled(
        () => mockInputConverter.stringToUnsignedInteger(any()),
      );
      verify(
        () => mockInputConverter.stringToUnsignedInteger(testNumberString),
      );
      await stateExpectation;
    });

    // invalid input test can be added here.
    // should emit [Error] when the input is invalid.
    test('should emit [Error] when the input is invalid', () async {
      // arrange
      // 이 when은 inputConverter가 문자열을 정수로 변환할 때 실패하도록 설정합니다.
      when(() => mockInputConverter.stringToUnsignedInteger(any()))
          .thenReturn(FailureResult(InvalidInputFailure()));

      final stateExpectation = expectLater(
        numberTriviaBloc.stream,
        emitsInOrder([Loading(), Error(INVALID_INPUT_FAILURE_MESSAGE)]),
      );

      // act
      // numberTriviaBloc에 'invalid'라는 문자열을 가진
      //GetTriviaForConcreteNumber 이벤트를 추가합니다.
      numberTriviaBloc.add(GetTriviaForConcreteNumber('invalid'));

      // assert
      await untilCalled(
        () => mockInputConverter.stringToUnsignedInteger(any()),
      );
      await stateExpectation;
      verifyZeroInteractions(mockGetConcreteNumberTrivia);
    });

    // 이 테스트는 구체적인 숫자에 대한 트리비아를 가져오는 use case가 호출되는지 확인합니다.
    test('should get data from the concrete use case', () async {
      // arrange
      // 먼저 inputConverter가 문자열을 정수로 변환하도록 설정합니다.
      when(() => mockInputConverter.stringToUnsignedInteger(any()))
          .thenReturn(Success(testNumberParsed));
      // 그리고 구체적인 숫자에 대한 트리비아를 가져오는 use case가 성공하도록 설정합니다.
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((_) async => Success(testNumberTrivia));
      // 상태 변화에 대한 기대를 설정합니다.
      final stateExpectation = expectLater(
        numberTriviaBloc.stream,
        emitsInOrder([Loading(), Loaded(testNumberTrivia)]),
      );

      // act
      // numberTriviaBloc에 testNumberString을 가진
      // GetTriviaForConcreteNumber 이벤트를 추가합니다.
      numberTriviaBloc.add(GetTriviaForConcreteNumber(testNumberString));

      // assert
      await untilCalled(
        () => mockInputConverter.stringToUnsignedInteger(any()),
      );
      verify(
        () => mockInputConverter.stringToUnsignedInteger(testNumberString),
      );
      await stateExpectation;
      verify(
        () => mockGetConcreteNumberTrivia(Params(number: testNumberParsed)),
      ).called(1);
    });
  });
}
