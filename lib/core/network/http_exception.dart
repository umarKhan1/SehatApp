/// Custom HTTP exceptions for better error handling
library;

/// Base HTTP exception
class HttpException implements Exception {
  const HttpException(this.message, {this.statusCode, this.data});
  final String message;
  final int? statusCode;
  final dynamic data;

  @override
  String toString() =>
      'HttpException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Network connectivity exception
class NetworkException extends HttpException {
  const NetworkException([super.message = 'No internet connection']);

  @override
  String toString() => 'NetworkException: $message';
}

/// Request timeout exception
class TimeoutException extends HttpException {
  const TimeoutException([super.message = 'Request timeout']);

  @override
  String toString() => 'TimeoutException: $message';
}

/// Server error (5xx)
class ServerException extends HttpException {
  const ServerException(super.message, {super.statusCode, super.data});

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

/// Client error (4xx)
class ClientException extends HttpException {
  const ClientException(super.message, {super.statusCode, super.data});

  @override
  String toString() => 'ClientException: $message (Status: $statusCode)';
}

/// Unauthorized (401)
class UnauthorizedException extends ClientException {
  const UnauthorizedException([super.message = 'Unauthorized'])
    : super(statusCode: 401);

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Not found (404)
class NotFoundException extends ClientException {
  const NotFoundException([super.message = 'Resource not found'])
    : super(statusCode: 404);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Parse/Serialization exception
class ParseException extends HttpException {
  const ParseException([super.message = 'Failed to parse response']);

  @override
  String toString() => 'ParseException: $message';
}
