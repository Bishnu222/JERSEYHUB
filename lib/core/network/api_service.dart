import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../app/constant/api_endpoints.dart';
import '../../app/constant/backend_config.dart';
import 'dio_error_interceptor.dart';

class ApiService {
  final Dio _dio;

  Dio get dio => _dio;

  ApiService(this._dio) {
    if (BackendConfig.enableBackend) {
      print('🔧 ApiService: Initializing with backend enabled');
      print('🌐 Base URL: ${ApiEndpoints.baseUrl}');
      print('⏱️ Connect timeout: ${ApiEndpoints.connectionTimeout}');
      print('⏱️ Receive timeout: ${ApiEndpoints.receiveTimeout}');
      print('🖥️ Platform: ${Platform.operatingSystem}');

      _dio
        ..options.baseUrl = ApiEndpoints.baseUrl
        ..options.connectTimeout = ApiEndpoints.connectionTimeout
        ..options.receiveTimeout = ApiEndpoints.receiveTimeout
        ..interceptors.add(DioErrorInterceptor())
        ..interceptors.add(
          PrettyDioLogger(
            requestHeader: true,
            requestBody: true,
            responseHeader: true,
            responseBody: true,
            error: true,
            compact: false,
            enabled: BackendConfig.enableApiLogging,
          ),
        )
        ..options.headers = {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        };
      print('✅ ApiService: Backend configuration complete');
      print(
        '🔗 Full URL for registration: ${ApiEndpoints.baseUrl}${ApiEndpoints.registerUser}',
      );
      print('🔧 Dio options:');
      print('  - Base URL: ${_dio.options.baseUrl}');
      print('  - Connect Timeout: ${_dio.options.connectTimeout}');
      print('  - Receive Timeout: ${_dio.options.receiveTimeout}');
      print('  - Headers: ${_dio.options.headers}');
    } else {
      print('📱 ApiService: Backend disabled, using mock mode');
      // Set a dummy base URL for mock mode with proper path
      _dio.options.baseUrl = 'http://mock.local/';
    }
  }

  // Helper method to add authorization header
  void setAuthToken(String token) {
    if (BackendConfig.enableBackend) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  // Helper method to remove authorization header
  void removeAuthToken() {
    if (BackendConfig.enableBackend) {
      _dio.options.headers.remove('Authorization');
    }
  }
}
