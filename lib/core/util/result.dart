import 'package:equatable/equatable.dart';

/// S는 성공 값의 타입, E는 실패 값의 타입입니다.
sealed class Result<S, E> extends Equatable {
  const Result();

  @override
  List<Object?> get props => [];
}

final class Success<S, E> extends Result<S, E> {
  final S value;
  const Success(this.value);

  @override
  List<Object?> get props => [value];
}

final class FailureResult<S, E> extends Result<S, E> {
  final E failure;
  const FailureResult(this.failure);

  @override
  List<Object?> get props => [failure];
}
