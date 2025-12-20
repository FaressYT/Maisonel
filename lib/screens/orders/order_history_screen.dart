import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import '../../models/order.dart';
import '../reviews/leave_review_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final List<Order> _orders = Order.getMockOrders();
  String _filterStatus = 'All';

  final List<String> _statusFilters = [
    'All',
    'Pending',
    'Confirmed',
    'Completed',
    'Cancelled',
  ];

  List<Order> get _filteredOrders {
    if (_filterStatus == 'All') {
      return _orders;
    }
    return _orders
        .where(
          (order) =>
              order.statusText.toLowerCase() == _filterStatus.toLowerCase(),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Status Filter
          Container(
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
                        setState(() {
                          _filterStatus = status;
                        });
                      },
                      backgroundColor: Theme.of(context).canvasColor,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      labelStyle: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).textTheme.bodyMedium?.color,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                      checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  );
                },
              ),
            ),
          ),
          // Orders List
          Expanded(
            child: _filteredOrders.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(const Duration(seconds: 1));
                      setState(() {});
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _buildOrderCard(_filteredOrders[index]),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No orders found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _filterStatus == 'All'
                  ? 'You haven\'t made any bookings yet'
                  : 'No $_filterStatus orders',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return GestureDetector(
      onTap: () {
        _showOrderDetails(order);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.medium,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image and Status Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.md),
                    topRight: Radius.circular(AppRadius.md),
                  ),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: AppColors.surfaceLight,
                    child: order.property.images.isNotEmpty
                        ? Image.network(
                            order.property.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.home, size: 48),
                              );
                            },
                          )
                        : const Center(child: Icon(Icons.home, size: 48)),
                  ),
                ),
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      order.statusText.toUpperCase(),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Order Details
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.property.title,
                    style: AppTypography.h6,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${order.property.location}, ${order.property.city}',
                          style: AppTypography.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Check-in',
                          DateFormat('MMM dd, yyyy').format(order.checkInDate),
                        ),
                        const SizedBox(height: 4),
                        _buildInfoRow(
                          Icons.calendar_today_outlined,
                          'Check-out',
                          DateFormat('MMM dd, yyyy').format(order.checkOutDate),
                        ),
                        const SizedBox(height: 4),
                        _buildInfoRow(
                          Icons.nights_stay,
                          'Duration',
                          '${order.numberOfNights} nights',
                        ),
                        const SizedBox(height: 4),
                        _buildInfoRow(
                          Icons.people,
                          'Guests',
                          '${order.guests} ${order.guests == 1 ? 'guest' : 'guests'}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Cost',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      Text(
                        '\$${order.totalCost.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  if (order.status == OrderStatus.completed) ...[
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  LeaveReviewScreen(property: order.property),
                            ),
                          );
                        },
                        icon: const Icon(Icons.star_outline),
                        label: const Text('Leave a Review'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.info;
      case OrderStatus.completed:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.lg),
            topRight: Radius.circular(AppRadius.lg),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textHint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text('Order Details', style: AppTypography.h5),
            ),
            const Divider(),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ID: ${order.id}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Property Details',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      order.property.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      order.property.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Booking Information',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Booked on: ${DateFormat('MMM dd, yyyy').format(order.bookingDate)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            // Close button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
