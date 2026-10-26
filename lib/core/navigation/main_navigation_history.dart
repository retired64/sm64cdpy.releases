class BackTarget {
  const BackTarget({
    required this.location,
    required this.pop,
    this.replace = false,
  });

  final String location;
  final bool pop;
  final bool replace;
}

class MainNavigationHistory {
  MainNavigationHistory({this.maxEntries = 20})
    : assert(maxEntries > 0, 'maxEntries must be positive');

  final int maxEntries;
  final List<String> _entries = [];

  List<String> get entries => List.unmodifiable(_entries);
  bool get isEmpty => _entries.isEmpty;
  String? get current => _entries.isEmpty ? null : _entries.last;

  static String _pathOf(String location) => Uri.parse(location).path;

  void record(String location) {
    final path = _pathOf(location);
    if (_entries.isNotEmpty && _pathOf(_entries.last) == path) {
      _entries[_entries.length - 1] = location;
      return;
    }
    _entries.add(location);
    if (_entries.length > maxEntries) {
      _entries.removeRange(0, _entries.length - maxEntries);
    }
  }

  void seedIfEmpty(String location) {
    if (_entries.isEmpty) record(location);
  }

  void sync(String location) {
    if (_entries.isEmpty) {
      record(location);
      return;
    }
    if (_pathOf(_entries.last) == _pathOf(location)) {
      _entries[_entries.length - 1] = location;
    } else {
      record(location);
    }
  }

  BackTarget? resolveBack(
    String location, {
    required bool secondary,
    String? fallbackParent,
  }) {
    final path = _pathOf(location);
    if (secondary) {
      if (fallbackParent != null) {
        return BackTarget(location: fallbackParent, pop: false);
      }
      if (_entries.isNotEmpty) {
        return BackTarget(location: _entries.last, pop: false);
      }
      return path == '/' ? null : const BackTarget(location: '/', pop: false);
    }

    if (_entries.isEmpty) {
      return path == '/' ? null : const BackTarget(location: '/', pop: false);
    }
    if (_pathOf(_entries.last) != path) {
      return path == '/'
          ? null
          : BackTarget(location: _entries.last, pop: false);
    }
    if (_entries.length > 1) {
      return BackTarget(location: _entries[_entries.length - 2], pop: true);
    }
    if (path == '/') return null;
    return const BackTarget(location: '/', pop: false, replace: true);
  }

  void commit(BackTarget target) {
    if (target.pop) {
      if (_entries.isNotEmpty) _entries.removeLast();
      if (_entries.isEmpty) {
        record(target.location);
      } else {
        _entries[_entries.length - 1] = target.location;
      }
      return;
    }
    if (target.replace) {
      if (_entries.isEmpty) {
        record(target.location);
      } else {
        _entries[_entries.length - 1] = target.location;
      }
      return;
    }
    record(target.location);
  }

  void clear() => _entries.clear();
}
