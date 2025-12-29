import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import '../../models/order.dart';
import '../../services/api_service.dart'; //
import '../reviews/leave_review_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Order> _allOrders = []; //
  bool _isLoading = true; //
  String? _errorMessage; //
  String _filterStatus = 'All'; //

  final List<String> _statusFilters = [
    'All',
    'Pending',
    'Confirmed',
    'Completed',
    'Cancelled',
  ]; //

  @override
  void initState() {
    super.initState();
    _fetchOrders(); //
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orders = await ApiService.getOwnerOrders(); //
      setState(() {
        _allOrders = orders; //
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load order history. Please try again.'; //
      });
    }
  }

  List<Order> get _filteredOrders {
    if (_filterStatus == 'All') {
      return _allOrders; //
    }
    return _allOrders
        .where(
          (order) =>
              order.statusText.toLowerCase() == _filterStatus.toLowerCase(),
        )
        .toList(); //
  }

  // التعديل الرئيسي هنا: استخدام رابط api/order/owner/show/{id}
  void _showOrderDetails(Order order) async {
    // إظهار مؤشر تحميل بسيط أثناء جلب التفاصيل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // استدعاء التابع الجديد لجلب تفاصيل الطلب رقم (id)
      final detailedOrder = await ApiService.getOrderDetails(
        int.parse(order.id),
      );

      if (!mounted) return;
      Navigator.pop(context); // إغلاق مؤشر التحميل

      // عرض التفاصيل الكاملة القادمة من السيرفر
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
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
                  'Order Details #${detailedOrder.id}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Divider(height: 32),
                _buildDetailRow('Property', detailedOrder.property.title),
                _buildDetailRow('Location', detailedOrder.property.location),
                _buildDetailRow('Status', detailedOrder.statusText),
                _buildDetailRow(
                  'Nights',
                  detailedOrder.numberOfNights.toString(),
                ),
                _buildDetailRow('Guests', detailedOrder.guests.toString()),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Paid',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${detailedOrder.totalCost}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                if (detailedOrder.status == OrderStatus.completed)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LeaveReviewScreen(
                              property: detailedOrder.property,
                            ),
                          ),
                        );
                      },
                      child: const Text('Leave a Review'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // إغلاق مؤشر التحميل
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not fetch details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            onPressed: _fetchOrders,
          ), //
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(), //
          Expanded(child: _buildBody()), //
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator()); //
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)), //
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchOrders,
              child: const Text('Retry'),
            ), //
          ],
        ),
      );
    }

    return _filteredOrders.isEmpty
        ? _buildEmptyState() //
        : RefreshIndicator(
            onRefresh: _fetchOrders,
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
          ); //
  }

  Widget _buildOrderCard(Order order) {
    return GestureDetector(
      onTap: () => _showOrderDetails(order), //
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            if (order.property.images.isNotEmpty) //
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.md),
                ),
                child: Image.network(
                  order.property.images.first, //
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ListTile(
              title: Text(order.property.title), //
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
                      order.statusText, //
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: Text(
                '\$${order.totalCost}', //
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
    return Center(child: Text('No orders found for $_filterStatus')); //
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    } //
  }
}
