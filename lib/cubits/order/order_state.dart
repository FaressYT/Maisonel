part of 'order_cubit.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<Order> userOrders;
  final List<Order> ownerRequests;

  const OrderLoaded({
    this.userOrders = const [],
    this.ownerRequests = const [],
  });

  @override
  List<Object> get props => [userOrders, ownerRequests];

  OrderLoaded copyWith({List<Order>? userOrders, List<Order>? ownerRequests}) {
    return OrderLoaded(
      userOrders: userOrders ?? this.userOrders,
      ownerRequests: ownerRequests ?? this.ownerRequests,
    );
  }
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object> get props => [message];
}
