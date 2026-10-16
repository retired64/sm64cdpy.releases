import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/player_profile.dart';

enum Player3DStatus { loading, ready, unavailable }

class Player3DPreview extends StatefulWidget {
  const Player3DPreview({
    required this.profile,
    required this.loadingLabel,
    required this.unavailableLabel,
    super.key,
  });

  final PlayerProfile profile;
  final String loadingLabel;
  final String unavailableLabel;

  @override
  State<Player3DPreview> createState() => _Player3DPreviewState();
}

class _Player3DPreviewState extends State<Player3DPreview>
    with AutomaticKeepAliveClientMixin<Player3DPreview> {
  MethodChannel? _channel;
  Player3DStatus _status = Player3DStatus.loading;

  Map<String, Object> get _profile => {
    'model': widget.profile.model,
    'colors': widget.profile.palette.platformColors,
  };

  @override
  void didUpdateWidget(covariant Player3DPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.model != widget.profile.model ||
        oldWidget.profile.palette != widget.profile.palette) {
      unawaited(_channel?.invokeMethod<void>('update', _profile));
    }
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  void _created(int id) {
    final channel = MethodChannel('mods.sm64cdpy/player3d/$id');
    _channel = channel;
    channel.setMethodCallHandler((call) async {
      if (call.method != 'state' || !mounted) return;
      _acceptState(Map<Object?, Object?>.from(call.arguments as Map));
    });
    unawaited(
      channel.invokeMapMethod<Object?, Object?>('getState').then((value) {
        if (value != null && mounted) _acceptState(value);
      }),
    );
  }

  void _acceptState(Map<Object?, Object?> value) {
    final next = switch (value['state']) {
      'ready' => Player3DStatus.ready,
      'error' => Player3DStatus.unavailable,
      _ => Player3DStatus.loading,
    };
    if (next != _status) setState(() => _status = next);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!Platform.isAndroid) {
      return _Message(icon: Icons.view_in_ar, label: widget.unavailableLabel);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        AndroidView(
          viewType: 'mods.sm64cdpy/player3d',
          creationParams: _profile,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _created,
        ),
        if (_status != Player3DStatus.ready)
          ColoredBox(
            color: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.88),
            child: _Message(
              icon: _status == Player3DStatus.unavailable
                  ? Icons.view_in_ar_outlined
                  : Icons.hourglass_top,
              label: _status == Player3DStatus.unavailable
                  ? widget.unavailableLabel
                  : widget.loadingLabel,
              progress: _status == Player3DStatus.loading,
            ),
          ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.label,
    this.progress = false,
  });

  final IconData icon;
  final String label;
  final bool progress;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (progress)
            const SizedBox.square(
              dimension: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            )
          else
            Icon(icon, size: 44),
          const SizedBox(height: 10),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
