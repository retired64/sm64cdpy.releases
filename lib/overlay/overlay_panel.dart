import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import 'overlay_sections.dart';

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
  final Map<String, String> _modStatus = {};
  final Map<String, int> _modProgress = {};
  final Map<String, Timer> _pendingTimers = {};
  bool _autoInstall = false;

  final _searchCtrl = TextEditingController();

  static const _bridgeTimeout = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _sub = FloatyOverlay.onData.listen(_onOverlayData);
    FloatyOverlay.shareData({'type': 'panel_opened'});
    _loadAutoInstall();
  }

  Future<void> _loadAutoInstall() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() =>
          _autoInstall = prefs.getBool(AppConstants.autoInstallModsKey) ?? false);
    }
  }

  Future<void> _toggleAutoInstall(bool value) async {
    setState(() => _autoInstall = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.autoInstallModsKey, value);
  }

  void _startDownload(OverlayModItem mod) {
    if (mod.downloadUrls.isEmpty) return;
    HapticFeedback.lightImpact();
    final title = mod.title;

    setState(() => _modStatus[title] = 'connecting');

    FloatyOverlay.shareData({
      'type': 'download_mod',
      'url': mod.downloadUrls.first,
      'modTitle': title,
      'section': mod.section.name,
    });

    _pendingTimers[title]?.cancel();
    _pendingTimers[title] = Timer(_bridgeTimeout, () {
      if (!mounted) return;
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
      ref.invalidate(overlayAllItems);
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
        'no_folder' => 'Select a folder first (Settings)',
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
    _searchCtrl.dispose();
    super.dispose();
  }

  void _switchSection(OverlaySection s) {
    if (s == ref.read(overlaySectionProvider)) return;
    ref.read(overlaySectionProvider.notifier).select(s);
    _searchCtrl.clear();
    ref.read(searchProviderFor(s).notifier).set('');
    ref.read(pageProviderFor(s).notifier).reset();
  }

  void _onSearchChanged(String v) {
    final section = ref.read(overlaySectionProvider);
    ref.read(searchProviderFor(section).notifier).set(v);
    ref.read(pageProviderFor(section).notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final section = ref.watch(overlaySectionProvider);
    final items = ref.watch(overlayPaginatedItems);
    final page = ref.watch(pageProviderFor(section));
    final totalPages = ref.watch(overlayTotalPages);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
          child: Column(
            children: [
              _SectionTabs(active: section, onTap: _switchSection),
              const SizedBox(height: 4),
              if (totalPages > 1)
                _PageBar(
                  current: page + 1,
                  total: totalPages,
                  onPrev: page > 0
                      ? () => ref
                          .read(pageProviderFor(section).notifier)
                          .set(page - 1)
                      : null,
                  onNext: page < totalPages - 1
                      ? () => ref
                          .read(pageProviderFor(section).notifier)
                          .set(page + 1)
                      : null,
                ),
              if (totalPages > 1) const SizedBox(height: 4),
              Expanded(
                child: items.when(
                  loading: () => const Center(child: _Spinner()),
                  error: (err, _) => Center(
                    child: Text('Error',
                        style: TextStyle(
                            color: Colors.redAccent, fontSize: 12)),
                  ),
                  data: (mods) {
                    if (mods.isEmpty) {
                      return Center(
                        child: Text(
                          'No results',
                          style: const TextStyle(
                              color: Colors.white24, fontSize: 12),
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
              const SizedBox(height: 6),
              _SearchBar(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
              ),
              const SizedBox(height: 4),
              _AutoInstallToggle(
                value: _autoInstall,
                onTap: () => _toggleAutoInstall(!_autoInstall),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTabs extends StatelessWidget {
  const _SectionTabs({required this.active, required this.onTap});

  final OverlaySection active;
  final ValueChanged<OverlaySection> onTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: OverlaySection.values.map((s) {
          final isActive = s == active;
          return GestureDetector(
            onTap: () => onTap(s),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isActive ? _accent : Colors.white10,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                s.label,
                style: TextStyle(
                  color: isActive ? _accent : _border,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PageBar extends StatelessWidget {
  const _PageBar({
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
        _ArrowIcon(
            icon: Icons.chevron_left, enabled: onPrev != null, onTap: onPrev),
        const SizedBox(width: 6),
        Text(
          '$current/$total',
          style: const TextStyle(
              color: Colors.white30, fontSize: 10, fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 6),
        _ArrowIcon(
            icon: Icons.chevron_right, enabled: onNext != null, onTap: onNext),
      ],
    );
  }
}

class _ArrowIcon extends StatelessWidget {
  const _ArrowIcon({required this.icon, required this.enabled, this.onTap});
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
        child: Icon(icon, size: 14, color: enabled ? _accent : Colors.white10),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(color: _border.withValues(alpha: 0.4)),
      ),
      child: TextField(
        controller: controller,
        autocorrect: false,
        enableSuggestions: false,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        decoration: const InputDecoration(
          hintText: 'SEARCH...',
          hintStyle: TextStyle(color: Colors.white24, fontSize: 10),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.white24, size: 16),
        ),
      ),
    );
  }
}

class _AutoInstallToggle extends StatelessWidget {
  const _AutoInstallToggle({required this.value, required this.onTap});

  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            value ? Icons.toggle_on : Icons.toggle_off,
            size: 16,
            color: value ? _accent : _border,
          ),
          const SizedBox(width: 4),
          Text(
            'AUTO',
            style: TextStyle(
              color: value ? _accent : Colors.white24,
              fontSize: 7,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModTile extends ConsumerStatefulWidget {
  const _ModTile({
    required this.mod,
    required this.onDownload,
    this.status,
    this.progress,
  });

  final OverlayModItem mod;
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
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
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
              const SizedBox(width: 4),
              if (_isDone)
                const Icon(Icons.check_circle, size: 15, color: _accent)
              else if (!_hasSingleUrl)
                const Icon(Icons.list_alt, size: 15, color: Colors.white24)
              else if (_isCancelled)
                GestureDetector(
                  onTap: widget.onDownload,
                  child: Icon(Icons.refresh, size: 15,
                      color: _accent.withValues(alpha: 0.6)),
                )
              else if (!_isActive)
                GestureDetector(
                  onTap: widget.onDownload,
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.15),
                      border:
                          Border.all(color: _accent.withValues(alpha: 0.5)),
                    ),
                    child: const Icon(Icons.download,
                        size: 13, color: _accent),
                  ),
                )
              else
                SizedBox(
                  width: 22,
                  height: 22,
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
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: LinearProgressIndicator(
                value: _isDownloading && widget.progress != null
                    ? widget.progress! / 100.0
                    : null,
                backgroundColor: _accent.withValues(alpha: 0.1),
                color: _accent,
                minHeight: 2.5,
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
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2, color: _accent),
    );
  }
}
