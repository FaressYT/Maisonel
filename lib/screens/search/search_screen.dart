import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/property.dart';
import '../../widgets/property_card.dart';
import '../../widgets/custom_button.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  RangeValues _priceRange = const RangeValues(0, 5000);
  String _selectedPropertyType = 'All';
  int _bedrooms = 0;
  int _bathrooms = 0;
  String _sortBy = 'Featured';

  List<Property> _searchResults = [];
  bool _hasSearched = false;

  final List<String> _propertyTypes = [
    'All',
    'Apartment',
    'House',
    'Villa',
    'Studio',
  ];

  final List<String> _sortOptions = [
    'Featured',
    'Price: Low to High',
    'Price: High to Low',
    'Rating',
    'Newest',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _performSearch() {
    setState(() {
      _hasSearched = true;
      // Get all properties and filter
      List<Property> results = Property.getMockProperties();

      // Filter by price range
      results = results
          .where(
            (p) => p.price >= _priceRange.start && p.price <= _priceRange.end,
          )
          .toList();

      // Filter by property type
      if (_selectedPropertyType != 'All') {
        results = results
            .where((p) => p.propertyType == _selectedPropertyType)
            .toList();
      }

      // Filter by bedrooms
      if (_bedrooms > 0) {
        results = results.where((p) => p.bedrooms >= _bedrooms).toList();
      }

      // Filter by bathrooms
      if (_bathrooms > 0) {
        results = results.where((p) => p.bathrooms >= _bathrooms).toList();
      }

      // Sort results
      switch (_sortBy) {
        case 'Price: Low to High':
          results.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'Price: High to Low':
          results.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'Rating':
          results.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'Featured':
          results.sort(
            (a, b) => (b.isFeatured ? 1 : 0).compareTo(a.isFeatured ? 1 : 0),
          );
          break;
      }

      _searchResults = results;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _locationController.clear();
      _priceRange = const RangeValues(0, 5000);
      _selectedPropertyType = 'All';
      _bedrooms = 0;
      _bathrooms = 0;
      _sortBy = 'Featured';
      _hasSearched = false;
      _searchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search Properties'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search Filters
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search properties...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppColors.cardBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Location
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      hintText: 'Location',
                      prefixIcon: const Icon(Icons.location_on),
                      filled: true,
                      fillColor: AppColors.cardBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Price Range
                  Text('Price Range', style: AppTypography.h6),
                  const SizedBox(height: AppSpacing.sm),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 5000,
                    divisions: 50,
                    activeColor: AppColors.primary,
                    labels: RangeLabels(
                      '\$${_priceRange.start.round()}',
                      '\$${_priceRange.end.round()}',
                    ),
                    onChanged: (values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                  ),
                  Text(
                    '\$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Property Type
                  Text('Property Type', style: AppTypography.h6),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: _propertyTypes.map((type) {
                      final isSelected = type == _selectedPropertyType;
                      return FilterChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedPropertyType = type;
                          });
                        },
                        backgroundColor: AppColors.cardBackground,
                        selectedColor: AppColors.primary,
                        labelStyle: AppTypography.bodyMedium.copyWith(
                          color: isSelected
                              ? AppColors.textWhite
                              : AppColors.textPrimary,
                        ),
                        checkmarkColor: AppColors.textWhite,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Bedrooms
                  Text('Bedrooms', style: AppTypography.h6),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: List.generate(5, (index) {
                      final value = index;
                      final isSelected = _bedrooms == value;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: ChoiceChip(
                          label: Text(value == 0 ? 'Any' : '$value+'),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _bedrooms = value;
                            });
                          },
                          backgroundColor: AppColors.cardBackground,
                          selectedColor: AppColors.primary,
                          labelStyle: AppTypography.bodyMedium.copyWith(
                            color: isSelected
                                ? AppColors.textWhite
                                : AppColors.textPrimary,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Bathrooms
                  Text('Bathrooms', style: AppTypography.h6),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: List.generate(5, (index) {
                      final value = index;
                      final isSelected = _bathrooms == value;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: ChoiceChip(
                          label: Text(value == 0 ? 'Any' : '$value+'),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _bathrooms = value;
                            });
                          },
                          backgroundColor: AppColors.cardBackground,
                          selectedColor: AppColors.primary,
                          labelStyle: AppTypography.bodyMedium.copyWith(
                            color: isSelected
                                ? AppColors.textWhite
                                : AppColors.textPrimary,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Sort By
                  Text('Sort By', style: AppTypography.h6),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: _sortBy,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.cardBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _sortOptions.map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value!;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Search Results
                  if (_hasSearched) ...[
                    Divider(color: AppColors.textHint.withOpacity(0.3)),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Search Results (${_searchResults.length})',
                      style: AppTypography.h5,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (_searchResults.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.search_off,
                                size: 64,
                                color: AppColors.textHint,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'No properties found',
                                style: AppTypography.h6.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: PropertyCard(
                              property: _searchResults[index],
                              onTap: () {
                                // TODO: Navigate to property details
                              },
                            ),
                          );
                        },
                      ),
                  ],
                ],
              ),
            ),
          ),
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              boxShadow: AppShadows.medium,
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Clear',
                    onPressed: _clearFilters,
                    variant: ButtonVariant.outline,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    text: 'Search',
                    onPressed: _performSearch,
                    icon: Icons.search,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
