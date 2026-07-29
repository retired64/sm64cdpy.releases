import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/mod_entity.dart';
import '../presentation/providers/mod_providers.dart';

const _bg = Color(0xFF262A38);
const _surface = Color(0xFF2B2F3E);
const _accent = Color(0xFF00D9C0);
const _border = Color(0xFF5B5E6B);

class OverlayPanel extends ConsumerStatefulWidget {
  const OverlayPanel({super.key});

  @override
  ConsumerState<OverlayPanel> createState() => _OverlayPanelState();
}

class _OverlayPanelState extends ConsumerState<OverlayPanel> {
  StreamSubscription<Object?>? _sub;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    // Created ONCE and kept alive for the lifetime of this State,
    // so the cursor/selection stays consistent across rebuilds.
    _searchController = TextEditingController(
      text: ref.read(searchQueryProvider),
    );
    _sub = FloatyOverlay.onData.listen((data) {
      if (data is Map && data['type'] == 'db_reloaded') {
        ref.invalidate(allModsProvider);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modsAsync = ref.watch(paginatedModsProvider);
    final currentPage = ref.watch(currentPageProvider);
    final totalPages = ref.watch(totalPagesProvider);

    // Only push provider -> controller when the change came from
    // OUTSIDE this field (e.g. search cleared elsewhere). If it already
    // matches what the user is typing, we leave the controller alone
    // so we never fight the user's cursor.
    ref.listen<String>(searchQueryProvider, (previous, next) {
      if (next != _searchController.text) {
        _searchController.value = _searchController.value.copyWith(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
          composing: TextRange.empty,
        );
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              // Page indicator
              if (totalPages > 1)
                _PageIndicator(
                  current: currentPage + 1,
                  total: totalPages,
                  onPrev: currentPage > 0
                      ? () =>
                          ref.read(currentPageProvider.notifier).setPage(
                                currentPage - 1,
                              )
                      : null,
                  onNext: currentPage < totalPages - 1
                      ? () =>
                          ref.read(currentPageProvider.notifier).setPage(
                                currentPage + 1,
                              )
                      : null,
                ),
              if (totalPages > 1) const SizedBox(height: 6),
              // Mods list
              Expanded(
                child: modsAsync.when(
                  loading: () =>
                      const Center(child: _Spinner()),
                  error: (err, _) => Center(
                    child: Text('Error',
                        style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                  ),
                  data: (mods) {
                    if (mods.isEmpty) {
                      return Center(
                        child: Text(
                          ref.watch(searchQueryProvider).isEmpty
                              ? 'No mods'
                              : 'No results',
                          style: const TextStyle(color: Colors.white24, fontSize: 13),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: mods.length,
                      itemBuilder: (context, i) => _ModTile(mod: mods[i]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Search bar — at bottom, above keyboard
              Container(
                decoration: BoxDecoration(
                  color: _surface,
                  border: Border.all(color: _border.withValues(alpha: 0.4)),
                ),
                child: TextField(
                  controller: _searchController,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.search,
                  onChanged: (v) {
                    ref.read(searchQueryProvider.notifier).setSearchQuery(v);
                    ref.read(currentPageProvider.notifier).setPage(0);
                  },
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'SEARCH MODS...',
                    hintStyle: TextStyle(color: Colors.white24, fontSize: 11),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    border: InputBorder.none,
                    prefixIcon:
                        Icon(Icons.search, color: Colors.white24, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Page indicator ─────────────────────────────────────────────────────────

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.current,
    required this.total,
    this.onPrev,
    this.onNext,
  });

  final int current;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ArrowButton(icon: Icons.chevron_left, enabled: onPrev != null, onTap: onPrev),
        const SizedBox(width: 10),
        Text(
          '$current / $total',
          style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 10),
        _ArrowButton(icon: Icons.chevron_right, enabled: onNext != null, onTap: onNext),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.enabled, this.onTap});
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled ? _border : Colors.white10,
          ),
          color: enabled ? _surface : Colors.transparent,
        ),
        child: Icon(icon, size: 16,
            color: enabled ? _accent : Colors.white10),
      ),
    );
  }
}

// ── Mod tile ───────────────────────────────────────────────────────────────

class _ModTile extends ConsumerWidget {
  const _ModTile({required this.mod});
  final ModEntity mod;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(color: _border.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  mod.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.download, size: 14,
                  color: _accent.withValues(alpha: 0.5)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Spinner ────────────────────────────────────────────────────────────────

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2, color: _accent),
    );
  }
}
