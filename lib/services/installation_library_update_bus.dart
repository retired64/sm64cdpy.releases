import 'dart:async';

import '../domain/entities/installation_library.dart';

/// Process-local invalidation bus for projections of the durable library.
///
/// This is not a source of truth and never crosses Flutter engines directly.
/// It lets the main-engine overlay bridge observe every repository refresh and
/// serialize the resulting snapshot through `floaty_chatheads`.
class InstallationLibraryUpdateBus {
  InstallationLibraryUpdateBus._();

  static final _controller =
      StreamController<InstallationLibrarySnapshot>.broadcast(sync: true);

  static Stream<InstallationLibrarySnapshot> get snapshots =>
      _controller.stream;

  static void publish(InstallationLibrarySnapshot snapshot) {
    _controller.add(snapshot);
  }
}
