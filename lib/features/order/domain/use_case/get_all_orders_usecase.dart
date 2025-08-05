import 'package:dartz/dartz.dart';
import 'package:jerseyhub/core/error/failure.dart';
import 'package:jerseyhub/app/use_case/usecase.dart';
import 'package:jerseyhub/features/order/domain/entity/order_entity.dart';
import 'package:jerseyhub/features/order/domain/repository/order_repository.dart';

class GetAllOrdersUseCase implements UsecaseWithoutParams<List<OrderEntity>> {
  final OrderRepository repository;

  GetAllOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, List<OrderEntity>>> call() async {
    return await repository.getAllOrders();
  }
}
