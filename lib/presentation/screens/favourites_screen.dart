import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/retro_theme.dart';

import '../../l10n/app_localizations.dart';
import '../providers/mod_providers.dart';
import '../providers/extra_providers.dart';
import '../widgets/app_shell.dart';
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
    final l10n = AppLocalizations.of(context);
    final retro = RetroTheme.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: retro.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: const DrawerMenuButton(),
          title: Text(l10n.favouritesTitle, style: retro.heading(size: 18)),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: l10n.favTabMods),
              Tab(text: l10n.favTabVip),
              Tab(text: l10n.favTabDynos),
              Tab(text: l10n.favTabTouch),
            ],
            indicatorColor: retro.accent,
            labelColor: retro.accent,
            unselectedLabelColor: retro.inkDim,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: retro.accent, width: 3),
              insets: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _ModsFavTab(),
              _VipFavTab(),
              _DynosFavTab(),
              _TouchFavTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Mods tab ───────────────────────────────────────────────────────────────

class _ModsFavTab extends ConsumerWidget {
  const _ModsFavTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retro = RetroTheme.of(context);
    final favsAsync = ref.watch(favouriteModsProvider);
    return favsAsync.when(
      loading: () =>
          Center(child: CircularProgressIndicator(color: retro.accent)),
      error: (e, _) => Center(
        child: Text(
          e.toString(),
          style: retro.body(size: 13, color: retro.inkDim),
        ),
      ),
      data: (mods) {
        if (mods.isEmpty) return const _EmptyFavourites(type: 'mods');
        return ListView.separated(
          shrinkWrap: true,
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
    final retro = RetroTheme.of(context);
    final favsAsync = ref.watch(favouriteVipModsProvider);
    return favsAsync.when(
      loading: () =>
          Center(child: CircularProgressIndicator(color: retro.accent)),
      error: (e, _) => Center(
        child: Text(
          e.toString(),
          style: retro.body(size: 13, color: retro.inkDim),
        ),
      ),
      data: (mods) {
        if (mods.isEmpty) return const _EmptyFavourites(type: 'VIP mods');
        return ListView.separated(
          shrinkWrap: true,
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
    final retro = RetroTheme.of(context);
    final favsAsync = ref.watch(favouriteDynosProvider);
    return favsAsync.when(
      loading: () =>
          Center(child: CircularProgressIndicator(color: retro.accent)),
      error: (e, _) => Center(
        child: Text(
          e.toString(),
          style: retro.body(size: 13, color: retro.inkDim),
        ),
      ),
      data: (mods) {
        if (mods.isEmpty) return const _EmptyFavourites(type: 'DynOS');
        return ListView.separated(
          shrinkWrap: true,
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
    final retro = RetroTheme.of(context);
    final favsAsync = ref.watch(favouriteTouchControlsProvider);
    return favsAsync.when(
      loading: () =>
          Center(child: CircularProgressIndicator(color: retro.accent)),
      error: (e, _) => Center(
        child: Text(
          e.toString(),
          style: retro.body(size: 13, color: retro.inkDim),
        ),
      ),
      data: (mods) {
        if (mods.isEmpty) return const _EmptyFavourites(type: 'Touch Controls');
        return ListView.separated(
          shrinkWrap: true,
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
    final l10n = AppLocalizations.of(context);
    final retro = RetroTheme.of(context);

    String emptyTitle() {
      switch (type) {
        case 'mods': return l10n.favEmptyMods;
        case 'VIP mods': return l10n.favEmptyVip;
        case 'DynOS': return l10n.favEmptyDynos;
        case 'Touch Controls': return l10n.favEmptyTouch;
        default: return 'No $type favourited yet';
      }
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: retro.surfaceAlt,
              borderRadius: RetroTheme.radius,
              border: Border.all(color: retro.accent, width: 2),
            ),
            child: Icon(Icons.favorite_border, size: 36, color: retro.accent),
          ),
          const SizedBox(height: 16),
          Text(emptyTitle(), style: retro.heading(size: 18)),
          const SizedBox(height: 8),
          Text(
            l10n.favEmptyHint(type),
            style: retro.body(size: 13),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => context.go(
              type == 'mods'
                  ? '/'
                  : type == 'VIP mods'
                  ? '/vip'
                  : type == 'DynOS'
                  ? '/dynos'
                  : '/touch-controls',
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              decoration: BoxDecoration(
                color: retro.accent,
                borderRadius: RetroTheme.radius,
                boxShadow: retro.hardShadow(dx: 3, dy: 3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.explore, size: 18, color: retro.background),
                  const SizedBox(width: 8),
                  Text(
                    l10n.favBrowse,
                    style: retro.heading(size: 12, color: retro.background),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
