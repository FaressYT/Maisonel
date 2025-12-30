import 'package:flutter/material.dart';
import 'package:maisonel_v02/services/api_service.dart';
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
  bool _isLoading = false;

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

  // التابع المعدل للربط مع API الفلترة
  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      // استدعاء السيرفر للقيام بالبحث والفلترة
      final results = await ApiService.getAvailableApartments();

      // ترتيب النتائج القادمة من السيرفر محلياً بناءً على اختيار المستخدم
      results.sort((a, b) {
        switch (_sortBy) {
          case 'Price: Low to High':
            return a.price.compareTo(b.price);
          case 'Price: High to Low':
            return b.price.compareTo(a.price);
          case 'Rating':
            return b.rating.compareTo(a.rating);
          case 'Featured':
            return (b.isFeatured ? 1 : 0).compareTo(a.isFeatured ? 1 : 0);
          default:
            return 0;
        }
      });

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
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
      appBar: AppBar(
        title: const Text('Search Properties'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // حقل البحث النصي
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search properties...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).inputDecorationTheme.fillColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // حقل الموقع
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      hintText: 'Location',
                      prefixIcon: const Icon(Icons.location_on),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).inputDecorationTheme.fillColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // شريط اختيار السعر
                  Text(
                    'Price Range',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 5000,
                    divisions: 50,
                    activeColor: Theme.of(context).colorScheme.primary,
                    labels: RangeLabels(
                      '\$${_priceRange.start.round()}',
                      '\$${_priceRange.end.round()}',
                    ),
                    onChanged: (values) => setState(() => _priceRange = values),
                  ),
                  Text(
                    '\$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // نوع العقار
                  Text(
                    'Property Type',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: _propertyTypes.map((type) {
                      final isSelected = type == _selectedPropertyType;
                      return FilterChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (selected) =>
                            setState(() => _selectedPropertyType = type),
                        selectedColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // عدد الغرف والحمامات
                  Text(
                    'Bedrooms',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  _buildChoiceChips(
                    5,
                    _bedrooms,
                    (val) => setState(() => _bedrooms = val),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Bathrooms',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  _buildChoiceChips(
                    5,
                    _bathrooms,
                    (val) => setState(() => _bathrooms = val),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // خيارات الترتيب
                  Text(
                    'Sort By',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    value: _sortBy,
                    decoration: const InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(),
                    ),
                    items: _sortOptions.map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _sortBy = value!),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // عرض نتائج البحث
                  if (_hasSearched) ...[
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Results Found: ${_searchResults.length}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_searchResults.isEmpty)
                      const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            Text('No properties match your filters'),
                          ],
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
                                // الانتقال لصفحة التفاصيل
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

          // أزرار التحكم السفلية (Footer)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
              ],
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
                    text: _isLoading ? 'Searching...' : 'Search',
                    onPressed: _isLoading ? () {} : _performSearch,
                    icon: _isLoading ? null : Icons.search,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ودجت مساعدة لاختيار الأعداد (غرف/حمامات)
  Widget _buildChoiceChips(
    int count,
    int selectedValue,
    Function(int) onSelected,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(count, (index) {
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(index == 0 ? 'Any' : '$index+'),
              selected: selectedValue == index,
              onSelected: (bool selected) => onSelected(index),
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: selectedValue == index ? Colors.white : null,
              ),
            ),
          );
        }),
      ),
    );
  }
}
