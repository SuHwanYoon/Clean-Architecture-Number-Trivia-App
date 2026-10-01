part of 'number_trivia_bloc.dart';

// NumberTriviaEvent는 숫자 퀴즈와 관련된 이벤트를 나타내는 추상 클래스입니다.
// 이 추상클래스의 역할은 숫자 퀴즈와 관련된 다양한 이벤트를 정의하고 관리하는 것입니다.
sealed class NumberTriviaEvent extends Equatable {
  const NumberTriviaEvent();

  @override
  List<Object> get props => [];
}

// 예를 들어, 사용자가 특정 숫자에 대한 퀴즈를 요청하거나 랜덤 숫자 퀴즈를 요청하는 이벤트를 정의할 수 있습니다.
class GetTriviaForConcreteNumber extends NumberTriviaEvent {
  final String numberString;

  const GetTriviaForConcreteNumber(this.numberString);

  @override
  List<Object> get props => [numberString];
}

class GetTriviaForRandomNumber extends NumberTriviaEvent {
  const GetTriviaForRandomNumber();
}
