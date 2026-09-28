import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/install_identity.dart';
import '../../domain/entities/installation_catalog.dart';
import '../../domain/entities/mod_version_resolver.dart';
import 'extra_providers.dart';
import 'installation_library_provider.dart';
import 'mod_providers.dart';

final installationCatalogTargetsProvider =
    FutureProvider<List<InstallationCatalogTarget>>((ref) async {
      final modsFuture = ref.watch(allModsProvider.future);
      final vipFuture = ref.watch(allVipModsProvider.future);
      final dynosFuture = ref.watch(allDynosProvider.future);
      final touchFuture = ref.watch(allTouchControlsProvider.future);
      final ommFuture = ref.watch(allOmmRebirthProvider.future);
      final render96Future = ref.watch(allRender96Provider.future);

      final mods = await modsFuture;
      final vip = await vipFuture;
      final dynos = await dynosFuture;
      final touch = await touchFuture;
      final omm = await ommFuture;
      final render96 = await render96Future;
      final targets = <InstallationCatalogTarget>[];

      for (final mod in mods) {
        final latest = resolveLatestDownloadableVersion(mod.versions);
        if (latest != null) {
          for (final file in latest.files) {
            targets.add(
              InstallationCatalogTarget(
                identity: InstallIdentity.forCatalogArtifact(
                  section: InstallSection.mods,
                  contentId: mod.id,
                  downloadUrl: file.file.downloadUrl,
                  versionLabel: latest.version.version,
                  fileName: file.file.filename,
                  explicitFileId: file.operationFileKey,
                ),
                title: mod.title,
                route: '/mod/${Uri.encodeComponent(mod.id)}',
              ),
            );
          }
          continue;
        }
        for (final entry
            in mod.downloadUrls
                .where((url) => url.trim().isNotEmpty)
                .toList(growable: false)
                .asMap()
                .entries) {
          targets.add(
            InstallationCatalogTarget(
              identity: InstallIdentity.forCatalogArtifact(
                section: InstallSection.mods,
                contentId: mod.id,
                downloadUrl: entry.value,
                versionLabel: mod.version,
                explicitFileId: entry.key == 0
                    ? 'primary'
                    : 'file-${entry.key}',
              ),
              title: mod.title,
              route: '/mod/${Uri.encodeComponent(mod.id)}',
            ),
          );
        }
      }

      for (final mod in vip) {
        targets.add(
          InstallationCatalogTarget(
            identity: InstallIdentity.forCatalogArtifact(
              section: InstallSection.vip,
              contentId: mod.id,
              downloadUrl: mod.downloadUrl,
              versionLabel: mod.version,
            ),
            title: mod.title,
            route: '/vip',
          ),
        );
      }
      for (final mod in dynos) {
        targets.add(
          InstallationCatalogTarget(
            identity: InstallIdentity.forCatalogArtifact(
              section: InstallSection.dynos,
              contentId: mod.id,
              downloadUrl: mod.downloadUrl,
              versionLabel: mod.version,
            ),
            title: mod.title,
            route: '/dynos',
          ),
        );
      }
      for (final mod in touch) {
        targets.add(
          InstallationCatalogTarget(
            identity: InstallIdentity.forCatalogArtifact(
              section: InstallSection.touchControls,
              contentId: mod.id,
              downloadUrl: mod.downloadUrl,
            ),
            title: mod.title,
            route: '/touch-controls',
          ),
        );
      }
      for (final mod in omm) {
        targets.add(
          InstallationCatalogTarget(
            identity: InstallIdentity.forCatalogArtifact(
              section: InstallSection.omm,
              contentId: mod.id,
              downloadUrl: mod.downloadUrl,
              versionLabel: mod.version,
            ),
            title: mod.title,
            route: '/omm-rebirth',
          ),
        );
      }
      for (final mod in render96) {
        targets.add(
          InstallationCatalogTarget(
            identity: InstallIdentity.forCatalogArtifact(
              section: InstallSection.render96,
              contentId: mod.id,
              downloadUrl: mod.downloadUrl,
              versionLabel: mod.version,
            ),
            title: mod.name,
            route: '/render96',
          ),
        );
      }
      return List.unmodifiable(targets);
    });

final installationUpdatesProvider =
    FutureProvider<List<InstallationUpdateCandidate>>((ref) async {
      final libraryFuture = ref.watch(installationLibraryProvider.future);
      final targetsFuture = ref.watch(
        installationCatalogTargetsProvider.future,
      );
      final library = await libraryFuture;
      final targets = await targetsFuture;
      return InstallationCatalogMatcher.updates(
        library: library.snapshot,
        targets: targets,
      );
    });
