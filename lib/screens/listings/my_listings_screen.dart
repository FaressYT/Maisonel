import 'package:flutter/material.dart';
import 'package:maisonel_v02/services/api_service.dart';
import '../../theme.dart';
import '../../models/property.dart';
import '../../widgets/property_card.dart';
import 'add_edit_listing_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  List<Property> _myListings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyListings();
  }

  // جلب البيانات من السيرفر
  Future<void> _fetchMyListings() async {
    setState(() => _isLoading = true);
    try {
      // ملحوظة: تأكد أن ApiService يحتوي على دالة لجلب عقارات المستخدم الحالي
      // إذا لم تتوفر، سنستخدم جلب الكل ونقوم بالتصفية (كمثال)
      final all = await ApiService.getOwnedApartments();

      setState(() {
        _myListings = all; // هنا نفترض جلب العقارات الخاصة بالمسوق
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading listings: $e')));
      }
    }
  }

  // حذف العقار من السيرفر
  Future<void> _deleteProperty(Property property) async {
    try {
      // نفترض وجود دالة deleteProperty في ApiService
      // await ApiService.deleteProperty(property.id);

      setState(() {
        _myListings.removeWhere((p) => p.id == property.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listing deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMyListings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myListings.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _fetchMyListings,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: _myListings.length,
                itemBuilder: (context, index) {
                  final property = _myListings[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _buildListingCard(property),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditListingScreen(),
            ),
          ).then((_) => _fetchMyListings()); // تحديث بعد الإضافة
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Listing'),
      ),
    );
  }

  Widget _buildListingCard(Property property) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.medium,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              PropertyCard(
                property: property,
                showFavoriteButton: false,
                onTap: () {
                  // الانتقال لتفاصيل العقار إذا رغبت
                },
              ),
              if (property.approvalStatus != 1)
                Positioned(
                  top: 12,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (property.approvalStatus == -1
                                  ? Colors.black
                                  : Colors.red)
                              .withOpacity(0.8),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          property.approvalStatus == -1
                              ? Icons.block
                              : Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          property.approvalStatus == -1
                              ? 'Rejected'
                              : 'Not Approved Yet',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppRadius.md),
                bottomRight: Radius.circular(AppRadius.md),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${(property.reviewCount * 12).toInt()} views', // رقم افتراضي للمشاهدات
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: property.approvalStatus == -1
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddEditListingScreen(property: property),
                            ),
                          ).then((_) => _fetchMyListings());
                        },
                  icon: const Icon(Icons.edit_outlined),
                  color: property.approvalStatus == -1
                      ? Colors.grey
                      : Theme.of(context).colorScheme.primary,
                ),
                IconButton(
                  onPressed: property.approvalStatus == -1
                      ? null
                      : () => _showDeleteConfirmation(property),
                  icon: const Icon(Icons.delete_outline),
                  color: property.approvalStatus == -1
                      ? Colors.grey
                      : Theme.of(context).colorScheme.error,
                ),
                // تبديل حالة العقار (نشط/غير نشط)
                Switch(
                  value: property.approvalStatus == 1
                      ? property.isFeatured
                      : false,
                  onChanged: property.approvalStatus == 1
                      ? (value) async {
                          // هنا يتم استدعاء ApiService لتحديث حالة العقار
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                value
                                    ? 'Listing Activated'
                                    : 'Listing Deactivated',
                              ),
                            ),
                          );
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Property property) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing'),
        content: Text('Are you sure you want to delete "${property.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProperty(property);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_business,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No listings yet',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Text('Start adding your properties to reach customers'),
        ],
      ),
    );
  }
}
