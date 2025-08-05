import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jerseyhub/features/payment/presentation/view/payment_view.dart';
import 'package:jerseyhub/features/payment/presentation/viewmodel/payment_viewmodel.dart';
import 'package:jerseyhub/features/payment/domain/entity/payment_entity.dart';
import 'package:jerseyhub/features/payment/presentation/utils/payment_validator.dart';
import 'package:jerseyhub/features/payment/presentation/constants/payment_constants.dart';

class MockPaymentViewModel extends Mock implements PaymentViewModel {}

void main() {
  group('PaymentView Tests', () {
    late MockPaymentViewModel mockPaymentViewModel;

    setUp(() {
      mockPaymentViewModel = MockPaymentViewModel();
    });

    Widget createTestWidget({
      String orderId = 'TEST123',
      double amount = 1000.0,
      String customerName = 'John Doe',
      String customerEmail = 'john@example.com',
    }) {
      return MaterialApp(
        home: BlocProvider<PaymentViewModel>.value(
          value: mockPaymentViewModel,
          child: PaymentView(
            orderId: orderId,
            amount: amount,
            customerName: customerName,
            customerEmail: customerEmail,
          ),
        ),
      );
    }

    group('Widget Rendering', () {
      testWidgets('should render payment summary correctly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Payment Summary'), findsOneWidget);
        expect(find.text('Order ID'), findsOneWidget);
        expect(find.text('TEST123'), findsOneWidget);
        expect(find.text('Amount'), findsOneWidget);
        expect(find.text('रू1000.00'), findsOneWidget);
        expect(find.text('Customer'), findsOneWidget);
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('john@example.com'), findsOneWidget);
      });

      testWidgets('should render payment methods correctly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Payment Method'), findsOneWidget);
        expect(find.text('eSewa'), findsOneWidget);
        expect(find.text('Cash on Delivery'), findsOneWidget);
      });

      testWidgets('should show eSewa as default selected payment method', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Pay with eSewa'), findsOneWidget);
      });
    });

    group('Payment Method Selection', () {
      testWidgets('should change payment method when tapped', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        // Initially eSewa should be selected
        expect(find.text('Pay with eSewa'), findsOneWidget);

        // Tap on Cash on Delivery
        await tester.tap(find.text('Cash on Delivery'));
        await tester.pump();

        // Button text should change
        expect(find.text('Place Order (Cash on Delivery)'), findsOneWidget);
      });
    });

    group('Payment Processing', () {
      testWidgets('should show loading state when processing payment', (
        WidgetTester tester,
      ) async {
        when(() => mockPaymentViewModel.state).thenReturn(PaymentLoading());

        await tester.pumpWidget(createTestWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should handle payment success', (WidgetTester tester) async {
        final successResponse = PaymentResponseEntity(
          success: true,
          paymentUrl: 'https://esewa.com.np/pay',
        );

        when(
          () => mockPaymentViewModel.state,
        ).thenReturn(PaymentCreated(response: successResponse));

        await tester.pumpWidget(createTestWidget());

        // Should show success dialog
        expect(find.text('Payment Successful!'), findsOneWidget);
      });

      testWidgets('should handle payment error', (WidgetTester tester) async {
        when(
          () => mockPaymentViewModel.state,
        ).thenReturn(const PaymentError(message: 'Payment failed'));

        await tester.pumpWidget(createTestWidget());

        // Should show error snackbar
        expect(find.text('Payment failed'), findsOneWidget);
      });
    });
  });

  group('PaymentValidator Tests', () {
    group('Order ID Validation', () {
      test('should return null for valid order ID', () {
        final result = PaymentValidator.validateOrderId('ORDER123');
        expect(result, isNull);
      });

      test('should return error for null order ID', () {
        final result = PaymentValidator.validateOrderId(null);
        expect(result, equals('Order ID is required'));
      });

      test('should return error for empty order ID', () {
        final result = PaymentValidator.validateOrderId('');
        expect(result, equals('Order ID is required'));
      });

      test('should return error for short order ID', () {
        final result = PaymentValidator.validateOrderId('AB');
        expect(result, equals('Order ID must be at least 3 characters'));
      });
    });

    group('Amount Validation', () {
      test('should return null for valid amount', () {
        final result = PaymentValidator.validateAmount(100.0);
        expect(result, isNull);
      });

      test('should return error for null amount', () {
        final result = PaymentValidator.validateAmount(null);
        expect(result, equals('Amount is required'));
      });

      test('should return error for zero amount', () {
        final result = PaymentValidator.validateAmount(0.0);
        expect(result, equals('Amount must be greater than 0'));
      });

      test('should return error for negative amount', () {
        final result = PaymentValidator.validateAmount(-10.0);
        expect(result, equals('Amount must be greater than 0'));
      });

      test('should return error for amount exceeding limit', () {
        final result = PaymentValidator.validateAmount(150000.0);
        expect(result, equals('Amount cannot exceed रू100,000'));
      });
    });

    group('Customer Name Validation', () {
      test('should return null for valid name', () {
        final result = PaymentValidator.validateCustomerName('John Doe');
        expect(result, isNull);
      });

      test('should return error for null name', () {
        final result = PaymentValidator.validateCustomerName(null);
        expect(result, equals('Customer name is required'));
      });

      test('should return error for empty name', () {
        final result = PaymentValidator.validateCustomerName('');
        expect(result, equals('Customer name is required'));
      });

      test('should return error for short name', () {
        final result = PaymentValidator.validateCustomerName('A');
        expect(result, equals('Customer name must be at least 2 characters'));
      });

      test('should return error for long name', () {
        final longName = 'A' * 51;
        final result = PaymentValidator.validateCustomerName(longName);
        expect(result, equals('Customer name cannot exceed 50 characters'));
      });
    });

    group('Email Validation', () {
      test('should return null for valid email', () {
        final result = PaymentValidator.validateCustomerEmail(
          'test@example.com',
        );
        expect(result, isNull);
      });

      test('should return error for null email', () {
        final result = PaymentValidator.validateCustomerEmail(null);
        expect(result, equals('Email is required'));
      });

      test('should return error for empty email', () {
        final result = PaymentValidator.validateCustomerEmail('');
        expect(result, equals('Email is required'));
      });

      test('should return error for invalid email format', () {
        final result = PaymentValidator.validateCustomerEmail('invalid-email');
        expect(result, equals('Please enter a valid email address'));
      });

      test('should return error for email without domain', () {
        final result = PaymentValidator.validateCustomerEmail('test@');
        expect(result, equals('Please enter a valid email address'));
      });
    });

    group('Complete Validation', () {
      test('should return valid for all correct inputs', () {
        final results = PaymentValidator.validatePaymentRequest(
          orderId: 'ORDER123',
          amount: 100.0,
          customerName: 'John Doe',
          customerEmail: 'john@example.com',
        );

        expect(PaymentValidator.isPaymentRequestValid(results), isTrue);
      });

      test('should return invalid for any incorrect input', () {
        final results = PaymentValidator.validatePaymentRequest(
          orderId: 'OR', // Too short
          amount: 100.0,
          customerName: 'John Doe',
          customerEmail: 'john@example.com',
        );

        expect(PaymentValidator.isPaymentRequestValid(results), isFalse);
        expect(
          PaymentValidator.getFirstValidationError(results),
          equals('Order ID must be at least 3 characters'),
        );
      });
    });
  });

  group('PaymentConstants Tests', () {
    test('should have correct currency symbol', () {
      expect(PaymentConstants.currencySymbol, equals('रू'));
    });

    test('should have correct payment method names', () {
      expect(PaymentConstants.esewaDisplayName, equals('eSewa'));
      expect(
        PaymentConstants.cashOnDeliveryDisplayName,
        equals('Cash on Delivery'),
      );
    });

    test('should have reasonable payment limits', () {
      expect(PaymentConstants.maxPaymentAmount, equals(100000.0));
      expect(PaymentConstants.minPaymentAmount, equals(0.01));
    });

    test('should have reasonable validation limits', () {
      expect(PaymentConstants.minOrderIdLength, equals(3));
      expect(PaymentConstants.minCustomerNameLength, equals(2));
      expect(PaymentConstants.maxCustomerNameLength, equals(50));
    });
  });
}
