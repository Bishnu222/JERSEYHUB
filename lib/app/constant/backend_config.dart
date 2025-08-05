import 'dart:io';
import 'package:dio/dio.dart';

/// Backend Configuration for Jersey Hub
///
/// IMPORTANT: Backend server runs on port 5050 - DO NOT CHANGE THIS PORT
class BackendConfig {
  // ===== JERSEY BACKEND CONFIGURATION =====

  /// Set this to true to enable backend and use real API data
  static const bool enableBackend = false; // Temporarily disabled for testing

  /// Your Jersey backend server address
  /// For Android emulator: http://10.0.2.2:5050
  /// For physical device: http://YOUR_COMPUTER_IP:5050
  /// For production: https://your-domain.com
  ///
  /// FIXED PORT: 5050 - DO NOT CHANGE THIS PORT
  static String get serverAddress {
    // For Android emulator, use 10.0.2.2 to access host machine
    if (Platform.isAndroid) {
      return "http://10.0.2.2:5050"; // Android emulator special IP
    }
    // For Windows and other platforms, use localhost
    return "http://localhost:5050";
  }

  /// Alternative server addresses for different scenarios
  static const List<String> alternativeAddresses = [
    "http://10.0.2.2:5050", // Android emulator (highest priority)
    "http://localhost:5050", // Localhost
    "http://127.0.0.1:5050", // Loopback (Windows compatible)
    "http://192.168.1.13:5050", // Your computer's IP
  ];

  /// API base path (usually empty for Jersey, or "/api" if you have it configured)
  static const String apiPath = "/api";

  /// Full base URL for API calls
  static String get baseUrl => "$serverAddress$apiPath/";

  /// Upload URL for images/files
  static String get uploadUrl => "$serverAddress/uploads/";

  // ===== JERSEY ENDPOINTS =====

  /// User authentication endpoints
  static const String loginEndpoint = "auth/login";
  static const String registerEndpoint = "auth/register";
  static const String getUserEndpoint = "auth/";
  static const String uploadImageEndpoint = "auth/upload-profile-image";

  /// Product endpoints
  static const String productsEndpoint = "admin/product";
  static const String categoriesEndpoint = "admin/category";

  /// Order endpoints
  static const String ordersEndpoint = "orders";

  /// Payment endpoints
  static const String esewaEndpoint = "esewa";

  /// Notification endpoints
  static const String notificationsEndpoint = "notifications";

  // ===== JERSEY RESPONSE FORMATS =====

  /// Expected token field names in login response
  /// Update these to match your Jersey backend response format
  static const List<String> tokenFieldNames = [
    'token',
    'accessToken',
    'jwt',
    'authToken',
    'bearerToken',
  ];

  /// Expected success status codes
  static const List<int> successStatusCodes = [200, 201];

  /// Expected error status codes and their messages
  static const Map<int, String> errorMessages = {
    400: 'Bad Request - Invalid data provided',
    401: 'Unauthorized - Invalid credentials',
    403: 'Forbidden - Access denied',
    404: 'Not Found - Resource not found',
    409: 'Conflict - User already exists',
    500: 'Internal Server Error - Server error occurred',
  };

  /// Test backend connectivity
  static Future<bool> testBackendConnection() async {
    final dio = Dio();

    print('🔍 Testing backend connectivity...');
    print('🖥️ Platform: ${Platform.operatingSystem}');
    print('🌐 Primary server address: $serverAddress');
    print('🔄 Alternative addresses: $alternativeAddresses');

    // Try the primary server address first
    try {
      print('🔄 Testing primary address: $serverAddress');
      final response = await dio.get('$serverAddress/api/test');
      if (response.statusCode == 200) {
        print('✅ Backend connection successful: $serverAddress');
        return true;
      }
    } catch (e) {
      print('❌ Primary backend connection failed: $serverAddress - $e');
    }

    // Try alternative addresses
    for (final address in alternativeAddresses) {
      try {
        print('🔄 Testing alternative address: $address');
        final response = await dio.get('$address/api/test');
        if (response.statusCode == 200) {
          print('✅ Alternative backend connection successful: $address');
          return true;
        }
      } catch (e) {
        print('❌ Alternative backend connection failed: $address - $e');
      }
    }

    print('❌ All backend connection attempts failed');
    return false;
  }

  /// Enable API logging for debugging
  static const bool enableApiLogging = true;

  /// Connection timeout in seconds
  static const int connectionTimeoutSeconds =
      30; // Increased to 30 seconds for better reliability

  /// Receive timeout in seconds
  static const int receiveTimeoutSeconds =
      30; // Increased to 30 seconds for better reliability
}
