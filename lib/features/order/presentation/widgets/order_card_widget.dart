import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jerseyhub/app/service_locator/service_locator.dart';
import 'package:jerseyhub/features/order/domain/entity/order_entity.dart';
import 'package:jerseyhub/features/order/presentation/view/order_detail_view.dart';
import 'package:jerseyhub/features/order/presentation/viewmodel/order_viewmodel.dart';

class OrderCardWidget extends StatefulWidget {
  final OrderEntity order;
  final OrderViewModel orderViewModel;

  const OrderCardWidget({
    super.key,
    required this.order,
    required this.orderViewModel,
  });

  @override
  State<OrderCardWidget> createState() => _OrderCardWidgetState();
}

class _OrderCardWidgetState extends State<OrderCardWidget> {
  @override
  Widget build(BuildContext context) {
    print(
      '🛒 OrderCardWidget: Building order card for order ID: ${widget.order.id}',
    );
    print('🛒 OrderCardWidget: Order has ${widget.order.items.length} items');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => serviceLocator<OrderViewModel>(),
                child: OrderDetailView(orderId: widget.order.id),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${widget.order.id.length > 8 ? widget.order.id.substring(widget.order.id.length - 8) : widget.order.id}',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          Theme.of(context).textTheme.bodyMedium?.color ??
                          Colors.grey[600],
                    ),
                  ),
                  Row(
                    children: [
                      _buildStatusChip(widget.order.status),
                      const SizedBox(width: 8),
                      _buildDeleteButton(context),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(widget.order.createdAt),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.shopping_bag, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.order.itemCount} items',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    'रू${widget.order.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (status) {
      case OrderStatus.pending:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        statusText = 'Pending';
        break;
      case OrderStatus.confirmed:
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        statusText = 'Confirmed';
        break;
      case OrderStatus.processing:
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[800]!;
        statusText = 'Processing';
        break;
      case OrderStatus.shipped:
        backgroundColor = Colors.indigo[100]!;
        textColor = Colors.indigo[800]!;
        statusText = 'Shipped';
        break;
      case OrderStatus.delivered:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        statusText = 'Delivered';
        break;
      case OrderStatus.cancelled:
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        statusText = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildDeleteButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDeleteConfirmation(context),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.delete_outline, size: 20, color: Colors.red[600]),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Order',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete order #${widget.order.id.length > 8 ? widget.order.id.substring(0, 8) : widget.order.id}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteOrder(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteOrder(BuildContext context) {
    widget.orderViewModel.add(DeleteOrderEvent(orderId: widget.order.id));

    // Show success message only if widget is still mounted
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order #${widget.order.id.length > 8 ? widget.order.id.substring(0, 8) : widget.order.id} deleted successfully',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
