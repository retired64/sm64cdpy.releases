import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ota_update/ota_update.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/retro_theme.dart';
import '../services/update_config.dart';

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
    final retro = RetroTheme.of(context);

    return PopScope(
      canPop: !widget.isForce && !_downloading,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && widget.isForce) {
          SystemNavigator.pop();
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: retro.surface,
            border: Border.all(color: retro.border, width: 2),
            boxShadow: retro.hardShadow(dx: 4, dy: 4),
            borderRadius: RetroTheme.radius,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Icon(Icons.system_update, color: retro.accent, size: 22),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        widget.isForce
                            ? 'ACTUALIZACION REQUERIDA'
                            : 'NUEVA VERSION DISPONIBLE',
                        style: retro.heading(size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Version ${widget.config.latestVersion}',
                      style: retro.heading(size: 14),
                    ),
                    if (widget.config.apkSize != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Tamano: ${(widget.config.apkSize! / 1024 / 1024).toStringAsFixed(1)} MB',
                        style: retro.body(size: 12),
                      ),
                    ],
                    if (widget.config.changelog != null &&
                        widget.config.changelog!.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text('Novedades:', style: retro.heading(size: 13)),
                      const SizedBox(height: 4),
                      Text(
                        widget.config.changelog!,
                        style: retro.body(size: 13),
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else ...[
                      const SizedBox(height: 14),
                      Text(
                        'Mejoras y correcciones menores.',
                        style: retro.body(size: 13),
                      ),
                    ],
                    if (_downloading) ...[
                      const SizedBox(height: 18),
                      LinearProgressIndicator(
                        value: _progress / 100,
                        color: retro.accent,
                        backgroundColor: retro.surfaceAlt,
                        minHeight: 6,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Descargando... ${_progress.toStringAsFixed(0)}%',
                        style: retro.body(size: 12),
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: retro.red.withValues(alpha: 0.12),
                          border: Border.all(
                            color: retro.red.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          borderRadius: RetroTheme.radius,
                        ),
                        child: Text(
                          _error!,
                          style: retro.body(size: 12, color: retro.red),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: retro.border, width: 1),
                  ),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    if (_error != null || !_canOtaUpdate)
                      _RetroTextButton(
                        retro: retro,
                        icon: Icons.open_in_browser,
                        label: 'ABRIR EN NAVEGADOR',
                        onTap: _openInBrowser,
                      ),
                    if (!widget.isForce && !_downloading)
                      _RetroTextButton(
                        retro: retro,
                        label: 'MAS TARDE',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    if (widget.isForce && !_downloading)
                      _RetroTextButton(
                        retro: retro,
                        label: 'SALIR',
                        onTap: () => SystemNavigator.pop(),
                      ),
                    if (!_downloading || _error != null)
                      _RetroPrimaryButton(
                        retro: retro,
                        icon: Icons.download,
                        label: _canOtaUpdate
                            ? 'ACTUALIZAR AHORA'
                            : 'IR A DESCARGAS',
                        onTap: _error != null
                            ? _startOtaUpdate
                            : _onUpdatePressed,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RetroTextButton extends StatelessWidget {
  const _RetroTextButton({
    required this.retro,
    required this.label,
    this.icon,
    required this.onTap,
  });

  final RetroTheme retro;
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: retro.border, width: 1.5),
          borderRadius: RetroTheme.radius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: retro.ink),
              const SizedBox(width: 6),
            ],
            Text(label, style: retro.heading(size: 11.5, color: retro.ink)),
          ],
        ),
      ),
    );
  }
}

class _RetroPrimaryButton extends StatelessWidget {
  const _RetroPrimaryButton({
    required this.retro,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final RetroTheme retro;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: retro.accent,
          border: Border.all(color: retro.border, width: 2),
          boxShadow: retro.hardShadow(dx: 3, dy: 3),
          borderRadius: RetroTheme.radius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: retro.inkOnAccent),
            const SizedBox(width: 6),
            Text(
              label,
              style: retro.heading(size: 11.5, color: retro.inkOnAccent),
            ),
          ],
        ),
      ),
    );
  }
}
