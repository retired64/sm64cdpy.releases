import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

import '../providers/mod_providers.dart';
import '../providers/extra_providers.dart';
import '../widgets/app_drawer.dart';
import '../widgets/mod_card.dart';
import 'vip_mods_screen.dart';
import 'dynos_screen.dart';
import 'touch_controls_screen.dart';

class FavouritesScreen extends ConsumerStatefulWidget {
  const FavouritesScreen({super.key});

  @override
  ConsumerState<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends ConsumerState<FavouritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const AppDrawer(currentRoute: '/favourites'),
      appBar: AppBar(
        title: const Text('Favourites'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mods'),
            Tab(text: 'VIP'),
            Tab(text: 'DynOS'),
            Tab(text: 'Touch'),
          ],
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ModsFavTab(),
          _VipFavTab(),
          _DynosFavTab(),
          _TouchFavTab(),
        ],
      ),
    );
  }
}

// ── Mods tab ───────────────────────────────────────────────────────────────

class _ModsFavTab extends ConsumerWidget {
  const _ModsFavTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favsAsync = ref.watch(favouriteModsProvider);
    return favsAsync.when(
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
        if (mods.isEmpty) return const _EmptyFavourites(type: 'mods');
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
      },
    );
  }
}

// ── VIP mods tab ───────────────────────────────────────────────────────────

class _VipFavTab extends ConsumerWidget {
  const _VipFavTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favsAsync = ref.watch(favouriteVipModsProvider);
    return favsAsync.when(
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
        if (mods.isEmpty) return const _EmptyFavourites(type: 'VIP mods');
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: mods.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final mod = mods[i];
            return VipModCard(mod: mod);
          },
        );
      },
    );
  }
}

// ── DynOS tab ──────────────────────────────────────────────────────────────

class _DynosFavTab extends ConsumerWidget {
  const _DynosFavTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favsAsync = ref.watch(favouriteDynosProvider);
    return favsAsync.when(
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
        if (mods.isEmpty) return const _EmptyFavourites(type: 'DynOS');
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: mods.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final mod = mods[i];
            return DynosCard(mod: mod);
          },
        );
      },
    );
  }
}

// ── Touch controls tab ─────────────────────────────────────────────────────

class _TouchFavTab extends ConsumerWidget {
  const _TouchFavTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favsAsync = ref.watch(favouriteTouchControlsProvider);
    return favsAsync.when(
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
        if (mods.isEmpty) return const _EmptyFavourites(type: 'Touch Controls');
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: mods.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final mod = mods[i];
            return TouchControlCard(mod: mod);
          },
        );
      },
    );
  }
}

// ── Empty state (shared) ──────────────────────────────────────────────────

class _EmptyFavourites extends StatelessWidget {
  const _EmptyFavourites({required this.type});
  final String type;

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
            'No $type favourited yet',
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
            'Tap ❤️ on any $type to save it here.',
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
            label: const Text('Browse'),
            onPressed: () => context.go(
              type == 'mods'
                  ? '/'
                  : type == 'VIP mods'
                      ? '/vip'
                      : type == 'DynOS'
                          ? '/dynos'
                          : '/touch-controls',
            ),
          ),
        ],
      ),
    );
  }
}
