import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/property.dart';
import '../../widgets/property_card.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  // Mock user's listings (first 3 properties)
  late List<Property> _myListings;

  @override
  void initState() {
    super.initState();
    _myListings = Property.getMockProperties().take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              // TODO: Navigate to add listing screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add new listing feature coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
      body: _myListings.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
                setState(() {});
              },
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
          // TODO: Navigate to add listing screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add new listing feature coming soon!'),
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Listing'),
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
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_business,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No listings yet',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start adding your properties to rent them out',
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
            onTap: () {
              // TODO: Navigate to listing details
            },
          ),
          // Action Buttons
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
                // Views count
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        size: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(property.reviewCount * 2.5).toInt()} views',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                // Edit button
                IconButton(
                  onPressed: () {
                    // TODO: Navigate to edit listing
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit listing feature coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                  color: Theme.of(context).colorScheme.primary,
                  tooltip: 'Edit',
                ),
                // Delete button
                IconButton(
                  onPressed: () {
                    _showDeleteConfirmation(property);
                  },
                  icon: const Icon(Icons.delete_outline),
                  color: Theme.of(context).colorScheme.error,
                  tooltip: 'Delete',
                ),
                // Toggle active/inactive
                Switch(
                  value: true,
                  onChanged: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value ? 'Listing activated' : 'Listing deactivated',
                        ),
                      ),
                    );
                  },
                  activeThumbColor: Colors.green, // Fallback for success
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
        title: Text(
          'Delete Listing',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        content: Text(
          'Are you sure you want to delete "${property.title}"? This action cannot be undone.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _myListings.remove(property);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Listing deleted'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(
              'Delete',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
