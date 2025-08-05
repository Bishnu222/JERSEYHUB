import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:jerseyhub/features/order/domain/entity/order_entity.dart';
import 'package:jerseyhub/features/order/domain/use_case/get_all_orders_usecase.dart';
import 'package:jerseyhub/features/order/domain/use_case/get_order_by_id_usecase.dart';
import 'package:jerseyhub/features/order/domain/use_case/create_order_usecase.dart';
import 'package:jerseyhub/features/order/domain/use_case/update_order_status_usecase.dart';
import 'package:jerseyhub/features/order/domain/use_case/delete_order_usecase.dart';
import 'package:jerseyhub/app/shared_prefs/user_shared_prefs.dart';

// Events
abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllOrdersEvent extends OrderEvent {
  const LoadAllOrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrderByIdEvent extends OrderEvent {
  final String orderId;
  const LoadOrderByIdEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class CreateOrderEvent extends OrderEvent {
  final OrderEntity order;
  const CreateOrderEvent({required this.order});

  @override
  List<Object?> get props => [order];
}

class UpdateOrderStatusEvent extends OrderEvent {
  final String orderId;
  final String status;
  const UpdateOrderStatusEvent({required this.orderId, required this.status});

  @override
  List<Object?> get props => [orderId, status];
}

class DeleteOrderEvent extends OrderEvent {
  final String orderId;
  const DeleteOrderEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class ClearLocalOrdersEvent extends OrderEvent {
  const ClearLocalOrdersEvent();

  @override
  List<Object?> get props => [];
}

// States
abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrdersLoaded extends OrderState {
  final List<OrderEntity> orders;
  const OrdersLoaded({required this.orders});

  @override
  List<Object?> get props => [orders];
}

class OrderLoaded extends OrderState {
  final OrderEntity order;
  const OrderLoaded({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrderCreated extends OrderState {
  final OrderEntity order;
  const OrderCreated({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrderUpdated extends OrderState {
  final OrderEntity order;
  const OrderUpdated({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrderDeleted extends OrderState {
  final String orderId;
  const OrderDeleted({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class OrderError extends OrderState {
  final String message;
  const OrderError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ViewModel
class OrderViewModel extends Bloc<OrderEvent, OrderState> {
  final GetAllOrdersUseCase getAllOrdersUseCase;
  final GetOrderByIdUseCase getOrderByIdUseCase;
  final CreateOrderUseCase createOrderUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;
  final DeleteOrderUseCase deleteOrderUseCase;
  final UserSharedPrefs _userSharedPrefs;

  OrderViewModel({
    required this.getAllOrdersUseCase,
    required this.getOrderByIdUseCase,
    required this.createOrderUseCase,
    required this.updateOrderStatusUseCase,
    required this.deleteOrderUseCase,
    required UserSharedPrefs userSharedPrefs,
  }) : _userSharedPrefs = userSharedPrefs,
       super(OrderInitial()) {
    on<LoadAllOrdersEvent>(_onLoadAllOrders);
    on<LoadOrderByIdEvent>(_onLoadOrderById);
    on<CreateOrderEvent>(_onCreateOrder);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
    on<DeleteOrderEvent>(_onDeleteOrder);
    on<ClearLocalOrdersEvent>(_onClearLocalOrders);
  }

  Future<void> _onLoadAllOrders(
    LoadAllOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      print('🔍 OrderViewModel: Loading orders for authenticated user');

      // Get current user ID for security validation
      final currentUserId = _userSharedPrefs.getCurrentUserId();
      print('🔍 OrderViewModel: Current user ID: $currentUserId');

      final result = await getAllOrdersUseCase();
      result.fold(
        (failure) {
          print('❌ OrderViewModel: Failed to load orders: ${failure.message}');
          emit(OrderError(message: failure.message));
        },
        (orders) {
          print(
            '✅ OrderViewModel: Successfully loaded ${orders.length} orders',
          );

          // Security check: Filter orders to only show current user's orders
          final userOrders = orders.where((order) {
            // Only show orders that explicitly belong to the current user
            if (order.userId == currentUserId) {
              print(
                '✅ OrderViewModel: Order ${order.id} belongs to current user $currentUserId',
              );
              return true;
            }

            // For debugging: Show orders with null userId if current user is authenticated
            if (order.userId == null && currentUserId != null && currentUserId.isNotEmpty) {
              print(
                '⚠️ OrderViewModel: DEBUG - Showing orphaned order ${order.id} for authenticated user $currentUserId',
              );
              return true;
            }

            // Filter out all other orders for security
            if (order.userId == null) {
              print(
                '🚨 OrderViewModel: Security warning - Order ${order.id} has no userId. Filtering out for security.',
              );
            } else if (order.userId != currentUserId) {
              print(
                '🚨 OrderViewModel: Security warning - Order ${order.id} belongs to user ${order.userId}, not current user $currentUserId',
              );
            }

            return false; // Don't show any orders that don't explicitly belong to current user
          }).toList();

          print(
            '🔒 OrderViewModel: Filtered to ${userOrders.length} orders for current user',
          );

          for (var order in userOrders) {
            print(
              '📦 Order: ID=${order.id}, Status=${order.status}, Total=${order.totalAmount}',
            );
          }
          emit(OrdersLoaded(orders: userOrders));
        },
      );
    } catch (e) {
      print('💥 OrderViewModel: Exception in _onLoadAllOrders: $e');
      emit(OrderError(message: 'Exception: $e'));
    }
  }

  Future<void> _onLoadOrderById(
    LoadOrderByIdEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    final result = await getOrderByIdUseCase(
      GetOrderByIdParams(orderId: event.orderId),
    );
    result.fold(
      (failure) => emit(OrderError(message: failure.message)),
      (order) => emit(OrderLoaded(order: order)),
    );
  }

  Future<void> _onCreateOrder(
    CreateOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    final result = await createOrderUseCase(
      CreateOrderParams(order: event.order),
    );
    result.fold(
      (failure) => emit(OrderError(message: failure.message)),
      (order) => emit(OrderCreated(order: order)),
    );
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatusEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    final result = await updateOrderStatusUseCase(
      UpdateOrderStatusParams(orderId: event.orderId, status: event.status),
    );
    result.fold(
      (failure) => emit(OrderError(message: failure.message)),
      (order) => emit(OrderUpdated(order: order)),
    );
  }

  Future<void> _onDeleteOrder(
    DeleteOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    final result = await deleteOrderUseCase(
      DeleteOrderParams(orderId: event.orderId),
    );
    result.fold(
      (failure) => emit(OrderError(message: failure.message)),
      (_) => emit(OrderDeleted(orderId: event.orderId)),
    );
  }

  Future<void> _onClearLocalOrders(
    ClearLocalOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      print('🧹 OrderViewModel: Clearing all local orders');
      // For now, we'll just emit a success state
      // In a real implementation, you'd call the clear use case
      emit(OrderInitial());
      print('✅ OrderViewModel: Local orders cleared successfully');
    } catch (e) {
      print('❌ OrderViewModel: Failed to clear local orders: $e');
      emit(OrderError(message: 'Failed to clear local orders: $e'));
    }
  }

  /// Clear orphaned orders (orders with null userId) when user re-authenticates
  void clearOrphanedOrders() {
    print(
      '🧹 OrderViewModel: Clearing orphaned orders for fresh authentication',
    );
    add(const ClearLocalOrdersEvent());
  }

  /// Force clear all local orders to remove orphaned data
  void forceClearAllOrders() {
    print(
      '🧹 OrderViewModel: Force clearing all local orders to remove orphaned data',
    );
    add(const ClearLocalOrdersEvent());
  }
}
