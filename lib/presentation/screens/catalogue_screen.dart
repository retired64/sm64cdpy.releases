import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/category_constants.dart';
import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../domain/entities/mod_entity.dart';
import '../providers/mod_providers.dart';
import '../widgets/app_shell.dart';
import '../widgets/mod_card.dart';

// ── Entry point ───────────────────────────────────────────────────────────────

class CatalogueScreen extends ConsumerStatefulWidget {
  const CatalogueScreen({super.key});

  @override
  ConsumerState<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends ConsumerState<CatalogueScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  int _page = 0;

  static const _pageSize = 15;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
  }

  void _onSearchChanged() => _resetPage();

  void _resetPage() {
    if (!mounted) return;
    setState(() => _page = 0);
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _goToPage(int page) {
    setState(() => _page = page);
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchCtrl.clear();
    ref.read(searchQueryProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final filteredAsync = ref.watch(filteredModsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final currentSort = ref.watch(sortOrderProvider);

    // Reset page + scroll to top when category or sort changes externally
    ref.listen(selectedCategoryProvider, (_, _) => _resetPage());
    ref.listen(sortOrderProvider, (_, _) => _resetPage());

    return RefreshIndicator(
      color: retro.background,
      backgroundColor: retro.accent,
      displacement: 80,
      onRefresh: () async {
        ref.read(localDatasourceProvider).invalidateCache();
        ref.invalidate(allModsProvider);
      },
      child: CustomScrollView(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // ── App bar ─────────────────────────────────────
          _CatalogueAppBar(searchCtrl: _searchCtrl, onClear: _clearSearch),

          // ── Section label ─────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
              child: Text('検索・カタログ', style: retro.body(size: 12)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: SectionKicker(retro: retro, label: l10n.catalogueTitle),
            ),
          ),

          // ── Filter bar ────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _FilterBarDelegate(
              selectedCategory: selectedCategory,
              currentSort: currentSort,
            ),
          ),

          // ── Results header ────────────────────────────────
          SliverToBoxAdapter(
            child: _ResultsHeader(filteredAsync: filteredAsync),
          ),

          // ── List ──────────────────────────────────────────
          filteredAsync.when(
            loading: () => _SliverSkeletonList(),
            error: (e, _) =>
                SliverFillRemaining(child: _ErrorView(message: e.toString())),
            data: (mods) => mods.isEmpty
                ? const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyView(),
                  )
                : _SliverModList(mods: mods, page: _page, pageSize: _pageSize),
          ),

          // ── Pagination bar ────────────────────────────────
          filteredAsync.maybeWhen(
            data: (mods) {
              if (mods.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              final totalPages = (mods.length / _pageSize).ceil();
              if (totalPages <= 1) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverToBoxAdapter(
                child: _PaginationBar(
                  currentPage: _page,
                  totalPages: totalPages,
                  totalItems: mods.length,
                  pageSize: _pageSize,
                  onPageChanged: _goToPage,
                ),
              );
            },
            orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ── App bar (hero) ───────────────────────────────────────────────────────────
// Cabecera expandible: franjas diagonales de fondo (como una tarjeta de
// release), título grande + kicker japonés, y el buscador anclado abajo.
// Al hacer scroll se colapsa a una barra simple, igual que el resto de
// screens de la app.

class _CatalogueAppBar extends ConsumerStatefulWidget {
  const _CatalogueAppBar({required this.searchCtrl, required this.onClear});

  final TextEditingController searchCtrl;
  final VoidCallback onClear;

  @override
  ConsumerState<_CatalogueAppBar> createState() => _CatalogueAppBarState();
}

class _CatalogueAppBarState extends ConsumerState<_CatalogueAppBar> {
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final filteredAsync = ref.watch(filteredModsProvider);
    final count = filteredAsync.maybeWhen(
      data: (mods) => mods.length,
      orElse: () => null,
    );

    return SliverAppBar(
      backgroundColor: retro.background,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      floating: true,
      snap: true,
      elevation: 0,
      shape: Border(bottom: BorderSide(color: retro.border, width: 3)),
      leading: const DrawerMenuButton(),
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'MOD ',
              style: retro.heading(size: 18, color: retro.ink),
            ),
            TextSpan(
              text: 'CATALOG',
              style: retro.heading(size: 18, color: retro.accent),
            ),
          ],
        ),
      ),
      actions: [
        if (count != null)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SkewChip(
              retro: retro,
              icon: Icons.extension_rounded,
              label: l10n.catalogueModCount(count),
              dense: true,
              selected: true,
            ),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: _SearchField(
            controller: widget.searchCtrl,
            focusNode: _focus,
            onClear: widget.onClear,
          ),
        ),
      ),
    );
  }
}

