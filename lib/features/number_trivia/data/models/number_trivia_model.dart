import 'package:clean_architecture_app/features/number_trivia/domain/entities/number_trivia.dart';

class NumberTriviaModel extends NumberTrivia {
  @override
  final number;

  @override
  final text;

  const NumberTriviaModel({required this.number, required this.text})
    : super(number: number, text: text);
}
