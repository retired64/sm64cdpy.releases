enum CoopSessionMode { host, join }

enum CoopSessionPhase {
  idle,
  preparing,
  starting,
  waiting,
  connecting,
  connected,
  reconnecting,
  stopping,
  stopped,
  failed;

  bool get active => switch (this) {
    preparing ||
    starting ||
    waiting ||
    connecting ||
    connected ||
    reconnecting ||
    stopping => true,
    _ => false,
  };
}

class CoopPeer {
  const CoopPeer({
    required this.id,
    this.route,
    this.reconnecting = false,
    this.game,
  });

  factory CoopPeer.fromMap(Map<Object?, Object?> value) => CoopPeer(
    id: value['id'] as String? ?? '',
    route: value['route'] as String?,
    reconnecting: value['reconnecting'] == true,
    game: value['game'] as bool?,
  );

  final String id;
  final String? route;
  final bool reconnecting;
  final bool? game;
}

class CoopSessionState {
  const CoopSessionState({
    this.phase = CoopSessionPhase.idle,
    this.mode,
    this.sessionId,
    this.code,
    this.port,
    this.trackers = 0,
    this.peers = const [],
    this.message,
    this.gameIn = false,
    this.gameHosting = false,
    this.gameInstalled,
    this.revision = 0,
    this.initialized = false,
  });

  factory CoopSessionState.fromMap(Map<Object?, Object?> value) {
    final phaseName = value['phase'] as String? ?? 'idle';
    final modeName = value['mode'] as String?;
    final rawPeers = value['friends'] as List<Object?>? ?? const [];
    return CoopSessionState(
      phase: CoopSessionPhase.values.firstWhere(
        (item) => item.name == phaseName,
        orElse: () => CoopSessionPhase.failed,
      ),
      mode: modeName == null
          ? null
          : CoopSessionMode.values.firstWhere(
              (item) => item.name == modeName,
              orElse: () => CoopSessionMode.join,
            ),
      sessionId: value['sessionId'] as String?,
      code: value['code'] as String?,
      port: (value['port'] as num?)?.toInt(),
      trackers: (value['trackers'] as num?)?.toInt() ?? 0,
      peers: rawPeers
          .whereType<Map>()
          .map((item) => CoopPeer.fromMap(Map<Object?, Object?>.from(item)))
          .toList(growable: false),
      message: value['message'] as String?,
      gameIn: value['gameIn'] == true,
      gameHosting: value['gameHosting'] == true,
      gameInstalled: value['gameInstalled'] as bool?,
      revision: (value['revision'] as num?)?.toInt() ?? 0,
      initialized: value['initialized'] == true,
    );
  }

  final CoopSessionPhase phase;
  final CoopSessionMode? mode;
  final String? sessionId;
  final String? code;
  final int? port;
  final int trackers;
  final List<CoopPeer> peers;
  final String? message;
  final bool gameIn;
  final bool gameHosting;
  final bool? gameInstalled;
  final int revision;
  final bool initialized;

  bool get canStart => initialized && !phase.active;

  CoopSessionState copyWith({bool? gameInstalled}) => CoopSessionState(
    phase: phase,
    mode: mode,
    sessionId: sessionId,
    code: code,
    port: port,
    trackers: trackers,
    peers: peers,
    message: message,
    gameIn: gameIn,
    gameHosting: gameHosting,
    gameInstalled: gameInstalled ?? this.gameInstalled,
    revision: revision,
    initialized: initialized,
  );
}
