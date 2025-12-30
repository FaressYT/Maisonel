import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/order.dart';
import '../../services/api_service.dart';

class OrderRequestsScreen extends StatefulWidget {
  const OrderRequestsScreen({super.key});

  @override
  State<OrderRequestsScreen> createState() => _OrderRequestsScreenState();
}

class _OrderRequestsScreenState extends State<OrderRequestsScreen> {
  List<Order> _requests = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPendingRequests();
  }

  // جلب الطلبات المعلقة فقط من السيرفر
  Future<void> _fetchPendingRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // نستخدم نفس التابع الذي جلب طلبات المالك ولكن نفلترها هنا أو في السيرفر
      final allOrders = await ApiService.getOwnerOrders();
      setState(() {
        _requests = allOrders
            .where((o) => o.status == OrderStatus.pending)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load requests';
      });
    }
  }

  // دالة معالجة القبول أو الرفض وإرسالها للسيرفر
  Future<void> _handleAction(Order order, bool approve) async {
    // إظهار مؤشر تحميل بسيط أو تعطيل الأزرار
    final actionStatus = approve ? 'confirmed' : 'cancelled';

    try {
      // نفترض وجود تابع في ApiService لتحديث حالة الطلب
      //await ApiService.updateOrderStatus(order.id, actionStatus);

      setState(() {
        _requests.remove(order);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              approve ? 'Request approved successfully' : 'Request rejected',
            ),
            backgroundColor: approve ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error updating status')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPendingRequests,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            TextButton(
              onPressed: _fetchPendingRequests,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_requests.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _fetchPendingRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final order = _requests[index];
          return _buildRequestCard(order);
        },
      ),
    );
  }

  Widget _buildRequestCard(Order order) {
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[200],
                    child: order.property.images.isNotEmpty
                        ? Image.network(
                            ApiService.getImageUrl(order.property.images[0]) ??
                                '',
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.home),
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
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Guest: User #${order.id.substring(0, 5)}', // مثال لاسم المستخدم
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
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleAction(order, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
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
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.done_all, size: 64, color: Colors.grey[400]),
          const SizedBox(height: AppSpacing.md),
          const Text('No pending requests found'),
        ],
      ),
    );
  }
}
