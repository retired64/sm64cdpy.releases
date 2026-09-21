import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/dynos_entity.dart';
import '../domain/entities/mod_entity.dart';
import '../domain/entities/mod_version_resolver.dart';
import '../domain/entities/omm_rebirth_entity.dart';
import '../domain/entities/render96_entity.dart';
import '../domain/entities/touch_control_entity.dart';
import '../domain/entities/vip_mod_entity.dart';
import '../presentation/providers/extra_providers.dart';
import '../presentation/providers/mod_providers.dart';

enum OverlaySection { all, vip, dynos, touchControls, omm, render96 }

extension OverlaySectionLabel on OverlaySection {
  String get label => switch (this) {
    OverlaySection.all => 'ALL',
    OverlaySection.vip => 'VIP',
    OverlaySection.dynos => 'DYN',
    OverlaySection.touchControls => 'TCH',
    OverlaySection.omm => 'OMM',
    OverlaySection.render96 => 'R96',
  };
}

class OverlayModItem {
  const OverlayModItem({
    required this.id,
    required this.title,
    required this.downloadOptions,
    this.imageUrl,
    required this.section,
    required this.installDestination,
  });

  final String id;
  final String title;
  final List<OverlayDownloadOption> downloadOptions;
  final String? imageUrl;
  final OverlaySection section;
  final String installDestination;

  factory OverlayModItem.fromModEntity(ModEntity m) {
    final latest = resolveLatestDownloadableVersion(m.versions);
    final options = latest != null
        ? latest.files
              .map(
                (file) => OverlayDownloadOption(
                  url: file.file.downloadUrl,
                  filename: file.file.filename,
                  fileKey: file.operationFileKey,
                  versionLabel: latest.version.version,
                ),
              )
              .toList(growable: false)
        : m.downloadUrls
              .where((url) => url.trim().isNotEmpty)
              .toList(growable: false)
              .asMap()
              .entries
              .map(
                (entry) => OverlayDownloadOption(
                  url: entry.value,
                  filename: '',
                  fileKey: entry.key == 0 ? 'primary' : 'file-${entry.key}',
                  versionLabel: m.version,
                ),
              )
              .toList(growable: false);
    return OverlayModItem(
      id: m.id,
      title: m.title,
      downloadOptions: options,
      imageUrl: m.imageUrl,
      section: OverlaySection.all,
      installDestination: 'mods',
    );
  }

  factory OverlayModItem.fromVip(VipModEntity m) => OverlayModItem(
    id: m.id,
    title: m.title,
    downloadOptions: [OverlayDownloadOption.primary(m.downloadUrl, m.version)],
    imageUrl: m.imageUrl,
    section: OverlaySection.vip,
    installDestination: 'mods',
  );

  factory OverlayModItem.fromDynos(DynosEntity m) => OverlayModItem(
    id: m.id,
    title: m.title,
    downloadOptions: [OverlayDownloadOption.primary(m.downloadUrl, m.version)],
    imageUrl: m.imageUrl,
    section: OverlaySection.dynos,
    installDestination: 'dynos',
  );

  factory OverlayModItem.fromTouch(TouchControlEntity m) => OverlayModItem(
    id: m.id,
    title: m.title,
    downloadOptions: [OverlayDownloadOption.primary(m.downloadUrl, '')],
    imageUrl: m.imageUrl,
    section: OverlaySection.touchControls,
    installDestination: 'dynos',
  );

  factory OverlayModItem.fromOmm(OmmRebirthEntity m) => OverlayModItem(
    id: m.id,
    title: m.title,
    downloadOptions: [OverlayDownloadOption.primary(m.downloadUrl, '')],
    imageUrl: m.imageUrl,
    section: OverlaySection.omm,
    installDestination: m.id == 'cappy-bros-dynos' ? 'dynos' : 'mods',
  );

  factory OverlayModItem.fromRender96(Render96Entity m) => OverlayModItem(
    id: m.id,
    title: m.name,
    downloadOptions: [
      OverlayDownloadOption.primary(m.downloadUrl, m.version ?? ''),
    ],
    imageUrl: m.imageUrl,
    section: OverlaySection.render96,
    installDestination: m.installDestination,
  );
}

class OverlayDownloadOption {
  const OverlayDownloadOption({
    required this.url,
    required this.filename,
    required this.fileKey,
    required this.versionLabel,
  });

  factory OverlayDownloadOption.primary(String url, String versionLabel) =>
      OverlayDownloadOption(
        url: url,
        filename: '',
        fileKey: 'primary',
        versionLabel: versionLabel,
      );

  final String url;
  final String filename;
  final String fileKey;
  final String versionLabel;
}

final overlaySectionProvider =
    NotifierProvider<OverlaySectionNotifier, OverlaySection>(
      OverlaySectionNotifier.new,
    );

class OverlaySectionNotifier extends Notifier<OverlaySection> {
  @override
  OverlaySection build() => OverlaySection.all;
  void select(OverlaySection s) => state = s;
}

class OverlaySearchNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String v) => state = v;
}

class OverlayPageNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void set(int v) => state = v;
  void reset() => state = 0;
}

