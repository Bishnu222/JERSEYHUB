import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class PaymentErrorHandler {
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static String handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';

      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';

      case DioExceptionType.badCertificate:
        return 'Security certificate error. Please try again.';

      case DioExceptionType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  static String _handleBadResponse(Response? response) {
    if (response == null) {
      return 'Server error. Please try again.';
    }

    switch (response.statusCode) {
      case 400:
        return 'Invalid request. Please check your payment details.';
      case 401:
        return 'Authentication failed. Please login again.';
      case 403:
        return 'Access denied. Please contact support.';
      case 404:
        return 'Payment service not found. Please try again later.';
      case 409:
        return 'Payment already exists. Please check your orders.';
      case 422:
        return 'Invalid payment data. Please check your information.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Payment service temporarily unavailable.';
      case 503:
        return 'Payment service is down for maintenance.';
      default:
        return 'Server error (${response.statusCode}). Please try again.';
    }
  }

  static String handlePaymentError(String error) {
    // Handle specific payment-related errors
    if (error.toLowerCase().contains('insufficient funds')) {
      return 'Insufficient funds in your account.';
    }
    if (error.toLowerCase().contains('invalid card')) {
      return 'Invalid payment method. Please try a different option.';
    }
    if (error.toLowerCase().contains('expired')) {
      return 'Payment method has expired. Please update your details.';
    }
    if (error.toLowerCase().contains('cancelled')) {
      return 'Payment was cancelled by user.';
    }
    if (error.toLowerCase().contains('timeout')) {
      return 'Payment timeout. Please try again.';
    }

    return error;
  }

  static void showRetryDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onRetry,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            if (onCancel != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onCancel();
                },
                child: const Text('Cancel'),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
          ],
        );
      },
    );
  }
}
