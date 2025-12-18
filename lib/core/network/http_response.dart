/// Generic HTTP response wrapper
class HttpResponse<T> {
  /// Error response
  factory HttpResponse.error(String message, {int statusCode = 500}) {
    return HttpResponse(
      statusCode: statusCode,
      errorMessage: message,
      isSuccess: false,
    );
  }
  const HttpResponse({
    required this.statusCode,
    this.data,
    this.errorMessage,
    required this.isSuccess,
  });

  /// Success response
  factory HttpResponse.success(T data, {int statusCode = 200}) {
    return HttpResponse(statusCode: statusCode, data: data, isSuccess: true);
  }
  final int statusCode;
  final T? data;
  final String? errorMessage;
  final bool isSuccess;

  @override
  String toString() {
    if (isSuccess) {
      return 'HttpResponse(success: $statusCode, data: $data)';
    } else {
      return 'HttpResponse(error: $statusCode, message: $errorMessage)';
    }
  }
}
