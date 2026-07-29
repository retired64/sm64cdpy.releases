import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final Map<String, String> _modStatus = {};
  final Map<String, int> _modProgress = {};
  final Map<String, Timer> _pendingTimers = {};

  static const _bridgeTimeout = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(searchQueryProvider),
    );
    _sub = FloatyOverlay.onData.listen(_onOverlayData);
  }

  /// Sends the download request and starts a "did anyone answer?" timer.
  /// The main app's engine (and with it OverlayBridge's listener) can be
  /// killed by Android when the app is swiped from recents — the overlay
  /// keeps running on its own, so the message would otherwise vanish with
  /// no feedback at all.
  void _startDownload(ModEntity mod) {
    if (mod.downloadUrls.isEmpty) return;
    HapticFeedback.lightImpact();
    final title = mod.title;

    setState(() => _modStatus[title] = 'connecting');

    FloatyOverlay.shareData({
      'type': 'download_mod',
      'url': mod.downloadUrls.first,
      'modTitle': title,
    });

    _pendingTimers[title]?.cancel();
    _pendingTimers[title] = Timer(_bridgeTimeout, () {
      if (!mounted) return;
      // Still 'connecting' after the timeout → nobody on the other end
      // ever answered (main engine most likely dead).
      if (_modStatus[title] == 'connecting') {
        setState(() => _modStatus.remove(title));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No response — open the main app once, then try again',
              style: TextStyle(fontSize: 11),
            ),
            duration: Duration(seconds: 3),
            backgroundColor: _surface,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(8),
          ),
        );
      }
    });
  }

  void _onOverlayData(Object? data) {
    if (data is! Map) return;
    final type = data['type'] as String?;
    if (type == 'db_reloaded') {
      ref.invalidate(allModsProvider);
    } else if (type == 'install_progress') {
      final modTitle = data['modTitle'] as String?;
      final rawStatus = data['status'] as String?;
      final progress = data['progress'] as int?;
      if (modTitle == null || rawStatus == null || !mounted) return;

      _pendingTimers.remove(modTitle)?.cancel();

      final mapped = _mapStatus(rawStatus);
      setState(() {
        _modStatus[modTitle] = mapped;
        if (progress != null) _modProgress[modTitle] = progress;
      });

      if (mapped == 'cancelled') {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _modStatus[modTitle] == 'cancelled') {
            setState(() {
              _modStatus.remove(modTitle);
              _modProgress.remove(modTitle);
            });
          }
        });
      }
    } else if (type == 'install_error') {
      final modTitle = data['modTitle'] as String?;
      final error = data['error'] as String?;
      if (modTitle == null || !mounted) return;
      _pendingTimers.remove(modTitle)?.cancel();
      setState(() {
        _modStatus.remove(modTitle);
        _modProgress.remove(modTitle);
      });
      final message = switch (error) {
        'no_folder' => 'Select a mods folder first (Settings)',
        'auto_install_off' => 'Enable auto-install first (Settings)',
        _ => 'Download failed',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontSize: 11)),
          duration: const Duration(seconds: 3),
          backgroundColor: _surface,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(8),
        ),
      );
    }
  }

  String _mapStatus(String raw) {
    switch (raw) {
      case 'BgDownloadProgress':
        return 'downloading';
      case 'BgInstallProgress':
        return 'installing';
      case 'completed':
      case 'BgInstallCompleted':
        return 'done';
      case 'BgOperationCancelled':
        return 'cancelled';
      default:
        if (raw.contains('Progress')) return 'downloading';
        if (raw.contains('Completed')) return 'done';
        return raw;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    for (final timer in _pendingTimers.values) {
      timer.cancel();
    }
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modsAsync = ref.watch(paginatedModsProvider);
    final currentPage = ref.watch(currentPageProvider);
    final totalPages = ref.watch(totalPagesProvider);

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
                _PageIndicatorCompact(
                  current: currentPage + 1,
                  total: totalPages,
                  onPrev: currentPage > 0
                      ? () => ref
                          .read(currentPageProvider.notifier)
                          .setPage(currentPage - 1)
                      : null,
                  onNext: currentPage < totalPages - 1
                      ? () => ref
                          .read(currentPageProvider.notifier)
                          .setPage(currentPage + 1)
                      : null,
                ),
              if (totalPages > 1) const SizedBox(height: 6),
              // Mods list
              Expanded(
                child: modsAsync.when(
                  loading: () => const Center(child: _Spinner()),
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
                      itemBuilder: (context, i) => _ModTile(
                        mod: mods[i],
                        status: _modStatus[mods[i].title],
                        progress: _modProgress[mods[i].title],
                        onDownload: () => _startDownload(mods[i]),
                      ),
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
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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

// ── Page indicator (compact) ───────────────────────────────────────────────

class _PageIndicatorCompact extends StatelessWidget {
  const _PageIndicatorCompact({
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
        _ArrowButton(
            icon: Icons.chevron_left,
            enabled: onPrev != null,
            onTap: onPrev),
        const SizedBox(width: 6),
        Text('$current/$total',
            style: const TextStyle(
                color: Colors.white30, fontSize: 10, fontWeight: FontWeight.w700)),
        const SizedBox(width: 6),
        _ArrowButton(
            icon: Icons.chevron_right,
            enabled: onNext != null,
            onTap: onNext),
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
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: enabled ? _border : Colors.white10),
          color: enabled ? _surface : Colors.transparent,
        ),
        child:
            Icon(icon, size: 14, color: enabled ? _accent : Colors.white10),
      ),
    );
  }
}

// ── Mod tile ───────────────────────────────────────────────────────────────

class _ModTile extends ConsumerStatefulWidget {
  const _ModTile({
    required this.mod,
    required this.onDownload,
    this.status,
    this.progress,
  });

  final ModEntity mod;
  final VoidCallback onDownload;
  final String? status;
  final int? progress;

  @override
  ConsumerState<_ModTile> createState() => _ModTileState();
}

class _ModTileState extends ConsumerState<_ModTile> {
  bool get _isDone => widget.status == 'done';
  bool get _isConnecting => widget.status == 'connecting';
  bool get _isDownloading => widget.status == 'downloading';
  bool get _isInstalling => widget.status == 'installing';
  bool get _isActive => _isConnecting || _isDownloading || _isInstalling;
  bool get _hasSingleUrl => widget.mod.downloadUrls.length == 1;
  bool get _isCancelled => widget.status == 'cancelled';

  @override
  Widget build(BuildContext context) {
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
                child: _titleRow(),
              ),
              const SizedBox(width: 6),
              if (_isDone)
                const Icon(Icons.check_circle, size: 16, color: _accent)
              else if (!_hasSingleUrl)
                const Icon(Icons.list_alt, size: 16,
                    color: Colors.white24)
              else if (_isCancelled)
                GestureDetector(
                  onTap: widget.onDownload,
                  child: Icon(Icons.refresh, size: 16,
                      color: _accent.withValues(alpha: 0.6)),
                )
              else if (!_isActive)
                GestureDetector(
                  onTap: widget.onDownload,
                  child: Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.15),
                      border: Border.all(
                          color: _accent.withValues(alpha: 0.5)),
                    ),
                    child: const Icon(Icons.download,
                        size: 14, color: _accent),
                  ),
                )
              else
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    value: _isDownloading && widget.progress != null
                        ? widget.progress! / 100.0
                        : null,
                    color: _accent,
                    backgroundColor: _accent.withValues(alpha: 0.15),
                  ),
                ),
            ],
          ),
          if (_isActive) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: LinearProgressIndicator(
                value: _isDownloading && widget.progress != null
                    ? widget.progress! / 100.0
                    : null,
                backgroundColor: _accent.withValues(alpha: 0.1),
                color: _accent,
                minHeight: 3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _titleRow() {
    final label = _isDownloading && widget.progress != null
        ? '${widget.mod.title}  ${widget.progress}%'
        : _isInstalling
            ? '${widget.mod.title}  Installing...'
            : _isConnecting
                ? '${widget.mod.title}  Connecting...'
                : widget.mod.title;

    return Text(
      label,
      style: TextStyle(
        color: _isDone ? _accent : Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
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
