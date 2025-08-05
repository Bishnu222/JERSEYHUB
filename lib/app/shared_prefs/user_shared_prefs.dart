import 'package:shared_preferences/shared_preferences.dart';
import 'package:jerseyhub/app/shared_prefs/token_shared_prefs.dart';

class UserSharedPrefs {
  final SharedPreferences _sharedPreferences;
  late final TokenSharedPrefs _tokenSharedPrefs;

  UserSharedPrefs(this._sharedPreferences) {
    _tokenSharedPrefs = TokenSharedPrefs(sharedPreferences: _sharedPreferences);
  }

  // Get current user email (used as identifier)
  String? getCurrentUserEmail() {
    return _sharedPreferences.getString('userEmail');
  }

  // Set current user email
  Future<void> setCurrentUserEmail(String email) async {
    await _sharedPreferences.setString('userEmail', email);
  }

  /// Check if user is properly logged in
  Future<bool> isUserLoggedIn() async {
    final userId = getCurrentUserId();
    final tokenResult = await _tokenSharedPrefs.getToken();

    return tokenResult.fold(
      (failure) => false,
      (token) =>
          userId != null &&
          userId.isNotEmpty &&
          userId != 'unknown_user' &&
          token != null &&
          token.isNotEmpty,
    );
  }

  /// Get current user ID with validation
  String? getCurrentUserId() {
    return _sharedPreferences.getString('userId');
  }

  // Set current user ID
  Future<void> setCurrentUserId(String userId) async {
    await _sharedPreferences.setString('userId', userId);
  }

  /// Set user as properly logged in (call this after successful authentication)
  Future<void> setUserLoggedIn(String userId, String email) async {
    await setCurrentUserId(userId);
    await setCurrentUserEmail(email);
    await _sharedPreferences.setBool('isLoggedIn', true);
    print(
      '✅ UserSharedPrefs: User logged in successfully - ID: $userId, Email: $email',
    );
  }

  // Clear user data on logout
  Future<void> clearUserData() async {
    await _sharedPreferences.remove('userEmail');
    await _sharedPreferences.remove('userId');
    await _sharedPreferences.remove('profileImageUrl');
    await _sharedPreferences.setBool('isLoggedIn', false);

    // Clear token using TokenSharedPrefs
    await _tokenSharedPrefs.clearToken();

    print('✅ UserSharedPrefs: All user data cleared successfully');
  }

  // Get all user data for debugging
  Map<String, dynamic> getAllUserData() {
    return {
      'userId': getCurrentUserId(),
      'userEmail': getCurrentUserEmail(),
      'profileImageUrl': getProfileImageUrl(),
      'isLoggedIn': isLoggedIn(),
    };
  }

  // Print current user data for debugging
  void printCurrentUserData() {
    final data = getAllUserData();
    print('🔍 UserSharedPrefs: Current user data:');
    data.forEach((key, value) {
      print('  $key: $value');
    });
  }

  // Get profile image URL
  String? getProfileImageUrl() {
    return _sharedPreferences.getString('profileImageUrl');
  }

  // Set profile image URL
  Future<void> setProfileImageUrl(String imageUrl) async {
    await _sharedPreferences.setString('profileImageUrl', imageUrl);
  }

  // Check if user is logged in (legacy method - use isUserLoggedIn() instead)
  bool isLoggedIn() {
    return _sharedPreferences.getBool('isLoggedIn') ?? false;
  }
}
