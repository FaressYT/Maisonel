import 'package:flutter/material.dart';
import 'package:maisonel_v02/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import '../../models/order.dart';
import '../../models/property.dart';
import '../../services/api_service.dart';
import '../../cubits/order/order_cubit.dart';
import '../../cubits/apartment/apartment_cubit.dart';

class OrderRequestsScreen extends StatefulWidget {
  const OrderRequestsScreen({super.key});

  @override
  State<OrderRequestsScreen> createState() => _OrderRequestsScreenState();
}

class _OrderRequestsScreenState extends State<OrderRequestsScreen> {
  @override
  void initState() {
    super.initState();
    // Load owner requests via Cubit
    context.read<OrderCubit>().loadOwnerRequests();
  }

  // Sort orders: pending first, then others
  List<Order> _sortOrders(List<Order> allRequests) {
    final pending = allRequests
        .where((o) => o.status == OrderStatus.pending)
        .toList();
    final processed = allRequests
        .where((o) => o.status != OrderStatus.pending)
        .toList();
    return [...pending, ...processed];
  }

  Property? _getProperty(Order order) {
    // 1. Try property from order itself
    if (order.property != null) return order.property;

    // 2. Try looking up in ApartmentCubit
    final apartmentState = context.read<ApartmentCubit>().state;
    if (apartmentState is ApartmentLoaded) {
      try {
        return apartmentState.ownedApartments.firstWhere(
          (p) => p.id == order.apartmentId,
        );
      } catch (e) {
        // Not found in owned, try available
        try {
          return apartmentState.availableApartments.firstWhere(
            (p) => p.id == order.apartmentId,
          );
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  Future<void> _handleAction(Order order, bool approve) async {
    // Optimistic update or waiting for Cubit
    // Cubit handles the API call and reloading
    if (approve) {
      context.read<OrderCubit>().approveOrder(order.id);
    } else {
      context.read<OrderCubit>().rejectOrder(order.id);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          approve
              ? AppLocalizations.of(context)!.processingApproval
              : AppLocalizations.of(context)!.processingRejection,
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.bookingRequests),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<OrderCubit>().loadOwnerRequests(),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return BlocConsumer<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.error(state.message)),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is OrderLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is OrderLoaded) {
          final sortedRequests = _sortOrders(state.ownerRequests);

          if (sortedRequests.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<OrderCubit>().loadOwnerRequests(),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: sortedRequests.length,
              itemBuilder: (context, index) {
                final order = sortedRequests[index];
                return _buildRequestCard(order);
              },
            ),
          );
        } else if (state is OrderError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.failedToLoadRequests,
                  style: TextStyle(color: Colors.red),
                ),
                TextButton(
                  onPressed: () =>
                      context.read<OrderCubit>().loadOwnerRequests(),
                  child: Text(AppLocalizations.of(context)!.retry),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRequestCard(Order order) {
    final property = _getProperty(order);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isPending = order.status == OrderStatus.pending;

    return Opacity(
      opacity: isPending ? 1.0 : 0.5,
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property Image and Title
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: property != null && property.images.isNotEmpty
                          ? Image.network(
                              ApiService.getImageUrl(property.images[0]) ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.home, size: 30),
                            )
                          : const Icon(Icons.home, size: 30),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property?.title ??
                              AppLocalizations.of(context)!.unknownProperty,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (property?.location != null)
                          Text(
                            property!.city + ', ' + property.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Booking Details
              _buildDetailRow(
                icon: Icons.calendar_today,
                label: AppLocalizations.of(context)!.checkIn,
                value: dateFormat.format(order.checkInDate),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                icon: Icons.calendar_today,
                label: AppLocalizations.of(context)!.checkOut,
                value: dateFormat.format(order.checkOutDate),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                icon: Icons.nights_stay,
                label: AppLocalizations.of(context)!.nights,
                value: AppLocalizations.of(
                  context,
                )!.nightsCount(order.numberOfNights),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                icon: Icons.people,
                label: AppLocalizations.of(context)!.guestLabel,
                value: AppLocalizations.of(context)!.guestCount(order.guests),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                icon: Icons.payment,
                label: AppLocalizations.of(context)!.payment,
                value:
                    order.paymentMethod ??
                    AppLocalizations.of(context)!.notSpecified,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                icon: Icons.access_time,
                label: AppLocalizations.of(context)!.bookedOn,
                value: dateFormat.format(order.bookingDate),
              ),

              const Divider(height: 24),

              // Total Cost
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.totalAmount,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${order.totalCost.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Action Buttons or Status Label
              if (isPending)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _handleAction(order, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: Text(AppLocalizations.of(context)!.reject),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleAction(order, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(AppLocalizations.of(context)!.approve),
                      ),
                    ),
                  ],
                )
              else
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(order.status),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      order.statusText.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    return Order.getStatusColor(status);
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.done_all, size: 64, color: Colors.grey[400]),
          const SizedBox(height: AppSpacing.md),
          Text(AppLocalizations.of(context)!.noPendingRequests),
        ],
      ),
    );
  }
}
