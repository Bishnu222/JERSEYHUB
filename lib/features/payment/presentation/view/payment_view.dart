import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jerseyhub/features/payment/domain/entity/payment_entity.dart';
import 'package:jerseyhub/features/payment/presentation/viewmodel/payment_viewmodel.dart';
import 'package:jerseyhub/features/cart/presentation/viewmodel/cart_viewmodel.dart';
import 'package:jerseyhub/app/service_locator/service_locator.dart';
import 'package:jerseyhub/app/shared_prefs/user_shared_prefs.dart';
import 'package:jerseyhub/features/home/presentation/view/home_page.dart';
import 'package:jerseyhub/features/home/presentation/viewmodel/homepage_viewmodel.dart';

class PaymentView extends StatefulWidget {
  final String orderId;
  final double amount;
  final String customerName;
  final String customerEmail;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentFailure;

  const PaymentView({
    super.key,
    required this.orderId,
    required this.amount,
    required this.customerName,
    required this.customerEmail,
    this.onPaymentSuccess,
    this.onPaymentFailure,
  });

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  PaymentMethod _selectedMethod = PaymentMethod.esewa;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // If user presses back button, return false to indicate payment was not completed
        Navigator.of(context).pop(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocListener<PaymentViewModel, PaymentState>(
          listener: (context, state) {
            if (state is PaymentCreated) {
              _handlePaymentCreated(state.response);
            } else if (state is PaymentError) {
              _showErrorSnackBar(state.message);
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderSummary(),
                const SizedBox(height: 24),
                _buildPaymentMethods(),
                const SizedBox(height: 24),
                _buildPaymentButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Order ID', widget.orderId),
            _buildSummaryRow('Amount', 'रू${widget.amount.toStringAsFixed(2)}'),
            _buildSummaryRow('Customer', widget.customerName),
            _buildSummaryRow('Email', widget.customerEmail),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPaymentMethodTile(
              PaymentMethod.esewa,
              'eSewa',
              'Pay securely with eSewa - Nepal\'s leading digital wallet',
              Icons.payment,
            ),
            const SizedBox(height: 8),
            _buildPaymentMethodTile(
              PaymentMethod.cashOnDelivery,
              'Cash on Delivery',
              'Pay when you receive your order',
              Icons.money,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile(
    PaymentMethod method,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedMethod == method;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton() {
    return BlocBuilder<PaymentViewModel, PaymentState>(
      builder: (context, state) {
        final isLoading = state is PaymentLoading;

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _getPaymentButtonText(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }

  String _getPaymentButtonText() {
    switch (_selectedMethod) {
      case PaymentMethod.esewa:
        return 'Pay with eSewa';
      case PaymentMethod.cashOnDelivery:
        return 'Place Order (Cash on Delivery)';
    }
  }

  void _processPayment() {
    switch (_selectedMethod) {
      case PaymentMethod.esewa:
        _processEsewaPayment();
        break;
      case PaymentMethod.cashOnDelivery:
        _processCashOnDelivery();
        break;
    }
  }

  void _processEsewaPayment() {
    print('💳 Processing eSewa payment...');
    print('📋 Order ID: ${widget.orderId}');
    print('💰 Amount: रू${widget.amount.toStringAsFixed(2)}');
    print('👤 Customer: ${widget.customerName}');
    print('📧 Email: ${widget.customerEmail}');

    // Show processing message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Initializing eSewa payment...'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );

    final request = PaymentRequestEntity(
      orderId: widget.orderId,
      amount: widget.amount,
      customerName: widget.customerName,
      customerEmail: widget.customerEmail,
      method: PaymentMethod.esewa,
    );

    print('🚀 Dispatching CreatePaymentEvent...');
    context.read<PaymentViewModel>().add(CreatePaymentEvent(request: request));
  }

  void _processCashOnDelivery() {
    print('💳 PaymentView: Processing Cash on Delivery payment');
    print('💳 PaymentView: Order ID: ${widget.orderId}');
    print('💳 PaymentView: Amount: ${widget.amount}');
    print('💳 PaymentView: Customer: ${widget.customerName}');
    print('💳 PaymentView: Email: ${widget.customerEmail}');

    // Show confirmation dialog for cash on delivery
    _showCashOnDeliveryConfirmation();
  }

  void _showCashOnDeliveryConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.money, color: Colors.orange, size: 32),
                    const SizedBox(width: 12),
                    const Text(
                      'Cash on Delivery',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Order Amount
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Order Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'रू${widget.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Important Information
                const Text(
                  'Important Information:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('• Pay when you receive your order'),
                _buildInfoRow('• Keep exact change ready'),
                _buildInfoRow('• Delivery within 3-5 business days'),
                _buildInfoRow('• Free delivery on orders above रू1000'),
                const SizedBox(height: 20),

                // Warning Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300, width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Please ensure you have the exact amount ready when the delivery person arrives.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _confirmCashOnDelivery();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          'Confirm Order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _confirmCashOnDelivery() {
    // Show processing message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Processing your order...'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );

    // Simulate order processing
    Future.delayed(const Duration(seconds: 2), () {
      _showCashOnDeliverySuccessDialog();
    });
  }

  void _showCashOnDeliverySuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 50),
                ),
                const SizedBox(height: 24),

                // Success Title
                const Text(
                  'Order Placed Successfully!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Order Amount
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Order Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'रू${widget.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Order ID
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    'Order ID: ${widget.orderId}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),

                // Important Message
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300, width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You will receive a confirmation call within 24 hours. Please keep रू${widget.amount.toStringAsFixed(2)} ready for delivery.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // OK Button - Navigate to Home Page
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        true,
                      ); // Close dialog (return true to indicate success)
                      widget.onPaymentSuccess
                          ?.call(); // Trigger order creation in CheckoutView
                      _navigateToHomeDirectly(); // Navigate to home after order creation is handled by CheckoutView
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Go to Home',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handlePaymentCreated(PaymentResponseEntity response) {
    if (response.success && response.paymentUrl != null) {
      _launchPaymentUrl(response.paymentUrl!);
    } else {
      _showErrorSnackBar(response.error ?? 'Payment creation failed');
    }
  }

  Future<void> _launchPaymentUrl(String url) async {
    try {
      print('🌐 Processing eSewa payment...');

      // Check if it's an eSewa URL
      final isEsewaUrl = url.contains('esewa.com.np') || url.contains('esewa');

      if (isEsewaUrl) {
        // Show processing message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Processing eSewa payment...'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );

        // Simulate payment processing
        await Future.delayed(const Duration(seconds: 3));

        // Show success dialog
        _showPaymentSuccessDialog();
      } else {
        // For non-eSewa payments, try to launch the URL
        final uri = Uri.parse(url);
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (launched) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment page opened successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          _showUrlDialog(url);
        }
      }
    } catch (e) {
      print('💥 Error processing payment: $e');
      _showUrlDialog(url);
    }
  }

  void _showErrorSnackBar(String message) {
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

  void _showUrlDialog(String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Payment URL'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please copy this URL and open it in your browser to complete the payment:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SelectableText(
                  url,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await Clipboard.setData(ClipboardData(text: url));
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment URL copied to clipboard'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  _showErrorSnackBar('Failed to copy URL: $e');
                }
              },
              child: const Text('Copy URL'),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your payment of रू${widget.amount.toStringAsFixed(2)} has been processed successfully.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Order ID: ${widget.orderId}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Text(
                  'Your order will be processed and you will receive a confirmation shortly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Close dialog and navigate directly to home
                Navigator.of(context).pop(); // Close dialog
                widget.onPaymentSuccess
                    ?.call(); // Trigger order creation in CheckoutView
                _navigateToHomeDirectly(); // Navigate to home after order creation is handled by CheckoutView
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Go to Home'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToHomeDirectly() async {
    // Clear the cart first
    final userSharedPrefs = serviceLocator<UserSharedPrefs>();
    final userId = userSharedPrefs.getCurrentUserId();
    if (userId != null) {
      final cartViewModel = serviceLocator<CartViewModel>();
      cartViewModel.add(PaymentCompletedEvent());
    }

    // Navigate directly to home page by replacing all routes with home page
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => serviceLocator<HomeViewModel>(),
          child: const HomePage(),
        ),
      ),
      (route) => false, // Remove all routes
    );
  }
}
