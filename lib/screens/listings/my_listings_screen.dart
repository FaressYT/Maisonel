import 'package:flutter/material.dart';
import 'package:maisonel_v02/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme.dart';
import '../../models/property.dart';
import '../../widgets/property_card.dart';
import '../../cubits/apartment/apartment_cubit.dart';
import 'add_edit_listing_screen.dart';
import 'property_details_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  @override
  void initState() {
    super.initState();
    // Load apartments if not already loaded or if specific refresh needed
    context.read<ApartmentCubit>().loadApartments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myListings),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ApartmentCubit>().loadApartments(),
          ),
        ],
      ),
      body: BlocBuilder<ApartmentCubit, ApartmentState>(
        builder: (context, state) {
          if (state is ApartmentLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ApartmentError) {
            return Center(
              child: Text(AppLocalizations.of(context)!.error(state.message)),
            );
          } else if (state is ApartmentLoaded) {
            final myListings = state.ownedApartments;
            return myListings.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () async =>
                        context.read<ApartmentCubit>().loadApartments(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: myListings.length,
                      itemBuilder: (context, index) {
                        final property = myListings[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _buildListingCard(property),
                        );
                      },
                    ),
                  );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditListingScreen(),
            ),
          ).then((_) {
            // Reload in case changes were made via AddEdit (if it doesn't use Cubit yet)
            // Or if it does, it might have updated state, but a reload ensures sync.
            // Ideally AddEditScreen uses Cubit so state is already updated.
            context.read<ApartmentCubit>().loadApartments();
          });
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.addListing),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PropertyDetailsScreen(property: property),
                    ),
                  ).then((_) {
                    if (mounted) {
                      context.read<ApartmentCubit>().loadApartments();
                    }
                  });
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
                              ? AppLocalizations.of(context)!.rejected
                              : AppLocalizations.of(context)!.notApprovedYet,
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
                        AppLocalizations.of(
                          context,
                        )!.viewsCount(property.viewCount),
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
                          ).then(
                            (_) =>
                                context.read<ApartmentCubit>().loadApartments(),
                          );
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
                // Switch (Active/Inactive)
                Switch(
                  value: property.approvalStatus == 1
                      ? property.isActive
                      : false,
                  onChanged: property.approvalStatus == 1
                      ? (value) {
                          context.read<ApartmentCubit>().toggleApartmentStatus(
                            property.id,
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
        title: Text(AppLocalizations.of(context)!.deleteListing),
        content: Text(
          AppLocalizations.of(context)!.deleteListingConfirm(property.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ApartmentCubit>().deleteApartment(property.id);
            },
            child: Text(
              AppLocalizations.of(context)!.delete,
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
            AppLocalizations.of(context)!.noListingsYet,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(AppLocalizations.of(context)!.startAddingProperties),
        ],
      ),
    );
  }
}
