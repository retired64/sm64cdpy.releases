import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/retro_theme.dart';
import '../../core/utils/extensions.dart';
import '../../domain/entities/mod_entity.dart';
import '../../l10n/app_localizations.dart';
import '../providers/mod_providers.dart';

/// Main mod catalogue card — used in ListView.builder.
class ModCard extends ConsumerStatefulWidget {
  const ModCard({super.key, required this.mod, required this.onTap});

  final ModEntity mod;
  final VoidCallback onTap;

  @override
  ConsumerState<ModCard> createState() => _ModCardState();
}

class _ModCardState extends ConsumerState<ModCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final isFav = ref.watch(favouritesProvider).contains(widget.mod.id);

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _pressCtrl,
        builder: (context, child) {
          final offset = 3.0 * _pressCtrl.value;
          return Transform.translate(
            offset: Offset(offset, offset),
            child: Container(
              decoration: BoxDecoration(
                color: retro.surface,
                borderRadius: RetroTheme.radius,
                border: Border.all(color: retro.border, width: 2.5),
                boxShadow: retro.hardShadow(dx: 4 - offset, dy: 4 - offset),
              ),
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Thumbnail ──────────────────────────────────────
              _Thumbnail(
                imageUrl: widget.mod.imageUrl,
                modId: widget.mod.id,
                featured: widget.mod.isFeatured,
                retro: retro,
              ),
              const SizedBox(width: 12),

              // ── Info ───────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.mod.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: retro.heading(size: 14.5, letterSpacing: -0.1),
                    ),
                    const SizedBox(height: 5),

                    // Author
                    RetroMeta(
                      retro: retro,
                      icon: Icons.person_rounded,
                      label: widget.mod.author,
                    ),
                    const SizedBox(height: 7),

                    // Stats row
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        RetroMeta(
                          retro: retro,
                          icon: Icons.star_rounded,
                          label: widget.mod.rating?.star ?? '—',
                          color: retro.amber,
                        ),
                        RetroMeta(
                          retro: retro,
                          icon: Icons.download_rounded,
                          label: widget.mod.downloads.compact,
                          color: retro.accent,
                        ),
                        if (widget.mod.isFeatured)
                          RetroTag(
                            retro: retro,
                            label: AppLocalizations.of(context).badgeFeatured,
                            color: retro.amber,
                            filled: true,
                            dense: true,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // ── Fav button ─────────────────────────────────────
              GestureDetector(
                onTap: () => ref.read(favouritesProvider.notifier).toggle(widget.mod.id),
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: retro.surfaceAlt,
                    border: Border.all(
                      color: isFav ? retro.red : retro.border,
                      width: isFav ? 2 : 1.5,
                    ),
                  ),
                  child: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 16,
                    color: isFav ? retro.red : retro.inkDim,
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

// ── Private helpers ──────────────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    this.imageUrl,
    required this.modId,
    required this.featured,
    required this.retro,
  });

  final String? imageUrl;
  final String modId;
  final bool featured;
  final RetroTheme retro;

  static const _size = 78.0;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            border: Border.all(color: retro.border, width: 2),
          ),
          child: Hero(
            tag: 'mod_img_$modId',
            child: hasImage
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        _ShimmerBox(width: _size, height: _size),
                    errorWidget: (context, url, error) =>
                        _StripedPlaceholder(size: _size, retro: retro),
                  )
                : _StripedPlaceholder(size: _size, retro: retro),
          ),
        ),

        // Badge tipo "verificado" en la esquina — solo si el mod es
        // destacado. Nunca bloquea el centro de la miniatura.
        if (featured)
          Positioned(
            right: -6,
            bottom: -6,
            child: RetroBadgeDot(
              retro: retro,
              icon: Icons.star_rounded,
              color: retro.amber,
              size: 20,
            ),
          ),
      ],
    );
  }
}

/// Placeholder con franjas diagonales para mods sin imagen — en vez del
/// cuadro plano de un solo color con un ícono suelto.
class _StripedPlaceholder extends StatelessWidget {
  const _StripedPlaceholder({required this.size, required this.retro});

  final double size;
  final RetroTheme retro;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DiagonalStripeBanner(
            baseColor: retro.surfaceAlt,
            stripeColor: retro.border.withValues(alpha: 0.35),
            stripeWidth: 8,
            gap: 8,
          ),
          Center(
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: retro.background,
                border: Border.all(color: retro.border, width: 1.5),
              ),
              child: Icon(Icons.extension_rounded, size: 15, color: retro.inkDim),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer placeholder for loading state.
class ModCardSkeleton extends StatelessWidget {
  const ModCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Shimmer.fromColors(
      baseColor: retro.surface,
      highlightColor: retro.surfaceAlt,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: retro.border, width: 2),
        ),
        child: Row(
          children: [
            _ShimmerBox(width: 78, height: 78),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ShimmerBox(width: 180, height: 14),
                  const SizedBox(height: 6),
                  _ShimmerBox(width: 100, height: 12),
                  const SizedBox(height: 10),
                  _ShimmerBox(width: 120, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(width: width, height: height, color: Colors.white);
  }
}
