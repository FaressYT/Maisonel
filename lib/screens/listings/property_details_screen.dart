import 'package:flutter/material.dart';
import 'package:maisonel_v02/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/property.dart';
import '../../models/review.dart';
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
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.property.isFavorite;
    _reviewsFuture = _loadReviews();

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

    ApiService.recordApartmentView(widget.property.id);
  }

  @override
  void didUpdateWidget(PropertyDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.property.isFavorite != widget.property.isFavorite) {
      _isFavorite = widget.property.isFavorite;
    }
    if (oldWidget.property.id != widget.property.id) {
      _reviewsFuture = _loadReviews();
    }
  }

  Future<List<Review>> _loadReviews() async {
    final data = await ApiService.getApartmentRatings(widget.property.id);
    final reviews = <Review>[];
    for (final item in data) {
      if (item is Map<String, dynamic>) {
        reviews.add(Review.fromJson(item));
      } else if (item is Map) {
        reviews.add(Review.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return reviews;
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        final position = index + 1;
        if (rating >= position) {
          return const Icon(Icons.star, size: 16, color: Colors.amber);
        }
        if (rating > index && rating < position) {
          return const Icon(Icons.star_half, size: 16, color: Colors.amber);
        }
        return const Icon(Icons.star_border, size: 16, color: Colors.amber);
      }),
    );
  }

  Widget _buildReviewCard(Review review) {
    final initials = review.reviewerName.isNotEmpty
        ? review.reviewerName.trim()[0].toUpperCase()
        : 'A';
    final reviewerPhoto = ApiService.getImageUrl(review.reviewerPhoto);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).colorScheme.primary,
                backgroundImage:
                    reviewerPhoto != null && reviewerPhoto.isNotEmpty
                        ? NetworkImage(reviewerPhoto)
                        : null,
                child: reviewerPhoto == null || reviewerPhoto.isEmpty
                    ? Text(
                        initials,
                        style: const TextStyle(color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(review.date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              _buildRatingStars(review.rating),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              review.comment,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
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
                            const SizedBox(height: AppSpacing.xs),
                            Row(
                              children: [
                                Icon(
                                  Icons.visibility,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.viewsCount(widget.property.viewCount),
                                  style: Theme.of(context).textTheme.bodySmall,
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
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Reviews',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FutureBuilder<List<Review>>(
                    future: _reviewsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.error(snapshot.error.toString()),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _reviewsFuture = _loadReviews();
                                });
                              },
                              child: Text(
                                AppLocalizations.of(context)!.retry,
                              ),
                            ),
                          ],
                        );
                      }
                      final reviews = snapshot.data ?? [];
                      if (reviews.isEmpty) {
                        return const Text('No reviews yet.');
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: reviews
                            .map((review) => _buildReviewCard(review))
                            .toList(),
                      );
                    },
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
