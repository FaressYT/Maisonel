import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/property_card.dart';
import '../../theme.dart';
import '../listings/property_details_screen.dart';
import '../../cubits/user/user_cubit.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Load user data including favorites
    context.read<UserCubit>().loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load favorites: ${state.message}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => context.read<UserCubit>().loadUserData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is UserLoaded) {
            final favorites = state.favorites;
            return favorites.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () async =>
                        context.read<UserCubit>().loadUserData(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final property = favorites[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: PropertyCard(
                            property: property,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PropertyDetailsScreen(property: property),
                                ),
                              ).then(
                                (_) => context.read<UserCubit>().loadUserData(),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text('Start adding properties to your favorites!'),
        ],
      ),
    );
  }
}
