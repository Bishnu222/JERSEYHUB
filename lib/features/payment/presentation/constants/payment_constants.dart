class PaymentConstants {
  // UI Constants
  static const double cardElevation = 2.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double iconSize = 24.0;
  static const double largeIconSize = 32.0;
  static const double buttonHeight = 56.0;
  static const double padding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Text Sizes
  static const double titleFontSize = 18.0;
  static const double largeTitleFontSize = 24.0;
  static const double extraLargeTitleFontSize = 28.0;
  static const double bodyFontSize = 16.0;
  static const double smallFontSize = 14.0;
  static const double extraSmallFontSize = 12.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(seconds: 2);
  static const Duration longAnimation = Duration(seconds: 3);

  // Payment Limits
  static const double maxPaymentAmount = 100000.0;
  static const double minPaymentAmount = 0.01;

  // Validation Limits
  static const int minOrderIdLength = 3;
  static const int minCustomerNameLength = 2;
  static const int maxCustomerNameLength = 50;

  // Currency
  static const String currencySymbol = 'रू';
  static const String currencyCode = 'NPR';

  // Payment Methods
  static const String esewaDisplayName = 'eSewa';
  static const String cashOnDeliveryDisplayName = 'Cash on Delivery';
  static const String esewaDescription =
      'Pay securely with eSewa - Nepal\'s leading digital wallet';
  static const String cashOnDeliveryDescription =
      'Pay when you receive your order';

  // Messages
  static const String paymentProcessingMessage = 'Processing payment...';
  static const String orderProcessingMessage = 'Processing your order...';
  static const String paymentSuccessMessage = 'Payment Successful!';
  static const String orderSuccessMessage = 'Order Placed Successfully!';
  static const String paymentUrlCopiedMessage =
      'Payment URL copied to clipboard';
  static const String orderCreatedMessage =
      'Order created successfully! Check your Orders tab.';

  // Error Messages
  static const String validationError = 'Please check your input and try again';
  static const String networkError =
      'Network error. Please check your connection';
  static const String paymentFailedError = 'Payment failed. Please try again';
  static const String orderCreationFailedError =
      'Failed to create order. Please try again.';

  // URLs
  static const String esewaUrlPattern = 'esewa.com.np';
  static const String esewaUrlPatternAlt = 'esewa';
}
