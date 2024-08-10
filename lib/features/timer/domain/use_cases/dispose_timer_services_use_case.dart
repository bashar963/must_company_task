import 'package:must_company_task/core/utils/use_case/use_case.dart';
import 'package:must_company_task/features/timer/domain/repositories/timer_repository.dart';

class DisposeTimerServicesUseCase implements UseCase<void, void> {
  final TimerRepository _repository;

  DisposeTimerServicesUseCase(this._repository);

  @override
  Future<Response<void>> call(void input) async {
    _repository.disposeServices();

    return SuccessResponse(data: null);
  }
}
