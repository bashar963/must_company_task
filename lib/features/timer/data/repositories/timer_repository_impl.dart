import 'dart:typed_data';

import 'package:must_company_task/features/timer/data/data_sources/timer_data_source.dart';
import 'package:must_company_task/features/timer/domain/repositories/timer_repository.dart';

class TimerRepositoryImpl implements TimerRepository {
  final TimerDataSource _dataSource;

  TimerRepositoryImpl(this._dataSource);

  @override
  Future<void> initServices() => _dataSource.initServices();

  @override
  Future<void> disposeServices() => _dataSource.disposeServices();

  @override
  Future<Uint8List?> takeHeadshot() => _dataSource.takeHeadshot();

  @override
  Future<Uint8List?> takeScreenshot() => _dataSource.takeScreenshot();
}
