import 'package:clean_architecture_app/features/number_trivia/domain/entities/number_trivia.dart';

class NumberTriviaModel extends NumberTrivia {
  @override
  final number;

  @override
  final text;

  const NumberTriviaModel({required this.number, required this.text})
    : super(number: number, text: text);
  // factory 생성자는 JSON 데이터를 받아 모델 객체를 생성하는 역할을 합니다.4
  // API로부터 받은 JSON 데이터를 처리하는 과정입니다. JSON의 'number'와 'text' 필드를 추출하여 모델 객체를 생성합니다.
  factory NumberTriviaModel.fromJson(Map<String, dynamic> json) {
    return NumberTriviaModel(
      // number 필드는 JSON에서 'number' 키로 가져오며, 정수로 변환합니다.
      // number 키로 가져온다는 것은 JSON 객체에 'number'라는 키가 존재한다는 의미입니다.
      number: (json['number'] as num).toInt(),
      text: json['text'],
    );
  }

  // toJson 메서드는 모델 객체를 JSON 형태로 변환하는 역할을 합니다.
  // API로 데이터를 전송하거나 저장할 때 사용됩니다.
  Map<String, dynamic> toJson() {
    return {'number': number, 'text': text};
  }
}
