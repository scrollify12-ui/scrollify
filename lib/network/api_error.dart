import 'package:dio/dio.dart';

class ApiError implements Exception {
  final String message;
  final int? statusCode;

  ApiError({required this.message, this.statusCode});

  factory ApiError.fromDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiError(message: 'Connection timed out. Please check your internet.');
      case DioExceptionType.badResponse:
        return ApiError(
            message: 'Server error: ${exception.response?.statusCode}',
            statusCode: exception.response?.statusCode);
      case DioExceptionType.connectionError:
        return ApiError(message: 'No internet connection.');
      default:
        return ApiError(message: 'Something went wrong. Please try again.');
    }
  }

  @override
  String toString() => message;
}
