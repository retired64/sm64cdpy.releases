import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/mod_entity.dart';
import '../providers/mod_providers.dart';
import '../widgets/app_drawer.dart';
import '../widgets/mod_card.dart';

class FavouritesScreen extends ConsumerWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favsAsync = ref.watch(favouriteModsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const AppDrawer(currentRoute: '/favourites'),
      appBar: AppBar(title: const Text('Favourites')),
      body: favsAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        error: (e, _) => Center(
          child: Text(
            e.toString(),
            style: TextStyle(
              color: AppTheme.textMutedColor(
                Theme.of(context).brightness == Brightness.dark,
              ),
            ),
          ),
        ),
        data: (mods) {
          if (mods.isEmpty) return const _EmptyFavourites();
          return _FavList(mods: mods);
        },
      ),
    );
  }
}

class _FavList extends StatelessWidget {
  const _FavList({required this.mods});

  final List<ModEntity> mods;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: mods.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final mod = mods[i];
        return ModCard(
          mod: mod,
          onTap: () => context.push('/mod/${Uri.encodeComponent(mod.id)}'),
        );
      },
    );
  }
}

class _EmptyFavourites extends StatelessWidget {
  const _EmptyFavourites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(36),
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 36,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No favourites yet',
            style: TextStyle(
              color: AppTheme.textPrimaryColor(
                Theme.of(context).brightness == Brightness.dark,
              ),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap ❤️ on any mod to save it here.',
            style: TextStyle(
              color: AppTheme.textMutedColor(
                Theme.of(context).brightness == Brightness.dark,
              ),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.explore_rounded, size: 18),
            label: const Text('Browse Mods'),
            onPressed: () => context.go('/'),
          ),
        ],
      ),
    );
  }
}
