part of 'number_trivia_bloc.dart';

sealed class NumberTriviaState extends Equatable {
  const NumberTriviaState();

  @override
  List<Object> get props => [];
}

// 상태가 비어 있을 때를 나타내는 상태 클래스입니다.
final class Empty extends NumberTriviaState {}

// 상태가 로딩 중일 때를 나타내는 상태 클래스입니다.
final class Loading extends NumberTriviaState {}

// 상태가 로딩이 완료되어 데이터를 가지고 있을 때를 나타내는 상태 클래스입니다.
final class Loaded extends NumberTriviaState {
  final NumberTrivia numberTrivia;

  const Loaded(this.numberTrivia);

  @override
  List<Object> get props => [numberTrivia];
}

// 상태가 에러가 발생했을 때를 나타내는 상태 클래스입니다.
final class Error extends NumberTriviaState {
  final String message;

  const Error(this.message);

  @override
  List<Object> get props => [message];
}
