import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../overlay/overlay_bridge.dart';
import '../../services/auto_install_preference_service.dart';

@immutable
class AutoInstallSettings {
  const AutoInstallSettings({required this.decision, this.isSaving = false});

  final AutoInstallDecision decision;
  final bool isSaving;

  bool get isEnabled => decision == AutoInstallDecision.enabled;
  bool get needsDecision => decision == AutoInstallDecision.undecided;
}

class AutoInstallNotifier extends Notifier<AutoInstallSettings> {
  @override
  AutoInstallSettings build() =>
      AutoInstallSettings(decision: AutoInstallPreferenceService.decision);

  Future<bool> setEnabled(bool enabled) async {
    if (state.isSaving) return false;
    final previous = state;
    state = AutoInstallSettings(decision: previous.decision, isSaving: true);
    try {
      await AutoInstallPreferenceService.setEnabled(enabled);
      if (ref.mounted) {
        state = AutoInstallSettings(
          decision: enabled
              ? AutoInstallDecision.enabled
              : AutoInstallDecision.disabled,
        );
      }
      // Persistence is already complete; overlay refresh is a best-effort
      // projection whose implementation handles its own platform errors.
      unawaited(OverlayBridge.refreshAutoInstall());
      return true;
    } catch (error, stack) {
      debugPrint('Failed to save auto-install preference: $error\n$stack');
      if (ref.mounted) state = previous;
      return false;
    }
  }
}

final autoInstallProvider =
    NotifierProvider<AutoInstallNotifier, AutoInstallSettings>(
      AutoInstallNotifier.new,
    );
