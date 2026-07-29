import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/mod_entity.dart';
import '../presentation/providers/mod_providers.dart';

class OverlayPanel extends ConsumerStatefulWidget {
  const OverlayPanel({super.key});

  @override
  ConsumerState<OverlayPanel> createState() => _OverlayPanelState();
}

class _OverlayPanelState extends ConsumerState<OverlayPanel> {
  StreamSubscription<Object?>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = FloatyOverlay.onData.listen((data) {
      if (data is Map && data['type'] == 'db_reloaded') {
        ref.invalidate(allModsProvider);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modsAsync = ref.watch(filteredModsProvider);
    final searchController = TextEditingController(
      text: ref.read(searchQueryProvider),
    );

    return Material(
      color: const Color(0xFF262A38),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              // Search bar
              TextField(
                controller: searchController,
                onChanged: (v) =>
                    ref.read(searchQueryProvider.notifier).setSearchQuery(v),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Search mods...',
                  hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  prefixIcon: Icon(Icons.search,
                      color: Colors.white.withValues(alpha: 0.3), size: 20),
                ),
              ),
              const SizedBox(height: 8),
              // Results
              Expanded(
                child: modsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00D9C0)),
                  ),
                  error: (err, _) => Center(
                    child: Text('Error: $err',
                        style: const TextStyle(color: Colors.redAccent)),
                  ),
                  data: (mods) {
                    if (mods.isEmpty) {
                      return const Center(
                        child: Text('No mods found',
                            style: TextStyle(
                                color: Colors.white38, fontSize: 14)),
                      );
                    }
                    return ListView.builder(
                      itemCount: mods.length,
                      itemBuilder: (context, i) {
                        final mod = mods[i];
                        return _ModResultTile(mod: mod);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModResultTile extends ConsumerWidget {
  const _ModResultTile({required this.mod});
  final ModEntity mod;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mod.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  mod.author,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.download,
              size: 16, color: Colors.white.withValues(alpha: 0.4)),
        ],
      ),
    );
  }
}
