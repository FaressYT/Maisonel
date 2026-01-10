import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/api_service.dart';
import '../../models/order.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  OrderCubit() : super(OrderInitial());

  Future<void> loadUserOrders() async {
    emit(OrderLoading());
    try {
      final orders = await ApiService.getUserOrders();
      // Keep existing requests if any, or empty list
      final currentRequests = state is OrderLoaded
          ? (state as OrderLoaded).ownerRequests
          : <Order>[];
      emit(OrderLoaded(userOrders: orders, ownerRequests: currentRequests));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> loadOwnerRequests() async {
    emit(OrderLoading());
    try {
      final requests = await ApiService.getOwnerOrders();
      // Keep existing user orders if any
      final currentOrders = state is OrderLoaded
          ? (state as OrderLoaded).userOrders
          : <Order>[];
      emit(OrderLoaded(userOrders: currentOrders, ownerRequests: requests));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> createOrder({
    required String apartmentId,
    required int guestCount,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required double pricePerNight,
    required double totalCost,
  }) async {
    emit(OrderLoading());
    try {
      await ApiService.createOrder(
        apartmentId: apartmentId,
        guestCount: guestCount,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        pricePerNight: pricePerNight,
        totalCost: totalCost,
      );
      await loadUserOrders(); // Refresh user orders
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> cancelOrder(String id) async {
    emit(OrderLoading());
    try {
      await ApiService.cancelUserOrder(id);
      await loadUserOrders(); // Refresh
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> approveOrder(String id) async {
    emit(OrderLoading());
    try {
      await ApiService.approveOrder(id);
      await loadOwnerRequests(); // Refresh
    } catch (e) {
      final errorMessage = e.toString().contains('No query results')
          ? 'Order not found. It may have already been processed.'
          : e.toString();
      emit(OrderError(errorMessage));
    }
  }

  Future<void> rejectOrder(String id) async {
    emit(OrderLoading());
    try {
      await ApiService.rejectOrder(id);
      await loadOwnerRequests(); // Refresh
    } catch (e) {
      final errorMessage = e.toString().contains('No query results')
          ? 'Order not found. It may have already been processed.'
          : e.toString();
      emit(OrderError(errorMessage));
    }
  }

  Future<List<DateTime>> getUnavailableDates(String apartmentId) async {
    try {
      return await ApiService.getUnavailableDates(apartmentId);
    } catch (e) {
      return [];
    }
  }
}
