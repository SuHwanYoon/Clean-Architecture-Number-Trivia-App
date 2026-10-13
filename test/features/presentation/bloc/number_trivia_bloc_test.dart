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

    // 유효한 숫자 입력이 변환된 뒤, 변환 결과를 concrete use case에 전달하는지 확인합니다.
    test('should get data from the concrete use case', () async {
      // arrange
      // 실제 변환기를 사용하지 않고, 입력 문자열이 testNumberParsed로
      // 성공적으로 변환된 상황을 만들어 테스트 대상을 Bloc의 흐름으로 한정합니다.
      when(() => mockInputConverter.stringToUnsignedInteger(any()))
          .thenReturn(Success(testNumberParsed));
      // 변환된 숫자로 concrete use case를 호출하면 테스트용 트리비아를 반환하도록 설정합니다.
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((_) async => Success(testNumberTrivia));
      // 이벤트를 보내기 전에 stream 구독을 시작해야 Loading과 Loaded 상태를
      // 빠짐없이 관찰할 수 있습니다. 두 상태가 이 순서로 발생하는지도 함께 검증합니다.
      final stateExpectation = expectLater(
        numberTriviaBloc.stream,
        emitsInOrder([Loading(), Loaded(testNumberTrivia)]),
      );

      // act
      // Bloc에 문자열 입력 이벤트를 전달합니다. Bloc은 이 값을 변환한 다음
      // 변환된 정수로 use case를 호출해야 합니다.
      numberTriviaBloc.add(GetTriviaForConcreteNumber(testNumberString));

      // assert
      // 이벤트 처리는 비동기이므로 변환기 호출이 실제로 일어날 때까지 기다린 뒤,
      // 원래 입력 문자열이 변환기에 전달됐는지 확인합니다.
      await untilCalled(
        () => mockInputConverter.stringToUnsignedInteger(any()),
      );
      verify(
        () => mockInputConverter.stringToUnsignedInteger(testNumberString),
      );
      // 상태 스트림에서 Loading 다음 Loaded가 방출될 때까지 기다립니다.
      await stateExpectation;
      // 변환된 값이 Params에 담겨 concrete use case로 전달되고,
      // 해당 호출이 정확히 한 번 발생했는지 검증합니다.
      verify(
        () => mockGetConcreteNumberTrivia(Params(number: testNumberParsed)),
      ).called(1);
    });

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () async {
        // arrange
        // 각 테스트의 Mock은 새로 생성되므로 입력 변환 성공도 여기서 설정해야 합니다.
        when(() => mockInputConverter.stringToUnsignedInteger(any()))
            .thenReturn(Success(testNumberParsed));
        // UseCase의 실제 조회 대신 테스트용 트리비아를 비동기 성공 결과로 반환합니다.
        // 이렇게 하면 외부 데이터에 의존하지 않고 Bloc의 상태 변경을 검사할 수 있습니다.
        when(() => mockGetConcreteNumberTrivia(any()))
            .thenAnswer((_) async => Success(testNumberTrivia));
        // 이벤트를 보내기 전에 스트림 구독을 시작해 빠르게 방출되는 상태도 관찰합니다.
        // Loading 다음 Loaded가 나오고, Loaded에 테스트용 트리비아가 담기는지 검증합니다.
        // expectLater가 반환하는 Future는 아래에서 검증 완료를 기다릴 때 사용합니다.
        final stateExpectation = expectLater(
          numberTriviaBloc.stream,
          emitsInOrder([Loading(), Loaded(testNumberTrivia)]),
        );

        // act
        // 문자열 입력 이벤트를 보내면 Bloc이 입력 변환 후 UseCase를 호출합니다.
        // add는 이벤트 처리가 끝날 때까지 기다리지 않으므로 아래에서 별도로 기다립니다.
        numberTriviaBloc.add(GetTriviaForConcreteNumber(testNumberString));

        // assert
        // 기대한 상태들이 방출될 때까지 기다려 비동기 처리 중에 테스트가 끝나지 않게 합니다.
        await stateExpectation;
        // 성공 상태뿐 아니라 변환된 숫자가 Params에 담겨 전달됐는지도 확인합니다.
        // called(1)은 해당 인자로 조회한 횟수가 정확히 한 번인지 검증합니다.
        verify(
          () => mockGetConcreteNumberTrivia(Params(number: testNumberParsed)),
        ).called(1);
      },
    );

    test('should emit [Loading, Error] with a proper message for the error when getting data fails', () async {
      // arrange
      when(() => mockInputConverter.stringToUnsignedInteger(any()))
          .thenReturn(Success(testNumberParsed));
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((_) async => FailureResult(ServerFailure()));
      final stateExpectation = expectLater(
        numberTriviaBloc.stream,
        emitsInOrder([Loading(), Error(SERVER_FAILURE_MESSAGE)]),
      );

      // act
      numberTriviaBloc.add(GetTriviaForConcreteNumber(testNumberString));

      // assert
      await stateExpectation;
    });
  });

  group('GetTriviaForRandomNumber', () {
    final testNumberTrivia = NumberTrivia(number: 1, text: 'Test trivia');

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () async {
        when(() => mockGetRandomNumberTrivia(any()))
            .thenAnswer((_) async => Success(testNumberTrivia));
        final stateExpectation = expectLater(
          numberTriviaBloc.stream,
          emitsInOrder([Loading(), Loaded(testNumberTrivia)]),
        );

        numberTriviaBloc.add(const GetTriviaForRandomNumber());

        await stateExpectation;
        verify(() => mockGetRandomNumberTrivia(NoParams())).called(1);
      },
    );

    test('should emit [Loading, Error] when data retrieval fails', () async {
      when(() => mockGetRandomNumberTrivia(any()))
          .thenAnswer((_) async => FailureResult(ServerFailure()));
      final stateExpectation = expectLater(
        numberTriviaBloc.stream,
        emitsInOrder([Loading(), Error(SERVER_FAILURE_MESSAGE)]),
      );

      numberTriviaBloc.add(const GetTriviaForRandomNumber());

      await stateExpectation;
      verify(() => mockGetRandomNumberTrivia(NoParams())).called(1);
    });
  });
}
