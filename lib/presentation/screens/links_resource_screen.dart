import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../widgets/app_drawer.dart';

class LinksResourceScreen extends StatelessWidget {
  const LinksResourceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const AppDrawer(currentRoute: '/links-resource'),
      appBar: AppBar(title: const Text('Links Resource')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _SectionLabel('OFFICIAL'),
          const SizedBox(height: 8),
          ..._kOfficialLinks.map((l) => _LinkCard(link: l)),
          const SizedBox(height: 24),
          _SectionLabel('SM64CDPY'),
          const SizedBox(height: 8),
          ..._kAppLinks.map((l) => _LinkCard(link: l)),
          const SizedBox(height: 24),
          _SectionLabel('RESOURCES'),
          const SizedBox(height: 8),
          ..._kResourceLinks.map((l) => _LinkCard(link: l)),
        ],
      ),
    );
  }
}

class _LinkData {
  const _LinkData({
    required this.title,
    required this.url,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String url;
  final String subtitle;
  final IconData icon;
}

const _kOfficialLinks = [
  _LinkData(
    title: 'SM64CoopDX Website',
    url: AppConstants.dataSourceUrl,
    subtitle: 'mods.sm64coopdx.com',
    icon: Icons.public_rounded,
  ),
  _LinkData(
    title: 'Discord Server',
    url: AppConstants.discordUrl,
    subtitle: 'Official community server',
    icon: Icons.chat_rounded,
  ),
  _LinkData(
    title: 'GitHub Repository',
    url: AppConstants.githubUrl,
    subtitle: 'Source code & issues',
    icon: Icons.code_rounded,
  ),
];

const _kAppLinks = [
  _LinkData(
    title: 'GitHub Releases',
    url: AppConstants.githubReleasesUrl,
    subtitle: 'Download latest APK',
    icon: Icons.system_update_rounded,
  ),
  _LinkData(
    title: 'YouTube Channel',
    url: AppConstants.youtubeUrl,
    subtitle: '@retired64',
    icon: Icons.play_circle_rounded,
  ),
];

const _kResourceLinks = [
  _LinkData(
    title: 'Wiki & Guides',
    url: AppConstants.wikiUrl,
    subtitle: 'Installation guides & docs',
    icon: Icons.menu_book_rounded,
  ),
  _LinkData(
    title: 'Tools & Add-ons',
    url: AppConstants.toolsAndAddonsUrl,
    subtitle: 'External tools & resources',
    icon: Icons.build_rounded,
  ),
];

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _LinkCard extends StatelessWidget {
  const _LinkCard({required this.link});
  final _LinkData link;

  Future<void> _open(BuildContext context) async {
    final uri = Uri.parse(link.url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.35)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _open(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(link.icon, size: 20, color: cs.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        link.title,
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        link.subtitle,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 16,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
