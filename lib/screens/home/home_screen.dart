import 'package:flutter/material.dart';
import 'package:maisonel_v02/services/api_service.dart';
import '../../theme.dart';
import '../../models/property.dart';
import '../../models/user.dart';
import '../../widgets/property_card.dart';
import '../listings/property_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// ... الإضافات في بداية الكلاس
class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Property>> _propertiesFuture;
  final User? _currentUser = ApiService.currentUser;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Apartment',
    'House',
    'Villa',
    'Studio',
  ];

  @override
  void initState() {
    super.initState();
    _propertiesFuture = ApiService.getAvailableApartments();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _propertiesFuture = ApiService.getAvailableApartments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: FutureBuilder<List<Property>>(
            future: _propertiesFuture,
            builder: (context, snapshot) {
              // 1. حالة التحميل
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // 2. حالة الخطأ
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${snapshot.error}'),
                      ElevatedButton(
                        onPressed: _handleRefresh,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              // 3. استلام البيانات بنجاح
              final allProperties = snapshot.data ?? [];

              // منطق التصفية (Filtering Logic) - تم نقله إلى هنا ليعمل على بيانات السيرفر
              final List<Property> filteredProperties =
                  _selectedCategory == 'All'
                  ? allProperties
                  : allProperties
                        .where((p) => p.propertyType == _selectedCategory)
                        .toList();

              final List<Property> featuredProperties = allProperties
                  .where((p) => p.isFeatured)
                  .toList();

              if (allProperties.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: CustomScrollView(
                    slivers: [
                      _buildAppBar(context),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(),
                      ),
                    ],
                  ),
                );
              }

              return CustomScrollView(
                slivers: [
                  _buildAppBar(context),

                  // Content
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.md),

                        // Category Filters
                        _buildCategoryList(),

                        const SizedBox(height: AppSpacing.lg),

                        // Featured Properties Section
                        if (featuredProperties.isNotEmpty) ...[
                          _buildSectionHeader('Featured'),
                          const SizedBox(height: AppSpacing.sm),
                          _buildHorizontalList(featuredProperties),
                          const SizedBox(height: AppSpacing.lg),
                        ],

                        _buildSectionHeader('Popular Properties'),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ),
                  ),

                  // Popular Properties Grid (Vertical List)
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: PropertyCard(
                            property: filteredProperties[index],
                            onTap: () =>
                                _navigateToDetails(filteredProperties[index]),
                          ),
                        );
                      }, childCount: filteredProperties.length),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // --- دوال مساعدة لتنظيف الكود (Helper Methods) ---

  Widget _buildCategoryList() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) =>
                  setState(() => _selectedCategory = category),
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(color: isSelected ? Colors.white : null),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalList(List<Property> properties) {
    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: properties.length,
        itemBuilder: (context, index) {
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: AppSpacing.md),
            child: PropertyCard(
              property: properties[index],
              onTap: () => _navigateToDetails(properties[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
    );
  }

  void _navigateToDetails(Property property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailsScreen(property: property),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.primary,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(gradient: AppColors.primaryGradient),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Hello, ${_currentUser?.name.split(' ').first ?? 'Guest'} 👋',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textWhite,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Find your dream home',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textWhite.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bedroom_parent_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No properties found',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later for new listings or refresh the page',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
