import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/player_profile.dart';

enum Player3DStatus { loading, ready, unavailable }

@visibleForTesting
enum Player3DDragIntent { pending, rotate, scroll }

/// Resolves the user's initial drag without requiring a perfectly straight
/// horizontal movement. A clear vertical drag is left to the page scroll.
@visibleForTesting
Player3DDragIntent resolvePlayer3DDragIntent(Offset movement) {
  const horizontalSlop = 6.0;
  const verticalSlop = 10.0;
  const diagonalTolerance = 0.72;
  final dx = movement.dx.abs();
  final dy = movement.dy.abs();

  if (dx >= horizontalSlop && dx >= dy * diagonalTolerance) {
    return Player3DDragIntent.rotate;
  }
  if (dy >= verticalSlop && dy > dx / diagonalTolerance) {
    return Player3DDragIntent.scroll;
  }
  return Player3DDragIntent.pending;
}

class _Player3DDragRecognizer extends OneSequenceGestureRecognizer {
  Offset? _origin;
  int? _pointer;
  bool _resolved = false;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (_pointer != null) {
      resolve(GestureDisposition.rejected);
      return;
    }
    _pointer = event.pointer;
    _origin = event.position;
    startTrackingPointer(event.pointer);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event.pointer != _pointer) return;

    if (!_resolved && event is PointerMoveEvent) {
      final intent = resolvePlayer3DDragIntent(event.position - _origin!);
      if (intent != Player3DDragIntent.pending) {
        _resolved = true;
        resolve(
          intent == Player3DDragIntent.rotate
              ? GestureDisposition.accepted
              : GestureDisposition.rejected,
        );
      }
    }

    if (event is PointerUpEvent || event is PointerCancelEvent) {
      if (!_resolved) resolve(GestureDisposition.rejected);
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _pointer = null;
    _origin = null;
    _resolved = false;
  }

  @override
  String get debugDescription => 'player 3D drag';
}

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
      'preview' || 'ready' => Player3DStatus.ready,
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
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(_Player3DDragRecognizer.new),
          },
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
