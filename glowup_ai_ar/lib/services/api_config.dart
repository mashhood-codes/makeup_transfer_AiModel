import 'package:dio/dio.dart';
import 'dart:convert';

class ApiConfig {
  static const String renderUrl = 'https://glowup-api.onrender.com';
  static const String ngrokUrl = 'https://glowup-dev-4821.ngrok-free.app';
  static const int timeoutMs = 30000;

  static final Dio _dio = Dio();
  static String _currentBaseUrl = renderUrl;

  static String get baseUrl => _currentBaseUrl;

  static Future<bool> _testUrl(String url) async {
    try {
      final testDio = Dio(BaseOptions(
        baseUrl: url,
        connectTimeout: const Duration(milliseconds: 5000),
        receiveTimeout: const Duration(milliseconds: 5000),
      ));
      await testDio.get('/health');
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> initialize() async {
    // Try Render first
    final renderAvailable = await _testUrl(renderUrl);
    if (renderAvailable) {
      _currentBaseUrl = renderUrl;
    } else {
      // Fallback to ngrok
      final ngrokAvailable = await _testUrl(ngrokUrl);
      _currentBaseUrl = ngrokAvailable ? ngrokUrl : renderUrl;
    }

    _dio.options = BaseOptions(
      baseUrl: _currentBaseUrl,
      connectTimeout: const Duration(milliseconds: timeoutMs),
      receiveTimeout: const Duration(milliseconds: timeoutMs * 10),
      contentType: 'application/json',
    );
  }

  static Dio getDio() {
    _dio.options.baseUrl = _currentBaseUrl;
    return _dio;
  }

  static Future<void> switchUrl(String newUrl) async {
    _currentBaseUrl = newUrl;
    _dio.options.baseUrl = newUrl;
  }
}
