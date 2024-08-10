import 'dart:typed_data';

import 'package:must_company_task/core/utils/use_case/use_case.dart';
import 'package:must_company_task/features/timer/domain/repositories/timer_repository.dart';

class TakeHeadshotUseCase implements UseCase<void, Uint8List?> {
  final TimerRepository _repository;

  TakeHeadshotUseCase(this._repository);

  @override
  Future<Response<Uint8List?>> call(void input) async {
    try {
      final result = await _repository.takeHeadshot();
      return SuccessResponse(data: result);
    } catch (e) {
      return ErrorResponse(message: e.toString());
    }
  }
}
