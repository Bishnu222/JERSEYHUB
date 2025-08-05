import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jerseyhub/app/shared_prefs/user_shared_prefs.dart';
import 'package:jerseyhub/app/shared_prefs/token_shared_prefs.dart';

void main() {
  group('Authentication Flow Tests', () {
    late SharedPreferences prefs;
    late UserSharedPrefs userSharedPrefs;
    late TokenSharedPrefs tokenSharedPrefs;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      userSharedPrefs = UserSharedPrefs(prefs);
      tokenSharedPrefs = TokenSharedPrefs(sharedPreferences: prefs);
    });

    test('should properly validate user login state', () async {
      // Initially should not be logged in
      final initialLoginState = await userSharedPrefs.isUserLoggedIn();
      expect(initialLoginState, false);

      // Set up valid user data
      await userSharedPrefs.setCurrentUserId('test_user_id');
      await userSharedPrefs.setCurrentUserEmail('test@example.com');
      await tokenSharedPrefs.saveToken('valid_token_123');

      // Should now be logged in
      final loggedInState = await userSharedPrefs.isUserLoggedIn();
      expect(loggedInState, true);

      // Clear user data
      await userSharedPrefs.clearUserData();

      // Should not be logged in after clearing
      final afterClearState = await userSharedPrefs.isUserLoggedIn();
      expect(afterClearState, false);
    });

    test('should handle invalid user data correctly', () async {
      // Set invalid user data
      await userSharedPrefs.setCurrentUserId('unknown_user');
      await tokenSharedPrefs.saveToken('valid_token_123');

      // Should not be logged in with unknown_user
      final loginState = await userSharedPrefs.isUserLoggedIn();
      expect(loginState, false);

      // Set valid user ID but no token
      await userSharedPrefs.setCurrentUserId('valid_user_id');
      await tokenSharedPrefs.clearToken();

      // Should not be logged in without token
      final noTokenState = await userSharedPrefs.isUserLoggedIn();
      expect(noTokenState, false);
    });
  });
}
