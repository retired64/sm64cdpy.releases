import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../providers/player_profile_provider.dart';

Future<bool> confirmPlayerLeave(BuildContext context, WidgetRef ref) async {
  final state = ref.read(playerProfileProvider);
  if (state.busy) return false;
  if (!state.dirty) return true;

  final l10n = AppLocalizations.of(context);
  final discard = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.playerUnsavedTitle),
      content: Text(l10n.playerUnsavedBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.playerKeepEditing),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n.playerDiscard),
        ),
      ],
    ),
  );
  if (!context.mounted || discard != true) return false;
  ref.read(playerProfileProvider.notifier).reset();
  return true;
}
