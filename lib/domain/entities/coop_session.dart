import 'dart:convert';

const coopNetworkConsentTermsVersion = 2;

String encodeCoopNetworkConsent({DateTime? acceptedAt}) => jsonEncode({
  'accepted': true,
  'termsVersion': coopNetworkConsentTermsVersion,
  'at': (acceptedAt ?? DateTime.now()).toUtc().toIso8601String(),
});

bool isValidCoopNetworkConsent(String? value) {
  if (value == null || value.isEmpty) return false;
  try {
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, dynamic>) return false;
    final acceptedAt = DateTime.tryParse(decoded['at'] as String? ?? '');
    return decoded['accepted'] == true &&
        decoded['termsVersion'] == coopNetworkConsentTermsVersion &&
        acceptedAt != null;
  } catch (_) {
    return false;
  }
}

enum CoopSessionMode { host, join }

String normalizeCoopCode(String input) {
  final raw = input
      .toUpperCase()
      .replaceAll(RegExp('[^A-Z0-9]'), '')
      .replaceAll(RegExp('[IL]'), '1')
      .replaceAll('O', '0')
      .replaceAll('U', 'V');
  return raw.length == 8 ? '${raw.substring(0, 4)}-${raw.substring(4)}' : raw;
}

bool isValidCoopCode(String code) =>
    RegExp(r'^[0-9A-HJKMNP-TV-Z]{4}-[0-9A-HJKMNP-TV-Z]{4}$').hasMatch(code);

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

class CoopSessionDiagnostics {
  const CoopSessionDiagnostics({
    this.toGame = 0,
    this.toPage = 0,
    this.upDelaySamples = 0,
    this.upDelayAverageMs = 0,
    this.upDelayMaxMs = 0,
  });

  factory CoopSessionDiagnostics.fromMap(Map<Object?, Object?> value) =>
      CoopSessionDiagnostics(
        toGame: (value['toGame'] as num?)?.toInt() ?? 0,
        toPage: (value['toPage'] as num?)?.toInt() ?? 0,
        upDelaySamples: (value['upDelaySamples'] as num?)?.toInt() ?? 0,
        upDelayAverageMs: (value['upDelayAverageMs'] as num?)?.toInt() ?? 0,
        upDelayMaxMs: (value['upDelayMaxMs'] as num?)?.toInt() ?? 0,
      );

  final int toGame;
  final int toPage;
  final int upDelaySamples;
  final int upDelayAverageMs;
  final int upDelayMaxMs;
}

class CoopBatteryOptimizationState {
  const CoopBatteryOptimizationState({
    required this.supported,
    required this.ignored,
    this.settingsOpened = false,
  });

  factory CoopBatteryOptimizationState.fromMap(Map<Object?, Object?> value) =>
      CoopBatteryOptimizationState(
        supported: value['supported'] == true,
        ignored: value['ignored'] == true,
        settingsOpened: value['settingsOpened'] == true,
      );

  final bool supported;
  final bool ignored;
  final bool settingsOpened;
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
    this.diagnostics = const CoopSessionDiagnostics(),
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
      diagnostics: CoopSessionDiagnostics.fromMap(value),
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
  final CoopSessionDiagnostics diagnostics;

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
    diagnostics: diagnostics,
  );
}
