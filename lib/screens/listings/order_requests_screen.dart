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
    _fetchAllRequests();
  }

  // جلب كل الطلبات (معلقة ومكتملة)
  Future<void> _fetchAllRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // نستخدم نفس التابع الذي جلب طلبات المالك ولكن نفلترها هنا أو في السيرفر
      final allOrders = await ApiService.getOwnerOrders();
      setState(() {
        _requests = allOrders; // عرض كل الطلبات وليس المعلقة فقط
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load requests';
      });
    }
  }

  // جلب تفاصيل الطلب وعرضها في نافذة منبثقة
  void _showRequestDetails(Order order) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // تفاصيل الطلب من السيرفر
      final detailedOrder = await ApiService.getOwnerOrderDetails(
        int.parse(order.id),
      );

      if (!mounted) return;
      Navigator.pop(context); // إغلاق مؤشر التحميل

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
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
                  'Request Details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Divider(height: 32),
                _buildDetailRow(
                  'Guest Name',
                  'User #${detailedOrder.id}',
                ), // يمكن استبداله باسم المستخدم إذا توفر
                _buildDetailRow('Property', detailedOrder.property.title),
                _buildDetailRow('Nights', '${detailedOrder.numberOfNights}'),
                _buildDetailRow(
                  'Total Price',
                  '\$${detailedOrder.totalCost.toInt()}',
                ),
                const SizedBox(height: 20),
                if (detailedOrder.status != OrderStatus.completed)
                  Row(
                    children: [
                      if (detailedOrder.status != OrderStatus.cancelled)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context); // إغلاق النافذة
                              _handleAction(detailedOrder, false); // رفض
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: const Text('Reject'),
                          ),
                        ),
                      if (detailedOrder.status != OrderStatus.cancelled &&
                          detailedOrder.status != OrderStatus.confirmed)
                        const SizedBox(width: 16),
                      if (detailedOrder.status != OrderStatus.confirmed)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // إغلاق النافذة
                              _handleAction(detailedOrder, true); // قبول
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              detailedOrder.status == OrderStatus.cancelled
                                  ? 'Re-Approve'
                                  : 'Approve',
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // إغلاق مؤشر التحميل
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading details: $e')));
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // دالة معالجة الإجراءات (قبول/رفض/تحديث)
  Future<void> _handleAction(Order order, bool approve) async {
    // إظهار مؤشر تحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      bool success;
      // إذا كان الطلب معلقاً، نستخدم قبول/رفض عادي
      if (order.status == OrderStatus.pending) {
        if (approve) {
          success = await ApiService.approveOrder(int.parse(order.id));
        } else {
          success = await ApiService.rejectOrder(int.parse(order.id));
        }
      }
      // إذا لم يكن معلقاً، نستخدم توابع التحديث (Update)
      else {
        if (approve) {
          success = await ApiService.approveOrderUpdate(int.parse(order.id));
        } else {
          success = await ApiService.rejectOrderUpdate(int.parse(order.id));
        }
      }

      if (!mounted) return;
      Navigator.pop(context); // إغلاق مؤشر التحميل

      if (success) {
        // تحديث القائمة بإعادة جلب البيانات لضمان دقة الحالة
        _fetchAllRequests();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approve ? 'Order Approved' : 'Order Rejected'),
            backgroundColor: approve ? Colors.green : Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Operation failed. Please try again.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
            onPressed: _fetchAllRequests,
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
              onPressed: _fetchAllRequests,
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
      onRefresh: _fetchAllRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final order = _requests[index];
          return GestureDetector(
            onTap: () => _showRequestDetails(order), // عرض التفاصيل عند الضغط
            child: _buildRequestCard(order),
          );
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
      elevation: 2,
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
                            order.property.images[0],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image),
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
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${order.statusText}', // عرض الحالة
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (order.status != OrderStatus.completed) ...[
              const Divider(height: 24),
              Row(
                children: [
                  // زر الرفض: يختفي إذا كان الطلب ملغى بالفعل
                  if (order.status != OrderStatus.cancelled)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _handleAction(order, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                  if (order.status != OrderStatus.cancelled &&
                      order.status != OrderStatus.confirmed)
                    const SizedBox(width: AppSpacing.md),
                  // زر القبول: يختفي إذا كان الطلب مؤكداً بالفعل
                  if (order.status != OrderStatus.confirmed)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleAction(order, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        // تغيير نص الزر حسب الحالة
                        child: Text(
                          order.status == OrderStatus.cancelled
                              ? 'Re-Approve'
                              : 'Approve',
                        ),
                      ),
                    ),
                ],
              ),
            ],
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
          Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
          const SizedBox(height: AppSpacing.md),
          const Text('No pending requests'),
        ],
      ),
    );
  }
}
