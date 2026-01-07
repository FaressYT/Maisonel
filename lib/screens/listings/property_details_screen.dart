import 'package:flutter/material.dart';
import 'package:maisonel_v02/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/property.dart';
import '../../theme.dart';
import 'booking_screen.dart';
import '../../services/api_service.dart';
import '../../cubits/user/user_cubit.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailsScreen({super.key, required this.property});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.property.isFavorite;

    // Cross-reference with UserCubit to ensure accurate favorite status
    final userState = context.read<UserCubit>().state;
    if (userState is UserLoaded) {
      final isActuallyFavorite = userState.favorites.any(
        (p) => p.id == widget.property.id,
      );
      if (isActuallyFavorite) {
        _isFavorite = true;
      }
    }
  }

  @override
  void didUpdateWidget(PropertyDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.property.isFavorite != widget.property.isFavorite) {
      _isFavorite = widget.property.isFavorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              BlocBuilder<UserCubit, UserState>(
                builder: (context, state) {
                  bool isFavorited = _isFavorite;
                  if (state is UserLoaded) {
                    isFavorited = state.favorites.any(
                      (p) => p.id == widget.property.id,
                    );
                  }

                  return IconButton(
                    icon: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                    ),
                    color: isFavorited ? Colors.red : null,
                    onPressed: () async {
                      setState(() {
                        _isFavorite = !isFavorited;
                      });
                      try {
                        await ApiService.toggleFavorite(widget.property.id);
                        if (mounted) {
                          context.read<UserCubit>().loadUserData();
                        }
                      } catch (e) {
                        setState(() {
                          _isFavorite = isFavorited; // Revert
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                )!.failedToUpdateFavorite,
                              ),
                            ),
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: PageView.builder(
                itemCount: widget.property.images.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    ApiService.getImageUrl(widget.property.images[index]) ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 50),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.property.title,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  '${widget.property.location}, ${widget.property.city}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.color,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '\$${widget.property.price.toInt()}',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.perMonth,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFeatureChip(
                        context,
                        Icons.bed,
                        AppLocalizations.of(
                          context,
                        )!.bedroomsCount(widget.property.bedrooms),
                      ),
                      _buildFeatureChip(
                        context,
                        Icons.bathroom,
                        AppLocalizations.of(
                          context,
                        )!.bathroomsCount(widget.property.bathrooms),
                      ),
                      _buildFeatureChip(
                        context,
                        Icons.square_foot,
                        AppLocalizations.of(
                          context,
                        )!.areaSqm(widget.property.area),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    AppLocalizations.of(context)!.descriptionTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.property.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    AppLocalizations.of(context)!.amenities,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: widget.property.amenities.map((amenity) {
                      return Chip(
                        label: Text(amenity),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 100), // Spacing for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: AppShadows.large,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              // Navigation to Booking Screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BookingScreen(property: widget.property),
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.bookNow),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
