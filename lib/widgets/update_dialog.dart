import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ota_update/ota_update.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/update_config.dart';

/// Diálogo de actualización OTA.
///
/// Muestra la versión disponible, el changelog y el progreso de descarga.
/// En Android: usa el plugin ota_update para descargar e instalar el APK.
/// En otras plataformas: abre el navegador con la URL de descarga.
class UpdateDialog extends StatefulWidget {
  const UpdateDialog({
    super.key,
    required this.config,
    this.isForce = false,
  });

  final UpdateConfig config;
  final bool isForce;

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  StreamSubscription<OtaEvent>? _otaSub;
  bool _downloading = false;
  double _progress = 0;
  String? _error;

  bool get _canOtaUpdate =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void dispose() {
    _otaSub?.cancel();
    super.dispose();
  }

  void _startOtaUpdate() {
    if (_downloading) return;

    setState(() {
      _downloading = true;
      _progress = 0;
      _error = null;
    });

    try {
      _otaSub = OtaUpdate()
          .execute(widget.config.updateUrl)
          .listen(
            (OtaEvent event) {
              if (!mounted) return;
              switch (event.status) {
                case OtaStatus.DOWNLOADING:
                  setState(() {
                    _progress =
                        double.tryParse(event.value ?? '0') ?? 0;
                  });

                case OtaStatus.INSTALLING:
                  break;

                case OtaStatus.INSTALLATION_DONE:
                  setState(() => _downloading = false);

                case OtaStatus.CANCELED:
                  setState(() => _downloading = false);

                case OtaStatus.ALREADY_RUNNING_ERROR:
                  setState(() {
                    _error =
                        'Ya hay una descarga en curso. Espera o reinicia la app.';
                    _downloading = false;
                  });

                case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
                  setState(() {
                    _error =
                        'Permiso de instalación denegado.\n'
                        'Ve a Ajustes → Apps → esta app → Instalar apps desconocidas.';
                    _downloading = false;
                  });

                case OtaStatus.INTERNAL_ERROR:
                  setState(() {
                    _error =
                        'Error interno: ${event.value ?? "desconocido"}';
                    _downloading = false;
                  });

                case OtaStatus.DOWNLOAD_ERROR:
                  setState(() {
                    _error =
                        'Error de descarga. Verifica tu conexión.';
                    _downloading = false;
                  });

                case OtaStatus.CHECKSUM_ERROR:
                  setState(() {
                    _error =
                        'El archivo descargado está corrupto. Intenta de nuevo.';
                    _downloading = false;
                  });

                case OtaStatus.INSTALLATION_ERROR:
                  setState(() {
                    _error =
                        'Error al instalar: ${event.value ?? "desconocido"}';
                    _downloading = false;
                  });

              }
            },
            onError: (dynamic e) {
              if (!mounted) return;
              setState(() {
                _error = 'Error inesperado: $e';
                _downloading = false;
              });
            },
            cancelOnError: true,
          );
    } catch (e) {
      setState(() {
        _error = 'No se pudo iniciar la actualización: $e';
        _downloading = false;
      });
    }
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(
      'https://github.com/retired64/sm64cdpy.releases/releases/latest',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _onUpdatePressed() {
    if (_canOtaUpdate) {
      _startOtaUpdate();
    } else {
      _openInBrowser();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return PopScope(
      canPop: !widget.isForce && !_downloading,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && widget.isForce) {
          SystemNavigator.pop();
        }
      },
      child: AlertDialog(
        title: Row(
          children: [
            Icon(Icons.system_update, color: cs.primary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                widget.isForce
                    ? '¡Actualización requerida!'
                    : 'Nueva versión disponible',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Versión ${widget.config.latestVersion} disponible',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              if (widget.config.apkSize != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Tamaño: ${(widget.config.apkSize! / 1024 / 1024).toStringAsFixed(1)} MB',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                ),
              ],
              if (widget.config.changelog != null &&
                  widget.config.changelog!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Novedades:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.config.changelog!,
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (_downloading) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(value: _progress / 100),
                const SizedBox(height: 4),
                Text(
                  'Descargando... ${_progress.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.errorContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: cs.onErrorContainer,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (_error != null || !_canOtaUpdate)
            TextButton.icon(
              icon: const Icon(Icons.open_in_browser, size: 16),
              label: const Text('Abrir en navegador'),
              onPressed: _openInBrowser,
            ),
          if (!widget.isForce && !_downloading)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('MÁS TARDE'),
            ),
          if (widget.isForce && !_downloading)
            TextButton(
              onPressed: () => SystemNavigator.pop(),
              child: const Text('SALIR'),
            ),
          if (!_downloading || _error != null)
            FilledButton.icon(
              icon: const Icon(Icons.download),
              label: Text(
                _canOtaUpdate ? 'ACTUALIZAR AHORA' : 'IR A DESCARGAS',
              ),
              onPressed: _error != null ? _startOtaUpdate : _onUpdatePressed,
            ),
        ],
      ),
    );
  }
}
