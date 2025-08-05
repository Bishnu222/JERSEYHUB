import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jerseyhub/app/service_locator/service_locator.dart';
import 'package:jerseyhub/app/shared_prefs/user_shared_prefs.dart';

enum SplashState { initial, navigateToHome, navigateToLogin }

class SplashViewModel extends Cubit<SplashState> {
  SplashViewModel() : super(SplashState.initial);

  Future<void> decideNavigation() async {
    // Increased delay to allow users to see the beautiful animations
    await Future.delayed(const Duration(seconds: 4));

    try {
      final userSharedPrefs = serviceLocator<UserSharedPrefs>();

      // Check if user is properly logged in with valid credentials
      final isLoggedIn = await userSharedPrefs.isUserLoggedIn();

      if (isLoggedIn) {
        // Additional validation: Check if token is still valid
        final token = await _validateToken();
        if (token) {
          print(
            '✅ SplashViewModel: User is properly authenticated, navigating to home',
          );
          emit(SplashState.navigateToHome);
        } else {
          print(
            '❌ SplashViewModel: Token validation failed, clearing user data and navigating to login',
          );
          await _clearInvalidUserData();
          emit(SplashState.navigateToLogin);
        }
      } else {
        print('❌ SplashViewModel: User not logged in, navigating to login');
        emit(SplashState.navigateToLogin);
      }
    } catch (e) {
      print('❌ SplashViewModel: Error during navigation decision: $e');
      // On error, clear any potentially corrupted data and go to login
      await _clearInvalidUserData();
      emit(SplashState.navigateToLogin);
    }
  }

  /// Validate if the stored token is still valid
  Future<bool> _validateToken() async {
    try {
      final userSharedPrefs = serviceLocator<UserSharedPrefs>();
      final token = userSharedPrefs.getCurrentUserId();

      if (token == null || token.isEmpty) {
        return false;
      }

      // You can add additional token validation here if needed
      // For now, we'll just check if the token exists and is not empty
      return true;
    } catch (e) {
      print('❌ SplashViewModel: Token validation error: $e');
      return false;
    }
  }

  /// Clear invalid user data
  Future<void> _clearInvalidUserData() async {
    try {
      final userSharedPrefs = serviceLocator<UserSharedPrefs>();
      await userSharedPrefs.clearUserData();
      print('✅ SplashViewModel: Invalid user data cleared');
    } catch (e) {
      print('❌ SplashViewModel: Error clearing user data: $e');
    }
  }
}
