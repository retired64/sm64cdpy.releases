import 'package:flutter/material.dart';

import '../../core/theme/retro_theme.dart';
import '../../services/game_launcher_service.dart';

Future<void> showPostInstallDialog(BuildContext context) async {
  final retro = RetroTheme.of(context);
  final isGameInstalled = await GameLauncherService.isInstalled();

  if (!context.mounted) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: retro.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      title: Row(
        children: [
          Icon(Icons.check_circle, color: retro.accent, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text('Mod installed', style: retro.heading(size: 15))),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isGameInstalled) ...[
            Text(
              'If the game was already running, close it completely '
              '(not just minimize) and reopen it so the new files '
              'are loaded correctly.',
              style: retro.body(size: 13),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 14, color: retro.amber),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'No force-stop or root needed — just close the game '
                    'normally and reopen it.',
                    style: retro.body(size: 11.5, color: retro.inkDim),
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              'Files have been copied to the mods folder.',
              style: retro.body(size: 13),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Close',
              style: retro.body(size: 13, color: retro.inkDim)),
        ),
        if (isGameInstalled)
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              GameLauncherService.launch();
            },
            child: Text(
              'LAUNCH GAME',
              style: retro.body(
                  size: 13, color: retro.accent, weight: FontWeight.w800),
            ),
          ),
      ],
    ),
  );
}
