import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clean_architecture_app/core/usecases/usecase.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture_app/core/util/input_converter.dart';
import 'package:equatable/equatable.dart';
import 'package:clean_architecture_app/core/error/failures.dart';
import 'package:clean_architecture_app/core/util/result.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

// 도메인의 실패 객체를 화면에 전달할 메시지로 바꿀 때 사용합니다.
// 입력 오류와 조회 실패를 구분해 사용자에게 원인에 맞는 메시지를 전달합니다.
const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero.';

// 화면의 요청(Event)을 받아 입력 검증과 UseCase 호출을 연결하고,
// 처리 단계에 맞는 상태(State)를 내보냅니다. 실제 데이터 조회는 UseCase에 맡깁니다.
class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required this.getConcreteNumberTrivia,
    required this.getRandomNumberTrivia,
    required this.inputConverter,
  }) : super(Empty()) {
    // on<Event> 메서드는 특정 이벤트가 발생했을 때 실행할 핸들러를 등록합니다.
    // 핸들러로 등록하면 해당 이벤트가 발생할 때마다 지정한 콜백 함수가 호출됩니다.
    // 첫 요청 전에는 표시할 조회 결과가 없으므로 Empty 상태로 시작합니다.
    // add로 전달된 이벤트의 타입에 따라 실행할 핸들러를 등록합니다.
    // 특정 숫자 조회에는 입력 검증이 필요하지만, 랜덤 조회에는 필요하지 않습니다.
    on<GetTriviaForConcreteNumber>(_onGetTriviaForConcreteNumber);
    on<GetTriviaForRandomNumber>(_onGetTriviaForRandomNumber);
  }

  FutureOr<void> _onGetTriviaForConcreteNumber(
    GetTriviaForConcreteNumber event,
    Emitter<NumberTriviaState> emit,
  ) async {
    // 입력 검증 전에 Loading을 내보내므로, 잘못된 입력도 Loading -> Error 순서입니다.
    // 화면은 이 상태를 통해 요청 처리가 시작됐음을 알 수 있습니다.
    emit(Loading());

    // 이벤트의 문자열을 0 이상의 정수로 변환합니다.
    // 변환 실패는 예외를 던지는 대신 FailureResult로 전달됩니다.
    final conversionResult = inputConverter.stringToUnsignedInteger(
      event.numberString,
    );

    if (conversionResult is FailureResult<int, Failure>) {
      // 유효하지 않은 입력은 조회할 수 없으므로 오류 상태를 내보내고 종료합니다.
      // return이 없으면 아래의 성공 값 추출과 UseCase 호출까지 진행하게 됩니다.
      emit(Error(INVALID_INPUT_FAILURE_MESSAGE));
      return;
    }

    // Result의 두 종류 중 실패는 위에서 종료했으므로 여기서는 Success입니다.
    // 변환된 정수를 꺼내 UseCase가 요구하는 매개변수 객체 Params에 담습니다.
    // await로 비동기 조회가 끝날 때까지 기다린 뒤, 성공 또는 실패 상태를 내보냅니다.
    final number = (conversionResult as Success<int, Failure>).value;
    final result = await getConcreteNumberTrivia(Params(number: number));
    _emitTriviaResult(result, emit);
  }

  FutureOr<void> _onGetTriviaForRandomNumber(
    GetTriviaForRandomNumber event,
    Emitter<NumberTriviaState> emit,
  ) async {
    // 랜덤 조회에는 숫자 입력이 없으므로 변환기를 거치지 않습니다.
    // NoParams는 공통 UseCase 인터페이스에 맞춰 '입력값 없음'을 표현합니다.
    // Loading을 먼저 내보내고 비동기 조회 결과를 기다립니다.
    emit(Loading());
    final result = await getRandomNumberTrivia(NoParams());
    _emitTriviaResult(result, emit);
  }

  // 특정 숫자 조회와 랜덤 조회의 결과 타입이 같으므로 상태 변환 로직을 공유합니다.
  // Result<NumberTrivia, Failure>의 첫 타입은 성공 값, 두 번째 타입은 실패 값입니다.
  // 여기서는 반환된 실패 값을 처리하며, 조회 중 던져진 예외를 잡는 것은 아닙니다.
  void _emitTriviaResult(
    Result<NumberTrivia, Failure> result,
    Emitter<NumberTriviaState> emit,
  ) {
    // 패턴 매칭으로 결과의 종류를 구분하면서 내부 값을 꺼냅니다.
    // 성공 값은 Loaded에 담고, 실패 값은 메시지로 바꿔 Error에 담습니다.
    switch (result) {
      case Success<NumberTrivia, Failure>(:final value):
        emit(Loaded(value));
      case FailureResult<NumberTrivia, Failure>(:final failure):
        emit(Error(_mapFailureToMessage(failure)));
    }
  }

  // 서버 조회 실패와 로컬 캐시 실패는 원인이 다르므로 메시지도 구분합니다.
  // 명시적으로 처리하지 않은 실패 타입에는 기본 메시지를 사용합니다.
  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      ServerFailure() => SERVER_FAILURE_MESSAGE,
      CacheFailure() => CACHE_FAILURE_MESSAGE,
      _ => 'Unexpected Error',
    };
  }
}
