import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sehatapp/core/network/http_exception.dart';
import 'package:sehatapp/core/network/http_response.dart';

/// HTTP client service for making API requests
class HttpClient {
  HttpClient({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
    this.enableLogging = true,
  }) : _client = client ?? http.Client();
  final http.Client _client;
  final Duration timeout;
  final bool enableLogging;

  /// Make a POST request
  Future<HttpResponse<T>> post<T>({
    required String url,
    Map<String, String>? headers,
    dynamic body,
    T Function(dynamic)? parser,
  }) async {
    try {
      _log('POST $url');
      if (body != null) _log('Body: ${jsonEncode(body)}');

      final response = await _client
          .post(
            Uri.parse(url),
            headers: headers ?? {'Content-Type': 'application/json'},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response, parser);
    } on io.SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const TimeoutException();
    } catch (e) {
      _log('Error: $e');
      rethrow;
    }
  }

  /// Make a GET request
  Future<HttpResponse<T>> get<T>({
    required String url,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  }) async {
    try {
      _log('GET $url');

      final response = await _client
          .get(Uri.parse(url), headers: headers)
          .timeout(timeout);

      return _handleResponse(response, parser);
    } on io.SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const TimeoutException();
    } catch (e) {
      _log('Error: $e');
      rethrow;
    }
  }

  /// Make a PUT request
  Future<HttpResponse<T>> put<T>({
    required String url,
    Map<String, String>? headers,
    dynamic body,
    T Function(dynamic)? parser,
  }) async {
    try {
      _log('PUT $url');
      if (body != null) _log('Body: ${jsonEncode(body)}');

      final response = await _client
          .put(
            Uri.parse(url),
            headers: headers ?? {'Content-Type': 'application/json'},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response, parser);
    } on io.SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const TimeoutException();
    } catch (e) {
      _log('Error: $e');
      rethrow;
    }
  }

  /// Make a DELETE request
  Future<HttpResponse<T>> delete<T>({
    required String url,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  }) async {
    try {
      _log('DELETE $url');

      final response = await _client
          .delete(Uri.parse(url), headers: headers)
          .timeout(timeout);

      return _handleResponse(response, parser);
    } on io.SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const TimeoutException();
    } catch (e) {
      _log('Error: $e');
      rethrow;
    }
  }

  /// Make a streaming POST request (for SSE)
  Stream<String> postStream({
    required String url,
    Map<String, String>? headers,
    dynamic body,
  }) async* {
    try {
      _log('POST STREAM $url');
      if (body != null) _log('Body: ${jsonEncode(body)}');

      final request = http.Request('POST', Uri.parse(url));
      request.headers.addAll(headers ?? {'Content-Type': 'application/json'});
      if (body != null) {
        request.body = jsonEncode(body);
      }

      final streamedResponse = await _client.send(request).timeout(timeout);

      _log('Stream Status: ${streamedResponse.statusCode}');

      if (streamedResponse.statusCode >= 400) {
        final errorBody = await streamedResponse.stream.bytesToString();
        _handleErrorStatus(streamedResponse.statusCode, errorBody);
      }

      await for (final chunk in streamedResponse.stream.transform(
        utf8.decoder,
      )) {
        yield chunk;
      }

      _log('Stream completed');
    } on io.SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const TimeoutException();
    } catch (e) {
      _log('Stream Error: $e');
      rethrow;
    }
  }

  /// Handle response and parse
  HttpResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? parser,
  ) {
    _log('Response Status: ${response.statusCode}');
    _log(
      'Response Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...',
    );

    // Check status code
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Success
      try {
        final data = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : null;
        final parsedData = parser != null && data != null
            ? parser(data)
            : data as T?;

        if (parsedData == null && T != dynamic) {
          throw ParseException(
            'Response data is null but type T is not nullable',
          );
        }

        return HttpResponse.success(
          parsedData as T,
          statusCode: response.statusCode,
        );
      } catch (e) {
        throw ParseException('Failed to parse response: $e');
      }
    } else {
      // Error
      _handleErrorStatus(response.statusCode, response.body);
      // This line won't be reached due to throw in _handleErrorStatus
      return HttpResponse.error(
        'Unknown error',
        statusCode: response.statusCode,
      );
    }
  }

  /// Handle error status codes
  void _handleErrorStatus(int statusCode, String body) {
    String errorMessage = 'Request failed';
    try {
      final data = jsonDecode(body);
      errorMessage =
          data['error']?['message'] ?? data['message'] ?? errorMessage;
    } catch (_) {
      errorMessage = body.isNotEmpty ? body : errorMessage;
    }

    if (statusCode == 401) {
      throw UnauthorizedException(errorMessage);
    } else if (statusCode == 404) {
      throw NotFoundException(errorMessage);
    } else if (statusCode >= 400 && statusCode < 500) {
      throw ClientException(errorMessage, statusCode: statusCode);
    } else if (statusCode >= 500) {
      throw ServerException(errorMessage, statusCode: statusCode);
    } else {
      throw HttpException(errorMessage, statusCode: statusCode);
    }
  }

  /// Log messages
  void _log(String message) {
    if (enableLogging) {
      if (kDebugMode) {
        print('[HttpClient] $message');
      }
    }
  }

  /// Dispose client
  void dispose() {
    _client.close();
  }
}
