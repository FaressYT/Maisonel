import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme.dart';
import '../../models/order.dart';
import '../../models/property.dart';
import '../../cubits/order/order_cubit.dart';
import '../../cubits/apartment/apartment_cubit.dart';
import '../../services/api_service.dart';
import '../reviews/leave_review_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _filterStatus = 'All';

  final List<String> _statusFilters = [
    'All',
    'Pending',
    'Confirmed',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    // Load orders via Cubit
    context.read<OrderCubit>().loadUserOrders();
  }

  List<Order> _filterOrders(List<Order> orders) {
    if (_filterStatus == 'All') {
      return orders;
    }
    return orders
        .where(
          (order) =>
              order.statusText.toLowerCase() == _filterStatus.toLowerCase(),
        )
        .toList();
  }

  Property? _getProperty(Order order) {
    // 1. Try property from order itself
    if (order.property != null) return order.property;

    // 2. Try looking up in ApartmentCubit
    final apartmentState = context.read<ApartmentCubit>().state;
    if (apartmentState is ApartmentLoaded) {
      try {
        return apartmentState.availableApartments.firstWhere(
          (p) => p.id == order.apartmentId,
        );
      } catch (e) {
        // Not found in available, try owned (unlikely for user order but possible)
        try {
          return apartmentState.ownedApartments.firstWhere(
            (p) => p.id == order.apartmentId,
          );
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  void _showOrderDetails(Order order) {
    // Resolve property locally
    final property = _getProperty(order);

    // We don't fetch from API anymore, use the data we have
    _buildDetailsBottomSheet(context, order, property);
  }

  void _buildDetailsBottomSheet(
    BuildContext context,
    Order order,
    Property? property,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Order Details #${order.id}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Divider(height: 32),
              _buildDetailRow(
                'Property',
                property?.title ?? 'Unknown Property',
              ),
              _buildDetailRow(
                'Location',
                property?.location ?? 'Unknown Location',
              ),
              _buildDetailRow('Status', order.statusText),
              _buildDetailRow('Nights', order.numberOfNights.toString()),
              _buildDetailRow('Guests', order.guests.toString()),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Paid',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${order.totalCost}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (order.status == OrderStatus.completed && property != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LeaveReviewScreen(
                            property: property,
                            orderId: order.id,
                          ),
                        ),
                      );
                    },
                    child: const Text('Leave a Review'),
                  ),
                ),
              if (order.status == OrderStatus.pending ||
                  order.status == OrderStatus.confirmed)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // Use Cubit to cancel
                        context.read<OrderCubit>().cancelOrder(order.id);
                        Navigator.pop(context); // Close details
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cancellation request sent'),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Cancel Booking'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<OrderCubit>().loadUserOrders(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: Theme.of(context).cardColor,
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _statusFilters.length,
          itemBuilder: (context, index) {
            final status = _statusFilters[index];
            final isSelected = status == _filterStatus;
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: FilterChip(
                label: Text(status),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _filterStatus = status);
                },
                backgroundColor: Theme.of(context).canvasColor,
                selectedColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(color: isSelected ? Colors.white : null),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is OrderError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => context.read<OrderCubit>().loadUserOrders(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (state is OrderLoaded) {
          final filteredOrders = _filterOrders(state.userOrders);
          return filteredOrders.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async =>
                      context.read<OrderCubit>().loadUserOrders(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _buildOrderCard(filteredOrders[index]),
                      );
                    },
                  ),
                );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildOrderCard(Order order) {
    final property = _getProperty(order);

    return GestureDetector(
      onTap: () => _showOrderDetails(order),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            if (property != null && property.images.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.md),
                ),
                child: Image.network(
                  ApiService.getImageUrl(property.images.first) ?? '',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              )
            else
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.md),
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.home, size: 40, color: Colors.grey),
                ),
              ),
            ListTile(
              title: Text(property?.title ?? 'Unknown Property'),
              subtitle: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      order.statusText,
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: Text(
                '\$${order.totalCost}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Text('No orders found for $_filterStatus'));
  }

  Color _getStatusColor(OrderStatus status) {
    return Order.getStatusColor(status);
  }
}
