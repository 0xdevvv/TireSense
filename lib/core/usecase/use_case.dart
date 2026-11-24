abstract interface class AsyncUseCase<Output> {
  Future<Output> execute();
}

abstract interface class AsyncUseCaseWithParam<Param, Output> {
  Future<Output> execute(Param param);
}

abstract interface class StreamUseCase<Output> {
  Stream<Output> execute();
}

abstract interface class UseCase<Output> {
  Output execute();
}

abstract interface class UseCaseWithParam<Param, Output> {
  Output execute(Param param);
}
