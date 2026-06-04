import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Base API service for all HTTP requests.
/// Handles auth token injection and standard response parsing.
class ApiService {
  static String _decodeFully(String value) {
    var current = value;
    for (var i = 0; i < 3; i++) {
      try {
        final next = Uri.decodeComponent(current);
        if (next == current) break;
        current = next;
      } catch (_) {
        break;
      }
    }
    return current;
  }

  static String _encodePathSegmentStrict(String segment) {
    final decoded = _decodeFully(segment);
    final encoded = Uri.encodeComponent(decoded);
    // Keep strict RFC3986 encoding for characters that may be left unescaped
    // by platform URI helpers but can still break image fetches in browsers.
    return encoded
        .replaceAll("'", '%27')
        .replaceAll('(', '%28')
        .replaceAll(')', '%29')
        .replaceAll('*', '%2A');
  }

  // Android emulator uses 10.0.2.2 to reach host localhost
  // iOS simulator and desktop use localhost directly
  static String get baseUrl {
    return 'https://ripe-waves-drive.loca.lt/api';
  }

  /// Image base URL (without /api)
  static String get imageBaseUrl {
    return 'https://ripe-waves-drive.loca.lt';
  }

  /// Normalizes image URLs from backend for current runtime.
  /// - Converts relative paths to absolute image URLs.
  /// - Rewrites localhost URLs for Android emulator.
  /// - Safely re-encodes each path segment for spaces/special chars.
  static String resolveImageUrl(String? rawUrl) {
    final input = (rawUrl ?? '').trim();
    if (input.isEmpty) return '';
    if (input.startsWith('data:')) return input;

    final base = Uri.parse(imageBaseUrl);
    final parsed = Uri.tryParse(input);

    String scheme;
    String host;
    int? port;
    List<String> segments;
    String query = '';

    if (parsed == null) {
      return input;
    } else if (!parsed.hasScheme) {
      scheme = base.scheme;
      host = base.host;
      port = base.hasPort ? base.port : null;
      segments = parsed.pathSegments;
      query = parsed.hasQuery ? parsed.query : '';
    } else {
      final shouldRewriteLocalHost = parsed.host == 'localhost' || parsed.host == '127.0.0.1';
      scheme = shouldRewriteLocalHost ? base.scheme : parsed.scheme;
      host = shouldRewriteLocalHost ? base.host : parsed.host;
      port = shouldRewriteLocalHost
          ? (base.hasPort ? base.port : null)
          : (parsed.hasPort ? parsed.port : null);
      segments = parsed.pathSegments;
      query = parsed.hasQuery ? parsed.query : '';
    }

    final encodedPath = segments.map(_encodePathSegmentStrict).join('/');
    final authority = port != null ? '$host:$port' : host;
    final queryPart = query.isNotEmpty ? '?$query' : '';
    return '$scheme://$authority/$encodedPath$queryPart';
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  /// GET request
  static Future<ApiResponse> get(String endpoint, {bool auth = true}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _headers(auth: auth),
      );
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection failed: ${e.toString()}',
        data: null,
        statusCode: 0,
      );
    }
  }

  /// POST request
  static Future<ApiResponse> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _headers(auth: auth),
        body: jsonEncode(body),
      );
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection failed: ${e.toString()}',
        data: null,
        statusCode: 0,
      );
    }
  }

  /// PUT request
  static Future<ApiResponse> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _headers(auth: auth),
        body: jsonEncode(body),
      );
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection failed: ${e.toString()}',
        data: null,
        statusCode: 0,
      );
    }
  }

  /// DELETE request
  static Future<ApiResponse> delete(String endpoint, {Map<String, dynamic>? body, bool auth = true}) async {
    try {
      final request = http.Request('DELETE', Uri.parse('$baseUrl$endpoint'));
      request.headers.addAll(await _headers(auth: auth));
      if (body != null) {
        request.body = jsonEncode(body);
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection failed: ${e.toString()}',
        data: null,
        statusCode: 0,
      );
    }
  }

  static ApiResponse _parseResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return ApiResponse(
        success: body['status'] == 'success',
        message: body['message'] ?? '',
        data: body['data'],
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to parse response',
        data: null,
        statusCode: response.statusCode,
      );
    }
  }
}

class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.statusCode,
  });
}
