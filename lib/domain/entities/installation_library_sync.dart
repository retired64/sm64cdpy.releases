/// Ordering is local to one main engine. A new session resets the old engine's
/// counter; replies from retired sessions cannot restore an old folder snapshot.
class InstallationLibrarySyncGate {
  String? session;
  int requestId = 0;
  bool sessionChanged = false;
  final _retired = <String>{};

  bool accept(String? incomingSession, int incomingRequest) {
    sessionChanged = false;
    if (incomingRequest < 0 || (session != null && incomingSession == null)) {
      return false;
    }
    if (incomingSession != null && incomingSession != session) {
      if (_retired.contains(incomingSession)) return false;
      if (session != null) _retired.add(session!);
      if (_retired.length > 32) _retired.remove(_retired.first);
      session = incomingSession;
      requestId = 0;
      sessionChanged = true;
    }
    if (incomingRequest < requestId) return false;
    requestId = incomingRequest;
    return true;
  }
}
