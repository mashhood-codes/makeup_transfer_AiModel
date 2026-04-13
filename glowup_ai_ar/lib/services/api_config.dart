import 'package:dio/dio.dart';
import 'dart:convert';

class ApiConfig {
  // Server URLs - Update NGROK_URL when you restart the server with ngrok
  static const String renderUrl = 'https://glowup-api.onrender.com';
  static const String ngrokUrl = 'https://loathsomely-unethnological-warren.ngrok-free.dev';
  static const int timeoutMs = 30000;

  static final Dio _dio = Dio();
  static String _currentBaseUrl = renderUrl;
  static String _activeServer = 'unknown';

  static String get baseUrl => _currentBaseUrl;
  static String get activeServer => _activeServer;

  static Future<bool> _testUrl(String url) async {
    try {
      print('🔍 Testing URL: $url');
      final testDio = Dio(BaseOptions(
        baseUrl: url,
        connectTimeout: const Duration(milliseconds: 5000),
        receiveTimeout: const Duration(milliseconds: 5000),
      ));
      final response = await testDio.get('/health');
      print('   ✅ Server healthy: ${response.data}');
      return response.statusCode == 200;
    } catch (e) {
      print('   ❌ Server unreachable: $e');
      return false;
    }
  }

  static Future<void> initialize() async {
    print('🚀 Initializing API Config...');
    print('');

    // Try Render first (production)
    print('1️⃣  Trying RENDER URL...');
    final renderAvailable = await _testUrl(renderUrl);

    if (renderAvailable) {
      _currentBaseUrl = renderUrl;
      _activeServer = 'RENDER (Production)';
      print('   ✅ Using RENDER server');
    } else {
      // Fallback to ngrok (development)
      print('2️⃣  Render unavailable, trying NGROK...');
      final ngrokAvailable = await _testUrl(ngrokUrl);

      if (ngrokAvailable) {
        _currentBaseUrl = ngrokUrl;
        _activeServer = 'NGROK (Development)';
        print('   ✅ Using NGROK server');
      } else {
        // Default to render (will fail gracefully)
        _currentBaseUrl = renderUrl;
        _activeServer = 'RENDER (Assumed, both offline)';
        print('   ⚠️  Both servers unreachable, defaulting to RENDER');
      }
    }

    print('');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ API Configuration Complete');
    print('   Server: $_activeServer');
    print('   URL: $_currentBaseUrl');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('');

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
    print('🔄 Switching API URL to: $newUrl');
    _currentBaseUrl = newUrl;
    _dio.options.baseUrl = newUrl;
  }

  /// For manual testing/debugging
  static Future<void> testConnection() async {
    print('');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🧪 Testing API Connection');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('Active Server: $_activeServer');
    print('Base URL: $_currentBaseUrl');
    print('');

    try {
      print('Sending /health request...');
      final response = await _dio.get('/health');
      print('✅ Response: ${response.data}');
    } catch (e) {
      print('❌ Error: $e');
    }

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('');
  }
}
