import 'package:must_company_task/features/timer/data/data_sources/timer_data_source.dart';
import 'package:must_company_task/features/timer/data/repositories/timer_repository_impl.dart';
import 'package:must_company_task/features/timer/domain/repositories/timer_repository.dart';
import 'package:must_company_task/features/timer/domain/use_cases/dispose_timer_services_use_case.dart';
import 'package:must_company_task/features/timer/domain/use_cases/init_timer_services_use_case.dart';
import 'package:must_company_task/features/timer/domain/use_cases/take_headshot_use_case.dart';
import 'package:must_company_task/features/timer/domain/use_cases/take_screenshot_use_case.dart';
import 'package:must_company_task/features/timer/presentation/manager/timer_view_model.dart';

TimerViewModel initViewModel() {
  final TimerDataSource timerDataSource = TimerDataSourceImpl();

  final TimerRepository timerRepository = TimerRepositoryImpl(timerDataSource);

  final InitTimerServicesUseCase initTimerServicesUseCase =
      InitTimerServicesUseCase(timerRepository);

  final TakeHeadshotUseCase takeHeadshotUseCase =
      TakeHeadshotUseCase(timerRepository);

  final TakeScreenshotUseCase takeScreenshotUseCase =
      TakeScreenshotUseCase(timerRepository);

  final DisposeTimerServicesUseCase disposeTimerServicesUseCase =
      DisposeTimerServicesUseCase(timerRepository);
  return TimerViewModel(
    initTimerServicesUseCase: initTimerServicesUseCase,
    disposeTimerServicesUseCase: disposeTimerServicesUseCase,
    takeHeadshotUseCase: takeHeadshotUseCase,
    takeScreenshotUseCase: takeScreenshotUseCase,
  );
}
