import 'package:equatable/equatable.dart';

// NumberTrivia는 도메인 계층의 엔티티로, 숫자와 관련된 정보를 나타내는 클래스입니다.
// Equatable을 상속받아 객체 비교를 쉽게 할 수 있도록 구현되어 있습니다.
class NumberTrivia extends Equatable {
  final String text;
  final int number;
  // 생성자를 통해 text와 number를 초기화합니다.
  // required 키워드를 사용하여 필수 매개변수임을 명시합니다.
  const NumberTrivia({required this.text, required this.number});
  // Equatable을 상속받았기 때문에, props를 오버라이드하여 비교할 속성을 정의합니다.
  // props는 객체 비교 시 사용되는 속성들을 리스트로 반환합니다.
  @override
  List<Object?> get props => [text, number];
}
