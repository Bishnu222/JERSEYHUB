import 'package:dio/dio.dart';
import 'package:jerseyhub/app/constant/backend_config.dart';
import 'package:jerseyhub/app/shared_prefs/user_shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:jerseyhub/app/service_locator/service_locator.dart';
import 'package:jerseyhub/features/notification/domain/use_case/add_notification_usecase.dart';
import 'package:jerseyhub/features/notification/domain/entity/notification_entity.dart';
import 'package:jerseyhub/features/notification/presentation/bloc/notification_bloc.dart';

class CartNotificationService {
  final Dio _dio;
  final UserSharedPrefs _userSharedPrefs;
  final GlobalKey<ScaffoldMessengerState>? _scaffoldMessengerKey;
  late final AddNotificationUseCase _addNotificationUseCase;

  CartNotificationService({
    required Dio dio,
    required UserSharedPrefs userSharedPrefs,
    GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey,
  }) : _dio = dio,
       _userSharedPrefs = userSharedPrefs,
       _scaffoldMessengerKey = scaffoldMessengerKey {
    _addNotificationUseCase = serviceLocator<AddNotificationUseCase>();
  }

  /// Refresh notifications in the notification page
  void _refreshNotifications(String userId) {
    try {
      final notificationBloc = serviceLocator<NotificationBloc>();
      notificationBloc.add(RefreshNotifications(userId));
      print(
        '🔔 CartNotificationService: Triggered notification refresh for user: $userId',
      );
    } catch (e) {
      print('❌ CartNotificationService: Failed to refresh notifications: $e');
    }
  }

