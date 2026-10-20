import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/retro_theme.dart';
import '../../domain/entities/rom_preparation.dart';
import '../../l10n/app_localizations.dart';
import '../providers/rom_preparation_provider.dart';

class RomPreparationPanel extends ConsumerWidget {
  const RomPreparationPanel({super.key, this.onContinueGuide});
  final VoidCallback? onContinueGuide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(romPreparationProvider);
    final notifier = ref.read(romPreparationProvider.notifier);
    final l = AppLocalizations.of(context);
    final retro = RetroTheme.of(context);
    final status = _status(l, state);
    final error = state.phase == RomPreparationPhase.failed
        ? _error(l, state.errorCode)
        : null;

    return Semantics(
      container: true,
      liveRegion: state.phase.busy,
      child: DecoratedBox(
        decoration: retro.surfaceDecoration(
          borderColor: retro.border,
          border: 2,
          shadowDx: 4,
          shadowDy: 4,
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionKicker(retro: retro, label: l.romPrepareTitle),
              const SizedBox(height: 10),
              Text(l.romPrepareDescription, style: retro.body(size: 15)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: retro.surfaceDecoration(
                  color: retro.surfaceAlt,
                  borderColor: retro.border,
                  border: 1.5,
                  shadowDx: 2,
                  shadowDy: 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(status, style: retro.heading(size: 16)),
                    if (state.inputName != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        state.inputName!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: retro.body(size: 14),
                      ),
                    ],
                    if (state.sourceFormat != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        l.romPrepareDetected(state.sourceFormat!.toUpperCase()),
                        style: retro.body(size: 13),
                      ),
                    ],
                    if (state.phase.busy) ...[
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: state.progress,
                        minHeight: 5,
                      ),
                      if (state.progress != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${(state.progress! * 100).round()}%',
                          style: retro.body(size: 13),
                        ),
                      ],
                    ],
                    if (error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        error,
                        style: retro.body(size: 14, color: retro.red),
                      ),
                    ],
                    if (state.outputName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        l.romPrepareSavedAs(state.outputName!),
                        style: retro.body(size: 14),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (!state.initialized)
                const Center(
                  child: SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (state.phase.busy)
                OutlinedButton.icon(
                  onPressed: state.phase == RomPreparationPhase.cancelling
                      ? null
                      : notifier.cancel,
                  icon: const Icon(Icons.close),
                  label: Text(l.romPrepareCancel),
                )
              else ...[
                if (state.phase == RomPreparationPhase.prepared ||
                    state.canExport)
                  FilledButton.icon(
                    onPressed: notifier.export,
                    icon: const Icon(Icons.save_alt_rounded),
                    label: Text(l.romPrepareSave),
                  ),
                if (state.phase == RomPreparationPhase.saved &&
                    onContinueGuide != null)
                  FilledButton.icon(
                    onPressed: onContinueGuide,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(l.romPrepareContinue),
                  ),
                if (state.phase != RomPreparationPhase.prepared &&
                    !state.canExport)
                  FilledButton.icon(
                    onPressed: notifier.pickAndPrepare,
                    icon: const Icon(Icons.folder_open_rounded),
                    label: Text(
                      state.phase == RomPreparationPhase.saved
                          ? l.romPrepareAnother
                          : l.romPrepareChoose,
                    ),
                  ),
                if (state.phase == RomPreparationPhase.prepared ||
                    state.canExport)
                  TextButton(
                    onPressed: notifier.discard,
                    child: Text(l.romPrepareChooseAnother),
                  ),
              ],
              const SizedBox(height: 10),
              Text(
                l.romPreparePrivacy,
                style: retro.body(size: 12, color: retro.inkDim),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _status(AppLocalizations l, RomPreparationState state) =>
      switch (state.phase) {
        RomPreparationPhase.idle => l.romPrepareIdle,
        RomPreparationPhase.picking => l.romPreparePicking,
        RomPreparationPhase.inspecting => l.romPrepareInspecting,
        RomPreparationPhase.converting => l.romPrepareConverting,
        RomPreparationPhase.validating => l.romPrepareValidating,
        RomPreparationPhase.prepared =>
          state.sourceFormat == 'z64'
              ? l.romPrepareAlreadyCompatible
              : l.romPrepareReady,
        RomPreparationPhase.choosingDestination =>
          l.romPrepareChoosingDestination,
        RomPreparationPhase.exporting => l.romPrepareExporting,
        RomPreparationPhase.verifyingExport => l.romPrepareVerifyingExport,
        RomPreparationPhase.saved => l.romPrepareSaved,
        RomPreparationPhase.cancelling => l.romPrepareCancelling,
        RomPreparationPhase.cancelled => l.romPrepareCancelled,
        RomPreparationPhase.failed => l.romPrepareFailed,
      };

  String _error(AppLocalizations l, String? code) => switch (code) {
    'unrecognized' => l.romPrepareErrorUnrecognized,
    'wrong_size' => l.romPrepareErrorSize,
    'incompatible' => l.romPrepareErrorIncompatible,
    'permission' => l.romPrepareErrorPermission,
    'storage' => l.romPrepareErrorStorage,
    'export_failed' || 'verification_failed' => l.romPrepareErrorExport,
    'busy' => l.romPrepareErrorBusy,
    _ => l.romPrepareErrorUnexpected,
  };
}
