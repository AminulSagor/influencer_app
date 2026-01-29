import 'package:dio/dio.dart';
import 'package:get/get.dart';

/// Centralized API error handler for consistent error management across the app.
///
/// Usage:
/// ```dart
/// final result = await ApiErrorHandler.call(() => myService.fetchData());
/// if (result.isSuccess) {
///   // use result.data
/// } else {
///   // error already shown via snackbar, or handle result.error
/// }
/// ```
class ApiErrorHandler {
  ApiErrorHandler._();

  /// Wraps an async API call with standardized error handling.
  ///
  /// - [apiCall]: The async function to execute
  /// - [showError]: Whether to show error snackbar (default: true)
  /// - [errorTitle]: Custom error title (default: 'Error')
  ///
  /// Returns [ApiResult] with success/failure state and data/error message.
  static Future<ApiResult<T>> call<T>(
    Future<T> Function() apiCall, {
    bool showError = true,
    String errorTitle = 'Error',
  }) async {
    try {
      final data = await apiCall();
      return ApiResult.success(data);
    } on DioException catch (e) {
      final message = _parseDioError(e);
      if (showError) {
        _showErrorSnackbar(errorTitle, message);
      }
      return ApiResult.failure(message);
    } catch (e) {
      final message = e.toString();
      if (showError) {
        _showErrorSnackbar(errorTitle, message);
      }
      return ApiResult.failure(message);
    }
  }

  /// Parses DioException to extract a user-friendly error message.
  static String _parseDioError(DioException e) {
    // Try to extract message from response body
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        // Check common error message fields
        return data['message']?.toString() ??
            data['error']?.toString() ??
            data['msg']?.toString() ??
            _getDefaultErrorMessage(e);
      }
      if (data is String && data.isNotEmpty) {
        return data;
      }
    }
    return _getDefaultErrorMessage(e);
  }

  /// Returns a default error message based on DioException type.
  static String _getDefaultErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'connection_timeout'.tr;
      case DioExceptionType.sendTimeout:
        return 'send_timeout'.tr;
      case DioExceptionType.receiveTimeout:
        return 'receive_timeout'.tr;
      case DioExceptionType.badCertificate:
        return 'bad_certificate'.tr;
      case DioExceptionType.badResponse:
        return _getHttpErrorMessage(e.response?.statusCode);
      case DioExceptionType.cancel:
        return 'request_cancelled'.tr;
      case DioExceptionType.connectionError:
        return 'connection_error'.tr;
      case DioExceptionType.unknown:
        return e.message ?? 'unknown_error'.tr;
    }
  }

  /// Returns a user-friendly message for HTTP status codes.
  static String _getHttpErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'bad_request'.tr;
      case 401:
        return 'unauthorized'.tr;
      case 403:
        return 'forbidden'.tr;
      case 404:
        return 'not_found'.tr;
      case 409:
        return 'conflict'.tr;
      case 422:
        return 'validation_error'.tr;
      case 429:
        return 'too_many_requests'.tr;
      case 500:
        return 'server_error'.tr;
      case 502:
        return 'bad_gateway'.tr;
      case 503:
        return 'service_unavailable'.tr;
      default:
        return 'http_error'.tr;
    }
  }

  /// Shows an error snackbar using GetX.
  static void _showErrorSnackbar(String title, String message) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  /// Extracts error message from DioException (for manual usage).
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      return _parseDioError(error);
    }
    return error.toString();
  }
}

/// Result wrapper for API calls.
class ApiResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  ApiResult._({this.data, this.error, required this.isSuccess});

  factory ApiResult.success(T data) => ApiResult._(data: data, isSuccess: true);

  factory ApiResult.failure(String error) =>
      ApiResult._(error: error, isSuccess: false);

  /// Returns data if successful, otherwise returns the fallback value.
  T dataOr(T fallback) => isSuccess && data != null ? data as T : fallback;
}
