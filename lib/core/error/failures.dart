import 'package:equatable/equatable.dart';

// Failure는 도메인 계층에서 발생할 수 있는 실패를 나타내는 추상 클래스입니다.
abstract class Failure extends Equatable {
  // 생성자를 통해 properties를 초기화합니다. properties는 실패와 관련된 속성들을 나타내며, 기본값으로 빈 리스트를 사용합니다.
  // const 키워드를 사용하여 상수 생성자를 정의합니다. 이는 Failure 객체가 불변임을 나타냅니다.
  // properties는 Equatable을 상속받은 클래스에서 객체 비교 시 사용되는 속성들을 나타냅니다.
  // dynamic 타입의 리스트를 사용하여 다양한 속성을 포함할 수 있도록 합니다.
  const Failure([List properties = const <dynamic>[]]);

  // Equatable을 상속받았기 때문에, props를 오버라이드하여 비교할 속성을 정의합니다.
  @override
  List<Object?> get props => [];
}
