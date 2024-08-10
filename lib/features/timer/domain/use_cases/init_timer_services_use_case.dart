import 'package:must_company_task/core/utils/use_case/use_case.dart';
import 'package:must_company_task/features/timer/domain/repositories/timer_repository.dart';

class InitTimerServicesUseCase implements UseCase<void, void> {
  final TimerRepository _repository;

  InitTimerServicesUseCase(this._repository);

  @override
  Future<Response<void>> call(void input) async {
    try {
      await _repository.initServices();
      return SuccessResponse(data: null);
    } catch (e) {
      return ErrorResponse(message: e.toString());
    }
  }
}
