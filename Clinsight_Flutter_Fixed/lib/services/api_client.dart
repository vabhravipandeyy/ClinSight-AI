import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient({required this.baseUrl});

  final String baseUrl;
  final Duration _timeout = const Duration(seconds: 20);
  final Map<String, String> _defaultHeaders = const {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Uri _uri(String path, [Map<String, String>? query]) {
    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$cleanBase$cleanPath').replace(queryParameters: query);
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    try {
      final res = await http
          .get(_uri(path, query), headers: _defaultHeaders)
          .timeout(_timeout);
      return _decode(res);
    } on TimeoutException {
      throw ApiException(
        statusCode: 0,
        message: 'Request timeout. Please check internet and try again.',
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        statusCode: 0,
        message: _mapClientError(e),
      );
    }
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    try {
      final res = await http
          .post(
            _uri(path),
            headers: _defaultHeaders,
            body: jsonEncode(body ?? const {}),
          )
          .timeout(_timeout);
      return _decode(res);
    } on TimeoutException {
      throw ApiException(
        statusCode: 0,
        message: 'Request timeout. Please check internet and try again.',
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        statusCode: 0,
        message: _mapClientError(e),
      );
    }
  }

  Future<dynamic> multipartPost(
    String path, {
    required String fileField,
    required String filePath,
    Map<String, String>? fields,
  }) async {
    final req = http.MultipartRequest('POST', _uri(path));
    req.fields.addAll(fields ?? const {});
    req.files.add(await http.MultipartFile.fromPath(fileField, filePath));

    try {
      final streamed = await req.send().timeout(_timeout);
      final res = await http.Response.fromStream(streamed);
      return _decode(res);
    } on TimeoutException {
      throw ApiException(
        statusCode: 0,
        message: 'Upload timeout. Please try a smaller file or retry.',
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        statusCode: 0,
        message: _mapClientError(e),
      );
    }
  }

  String _mapClientError(http.ClientException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('failed to fetch')) {
      return 'Network/CORS issue: backend not reachable from this client.';
    }
    return 'Network error: ${e.message}';
  }

  dynamic _decode(http.Response res) {
    final bodyText = res.body.trim();
    final isJson =
        res.headers['content-type']?.contains('application/json') == true;
    dynamic body;

    if (bodyText.isNotEmpty && isJson) {
      body = jsonDecode(bodyText);
    } else {
      body = bodyText;
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }

    String message = 'Request failed';
    if (body is Map<String, dynamic> && body['error'] != null) {
      message = '${body['error']}';
    } else if (body is String && body.isNotEmpty) {
      message = body;
    }

    throw ApiException(statusCode: res.statusCode, message: message);
  }
}
