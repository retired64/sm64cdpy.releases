import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/app_shell.dart';
import '../widgets/app_snackbar.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Container(
            height: 56,
            color: retro.background,
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const DrawerMenuButton(),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.disclaimerTitle,
                    style: retro.heading(size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _DisclaimerBody(l10n: l10n),
        ),
      ],
    );
  }
}

class _DisclaimerBody extends StatelessWidget {
  const _DisclaimerBody({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);

    final sections = <_SectionData>[
      _SectionData(
        icon: Icons.person_rounded,
        title: l10n.disclaimerSectionPersonalPurpose,
        body: l10n.disclaimerBodyPersonalPurpose,
      ),
      _SectionData(
        icon: Icons.link_off_rounded,
        title: l10n.disclaimerSectionNoAffiliation,
        body: l10n.disclaimerBodyNoAffiliation,
      ),
      _SectionData(
        icon: Icons.storage_rounded,
        title: l10n.disclaimerSectionDataSource,
        body: l10n.disclaimerBodyDataSource,
      ),
      _SectionData(
        icon: Icons.auto_awesome_rounded,
        title: l10n.disclaimerSectionExclusive,
        body: l10n.disclaimerBodyExclusive(AppConstants.appVersion),
      ),
      _SectionData(
        icon: Icons.bug_report_rounded,
        title: l10n.disclaimerSectionBugs,
        body: l10n.disclaimerBodyBugs,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 8),
        _HeroBadge(l10n: l10n),
        const SizedBox(height: 28),
        ...sections.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _DisclaimerSection(
              icon: s.icon,
              title: s.title,
              body: s.body,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _WarningBanner(l10n: l10n),
        const SizedBox(height: 28),
        _SectionLabel(l10n.disclaimerDeveloperContact),
        const SizedBox(height: 12),
        _ContactButton(
          asset: 'assets/icons/discord-chat.svg',
          platform: l10n.disclaimerDiscord,
          handle: l10n.disclaimerDiscordReach,
          url: 'https://discord.com/invite/thuhUH2WNX',
          l10n: l10n,
        ),
        const SizedBox(height: 28),
        Center(
          child: Text(
            l10n.disclaimerFooter(AppConstants.appVersion),
            style: retro.body(size: 11),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _SectionData {
  const _SectionData({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: retro.surface,
            borderRadius: RetroTheme.radius,
            border: Border.all(color: retro.border, width: 2.5),
            boxShadow: retro.hardShadow(),
          ),
          child: Icon(Icons.info_outline, size: 38, color: retro.accent),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.disclaimerUnofficialBanner,
          style: retro.heading(size: 22),
        ),
        const SizedBox(height: 5),
        RetroTag(
          retro: retro,
          label: l10n.disclaimerAppSubtitle,
          filled: true,
          dense: true,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: retro.surface,
            borderRadius: RetroTheme.radius,
            border: Border.all(color: retro.border, width: 1),
          ),
          child: Text(
            'v${AppConstants.appVersion}',
            style: retro.body(size: 11),
          ),
        ),
      ],
    );
  }
}

class _DisclaimerSection extends StatelessWidget {
  const _DisclaimerSection({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: retro.surface,
        borderRadius: RetroTheme.radius,
        border: Border.all(color: retro.border, width: 2),
        boxShadow: retro.hardShadow(dx: 2, dy: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: retro.surfaceAlt,
              borderRadius: RetroTheme.radius,
              border: Border.all(color: retro.accent, width: 1.5),
            ),
            child: Icon(icon, size: 18, color: retro.accent),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: retro.heading(size: 13)),
                const SizedBox(height: 5),
                Text(body, style: retro.body(size: 12.5, height: 1.56)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: retro.surface,
        borderRadius: RetroTheme.radius,
        border: Border.all(color: retro.red, width: 2),
        boxShadow: retro.hardShadow(dx: 3, dy: 3),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber, size: 20, color: retro.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.disclaimerWarningBody,
              style: TextStyle(
                color: retro.ink,
                fontSize: 12,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Text(label.toUpperCase(),
        style: retro.heading(size: 10, color: retro.inkDim, letterSpacing: 1.5));
  }
}

class _ContactButton extends StatefulWidget {
  const _ContactButton({
    required this.asset,
    required this.platform,
    required this.handle,
    required this.url,
    required this.l10n,
  });
  final String asset;
  final String platform;
  final String handle;
  final String url;
  final AppLocalizations l10n;

  @override
  State<_ContactButton> createState() => _ContactButtonState();
}

class _ContactButtonState extends State<_ContactButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  Future<void> _launch(BuildContext context) async {
    try {
      await launchUrl(
        Uri.parse(widget.url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      if (context.mounted) {
        AppSnackbar.error(context, message: widget.l10n.disclaimerCouldNotOpenLink);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapCancel: () => _pressCtrl.reverse(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        _launch(context);
      },
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: SvgPicture.asset(
                widget.asset,
                height: 100,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: retro.discordBrand,
                borderRadius: RetroTheme.radius,
                border: Border.all(color: retro.border, width: 2.5),
                boxShadow: retro.hardShadow(dx: 4, dy: 4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.discord, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.handle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: RetroTheme.radius,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                        width: 0.8,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
