import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/order.dart';

class OrderRequestsScreen extends StatefulWidget {
  const OrderRequestsScreen({super.key});

  @override
  State<OrderRequestsScreen> createState() => _OrderRequestsScreenState();
}

class _OrderRequestsScreenState extends State<OrderRequestsScreen> {
  // Filter only pending orders for this example
  final List<Order> _requests = Order.getMockOrders()
      .where((order) => order.status == OrderStatus.pending)
      .toList();

  void _handleAction(Order order, bool approve) {
    setState(() {
      _requests.remove(order);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          approve ? 'Request approved successfully' : 'Request rejected',
        ),
        backgroundColor: approve
            ? AppColors.success
            : Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Requests')),
      body: _requests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No pending requests',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final order = _requests[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(order.property.images[0]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.property.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${order.numberOfNights} nights • \$${order.totalCost.toInt()}',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Guest: John Doe', // Mock guest name
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '${order.guests} Guests',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _handleAction(order, false),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                  side: BorderSide(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                child: const Text('Reject'),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _handleAction(order, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Approve'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
