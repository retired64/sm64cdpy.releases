import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import 'app_snackbar.dart';
import 'settings_expansion_group.dart';

class LocaleSelector extends ConsumerStatefulWidget {
  const LocaleSelector({super.key});

  @override
  ConsumerState<LocaleSelector> createState() => _LocaleSelectorState();
}

class _LocaleSelectorState extends ConsumerState<LocaleSelector> {
  bool _expanded = false;
  bool _saving = false;

  String _flag(String? tag) => switch (tag) {
    'en_US' => '🇺🇸',
    'es_419' => '🇲🇽',
    'pt_BR' => '🇧🇷',
    'fr' => '🇫🇷',
    'it' => '🇮🇹',
    _ => '🌐',
  };

  String _name(AppLocalizations l10n, String? tag) => switch (tag) {
    'en_US' => l10n.languageEnglish,
    'es_419' => l10n.languageSpanish,
    'pt_BR' => l10n.languagePortuguese,
    'fr' => l10n.languageFrench,
    'it' => l10n.languageItalian,
    _ => l10n.languageFollowSystem,
  };

  Future<void> _select(String? tag) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(localeNotifierProvider.notifier).setLocale(tag);
      if (!mounted) return;
      setState(() => _expanded = false);
    } catch (error, stack) {
      debugPrint('Locale selection failed: $error\n$stack');
      if (!mounted) return;
      AppSnackbar.error(
        context,
        message: AppLocalizations.of(context).languageSaveFailed,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tag = ref.watch(localeNotifierProvider);
    final l10n = AppLocalizations.of(context);
    return SettingsExpansionGroup(
      key: const PageStorageKey('locale-selector'),
      title: l10n.settingsLanguageMode,
      subtitle: '${_flag(tag)} ${_name(l10n, tag)}',
      icon: Icons.translate_rounded,
      expanded: _expanded,
      onExpansionChanged: (expanded) => setState(() => _expanded = expanded),
      children: [
        for (final option in <String?>[null, ...LocaleNotifier.supportedTags])
          SettingsSelectionOption(
            key: ValueKey('locale-${option ?? 'system'}'),
            label: _name(l10n, option),
            leading: Text(_flag(option), style: const TextStyle(fontSize: 18)),
            selected: option == tag,
            onPressed: _saving
                ? null
                : () async {
                    await _select(option);
                  },
          ),
      ],
    );
  }
}
