import 'package:flutter/material.dart';
import 'package:maisonel_v02/services/api_service.dart';
import '../../theme.dart';
import '../../models/property.dart';
import '../../widgets/property_card.dart';
import 'add_edit_listing_screen.dart';
import 'property_details_screen.dart'; // تأكد من استيراد شاشة التفاصيل

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

  // جلب كافة العقارات الخاصة بالمستخدم
  Future<void> _fetchMyListings() async {
    setState(() => _isLoading = true);
    try {
      final myData = await ApiService.getMyApartments();
      setState(() {
        _myListings = myData;
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

  // جلب تفاصيل شقة واحدة عند الضغط عليها (التابع الجديد بالتوكن)
  Future<void> _handleViewDetails(int apartmentId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final property = await ApiService.getApartmentById(apartmentId);

      if (mounted) Navigator.pop(context); // إغلاق مؤشر التحميل

      if (property != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetailsScreen(property: property),
          ),
        );
      } else {
        _showSnackBar(
          'Could not fetch details. Please try again.',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnackBar('Connection error', isError: true);
    }
  }

  // حذف العقار نهائياً
  Future<void> _deleteProperty(Property property) async {
    try {
      final success = await ApiService.deleteApartment(
        property.id.compareTo(property.id),
      );

      if (success) {
        setState(() {
          _myListings.removeWhere((p) => p.id == property.id);
        });
        _showSnackBar('Listing deleted successfully');
      } else {
        throw Exception("Failed to delete from server");
      }
    } catch (e) {
      _showSnackBar('Failed to delete: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
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
          ).then((value) {
            if (value == true) _fetchMyListings();
          });
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
          PropertyCard(
            property: property,
            showFavoriteButton: false,
            // التعديل: استدعاء جلب التفاصيل بالتوكن عند الضغط
            onTap: () => _handleViewDetails(property.id.compareTo(property.id)),
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
                        '${(property.reviewCount * 12).toInt()} views',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddEditListingScreen(property: property),
                      ),
                    ).then((value) {
                      if (value == true) _fetchMyListings();
                    });
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
                Switch(
                  value: property.isFeatured,
                  onChanged: (value) {
                    // هنا يمكن إضافة تابع لتغيير حالة التميز بالسيرفر
                  },
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
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _fetchMyListings,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}
