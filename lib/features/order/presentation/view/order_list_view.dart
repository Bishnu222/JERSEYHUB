import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jerseyhub/features/order/presentation/viewmodel/order_viewmodel.dart';
import 'package:jerseyhub/features/order/presentation/widgets/order_card_widget.dart';
import 'package:jerseyhub/app/shared_prefs/user_shared_prefs.dart';
import 'package:jerseyhub/app/service_locator/service_locator.dart';

class OrderListView extends StatefulWidget {
  final VoidCallback? onShopNowPressed;

  const OrderListView({super.key, this.onShopNowPressed});

  @override
  State<OrderListView> createState() => _OrderListViewState();
}

class _OrderListViewState extends State<OrderListView>
    with WidgetsBindingObserver {
  late final UserSharedPrefs _userSharedPrefs;

  @override
  void initState() {
    super.initState();
    _userSharedPrefs = serviceLocator<UserSharedPrefs>();
    WidgetsBinding.instance.addObserver(this);
    // Do not call _loadOrders here if it uses ScaffoldMessenger
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadOrders();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print('🔄 App resumed, refreshing orders');
      _loadOrders();
    }
  }

  void _loadOrders() {
    final userId = _userSharedPrefs.getCurrentUserId();
    print('🔍 OrderListView: Loading orders for user ID: $userId');

    if (userId != null && userId.isNotEmpty && userId != 'unknown_user') {
      print(
        '🔍 OrderListView: Dispatching LoadAllOrdersEvent for authenticated user',
      );
      try {
        context.read<OrderViewModel>().add(const LoadAllOrdersEvent());
      } catch (e) {
        print('❌ OrderListView: Error dispatching LoadAllOrdersEvent: $e');
      }
    } else {
      print('❌ OrderListView: No valid user ID found!');
      // Show a user-friendly message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to view your orders'),
            backgroundColor: Colors.orange,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).primaryColor,
            child: Row(
              children: [
                const Text(
                  'My Orders',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    print('🔄 Manual refresh triggered');
                    _loadOrders();
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white),
                ),
              ],
            ),
          ),
          // Orders content
          Expanded(
            child: BlocListener<OrderViewModel, OrderState>(
              listener: (context, state) {
                if (state is OrdersLoaded) {
                  print(
                    '🔍 OrderListView: Orders loaded successfully. Count: ${state.orders.length}',
                  );
                  for (var order in state.orders) {
                    print(
                      '🔍 OrderListView: Order ID: ${order.id}, Status: ${order.status}, Total: ${order.totalAmount}',
                    );
                  }
                } else if (state is OrderError) {
                  print(
                    '❌ OrderListView: Error loading orders: ${state.message}',
                  );
                }
              },
              child: BlocBuilder<OrderViewModel, OrderState>(
                builder: (context, state) {
                  if (state is OrderLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is OrdersLoaded) {
                    if (state.orders.isEmpty) {
                      return _buildEmptyOrders();
                    }
                    return _buildOrdersList(state.orders);
                  } else if (state is OrderError) {
                    return _buildErrorState(state.message);
                  } else if (state is OrderDeleted) {
                    // Reload orders after deletion
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _loadOrders();
                    });
                    return const Center(child: CircularProgressIndicator());
                  }
                  return const Center(child: Text('No orders found'));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrders() {
    final userId = _userSharedPrefs.getCurrentUserId();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Debug indicator
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: Text(
              'DEBUG: User ID = $userId',
              style: TextStyle(
                color: Colors.blue[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Orders Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your order history will appear here',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Call the callback to switch to home/products tab
              widget.onShopNowPressed?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Shop Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<dynamic> orders) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadOrders();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OrderCardWidget(
              order: order,
              orderViewModel: context.read<OrderViewModel>(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error Loading Orders',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color:
                  Theme.of(context).textTheme.bodyLarge?.color ??
                  Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _loadOrders();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
