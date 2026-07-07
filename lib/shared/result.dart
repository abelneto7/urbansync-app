abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ApiFailure extends Failure {
  const ApiFailure(super.message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}

sealed class Result<S> {
  const Result();

  bool get isSuccess => this is Success<S>;

  bool get isFailure => this is ResultFailure<S>;

  S get value {
    if (this is Success<S>) return (this as Success<S>).data;
    throw StateError('Result is a Failure — check isSuccess before calling value.');
  }

  Failure get failure {
    if (this is ResultFailure<S>) return (this as ResultFailure<S>).error;
    throw StateError('Result is a Success — check isFailure before calling failure.');
  }

  T when<T>({
    required T Function(S data) success,
    required T Function(Failure error) failure,
  }) {
    return switch (this) {
      Success<S> s => success(s.data),
      ResultFailure<S> f => failure(f.error),
    };
  }

  Result<T> map<T>(T Function(S data) transform) {
    return switch (this) {
      Success<S> s => Success(transform(s.data)),
      ResultFailure<S> f => ResultFailure(f.error),
    };
  }

  factory Result.success(S data) => Success(data);

  factory Result.failure(Failure error) => ResultFailure(error);
}

final class Success<S> extends Result<S> {
  final S data;
  const Success(this.data);
}

final class ResultFailure<S> extends Result<S> {
  final Failure error;
  const ResultFailure(this.error);
}
