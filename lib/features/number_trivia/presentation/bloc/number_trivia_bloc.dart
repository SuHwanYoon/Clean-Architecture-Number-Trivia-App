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

//전역적으로 사용할 Failure 메시지 상수 정의
const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required this.getConcreteNumberTrivia,
    required this.getRandomNumberTrivia,
    required this.inputConverter,
  }) : super(Empty()) {
    // 이벤트별 독립 핸들러 등록
    on<GetTriviaForConcreteNumber>(_onGetTriviaForConcreteNumber);
    on<GetTriviaForRandomNumber>(_onGetTriviaForRandomNumber);
  }

  FutureOr<void> _onGetTriviaForConcreteNumber(
    GetTriviaForConcreteNumber event,
    Emitter<NumberTriviaState> emit,
  ) async {
    emit(Loading());

    final conversionResult = inputConverter.stringToUnsignedInteger(
      event.numberString,
    );

    if (conversionResult is FailureResult<int, Failure>) {
      emit(Error(INVALID_INPUT_FAILURE_MESSAGE));
      return;
    }

    final number = (conversionResult as Success<int, Failure>).value;
    final result = await getConcreteNumberTrivia(Params(number: number));
    _emitTriviaResult(result, emit);
  }

  FutureOr<void> _onGetTriviaForRandomNumber(
    GetTriviaForRandomNumber event,
    Emitter<NumberTriviaState> emit,
  ) async {
    emit(Loading());
    final result = await getRandomNumberTrivia(NoParams());
    _emitTriviaResult(result, emit);
  }

  void _emitTriviaResult(
    Result<NumberTrivia, Failure> result,
    Emitter<NumberTriviaState> emit,
  ) {
    switch (result) {
      case Success<NumberTrivia, Failure>(:final value):
        emit(Loaded(value));
      case FailureResult<NumberTrivia, Failure>(:final failure):
        emit(Error(_mapFailureToMessage(failure)));
    }
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      ServerFailure() => SERVER_FAILURE_MESSAGE,
      CacheFailure() => CACHE_FAILURE_MESSAGE,
      _ => 'Unexpected Error',
    };
  }
}
