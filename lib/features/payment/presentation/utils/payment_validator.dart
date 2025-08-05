class PaymentValidator {
  static String? validateOrderId(String? orderId) {
    if (orderId == null || orderId.trim().isEmpty) {
      return 'Order ID is required';
    }
    if (orderId.length < 3) {
      return 'Order ID must be at least 3 characters';
    }
    return null;
  }

  static String? validateAmount(double? amount) {
    if (amount == null) {
      return 'Amount is required';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    if (amount > 100000) {
      return 'Amount cannot exceed रू100,000';
    }
    return null;
  }

  static String? validateCustomerName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Customer name is required';
    }
    if (name.trim().length < 2) {
      return 'Customer name must be at least 2 characters';
    }
    if (name.trim().length > 50) {
      return 'Customer name cannot exceed 50 characters';
    }
    return null;
  }

  static String? validateCustomerEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static Map<String, String?> validatePaymentRequest({
    required String orderId,
    required double amount,
    required String customerName,
    required String customerEmail,
  }) {
    return {
      'orderId': validateOrderId(orderId),
      'amount': validateAmount(amount),
      'customerName': validateCustomerName(customerName),
      'customerEmail': validateCustomerEmail(customerEmail),
    };
  }

  static bool isPaymentRequestValid(Map<String, String?> validationResults) {
    return validationResults.values.every((error) => error == null);
  }

  static String getFirstValidationError(
    Map<String, String?> validationResults,
  ) {
    final firstError = validationResults.values.firstWhere(
      (error) => error != null,
      orElse: () => null,
    );
    return firstError ?? 'Unknown validation error';
  }
}
