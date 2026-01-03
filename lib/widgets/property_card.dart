import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/property.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../cubits/user/user_cubit.dart';

class PropertyCard extends StatefulWidget {
  final Property property;
  final VoidCallback? onTap;
  final bool showFavoriteButton;

  const PropertyCard({
    super.key,
    required this.property,
    this.onTap,
    this.showFavoriteButton = true,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
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
  void didUpdateWidget(PropertyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.property.isFavorite != widget.property.isFavorite) {
      _isFavorite = widget.property.isFavorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.medium,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.md),
                    topRight: Radius.circular(AppRadius.md),
                  ),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: widget.property.images.isNotEmpty
                        ? Image.network(
                            ApiService.getImageUrl(
                                  widget.property.images.first,
                                ) ??
                                '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                child: Center(
                                  child: Icon(
                                    Icons.home,
                                    size: 48,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              Icons.home,
                              size: 48,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                  ),
                ),
                // Featured badge
                if (widget.property.isFeatured)
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.secondaryGradient,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        'FEATURED',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                // Favorite button
                if (widget.showFavoriteButton)
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: BlocBuilder<UserCubit, UserState>(
                        builder: (context, state) {
                          bool isFavorited = _isFavorite;
                          if (state is UserLoaded) {
                            isFavorited = state.favorites.any(
                              (p) => p.id == widget.property.id,
                            );
                          }

                          return IconButton(
                            icon: Icon(
                              isFavorited
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 20,
                            ),
                            color: Theme.of(context).colorScheme.error,
                            onPressed: () async {
                              setState(() {
                                _isFavorite = !isFavorited;
                              });
                              try {
                                await ApiService.toggleFavorite(
                                  widget.property.id,
                                );
                                if (mounted) {
                                  context.read<UserCubit>().loadUserData();
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      !isFavorited
                                          ? 'Added to favorites'
                                          : 'Removed from favorites',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              } catch (e) {
                                setState(() {
                                  _isFavorite = isFavorited; // Revert
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to update favorite'),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
            // Property Details
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.property.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${widget.property.location}, ${widget.property.city}',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Property Info
                  Row(
                    children: [
                      _buildInfoChip(
                        context,
                        Icons.bed,
                        '${widget.property.bedrooms} Beds',
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildInfoChip(
                        context,
                        Icons.bathtub,
                        '${widget.property.bathrooms} Baths',
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildInfoChip(
                        context,
                        Icons.square_foot,
                        '${widget.property.area.toInt()} m²',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Rating and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.property.rating} (${widget.property.reviewCount})',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Text(
                        '\$${widget.property.price.toStringAsFixed(0)}/mo',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
