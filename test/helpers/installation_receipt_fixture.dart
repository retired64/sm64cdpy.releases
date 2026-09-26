Map<String, dynamic> installationReceiptFixture({
  String artifactKey = 'v1|mods|content-1|file-1',
  String workerId = 'worker-1',
  String installedAt = '2026-09-25T10:00:00Z',
}) => {
  'schemaVersion': 1,
  'contentKey': 'v1|mods|content-1',
  'artifactKey': artifactKey,
  'operationKey': artifactKey,
  'section': 'mods',
  'contentId': 'content-1',
  'artifactId': artifactKey.split('|').last,
  'destination': 'mods',
  'installedAt': installedAt,
  'installWorkerId': workerId,
  'eventKind': 'install',
  'fileCount': 2,
  'sentinels': [
    {'relativePath': 'sample/main.lua', 'kind': 'file'},
  ],
  'source': 'sm64cdpy',
  'displaySnapshot': {
    'title': 'Sample',
    'versionLabel': 'v1.0',
    'filename': 'sample.zip',
  },
  'packageShape': 'single_root',
};