final overlayAllSearchQuery = NotifierProvider<OverlaySearchNotifier, String>(
  OverlaySearchNotifier.new,
);
final overlayVipSearchQuery = NotifierProvider<OverlaySearchNotifier, String>(
  OverlaySearchNotifier.new,
);
final overlayDynosSearchQuery = NotifierProvider<OverlaySearchNotifier, String>(
  OverlaySearchNotifier.new,
);
final overlayTouchSearchQuery = NotifierProvider<OverlaySearchNotifier, String>(
  OverlaySearchNotifier.new,
);
final overlayOmmSearchQuery = NotifierProvider<OverlaySearchNotifier, String>(
  OverlaySearchNotifier.new,
);
final overlayRender96SearchQuery =
    NotifierProvider<OverlaySearchNotifier, String>(OverlaySearchNotifier.new);

final overlayAllPage = NotifierProvider<OverlayPageNotifier, int>(
  OverlayPageNotifier.new,
);
final overlayVipPage = NotifierProvider<OverlayPageNotifier, int>(
  OverlayPageNotifier.new,
);
final overlayDynosPage = NotifierProvider<OverlayPageNotifier, int>(
  OverlayPageNotifier.new,
);
final overlayTouchPage = NotifierProvider<OverlayPageNotifier, int>(
  OverlayPageNotifier.new,
);
final overlayOmmPage = NotifierProvider<OverlayPageNotifier, int>(
  OverlayPageNotifier.new,
);
final overlayRender96Page = NotifierProvider<OverlayPageNotifier, int>(
  OverlayPageNotifier.new,
);

final overlayAllItems = FutureProvider<List<OverlayModItem>>((ref) async {
  final mods = await ref.watch(allModsProvider.future);
  return mods.map(OverlayModItem.fromModEntity).toList();
});

final overlayVipItems = FutureProvider<List<OverlayModItem>>((ref) async {
  final mods = await ref.watch(allVipModsProvider.future);
  return mods.map(OverlayModItem.fromVip).toList();
});

final overlayDynosItems = FutureProvider<List<OverlayModItem>>((ref) async {
  final mods = await ref.watch(allDynosProvider.future);
  return mods.map(OverlayModItem.fromDynos).toList();
});

final overlayTouchItems = FutureProvider<List<OverlayModItem>>((ref) async {
  final mods = await ref.watch(allTouchControlsProvider.future);
  return mods.map(OverlayModItem.fromTouch).toList();
});

final overlayOmmItems = FutureProvider<List<OverlayModItem>>((ref) async {
  final mods = await ref.watch(allOmmRebirthProvider.future);
  return mods.map(OverlayModItem.fromOmm).toList();
});

final overlayRender96Items = FutureProvider<List<OverlayModItem>>((ref) async {
  final mods = await ref.watch(allRender96Provider.future);
  return mods.map(OverlayModItem.fromRender96).toList();
});

FutureProvider<List<OverlayModItem>> itemsProviderFor(OverlaySection s) =>
    switch (s) {
      OverlaySection.all => overlayAllItems,
      OverlaySection.vip => overlayVipItems,
      OverlaySection.dynos => overlayDynosItems,
      OverlaySection.touchControls => overlayTouchItems,
      OverlaySection.omm => overlayOmmItems,
      OverlaySection.render96 => overlayRender96Items,
    };

NotifierProvider<OverlaySearchNotifier, String> searchProviderFor(
  OverlaySection s,
) => switch (s) {
  OverlaySection.all => overlayAllSearchQuery,
  OverlaySection.vip => overlayVipSearchQuery,
  OverlaySection.dynos => overlayDynosSearchQuery,
  OverlaySection.touchControls => overlayTouchSearchQuery,
  OverlaySection.omm => overlayOmmSearchQuery,
  OverlaySection.render96 => overlayRender96SearchQuery,
};

NotifierProvider<OverlayPageNotifier, int> pageProviderFor(OverlaySection s) =>
    switch (s) {
      OverlaySection.all => overlayAllPage,
      OverlaySection.vip => overlayVipPage,
      OverlaySection.dynos => overlayDynosPage,
      OverlaySection.touchControls => overlayTouchPage,
      OverlaySection.omm => overlayOmmPage,
      OverlaySection.render96 => overlayRender96Page,
    };

final overlayFilteredItems = Provider<AsyncValue<List<OverlayModItem>>>((ref) {
  final section = ref.watch(overlaySectionProvider);
  final items = ref.watch(itemsProviderFor(section));
  final search = ref.watch(searchProviderFor(section)).toLowerCase();
  return items.whenData((list) {
    if (search.isEmpty) return list;
    return list.where((m) => m.title.toLowerCase().contains(search)).toList();
  });
});

const _pageSize = 3;

final overlayPaginatedItems = Provider<AsyncValue<List<OverlayModItem>>>((ref) {
  final section = ref.watch(overlaySectionProvider);
  final items = ref.watch(overlayFilteredItems);
  final page = ref.watch(pageProviderFor(section));
  return items.whenData((list) {
    final start = page * _pageSize;
    if (start >= list.length) return <OverlayModItem>[];
    final end = (start + _pageSize).clamp(0, list.length);
    return list.sublist(start, end);
  });
});

final overlayTotalPages = Provider<int>((ref) {
  final items = ref.watch(overlayFilteredItems);
  return items.maybeWhen(
    data: (list) => (list.length / _pageSize).ceil(),
    orElse: () => 0,
  );
});
