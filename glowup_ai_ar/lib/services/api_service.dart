import 'dart:io';
import 'package:dio/dio.dart';
import '../models/makeup_style.dart';

class ApiService {
  late Dio _dio;
  static String _serverIp = 'loathsomely-unethnological-warren.ngrok-free.dev';
  static bool _useHttps = true;

  ApiService() {
    _initializeDio();
  }

  void _initializeDio() {
    final protocol = _useHttps ? 'https' : 'http';
    _dio = Dio(
      BaseOptions(
        baseUrl: '$protocol://$_serverIp/api',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 5),
        contentType: 'application/json',
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: false,
        error: true,
      ),
    );
  }

  /// Set custom server IP (format: "192.168.1.100:5000")
  void setServerIp(String ipAddress) {
    _serverIp = ipAddress;
    _initializeDio();
  }

  /// Get current server IP
  String getServerIp() => _serverIp;

  /// Health check
  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get API status
  Future<ApiResponse<Map<String, dynamic>>> getStatus() async {
    try {
      final response = await _dio.get('/status');

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: response.data as Map<String, dynamic>,
          message: 'Status retrieved successfully',
          statusCode: 200,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Failed to get status',
          statusCode: response.statusCode ?? 500,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Get available makeup styles
  Future<ApiResponse<List<MakeupStyle>>> getMakeupStyles() async {
    try {
      final response = await _dio.get('/styles');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final styles = data
            .map((item) => MakeupStyle.fromJson(item as Map<String, dynamic>))
            .toList();

        return ApiResponse(
          success: true,
          data: styles,
          message: 'Styles loaded successfully',
          statusCode: 200,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Failed to load styles',
          statusCode: response.statusCode ?? 500,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Transfer makeup to image
  Future<ApiResponse<TransferResult>> transferMakeup({
    required String imagePath,
    required String styleId,
    String? customStylePath,
    Function(int, int)? onSendProgress,
  }) async {
    try {
      // Validate image file exists
      if (!File(imagePath).existsSync()) {
        return ApiResponse(
          success: false,
          message: 'Image file not found',
          statusCode: 400,
        );
      }

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
        'style_id': styleId,
        if (customStylePath != null && File(customStylePath).existsSync())
          'custom_style': await MultipartFile.fromFile(customStylePath),
      });

      final response = await _dio.post(
        '/transfer',
        data: formData,
        onSendProgress: onSendProgress,
      );

      if (response.statusCode == 200) {
        final result = TransferResult.fromJson(response.data);
        return ApiResponse(
          success: true,
          data: result,
          message: 'Makeup transfer completed successfully',
          statusCode: 200,
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['message'] ?? 'Transfer failed',
          statusCode: response.statusCode ?? 500,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Download result image
  Future<ApiResponse<File>> downloadResult(String resultId) async {
    try {
      final savePath = '/tmp/$resultId';
      final response = await _dio.download(
        '/result/$resultId',
        savePath,
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: File(savePath),
          message: 'Result downloaded successfully',
          statusCode: 200,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Failed to download result',
          statusCode: response.statusCode ?? 500,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }
}
