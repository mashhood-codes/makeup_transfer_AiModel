import 'dart:io';
import 'package:dio/dio.dart';
import 'api_config.dart';

class MakeupAPI {
  late Dio _dio;
  Dio get dio => _dio;  // Expose for accessing Dio directly

  MakeupAPI() {
    _initDio();
  }

  void _initDio() {
    _dio = Dio(BaseOptions(
      baseUrl: '${ApiConfig.baseUrl}/api',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 10),
    ));
  }

  void setServerUrl(String url) {
    ApiConfig.switchUrl(url);
    _initDio();
  }

  Future<bool> checkHealth() async {
    try {
      final res = await _dio.get('/health');
      return res.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }

  Future<List<Map<String, String>>> getStyles() async {
    try {
      final res = await _dio.get('/styles');
      if (res.statusCode == 200 && res.data is List) {
        return List<Map<String, String>>.from(
          (res.data as List).map((e) => Map<String, String>.from(e))
        );
      }
      throw Exception('Failed to get styles: ${res.statusCode}');
    } catch (e) {
      print('Error getting styles: $e');
      rethrow;
    }
  }

  Future<String> transferMakeup(File imageFile, String styleId, {File? customStyleFile}) async {
    try {
      print('🎨 Starting transfer:');
      print('   - Server: ${ApiConfig.baseUrl}');
      print('   - Image: ${imageFile.path}');
      print('   - Style ID: $styleId');
      print('   - Custom Style: ${customStyleFile?.path ?? "None"}');

      final formDataMap = {
        'image': await MultipartFile.fromFile(imageFile.path),
        'style_id': styleId,
      };

      // Add custom style if provided
      if (customStyleFile != null) {
        formDataMap['custom_style'] = await MultipartFile.fromFile(customStyleFile.path);
        print('   ✅ Custom style added to request');
      }

      final formData = FormData.fromMap(formDataMap);
      print('📤 Sending POST /api/transfer to ${ApiConfig.baseUrl}');

      final res = await _dio.post('/transfer', data: formData);

      print('📥 Response received: ${res.statusCode}');
      print('   - Full response data: ${res.data}');

      if (res.statusCode == 200) {
        var resultFilename = res.data['result_path'] ?? '';
        print('   - Raw result_path: "$resultFilename"');

        // CRITICAL: Extract ONLY the filename, remove any path components
        if (resultFilename.isNotEmpty) {
          // Handle Windows absolute paths (C:\path\to\file or C://path//to//file)
          resultFilename = resultFilename.replaceAll(RegExp(r'[\\\/]'), '/');
          resultFilename = resultFilename.replaceAll(RegExp(r'^[A-Z]:'), ''); // Remove C: D: etc
          resultFilename = resultFilename.replaceAll(RegExp(r'^/+'), ''); // Remove leading slashes

          final parts = resultFilename.split('/');
          resultFilename = parts.where((p) => p.isNotEmpty).toList().last;
          print('   - Cleaned filename: "$resultFilename"');
        }

        if (resultFilename.isEmpty) {
          throw Exception('Empty result filename received from server');
        }

        // Build FULL URL with just the filename
        final fullUrl = '${ApiConfig.baseUrl}/api/result/$resultFilename';
        print('📥 Building result URL:');
        print('   - Server: ${ApiConfig.baseUrl}');
        print('   - Filename: $resultFilename');
        print('   - Full URL: $fullUrl');

        return fullUrl;
      }
      throw Exception('Transfer failed: ${res.statusCode}');
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }
}




