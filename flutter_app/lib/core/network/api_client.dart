import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../errors/app_error.dart';

typedef TokenProvider = Future<String?> Function();

class ApiClient {
  ApiClient({http.Client? httpClient, this._tokenProvider, String? baseUrl})
    : _httpClient = httpClient ?? http.Client(),
      _baseUri = Uri.parse(baseUrl ?? AppConfig.oracleApiBaseUrl);

  final http.Client _httpClient;
  final TokenProvider? _tokenProvider;
  final Uri _baseUri;

  Uri _uri(String path, [Map<String, dynamic>? queryParameters]) {
    final safePath = path.startsWith('/') ? path : '/$path';
    return _baseUri.replace(
      path: safePath,
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  Future<Map<String, String>> _headers({
    bool auth = true,
    bool json = true,
  }) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (json) headers['Content-Type'] = 'application/json';
    if (_baseUri.host.contains('ngrok-free.dev') ||
        _baseUri.host.contains('ngrok-free.app')) {
      headers['ngrok-skip-browser-warning'] = 'true';
    }
    final tokenProvider = _tokenProvider;
    if (auth && tokenProvider != null) {
      final token = await tokenProvider();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<dynamic> get(
    String path, {
    bool auth = true,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _request(
      () async => _httpClient.get(
        _uri(path, queryParameters),
        headers: await _headers(auth: auth),
      ),
      timeout: AppConfig.requestTimeout,
    );
    return _decode(response);
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    bool auth = true,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _request(
      () async => _httpClient.post(
        _uri(path, queryParameters),
        headers: await _headers(auth: auth),
        body: jsonEncode(body ?? const <String, dynamic>{}),
      ),
      timeout: AppConfig.requestTimeout,
    );
    return _decode(response);
  }

  Future<dynamic> put(
    String path, {
    Object? body,
    bool auth = true,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _request(
      () async => _httpClient.put(
        _uri(path, queryParameters),
        headers: await _headers(auth: auth),
        body: jsonEncode(body ?? const <String, dynamic>{}),
      ),
      timeout: AppConfig.requestTimeout,
    );
    return _decode(response);
  }

  Future<dynamic> delete(
    String path, {
    Object? body,
    bool auth = true,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _request(
      () async => _httpClient.delete(
        _uri(path, queryParameters),
        headers: await _headers(auth: auth),
        body: body == null ? null : jsonEncode(body),
      ),
      timeout: AppConfig.requestTimeout,
    );
    return _decode(response);
  }

  Future<dynamic> multipartPost(
    String path, {
    required String fileField,
    required String filename,
    required Uint8List bytes,
    Map<String, String> fields = const {},
    bool auth = true,
  }) async {
    final request = http.MultipartRequest('POST', _uri(path))
      ..headers.addAll(await _headers(auth: auth, json: false))
      ..files.add(
        http.MultipartFile.fromBytes(fileField, bytes, filename: filename),
      )
      ..fields.addAll(fields);

    final streamed = await _requestStream(
      request.send,
      timeout: AppConfig.uploadTimeout,
    );
    return _decode(streamed);
  }

  Future<Uint8List> postBytes(
    String path, {
    Object? body,
    bool auth = true,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _request(
      () async => _httpClient.post(
        _uri(path, queryParameters),
        headers: await _headers(auth: auth),
        body: jsonEncode(body ?? const <String, dynamic>{}),
      ),
      timeout: AppConfig.uploadTimeout,
    );
    return response.bodyBytes;
  }

  Future<http.Response> _request(
    Future<http.Response> Function() call, {
    required Duration timeout,
  }) async {
    try {
      final response = await call().timeout(timeout);
      _guardStatusCode(response.statusCode, response.body);
      return response;
    } on TimeoutException {
      throw BackendOfflineError('Tempo limite excedido ao chamar o backend.');
    } on UnauthorizedError {
      rethrow;
    } on ForbiddenError {
      rethrow;
    } on AppError {
      rethrow;
    } catch (error) {
      throw BackendOfflineError('Falha de rede: $error');
    }
  }

  Future<http.Response> _requestStream(
    Future<http.StreamedResponse> Function() call, {
    required Duration timeout,
  }) async {
    try {
      final streamed = await call().timeout(timeout);
      final response = await http.Response.fromStream(streamed);
      _guardStatusCode(response.statusCode, response.body);
      return response;
    } on TimeoutException {
      throw BackendOfflineError('Tempo limite excedido ao chamar o backend.');
    } on UnauthorizedError {
      rethrow;
    } on ForbiddenError {
      rethrow;
    } on AppError {
      rethrow;
    } catch (error) {
      throw BackendOfflineError('Falha de rede: $error');
    }
  }

  dynamic _decode(http.Response response) {
    if (response.body.isEmpty) return const <String, dynamic>{};
    try {
      return jsonDecode(response.body);
    } catch (_) {
      throw InvalidResponseError();
    }
  }

  void _guardStatusCode(int statusCode, String body) {
    if (statusCode >= 200 && statusCode < 300) return;
    if (statusCode == 401) throw UnauthorizedError();
    if (statusCode == 403) throw ForbiddenError();

    String message = 'Erro do servidor ($statusCode).';
    if (body.isNotEmpty) {
      try {
        final payload = jsonDecode(body);
        if (payload is Map<String, dynamic>) {
          final candidate = payload['message'] ?? payload['error'];
          if (candidate is String && candidate.trim().isNotEmpty) {
            message = candidate.trim();
          }
        }
      } catch (_) {
        // Keep default message.
      }
    }
    throw AppError(message, statusCode: statusCode);
  }
}