  /// Send notification when item is added to cart
  Future<void> sendAddToCartNotification({
    required String productName,
    required int quantity,
  }) async {
    try {
      final userId = _userSharedPrefs.getCurrentUserId();
      print('🔍 CartNotificationService: Current user ID: $userId');

      if (userId == null) {
        print('❌ CartNotificationService: No user ID found');
        return;
      }

      // Create notification entity
      final notification = NotificationEntity(
        id: 'cart_add_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        message: '$productName (Qty: $quantity) has been added to your cart',
        read: false,
        type: 'cart_add',
        metadata: {
          'productName': productName,
          'quantity': quantity,
          'action': 'add_to_cart',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Store notification locally
      final result = await _addNotificationUseCase(notification);
      result.fold(
        (failure) {
          print(
            '❌ CartNotificationService: Failed to store notification: ${failure.message}',
          );
        },
        (storedNotification) {
          print('✅ CartNotificationService: Notification stored successfully');
        },
      );

      // Refresh notifications
      _refreshNotifications(userId);

      // Show local notification if backend is disabled
      if (!BackendConfig.enableBackend) {
        _showLocalNotification(
          title: 'Added to Cart! 🛒',
          message: '$productName (Qty: $quantity) has been added to your cart',
          backgroundColor: Colors.green,
          icon: Icons.shopping_cart,
        );
        print(
          '📱 CartNotificationService: Local notification shown for add to cart',
        );
        return;
      }

      print('🔍 CartNotificationService: Sending notification to backend...');
      final response = await _dio.post(
        '${BackendConfig.baseUrl}cart/add-notification',
        data: {
          'userId': userId,
          'productName': productName,
          'quantity': quantity,
        },
      );
      print(
        '✅ CartNotificationService: Add to cart notification sent successfully',
      );
      print('🔍 CartNotificationService: Backend response: ${response.data}');
    } catch (e) {
      print(
        '❌ CartNotificationService: Failed to send add to cart notification: $e',
      );
      // Show local notification as fallback
      _showLocalNotification(
        title: 'Added to Cart! 🛒',
        message: '$productName (Qty: $quantity) has been added to your cart',
        backgroundColor: Colors.green,
        icon: Icons.shopping_cart,
      );
    }
  }

  /// Send notification when item is removed from cart
  Future<void> sendRemoveFromCartNotification({
    required String productName,
    required int quantity,
  }) async {
    try {
      final userId = _userSharedPrefs.getCurrentUserId();
      if (userId == null) {
        print('❌ CartNotificationService: No user ID found');
        return;
      }

      // Create notification entity
      final notification = NotificationEntity(
        id: 'cart_remove_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        message:
            '$productName (Qty: $quantity) has been removed from your cart',
        read: false,
        type: 'cart_remove',
        metadata: {
          'productName': productName,
          'quantity': quantity,
          'action': 'remove_from_cart',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Store notification locally
      final result = await _addNotificationUseCase(notification);
      result.fold(
        (failure) {
          print(
            '❌ CartNotificationService: Failed to store notification: ${failure.message}',
          );
        },
        (storedNotification) {
          print('✅ CartNotificationService: Notification stored successfully');
        },
      );

      // Refresh notifications
      _refreshNotifications(userId);

      // Show local notification if backend is disabled
      if (!BackendConfig.enableBackend) {
        _showLocalNotification(
          title: 'Removed from Cart! 🗑️',
          message:
              '$productName (Qty: $quantity) has been removed from your cart',
          backgroundColor: Colors.orange,
          icon: Icons.remove_shopping_cart,
        );
        print(
          '📱 CartNotificationService: Local notification shown for remove from cart',
        );
        return;
      }

      await _dio.post(
        '${BackendConfig.baseUrl}cart/remove-notification',
        data: {
          'userId': userId,
          'productName': productName,
          'quantity': quantity,
        },
      );
      print('✅ CartNotificationService: Remove from cart notification sent');
    } catch (e) {
      print(
        '❌ CartNotificationService: Failed to send remove from cart notification: $e',
      );
      // Show local notification as fallback
      _showLocalNotification(
        title: 'Removed from Cart! 🗑️',
        message:
            '$productName (Qty: $quantity) has been removed from your cart',
        backgroundColor: Colors.orange,
        icon: Icons.remove_shopping_cart,
      );
    }
  }

  /// Send cart reminder notification
  Future<void> sendCartReminderNotification({required int itemCount}) async {
    try {
      final userId = _userSharedPrefs.getCurrentUserId();
      if (userId == null) {
        print('❌ CartNotificationService: No user ID found');
        return;
      }

      // Create notification entity
      final notification = NotificationEntity(
        id: 'cart_reminder_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        message: 'You have $itemCount items in your cart. Ready to checkout?',
        read: false,
        type: 'cart_reminder',
        metadata: {'itemCount': itemCount, 'action': 'cart_reminder'},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Store notification locally
      final result = await _addNotificationUseCase(notification);
      result.fold(
        (failure) {
          print(
            '❌ CartNotificationService: Failed to store notification: ${failure.message}',
          );
        },
        (storedNotification) {
          print('✅ CartNotificationService: Notification stored successfully');
        },
      );

      // Refresh notifications
      _refreshNotifications(userId);

      // Show local notification if backend is disabled
      if (!BackendConfig.enableBackend) {
        _showLocalNotification(
          title: 'Cart Reminder! 📝',
          message: 'You have $itemCount items in your cart. Ready to checkout?',
          backgroundColor: Colors.blue,
          icon: Icons.shopping_basket,
        );
        print(
          '📱 CartNotificationService: Local notification shown for cart reminder',
        );
        return;
      }

      await _dio.post(
        '${BackendConfig.baseUrl}cart/reminder-notification',
        data: {'userId': userId, 'itemCount': itemCount},
      );
      print('✅ CartNotificationService: Cart reminder notification sent');
    } catch (e) {
      print(
        '❌ CartNotificationService: Failed to send cart reminder notification: $e',
      );
      // Show local notification as fallback
      _showLocalNotification(
        title: 'Cart Reminder! 📝',
        message: 'You have $itemCount items in your cart. Ready to checkout?',
        backgroundColor: Colors.blue,
        icon: Icons.shopping_basket,
      );
    }
  }

  /// Send cart total update notification
  Future<void> sendCartTotalUpdateNotification({
    required double oldTotal,
    required double newTotal,
    String? changeReason,
  }) async {
    try {
      final userId = _userSharedPrefs.getCurrentUserId();
      if (userId == null) {
        print('❌ CartNotificationService: No user ID found');
        return;
      }

      final changeText = changeReason ?? 'Cart updated';
      final message =
          '$changeText: Total changed from रू${oldTotal.toStringAsFixed(2)} to रू${newTotal.toStringAsFixed(2)}';

      // Create notification entity
      final notification = NotificationEntity(
        id: 'cart_update_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        message: message,
        read: false,
        type: 'cart_update',
        metadata: {
          'oldTotal': oldTotal,
          'newTotal': newTotal,
          'changeReason': changeReason,
          'action': 'cart_update',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Store notification locally
      final result = await _addNotificationUseCase(notification);
      result.fold(
        (failure) {
          print(
            '❌ CartNotificationService: Failed to store notification: ${failure.message}',
          );
        },
        (storedNotification) {
          print('✅ CartNotificationService: Notification stored successfully');
        },
      );

      // Refresh notifications
      _refreshNotifications(userId);

      // Show local notification if backend is disabled
      if (!BackendConfig.enableBackend) {
        _showLocalNotification(
          title: 'Cart Updated! 💰',
          message: message,
          backgroundColor: Colors.purple,
          icon: Icons.account_balance_wallet,
        );
        print(
          '📱 CartNotificationService: Local notification shown for cart total update',
        );
        return;
      }

      await _dio.post(
        '${BackendConfig.baseUrl}cart/total-update-notification',
        data: {
          'userId': userId,
          'oldTotal': oldTotal,
          'newTotal': newTotal,
          'changeReason': changeReason,
        },
      );
      print('✅ CartNotificationService: Cart total update notification sent');
    } catch (e) {
      print(
        '❌ CartNotificationService: Failed to send cart total update notification: $e',
      );
      // Show local notification as fallback
      final changeText = changeReason ?? 'Cart updated';
      _showLocalNotification(
        title: 'Cart Updated! 💰',
        message:
            '$changeText: Total changed from रू${oldTotal.toStringAsFixed(2)} to रू${newTotal.toStringAsFixed(2)}',
        backgroundColor: Colors.purple,
        icon: Icons.account_balance_wallet,
      );
    }
  }

  /// Show local notification using SnackBar
  void _showLocalNotification({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    if (_scaffoldMessengerKey?.currentState != null) {
      _scaffoldMessengerKey!.currentState!.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(message, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(8),
        ),
      );
    } else {
      print(
        '⚠️ CartNotificationService: ScaffoldMessenger not available for notification',
      );
    }
  }
}
