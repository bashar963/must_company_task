part 'response.dart';

abstract interface class UseCase<TInput, TOutput> {
  Future<Response<TOutput>> call(TInput input);
}
