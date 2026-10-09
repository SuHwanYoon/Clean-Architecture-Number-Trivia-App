import 'package:clean_architecture_app/core/error/failures.dart';
import 'package:clean_architecture_app/core/util/result.dart';
import 'package:equatable/equatable.dart';

// UseCase는 도메인 계층에서 비즈니스 로직을 수행하는 유스케이스를 나타내는 추상 클래스입니다.
// 이 클래스는 제네릭 타입(T, Params)을 사용하여
//다양한 유스케이스에 대해 재사용될 수 있도록 설계되었습니다.
// T는 유스케이스가 반환하는 성공 값의 타입을 나타내며,
//Params는 유스케이스가 필요로 하는 매개변수의 타입을 나타냅니다.
//예를 들어, GetConcreteNumberTrivia 유스케이스의 경우 T는 NumberTrivia이고,
// Params는 int 타입의 number가 됩니다.
// call 메서드는 유스케이스를 실행하는 역할을 하며,
//매개변수로 Params 타입의 params를 받습니다.
// 이 메서드는 비동기적으로 동작하며,
// 결과를 Future<Result<T, Failure>>로 반환합니다.
// Success는 성공 값(T), FailureResult는 실패(Failure)를 담습니다.
abstract class UseCase<T, Params> {
  Future<Result<T, Failure>> call(Params params);
}

// NoParams는 매개변수가 필요 없는 유스케이스에서 사용되는 클래스입니다.
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
