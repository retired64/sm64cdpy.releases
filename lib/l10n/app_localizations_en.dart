// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get hello => 'Hello';

  @override
  String get navHome => 'Home';

  @override
  String get navCatalog => 'Catalog';

  @override
  String get navFavourites => 'Favourites';

  @override
  String get navPopular => 'Popular';

  @override
  String get navVIPMods => 'VIP Mods';

  @override
  String get navDynOS => 'DynOS';

  @override
  String get navTouchControls => 'Touch Controls';

  @override
  String get navOmmRebirth => 'OMMR PACK';

  @override
  String get navLinksResource => 'Links Resource';

  @override
  String get navDisclaimer => 'Disclaimer';

  @override
  String get navChangelog => 'Changelog';

  @override
  String get navSettings => 'Settings';

  @override
  String get sectionExclusive => 'EXCLUSIVE';

  @override
  String get sectionExplore => 'EXPLORE';

  @override
  String get sectionCategories => 'CATEGORIES';

  @override
  String get sectionSortBy => 'SORT BY';

  @override
  String get sectionSocialLinks => 'SOCIAL LINKS';

  @override
  String get sortDefault => 'Default';

  @override
  String get sortRating => 'Rating';

  @override
  String get sortDownloads => 'Downloads';

  @override
  String get sortNewest => 'Newest Update';

  @override
  String get socialYouTube => 'YouTube';

  @override
  String get socialDiscord => 'Discord';

  @override
  String get socialGitHub => 'GitHub';

  @override
  String get categoryCharacters => 'Characters';

  @override
  String get categoryGameModes => 'Game Modes';

  @override
  String get categoryROMHacks => 'ROM Hacks & Levels';

  @override
  String get categoryGameplay => 'Gameplay & Mechanics';

  @override
  String get categoryVisual => 'Visual & Models';

  @override
  String get categoryAudio => 'Audio & Voice';

  @override
  String get categoryUtilities => 'Utilities & Tools';

  @override
  String get categoryMisc => 'Misc & Fun';

  @override
  String get badgeFeatured => 'FEATURED';

  @override
  String get updateRequired => 'UPDATE REQUIRED';

  @override
  String get updateAvailable => 'NEW VERSION AVAILABLE';

  @override
  String updateVersion(String version) {
    return 'Version $version';
  }

  @override
  String updateSize(String size) {
    return 'Size: $size MB';
  }

  @override
  String get updateWhatIsNew => 'What\'s new:';

  @override
  String get updateGenericDescription => 'Minor improvements and bug fixes.';

  @override
  String updateDownloading(String pct) {
    return 'Downloading... $pct%';
  }

  @override
  String get updateAlreadyDownloading =>
      'A download is already in progress. Wait or restart the app.';

  @override
  String get updatePermissionDenied =>
      'Install permission denied.\nGo to Settings → Apps → this app → Install unknown apps.';

  @override
  String updateInternalError(String detail) {
    return 'Internal error: $detail';
  }

  @override
  String get updateDownloadError => 'Download error. Check your connection.';

  @override
  String get updateChecksumError =>
      'The downloaded file is corrupt. Please try again.';

  @override
  String updateInstallError(String detail) {
    return 'Install error: $detail';
  }

  @override
  String updateUnexpectedError(String detail) {
    return 'Unexpected error: $detail';
  }

  @override
  String updateCantStart(String detail) {
    return 'Could not start the update: $detail';
  }

  @override
  String get updateButtonOpenBrowser => 'OPEN IN BROWSER';

  @override
  String get updateButtonLater => 'LATER';

  @override
  String get updateButtonExit => 'EXIT';

  @override
  String get updateButtonUpdateNow => 'UPDATE NOW';

  @override
  String get updateButtonGoToDownloads => 'GO TO DOWNLOADS';

  @override
  String get postInstallTitle => 'Mod installed';

  @override
  String get postInstallGameRunning =>
      'If the game was already running, close it completely (not just minimize) and reopen it so the new files are loaded correctly.';

  @override
  String get postInstallNoRoot =>
      'No force-stop or root needed — just close the game normally and reopen it.';

  @override
  String get postInstallFilesCopied =>
      'Files have been copied to the mods folder.';

  @override
  String get postInstallClose => 'Close';

  @override
  String get postInstallLaunchGame => 'LAUNCH GAME';

  @override
  String get homeExclusiveContent => 'Exclusive Content';

  @override
  String get homeTopDownloads => 'Top Downloads';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeFeatured => 'Featured';

  @override
  String get homeCatalog => 'Catalog';

  @override
  String get homeCatalogDesc =>
      'Browse, search & filter the full mod collection';

  @override
  String get homeFavorites => 'Favorites';

  @override
  String get homeFavoritesDesc => 'Your saved mods across all sections';

  @override
  String get homePopular => 'Popular';

  @override
  String get homePopularDesc => 'Top mods ranked by total downloads';

  @override
  String get homeBrowse => 'Browse';

  @override
  String get homeGoTo => 'GO TO';

  @override
  String get homeVipMods => 'VIP Mods';

  @override
  String get homeVipModsDesc => 'Exclusive character & model packs';

  @override
  String get homeDynos => 'DynOS';

  @override
  String get homeDynosDesc => 'Custom textures & model swaps';

  @override
  String get homeTouchControls => 'Touch Controls';

  @override
  String get homeTouchControlsDesc => 'Custom button & joystick layouts';

  @override
  String get homeOmmrPack => 'OMMR PACK';

  @override
  String get homeOmmrPackDesc => 'Complete OMM Rebirth texture pack';

  @override
  String get homeGameNotInstalled => 'Game not installed';

  @override
  String get homeGameNotInstalledBody =>
      'SM64CoopDX (com.maniscat2.sm64coopdx)\nis not installed on this device.';

  @override
  String get homeClose => 'Close';

  @override
  String get homeDownload => 'Download';

  @override
  String get homeLaunchGame => 'LAUNCH  GAME';

  @override
  String get homeSoon => 'SOON';

  @override
  String get homeFailedToLoad => 'Failed to load mods';

  @override
  String get homeRetry => 'Retry';

  @override
  String get catalogueTitle => 'BROWSE MODS';

  @override
  String catalogueModCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count MODS',
      one: '$count MOD',
    );
    return '$_temp0';
  }

  @override
  String catalogueResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count RESULT',
      one: '$count RESULT',
    );
    return '$_temp0';
  }

  @override
  String get catalogueSearchHint => 'SEARCH MODS, AUTHORS, TAGS…';

  @override
  String get catalogueSortDefault => 'Default';

  @override
  String get catalogueSortTopRated => 'Top Rated';

  @override
  String get catalogueSortMostDownloaded => 'Most Downloaded';

  @override
  String get catalogueSortRecentlyUpdated => 'Recently Updated';

  @override
  String get catalogueClearAll => 'CLEAR ALL';

  @override
  String cataloguePaginationRange(int start, int end, int total) {
    return '$start–$end OF $total MODS';
  }

  @override
  String get catalogueNoModsFound => 'NO MODS FOUND';

  @override
  String get catalogueNothingHere => 'NOTHING HERE YET';

  @override
  String get catalogueEmptyHint1 => 'Try different keywords or remove filters.';

  @override
  String get catalogueEmptyHint2 => 'Check back later for new content.';

  @override
  String get catalogueClearFilters => 'CLEAR FILTERS';

  @override
  String get catalogueFailedToLoad => 'FAILED TO LOAD MODS';

  @override
  String get catalogueRating => 'RATING';

  @override
  String get catalogueDownloads => 'DOWNLOADS';

  @override
  String get catalogueNewest => 'NEWEST';

  @override
  String get catalogueSort => 'SORT';

  @override
  String get catalogueEllipsis => '···';

  @override
  String get popularTitle => 'POPULAR';

  @override
  String popularModCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count MODS',
      one: '$count MOD',
    );
    return '$_temp0';
  }

  @override
  String get popularMoreRankings => 'MORE RANKINGS';

  @override
  String get popularRankings => 'RANKINGS';

  @override
  String popularPage(int page, int total) {
    return 'PG $page/$total';
  }

  @override
  String get popularTop3 => 'TOP 3';

  @override
  String popularRank(int rank) {
    return '#$rank';
  }

  @override
  String get popularFailedToLoad => 'FAILED TO LOAD';

  @override
  String get favouritesTitle => 'Favorites';

  @override
  String get favTabMods => 'Mods';

  @override
  String get favTabVip => 'VIP';

  @override
  String get favTabDynos => 'DynOS';

  @override
  String get favTabTouch => 'Touch';

  @override
  String get favEmptyMods => 'No mods favourited yet';

  @override
  String get favEmptyVip => 'No VIP mods favourited yet';

  @override
  String get favEmptyDynos => 'No DynOS favourited yet';

  @override
  String get favEmptyTouch => 'No Touch Controls favourited yet';

  @override
  String favEmptyHint(String type) {
    return 'Tap ♥ on any $type to save it here.';
  }

  @override
  String get favBrowse => 'Browse';

  @override
  String get sharedAddedToFavorites => 'Added to favorites';

  @override
  String get sharedRemovedFromFavorites => 'Removed from favorites';

  @override
  String sharedDownloaded(String name) {
    return 'Downloaded: $name';
  }

  @override
  String sharedDownloadedType(String type, String name) {
    return 'Downloaded $type: $name';
  }

  @override
  String get sharedDownloadFailed => 'Download failed';

  @override
  String get sharedAddToFavorites => 'ADD TO FAVORITES';

  @override
  String get sharedRemoveFromFavorites => 'REMOVE FROM FAVORITES';

  @override
  String get sharedDownload => 'DOWNLOAD';

  @override
  String get sharedReadMore => 'READ MORE';

  @override
  String get sharedShowLess => 'SHOW LESS';

  @override
  String get vipTitle => 'VIP MODS';

  @override
  String get vipEmpty => 'NO VIP MODS YET';

  @override
  String get vipEmptyHint => 'Check back later for exclusive content.';

  @override
  String get vipFailedToLoad => 'FAILED TO LOAD VIP MODS';

  @override
  String get dynosTitle => 'DYNOS';

  @override
  String get dynosEmpty => 'NO DYNOS YET';

  @override
  String get dynosEmptyHint => 'Check back later for runtime patches.';

  @override
  String get dynosFailedToLoad => 'FAILED TO LOAD DYNOS';

  @override
  String get touchTitle => 'TOUCH CONTROLS';

  @override
  String touchModCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count LAYOUTS',
      one: '$count LAYOUT',
    );
    return '$_temp0';
  }

  @override
  String get touchEmpty => 'NO TOUCH LAYOUTS YET';

  @override
  String get touchEmptyHint => 'Check back later for mobile control layouts.';

  @override
  String get touchFailedToLoad => 'FAILED TO LOAD TOUCH CONTROLS';

  @override
  String get ommTitle => 'OMM REBIRTH';

  @override
  String get ommEmpty => 'NO OMM REBIRTH MODS YET';

  @override
  String get ommEmptyHint => 'Check back later for OMM Rebirth content.';

  @override
  String get ommFailedToLoad => 'FAILED TO LOAD OMM REBIRTH MODS';

  @override
  String get detailDownload => 'Download';

  @override
  String get detailDownloadButton => 'DOWNLOAD';

  @override
  String get detailModNotFound => 'Mod not found';

  @override
  String get detailModNotFoundBody =>
      'This mod may have been removed or the link is invalid.';

  @override
  String get detailGoBack => 'Go back';

  @override
  String get detailFailedToLoad => 'Failed to load mod';

  @override
  String get detailRetry => 'Retry';

  @override
  String get detailNotificationsNeeded => 'Notifications needed';

  @override
  String get detailNotificationsBody =>
      'We need notification permission to show download and installation progress, even if you leave the app.';

  @override
  String get detailNotNow => 'Not now';

  @override
  String get detailContinue => 'Continue';

  @override
  String get detailNotificationsSkipped =>
      'You won\'t see progress outside the app. Grant permission in Settings to enable notifications.';

  @override
  String get detailModsFolderNotSelected => 'Mods folder not selected';

  @override
  String get detailModsFolderBody =>
      'You need to select a mods folder before installing mods to the game.\n\nGo to Settings → Game Integration to select it.';

  @override
  String get detailCancel => 'Cancel';

  @override
  String get detailGoToSettings => 'Go to Settings';

  @override
  String detailDownloading(String filename) {
    return 'Downloading \"$filename\"...';
  }

  @override
  String detailSavedToModsFolder(String name) {
    return 'Saved to mods folder: $name';
  }

  @override
  String detailSavedToFolder(String type, String name) {
    return 'Saved to $type folder: $name';
  }

  @override
  String get detailDownloadFailed => 'Download failed';

  @override
  String detailError(String detail) {
    return 'Error: $detail';
  }

  @override
  String detailDownloaded(String name) {
    return 'Downloaded: $name';
  }

  @override
  String detailDownloadedType(String type, String name) {
    return 'Downloaded $type: $name';
  }

  @override
  String get detailDownloadingBanner => 'Downloading mod...';

  @override
  String detailDownloadingBannerType(String type) {
    return 'Downloading $type...';
  }

  @override
  String detailFilesProgress(int current, int total) {
    return '$current/$total files';
  }

  @override
  String get detailExtracting => 'Extracting...';

  @override
  String get detailInstallingMod => 'Installing mod...';

  @override
  String get detailInstallComplete => 'Installation complete';

  @override
  String detailInstallFilesExtracted(int count, String dir) {
    return '$count files extracted to \"$dir\"';
  }

  @override
  String get detailInstallFailed => 'Installation failed';

  @override
  String get detailOperationCancelled => 'Operation cancelled';

  @override
  String detailDownloadingPct(String pct) {
    return 'Downloading $pct%';
  }

  @override
  String get detailInstalling => 'Installing...';

  @override
  String get detailScreenshots => 'Screenshots';

  @override
  String get detailTags => 'Tags';

  @override
  String get detailAbout => 'About';

  @override
  String get detailRating => 'Rating';

  @override
  String get detailDownloads => 'Downloads';

  @override
  String get detailViews => 'Views';

  @override
  String get detailReviews => 'Reviews';

  @override
  String detailDownloadFiles(int count) {
    return 'Download files ($count)';
  }

  @override
  String detailVersions(int count) {
    return 'Versions ($count)';
  }

  @override
  String get detailVersionFallback => 'v?';

  @override
  String get detailFirstRelease => 'First Release';

  @override
  String get detailLastUpdate => 'Last Update';

  @override
  String get detailChangelog => 'Changelog';

  @override
  String get detailCollapseChangelog => 'Collapse changelog';

  @override
  String detailViewAllUpdates(int count) {
    return 'View all $count updates';
  }

  @override
  String get detailShowLess => 'Show less';

  @override
  String get detailShowMore => 'Show more';

  @override
  String get detailNotificationsDisabled =>
      'Notifications not enabled. You won\'t see download progress outside the app.';

  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get settingsData => 'DATA';

  @override
  String get settingsClearFavourites => 'Clear favourites';

  @override
  String get settingsClearFavouritesDesc => 'Remove all saved mods';

  @override
  String get settingsExportFavourites => 'Export favourites';

  @override
  String get settingsExportFavouritesDesc => 'Share your saved mods';

  @override
  String get settingsImportFavourites => 'Import favourites';

  @override
  String get settingsImportFavouritesDesc =>
      'Restore from a previously exported file';

  @override
  String get settingsGameIntegration => 'GAME INTEGRATION';

  @override
  String get settingsAppearance => 'APPEARANCE';

  @override
  String get settingsAbout => 'ABOUT';

  @override
  String get settingsGoToReleases => 'Go to releases';

  @override
  String settingsViewAllVersions(String version) {
    return 'View all versions on GitHub · v$version';
  }

  @override
  String get settingsDataSource => 'Data source';

  @override
  String get settingsNoFavouritesToExport =>
      'You have no favourites to export.';

  @override
  String settingsImportAdded(int count) {
    return '$count added';
  }

  @override
  String settingsImportAlreadySaved(int count) {
    return '$count already saved';
  }

  @override
  String settingsImportNotFound(int count) {
    return '$count not found in catalogue';
  }

  @override
  String get settingsImportNothingNew => 'Nothing new to import.';

  @override
  String get settingsImportComplete => 'Import complete';

  @override
  String get settingsClearFavouritesTitle => 'CLEAR FAVOURITES?';

  @override
  String get settingsClearFavouritesBody =>
      'This will remove all your saved mods. This action cannot be undone.';

  @override
  String get settingsClearButton => 'CLEAR';

  @override
  String get settingsFavouritesCleared => 'Favourites cleared';

  @override
  String settingsCannotOpenUrl(String url) {
    return 'Cannot open URL: $url';
  }

  @override
  String get settingsCancel => 'CANCEL';

  @override
  String get settingsModsFolderSelected =>
      'Mods folder selected. Mods will be installed here.';

  @override
  String get settingsClearModsFolderTitle => 'CLEAR MODS FOLDER?';

  @override
  String get settingsClearModsFolderBody =>
      'You will need to select the folder again before installing mods to the game.';

  @override
  String get settingsModsFolderCleared => 'Mods folder selection cleared.';

  @override
  String get settingsModsFolder => 'Mods folder';

  @override
  String get settingsSelectModsFolder => 'Select mods folder';

  @override
  String get settingsModsFolderHint => 'Tap to change · Long-press to clear';

  @override
  String get settingsModsFolderDesc =>
      'Choose where to install downloaded mods';

  @override
  String get settingsAutoInstall => 'Auto-install after download';

  @override
  String get settingsAutoInstallOn =>
      'Mods will be automatically installed to the game folder';

  @override
  String get settingsAutoInstallOff => 'You will be asked after each download';

  @override
  String get settingsThemeMode => 'THEME MODE';

  @override
  String settingsDatabaseUpdated(int count, String date) {
    return 'Database updated · $count mods$date';
  }

  @override
  String get settingsUnknownError => 'Unknown error';

  @override
  String get settingsReloadDatabase => 'Reload database';

  @override
  String get settingsDownloading => 'Downloading...';

  @override
  String get settingsDownloadLatest => 'Download latest mod list';

  @override
  String settingsUpToDate(String version) {
    return 'You\'re up to date · v$version';
  }

  @override
  String get settingsCheckForUpdates => 'Check for updates';

  @override
  String get settingsChecking => 'Checking...';

  @override
  String get changelogTitle => 'Changelog';

  @override
  String get changelogNew => 'New';

  @override
  String get changelogImproved => 'Improved';

  @override
  String get changelogFixed => 'Fixed';

  @override
  String get changelogRemoved => 'Removed';

  @override
  String get changelogChanged => 'Changed';

  @override
  String get changelogLatest => 'Latest';

  @override
  String get generalSettings => 'Settings';

  @override
  String get generalRetry => 'Retry';

  @override
  String get linksTitle => 'LINKS ';

  @override
  String get linksSubtitle => '& RECURSOS';

  @override
  String get linksOfficiaSection => 'OFFICIAL';

  @override
  String get linksOfficialDesc =>
      'Verified channels from the SM64CoopDX project.';

  @override
  String get linksSm64cdpySection => 'SM64CDPY';

  @override
  String get linksSm64cdpyDesc => 'Downloads and content from this app.';

  @override
  String get linksResourcesSection => 'RESOURCES';

  @override
  String get linksResourcesDesc =>
      'Community, guides, and step-by-step installation.';

  @override
  String get linksHeroTitle => 'LINK HUB';

  @override
  String get linksHeroDesc =>
      'Everything official, the community, and project resources in one place.';

  @override
  String get linksChipTap => 'TAP = OPEN';

  @override
  String get linksChipHold => 'HOLD = COPY';

  @override
  String get linksWebsite => 'SM64CoopDX Website';

  @override
  String get linksWebsiteUrl => 'sm64coopdx.com';

  @override
  String get linksKindWeb => 'WEB';

  @override
  String get linksDiscordServer => 'Discord Server';

  @override
  String get linksDiscordOfficial => 'Official community server · Android';

  @override
  String get linksKindDiscord => 'DISCORD';

  @override
  String get linksGithubRepo => 'GitHub Repository';

  @override
  String get linksGithubDesc => 'Source code & issues';

  @override
  String get linksKindGithub => 'GITHUB';

  @override
  String get linksGithubReleases => 'GitHub Releases';

  @override
  String get linksGithubReleasesDesc => 'Download latest APK';

  @override
  String get linksKindDownload => 'DOWNLOAD';

  @override
  String get linksYoutubeChannel => 'YouTube Channel';

  @override
  String get linksYoutubeHandle => '@retired64';

  @override
  String get linksKindYoutube => 'YOUTUBE';

  @override
  String get linksDiscordCommunity => 'Community & support server';

  @override
  String get linksWiki => 'Wiki & Guides';

  @override
  String get linksWikiDesc => 'Installation guides & docs';

  @override
  String get linksKindWiki => 'WIKI';

  @override
  String get linksTools => 'Tools & Add-ons';

  @override
  String get linksToolsDesc => 'How to make mods & resources';

  @override
  String get linksKindTools => 'TOOLS';

  @override
  String get linksCouldNotOpen => 'Could not open link';

  @override
  String get linksCopied => 'Link copied';

  @override
  String get disclaimerTitle => 'Disclaimer';

  @override
  String get disclaimerDeveloperContact => 'Developer contact';

  @override
  String get disclaimerDiscordReach => 'Reach me on my Discord server';

  @override
  String get disclaimerDiscord => 'Discord';

  @override
  String disclaimerFooter(String version) {
    return 'v$version · for personal use · Unofficial';
  }

  @override
  String get disclaimerUnofficialBanner => 'Unofficial Fan-Made';

  @override
  String get disclaimerAppSubtitle => 'SM64CoopDX Mods Manager';

  @override
  String get disclaimerWarningBody =>
      'This app is a personal project. Any issues related to it (functionality, bugs, etc.) are the sole responsibility of the developer. The SM64CoopDX developers and mod creators bear no responsibility whatsoever for this application.';

  @override
  String get disclaimerCouldNotOpenLink => 'Could not open the link';

  @override
  String get disclaimerSectionPersonalPurpose => 'Personal purpose';

  @override
  String get disclaimerBodyPersonalPurpose =>
      'This application was independently developed as a personal project. Its sole purpose is to give me faster access, organization, and download management for mods I use for my own entertainment. It is not an application supported by the SM64CoopDX team or an official service of any kind.';

  @override
  String get disclaimerSectionNoAffiliation => 'No official affiliation';

  @override
  String get disclaimerBodyNoAffiliation =>
      'This project is not associated with, endorsed by, or approved by the developers of SM64CoopDX, Super Mario 64, Nintendo, or any of the mod creators listed. All names, images, and content displayed belong to their respective authors.';

  @override
  String get disclaimerSectionDataSource => 'Data source';

  @override
  String get disclaimerBodyDataSource =>
      'Mod information comes from the public catalog at mods.sm64coopdx.com. This app only presents that information in a more accessible way; it does not host, modify, or redistribute any mod files.';

  @override
  String get disclaimerSectionExclusive =>
      'Exclusive sections (VIP · DynOS · Touch Controls)';

  @override
  String disclaimerBodyExclusive(Object version) {
    return 'Starting with v$version, the app includes curated sections with content not officially listed on the SM64CoopDX website. These sections (VIP Mods, DynOS packs, and Touch Control layouts) are maintained independently by the developer and are not affiliated with any official source. All credit goes to the original creators.';
  }

  @override
  String get disclaimerSectionBugs => 'Bugs, suggestions & requests';

  @override
  String get disclaimerBodyBugs =>
      'If you find an issue with this app, have a suggestion, or want to request something, contact me directly through my social media. Please do not contact the official SM64CoopDX developers or mod creators about anything related to this application.';

  @override
  String get vipSectionHeader => 'EXCLUSIVE CONTENT';

  @override
  String get dynosSectionHeader => 'CUSTOM DYNOS';

  @override
  String get touchSectionHeader => 'MOBILE LAYOUTS';

  @override
  String get ommSectionHeader => 'OMM REBIRTH MODS';

  @override
  String sharedModCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count MODS',
      one: '$count MOD',
    );
    return '$_temp0';
  }

  @override
  String get settingsDynosFolder => 'DynOS folder';

  @override
  String get settingsSelectDynosFolder => 'Select DynOS folder';

  @override
  String get settingsDynosFolderHint => 'Tap to change · Long-press to clear';

  @override
  String get settingsDynosFolderDesc =>
      'Choose where to install DynOS and Touch Controls packs';

  @override
  String get settingsDynosFolderSelected =>
      'DynOS folder selected. Packs will be installed here.';

  @override
  String get settingsClearDynosFolderTitle => 'CLEAR DYNOS FOLDER?';

  @override
  String get settingsClearDynosFolderBody =>
      'You will need to select the folder again before installing DynOS or Touch Control packs.';

  @override
  String get settingsDynosFolderCleared => 'DynOS folder selection cleared.';

  @override
  String get settingsLanguageMode => 'LANGUAGE';

  @override
  String get languageFollowSystem => 'Follow system';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get overlaySearchHint => 'SEARCH...';

  @override
  String get overlayNoResponse =>
      'No response — open the main app once, then try again';

  @override
  String get overlaySelectFolder => 'Select a folder first (Settings)';

  @override
  String get overlayEnableAutoInstall => 'Enable auto-install first (Settings)';

  @override
  String get overlayDownloadFailed => 'Download failed';

  @override
  String get overlayTapToCancel => 'TAP TO CANCEL';

  @override
  String get overlayInstalling => 'Installing...';

  @override
  String get overlayConnecting => 'Connecting...';

  @override
  String get overlayNoResults => 'NO RESULTS';

  @override
  String get overlayError => 'ERROR';

  @override
  String get settingsOverlayActive => 'Chathead active';

  @override
  String get settingsOverlayInactive => 'Floating overlay';

  @override
  String get settingsOverlayActiveDesc => 'Tap to hide the bubble';

  @override
  String get settingsOverlayInactiveDesc =>
      'Tap to show the bubble over the game';
}
