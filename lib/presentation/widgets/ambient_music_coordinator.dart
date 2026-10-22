import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/ambient_music.dart';
import '../providers/app_audio_settings_provider.dart';
import '../providers/theme_provider.dart';

final ambientMusicProvider = Provider<AmbientMusic>((ref) => AmbientMusic());

/// Un propietario por app principal: navegar no reinicia la pista.
class AmbientMusicCoordinator extends ConsumerStatefulWidget {
  const AmbientMusicCoordinator({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<AmbientMusicCoordinator> createState() => _AmbientMusicCoordinatorState();
}

class _AmbientMusicCoordinatorState extends ConsumerState<AmbientMusicCoordinator> {
  late final AmbientMusic _music;

  @override
  void initState() {
    super.initState();
    _music = ref.read(ambientMusicProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _sync();
    });
  }

  void _sync() {
    final mix = ref.read(appAudioSettingsProvider);
    unawaited(_music.configure(
      enabled: mix.musicEnabled && ref.read(themeDesignProvider).id.isManga,
      volume: mix.musicVolume,
    ));
  }

  @override
  void dispose() {
    unawaited(_music.configure(enabled: false, volume: 0));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(appAudioSettingsProvider, (_, _) => _sync());
    ref.listen(themeDesignProvider, (_, _) => _sync());
    return widget.child;
  }
}
