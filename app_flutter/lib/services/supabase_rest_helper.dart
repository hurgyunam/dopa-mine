import 'dart:convert';
import 'dart:io';

typedef AccessTokenProvider = Future<String?> Function();

class SupabaseApiException implements Exception {
  SupabaseApiException({
    required this.statusCode,
    required this.code,
    required this.message,
  });

  final int statusCode;
  final String code;
  final String message;

  @override
  String toString() =>
      'SupabaseApiException(statusCode: $statusCode, code: $code, message: $message)';
}

class SupabaseRestHelper {
  SupabaseRestHelper({
    required String supabaseUrl,
    required String publishableKey,
    required AccessTokenProvider accessTokenProvider,
    HttpClient? httpClient,
  })  : _baseUri = Uri.parse('$supabaseUrl/rest/v1/'),
        _publishableKey = publishableKey,
        _accessTokenProvider = accessTokenProvider,
        _httpClient = httpClient ?? HttpClient();

  final Uri _baseUri;
  final String _publishableKey;
  final AccessTokenProvider _accessTokenProvider;
  final HttpClient _httpClient;

  Future<List<Map<String, dynamic>>> postTable({
    required String table,
    required List<Map<String, dynamic>> rows,
    Map<String, String> query = const <String, String>{},
    bool returnRepresentation = false,
  }) async {
    final Object? body = rows;
    final Object? decoded = await _request(
      method: 'POST',
      path: table,
      query: query,
      body: body,
      returnRepresentation: returnRepresentation,
    );
    return _decodeListMap(decoded);
  }

  Future<List<Map<String, dynamic>>> patchTable({
    required String table,
    required Map<String, dynamic> row,
    required Map<String, String> query,
    bool returnRepresentation = false,
  }) async {
    final Object? decoded = await _request(
      method: 'PATCH',
      path: table,
      query: query,
      body: row,
      returnRepresentation: returnRepresentation,
    );
    return _decodeListMap(decoded);
  }

  Future<List<Map<String, dynamic>>> getTable({
    required String table,
    Map<String, String> query = const <String, String>{},
  }) async {
    final Object? decoded = await _request(
      method: 'GET',
      path: table,
      query: query,
      body: null,
      returnRepresentation: false,
    );
    return _decodeListMap(decoded);
  }

  Future<Object?> _request({
    required String method,
    required String path,
    required Map<String, String> query,
    required Object? body,
    required bool returnRepresentation,
  }) async {
    final String? token = await _accessTokenProvider();
    if (token == null || token.isEmpty) {
      throw SupabaseApiException(
        statusCode: 401,
        code: 'missing_access_token',
        message: '로그인 access token이 없어 Supabase 요청을 보낼 수 없습니다.',
      );
    }

    final Uri uri = _baseUri.resolve(path).replace(queryParameters: query);
    final HttpClientRequest request = await _httpClient.openUrl(method, uri);
    request.headers.set(HttpHeaders.contentTypeHeader, ContentType.json.mimeType);
    request.headers.set('apikey', _publishableKey);
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    request.headers.set('Accept', 'application/json');
    if (returnRepresentation) {
      request.headers.set('Prefer', 'return=representation');
    }

    if (body != null) {
      request.write(jsonEncode(body));
    }

    final HttpClientResponse response = await request.close();
    final String responseText = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SupabaseApiException(
        statusCode: response.statusCode,
        code: _extractErrorCode(responseText) ?? 'http_${response.statusCode}',
        message: _extractErrorMessage(responseText) ?? 'Supabase REST 호출에 실패했습니다.',
      );
    }

    if (responseText.isEmpty) {
      return null;
    }
    return jsonDecode(responseText);
  }

  List<Map<String, dynamic>> _decodeListMap(Object? decoded) {
    if (decoded == null) {
      return const <Map<String, dynamic>>[];
    }
    if (decoded is! List) {
      throw SupabaseApiException(
        statusCode: 500,
        code: 'invalid_response_shape',
        message: 'Supabase 응답 형식이 예상과 다릅니다.',
      );
    }

    return decoded
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (Map<dynamic, dynamic> row) => row.map<String, dynamic>(
            (dynamic key, dynamic value) => MapEntry<String, dynamic>(
              key.toString(),
              value,
            ),
          ),
        )
        .toList(growable: false);
  }

  String? _extractErrorCode(String rawBody) {
    final Object? decoded = _tryDecode(rawBody);
    if (decoded is Map && decoded['code'] is String) {
      return decoded['code'] as String;
    }
    return null;
  }

  String? _extractErrorMessage(String rawBody) {
    final Object? decoded = _tryDecode(rawBody);
    if (decoded is Map && decoded['message'] is String) {
      return decoded['message'] as String;
    }
    return null;
  }

  Object? _tryDecode(String rawBody) {
    if (rawBody.isEmpty) {
      return null;
    }
    try {
      return jsonDecode(rawBody);
    } catch (_) {
      return null;
    }
  }
}
