import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../services/background_install_service.dart';
import '../providers/mod_providers.dart';
import 'app_snackbar.dart';

/// Punto único de feedback para operaciones WorkManager.
///
/// Vive debajo de MaterialApp y por encima del router, por lo que sigue
/// montado al cambiar de pantalla. Las tarjetas solo representan progreso;
/// este coordinador anuncia una transición terminal exactamente una vez por
/// workId, incluida una operación reconciliada tras reiniciar la aplicación.
class BackgroundOperationCoordinator extends ConsumerStatefulWidget {
  const BackgroundOperationCoordinator({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<BackgroundOperationCoordinator> createState() =>
      _BackgroundOperationCoordinatorState();
}

class _BackgroundOperationCoordinatorState
    extends ConsumerState<BackgroundOperationCoordinator> {
  final Set<String> _announced = {};

  @override
  Widget build(BuildContext context) {
    ref.listen<Map<String, BgInstallInfo>>(bgInstallStateProvider, (
      previous,
      next,
    ) {
      for (final entry in next.entries) {
        final info = entry.value;
        final oldStatus = previous?[entry.key]?.status;
        final terminal =
            info.status == BgInstallStatus.completed ||
            info.status == BgInstallStatus.error ||
            info.status == BgInstallStatus.cancelled;
        if (!terminal || oldStatus == info.status) continue;

        final eventKey =
            '${info.workId ?? info.installWorkId ?? info.downloadWorkId ?? entry.key}:${info.status.name}';
        if (!_announced.add(eventKey)) continue;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final l10n = AppLocalizations.of(context);
          switch (info.status) {
            case BgInstallStatus.completed:
              AppSnackbar.success(context, message: l10n.detailInstallComplete);
            case BgInstallStatus.error:
              AppSnackbar.errorWithCopy(
                context,
                message: l10n.detailInstallFailed,
                copyText: info.error ?? l10n.detailInstallFailed,
              );
            case BgInstallStatus.cancelled:
              AppSnackbar.info(context, message: l10n.detailOperationCancelled);
            default:
              break;
          }
        });
      }
    });

    return widget.child;
  }
}
