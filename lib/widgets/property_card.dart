import 'package:flutter/material.dart';
import '../models/property.dart';
import '../theme.dart';
import '../services/api_service.dart';

class PropertyCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                    child: property.images.isNotEmpty
                        ? Image.network(
                            ApiService.getImageUrl(property.images.first) ?? '',
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
                if (property.isFeatured)
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
                if (showFavoriteButton)
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.favorite_border, size: 20),
                        color: Theme.of(context).colorScheme.error,
                        onPressed: () {
                          // TODO: Implement favorite functionality
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
                    property.title,
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
                          '${property.location}, ${property.city}',
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
                        '${property.bedrooms} Beds',
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildInfoChip(
                        context,
                        Icons.bathtub,
                        '${property.bathrooms} Baths',
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildInfoChip(
                        context,
                        Icons.square_foot,
                        '${property.area.toInt()} m²',
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
                            '${property.rating} (${property.reviewCount})',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Text(
                        '\$${property.price.toStringAsFixed(0)}/mo',
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
