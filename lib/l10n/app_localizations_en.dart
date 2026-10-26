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
  String get navVIPMods => 'Mods';

  @override
  String get navDynOS => 'DynOS';

  @override
  String get navTouchControls => 'Touch Controls';

  @override
  String get navOmmRebirth => 'Omm Pack';

  @override
  String get navLinksResource => 'Links';

  @override
  String get navDisclaimer => 'Disclaimer';

  @override
  String get navSettings => 'Settings';

  @override
  String get sectionExclusive => 'Exclusive';

  @override
  String get sectionNavigation => 'NAVIGATION';

  @override
  String get sectionExplore => 'Explore';

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
  String get homeExclusiveContent => 'Exclusive';

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
  String get homeLaunchGame => 'START GAME';

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
    return 'Page $page/$total';
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
  String get installationChecking => 'CHECKING...';

  @override
  String get installationCancel => 'CANCEL';

  @override
  String get installationInstalled => 'INSTALLED';

  @override
  String get installationUpdate => 'UPDATE';

  @override
  String get installationInstall => 'INSTALL';

  @override
  String get installationReinstall => 'REINSTALL';

  @override
  String get installationVerify => 'VERIFY';

  @override
  String get installationSelectFolder => 'SELECT FOLDER';

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
  String get dynosEmptyHint => 'Check back later for new DynOS packs.';

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
  String get overlayCancelling => 'Cancelling...';

  @override
  String get detailDynosFolderNotSelected =>
      'DynOS and Touch Controls folder not selected';

  @override
  String get detailDynosFolderBody =>
      'Select the shared DynOS and Touch Controls folder in Settings → Game Integration before installing this content.';

  @override
  String get detailInstallDownloadedTitle => 'Install downloaded content?';

  @override
  String detailInstallDownloadedBody(String name) {
    return '$name has finished downloading. Install it in the DynOS and Touch Controls folder now?';
  }

  @override
  String get detailInstallNow => 'Install now';

  @override
  String get detailKeepDownload => 'Not now';

  @override
  String detailDownloadedNotInstalled(String name) {
    return 'Downloaded, but not installed: $name';
  }

  @override
  String detailInstallQueued(String name) {
    return 'Download and installation queued: $name';
  }

  @override
  String get detailContentUnavailable =>
      'This download is no longer available (404). The link may have been removed or changed.';

  @override
  String get detailFriendlyDownloadError =>
      'The download could not be completed. Check your connection and try again.';

  @override
  String get detailScreenshots => 'Screenshots';

  @override
  String get detailYoutubeVideos => 'YouTube Videos';

  @override
  String get detailDirectVideos => 'Videos';

  @override
  String get detailTags => 'Tags';

  @override
  String get detailAbout => 'About';

  @override
  String get detailDescriptionViewOriginal => 'View original';

  @override
  String get detailDescriptionViewTranslation => 'View translation';

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
  String get detailLatestVersion => 'LATEST VERSION';

  @override
  String get detailPreviousVersions => 'Previous versions';

  @override
  String detailViewPreviousVersions(int count) {
    return 'View $count previous versions';
  }

  @override
  String get detailNoDownloadFiles => 'No downloadable files are available.';

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
      'Downloads will be installed automatically in their configured game folder';

  @override
  String get settingsAutoInstallOff => 'You will be asked after each download';

  @override
  String get autoInstallPromptTitle => 'Install mods after downloading?';

  @override
  String get autoInstallPromptBody =>
      'Turn on auto-install to place downloaded mods in their configured game folder. You can change this later in Settings.';

  @override
  String get autoInstallPromptEnable => 'Turn on';

  @override
  String get autoInstallPromptDownloadOnly => 'Download only';

  @override
  String get settingsThemeMode => 'Theme mode';

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
  String get linksAppWebsite => 'Official SM64CDPY Website';

  @override
  String get linksAppWebsiteDesc => 'News, downloads, and project information';

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
      'SM64CDPY is independent software. Questions, technical issues, and requests concerning this app must be directed to the SM64CDPY developer, not to Nintendo, the SM64CoopDX team, or the listed mod authors.';

  @override
  String get disclaimerCouldNotOpenLink => 'Could not open the link';

  @override
  String get disclaimerSectionPersonalPurpose => 'About this app';

  @override
  String get disclaimerBodyPersonalPurpose =>
      'SM64CDPY is an independent Android catalog and manager for community-created SM64CoopDX mods. It helps users browse, download, organize, and install compatible content in folders selected by the user. The app does not distribute or install Super Mario 64, ROM files, SM64CoopDX, or Android builds of SM64CoopDX. It does not request, verify, or provide instructions for obtaining any game file.';

  @override
  String get disclaimerSectionNoAffiliation => 'No official affiliation';

  @override
  String get disclaimerBodyNoAffiliation =>
      'This project is not associated with, endorsed by, or approved by Nintendo, the SM64CoopDX team, or the listed mod authors. Product names and trademarks identify compatibility only. Mod titles, descriptions, images, files, and other credited material remain the property of their respective authors or rights holders.';

  @override
  String get disclaimerSectionDataSource => 'Data source';

  @override
  String get disclaimerBodyDataSource =>
      'The main catalog presents public community listings from Coop DX Mods (mods.sm64coopdx.com) while preserving the published author, title, dates, versions, and source. SM64CDPY provides a mobile interface and retrieves downloads from the source made available for each resource; catalog inclusion does not imply ownership or official endorsement by SM64CDPY.';

  @override
  String get disclaimerSectionExclusive =>
      'Curated sections (VIP · DynOS · Touch Controls)';

  @override
  String disclaimerBodyExclusive(Object version) {
    return 'In v$version, VIP Mods, DynOS packs, Touch Control layouts, OMM Rebirth, and Render96 may use independently curated sources. Whenever content was not created by the SM64CDPY developer, its credited creator retains authorship. These sections are separate from the main Coop DX Mods catalog and are not official Nintendo or SM64CoopDX services.';
  }

  @override
  String get disclaimerSectionLocalData => 'Accounts and local data';

  @override
  String get disclaimerBodyLocalData =>
      'SM64CDPY currently does not create user accounts. Favorites, installation history, selected folders, and app preferences are stored locally on the device. Removing the app or clearing its data may remove this information.';

  @override
  String get disclaimerSectionExternalServices => 'External services';

  @override
  String get disclaimerBodyExternalServices =>
      'Browsing, refreshing catalogs, opening links, and downloading content may connect to services such as Coop DX Mods, GitHub, Google Drive, Dropbox, or GameBanana. Those services operate under their own terms and privacy practices, which SM64CDPY does not control.';

  @override
  String get disclaimerSectionBugs => 'Support and content corrections';

  @override
  String get disclaimerBodyBugs =>
      'Contact the SM64CDPY developer if you find an app issue, incorrect attribution, outdated information, or content that should be corrected or removed. Please include the mod title and source when applicable. App-related requests should not be directed to Nintendo, the SM64CoopDX team, or mod authors.';

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
  String get settingsDynosFolder => 'DynOS and Touch Controls folder';

  @override
  String get settingsSelectDynosFolder => 'Select DynOS folder';

  @override
  String get settingsDynosFolderHint => 'Tap to change · Long-press to clear';

  @override
  String get settingsDynosFolderDesc =>
      'Choose where to install DynOS and Touch Controls packs';

  @override
  String get settingsDynosFolderSelected =>
      'DynOS and Touch Controls folder selected. Both content types will be installed here.';

  @override
  String get settingsClearDynosFolderTitle => 'CLEAR DYNOS FOLDER?';

  @override
  String get settingsClearDynosFolderBody =>
      'You will need to select the folder again before installing DynOS or Touch Control packs.';

  @override
  String get settingsDynosFolderCleared => 'DynOS folder selection cleared.';

  @override
  String get settingsLanguageMode => 'Language';

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
  String get overlayChooseFile => 'Choose a file';

  @override
  String overlayFileFallback(int number) {
    return 'File $number';
  }

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

  @override
  String get navRender96 => 'Render96';

  @override
  String get render96Title => 'RENDER96';

  @override
  String get render96SectionHeader => 'EXCLUSIVE COLLECTION';

  @override
  String get render96Empty => 'COMING SOON';

  @override
  String get render96EmptyHint => 'New Render96 content will appear here.';

  @override
  String get render96FailedToLoad => 'FAILED TO LOAD';

  @override
  String get navLibrary => 'Library';

  @override
  String get libraryTitle => 'LIBRARY';

  @override
  String get libraryInstalled => 'Installed';

  @override
  String get libraryUpdates => 'Updates';

  @override
  String get libraryRecent => 'Recent';

  @override
  String get libraryViewAll => 'View all';

  @override
  String get libraryRefresh => 'Refresh library';

  @override
  String get libraryAllSections => 'All sections';

  @override
  String get libraryAllDestinations => 'All folders';

  @override
  String get libraryModsDestination => 'Mods folder';

  @override
  String get libraryDynosDestination => 'DynOS folder';

  @override
  String get libraryPresent => 'Installed';

  @override
  String get libraryMissing => 'Missing';

  @override
  String get libraryPermissionRevoked => 'Permission required';

  @override
  String get libraryFolderNotSelected => 'Folder required';

  @override
  String get libraryNotVerified => 'Not verified';

  @override
  String get libraryOpenSource => 'OPEN CONTENT';

  @override
  String get libraryEmptyTitle => 'NO INSTALLATIONS YET';

  @override
  String get libraryEmptyBody => 'Mods installed by SM64CDPY will appear here.';

  @override
  String get libraryUpdatesEmptyTitle => 'NO KNOWN UPDATES';

  @override
  String get libraryUpdatesEmptyBody =>
      'Updates confirmed by the catalog will appear here. You can still check each content section.';

  @override
  String get libraryDiscoveryHeaderIdentified => 'Header identified';

  @override
  String get libraryDiscoveryProbable => 'Probable mod';

  @override
  String get libraryDiscoveryUnlinked => 'Unlinked Lua';

  @override
  String get libraryErrorTitle => 'LIBRARY UNAVAILABLE';

  @override
  String get libraryErrorBody =>
      'The installation history could not be read. Try again without changing your game files.';

  @override
  String get libraryPartialWarning =>
      'Some records could not be read. Valid installations are still shown.';

  @override
  String get libraryCatalogLoading => 'Checking the current catalog…';

  @override
  String get libraryCatalogError =>
      'The catalog could not be checked. Installed content is still available.';

  @override
  String libraryUpdateVersions(String installed, String available) {
    return '$installed → $available';
  }

  @override
  String get libraryEventInstall => 'Installed';

  @override
  String get libraryEventUpdate => 'Updated';

  @override
  String get libraryEventReinstall => 'Reinstalled';

  @override
  String get libraryEventReplaced => 'Replaced by a newer version';

  @override
  String get libraryForgetAction => 'FORGET INSTALLATION';

  @override
  String get libraryForgetTitle => 'FORGET THIS INSTALLATION?';

  @override
  String get libraryForgetBody =>
      'SM64CDPY will remove this item from the Library, but it will not delete any game files.';

  @override
  String get libraryForgetConfirm => 'FORGET';

  @override
  String get libraryRemoveHistoryAction => 'REMOVE FROM HISTORY';

  @override
  String get libraryRemoveHistoryTitle => 'REMOVE THIS EVENT?';

  @override
  String get libraryRemoveHistoryBody =>
      'Only this history entry will be removed. The current installation and game files will not change.';

  @override
  String get libraryRemoveHistoryConfirm => 'REMOVE';

  @override
  String get libraryMaintenanceError =>
      'The Library could not be updated. Try again.';

  @override
  String get detailOpenExternalFolder => 'OPEN SOURCE FOLDER';

  @override
  String get detailSourceUnavailable =>
      'This version has no downloadable file available right now.';

  @override
  String get detailViewDiscussion => 'VIEW COMMUNITY DISCUSSION';

  @override
  String get settingsInterfaceTheme => 'Interface theme';

  @override
  String get settingsInterfaceThemeDesc =>
      'Choose an included design. Applies to the app; the floating panel keeps its dark design.';

  @override
  String get themeMinimal => 'Minimal';

  @override
  String get themeRetroManga => 'Retro Manga';

  @override
  String get themeMinishCap => 'The Minish Cap';

  @override
  String get themeMarioKart64 => 'Mario Kart 64';

  @override
  String get themeMario64 => 'Mario 64';

  @override
  String get themeSm64Intro => 'SM64 Intro';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get themeModeSystem => 'Follow system';

  @override
  String get themeSaveFailed => 'Could not save the appearance. Try again.';

  @override
  String get themeSaving => 'Saving appearance';

  @override
  String get gameModsTitle => 'Game mods';

  @override
  String get gameModsSubtitle => 'Choose mods for the next game start';

  @override
  String get gameModsHint =>
      'Close the game before making changes. These switches configure Lua mods and DynOS/Touch Controls packs for the next start.';

  @override
  String get gameModsSelectHint =>
      'Select the game’s user folder containing sm64config.txt and mods.';

  @override
  String get gameModsConfirm =>
      'Close the game first. Apply this selection for its next start?';

  @override
  String get gameModsCancel => 'Cancel';

  @override
  String get gameModsApply => 'Apply';

  @override
  String get gameModsSelect => 'Select user folder';

  @override
  String get gameModsDisconnect => 'Disconnect';

  @override
  String get gameModsConflict =>
      'The configuration changed or another enabled mod is incompatible. Refresh and try again.';

  @override
  String get gameModsBlocked =>
      'Cannot safely enable this mod. Check its structure and metadata, or disable an incompatible mod.';

  @override
  String get gameModsMismatch =>
      'This user folder does not match your selected mods folder. Choose the same game installation.';

  @override
  String get gameModsWriteError =>
      'The write could not be confirmed. Close the game and restore the previous configuration if necessary.';

  @override
  String get gameModsFormat =>
      'The configuration or folder exceeds the supported limits or has an unsupported format. No change was applied.';

  @override
  String get gameModsAccess =>
      'Configuration unavailable. Check that user contains sm64config.txt and mods, and select the folder again with read/write access.';

  @override
  String get gameModsRestore => 'Restore previous configuration';

  @override
  String get gameModsRestoreConfirm =>
      'With the game closed, replace the configuration with the private backup from before the last edit? This also restores its other settings.';

  @override
  String get gameModsInstalling =>
      'Wait for downloads and installations to finish before changing game mods.';

  @override
  String get gameModsEmpty =>
      'No compatible Lua mods were found in the game folders.';

  @override
  String get gameModsEnabled => 'Enabled for next start';

  @override
  String get gameModsDisabled => 'Disabled for next start';

  @override
  String get gameModsMore => 'Show more';

  @override
  String get gameModsSize =>
      'This mod reaches the game’s 35 MiB size limit and cannot be enabled.';

  @override
  String get gameModsSaved =>
      'Selection saved and verified for the next game start.';

  @override
  String get gameModsManage => 'Manage game folder';

  @override
  String gameModsCount(int enabled, int total) {
    return '$enabled of $total enabled';
  }

  @override
  String get gameModsSearch => 'Search mods, authors, categories…';

  @override
  String get gameModsAll => 'All';

  @override
  String get gameModsEnabledFilter => 'Enabled';

  @override
  String get gameModsDisabledFilter => 'Disabled';

  @override
  String get gameModsNoResults => 'No mods match this search or filter.';

  @override
  String get gameModsClearSearch => 'Clear search';

  @override
  String get gameModsDetails => 'Mod details';

  @override
  String get gameModsCloseDetails => 'Close';

  @override
  String get marioRomTitle => 'Original game resources';

  @override
  String get marioRomBuiltIn => 'ROM not selected';

  @override
  String get marioRomReady => 'Original interface ready';

  @override
  String get marioRomDescription =>
      'Mario themes use the ROM in your connected user folder. Images and fonts are prepared privately once and reused later. No separate ROM selection is needed.';

  @override
  String get marioRomImport => 'Prepare from game folder';

  @override
  String get marioRomPreparing => 'Preparing game resources…';

  @override
  String get marioRomCancel => 'Cancel import';

  @override
  String get marioRomRemove => 'Use built-in design';

  @override
  String get marioRomUnsupported =>
      'This ROM is not supported. Select an unmodified US .z64 ROM. Your previous design is still available.';

  @override
  String get marioRomFailed =>
      'Could not read or save the resources. Select the file again and check available storage. Your previous design is still available.';

  @override
  String get marioRomSuccess => 'Original game resources are ready.';

  @override
  String get marioRomUpgrade =>
      'Select the ROM again to upgrade the original interface';

  @override
  String get gameFolderTitle => 'Connect SM64CoopDX';

  @override
  String get gameFolderSummary =>
      'Choose the main game folder once to find mods and DynOS packs both inside and outside user, plus the ROM for Mario themes.';

  @override
  String get gameFolderGuide =>
      'Choose the main com.maniscat2.sm64coopdx folder, the one containing user. We will check mods and dynos/packs both here and inside user. Configuration and ROM stay in user; new installations also go inside user. Select the main folder, not user or an individual file.';

  @override
  String get gameFolderChoose => 'Choose game folder';

  @override
  String get gameFolderLater => 'Not now';

  @override
  String get gameFolderConnected => 'Game connected';

  @override
  String get gameFolderResolved =>
      'Library: mods, user/mods, dynos/packs and user/dynos/packs. New installations: user/mods and user/dynos/packs.';

  @override
  String get gameFolderConfigReady => 'Game mod settings found.';

  @override
  String get gameFolderConfigMissing =>
      'Open the game once to create its mod settings. Downloads and themes remain available.';

  @override
  String get gameFolderRomFound =>
      'Game ROM found. Mario themes can prepare their resources when selected.';

  @override
  String get gameFolderRomMissing =>
      'No compatible ROM was found in user. Open SM64CoopDX and set up its ROM, then try again.';

  @override
  String get gameFolderChange => 'Change game folder';

  @override
  String get gameFolderInvalid =>
      'Choose the main game folder containing user, normally com.maniscat2.sm64coopdx. Open the game once if its user folder is not ready.';

  @override
  String get gameFolderAccessLost =>
      'The game folder is unavailable. Choose it again to reconnect.';

  @override
  String get gameFolderDisconnect => 'Disconnect game';

  @override
  String get gameFolderDisconnectBody =>
      'Stop using this folder for mods, DynOS and ROM detection. Your game files, installed mods and prepared theme resources will stay on the device.';

  @override
  String get gameFolderPrepareTitle => 'Prepare Mario theme';

  @override
  String get gameFolderPrepareBody =>
      'We will read the ROM in your connected game folder and prepare the theme’s images and fonts. This is done once; the ROM and game configuration stay unchanged.';

  @override
  String get gameFolderPrepare => 'Prepare theme';

  @override
  String get gameFolderBusy =>
      'Wait for downloads and installations to finish before changing the game folder.';

  @override
  String get gameModsLuaType => 'Lua mods';

  @override
  String get gameModsDynosType => 'DynOS / Touch Controls';

  @override
  String get gameFolderUpgrade =>
      'Access is limited to user. Choose the main game folder to include mods and DynOS packs outside user too.';

  @override
  String get gameDynosEmpty =>
      'No DynOS / Touch Controls pack folders were found in the game folders.';

  @override
  String get gameDynosSearch => 'Search DynOS / Touch Controls packs…';

  @override
  String get navPlayer => 'Player';

  @override
  String get playerTitle => 'PLAYER';

  @override
  String get playerCharacter => 'CHARACTER';

  @override
  String get player3DLoading => 'Building your character from the game…';

  @override
  String get player3DUnavailable =>
      'The 3D preview is unavailable. Check that SM64CoopDX and a supported US ROM are connected.';

  @override
  String get playerName => 'Player name';

  @override
  String get playerNameHint => 'Name shown in SM64CoopDX';

  @override
  String get playerCloseGameHint =>
      'Close SM64CoopDX before applying. Changes are used on the next start.';

  @override
  String get playerPresets => 'PALETTES';

  @override
  String get playerParts => 'CHARACTER COLORS';

  @override
  String get playerUnsavedTitle => 'Discard changes?';

  @override
  String get playerUnsavedBody =>
      'Your player colors or name have not been applied to the game.';

  @override
  String get playerKeepEditing => 'Keep editing';

  @override
  String get playerDiscard => 'Discard';

  @override
  String get playerDeletePreset => 'Delete palette?';

  @override
  String playerDeletePresetBody(String name) {
    return 'Delete your palette “$name”?';
  }

  @override
  String get playerCancel => 'Cancel';

  @override
  String get playerDelete => 'Delete';

  @override
  String get playerConflict =>
      'The game configuration changed. Reload it before applying your profile.';

  @override
  String get playerInvalid =>
      'Enter a valid name and colors. Names cannot contain spaces and can use up to 63 UTF-8 bytes.';

  @override
  String get playerPresetExists => 'A palette with this name already exists.';

  @override
  String get playerAccessError =>
      'The player configuration is unavailable. Check the connected game folder and its permission.';

  @override
  String get playerSavePreset => 'Save palette';

  @override
  String get playerPresetName => 'Palette name';

  @override
  String get playerSave => 'Save';

  @override
  String playerOverwritePreset(String name) {
    return 'Replace your palette “$name”?';
  }

  @override
  String get playerOverwrite => 'Replace';

  @override
  String get playerPresetSaved => 'Palette saved for SM64CoopDX.';

  @override
  String get playerApplied =>
      'Player profile saved and verified for the next game start.';

  @override
  String get playerConnectGame =>
      'Connect the main SM64CoopDX folder to edit the player.';

  @override
  String get playerMissingConfig =>
      'Open SM64CoopDX once to create user/sm64config.txt.';

  @override
  String get playerRetry => 'Try again';

  @override
  String get playerHex => 'Hex color';

  @override
  String get playerRed => 'R';

  @override
  String get playerGreen => 'G';

  @override
  String get playerBlue => 'B';

  @override
  String get playerReset => 'Reset';

  @override
  String get playerApply => 'Apply to game';

  @override
  String get playerPants => 'Overalls';

  @override
  String get playerShirt => 'Shirt';

  @override
  String get playerGloves => 'Gloves';

  @override
  String get playerShoes => 'Shoes';

  @override
  String get playerHair => 'Hair';

  @override
  String get playerSkin => 'Skin';

  @override
  String get playerCap => 'Cap';

  @override
  String get playerEmblem => 'Emblem';

  @override
  String get playerRestore => 'Restore previous configuration';

  @override
  String get playerRestoreBody =>
      'With SM64CoopDX closed, restore the private backup from before the last mod or player edit? This restores the whole configuration.';

  @override
  String get playerRestored => 'Previous game configuration restored.';

  @override
  String get retroAccentTitle => 'Interface accent';

  @override
  String get retroAccentDescription =>
      'Choose the highlight color for Retro Manga or Mario Kart 64. MK64 also coordinates its background, panels and racing grid with it.';

  @override
  String get retroAccentCyan => 'Cyan';

  @override
  String get retroAccentBlue => 'Blue';

  @override
  String get retroAccentViolet => 'Violet';

  @override
  String get retroAccentPink => 'Pink';

  @override
  String get retroAccentCoral => 'Coral';

  @override
  String get retroAccentAmber => 'Amber';

  @override
  String get retroAccentGreen => 'Green';

  @override
  String get retroAccentLime => 'Lime';

  @override
  String get gameToolTitle => 'GameTool';

  @override
  String get saveFileTitle => 'Save File';

  @override
  String get saveFileHint => 'Choose a file · original game';

  @override
  String get saveFileConfirm =>
      'Close SM64CoopDX first. Changes apply on the next launch. Copy and erase affect both normal and alternative progress for the selected slot. Restore replaces all four slots. A full backup is saved before writing.';

  @override
  String get saveFileDone => 'Saved';

  @override
  String get saveFileMissing =>
      'Connect the game folder and start the game once to create its save file.';

  @override
  String get saveFileError =>
      'Could not verify or save the file. Refresh and try again; recovery copies are kept in Backups.';

  @override
  String get saveFilePrimary => 'Normal';

  @override
  String get saveFileAlternate => 'Alternative';

  @override
  String get saveFileEmpty => 'Empty';

  @override
  String get saveFileUnsigned => 'Unsigned or damaged copy';

  @override
  String get saveFileCopy => 'Copy';

  @override
  String get saveFileProgress => 'Progress';

  @override
  String get saveFileBackup => 'Create backup';

  @override
  String get saveFileBackups => 'Backups';

  @override
  String get saveFileCannon => 'Cannon';

  @override
  String get saveFileCoins => 'Coins';

  @override
  String get saveFileCastle => 'Castle stars';

  @override
  String get saveFileUnlocks => 'Unlocks';

  @override
  String get saveFileWing => 'Wing Cap';

  @override
  String get saveFileMetal => 'Metal Cap';

  @override
  String get saveFileVanish => 'Vanish Cap';

  @override
  String get saveFileKey1 => 'First key';

  @override
  String get saveFileKey2 => 'Second key';

  @override
  String get saveFileBasement => 'Basement door';

  @override
  String get saveFileUpstairs => 'Upstairs door';

  @override
  String get saveFileMoat => 'Drain moat';

  @override
  String get saveFileComplete => 'Complete progress: 120 stars';

  @override
  String get saveFileClearStars => 'Clear stars';

  @override
  String get saveFileCourseNames =>
      'Bob-omb Battlefield|Whomp\'s Fortress|Jolly Roger Bay|Cool, Cool Mountain|Big Boo\'s Haunt|Hazy Maze Cave|Lethal Lava Land|Shifting Sand Land|Dire, Dire Docks|Snowman\'s Land|Wet-Dry World|Tall, Tall Mountain|Tiny-Huge Island|Tick Tock Clock|Rainbow Ride|Bowser in the Dark World|Bowser in the Fire Sea|Bowser in the Sky|The Princess\'s Secret Slide|Cavern of the Metal Cap|Tower of the Wing Cap|Vanish Cap Under the Moat|Wing Mario Over the Rainbow|The Secret Aquarium';

  @override
  String get saveFileCopies => 'Game progress';

  @override
  String get saveFileCopiesHint =>
      'Normal is your usual game progress. Some mods use Alternative for special modes, such as hard mode. It is not a backup. Selecting it here does not change which progress the game uses.';

  @override
  String get saveFileOpenSlot => 'Tap to edit';

  @override
  String get saveFileActions => 'Slot actions';

  @override
  String get saveFileDraft => 'Preview · saved only after Apply';

  @override
  String get drawerResources => 'Resources';

  @override
  String get fastInstallTitle => 'Enable faster installation';

  @override
  String get fastInstallDescription =>
      'Optional: allow all-files access in Android to speed up installation in compatible game folders. Without it, installation still works normally.';

  @override
  String get fastInstallAccessError =>
      'Could not open permission settings. You can keep installing normally.';

  @override
  String get playGuideTitle => 'How to Play';

  @override
  String get playGuideIntro =>
      'Your first adventure, one step at a time. Start with the game, then bring your mods here.';

  @override
  String get playGuideNext => 'Next step';

  @override
  String get playGuideBack => 'Previous step';

  @override
  String get playGuideOpenDownload => 'Open Android downloads';

  @override
  String get playGuideRepository => 'Android port repository';

  @override
  String get playGuideConnect => 'Connect game folder';

  @override
  String get playGuideLibrary => 'Open Library';

  @override
  String get playGuideLaunch => 'Open the game';

  @override
  String get playGuideMissingTitle => 'Let’s prepare your game';

  @override
  String get playGuideMissingBody =>
      'SM64CoopDX Android is not installed. Follow the guide to install it, prepare your ROM and connect your mods.';

  @override
  String get playGuideRead => 'See getting-started guide';

  @override
  String get playGuideLater => 'Not now';

  @override
  String get playGuideLinkError =>
      'The page could not open. Check your connection and try again.';

  @override
  String get playGuideLaunchError =>
      'The game is installed, but Android could not open it. Try its icon on your home screen.';

  @override
  String get playGuideInstalled => 'Game installed';

  @override
  String get playGuideNotInstalled => 'Game not detected yet';

  @override
  String get playGuideConnected => 'Game folder connected';

  @override
  String get playGuideNotConnected => 'Game folder not connected yet';

  @override
  String get playGuideReady =>
      'Your adventure awaits! You can revisit any step whenever you need it.';

  @override
  String get playGuideStep1Title => 'Get the game';

  @override
  String get playGuideStep2Title => 'Prepare your own ROM';

  @override
  String get playGuideConvertTitle => 'Convert my ROM (.n64 / .v64)';

  @override
  String get playGuideStep3Title => 'Give the ROM to the game';

  @override
  String get playGuideStep4Title => 'Connect the manager';

  @override
  String get playGuideStep5Title => 'Add your first mod';

  @override
  String get playGuidePathsTitle => 'Where does everything go?';

  @override
  String get playGuideStep6Title => 'Play and find help';

  @override
  String get playGuideMap => 'Your adventure map';

  @override
  String get playGuideSwipe => 'Swipe left or right to change chapter';

  @override
  String get playGuideChapter => 'CHAPTER';

  @override
  String get playGuideTip => 'Remember';

  @override
  String get playGuideOverview => 'All steps';

  @override
  String get playGuideS1Card1 =>
      'SM64CDPY manages mods. SM64CoopDX Android is the separate app that runs the game.';

  @override
  String get playGuideS1Card2 =>
      'Tap Open Android downloads. Your browser will open the Android port’s GitHub page.';

  @override
  String get playGuideS1Card3 =>
      'Find the release and expand Assets if needed. Download the file ending in .apk, not Source code. Follow the release’s device requirements if it offers different builds.';

  @override
  String get playGuideS1Card4 =>
      'Open the downloaded APK and tap Install. If Android asks, allow this browser or file app to install this APK, then return to installation.';

  @override
  String get playGuideS1Card5 =>
      'Open SM64CoopDX once. Follow its storage instructions so it can create its game folder.';

  @override
  String get playGuideS1Card6 =>
      'If you are unsure about Android’s prompts, ask someone you trust to help.';

  @override
  String get playGuideS2Card1 =>
      'The ROM is a copy of the original Super Mario 64 cartridge. The APK alone does not include the game’s original pictures and sounds.';

  @override
  String get playGuideS2Card2 =>
      'Use your own unmodified USA copy in .z64 format. This guide does not supply ROMs. A ZIP is a package: extract it first to see the file inside.';

  @override
  String get playGuideS2Card3 => 'Already .z64? Go to the next step.';

  @override
  String get playGuideS2Card4 =>
      'Ends in .n64 or .v64? Open “Convert my ROM” below.';

  @override
  String get playGuideS2Card5 =>
      'A different region or modified game? Changing its name or format will not make it a USA original.';

  @override
  String get playGuideS3Card1 => 'Open SM64CoopDX Android.';

  @override
  String get playGuideS3Card2 =>
      'If it asks you to choose a ROM, select your USA .z64 file, usually in Downloads. Let the game finish preparing it.';

  @override
  String get playGuideS3Card3 =>
      'If your version has no selector, close the game. In your file app, copy the .z64 into Internal storage → com.maniscat2.sm64coopdx → user. Open the game again.';

  @override
  String get playGuideS3Card4 =>
      'Wait until you can reach the game menu. If the ROM is rejected, check the region, original unmodified contents and real .z64 conversion.';

  @override
  String get playGuideS3Card5 =>
      'The game keeps its accepted USA ROM as user/baserom.us.z64. The folder can depend on the game’s storage permissions; follow the location the game shows you.';

  @override
  String get playGuideS4Card1 =>
      'Return to SM64CDPY and tap Connect game folder. We explain what to choose before opening Android’s folder window.';

  @override
  String get playGuideS4Card2 =>
      'Open Internal storage → com.maniscat2.sm64coopdx.';

  @override
  String get playGuideS4Card3 =>
      'Select that main folder, the one containing user, and tap Use this folder / Allow. Do not select Downloads, user alone or the ROM file.';

  @override
  String get playGuideS4Card4 =>
      'One selection connects mods, DynOS, game settings and ROM detection. If user is missing, open and prepare the game first. If Android blocks access, check the game’s storage setup; choosing an unrelated empty folder will not fix it.';

  @override
  String get playGuideS4Card5 =>
      'Already connected? Continue. You do not need to select the same folders for each mod.';

  @override
  String get playGuideS5Card1 =>
      'Close the game before installing or changing mods.';

  @override
  String get playGuideS5Card2 =>
      'Open Catalog and choose one mod. Read its compatibility notes.';

  @override
  String get playGuideS5Card3 =>
      'Download it. With automatic installation enabled, wait for Installed: a finished download alone is not a finished installation. If automatic installation is off, follow the manual-install prompt or enable it in Settings.';

  @override
  String get playGuideS5Card4 =>
      'Open GameTool → Library. Game Mods holds Lua mods. DynOS / Touch Controls holds model, texture and control packs. Turn on the item you want.';

  @override
  String get playGuideS5Card5 =>
      'Open the game again to load your changes. Some packs need their own in-game settings; follow the author’s instructions.';

  @override
  String get playGuideS6Card1 =>
      'Tap Open the game below. Choose a save slot in the game and enjoy your adventure.';

  @override
  String get playGuideS6Card2 =>
      'Game not opening? First open it from Android’s home screen.';

  @override
  String get playGuideS6Card3 =>
      'ROM not accepted? Recheck the USA original and .z64 format in step 2.';

  @override
  String get playGuideS6Card4 =>
      'Mod missing? Check that installation finished, enable it in Library and restart the game. Check whether it needs another mod.';

  @override
  String get playGuideS6Card5 =>
      'Folder access lost? Reconnect the main game folder in step 4.';

  @override
  String get playGuideS6Card6 =>
      'Try one mod at a time. If something breaks, turn off that mod, then reopen the game. Keep a backup before deleting game files.';

  @override
  String get playGuideConvertCard1 => 'Keep your original file as a backup.';

  @override
  String get playGuideConvertCard2 => 'Open the ROM converter in your browser.';

  @override
  String get playGuideConvertCard3 => 'Choose your own .n64 or .v64 file.';

  @override
  String get playGuideConvertCard4 =>
      'Select .z64 as the output format and save the converted file, usually in Downloads.';

  @override
  String get playGuideConvertCard5 =>
      'Return here and continue with that .z64 file.';

  @override
  String get playGuideConvertCard6 =>
      'Conversion rearranges the file’s bytes. Renaming .n64 to .z64 does not convert it. This is an external tool; if it is unavailable, use another N64 byte-order converter with .z64 output.';

  @override
  String get playGuidePathsCard1 =>
      'Inside Internal storage → com.maniscat2.sm64coopdx:';

  @override
  String get playGuidePathsCard2 =>
      'user/mods → new Lua mod installations. A mod can be a .lua file or a folder with main.lua.';

  @override
  String get playGuidePathsCard3 =>
      'user/dynos/packs → new DynOS and Touch Controls packs. Touch Controls shares this destination.';

  @override
  String get playGuidePathsCard4 =>
      'user/baserom.us.z64 → the original USA ROM accepted by the game.';

  @override
  String get playGuidePathsCard5 =>
      'user/sm64config.txt → game settings and enabled items. Let the app manage it rather than editing it by hand.';

  @override
  String get playGuidePathsCard6 =>
      'The game also reads mods and dynos/packs outside user. This manager shows those too when the main folder is connected. For duplicate names, Lua uses user/mods first; DynOS uses the outer dynos/packs first. Avoid keeping two copies with the same name.';

  @override
  String get playGuideS1Title1 => 'Two apps, two jobs';

  @override
  String get playGuideS1Title2 => 'Open the Android page';

  @override
  String get playGuideS1Title3 => 'Choose the APK';

  @override
  String get playGuideS1Title4 => 'Install the game';

  @override
  String get playGuideS1Title5 => 'Open it once';

  @override
  String get playGuideS1Title6 => 'A helping hand';

  @override
  String get playGuideS2Title1 => 'What is a ROM?';

  @override
  String get playGuideS2Title2 => 'The copy you need';

  @override
  String get playGuideS2Title3 => 'Already .z64';

  @override
  String get playGuideS2Title4 => 'I have .n64 or .v64';

  @override
  String get playGuideS2Title5 => 'Region matters';

  @override
  String get playGuideS3Title1 => 'Open SM64CoopDX';

  @override
  String get playGuideS3Title2 => 'Choose your ROM';

  @override
  String get playGuideS3Title3 => 'If there is no selector';

  @override
  String get playGuideS3Title4 => 'Reach the game menu';

  @override
  String get playGuideS3Title5 => 'Your ROM’s home';

  @override
  String get playGuideS4Title1 => 'Return to this manager';

  @override
  String get playGuideS4Title2 => 'Find the main folder';

  @override
  String get playGuideS4Title3 => 'Allow that folder';

  @override
  String get playGuideS4Title4 => 'One connection';

  @override
  String get playGuideS4Title5 => 'Already connected?';

  @override
  String get playGuideS5Title1 => 'Close the game first';

  @override
  String get playGuideS5Title2 => 'Choose one mod';

  @override
  String get playGuideS5Title3 => 'Wait for installation';

  @override
  String get playGuideS5Title4 => 'Turn it on in Library';

  @override
  String get playGuideS5Title5 => 'Restart and try it';

  @override
  String get playGuideS6Title1 => 'Start your adventure';

  @override
  String get playGuideS6Title2 => 'The game will not open';

  @override
  String get playGuideS6Title3 => 'The ROM is rejected';

  @override
  String get playGuideS6Title4 => 'The mod is missing';

  @override
  String get playGuideS6Title5 => 'Folder permission lost';

  @override
  String get playGuideS6Title6 => 'Try one at a time';

  @override
  String get romPrepareNav => 'Prepare ROM';

  @override
  String get romPrepareTitle => 'Prepare your ROM';

  @override
  String get romPrepareDescription =>
      'Choose your own Super Mario 64 file. The app creates and verifies a compatible .z64 copy without changing the original.';

  @override
  String get romPreparePrivacy =>
      'SM64CDPY does not include, download or share ROMs. The selected file is processed locally on your device.';

  @override
  String get romPrepareChoose => 'Choose ROM';

  @override
  String get romPrepareChooseAnother => 'Choose another file';

  @override
  String get romPrepareAnother => 'Prepare another ROM';

  @override
  String get romPrepareSave => 'Save .z64 copy';

  @override
  String get romPrepareContinue => 'Continue with the guide';

  @override
  String get romPrepareCancel => 'Cancel';

  @override
  String get romPrepareIdle => 'Ready to check your file';

  @override
  String get romPreparePicking => 'Choose your file in Android';

  @override
  String get romPrepareInspecting => 'Checking the selected file';

  @override
  String get romPrepareConverting => 'Preparing a compatible copy';

  @override
  String get romPrepareValidating => 'Verifying the prepared ROM';

  @override
  String get romPrepareReady => 'Compatible ROM ready';

  @override
  String get romPrepareAlreadyCompatible =>
      'Your ROM was already in the correct format';

  @override
  String get romPrepareChoosingDestination => 'Choose where to save the copy';

  @override
  String get romPrepareExporting => 'Saving your copy';

  @override
  String get romPrepareVerifyingExport => 'Verifying the saved copy';

  @override
  String get romPrepareSaved => 'Copy saved and verified';

  @override
  String get romPrepareCancelling => 'Stopping safely';

  @override
  String get romPrepareCancelled => 'Preparation cancelled';

  @override
  String get romPrepareFailed => 'The ROM could not be prepared';

  @override
  String romPrepareDetected(String format) {
    return 'Detected format: $format';
  }

  @override
  String romPrepareSavedAs(String name) {
    return 'Saved as $name';
  }

  @override
  String get romPrepareErrorUnrecognized =>
      'This file is not a recognized N64 ROM format.';

  @override
  String get romPrepareErrorSize =>
      'The original Super Mario 64 ROM must be exactly 8 MiB.';

  @override
  String get romPrepareErrorIncompatible =>
      'You need an unmodified original Super Mario 64 USA ROM.';

  @override
  String get romPrepareErrorPermission =>
      'Android no longer allows access to that file. Choose it again.';

  @override
  String get romPrepareErrorStorage =>
      'There is not enough available storage, or the file could not be read.';

  @override
  String get romPrepareErrorExport =>
      'The saved copy could not be verified. Choose another destination and try again.';

  @override
  String get romPrepareErrorBusy => 'Another ROM operation is already active.';

  @override
  String get romPrepareErrorUnexpected =>
      'Something unexpected happened. Your original file was not changed.';

  @override
  String get mangaNavLibrary => 'Library';

  @override
  String get mangaNavExplore => 'Explore';

  @override
  String get mangaMenuLabel => 'Menu';

  @override
  String get mangaMenuOpen => 'Open menu';

  @override
  String get mangaMenuClose => 'Close menu';

  @override
  String get mangaNavTools => 'Tools';

  @override
  String get mangaNavMore => 'More';

  @override
  String get mangaNavPlay => 'Play';

  @override
  String get mangaNavHint => 'Swipe to browse. Tap to open.';

  @override
  String get mangaNavError => 'Could not complete this action. Try again.';

  @override
  String get mangaMenuSoundsTitle => 'Menu sounds';

  @override
  String get mangaMenuSoundsDescription =>
      'Sound effects when opening, selecting and swiping the menu.';

  @override
  String get appEffectsVolume => 'Effects volume';

  @override
  String get appEffectsVolumeDescription =>
      'Adjusts only this app’s effects. Your device’s media volume remains the limit.';

  @override
  String get ambientMusicTitle => 'Ambient music';

  @override
  String get ambientMusicDescription =>
      'A soft background track while using Retro Manga. Pauses when you leave the app.';

  @override
  String get ambientMusicVolume => 'Music volume';

  @override
  String get mangaNavAudio => 'Audio';

  @override
  String get themeMangaDeluxe => 'Manga Deluxe';

  @override
  String get deluxeWelcome => 'Welcome to CoopDX';

  @override
  String get deluxeWelcomeBody =>
      'Your Android mod companion: prepare the game, discover mods and find the CoopDX community.';

  @override
  String get deluxeSpotlight => 'From the CoopDX showcase';

  @override
  String get deluxeDncBody =>
      'Changing skies, lighting and a full day/night cycle. See the mod in motion before exploring its details.';

  @override
  String get deluxeViewMod => 'View mod';

  @override
  String get deluxeWatchDemo => 'Watch demo';

  @override
  String get deluxeDemoHint =>
      'Opens the official video outside the app. Requires internet.';

  @override
  String get deluxeLinkError =>
      'Could not open the link. Check your connection and try again.';

  @override
  String get deluxeHelpTitle => 'Quick help';

  @override
  String get deluxeFaqRom => 'Which ROM do I need?';

  @override
  String get deluxeFaqRomAnswer =>
      'Use your own verified USA dump in .z64 format. ROM Preparation can convert a copy without changing the original.';

  @override
  String get deluxeFaqFolders => 'Which folder should I select?';

  @override
  String get deluxeFaqFoldersAnswer =>
      'Use Connect game folder. The guide explains the location to select and the manager discovers supported mods and packs.';

  @override
  String get deluxeFaqPacks => 'Game Mods or DynOS?';

  @override
  String get deluxeFaqPacksAnswer =>
      'Lua mods change game behavior. DynOS packs provide models, textures and Touch Controls. Use their separate Library sections to manage them.';

  @override
  String get deluxeOpenGuide => 'Open';

  @override
  String get deluxeCommunity => 'Community and links';

  @override
  String get deluxeGameNews => 'Android game updates';

  @override
  String get deluxeMotion => 'Moving background';

  @override
  String get deluxeMotionHint =>
      'Optional scrolling hats and pattern. Leave off to save battery.';

  @override
  String get deluxeReducedMotion =>
      'Motion is paused by your accessibility settings.';

  @override
  String get deluxeReset => 'Reset Deluxe appearance and audio';

  @override
  String get deluxeResetDone => 'Deluxe appearance and audio restored.';

  @override
  String get deluxeMusicDescription =>
      'A soft background track for Manga Deluxe. Pauses when you leave the app.';

  @override
  String get deluxeAccentDescription =>
      'Choose the ink accents and background pattern color for Manga Deluxe.';

  @override
  String get deluxeResetHint =>
      'Restores the shared accent and audio levels. Your folders, mods and save files stay unchanged.';

  @override
  String get deluxeWelcomeCompact =>
      'New here? Set up the game with our quick guide.';

  @override
  String get deluxeSkip => 'Skip';

  @override
  String get deluxeSkipHint =>
      'Hide this introduction permanently. The guide stays in the menu.';

  @override
  String get coopTitle => 'Play with friends';

  @override
  String get coopNav => 'Play';

  @override
  String get coopIntro =>
      'Create a private room or join your friend\'s code. The helper connects SM64CoopDX through the internet while the game uses its local Direct Connection.';

  @override
  String get coopPrivacy =>
      'The room code is a shared secret. Signalling uses the compatible Cloudflare service; game traffic connects directly when possible and uses TURN only when needed.';

  @override
  String get coopConsentTitle => 'Network privacy';

  @override
  String get coopConsentIntro =>
      'Before creating or joining a room, review how the connection works.';

  @override
  String get coopConsentEncrypted =>
      'The room code derives the key that encrypts WebRTC signalling. Share it only with people you trust.';

  @override
  String get coopConsentIp =>
      'Your internet address may be visible to your invited friend and to the Google and Cloudflare address-discovery services.';

  @override
  String get coopConsentThirdParty =>
      'Signalling and relay access use a compatible third-party Cloudflare service. Availability and retention are controlled by that service.';

  @override
  String get coopConsentAccept => 'I understand and continue';

  @override
  String get coopConsentCancel => 'Not now';

  @override
  String get coopConsentReview => 'Review network privacy';

  @override
  String get coopConsentSaveError =>
      'Your choice could not be saved. No network session was started.';

  @override
  String get coopCreate => 'Create room';

  @override
  String get coopJoin => 'Join room';

  @override
  String get coopCode => 'Friend code';

  @override
  String get coopCodeHint => 'ABCD-1234';

  @override
  String get coopRecent => 'Recent codes';

  @override
  String get coopClearRecent => 'Clear';

  @override
  String get coopWaiting => 'Waiting for friends';

  @override
  String get coopConnecting => 'Looking for your friend';

  @override
  String get coopConnected => 'Session connected';

  @override
  String get coopReconnecting => 'Reconnecting';

  @override
  String get coopPreparing => 'Preparing secure room';

  @override
  String get coopStop => 'Stop session';

  @override
  String get coopOpenGame => 'Open SM64CoopDX';

  @override
  String get coopGameMissing => 'SM64CoopDX is not installed on this device.';

  @override
  String get coopGameReady => 'SM64CoopDX detected';

  @override
  String get coopHostInstruction =>
      'Open Multiplayer > Direct Connection > Host in the game. Friends join using the code shown here.';

  @override
  String coopJoinInstruction(int port) {
    return 'Open Multiplayer > Direct Connection in the game and connect to 127.0.0.1 using port $port.';
  }

  @override
  String get coopCopy => 'Copy code';

  @override
  String get coopCopied => 'Code copied';

  @override
  String get coopShare => 'Share invite';

  @override
  String get coopShareSubject => 'SM64CoopDX game invite';

  @override
  String coopShareMessage(String code) {
    return 'Join my SM64CoopDX game!\n\nFriend code: $code\n\nOpen SM64CDPY, go to Play, choose Join room and enter this code. Share it only with people you trust.';
  }

  @override
  String get coopShareError =>
      'The invite could not be shared. Try copying the code instead.';

  @override
  String coopPeers(int count) {
    return 'Friends: $count';
  }

  @override
  String get coopDirect => 'Direct';

  @override
  String get coopRelay => 'Relay';

  @override
  String get coopNoCode => 'Enter a valid eight-character code.';

  @override
  String get coopNetworkError =>
      'The session could not start. Check your connection and try again.';

  @override
  String get coopBatteryTitle => 'Background connection';

  @override
  String get coopBatteryDescription =>
      'Optional: allow unrestricted battery use so Android is less likely to pause a session while the game is open.';

  @override
  String get coopBatteryAllowed =>
      'Unrestricted battery use is allowed. Android can keep the session active more reliably.';

  @override
  String get coopBatteryAllow => 'Allow in Android';

  @override
  String get coopBatteryManage => 'Manage in Android';

  @override
  String get coopBatteryOpenError =>
      'Android battery settings could not be opened on this device.';

  @override
  String get coopDiagnosticsTitle => 'Connection diagnostics';

  @override
  String coopDiagnosticsSignal(int count) {
    return 'Signalling connections: $count';
  }

  @override
  String coopDiagnosticsPackets(int toGame, int toPage) {
    return 'Game packets: $toGame received · $toPage sent';
  }

  @override
  String coopDiagnosticsDelay(int average, int max) {
    return 'Bridge delay: $average ms average · $max ms maximum';
  }

  @override
  String get homeCardSoundsTitle => 'Home card sounds';

  @override
  String get homeCardSoundsDescription =>
      'Play a sound when changing Featured or Browse cards. Separate from menu effects and music.';

  @override
  String get homeCardSoundsVolume => 'Card volume';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageSaveFailed => 'Could not save the language. Try again.';

  @override
  String get sharedCopyDetails => 'Copy details';

  @override
  String get sharedCopied => 'Copied to clipboard';

  @override
  String sharedAuthor(String author) {
    return 'Author: $author';
  }

  @override
  String get sharedUntitled => 'Untitled';

  @override
  String get render96Required => 'REQUIRED';

  @override
  String get render96Optional => 'OPTIONAL';

  @override
  String get render96Skinpack => 'MODEL PACK';

  @override
  String get settingsExportFailed =>
      'Could not export your favorites. Try again.';

  @override
  String get settingsImportFailed =>
      'Could not import this file. Choose a favorites file exported by SM64CDPY.';

  @override
  String get settingsDatabaseFailed =>
      'Could not refresh the catalog. Check your connection and try again.';

  @override
  String get updateActionFailed =>
      'Could not complete the update. Try again or download it in your browser.';

  @override
  String get render96WatchTrailer => 'WATCH TRAILER';

  @override
  String get render96CategoryOther => 'CONTENT';

  @override
  String get coopConnectionFailed =>
      'The session could not continue. Check your connection and start it again.';

  @override
  String get catalogLoadFailed =>
      'Could not load this content. Check your connection and try again.';

  @override
  String get settingsFavouritesShareSubject => 'SM64CoopDX favorites';

  @override
  String get favEmptyActionHint => 'Tap ♥ on a card to save it here.';

  @override
  String get guidedSetupWelcomeTitle => 'Welcome';

  @override
  String get guidedSetupWelcomeBody =>
      'Great to see you here! Let\'s get your mod adventure ready together. You\'ll always stay in control, and optional access can wait until you need it.';

  @override
  String guidedSetupProgress(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get guidedSetupStart => 'Start';

  @override
  String get guidedSetupLater => 'Do it later';

  @override
  String get guidedSetupAudioTitle => 'Sound experience';

  @override
  String get guidedSetupAudioBody =>
      'Would you like to enjoy ambient music and sound effects while exploring your mods? You can change music and effects separately later in Settings.';

  @override
  String get guidedSetupAudioOn => 'With sound';

  @override
  String get guidedSetupAudioOff => 'Silent mode';

  @override
  String get guidedSetupAudioSaveError =>
      'Your sound preference could not be saved. Try again.';

  @override
  String get guidedSetupDoneTitle => 'You\'re ready';

  @override
  String get guidedSetupDoneBody =>
      'The basic setup is complete. Optional access remains available in Settings whenever a feature needs it.';

  @override
  String get guidedSetupFinish => 'Finish';

  @override
  String get permissionCenterTitle => 'Permissions & access';

  @override
  String get permissionCenterSubtitle => 'Review what the app can use and why';

  @override
  String get permissionCenterIntro =>
      'Only grant access when you understand its purpose. Optional access is requested in context and the app checks Android for the current status.';

  @override
  String get permissionStatusAllowed => 'Allowed';

  @override
  String get permissionStatusNotAllowed => 'Not allowed';

  @override
  String get permissionStatusOptional => 'Optional · checking status';

  @override
  String get permissionManage => 'Manage';

  @override
  String get permissionFolderDescription =>
      'Lets the app find, install and manage mods and player files in the game folder you select.';

  @override
  String get permissionNotificationsDescription =>
      'Shows download and installation progress. Requested only when a download needs it.';

  @override
  String get permissionAllFilesDescription =>
      'Optional faster installation on compatible Android devices. Folder access continues to work without it.';

  @override
  String get permissionOverlayDescription =>
      'Optional floating download bubble displayed over other apps.';

  @override
  String get permissionBatteryDescription =>
      'Optional for hosting or joining longer Play sessions while the app is in the background.';

  @override
  String get permissionUpdatesTitle => 'Install app updates';

  @override
  String get permissionUpdatesDescription =>
      'Android asks for this special access only when you choose to install an app update.';

  @override
  String get permissionNetworkTitle => 'Network & Play';

  @override
  String get permissionNetworkDescription =>
      'Internet access powers the catalog and online sessions. Play asks for explicit consent before connecting to its service.';

  @override
  String get permissionRunGuide => 'Run guided setup again';

  @override
  String get permissionRunGuideDescription =>
      'Reopens the welcome steps without changing any Android permission by itself.';

  @override
  String get detailArtifactRecommended => 'RECOMMENDED';

  @override
  String get detailArtifactTextures => 'Textures';

  @override
  String get detailArtifactVoices => 'Extra voices';

  @override
  String get detailArtifactPrimaryDescription =>
      'Complete main package. Start with this file.';

  @override
  String get detailArtifactLiteDescription =>
      'Lighter variant with some non-essential features removed.';

  @override
  String get detailArtifactApiDescription =>
      'Optional add-ons that use this mod\'s API; not the main mod.';

  @override
  String get detailArtifactTexturesDescription =>
      'Optional visual resources for this mod.';

  @override
  String get detailArtifactVoicesDescription =>
      'Optional additional voice pack; install the main mod first.';

  @override
  String get detailArtifactOptionalDescription =>
      'Optional companion file. Check the mod description before installing.';
}
