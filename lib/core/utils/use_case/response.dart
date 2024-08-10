part of 'use_case.dart';

sealed class Response<T> {
  final T? data;
  final String? message;
  final bool isSuccess;
  Response({
    this.data,
    this.message,
    required this.isSuccess,
  });
}

class SuccessResponse<T> extends Response<T> {
  SuccessResponse({
    super.data,
    super.message,
  }) : super(isSuccess: true);
}

class ErrorResponse<T> extends Response<T> {
  ErrorResponse({
    super.data,
    super.message,
  }) : super(isSuccess: false);
}