// ── Search field ──────────────────────────────────────────────────────────────

class _SearchField extends ConsumerWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: retro.surface,
        border: Border.all(color: retro.border, width: 2.5),
        boxShadow: focusNode.hasFocus ? [] : retro.hardShadow(dx: 3, dy: 3),
      ),
      transform: focusNode.hasFocus
          ? Matrix4.translationValues(3.0, 3.0, 0.0)
          : Matrix4.identity(),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: (v) {
          ref.read(searchQueryProvider.notifier).setSearchQuery(v);
        },
        style: TextStyle(
          color: retro.ink,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: l10n.catalogueSearchHint,
          hintStyle: TextStyle(
            color: retro.inkDim,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: focusNode.hasFocus ? retro.accent : retro.inkDim,
            size: 20,
          ),
          suffixIcon: ValueListenableBuilder(
            valueListenable: controller,
            builder: (_, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(Icons.close_rounded, size: 17, color: retro.inkDim),
                onPressed: onClear,
                splashRadius: 16,
              );
            },
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

// ── Filter bar (pinned) ───────────────────────────────────────────────────────

class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  const _FilterBarDelegate({
    required this.selectedCategory,
    required this.currentSort,
  });

  final String? selectedCategory;
  final SortOrder currentSort;

  @override
  double get minExtent => 60;
  @override
  double get maxExtent => 60;

  @override
  bool shouldRebuild(_FilterBarDelegate old) =>
      old.selectedCategory != selectedCategory ||
      old.currentSort != currentSort;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final retro = RetroTheme.of(context);
    final elevated = shrinkOffset > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: retro.background,
        border: elevated
            ? Border(bottom: BorderSide(color: retro.border, width: 3))
            : null,
      ),
      child: _FilterBar(
        selectedCategory: selectedCategory,
        currentSort: currentSort,
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.selectedCategory, required this.currentSort});

  final String? selectedCategory;
  final SortOrder currentSort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retro = RetroTheme.of(context);
    final categories = CategoryConstants.allCategories;

    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        physics: const BouncingScrollPhysics(),
        children: [
          // Sort chip
          _SortChip(retro: retro, currentSort: currentSort),
          const SizedBox(width: 8),

          // Divider
          Container(
            width: 3,
            height: 26,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            color: retro.border,
          ),
          const SizedBox(width: 8),

          // Category chips
          ...categories.map((cat) {
            final isSelected = selectedCategory == cat;
            final icon = CategoryConstants.getIconForCategory(cat);
            final color = CategoryConstants.getColorForCategory(cat);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SkewChip(
                retro: retro,
                label: cat.toUpperCase(),
                icon: icon,
                selected: isSelected,
                dense: true,
                accentColor: color,
                onTap: () {
                  final notifier = ref.read(selectedCategoryProvider.notifier);
                  notifier.setCategory(isSelected ? null : cat);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SortChip extends ConsumerWidget {
  const _SortChip({required this.retro, required this.currentSort});

  final RetroTheme retro;
  final SortOrder currentSort;

  String _label(AppLocalizations l10n) {
    switch (currentSort) {
      case SortOrder.ratingDesc:
        return l10n.catalogueRating;
      case SortOrder.downloadsDesc:
        return l10n.catalogueDownloads;
      case SortOrder.newest:
        return l10n.catalogueNewest;
      case SortOrder.none:
        return l10n.catalogueSort;
    }
  }

  IconData get _icon {
    switch (currentSort) {
      case SortOrder.ratingDesc:
        return Icons.star_rounded;
      case SortOrder.downloadsDesc:
        return Icons.download_rounded;
      case SortOrder.newest:
        return Icons.access_time_rounded;
      case SortOrder.none:
        return Icons.tune_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isActive = currentSort != SortOrder.none;

    return SkewChip(
      retro: retro,
      label: _label(l10n),
      icon: _icon,
      selected: isActive,
      dense: true,
      trailing: isActive ? Icons.close_rounded : null,
      onTap: () {
        if (isActive) {
          ref.read(sortOrderProvider.notifier).setSortOrder(SortOrder.none);
        } else {
          _showSortSheet(context, ref, currentSort);
        }
      },
    );
  }

  void _showSortSheet(BuildContext context, WidgetRef ref, SortOrder current) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: retro.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: retro.border, width: 3),
        borderRadius: BorderRadius.zero,
      ),
      builder: (_) => _SortSheet(retro: retro, current: current, ref: ref),
    );
  }
}

class _SortSheet extends StatelessWidget {
  const _SortSheet({
    required this.retro,
    required this.current,
    required this.ref,
  });

  final RetroTheme retro;
  final SortOrder current;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = [
      (order: SortOrder.none, icon: Icons.list_rounded, label: l10n.catalogueSortDefault),
      (
        order: SortOrder.ratingDesc,
        icon: Icons.star_rounded,
        label: l10n.catalogueSortTopRated,
      ),
      (
        order: SortOrder.downloadsDesc,
        icon: Icons.download_rounded,
        label: l10n.catalogueSortMostDownloaded,
      ),
      (
        order: SortOrder.newest,
        icon: Icons.access_time_rounded,
        label: l10n.catalogueSortRecentlyUpdated,
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 36, height: 4, color: retro.border)),
            const SizedBox(height: 18),
            Text(l10n.sectionSortBy, style: retro.heading(size: 16)),
            const SizedBox(height: 14),
            ...options.map((opt) {
              final isSelected = current == opt.order;
              return GestureDetector(
                onTap: () {
                  ref.read(sortOrderProvider.notifier).setSortOrder(opt.order);
                  Navigator.of(context).pop();
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? retro.accent : retro.surfaceAlt,
                    border: Border.all(color: retro.border, width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        opt.icon,
                        size: 17,
                        color: isSelected ? retro.background : retro.ink,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          opt.label.toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? retro.background : retro.ink,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: retro.background,
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Results header ────────────────────────────────────────────────────────────

class _ResultsHeader extends ConsumerWidget {
  const _ResultsHeader({required this.filteredAsync});

  final AsyncValue<List<ModEntity>> filteredAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final query = ref.watch(searchQueryProvider);
    final category = ref.watch(selectedCategoryProvider);

    return filteredAsync.maybeWhen(
      data: (mods) {
        final hasFilters = query.isNotEmpty || category != null;
        if (!hasFilters) return const SizedBox(height: 8);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  l10n.catalogueResultCount(mods.length),
                  key: ValueKey(mods.length),
                  style: TextStyle(
                    color: retro.inkDim,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const Spacer(),
              if (hasFilters)
                GestureDetector(
                  onTap: () {
                    ref.read(searchQueryProvider.notifier).clear();
                    ref.read(selectedCategoryProvider.notifier).clear();
                    ref
                        .read(sortOrderProvider.notifier)
                        .setSortOrder(SortOrder.none);
                  },
                  child: Text(
                    l10n.catalogueClearAll,
                    style: TextStyle(
                      color: retro.accent,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox(height: 8),
    );
  }
}

// ── Sliver mod list (paginated) ───────────────────────────────────────────────

class _SliverModList extends StatelessWidget {
  const _SliverModList({
    required this.mods,
    required this.page,
    required this.pageSize,
  });

  final List<ModEntity> mods;
  final int page;
  final int pageSize;

  @override
  Widget build(BuildContext context) {
    final start = page * pageSize;
    final end = (start + pageSize).clamp(0, mods.length);
    final pageMods = mods.sublist(start, end);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.separated(
        itemCount: pageMods.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final mod = pageMods[index];
          return ModCard(
            mod: mod,
            onTap: () => context.push('/mod/${Uri.encodeComponent(mod.id)}'),
          );
        },
      ),
    );
  }
}

// ── Pagination bar ────────────────────────────────────────────────────────────

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final start = currentPage * pageSize + 1;
    final end = ((currentPage + 1) * pageSize).clamp(0, totalItems);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: retro.surface,
          border: Border.all(color: retro.border, width: 3),
          boxShadow: retro.hardShadow(),
        ),
        child: Row(
          children: [
            _PageButton(
              icon: Icons.arrow_back_ios_rounded,
              enabled: currentPage > 0,
              onTap: () => onPageChanged(currentPage - 1),
              retro: retro,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PagePills(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    onPageChanged: onPageChanged,
                    retro: retro,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.cataloguePaginationRange(start, end, totalItems),
                    style: TextStyle(
                      color: retro.inkDim,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _PageButton(
              icon: Icons.arrow_forward_ios_rounded,
              enabled: currentPage < totalPages - 1,
              onTap: () => onPageChanged(currentPage + 1),
              retro: retro,
            ),
          ],
        ),
      ),
    );
  }
}

class _PagePills extends StatelessWidget {
  const _PagePills({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.retro,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final RetroTheme retro;

  /// Returns the page numbers to show as pills (max 5 visible)
  List<int?> get _visiblePages {
    if (totalPages <= 5) {
      return List.generate(totalPages, (i) => i);
    }
    final pages = <int?>{};
    pages.add(0);
    pages.add(totalPages - 1);
    pages.add(currentPage);
    if (currentPage > 0) pages.add(currentPage - 1);
    if (currentPage < totalPages - 1) pages.add(currentPage + 1);

    final sorted = pages.toList()..sort((a, b) => a!.compareTo(b!));

    final result = <int?>[];
    for (int i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i]! - sorted[i - 1]! > 1) result.add(null);
      result.add(sorted[i]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _visiblePages.map((page) {
        if (page == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Text(
              l10n.catalogueEllipsis,
              style: TextStyle(
                color: retro.inkDim,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }
        final isActive = page == currentPage;
        return GestureDetector(
          onTap: isActive ? null : () => onPageChanged(page),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isActive ? 28 : 24,
            height: 24,
            decoration: BoxDecoration(
              color: isActive ? retro.accent : retro.surfaceAlt,
              border: Border.all(
                color: retro.border,
                width: isActive ? 2 : 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '${page + 1}',
              style: TextStyle(
                color: isActive ? retro.background : retro.inkDim,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.retro,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final RetroTheme retro;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? retro.accent : retro.surfaceAlt,
          border: Border.all(
            color: enabled ? retro.border : retro.border.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          size: 15,
          color: enabled
              ? retro.background
              : retro.inkDim.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _SliverSkeletonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.separated(
        itemCount: 6,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, _) => const ModCardSkeleton(),
      ),
    );
  }
}

// ── Empty view ────────────────────────────────────────────────────────────────

class _EmptyView extends ConsumerWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final query = ref.watch(searchQueryProvider);
    final category = ref.watch(selectedCategoryProvider);
    final hasFilters = query.isNotEmpty || category != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: retro.surface,
                border: Border.all(color: retro.border, width: 3),
                boxShadow: retro.hardShadow(),
              ),
              child: Icon(
                hasFilters
                    ? Icons.search_off_rounded
                    : Icons.extension_off_rounded,
                size: 30,
                color: retro.accent,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              hasFilters ? l10n.catalogueNoModsFound : l10n.catalogueNothingHere,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: retro.ink,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
? l10n.catalogueEmptyHint1
                    : l10n.catalogueEmptyHint2,
              style: TextStyle(color: retro.inkDim, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: 22),
              GestureDetector(
                onTap: () {
                  ref.read(searchQueryProvider.notifier).clear();
                  ref.read(selectedCategoryProvider.notifier).clear();
                  ref
                      .read(sortOrderProvider.notifier)
                      .setSortOrder(SortOrder.none);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: retro.accent,
                    border: Border.all(color: retro.border, width: 2.5),
                    boxShadow: retro.hardShadow(dx: 3, dy: 3),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.filter_alt_off_rounded,
                        size: 15,
                        color: retro.background,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.catalogueClearFilters,
                        style: TextStyle(
                          color: retro.background,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: retro.surface,
                border: Border.all(color: retro.red, width: 3),
                boxShadow: retro.hardShadow(),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 28,
                color: retro.red,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.catalogueFailedToLoad,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: retro.ink,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(color: retro.inkDim, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
