import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/category_constants.dart';
import '../../domain/entities/mod_entity.dart';
import '../providers/mod_providers.dart';
import '../widgets/app_drawer.dart';
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
    final cs = Theme.of(context).colorScheme;
    final filteredAsync = ref.watch(filteredModsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final currentSort = ref.watch(sortOrderProvider);

    // Reset page + scroll to top when category or sort changes externally
    ref.listen(selectedCategoryProvider, (_, _) => _resetPage());
    ref.listen(sortOrderProvider, (_, _) => _resetPage());

    return Scaffold(
      backgroundColor: cs.surface,
      drawer: const AppDrawer(currentRoute: '/catalogue'),
      body: RefreshIndicator(
        color: cs.primary,
        backgroundColor: cs.surface,
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
            // ── App bar ───────────────────────────────────────
            _CatalogueAppBar(searchCtrl: _searchCtrl, onClear: _clearSearch),

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
                  : _SliverModList(
                      mods: mods,
                      page: _page,
                      pageSize: _pageSize,
                    ),
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
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

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
    final cs = Theme.of(context).colorScheme;

    return SliverAppBar(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      floating: true,
      snap: true,
      elevation: 0,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: Icon(Icons.menu_rounded, color: cs.onSurface, size: 22),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: Text(
        'Catalogue',
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 17,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.1,
        ),
      ),
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
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: focusNode.hasFocus
              ? cs.primary.withValues(alpha: 0.6)
              : cs.outline.withValues(alpha: 0.3),
          width: focusNode.hasFocus ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: (v) {
          ref.read(searchQueryProvider.notifier).setSearchQuery(v);
        },
        style: TextStyle(color: cs.onSurface, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search mods, authors, tags…',
          hintStyle: TextStyle(
            color: cs.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: focusNode.hasFocus ? cs.primary : cs.outline,
            size: 20,
          ),
          suffixIcon: ValueListenableBuilder(
            valueListenable: controller,
            builder: (_, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(Icons.close_rounded, size: 17, color: cs.outline),
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
  double get minExtent => 52;
  @override
  double get maxExtent => 52;

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
    final cs = Theme.of(context).colorScheme;
    final elevated = shrinkOffset > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: cs.surface,
        border: elevated
            ? Border(
                bottom: BorderSide(
                  color: cs.outline.withValues(alpha: 0.15),
                  width: 1,
                ),
              )
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
    final cs = Theme.of(context).colorScheme;
    final categories = CategoryConstants.allCategories;

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        physics: const BouncingScrollPhysics(),
        children: [
          // Sort pill
          _SortPill(currentSort: currentSort),
          const SizedBox(width: 8),

          // Divider
          Container(
            width: 1,
            height: 28,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            color: cs.outline.withValues(alpha: 0.25),
          ),
          const SizedBox(width: 8),

          // Category chips
          ...categories.map((cat) {
            final isSelected = selectedCategory == cat;
            final icon = CategoryConstants.getIconForCategory(cat);
            final color = CategoryConstants.getColorForCategory(cat);

            return Padding(
              padding: const EdgeInsets.only(right: 7),
              child: _FilterChip(
                label: cat,
                icon: icon,
                color: color,
                isSelected: isSelected,
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.12)
              : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.5)
                : cs.outline.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? color : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : cs.onSurfaceVariant,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortPill extends ConsumerWidget {
  const _SortPill({required this.currentSort});

  final SortOrder currentSort;

  String get _label {
    switch (currentSort) {
      case SortOrder.ratingDesc:
        return '⭐ Rating';
      case SortOrder.downloadsDesc:
        return '⬇ Downloads';
      case SortOrder.newest:
        return '🕐 Newest';
      case SortOrder.none:
        return 'Sort';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isActive = currentSort != SortOrder.none;

    return GestureDetector(
      onTap: () => _showSortSheet(context, ref, currentSort),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? cs.primaryContainer : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? cs.primary.withValues(alpha: 0.4)
                : cs.outline.withValues(alpha: 0.3),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 13,
              color: isActive ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 5),
            Text(
              _label,
              style: TextStyle(
                color: isActive ? cs.primary : cs.onSurfaceVariant,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () => ref
                    .read(sortOrderProvider.notifier)
                    .setSortOrder(SortOrder.none),
                child: Icon(Icons.close_rounded, size: 13, color: cs.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSortSheet(BuildContext context, WidgetRef ref, SortOrder current) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SortSheet(current: current, ref: ref),
    );
  }
}

class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.current, required this.ref});

  final SortOrder current;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final options = [
      (order: SortOrder.none, label: 'Default', emoji: '📋'),
      (order: SortOrder.ratingDesc, label: 'Top Rated', emoji: '⭐'),
      (order: SortOrder.downloadsDesc, label: 'Most Downloaded', emoji: '⬇️'),
      (order: SortOrder.newest, label: 'Recently Updated', emoji: '🕐'),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sort by',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
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
                    color: isSelected
                        ? cs.primaryContainer
                        : cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? cs.primary.withValues(alpha: 0.4)
                          : cs.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(opt.emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          opt.label,
                          style: TextStyle(
                            color: isSelected ? cs.primary : cs.onSurface,
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_rounded, size: 18, color: cs.primary),
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
    final cs = Theme.of(context).colorScheme;
    final query = ref.watch(searchQueryProvider);
    final category = ref.watch(selectedCategoryProvider);

    return filteredAsync.maybeWhen(
      data: (mods) {
        final hasFilters = query.isNotEmpty || category != null;
        if (!hasFilters) return const SizedBox(height: 4);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  '${mods.length} result${mods.length == 1 ? '' : 's'}',
                  key: ValueKey(mods.length),
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
                    'Clear all',
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox(height: 4),
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
        separatorBuilder: (_, _) => const SizedBox(height: 6),
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
    final cs = Theme.of(context).colorScheme;
    final start = currentPage * pageSize + 1;
    final end = ((currentPage + 1) * pageSize).clamp(0, totalItems);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            // Prev button
            _PageButton(
              icon: Icons.arrow_back_ios_rounded,
              enabled: currentPage > 0,
              onTap: () => onPageChanged(currentPage - 1),
              cs: cs,
            ),

            const SizedBox(width: 12),

            // Page indicator
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page pills row
                  _PagePills(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    onPageChanged: onPageChanged,
                    cs: cs,
                  ),
                  const SizedBox(height: 5),
                  // Range label
                  Text(
                    '$start–$end of $totalItems mods',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Next button
            _PageButton(
              icon: Icons.arrow_forward_ios_rounded,
              enabled: currentPage < totalPages - 1,
              onTap: () => onPageChanged(currentPage + 1),
              cs: cs,
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
    required this.cs,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final ColorScheme cs;

  /// Returns the page numbers to show as pills (max 5 visible)
  List<int?> get _visiblePages {
    if (totalPages <= 5) {
      return List.generate(totalPages, (i) => i);
    }
    // Always show first, last, current, and neighbours
    final pages = <int?>{};
    pages.add(0);
    pages.add(totalPages - 1);
    pages.add(currentPage);
    if (currentPage > 0) pages.add(currentPage - 1);
    if (currentPage < totalPages - 1) pages.add(currentPage + 1);

    final sorted = pages.toList()..sort((a, b) => a!.compareTo(b!));

    // Insert nulls for gaps
    final result = <int?>[];
    for (int i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i]! - sorted[i - 1]! > 1) result.add(null);
      result.add(sorted[i]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _visiblePages.map((page) {
        if (page == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Text(
              '…',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
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
              color: isActive ? cs.primary : cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(7),
              border: isActive
                  ? null
                  : Border.all(color: cs.outline.withValues(alpha: 0.3)),
            ),
            alignment: Alignment.center,
            child: Text(
              '${page + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : cs.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w700,
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
    required this.cs,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? cs.primaryContainer : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled
                ? cs.primary.withValues(alpha: 0.3)
                : cs.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Icon(
          icon,
          size: 15,
          color: enabled
              ? cs.primary
              : cs.onSurfaceVariant.withValues(alpha: 0.3),
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
        separatorBuilder: (_, _) => const SizedBox(height: 6),
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
    final cs = Theme.of(context).colorScheme;
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
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                hasFilters
                    ? Icons.search_off_rounded
                    : Icons.extension_off_rounded,
                size: 34,
                color: cs.outline.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No mods found' : 'Nothing here yet',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasFilters
                  ? 'Try different keywords or remove filters.'
                  : 'Check back later for new content.',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                label: const Text('Clear filters'),
                onPressed: () {
                  ref.read(searchQueryProvider.notifier).clear();
                  ref.read(selectedCategoryProvider.notifier).clear();
                  ref
                      .read(sortOrderProvider.notifier)
                      .setSortOrder(SortOrder.none);
                },
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
    final cs = Theme.of(context).colorScheme;

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
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 30,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load mods',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
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
