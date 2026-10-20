import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('es', '419'),
    Locale('pt'),
    Locale('pt', 'BR'),
  ];

  /// Test key — remove before production
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// Drawer navigation label for the home screen
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Drawer navigation label for the catalogue screen
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get navCatalog;

  /// Drawer navigation label for the favourites screen
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get navFavourites;

  /// Drawer navigation label for the popular screen
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get navPopular;

  /// Drawer navigation label for the VIP mods screen
  ///
  /// In en, this message translates to:
  /// **'Mods'**
  String get navVIPMods;

  /// Drawer navigation label for the DynOS screen
  ///
  /// In en, this message translates to:
  /// **'DynOS'**
  String get navDynOS;

  /// Drawer navigation label for the touch controls screen
  ///
  /// In en, this message translates to:
  /// **'Touch Controls'**
  String get navTouchControls;

  /// Drawer navigation label for the OMM Rebirth screen
  ///
  /// In en, this message translates to:
  /// **'Omm Pack'**
  String get navOmmRebirth;

  /// Drawer navigation label for the links & resources screen
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get navLinksResource;

  /// Drawer navigation label for the disclaimer screen
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get navDisclaimer;

  /// Drawer navigation label for the settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Section header in the drawer for exclusive content items
  ///
  /// In en, this message translates to:
  /// **'Exclusive'**
  String get sectionExclusive;

  /// Section header for the primary navigation items in the drawer
  ///
  /// In en, this message translates to:
  /// **'NAVIGATION'**
  String get sectionNavigation;

  /// Section header in the drawer for category browsing
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get sectionExplore;

  /// Expandable section header in the drawer for category filters
  ///
  /// In en, this message translates to:
  /// **'CATEGORIES'**
  String get sectionCategories;

  /// Expandable section header in the drawer for sort options
  ///
  /// In en, this message translates to:
  /// **'SORT BY'**
  String get sectionSortBy;

  /// Section header in the drawer for social media links
  ///
  /// In en, this message translates to:
  /// **'SOCIAL LINKS'**
  String get sectionSocialLinks;

  /// Sort option label: default / relevance
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get sortDefault;

  /// Sort option label: sort by rating
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get sortRating;

  /// Sort option label: sort by download count
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get sortDownloads;

  /// Sort option label: sort by most recently updated
  ///
  /// In en, this message translates to:
  /// **'Newest Update'**
  String get sortNewest;

  /// Tooltip for the YouTube social link button
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get socialYouTube;

  /// Tooltip for the Discord social link button
  ///
  /// In en, this message translates to:
  /// **'Discord'**
  String get socialDiscord;

  /// Tooltip for the GitHub social link button
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get socialGitHub;

  /// Category name: character mods and player models
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get categoryCharacters;

  /// Category name: custom game modes and multiplayer modes
  ///
  /// In en, this message translates to:
  /// **'Game Modes'**
  String get categoryGameModes;

  /// Category name: custom levels, ROM hacks, and worlds
  ///
  /// In en, this message translates to:
  /// **'ROM Hacks & Levels'**
  String get categoryROMHacks;

  /// Category name: gameplay tweaks, mechanics, and abilities
  ///
  /// In en, this message translates to:
  /// **'Gameplay & Mechanics'**
  String get categoryGameplay;

  /// Category name: visual mods, textures, models, and HUD
  ///
  /// In en, this message translates to:
  /// **'Visual & Models'**
  String get categoryVisual;

  /// Category name: music, sound effects, and voice packs
  ///
  /// In en, this message translates to:
  /// **'Audio & Voice'**
  String get categoryAudio;

  /// Category name: utility and tool mods for server/admin
  ///
  /// In en, this message translates to:
  /// **'Utilities & Tools'**
  String get categoryUtilities;

  /// Category name: miscellaneous, fun, memes, and joke mods
  ///
  /// In en, this message translates to:
  /// **'Misc & Fun'**
  String get categoryMisc;

  /// Badge label shown on featured mod cards
  ///
  /// In en, this message translates to:
  /// **'FEATURED'**
  String get badgeFeatured;

  /// Dialog title when a forced update is required
  ///
  /// In en, this message translates to:
  /// **'UPDATE REQUIRED'**
  String get updateRequired;

  /// Dialog title when a new version is available
  ///
  /// In en, this message translates to:
  /// **'NEW VERSION AVAILABLE'**
  String get updateAvailable;

  /// Shows the available version number in the update dialog
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String updateVersion(String version);

  /// Shows the APK file size in the update dialog
  ///
  /// In en, this message translates to:
  /// **'Size: {size} MB'**
  String updateSize(String size);

  /// Progress text shown while downloading the update
  ///
  /// In en, this message translates to:
  /// **'Downloading... {pct}%'**
  String updateDownloading(String pct);

  /// Error shown when OTA update is already running
  ///
  /// In en, this message translates to:
  /// **'A download is already in progress. Wait or restart the app.'**
  String get updateAlreadyDownloading;

  /// Error shown when the user denied install permission
  ///
  /// In en, this message translates to:
  /// **'Install permission denied.\nGo to Settings → Apps → this app → Install unknown apps.'**
  String get updatePermissionDenied;

  /// Error shown for internal OTA errors
  ///
  /// In en, this message translates to:
  /// **'Internal error: {detail}'**
  String updateInternalError(String detail);

  /// Error shown when the download fails due to network issues
  ///
  /// In en, this message translates to:
  /// **'Download error. Check your connection.'**
  String get updateDownloadError;

  /// Error shown when the APK checksum verification fails
  ///
  /// In en, this message translates to:
  /// **'The downloaded file is corrupt. Please try again.'**
  String get updateChecksumError;

  /// Error shown when APK installation fails
  ///
  /// In en, this message translates to:
  /// **'Install error: {detail}'**
  String updateInstallError(String detail);

  /// Generic error shown for unexpected OTA failures
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {detail}'**
  String updateUnexpectedError(String detail);

  /// Error shown when the OTA update process cannot be initiated
  ///
  /// In en, this message translates to:
  /// **'Could not start the update: {detail}'**
  String updateCantStart(String detail);

  /// Button label to open the release page in the browser
  ///
  /// In en, this message translates to:
  /// **'OPEN IN BROWSER'**
  String get updateButtonOpenBrowser;

  /// Button label to dismiss the optional update dialog
  ///
  /// In en, this message translates to:
  /// **'LATER'**
  String get updateButtonLater;

  /// Button label to close the app (forced update)
  ///
  /// In en, this message translates to:
  /// **'EXIT'**
  String get updateButtonExit;

  /// Button label to start the OTA update download
  ///
  /// In en, this message translates to:
  /// **'UPDATE NOW'**
  String get updateButtonUpdateNow;

  /// Button label to go to the GitHub releases page (non-Android)
  ///
  /// In en, this message translates to:
  /// **'GO TO DOWNLOADS'**
  String get updateButtonGoToDownloads;

  /// Title of the post-install dialog shown after a mod is installed
  ///
  /// In en, this message translates to:
  /// **'Mod installed'**
  String get postInstallTitle;

  /// Post-install instruction when the game is detected as installed
  ///
  /// In en, this message translates to:
  /// **'If the game was already running, close it completely (not just minimize) and reopen it so the new files are loaded correctly.'**
  String get postInstallGameRunning;

  /// Clarification that the user does not need special permissions
  ///
  /// In en, this message translates to:
  /// **'No force-stop or root needed — just close the game normally and reopen it.'**
  String get postInstallNoRoot;

  /// Message shown when game is not installed, just files were copied
  ///
  /// In en, this message translates to:
  /// **'Files have been copied to the mods folder.'**
  String get postInstallFilesCopied;

  /// Button label to dismiss the post-install dialog
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get postInstallClose;

  /// Button label to launch the game after installing a mod
  ///
  /// In en, this message translates to:
  /// **'LAUNCH GAME'**
  String get postInstallLaunchGame;

  /// Home screen section title for exclusive content
  ///
  /// In en, this message translates to:
  /// **'Exclusive Content'**
  String get homeExclusiveContent;

  /// Home screen section title for top downloads
  ///
  /// In en, this message translates to:
  /// **'Top Downloads'**
  String get homeTopDownloads;

  /// Home screen link to see all items in a section
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// Home screen section title for featured mods
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get homeFeatured;

  /// Home screen quick-link tile for the full catalog
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get homeCatalog;

  /// Home screen description for the catalog quick-link tile
  ///
  /// In en, this message translates to:
  /// **'Browse, search & filter the full mod collection'**
  String get homeCatalogDesc;

  /// Home screen quick-link tile for favourites
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get homeFavorites;

  /// Home screen description for the favourites quick-link tile
  ///
  /// In en, this message translates to:
  /// **'Your saved mods across all sections'**
  String get homeFavoritesDesc;

  /// Home screen quick-link tile for popular rankings
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get homePopular;

  /// Home screen description for the popular quick-link tile
  ///
  /// In en, this message translates to:
  /// **'Top mods ranked by total downloads'**
  String get homePopularDesc;

  /// Home screen button label to browse content
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get homeBrowse;

  /// Home screen button label to navigate to a section
  ///
  /// In en, this message translates to:
  /// **'GO TO'**
  String get homeGoTo;

  /// Home screen quick-link tile for VIP mods
  ///
  /// In en, this message translates to:
  /// **'VIP Mods'**
  String get homeVipMods;

  /// Home screen description for the VIP mods quick-link tile
  ///
  /// In en, this message translates to:
  /// **'Exclusive character & model packs'**
  String get homeVipModsDesc;

  /// Home screen quick-link tile for DynOS
  ///
  /// In en, this message translates to:
  /// **'DynOS'**
  String get homeDynos;

  /// Home screen description for the DynOS quick-link tile
  ///
  /// In en, this message translates to:
  /// **'Custom textures & model swaps'**
  String get homeDynosDesc;

  /// Home screen quick-link tile for touch controls
  ///
  /// In en, this message translates to:
  /// **'Touch Controls'**
  String get homeTouchControls;

  /// Home screen description for the touch controls quick-link tile
  ///
  /// In en, this message translates to:
  /// **'Custom button & joystick layouts'**
  String get homeTouchControlsDesc;

  /// Home screen quick-link tile for the OMM Rebirth texture pack
  ///
  /// In en, this message translates to:
  /// **'OMMR PACK'**
  String get homeOmmrPack;

  /// Home screen description for the OMM Rebirth quick-link tile
  ///
  /// In en, this message translates to:
  /// **'Complete OMM Rebirth texture pack'**
  String get homeOmmrPackDesc;

  /// Home screen title for the game-not-installed dialog
  ///
  /// In en, this message translates to:
  /// **'Game not installed'**
  String get homeGameNotInstalled;

  /// Home screen body text for the game-not-installed dialog
  ///
  /// In en, this message translates to:
  /// **'SM64CoopDX (com.maniscat2.sm64coopdx)\nis not installed on this device.'**
  String get homeGameNotInstalledBody;

  /// Home screen button label to close a dialog
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get homeClose;

  /// Home screen button label to download the game
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get homeDownload;

  /// Home screen button label to launch the game
  ///
  /// In en, this message translates to:
  /// **'LAUNCH  GAME'**
  String get homeLaunchGame;

  /// Home screen badge label indicating a section is coming soon
  ///
  /// In en, this message translates to:
  /// **'SOON'**
  String get homeSoon;

  /// Home screen error message when mods cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Failed to load mods'**
  String get homeFailedToLoad;

  /// Home screen button label to retry a failed action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get homeRetry;

  /// Catalogue screen title
  ///
  /// In en, this message translates to:
  /// **'BROWSE MODS'**
  String get catalogueTitle;

  /// Catalogue screen count of total mods
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} MOD} other{{count} MODS}}'**
  String catalogueModCount(int count);

  /// Catalogue screen count of search/filter results
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} RESULT} other{{count} RESULT}}'**
  String catalogueResultCount(int count);

  /// Catalogue screen placeholder text for the search field
  ///
  /// In en, this message translates to:
  /// **'SEARCH MODS, AUTHORS, TAGS…'**
  String get catalogueSearchHint;

  /// Catalogue screen sort option: default ordering
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get catalogueSortDefault;

  /// Catalogue screen sort option: top rated first
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get catalogueSortTopRated;

  /// Catalogue screen sort option: most downloaded first
  ///
  /// In en, this message translates to:
  /// **'Most Downloaded'**
  String get catalogueSortMostDownloaded;

  /// Catalogue screen sort option: recently updated first
  ///
  /// In en, this message translates to:
  /// **'Recently Updated'**
  String get catalogueSortRecentlyUpdated;

  /// Catalogue screen button to clear all active filters
  ///
  /// In en, this message translates to:
  /// **'CLEAR ALL'**
  String get catalogueClearAll;

  /// Catalogue screen pagination label showing current range of total mods
  ///
  /// In en, this message translates to:
  /// **'{start}–{end} OF {total} MODS'**
  String cataloguePaginationRange(int start, int end, int total);

  /// Catalogue screen empty state title when search yields no results
  ///
  /// In en, this message translates to:
  /// **'NO MODS FOUND'**
  String get catalogueNoModsFound;

  /// Catalogue screen empty state title when no content exists
  ///
  /// In en, this message translates to:
  /// **'NOTHING HERE YET'**
  String get catalogueNothingHere;

  /// Catalogue screen empty state hint — first suggestion
  ///
  /// In en, this message translates to:
  /// **'Try different keywords or remove filters.'**
  String get catalogueEmptyHint1;

  /// Catalogue screen empty state hint — second suggestion
  ///
  /// In en, this message translates to:
  /// **'Check back later for new content.'**
  String get catalogueEmptyHint2;

  /// Catalogue screen button to remove active filters
  ///
  /// In en, this message translates to:
  /// **'CLEAR FILTERS'**
  String get catalogueClearFilters;

  /// Catalogue screen error message when mods cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'FAILED TO LOAD MODS'**
  String get catalogueFailedToLoad;

  /// Catalogue screen sort chip label: rating order
  ///
  /// In en, this message translates to:
  /// **'RATING'**
  String get catalogueRating;

  /// Catalogue screen sort chip label: download count order
  ///
  /// In en, this message translates to:
  /// **'DOWNLOADS'**
  String get catalogueDownloads;

  /// Catalogue screen sort chip label: newest first
  ///
  /// In en, this message translates to:
  /// **'NEWEST'**
  String get catalogueNewest;

  /// Catalogue screen sort chip label: generic sort action
  ///
  /// In en, this message translates to:
  /// **'SORT'**
  String get catalogueSort;

  /// Catalogue screen pagination ellipsis indicator
  ///
  /// In en, this message translates to:
  /// **'···'**
  String get catalogueEllipsis;

  /// Popular screen title
  ///
  /// In en, this message translates to:
  /// **'POPULAR'**
  String get popularTitle;

  /// Popular screen count of total ranked mods
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} MOD} other{{count} MODS}}'**
  String popularModCount(int count);

  /// Popular screen button label to view more rankings
  ///
  /// In en, this message translates to:
  /// **'MORE RANKINGS'**
  String get popularMoreRankings;

  /// Popular screen section header for rankings list
  ///
  /// In en, this message translates to:
  /// **'RANKINGS'**
  String get popularRankings;

  /// Popular screen page indicator
  ///
  /// In en, this message translates to:
  /// **'PG {page}/{total}'**
  String popularPage(int page, int total);

  /// Popular screen section header for the top 3 mods
  ///
  /// In en, this message translates to:
  /// **'TOP 3'**
  String get popularTop3;

  /// Popular screen rank number prefix
  ///
  /// In en, this message translates to:
  /// **'#{rank}'**
  String popularRank(int rank);

  /// Popular screen error message when rankings cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'FAILED TO LOAD'**
  String get popularFailedToLoad;

  /// Favourites screen title
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favouritesTitle;

  /// Favourites screen tab label for mods
  ///
  /// In en, this message translates to:
  /// **'Mods'**
  String get favTabMods;

  /// Favourites screen tab label for VIP mods
  ///
  /// In en, this message translates to:
  /// **'VIP'**
  String get favTabVip;

  /// Favourites screen tab label for DynOS
  ///
  /// In en, this message translates to:
  /// **'DynOS'**
  String get favTabDynos;

  /// Favourites screen tab label for touch controls
  ///
  /// In en, this message translates to:
  /// **'Touch'**
  String get favTabTouch;

  /// Favourites screen empty state for mods tab
  ///
  /// In en, this message translates to:
  /// **'No mods favourited yet'**
  String get favEmptyMods;

  /// Favourites screen empty state for VIP tab
  ///
  /// In en, this message translates to:
  /// **'No VIP mods favourited yet'**
  String get favEmptyVip;

  /// Favourites screen empty state for DynOS tab
  ///
  /// In en, this message translates to:
  /// **'No DynOS favourited yet'**
  String get favEmptyDynos;

  /// Favourites screen empty state for touch controls tab
  ///
  /// In en, this message translates to:
  /// **'No Touch Controls favourited yet'**
  String get favEmptyTouch;

  /// Favourites screen empty state hint explaining how to add items
  ///
  /// In en, this message translates to:
  /// **'Tap ♥ on any {type} to save it here.'**
  String favEmptyHint(String type);

  /// Favourites screen button label to browse content when empty
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get favBrowse;

  /// Snackbar message shown when a mod is added to favourites
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get sharedAddedToFavorites;

  /// Snackbar message shown when a mod is removed from favourites
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get sharedRemovedFromFavorites;

  /// Snackbar message shown when a mod download completes
  ///
  /// In en, this message translates to:
  /// **'Downloaded: {name}'**
  String sharedDownloaded(String name);

  /// Snackbar message shown when a content download completes, with content type
  ///
  /// In en, this message translates to:
  /// **'Downloaded {type}: {name}'**
  String sharedDownloadedType(String type, String name);

  /// Snackbar message shown when a mod download fails
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get sharedDownloadFailed;

  /// Shared button label to add an item to favourites
  ///
  /// In en, this message translates to:
  /// **'ADD TO FAVORITES'**
  String get sharedAddToFavorites;

  /// Shared button label to remove an item from favourites
  ///
  /// In en, this message translates to:
  /// **'REMOVE FROM FAVORITES'**
  String get sharedRemoveFromFavorites;

  /// Shared button label to download a mod
  ///
  /// In en, this message translates to:
  /// **'DOWNLOAD'**
  String get sharedDownload;

  /// No description provided for @installationChecking.
  ///
  /// In en, this message translates to:
  /// **'CHECKING...'**
  String get installationChecking;

  /// No description provided for @installationCancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get installationCancel;

  /// No description provided for @installationInstalled.
  ///
  /// In en, this message translates to:
  /// **'INSTALLED'**
  String get installationInstalled;

  /// No description provided for @installationUpdate.
  ///
  /// In en, this message translates to:
  /// **'UPDATE'**
  String get installationUpdate;

  /// No description provided for @installationInstall.
  ///
  /// In en, this message translates to:
  /// **'INSTALL'**
  String get installationInstall;

  /// No description provided for @installationReinstall.
  ///
  /// In en, this message translates to:
  /// **'REINSTALL'**
  String get installationReinstall;

  /// No description provided for @installationVerify.
  ///
  /// In en, this message translates to:
  /// **'VERIFY'**
  String get installationVerify;

  /// No description provided for @installationSelectFolder.
  ///
  /// In en, this message translates to:
  /// **'SELECT FOLDER'**
  String get installationSelectFolder;

  /// Shared button label to expand text
  ///
  /// In en, this message translates to:
  /// **'READ MORE'**
  String get sharedReadMore;

  /// Shared button label to collapse text
  ///
  /// In en, this message translates to:
  /// **'SHOW LESS'**
  String get sharedShowLess;

  /// VIP mods screen title
  ///
  /// In en, this message translates to:
  /// **'VIP MODS'**
  String get vipTitle;

  /// VIP mods screen empty state title
  ///
  /// In en, this message translates to:
  /// **'NO VIP MODS YET'**
  String get vipEmpty;

  /// VIP mods screen empty state hint
  ///
  /// In en, this message translates to:
  /// **'Check back later for exclusive content.'**
  String get vipEmptyHint;

  /// VIP mods screen error message when content cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'FAILED TO LOAD VIP MODS'**
  String get vipFailedToLoad;

  /// DynOS screen title
  ///
  /// In en, this message translates to:
  /// **'DYNOS'**
  String get dynosTitle;

  /// DynOS screen empty state title
  ///
  /// In en, this message translates to:
  /// **'NO DYNOS YET'**
  String get dynosEmpty;

  /// DynOS screen empty state hint
  ///
  /// In en, this message translates to:
  /// **'Check back later for runtime patches.'**
  String get dynosEmptyHint;

  /// DynOS screen error message when content cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'FAILED TO LOAD DYNOS'**
  String get dynosFailedToLoad;

  /// Touch controls screen title
  ///
  /// In en, this message translates to:
  /// **'TOUCH CONTROLS'**
  String get touchTitle;

  /// Touch controls screen count of available layouts
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} LAYOUT} other{{count} LAYOUTS}}'**
  String touchModCount(int count);

  /// Touch controls screen empty state title
  ///
  /// In en, this message translates to:
  /// **'NO TOUCH LAYOUTS YET'**
  String get touchEmpty;

  /// Touch controls screen empty state hint
  ///
  /// In en, this message translates to:
  /// **'Check back later for mobile control layouts.'**
  String get touchEmptyHint;

  /// Touch controls screen error message when content cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'FAILED TO LOAD TOUCH CONTROLS'**
  String get touchFailedToLoad;

  /// OMM Rebirth screen title
  ///
  /// In en, this message translates to:
  /// **'OMM REBIRTH'**
  String get ommTitle;

  /// OMM Rebirth screen empty state title
  ///
  /// In en, this message translates to:
  /// **'NO OMM REBIRTH MODS YET'**
  String get ommEmpty;

  /// OMM Rebirth screen empty state hint
  ///
  /// In en, this message translates to:
  /// **'Check back later for OMM Rebirth content.'**
  String get ommEmptyHint;

  /// OMM Rebirth screen error message when content cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'FAILED TO LOAD OMM REBIRTH MODS'**
  String get ommFailedToLoad;

  /// Detail screen section title for the download area
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get detailDownload;

  /// Detail screen button label to start download
  ///
  /// In en, this message translates to:
  /// **'DOWNLOAD'**
  String get detailDownloadButton;

  /// Detail screen error title when a mod cannot be found
  ///
  /// In en, this message translates to:
  /// **'Mod not found'**
  String get detailModNotFound;

  /// Detail screen error body when a mod cannot be found
  ///
  /// In en, this message translates to:
  /// **'This mod may have been removed or the link is invalid.'**
  String get detailModNotFoundBody;

  /// Detail screen button label to navigate back
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get detailGoBack;

  /// Detail screen error message when mod details cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Failed to load mod'**
  String get detailFailedToLoad;

  /// Detail screen button label to retry loading
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get detailRetry;

  /// Detail screen dialog title for notification permission request
  ///
  /// In en, this message translates to:
  /// **'Notifications needed'**
  String get detailNotificationsNeeded;

  /// Detail screen dialog body for notification permission request
  ///
  /// In en, this message translates to:
  /// **'We need notification permission to show download and installation progress, even if you leave the app.'**
  String get detailNotificationsBody;

  /// Detail screen dialog button to skip notification permission
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get detailNotNow;

  /// Detail screen dialog button to proceed with notification permission
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get detailContinue;

  /// Detail screen message when notification permission is skipped
  ///
  /// In en, this message translates to:
  /// **'You won\'t see progress outside the app. Grant permission in Settings to enable notifications.'**
  String get detailNotificationsSkipped;

  /// Detail screen dialog title when no mods folder is selected
  ///
  /// In en, this message translates to:
  /// **'Mods folder not selected'**
  String get detailModsFolderNotSelected;

  /// Detail screen dialog body when no mods folder is selected
  ///
  /// In en, this message translates to:
  /// **'You need to select a mods folder before installing mods to the game.\n\nGo to Settings → Game Integration to select it.'**
  String get detailModsFolderBody;

  /// Detail screen dialog button to cancel an action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get detailCancel;

  /// Detail screen button label to navigate to settings
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get detailGoToSettings;

  /// Detail screen message showing current download file name
  ///
  /// In en, this message translates to:
  /// **'Downloading \"{filename}\"...'**
  String detailDownloading(String filename);

  /// Detail screen message when a mod is saved to the mods folder
  ///
  /// In en, this message translates to:
  /// **'Saved to mods folder: {name}'**
  String detailSavedToModsFolder(String name);

  /// Detail screen message when content is saved to a specific folder type
  ///
  /// In en, this message translates to:
  /// **'Saved to {type} folder: {name}'**
  String detailSavedToFolder(String type, String name);

  /// Detail screen error message when a download fails
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get detailDownloadFailed;

  /// Detail screen generic error message with detail
  ///
  /// In en, this message translates to:
  /// **'Error: {detail}'**
  String detailError(String detail);

  /// Detail screen message when a download completes
  ///
  /// In en, this message translates to:
  /// **'Downloaded: {name}'**
  String detailDownloaded(String name);

  /// Detail screen message when a download completes, with content type
  ///
  /// In en, this message translates to:
  /// **'Downloaded {type}: {name}'**
  String detailDownloadedType(String type, String name);

  /// Detail screen banner text shown during download
  ///
  /// In en, this message translates to:
  /// **'Downloading mod...'**
  String get detailDownloadingBanner;

  /// Detail screen banner text shown during download, with content type
  ///
  /// In en, this message translates to:
  /// **'Downloading {type}...'**
  String detailDownloadingBannerType(String type);

  /// Detail screen progress indicator for file extraction
  ///
  /// In en, this message translates to:
  /// **'{current}/{total} files'**
  String detailFilesProgress(int current, int total);

  /// Detail screen message shown during archive extraction
  ///
  /// In en, this message translates to:
  /// **'Extracting...'**
  String get detailExtracting;

  /// Detail screen message shown during mod installation
  ///
  /// In en, this message translates to:
  /// **'Installing mod...'**
  String get detailInstallingMod;

  /// Detail screen message when installation finishes
  ///
  /// In en, this message translates to:
  /// **'Installation complete'**
  String get detailInstallComplete;

  /// Detail screen message showing extraction results
  ///
  /// In en, this message translates to:
  /// **'{count} files extracted to \"{dir}\"'**
  String detailInstallFilesExtracted(int count, String dir);

  /// Detail screen error message when installation fails
  ///
  /// In en, this message translates to:
  /// **'Installation failed'**
  String get detailInstallFailed;

  /// Detail screen message when an operation is cancelled
  ///
  /// In en, this message translates to:
  /// **'Operation cancelled'**
  String get detailOperationCancelled;

  /// Detail screen progress percentage during download
  ///
  /// In en, this message translates to:
  /// **'Downloading {pct}%'**
  String detailDownloadingPct(String pct);

  /// Detail screen message during installation step
  ///
  /// In en, this message translates to:
  /// **'Installing...'**
  String get detailInstalling;

  /// No description provided for @overlayCancelling.
  ///
  /// In en, this message translates to:
  /// **'Cancelling...'**
  String get overlayCancelling;

  /// No description provided for @detailDynosFolderNotSelected.
  ///
  /// In en, this message translates to:
  /// **'DynOS and Touch Controls folder not selected'**
  String get detailDynosFolderNotSelected;

  /// No description provided for @detailDynosFolderBody.
  ///
  /// In en, this message translates to:
  /// **'Select the shared DynOS and Touch Controls folder in Settings → Game Integration before installing this content.'**
  String get detailDynosFolderBody;

  /// No description provided for @detailInstallDownloadedTitle.
  ///
  /// In en, this message translates to:
  /// **'Install downloaded content?'**
  String get detailInstallDownloadedTitle;

  /// No description provided for @detailInstallDownloadedBody.
  ///
  /// In en, this message translates to:
  /// **'{name} has finished downloading. Install it in the DynOS and Touch Controls folder now?'**
  String detailInstallDownloadedBody(String name);

  /// No description provided for @detailInstallNow.
  ///
  /// In en, this message translates to:
  /// **'Install now'**
  String get detailInstallNow;

  /// No description provided for @detailKeepDownload.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get detailKeepDownload;

  /// No description provided for @detailDownloadedNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Downloaded, but not installed: {name}'**
  String detailDownloadedNotInstalled(String name);

  /// No description provided for @detailInstallQueued.
  ///
  /// In en, this message translates to:
  /// **'Download and installation started: {name}'**
  String detailInstallQueued(String name);

  /// No description provided for @detailContentUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This download is no longer available (404). The link may have been removed or changed.'**
  String get detailContentUnavailable;

  /// No description provided for @detailFriendlyDownloadError.
  ///
  /// In en, this message translates to:
  /// **'The download could not be completed. Check your connection and try again.'**
  String get detailFriendlyDownloadError;

  /// Detail screen section title for screenshots gallery
  ///
  /// In en, this message translates to:
  /// **'Screenshots'**
  String get detailScreenshots;

  /// Detail screen section title for tags
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get detailTags;

  /// Detail screen section title for about/description
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get detailAbout;

  /// Detail screen label for mod rating
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get detailRating;

  /// Detail screen label for download count
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get detailDownloads;

  /// Detail screen label for view count
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get detailViews;

  /// Detail screen label for review count
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get detailReviews;

  /// Detail screen section title for downloadable files with count
  ///
  /// In en, this message translates to:
  /// **'Download files ({count})'**
  String detailDownloadFiles(int count);

  /// Detail screen section title for version history with count
  ///
  /// In en, this message translates to:
  /// **'Versions ({count})'**
  String detailVersions(int count);

  /// Detail screen fallback label when version is unknown
  ///
  /// In en, this message translates to:
  /// **'v?'**
  String get detailVersionFallback;

  /// No description provided for @detailLatestVersion.
  ///
  /// In en, this message translates to:
  /// **'LATEST VERSION'**
  String get detailLatestVersion;

  /// No description provided for @detailPreviousVersions.
  ///
  /// In en, this message translates to:
  /// **'Previous versions'**
  String get detailPreviousVersions;

  /// No description provided for @detailViewPreviousVersions.
  ///
  /// In en, this message translates to:
  /// **'View {count} previous versions'**
  String detailViewPreviousVersions(int count);

  /// No description provided for @detailNoDownloadFiles.
  ///
  /// In en, this message translates to:
  /// **'No downloadable files are available.'**
  String get detailNoDownloadFiles;

  /// Detail screen label for initial release date
  ///
  /// In en, this message translates to:
  /// **'First Release'**
  String get detailFirstRelease;

  /// Detail screen label for last update date
  ///
  /// In en, this message translates to:
  /// **'Last Update'**
  String get detailLastUpdate;

  /// Detail screen section title for changelog
  ///
  /// In en, this message translates to:
  /// **'Changelog'**
  String get detailChangelog;

  /// Detail screen button label to collapse changelog section
  ///
  /// In en, this message translates to:
  /// **'Collapse changelog'**
  String get detailCollapseChangelog;

  /// Detail screen button label to view all version updates
  ///
  /// In en, this message translates to:
  /// **'View all {count} updates'**
  String detailViewAllUpdates(int count);

  /// Detail screen button label to collapse expanded content
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get detailShowLess;

  /// Detail screen button label to expand truncated content
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get detailShowMore;

  /// Detail screen message when notifications are not enabled
  ///
  /// In en, this message translates to:
  /// **'Notifications not enabled. You won\'t see download progress outside the app.'**
  String get detailNotificationsDisabled;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsTitle;

  /// Settings screen section header for data management
  ///
  /// In en, this message translates to:
  /// **'DATA'**
  String get settingsData;

  /// Settings screen label for clearing all favourites
  ///
  /// In en, this message translates to:
  /// **'Clear favourites'**
  String get settingsClearFavourites;

  /// Settings screen description for clearing favourites
  ///
  /// In en, this message translates to:
  /// **'Remove all saved mods'**
  String get settingsClearFavouritesDesc;

  /// Settings screen label for exporting favourites
  ///
  /// In en, this message translates to:
  /// **'Export favourites'**
  String get settingsExportFavourites;

  /// Settings screen description for exporting favourites
  ///
  /// In en, this message translates to:
  /// **'Share your saved mods'**
  String get settingsExportFavouritesDesc;

  /// Settings screen label for importing favourites
  ///
  /// In en, this message translates to:
  /// **'Import favourites'**
  String get settingsImportFavourites;

  /// Settings screen description for importing favourites
  ///
  /// In en, this message translates to:
  /// **'Restore from a previously exported file'**
  String get settingsImportFavouritesDesc;

  /// Settings screen section header for game integration
  ///
  /// In en, this message translates to:
  /// **'GAME INTEGRATION'**
  String get settingsGameIntegration;

  /// Settings screen section header for appearance
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get settingsAppearance;

  /// Settings screen section header for about info
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get settingsAbout;

  /// Settings screen link label to view GitHub releases
  ///
  /// In en, this message translates to:
  /// **'Go to releases'**
  String get settingsGoToReleases;

  /// Settings screen link label showing current version with GitHub link
  ///
  /// In en, this message translates to:
  /// **'View all versions on GitHub · v{version}'**
  String settingsViewAllVersions(String version);

  /// Settings screen label for the mod database source
  ///
  /// In en, this message translates to:
  /// **'Data source'**
  String get settingsDataSource;

  /// Settings screen message when there are no favourites to export
  ///
  /// In en, this message translates to:
  /// **'You have no favourites to export.'**
  String get settingsNoFavouritesToExport;

  /// Settings screen import result: number of items added
  ///
  /// In en, this message translates to:
  /// **'{count} added'**
  String settingsImportAdded(int count);

  /// Settings screen import result: number of items already saved
  ///
  /// In en, this message translates to:
  /// **'{count} already saved'**
  String settingsImportAlreadySaved(int count);

  /// Settings screen import result: number of items not found
  ///
  /// In en, this message translates to:
  /// **'{count} not found in catalogue'**
  String settingsImportNotFound(int count);

  /// Settings screen message when import has no new items
  ///
  /// In en, this message translates to:
  /// **'Nothing new to import.'**
  String get settingsImportNothingNew;

  /// Settings screen dialog title when import finishes
  ///
  /// In en, this message translates to:
  /// **'Import complete'**
  String get settingsImportComplete;

  /// Settings screen confirmation dialog title for clearing favourites
  ///
  /// In en, this message translates to:
  /// **'CLEAR FAVOURITES?'**
  String get settingsClearFavouritesTitle;

  /// Settings screen confirmation dialog body for clearing favourites
  ///
  /// In en, this message translates to:
  /// **'This will remove all your saved mods. This action cannot be undone.'**
  String get settingsClearFavouritesBody;

  /// Settings screen button label to confirm clearing
  ///
  /// In en, this message translates to:
  /// **'CLEAR'**
  String get settingsClearButton;

  /// Settings screen message when favourites are cleared
  ///
  /// In en, this message translates to:
  /// **'Favourites cleared'**
  String get settingsFavouritesCleared;

  /// Settings screen error message when a URL cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Cannot open URL: {url}'**
  String settingsCannotOpenUrl(String url);

  /// Settings screen button label to cancel an action
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get settingsCancel;

  /// Settings screen message when mods folder is selected
  ///
  /// In en, this message translates to:
  /// **'Mods folder selected. Mods will be installed here.'**
  String get settingsModsFolderSelected;

  /// Settings screen confirmation dialog title for clearing mods folder
  ///
  /// In en, this message translates to:
  /// **'CLEAR MODS FOLDER?'**
  String get settingsClearModsFolderTitle;

  /// Settings screen confirmation dialog body for clearing mods folder
  ///
  /// In en, this message translates to:
  /// **'You will need to select the folder again before installing mods to the game.'**
  String get settingsClearModsFolderBody;

  /// Settings screen message when mods folder selection is cleared
  ///
  /// In en, this message translates to:
  /// **'Mods folder selection cleared.'**
  String get settingsModsFolderCleared;

  /// Settings screen label for the mods folder setting
  ///
  /// In en, this message translates to:
  /// **'Mods folder'**
  String get settingsModsFolder;

  /// Settings screen button label to select a mods folder
  ///
  /// In en, this message translates to:
  /// **'Select mods folder'**
  String get settingsSelectModsFolder;

  /// Settings screen hint text for mods folder interaction
  ///
  /// In en, this message translates to:
  /// **'Tap to change · Long-press to clear'**
  String get settingsModsFolderHint;

  /// Settings screen description for the mods folder setting
  ///
  /// In en, this message translates to:
  /// **'Choose where to install downloaded mods'**
  String get settingsModsFolderDesc;

  /// Settings screen label for auto-install toggle
  ///
  /// In en, this message translates to:
  /// **'Auto-install after download'**
  String get settingsAutoInstall;

  /// Settings screen message when auto-install is on
  ///
  /// In en, this message translates to:
  /// **'Downloads will be installed automatically in their configured game folder'**
  String get settingsAutoInstallOn;

  /// Settings screen message when auto-install is off
  ///
  /// In en, this message translates to:
  /// **'You will be asked after each download'**
  String get settingsAutoInstallOff;

  /// One-time auto-install choice banner title
  ///
  /// In en, this message translates to:
  /// **'Install mods after downloading?'**
  String get autoInstallPromptTitle;

  /// One-time auto-install choice banner explanation
  ///
  /// In en, this message translates to:
  /// **'Turn on auto-install to place downloaded mods in their configured game folder. You can change this later in Settings.'**
  String get autoInstallPromptBody;

  /// Enables auto-install from the one-time banner
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get autoInstallPromptEnable;

  /// Keeps auto-install disabled from the one-time banner
  ///
  /// In en, this message translates to:
  /// **'Download only'**
  String get autoInstallPromptDownloadOnly;

  /// Settings screen section header for theme mode selection
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get settingsThemeMode;

  /// Settings screen message when the mod database is updated
  ///
  /// In en, this message translates to:
  /// **'Database updated · {count} mods{date}'**
  String settingsDatabaseUpdated(int count, String date);

  /// Settings screen message for unknown errors
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get settingsUnknownError;

  /// Settings screen button label to reload the mod database
  ///
  /// In en, this message translates to:
  /// **'Reload database'**
  String get settingsReloadDatabase;

  /// Settings screen progress message while downloading database
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get settingsDownloading;

  /// Settings screen button label to download the latest mod list
  ///
  /// In en, this message translates to:
  /// **'Download latest mod list'**
  String get settingsDownloadLatest;

  /// Settings screen message when database is current
  ///
  /// In en, this message translates to:
  /// **'You\'re up to date · v{version}'**
  String settingsUpToDate(String version);

  /// Settings screen button label to check for database updates
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get settingsCheckForUpdates;

  /// Settings screen message while checking for updates
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get settingsChecking;

  /// Generic settings label used in navigation and headers
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get generalSettings;

  /// Generic retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get generalRetry;

  /// Links screen title part 1 — uppercase section label
  ///
  /// In en, this message translates to:
  /// **'LINKS '**
  String get linksTitle;

  /// Links screen title part 2 — descriptive subtitle
  ///
  /// In en, this message translates to:
  /// **'& RECURSOS'**
  String get linksSubtitle;

  /// Links screen section header for official project channels
  ///
  /// In en, this message translates to:
  /// **'OFFICIAL'**
  String get linksOfficiaSection;

  /// Links screen description for verified project channels
  ///
  /// In en, this message translates to:
  /// **'Verified channels from the SM64CoopDX project.'**
  String get linksOfficialDesc;

  /// Links screen section header for app downloads and content
  ///
  /// In en, this message translates to:
  /// **'SM64CDPY'**
  String get linksSm64cdpySection;

  /// Links screen description for app content
  ///
  /// In en, this message translates to:
  /// **'Downloads and content from this app.'**
  String get linksSm64cdpyDesc;

  /// Links screen section header for community and guides
  ///
  /// In en, this message translates to:
  /// **'RESOURCES'**
  String get linksResourcesSection;

  /// Links screen description for community resources
  ///
  /// In en, this message translates to:
  /// **'Community, guides, and step-by-step installation.'**
  String get linksResourcesDesc;

  /// Links screen hero card title
  ///
  /// In en, this message translates to:
  /// **'LINK HUB'**
  String get linksHeroTitle;

  /// Links screen hero card description text
  ///
  /// In en, this message translates to:
  /// **'Everything official, the community, and project resources in one place.'**
  String get linksHeroDesc;

  /// Links screen hint chip — tap to open link
  ///
  /// In en, this message translates to:
  /// **'TAP = OPEN'**
  String get linksChipTap;

  /// Links screen hint chip — hold to copy link
  ///
  /// In en, this message translates to:
  /// **'HOLD = COPY'**
  String get linksChipHold;

  /// Link item title for the project website
  ///
  /// In en, this message translates to:
  /// **'SM64CoopDX Website'**
  String get linksWebsite;

  /// Link item subtitle showing the website URL
  ///
  /// In en, this message translates to:
  /// **'sm64coopdx.com'**
  String get linksWebsiteUrl;

  /// Link item title for the official SM64CDPY website
  ///
  /// In en, this message translates to:
  /// **'Official SM64CDPY Website'**
  String get linksAppWebsite;

  /// Link item subtitle for the official SM64CDPY website
  ///
  /// In en, this message translates to:
  /// **'News, downloads, and project information'**
  String get linksAppWebsiteDesc;

  /// Link kind badge label for web links
  ///
  /// In en, this message translates to:
  /// **'WEB'**
  String get linksKindWeb;

  /// Link item title for Discord server
  ///
  /// In en, this message translates to:
  /// **'Discord Server'**
  String get linksDiscordServer;

  /// Link item subtitle for the official Discord server
  ///
  /// In en, this message translates to:
  /// **'Official community server · Android'**
  String get linksDiscordOfficial;

  /// Link kind badge label for Discord links
  ///
  /// In en, this message translates to:
  /// **'DISCORD'**
  String get linksKindDiscord;

  /// Link item title for GitHub repository
  ///
  /// In en, this message translates to:
  /// **'GitHub Repository'**
  String get linksGithubRepo;

  /// Link item subtitle for GitHub repository
  ///
  /// In en, this message translates to:
  /// **'Source code & issues'**
  String get linksGithubDesc;

  /// Link kind badge label for GitHub links
  ///
  /// In en, this message translates to:
  /// **'GITHUB'**
  String get linksKindGithub;

  /// Link item title for GitHub releases page
  ///
  /// In en, this message translates to:
  /// **'GitHub Releases'**
  String get linksGithubReleases;

  /// Link item subtitle for GitHub releases
  ///
  /// In en, this message translates to:
  /// **'Download latest APK'**
  String get linksGithubReleasesDesc;

  /// Link kind badge label for download links
  ///
  /// In en, this message translates to:
  /// **'DOWNLOAD'**
  String get linksKindDownload;

  /// Link item title for YouTube channel
  ///
  /// In en, this message translates to:
  /// **'YouTube Channel'**
  String get linksYoutubeChannel;

  /// Link item subtitle showing the YouTube handle
  ///
  /// In en, this message translates to:
  /// **'@retired64'**
  String get linksYoutubeHandle;

  /// Link kind badge label for YouTube links
  ///
  /// In en, this message translates to:
  /// **'YOUTUBE'**
  String get linksKindYoutube;

  /// Link item subtitle for the community Discord server
  ///
  /// In en, this message translates to:
  /// **'Community & support server'**
  String get linksDiscordCommunity;

  /// Link item title for wiki and guides
  ///
  /// In en, this message translates to:
  /// **'Wiki & Guides'**
  String get linksWiki;

  /// Link item subtitle for wiki and guides
  ///
  /// In en, this message translates to:
  /// **'Installation guides & docs'**
  String get linksWikiDesc;

  /// Link kind badge label for wiki links
  ///
  /// In en, this message translates to:
  /// **'WIKI'**
  String get linksKindWiki;

  /// Link item title for tools and add-ons
  ///
  /// In en, this message translates to:
  /// **'Tools & Add-ons'**
  String get linksTools;

  /// Link item subtitle for tools and add-ons
  ///
  /// In en, this message translates to:
  /// **'How to make mods & resources'**
  String get linksToolsDesc;

  /// Link kind badge label for tools links
  ///
  /// In en, this message translates to:
  /// **'TOOLS'**
  String get linksKindTools;

  /// Snackbar error message when a URL fails to open
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get linksCouldNotOpen;

  /// Snackbar message when a link is copied to clipboard
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linksCopied;

  /// Disclaimer screen title
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get disclaimerTitle;

  /// Disclaimer screen section header for developer contact
  ///
  /// In en, this message translates to:
  /// **'Developer contact'**
  String get disclaimerDeveloperContact;

  /// Disclaimer screen text inviting users to reach out on Discord
  ///
  /// In en, this message translates to:
  /// **'Reach me on my Discord server'**
  String get disclaimerDiscordReach;

  /// Disclaimer screen label for the Discord link
  ///
  /// In en, this message translates to:
  /// **'Discord'**
  String get disclaimerDiscord;

  /// Disclaimer screen footer text showing app version
  ///
  /// In en, this message translates to:
  /// **'v{version} · for personal use · Unofficial'**
  String disclaimerFooter(String version);

  /// Disclaimer screen banner text marking the app as unofficial
  ///
  /// In en, this message translates to:
  /// **'Unofficial Fan-Made'**
  String get disclaimerUnofficialBanner;

  /// Disclaimer screen app subtitle
  ///
  /// In en, this message translates to:
  /// **'SM64CoopDX Mods Manager'**
  String get disclaimerAppSubtitle;

  /// Disclaimer screen warning banner body text
  ///
  /// In en, this message translates to:
  /// **'SM64CDPY is independent software. Questions, technical issues, and requests concerning this app must be directed to the SM64CDPY developer, not to Nintendo, the SM64CoopDX team, or the listed mod authors.'**
  String get disclaimerWarningBody;

  /// Disclaimer screen error message when a link cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open the link'**
  String get disclaimerCouldNotOpenLink;

  /// Disclaimer screen section header for personal purpose
  ///
  /// In en, this message translates to:
  /// **'About this app'**
  String get disclaimerSectionPersonalPurpose;

  /// Disclaimer screen body text for the personal purpose section
  ///
  /// In en, this message translates to:
  /// **'SM64CDPY is an independent Android catalog and manager for community-created SM64CoopDX mods. It helps users browse, download, organize, and install compatible content in folders selected by the user. The app does not distribute or install Super Mario 64, ROM files, SM64CoopDX, or Android builds of SM64CoopDX. It does not request, verify, or provide instructions for obtaining any game file.'**
  String get disclaimerBodyPersonalPurpose;

  /// Disclaimer screen section header for no official affiliation
  ///
  /// In en, this message translates to:
  /// **'No official affiliation'**
  String get disclaimerSectionNoAffiliation;

  /// Disclaimer screen body text for the no affiliation section
  ///
  /// In en, this message translates to:
  /// **'This project is not associated with, endorsed by, or approved by Nintendo, the SM64CoopDX team, or the listed mod authors. Product names and trademarks identify compatibility only. Mod titles, descriptions, images, files, and other credited material remain the property of their respective authors or rights holders.'**
  String get disclaimerBodyNoAffiliation;

  /// Disclaimer screen section header for data source
  ///
  /// In en, this message translates to:
  /// **'Data source'**
  String get disclaimerSectionDataSource;

  /// Disclaimer screen body text for the data source section
  ///
  /// In en, this message translates to:
  /// **'The main catalog presents public community listings from Coop DX Mods (mods.sm64coopdx.com) while preserving the published author, title, dates, versions, and source. SM64CDPY provides a mobile interface and retrieves downloads from the source made available for each resource; catalog inclusion does not imply ownership or official endorsement by SM64CDPY.'**
  String get disclaimerBodyDataSource;

  /// Disclaimer screen section header for exclusive sections
  ///
  /// In en, this message translates to:
  /// **'Curated sections (VIP · DynOS · Touch Controls)'**
  String get disclaimerSectionExclusive;

  /// Disclaimer screen body text for the exclusive sections
  ///
  /// In en, this message translates to:
  /// **'In v{version}, VIP Mods, DynOS packs, Touch Control layouts, OMM Rebirth, and Render96 may use independently curated sources. Whenever content was not created by the SM64CDPY developer, its credited creator retains authorship. These sections are separate from the main Coop DX Mods catalog and are not official Nintendo or SM64CoopDX services.'**
  String disclaimerBodyExclusive(Object version);

  /// Disclaimer section header for accounts and locally stored app data
  ///
  /// In en, this message translates to:
  /// **'Accounts and local data'**
  String get disclaimerSectionLocalData;

  /// Disclaimer body explaining the current absence of accounts and local storage
  ///
  /// In en, this message translates to:
  /// **'SM64CDPY currently does not create user accounts. Favorites, installation history, selected folders, and app preferences are stored locally on the device. Removing the app or clearing its data may remove this information.'**
  String get disclaimerBodyLocalData;

  /// Disclaimer section header for third-party network services
  ///
  /// In en, this message translates to:
  /// **'External services'**
  String get disclaimerSectionExternalServices;

  /// Disclaimer body describing external content and download services
  ///
  /// In en, this message translates to:
  /// **'Browsing, refreshing catalogs, opening links, and downloading content may connect to services such as Coop DX Mods, GitHub, Google Drive, Dropbox, or GameBanana. Those services operate under their own terms and privacy practices, which SM64CDPY does not control.'**
  String get disclaimerBodyExternalServices;

  /// Disclaimer screen section header for bugs and suggestions
  ///
  /// In en, this message translates to:
  /// **'Support and content corrections'**
  String get disclaimerSectionBugs;

  /// Disclaimer screen body text for the bugs and suggestions section
  ///
  /// In en, this message translates to:
  /// **'Contact the SM64CDPY developer if you find an app issue, incorrect attribution, outdated information, or content that should be corrected or removed. Please include the mod title and source when applicable. App-related requests should not be directed to Nintendo, the SM64CoopDX team, or mod authors.'**
  String get disclaimerBodyBugs;

  /// Section header for the VIP mods list
  ///
  /// In en, this message translates to:
  /// **'EXCLUSIVE CONTENT'**
  String get vipSectionHeader;

  /// Section header for the DynOS list
  ///
  /// In en, this message translates to:
  /// **'CUSTOM DYNOS'**
  String get dynosSectionHeader;

  /// Section header for the touch controls list
  ///
  /// In en, this message translates to:
  /// **'MOBILE LAYOUTS'**
  String get touchSectionHeader;

  /// Section header for the OMM Rebirth mods list
  ///
  /// In en, this message translates to:
  /// **'OMM REBIRTH MODS'**
  String get ommSectionHeader;

  /// Shared label showing the count of mods
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} MOD} other{{count} MODS}}'**
  String sharedModCount(int count);

  /// Settings tile label for the DynOS folder picker
  ///
  /// In en, this message translates to:
  /// **'DynOS and Touch Controls folder'**
  String get settingsDynosFolder;

  /// Prompt text to select the DynOS packs directory
  ///
  /// In en, this message translates to:
  /// **'Select DynOS folder'**
  String get settingsSelectDynosFolder;

  /// Hint text explaining how to change or clear the DynOS folder
  ///
  /// In en, this message translates to:
  /// **'Tap to change · Long-press to clear'**
  String get settingsDynosFolderHint;

  /// Description subtitle on the DynOS folder settings tile
  ///
  /// In en, this message translates to:
  /// **'Choose where to install DynOS and Touch Controls packs'**
  String get settingsDynosFolderDesc;

  /// Snackbar message shown after selecting the DynOS folder
  ///
  /// In en, this message translates to:
  /// **'DynOS and Touch Controls folder selected. Both content types will be installed here.'**
  String get settingsDynosFolderSelected;

  /// Confirmation dialog title before clearing the DynOS folder selection
  ///
  /// In en, this message translates to:
  /// **'CLEAR DYNOS FOLDER?'**
  String get settingsClearDynosFolderTitle;

  /// Confirmation dialog body before clearing the DynOS folder selection
  ///
  /// In en, this message translates to:
  /// **'You will need to select the folder again before installing DynOS or Touch Control packs.'**
  String get settingsClearDynosFolderBody;

  /// Snackbar message shown after the DynOS folder selection is cleared
  ///
  /// In en, this message translates to:
  /// **'DynOS folder selection cleared.'**
  String get settingsDynosFolderCleared;

  /// Settings tile label for the language selector
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageMode;

  /// Language option to follow the device's system language
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get languageFollowSystem;

  /// Language name for English (endonym)
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Language name for Spanish (endonym)
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// Language name for Brazilian Portuguese (endonym)
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get languagePortuguese;

  /// Placeholder text for the search field in the floating overlay
  ///
  /// In en, this message translates to:
  /// **'SEARCH...'**
  String get overlaySearchHint;

  /// No description provided for @overlayChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose a file'**
  String get overlayChooseFile;

  /// No description provided for @overlayFileFallback.
  ///
  /// In en, this message translates to:
  /// **'File {number}'**
  String overlayFileFallback(int number);

  /// Toast shown in the floating overlay when the download bridge does not respond
  ///
  /// In en, this message translates to:
  /// **'No response — open the main app once, then try again'**
  String get overlayNoResponse;

  /// Error toast shown in the overlay when no destination folder has been selected
  ///
  /// In en, this message translates to:
  /// **'Select a folder first (Settings)'**
  String get overlaySelectFolder;

  /// Error toast shown in the overlay when auto-install is disabled
  ///
  /// In en, this message translates to:
  /// **'Enable auto-install first (Settings)'**
  String get overlayEnableAutoInstall;

  /// Error toast shown in the overlay when a download fails
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get overlayDownloadFailed;

  /// Label below the progress bar in the overlay mod tile during download/install
  ///
  /// In en, this message translates to:
  /// **'TAP TO CANCEL'**
  String get overlayTapToCancel;

  /// Status text shown in the overlay mod tile title during installation
  ///
  /// In en, this message translates to:
  /// **'Installing...'**
  String get overlayInstalling;

  /// Status text shown in the overlay mod tile title while waiting for the bridge
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get overlayConnecting;

  /// Empty state label shown in the overlay when search/filter yields no mods
  ///
  /// In en, this message translates to:
  /// **'NO RESULTS'**
  String get overlayNoResults;

  /// Error state label shown in the overlay when content fails to load
  ///
  /// In en, this message translates to:
  /// **'ERROR'**
  String get overlayError;

  /// Settings tile title when the floating overlay bubble is active
  ///
  /// In en, this message translates to:
  /// **'Chathead active'**
  String get settingsOverlayActive;

  /// Settings tile title when the floating overlay bubble is not active
  ///
  /// In en, this message translates to:
  /// **'Floating overlay'**
  String get settingsOverlayInactive;

  /// Settings tile subtitle when the floating overlay is active
  ///
  /// In en, this message translates to:
  /// **'Tap to hide the bubble'**
  String get settingsOverlayActiveDesc;

  /// Settings tile subtitle when the floating overlay is not active
  ///
  /// In en, this message translates to:
  /// **'Tap to show the bubble over the game'**
  String get settingsOverlayInactiveDesc;

  /// Drawer navigation label for the Render96 screen
  ///
  /// In en, this message translates to:
  /// **'Render96'**
  String get navRender96;

  /// Title shown on the Render96 screen
  ///
  /// In en, this message translates to:
  /// **'RENDER96'**
  String get render96Title;

  /// Section header on the Render96 screen
  ///
  /// In en, this message translates to:
  /// **'EXCLUSIVE COLLECTION'**
  String get render96SectionHeader;

  /// Empty state title on the Render96 screen
  ///
  /// In en, this message translates to:
  /// **'COMING SOON'**
  String get render96Empty;

  /// Empty state hint on the Render96 screen
  ///
  /// In en, this message translates to:
  /// **'New Render96 content will appear here.'**
  String get render96EmptyHint;

  /// Error message shown on the Render96 screen when content fails to load
  ///
  /// In en, this message translates to:
  /// **'FAILED TO LOAD'**
  String get render96FailedToLoad;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'LIBRARY'**
  String get libraryTitle;

  /// No description provided for @libraryInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get libraryInstalled;

  /// No description provided for @libraryUpdates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get libraryUpdates;

  /// No description provided for @libraryRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get libraryRecent;

  /// No description provided for @libraryViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get libraryViewAll;

  /// No description provided for @libraryRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh library'**
  String get libraryRefresh;

  /// No description provided for @libraryAllSections.
  ///
  /// In en, this message translates to:
  /// **'All sections'**
  String get libraryAllSections;

  /// No description provided for @libraryAllDestinations.
  ///
  /// In en, this message translates to:
  /// **'All folders'**
  String get libraryAllDestinations;

  /// No description provided for @libraryModsDestination.
  ///
  /// In en, this message translates to:
  /// **'Mods folder'**
  String get libraryModsDestination;

  /// No description provided for @libraryDynosDestination.
  ///
  /// In en, this message translates to:
  /// **'DynOS folder'**
  String get libraryDynosDestination;

  /// No description provided for @libraryPresent.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get libraryPresent;

  /// No description provided for @libraryMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get libraryMissing;

  /// No description provided for @libraryPermissionRevoked.
  ///
  /// In en, this message translates to:
  /// **'Permission required'**
  String get libraryPermissionRevoked;

  /// No description provided for @libraryFolderNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Folder required'**
  String get libraryFolderNotSelected;

  /// No description provided for @libraryNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get libraryNotVerified;

  /// No description provided for @libraryOpenSource.
  ///
  /// In en, this message translates to:
  /// **'OPEN CONTENT'**
  String get libraryOpenSource;

  /// No description provided for @libraryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'NO INSTALLATIONS YET'**
  String get libraryEmptyTitle;

  /// No description provided for @libraryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Mods installed by SM64CDPY will appear here.'**
  String get libraryEmptyBody;

  /// No description provided for @libraryUpdatesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'NO KNOWN UPDATES'**
  String get libraryUpdatesEmptyTitle;

  /// No description provided for @libraryUpdatesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Updates confirmed by the catalog will appear here. You can still check each content section.'**
  String get libraryUpdatesEmptyBody;

  /// No description provided for @libraryDiscoveryHeaderIdentified.
  ///
  /// In en, this message translates to:
  /// **'Header identified'**
  String get libraryDiscoveryHeaderIdentified;

  /// No description provided for @libraryDiscoveryProbable.
  ///
  /// In en, this message translates to:
  /// **'Probable mod'**
  String get libraryDiscoveryProbable;

  /// No description provided for @libraryDiscoveryUnlinked.
  ///
  /// In en, this message translates to:
  /// **'Unlinked Lua'**
  String get libraryDiscoveryUnlinked;

  /// No description provided for @libraryErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'LIBRARY UNAVAILABLE'**
  String get libraryErrorTitle;

  /// No description provided for @libraryErrorBody.
  ///
  /// In en, this message translates to:
  /// **'The installation history could not be read. Try again without changing your game files.'**
  String get libraryErrorBody;

  /// No description provided for @libraryPartialWarning.
  ///
  /// In en, this message translates to:
  /// **'Some records could not be read. Valid installations are still shown.'**
  String get libraryPartialWarning;

  /// No description provided for @libraryCatalogLoading.
  ///
  /// In en, this message translates to:
  /// **'Checking the current catalog…'**
  String get libraryCatalogLoading;

  /// No description provided for @libraryCatalogError.
  ///
  /// In en, this message translates to:
  /// **'The catalog could not be checked. Installed content is still available.'**
  String get libraryCatalogError;

  /// Installed and available versions shown on a Library update card
  ///
  /// In en, this message translates to:
  /// **'{installed} → {available}'**
  String libraryUpdateVersions(String installed, String available);

  /// No description provided for @libraryEventInstall.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get libraryEventInstall;

  /// No description provided for @libraryEventUpdate.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get libraryEventUpdate;

  /// No description provided for @libraryEventReinstall.
  ///
  /// In en, this message translates to:
  /// **'Reinstalled'**
  String get libraryEventReinstall;

  /// No description provided for @libraryEventReplaced.
  ///
  /// In en, this message translates to:
  /// **'Replaced by a newer version'**
  String get libraryEventReplaced;

  /// No description provided for @libraryForgetAction.
  ///
  /// In en, this message translates to:
  /// **'FORGET INSTALLATION'**
  String get libraryForgetAction;

  /// No description provided for @libraryForgetTitle.
  ///
  /// In en, this message translates to:
  /// **'FORGET THIS INSTALLATION?'**
  String get libraryForgetTitle;

  /// No description provided for @libraryForgetBody.
  ///
  /// In en, this message translates to:
  /// **'SM64CDPY will remove this item from the Library, but it will not delete any game files.'**
  String get libraryForgetBody;

  /// No description provided for @libraryForgetConfirm.
  ///
  /// In en, this message translates to:
  /// **'FORGET'**
  String get libraryForgetConfirm;

  /// No description provided for @libraryRemoveHistoryAction.
  ///
  /// In en, this message translates to:
  /// **'REMOVE FROM HISTORY'**
  String get libraryRemoveHistoryAction;

  /// No description provided for @libraryRemoveHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'REMOVE THIS EVENT?'**
  String get libraryRemoveHistoryTitle;

  /// No description provided for @libraryRemoveHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'Only this history entry will be removed. The current installation and game files will not change.'**
  String get libraryRemoveHistoryBody;

  /// No description provided for @libraryRemoveHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'REMOVE'**
  String get libraryRemoveHistoryConfirm;

  /// No description provided for @libraryMaintenanceError.
  ///
  /// In en, this message translates to:
  /// **'The Library could not be updated. Try again.'**
  String get libraryMaintenanceError;

  /// No description provided for @detailOpenExternalFolder.
  ///
  /// In en, this message translates to:
  /// **'OPEN SOURCE FOLDER'**
  String get detailOpenExternalFolder;

  /// No description provided for @detailSourceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This version has no downloadable file available right now.'**
  String get detailSourceUnavailable;

  /// No description provided for @detailViewDiscussion.
  ///
  /// In en, this message translates to:
  /// **'VIEW COMMUNITY DISCUSSION'**
  String get detailViewDiscussion;

  /// No description provided for @settingsInterfaceTheme.
  ///
  /// In en, this message translates to:
  /// **'Interface theme'**
  String get settingsInterfaceTheme;

  /// No description provided for @settingsInterfaceThemeDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose an included design. Applies to the app; the floating panel keeps its dark design.'**
  String get settingsInterfaceThemeDesc;

  /// No description provided for @themeMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get themeMinimal;

  /// No description provided for @themeRetroManga.
  ///
  /// In en, this message translates to:
  /// **'Retro Manga'**
  String get themeRetroManga;

  /// No description provided for @themeMinishCap.
  ///
  /// In en, this message translates to:
  /// **'The Minish Cap'**
  String get themeMinishCap;

  /// No description provided for @themeMarioKart64.
  ///
  /// In en, this message translates to:
  /// **'Mario Kart 64'**
  String get themeMarioKart64;

  /// No description provided for @themeMario64.
  ///
  /// In en, this message translates to:
  /// **'Mario 64'**
  String get themeMario64;

  /// No description provided for @themeSm64Intro.
  ///
  /// In en, this message translates to:
  /// **'SM64 Intro'**
  String get themeSm64Intro;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get themeModeSystem;

  /// No description provided for @themeSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the appearance. Try again.'**
  String get themeSaveFailed;

  /// No description provided for @themeSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving appearance'**
  String get themeSaving;

  /// No description provided for @gameModsTitle.
  ///
  /// In en, this message translates to:
  /// **'Game mods'**
  String get gameModsTitle;

  /// No description provided for @gameModsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose mods for the next game start'**
  String get gameModsSubtitle;

  /// No description provided for @gameModsHint.
  ///
  /// In en, this message translates to:
  /// **'Close the game before making changes. These switches configure Lua mods and DynOS/Touch Controls packs for the next start.'**
  String get gameModsHint;

  /// No description provided for @gameModsSelectHint.
  ///
  /// In en, this message translates to:
  /// **'Select the game’s user folder containing sm64config.txt and mods.'**
  String get gameModsSelectHint;

  /// No description provided for @gameModsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Close the game first. Apply this selection for its next start?'**
  String get gameModsConfirm;

  /// No description provided for @gameModsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get gameModsCancel;

  /// No description provided for @gameModsApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get gameModsApply;

  /// No description provided for @gameModsSelect.
  ///
  /// In en, this message translates to:
  /// **'Select user folder'**
  String get gameModsSelect;

  /// No description provided for @gameModsDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get gameModsDisconnect;

  /// No description provided for @gameModsConflict.
  ///
  /// In en, this message translates to:
  /// **'The configuration changed or another enabled mod is incompatible. Refresh and try again.'**
  String get gameModsConflict;

  /// No description provided for @gameModsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Cannot safely enable this mod. Check its structure and metadata, or disable an incompatible mod.'**
  String get gameModsBlocked;

  /// No description provided for @gameModsMismatch.
  ///
  /// In en, this message translates to:
  /// **'This user folder does not match your selected mods folder. Choose the same game installation.'**
  String get gameModsMismatch;

  /// No description provided for @gameModsWriteError.
  ///
  /// In en, this message translates to:
  /// **'The write could not be confirmed. Close the game and restore the previous configuration if necessary.'**
  String get gameModsWriteError;

  /// No description provided for @gameModsFormat.
  ///
  /// In en, this message translates to:
  /// **'The configuration or folder exceeds the supported limits or has an unsupported format. No change was applied.'**
  String get gameModsFormat;

  /// No description provided for @gameModsAccess.
  ///
  /// In en, this message translates to:
  /// **'Configuration unavailable. Check that user contains sm64config.txt and mods, and select the folder again with read/write access.'**
  String get gameModsAccess;

  /// No description provided for @gameModsRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore previous configuration'**
  String get gameModsRestore;

  /// No description provided for @gameModsRestoreConfirm.
  ///
  /// In en, this message translates to:
  /// **'With the game closed, replace the configuration with the private backup from before the last edit? This also restores its other settings.'**
  String get gameModsRestoreConfirm;

  /// No description provided for @gameModsInstalling.
  ///
  /// In en, this message translates to:
  /// **'Wait for downloads and installations to finish before changing game mods.'**
  String get gameModsInstalling;

  /// No description provided for @gameModsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No compatible Lua mods were found in the game folders.'**
  String get gameModsEmpty;

  /// No description provided for @gameModsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled for next start'**
  String get gameModsEnabled;

  /// No description provided for @gameModsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled for next start'**
  String get gameModsDisabled;

  /// No description provided for @gameModsMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get gameModsMore;

  /// No description provided for @gameModsSize.
  ///
  /// In en, this message translates to:
  /// **'This mod reaches the game’s 35 MiB size limit and cannot be enabled.'**
  String get gameModsSize;

  /// No description provided for @gameModsSaved.
  ///
  /// In en, this message translates to:
  /// **'Selection saved and verified for the next game start.'**
  String get gameModsSaved;

  /// No description provided for @gameModsManage.
  ///
  /// In en, this message translates to:
  /// **'Manage game folder'**
  String get gameModsManage;

  /// Confirmed enabled game mods versus all controllable mods
  ///
  /// In en, this message translates to:
  /// **'{enabled} of {total} enabled'**
  String gameModsCount(int enabled, int total);

  /// No description provided for @gameModsSearch.
  ///
  /// In en, this message translates to:
  /// **'Search mods, authors, categories…'**
  String get gameModsSearch;

  /// No description provided for @gameModsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get gameModsAll;

  /// No description provided for @gameModsEnabledFilter.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get gameModsEnabledFilter;

  /// No description provided for @gameModsDisabledFilter.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get gameModsDisabledFilter;

  /// No description provided for @gameModsNoResults.
  ///
  /// In en, this message translates to:
  /// **'No mods match this search or filter.'**
  String get gameModsNoResults;

  /// No description provided for @gameModsClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get gameModsClearSearch;

  /// No description provided for @gameModsDetails.
  ///
  /// In en, this message translates to:
  /// **'Mod details'**
  String get gameModsDetails;

  /// No description provided for @gameModsCloseDetails.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get gameModsCloseDetails;

  /// No description provided for @marioRomTitle.
  ///
  /// In en, this message translates to:
  /// **'Original game resources'**
  String get marioRomTitle;

  /// No description provided for @marioRomBuiltIn.
  ///
  /// In en, this message translates to:
  /// **'ROM not selected'**
  String get marioRomBuiltIn;

  /// No description provided for @marioRomReady.
  ///
  /// In en, this message translates to:
  /// **'Original interface ready'**
  String get marioRomReady;

  /// No description provided for @marioRomDescription.
  ///
  /// In en, this message translates to:
  /// **'Mario themes use the ROM in your connected user folder. Images and fonts are prepared privately once and reused later. No separate ROM selection is needed.'**
  String get marioRomDescription;

  /// No description provided for @marioRomImport.
  ///
  /// In en, this message translates to:
  /// **'Prepare from game folder'**
  String get marioRomImport;

  /// No description provided for @marioRomPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing game resources…'**
  String get marioRomPreparing;

  /// No description provided for @marioRomCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel import'**
  String get marioRomCancel;

  /// No description provided for @marioRomRemove.
  ///
  /// In en, this message translates to:
  /// **'Use built-in design'**
  String get marioRomRemove;

  /// No description provided for @marioRomUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This ROM is not supported. Select an unmodified US .z64 ROM. Your previous design is still available.'**
  String get marioRomUnsupported;

  /// No description provided for @marioRomFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read or save the resources. Select the file again and check available storage. Your previous design is still available.'**
  String get marioRomFailed;

  /// No description provided for @marioRomSuccess.
  ///
  /// In en, this message translates to:
  /// **'Original game resources are ready.'**
  String get marioRomSuccess;

  /// No description provided for @marioRomUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Select the ROM again to upgrade the original interface'**
  String get marioRomUpgrade;

  /// No description provided for @gameFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect SM64CoopDX'**
  String get gameFolderTitle;

  /// No description provided for @gameFolderSummary.
  ///
  /// In en, this message translates to:
  /// **'Choose the main game folder once to find mods and DynOS packs both inside and outside user, plus the ROM for Mario themes.'**
  String get gameFolderSummary;

  /// No description provided for @gameFolderGuide.
  ///
  /// In en, this message translates to:
  /// **'Choose the main com.maniscat2.sm64coopdx folder, the one containing user. We will check mods and dynos/packs both here and inside user. Configuration and ROM stay in user; new installations also go inside user. Select the main folder, not user or an individual file.'**
  String get gameFolderGuide;

  /// No description provided for @gameFolderChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose game folder'**
  String get gameFolderChoose;

  /// No description provided for @gameFolderLater.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get gameFolderLater;

  /// No description provided for @gameFolderConnected.
  ///
  /// In en, this message translates to:
  /// **'Game connected'**
  String get gameFolderConnected;

  /// No description provided for @gameFolderResolved.
  ///
  /// In en, this message translates to:
  /// **'Library: mods, user/mods, dynos/packs and user/dynos/packs. New installations: user/mods and user/dynos/packs.'**
  String get gameFolderResolved;

  /// No description provided for @gameFolderConfigReady.
  ///
  /// In en, this message translates to:
  /// **'Game mod settings found.'**
  String get gameFolderConfigReady;

  /// No description provided for @gameFolderConfigMissing.
  ///
  /// In en, this message translates to:
  /// **'Open the game once to create its mod settings. Downloads and themes remain available.'**
  String get gameFolderConfigMissing;

  /// No description provided for @gameFolderRomFound.
  ///
  /// In en, this message translates to:
  /// **'Game ROM found. Mario themes can prepare their resources when selected.'**
  String get gameFolderRomFound;

  /// No description provided for @gameFolderRomMissing.
  ///
  /// In en, this message translates to:
  /// **'No compatible ROM was found in user. Open SM64CoopDX and set up its ROM, then try again.'**
  String get gameFolderRomMissing;

  /// No description provided for @gameFolderChange.
  ///
  /// In en, this message translates to:
  /// **'Change game folder'**
  String get gameFolderChange;

  /// No description provided for @gameFolderInvalid.
  ///
  /// In en, this message translates to:
  /// **'Choose the main game folder containing user, normally com.maniscat2.sm64coopdx. Open the game once if its user folder is not ready.'**
  String get gameFolderInvalid;

  /// No description provided for @gameFolderAccessLost.
  ///
  /// In en, this message translates to:
  /// **'The game folder is unavailable. Choose it again to reconnect.'**
  String get gameFolderAccessLost;

  /// No description provided for @gameFolderDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect game'**
  String get gameFolderDisconnect;

  /// No description provided for @gameFolderDisconnectBody.
  ///
  /// In en, this message translates to:
  /// **'Stop using this folder for mods, DynOS and ROM detection. Your game files, installed mods and prepared theme resources will stay on the device.'**
  String get gameFolderDisconnectBody;

  /// No description provided for @gameFolderPrepareTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare Mario theme'**
  String get gameFolderPrepareTitle;

  /// No description provided for @gameFolderPrepareBody.
  ///
  /// In en, this message translates to:
  /// **'We will read the ROM in your connected game folder and prepare the theme’s images and fonts. This is done once; the ROM and game configuration stay unchanged.'**
  String get gameFolderPrepareBody;

  /// No description provided for @gameFolderPrepare.
  ///
  /// In en, this message translates to:
  /// **'Prepare theme'**
  String get gameFolderPrepare;

  /// No description provided for @gameFolderBusy.
  ///
  /// In en, this message translates to:
  /// **'Wait for downloads and installations to finish before changing the game folder.'**
  String get gameFolderBusy;

  /// No description provided for @gameModsLuaType.
  ///
  /// In en, this message translates to:
  /// **'Lua mods'**
  String get gameModsLuaType;

  /// No description provided for @gameModsDynosType.
  ///
  /// In en, this message translates to:
  /// **'DynOS / Touch Controls'**
  String get gameModsDynosType;

  /// No description provided for @gameFolderUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Access is limited to user. Choose the main game folder to include mods and DynOS packs outside user too.'**
  String get gameFolderUpgrade;

  /// No description provided for @gameDynosEmpty.
  ///
  /// In en, this message translates to:
  /// **'No DynOS / Touch Controls pack folders were found in the game folders.'**
  String get gameDynosEmpty;

  /// No description provided for @gameDynosSearch.
  ///
  /// In en, this message translates to:
  /// **'Search DynOS / Touch Controls packs…'**
  String get gameDynosSearch;

  /// No description provided for @navPlayer.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get navPlayer;

  /// No description provided for @playerTitle.
  ///
  /// In en, this message translates to:
  /// **'PLAYER'**
  String get playerTitle;

  /// No description provided for @playerCharacter.
  ///
  /// In en, this message translates to:
  /// **'CHARACTER'**
  String get playerCharacter;

  /// No description provided for @player3DLoading.
  ///
  /// In en, this message translates to:
  /// **'Building your character from the game…'**
  String get player3DLoading;

  /// No description provided for @player3DUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The 3D preview is unavailable. Check that SM64CoopDX and a supported US ROM are connected.'**
  String get player3DUnavailable;

  /// No description provided for @playerName.
  ///
  /// In en, this message translates to:
  /// **'Player name'**
  String get playerName;

  /// No description provided for @playerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name shown in SM64CoopDX'**
  String get playerNameHint;

  /// No description provided for @playerCloseGameHint.
  ///
  /// In en, this message translates to:
  /// **'Close SM64CoopDX before applying. Changes are used on the next start.'**
  String get playerCloseGameHint;

  /// No description provided for @playerPresets.
  ///
  /// In en, this message translates to:
  /// **'PALETTES'**
  String get playerPresets;

  /// No description provided for @playerParts.
  ///
  /// In en, this message translates to:
  /// **'CHARACTER COLORS'**
  String get playerParts;

  /// No description provided for @playerUnsavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get playerUnsavedTitle;

  /// No description provided for @playerUnsavedBody.
  ///
  /// In en, this message translates to:
  /// **'Your player colors or name have not been applied to the game.'**
  String get playerUnsavedBody;

  /// No description provided for @playerKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get playerKeepEditing;

  /// No description provided for @playerDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get playerDiscard;

  /// No description provided for @playerDeletePreset.
  ///
  /// In en, this message translates to:
  /// **'Delete palette?'**
  String get playerDeletePreset;

  /// No description provided for @playerDeletePresetBody.
  ///
  /// In en, this message translates to:
  /// **'Delete your palette “{name}”?'**
  String playerDeletePresetBody(String name);

  /// No description provided for @playerCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get playerCancel;

  /// No description provided for @playerDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get playerDelete;

  /// No description provided for @playerConflict.
  ///
  /// In en, this message translates to:
  /// **'The game configuration changed. Reload it before applying your profile.'**
  String get playerConflict;

  /// No description provided for @playerInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid name and colors. Names cannot contain spaces and can use up to 63 UTF-8 bytes.'**
  String get playerInvalid;

  /// No description provided for @playerPresetExists.
  ///
  /// In en, this message translates to:
  /// **'A palette with this name already exists.'**
  String get playerPresetExists;

  /// No description provided for @playerAccessError.
  ///
  /// In en, this message translates to:
  /// **'The player configuration is unavailable. Check the connected game folder and its permission.'**
  String get playerAccessError;

  /// No description provided for @playerSavePreset.
  ///
  /// In en, this message translates to:
  /// **'Save palette'**
  String get playerSavePreset;

  /// No description provided for @playerPresetName.
  ///
  /// In en, this message translates to:
  /// **'Palette name'**
  String get playerPresetName;

  /// No description provided for @playerSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get playerSave;

  /// No description provided for @playerOverwritePreset.
  ///
  /// In en, this message translates to:
  /// **'Replace your palette “{name}”?'**
  String playerOverwritePreset(String name);

  /// No description provided for @playerOverwrite.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get playerOverwrite;

  /// No description provided for @playerPresetSaved.
  ///
  /// In en, this message translates to:
  /// **'Palette saved for SM64CoopDX.'**
  String get playerPresetSaved;

  /// No description provided for @playerApplied.
  ///
  /// In en, this message translates to:
  /// **'Player profile saved and verified for the next game start.'**
  String get playerApplied;

  /// No description provided for @playerConnectGame.
  ///
  /// In en, this message translates to:
  /// **'Connect the main SM64CoopDX folder to edit the player.'**
  String get playerConnectGame;

  /// No description provided for @playerMissingConfig.
  ///
  /// In en, this message translates to:
  /// **'Open SM64CoopDX once to create user/sm64config.txt.'**
  String get playerMissingConfig;

  /// No description provided for @playerRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get playerRetry;

  /// No description provided for @playerHex.
  ///
  /// In en, this message translates to:
  /// **'Hex color'**
  String get playerHex;

  /// No description provided for @playerRed.
  ///
  /// In en, this message translates to:
  /// **'R'**
  String get playerRed;

  /// No description provided for @playerGreen.
  ///
  /// In en, this message translates to:
  /// **'G'**
  String get playerGreen;

  /// No description provided for @playerBlue.
  ///
  /// In en, this message translates to:
  /// **'B'**
  String get playerBlue;

  /// No description provided for @playerReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get playerReset;

  /// No description provided for @playerApply.
  ///
  /// In en, this message translates to:
  /// **'Apply to game'**
  String get playerApply;

  /// No description provided for @playerPants.
  ///
  /// In en, this message translates to:
  /// **'Overalls'**
  String get playerPants;

  /// No description provided for @playerShirt.
  ///
  /// In en, this message translates to:
  /// **'Shirt'**
  String get playerShirt;

  /// No description provided for @playerGloves.
  ///
  /// In en, this message translates to:
  /// **'Gloves'**
  String get playerGloves;

  /// No description provided for @playerShoes.
  ///
  /// In en, this message translates to:
  /// **'Shoes'**
  String get playerShoes;

  /// No description provided for @playerHair.
  ///
  /// In en, this message translates to:
  /// **'Hair'**
  String get playerHair;

  /// No description provided for @playerSkin.
  ///
  /// In en, this message translates to:
  /// **'Skin'**
  String get playerSkin;

  /// No description provided for @playerCap.
  ///
  /// In en, this message translates to:
  /// **'Cap'**
  String get playerCap;

  /// No description provided for @playerEmblem.
  ///
  /// In en, this message translates to:
  /// **'Emblem'**
  String get playerEmblem;

  /// No description provided for @playerRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore previous configuration'**
  String get playerRestore;

  /// No description provided for @playerRestoreBody.
  ///
  /// In en, this message translates to:
  /// **'With SM64CoopDX closed, restore the private backup from before the last mod or player edit? This restores the whole configuration.'**
  String get playerRestoreBody;

  /// No description provided for @playerRestored.
  ///
  /// In en, this message translates to:
  /// **'Previous game configuration restored.'**
  String get playerRestored;

  /// No description provided for @retroAccentTitle.
  ///
  /// In en, this message translates to:
  /// **'Interface accent'**
  String get retroAccentTitle;

  /// No description provided for @retroAccentDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the highlight color for Retro Manga or Mario Kart 64. MK64 also coordinates its background, panels and racing grid with it.'**
  String get retroAccentDescription;

  /// No description provided for @retroAccentCyan.
  ///
  /// In en, this message translates to:
  /// **'Cyan'**
  String get retroAccentCyan;

  /// No description provided for @retroAccentBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get retroAccentBlue;

  /// No description provided for @retroAccentViolet.
  ///
  /// In en, this message translates to:
  /// **'Violet'**
  String get retroAccentViolet;

  /// No description provided for @retroAccentPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get retroAccentPink;

  /// No description provided for @retroAccentCoral.
  ///
  /// In en, this message translates to:
  /// **'Coral'**
  String get retroAccentCoral;

  /// No description provided for @retroAccentAmber.
  ///
  /// In en, this message translates to:
  /// **'Amber'**
  String get retroAccentAmber;

  /// No description provided for @retroAccentGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get retroAccentGreen;

  /// No description provided for @retroAccentLime.
  ///
  /// In en, this message translates to:
  /// **'Lime'**
  String get retroAccentLime;

  /// No description provided for @gameToolTitle.
  ///
  /// In en, this message translates to:
  /// **'GameTool'**
  String get gameToolTitle;

  /// No description provided for @saveFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Save File'**
  String get saveFileTitle;

  /// No description provided for @saveFileHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a file · original game'**
  String get saveFileHint;

  /// No description provided for @saveFileConfirm.
  ///
  /// In en, this message translates to:
  /// **'Close SM64CoopDX first. Changes apply on the next launch. Copy and erase affect both normal and alternative progress for the selected slot. Restore replaces all four slots. A full backup is saved before writing.'**
  String get saveFileConfirm;

  /// No description provided for @saveFileDone.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saveFileDone;

  /// No description provided for @saveFileMissing.
  ///
  /// In en, this message translates to:
  /// **'Connect the game folder and start the game once to create its save file.'**
  String get saveFileMissing;

  /// No description provided for @saveFileError.
  ///
  /// In en, this message translates to:
  /// **'Could not verify or save the file. Refresh and try again; recovery copies are kept in Backups.'**
  String get saveFileError;

  /// No description provided for @saveFilePrimary.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get saveFilePrimary;

  /// No description provided for @saveFileAlternate.
  ///
  /// In en, this message translates to:
  /// **'Alternative'**
  String get saveFileAlternate;

  /// No description provided for @saveFileEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get saveFileEmpty;

  /// No description provided for @saveFileUnsigned.
  ///
  /// In en, this message translates to:
  /// **'Unsigned or damaged copy'**
  String get saveFileUnsigned;

  /// No description provided for @saveFileCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get saveFileCopy;

  /// No description provided for @saveFileProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get saveFileProgress;

  /// No description provided for @saveFileBackup.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get saveFileBackup;

  /// No description provided for @saveFileBackups.
  ///
  /// In en, this message translates to:
  /// **'Backups'**
  String get saveFileBackups;

  /// No description provided for @saveFileCannon.
  ///
  /// In en, this message translates to:
  /// **'Cannon'**
  String get saveFileCannon;

  /// No description provided for @saveFileCoins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get saveFileCoins;

  /// No description provided for @saveFileCastle.
  ///
  /// In en, this message translates to:
  /// **'Castle stars'**
  String get saveFileCastle;

  /// No description provided for @saveFileUnlocks.
  ///
  /// In en, this message translates to:
  /// **'Unlocks'**
  String get saveFileUnlocks;

  /// No description provided for @saveFileWing.
  ///
  /// In en, this message translates to:
  /// **'Wing Cap'**
  String get saveFileWing;

  /// No description provided for @saveFileMetal.
  ///
  /// In en, this message translates to:
  /// **'Metal Cap'**
  String get saveFileMetal;

  /// No description provided for @saveFileVanish.
  ///
  /// In en, this message translates to:
  /// **'Vanish Cap'**
  String get saveFileVanish;

  /// No description provided for @saveFileKey1.
  ///
  /// In en, this message translates to:
  /// **'First key'**
  String get saveFileKey1;

  /// No description provided for @saveFileKey2.
  ///
  /// In en, this message translates to:
  /// **'Second key'**
  String get saveFileKey2;

  /// No description provided for @saveFileBasement.
  ///
  /// In en, this message translates to:
  /// **'Basement door'**
  String get saveFileBasement;

  /// No description provided for @saveFileUpstairs.
  ///
  /// In en, this message translates to:
  /// **'Upstairs door'**
  String get saveFileUpstairs;

  /// No description provided for @saveFileMoat.
  ///
  /// In en, this message translates to:
  /// **'Drain moat'**
  String get saveFileMoat;

  /// No description provided for @saveFileComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete progress: 120 stars'**
  String get saveFileComplete;

  /// No description provided for @saveFileClearStars.
  ///
  /// In en, this message translates to:
  /// **'Clear stars'**
  String get saveFileClearStars;

  /// No description provided for @saveFileCourseNames.
  ///
  /// In en, this message translates to:
  /// **'Bob-omb Battlefield|Whomp\'s Fortress|Jolly Roger Bay|Cool, Cool Mountain|Big Boo\'s Haunt|Hazy Maze Cave|Lethal Lava Land|Shifting Sand Land|Dire, Dire Docks|Snowman\'s Land|Wet-Dry World|Tall, Tall Mountain|Tiny-Huge Island|Tick Tock Clock|Rainbow Ride|Bowser in the Dark World|Bowser in the Fire Sea|Bowser in the Sky|The Princess\'s Secret Slide|Cavern of the Metal Cap|Tower of the Wing Cap|Vanish Cap Under the Moat|Wing Mario Over the Rainbow|The Secret Aquarium'**
  String get saveFileCourseNames;

  /// No description provided for @saveFileCopies.
  ///
  /// In en, this message translates to:
  /// **'Game progress'**
  String get saveFileCopies;

  /// No description provided for @saveFileCopiesHint.
  ///
  /// In en, this message translates to:
  /// **'Normal is your usual game progress. Some mods use Alternative for special modes, such as hard mode. It is not a backup. Selecting it here does not change which progress the game uses.'**
  String get saveFileCopiesHint;

  /// No description provided for @saveFileOpenSlot.
  ///
  /// In en, this message translates to:
  /// **'Tap to edit'**
  String get saveFileOpenSlot;

  /// No description provided for @saveFileActions.
  ///
  /// In en, this message translates to:
  /// **'Slot actions'**
  String get saveFileActions;

  /// No description provided for @saveFileDraft.
  ///
  /// In en, this message translates to:
  /// **'Preview · saved only after Apply'**
  String get saveFileDraft;

  /// No description provided for @drawerResources.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get drawerResources;

  /// No description provided for @fastInstallTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable faster installation'**
  String get fastInstallTitle;

  /// No description provided for @fastInstallDescription.
  ///
  /// In en, this message translates to:
  /// **'Optional: allow all-files access in Android to speed up installation in compatible game folders. Without it, installation still works normally.'**
  String get fastInstallDescription;

  /// No description provided for @fastInstallAccessError.
  ///
  /// In en, this message translates to:
  /// **'Could not open permission settings. You can keep installing normally.'**
  String get fastInstallAccessError;

  /// No description provided for @playGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get playGuideTitle;

  /// No description provided for @playGuideIntro.
  ///
  /// In en, this message translates to:
  /// **'Your first adventure, one step at a time. Start with the game, then bring your mods here.'**
  String get playGuideIntro;

  /// No description provided for @playGuideNext.
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get playGuideNext;

  /// No description provided for @playGuideBack.
  ///
  /// In en, this message translates to:
  /// **'Previous step'**
  String get playGuideBack;

  /// No description provided for @playGuideOpenDownload.
  ///
  /// In en, this message translates to:
  /// **'Open Android downloads'**
  String get playGuideOpenDownload;

  /// No description provided for @playGuideRepository.
  ///
  /// In en, this message translates to:
  /// **'Android port repository'**
  String get playGuideRepository;

  /// No description provided for @playGuideConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect game folder'**
  String get playGuideConnect;

  /// No description provided for @playGuideLibrary.
  ///
  /// In en, this message translates to:
  /// **'Open Library'**
  String get playGuideLibrary;

  /// No description provided for @playGuideLaunch.
  ///
  /// In en, this message translates to:
  /// **'Open the game'**
  String get playGuideLaunch;

  /// No description provided for @playGuideMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'Let’s prepare your game'**
  String get playGuideMissingTitle;

  /// No description provided for @playGuideMissingBody.
  ///
  /// In en, this message translates to:
  /// **'SM64CoopDX Android is not installed. Follow the guide to install it, prepare your ROM and connect your mods.'**
  String get playGuideMissingBody;

  /// No description provided for @playGuideRead.
  ///
  /// In en, this message translates to:
  /// **'See getting-started guide'**
  String get playGuideRead;

  /// No description provided for @playGuideLater.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get playGuideLater;

  /// No description provided for @playGuideLinkError.
  ///
  /// In en, this message translates to:
  /// **'The page could not open. Check your connection and try again.'**
  String get playGuideLinkError;

  /// No description provided for @playGuideLaunchError.
  ///
  /// In en, this message translates to:
  /// **'The game is installed, but Android could not open it. Try its icon on your home screen.'**
  String get playGuideLaunchError;

  /// No description provided for @playGuideInstalled.
  ///
  /// In en, this message translates to:
  /// **'Game installed'**
  String get playGuideInstalled;

  /// No description provided for @playGuideNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Game not detected yet'**
  String get playGuideNotInstalled;

  /// No description provided for @playGuideConnected.
  ///
  /// In en, this message translates to:
  /// **'Game folder connected'**
  String get playGuideConnected;

  /// No description provided for @playGuideNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Game folder not connected yet'**
  String get playGuideNotConnected;

  /// No description provided for @playGuideReady.
  ///
  /// In en, this message translates to:
  /// **'Your adventure awaits! You can revisit any step whenever you need it.'**
  String get playGuideReady;

  /// No description provided for @playGuideStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Get the game'**
  String get playGuideStep1Title;

  /// No description provided for @playGuideStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Prepare your own ROM'**
  String get playGuideStep2Title;

  /// No description provided for @playGuideConvertTitle.
  ///
  /// In en, this message translates to:
  /// **'Convert my ROM (.n64 / .v64)'**
  String get playGuideConvertTitle;

  /// No description provided for @playGuideStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Give the ROM to the game'**
  String get playGuideStep3Title;

  /// No description provided for @playGuideStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Connect the manager'**
  String get playGuideStep4Title;

  /// No description provided for @playGuideStep5Title.
  ///
  /// In en, this message translates to:
  /// **'Add your first mod'**
  String get playGuideStep5Title;

  /// No description provided for @playGuidePathsTitle.
  ///
  /// In en, this message translates to:
  /// **'Where does everything go?'**
  String get playGuidePathsTitle;

  /// No description provided for @playGuideStep6Title.
  ///
  /// In en, this message translates to:
  /// **'Play and find help'**
  String get playGuideStep6Title;

  /// No description provided for @playGuideMap.
  ///
  /// In en, this message translates to:
  /// **'Your adventure map'**
  String get playGuideMap;

  /// No description provided for @playGuideSwipe.
  ///
  /// In en, this message translates to:
  /// **'Swipe left or right to change chapter'**
  String get playGuideSwipe;

  /// No description provided for @playGuideChapter.
  ///
  /// In en, this message translates to:
  /// **'CHAPTER'**
  String get playGuideChapter;

  /// No description provided for @playGuideTip.
  ///
  /// In en, this message translates to:
  /// **'Remember'**
  String get playGuideTip;

  /// No description provided for @playGuideOverview.
  ///
  /// In en, this message translates to:
  /// **'All steps'**
  String get playGuideOverview;

  /// No description provided for @playGuideS1Card1.
  ///
  /// In en, this message translates to:
  /// **'SM64CDPY manages mods. SM64CoopDX Android is the separate app that runs the game.'**
  String get playGuideS1Card1;

  /// No description provided for @playGuideS1Card2.
  ///
  /// In en, this message translates to:
  /// **'Tap Open Android downloads. Your browser will open the Android port’s GitHub page.'**
  String get playGuideS1Card2;

  /// No description provided for @playGuideS1Card3.
  ///
  /// In en, this message translates to:
  /// **'Find the release and expand Assets if needed. Download the file ending in .apk, not Source code. Follow the release’s device requirements if it offers different builds.'**
  String get playGuideS1Card3;

  /// No description provided for @playGuideS1Card4.
  ///
  /// In en, this message translates to:
  /// **'Open the downloaded APK and tap Install. If Android asks, allow this browser or file app to install this APK, then return to installation.'**
  String get playGuideS1Card4;

  /// No description provided for @playGuideS1Card5.
  ///
  /// In en, this message translates to:
  /// **'Open SM64CoopDX once. Follow its storage instructions so it can create its game folder.'**
  String get playGuideS1Card5;

  /// No description provided for @playGuideS1Card6.
  ///
  /// In en, this message translates to:
  /// **'If you are unsure about Android’s prompts, ask someone you trust to help.'**
  String get playGuideS1Card6;

  /// No description provided for @playGuideS2Card1.
  ///
  /// In en, this message translates to:
  /// **'The ROM is a copy of the original Super Mario 64 cartridge. The APK alone does not include the game’s original pictures and sounds.'**
  String get playGuideS2Card1;

  /// No description provided for @playGuideS2Card2.
  ///
  /// In en, this message translates to:
  /// **'Use your own unmodified USA copy in .z64 format. This guide does not supply ROMs. A ZIP is a package: extract it first to see the file inside.'**
  String get playGuideS2Card2;

  /// No description provided for @playGuideS2Card3.
  ///
  /// In en, this message translates to:
  /// **'Already .z64? Go to the next step.'**
  String get playGuideS2Card3;

  /// No description provided for @playGuideS2Card4.
  ///
  /// In en, this message translates to:
  /// **'Ends in .n64 or .v64? Open “Convert my ROM” below.'**
  String get playGuideS2Card4;

  /// No description provided for @playGuideS2Card5.
  ///
  /// In en, this message translates to:
  /// **'A different region or modified game? Changing its name or format will not make it a USA original.'**
  String get playGuideS2Card5;

  /// No description provided for @playGuideS3Card1.
  ///
  /// In en, this message translates to:
  /// **'Open SM64CoopDX Android.'**
  String get playGuideS3Card1;

  /// No description provided for @playGuideS3Card2.
  ///
  /// In en, this message translates to:
  /// **'If it asks you to choose a ROM, select your USA .z64 file, usually in Downloads. Let the game finish preparing it.'**
  String get playGuideS3Card2;

  /// No description provided for @playGuideS3Card3.
  ///
  /// In en, this message translates to:
  /// **'If your version has no selector, close the game. In your file app, copy the .z64 into Internal storage → com.maniscat2.sm64coopdx → user. Open the game again.'**
  String get playGuideS3Card3;

  /// No description provided for @playGuideS3Card4.
  ///
  /// In en, this message translates to:
  /// **'Wait until you can reach the game menu. If the ROM is rejected, check the region, original unmodified contents and real .z64 conversion.'**
  String get playGuideS3Card4;

  /// No description provided for @playGuideS3Card5.
  ///
  /// In en, this message translates to:
  /// **'The game keeps its accepted USA ROM as user/baserom.us.z64. The folder can depend on the game’s storage permissions; follow the location the game shows you.'**
  String get playGuideS3Card5;

  /// No description provided for @playGuideS4Card1.
  ///
  /// In en, this message translates to:
  /// **'Return to SM64CDPY and tap Connect game folder. We explain what to choose before opening Android’s folder window.'**
  String get playGuideS4Card1;

  /// No description provided for @playGuideS4Card2.
  ///
  /// In en, this message translates to:
  /// **'Open Internal storage → com.maniscat2.sm64coopdx.'**
  String get playGuideS4Card2;

  /// No description provided for @playGuideS4Card3.
  ///
  /// In en, this message translates to:
  /// **'Select that main folder, the one containing user, and tap Use this folder / Allow. Do not select Downloads, user alone or the ROM file.'**
  String get playGuideS4Card3;

  /// No description provided for @playGuideS4Card4.
  ///
  /// In en, this message translates to:
  /// **'One selection connects mods, DynOS, game settings and ROM detection. If user is missing, open and prepare the game first. If Android blocks access, check the game’s storage setup; choosing an unrelated empty folder will not fix it.'**
  String get playGuideS4Card4;

  /// No description provided for @playGuideS4Card5.
  ///
  /// In en, this message translates to:
  /// **'Already connected? Continue. You do not need to select the same folders for each mod.'**
  String get playGuideS4Card5;

  /// No description provided for @playGuideS5Card1.
  ///
  /// In en, this message translates to:
  /// **'Close the game before installing or changing mods.'**
  String get playGuideS5Card1;

  /// No description provided for @playGuideS5Card2.
  ///
  /// In en, this message translates to:
  /// **'Open Catalog and choose one mod. Read its compatibility notes.'**
  String get playGuideS5Card2;

  /// No description provided for @playGuideS5Card3.
  ///
  /// In en, this message translates to:
  /// **'Download it. With automatic installation enabled, wait for Installed: a finished download alone is not a finished installation. If automatic installation is off, follow the manual-install prompt or enable it in Settings.'**
  String get playGuideS5Card3;

  /// No description provided for @playGuideS5Card4.
  ///
  /// In en, this message translates to:
  /// **'Open GameTool → Library. Game Mods holds Lua mods. DynOS / Touch Controls holds model, texture and control packs. Turn on the item you want.'**
  String get playGuideS5Card4;

  /// No description provided for @playGuideS5Card5.
  ///
  /// In en, this message translates to:
  /// **'Open the game again to load your changes. Some packs need their own in-game settings; follow the author’s instructions.'**
  String get playGuideS5Card5;

  /// No description provided for @playGuideS6Card1.
  ///
  /// In en, this message translates to:
  /// **'Tap Open the game below. Choose a save slot in the game and enjoy your adventure.'**
  String get playGuideS6Card1;

  /// No description provided for @playGuideS6Card2.
  ///
  /// In en, this message translates to:
  /// **'Game not opening? First open it from Android’s home screen.'**
  String get playGuideS6Card2;

  /// No description provided for @playGuideS6Card3.
  ///
  /// In en, this message translates to:
  /// **'ROM not accepted? Recheck the USA original and .z64 format in step 2.'**
  String get playGuideS6Card3;

  /// No description provided for @playGuideS6Card4.
  ///
  /// In en, this message translates to:
  /// **'Mod missing? Check that installation finished, enable it in Library and restart the game. Check whether it needs another mod.'**
  String get playGuideS6Card4;

  /// No description provided for @playGuideS6Card5.
  ///
  /// In en, this message translates to:
  /// **'Folder access lost? Reconnect the main game folder in step 4.'**
  String get playGuideS6Card5;

  /// No description provided for @playGuideS6Card6.
  ///
  /// In en, this message translates to:
  /// **'Try one mod at a time. If something breaks, turn off that mod, then reopen the game. Keep a backup before deleting game files.'**
  String get playGuideS6Card6;

  /// No description provided for @playGuideConvertCard1.
  ///
  /// In en, this message translates to:
  /// **'Keep your original file as a backup.'**
  String get playGuideConvertCard1;

  /// No description provided for @playGuideConvertCard2.
  ///
  /// In en, this message translates to:
  /// **'Open the ROM converter in your browser.'**
  String get playGuideConvertCard2;

  /// No description provided for @playGuideConvertCard3.
  ///
  /// In en, this message translates to:
  /// **'Choose your own .n64 or .v64 file.'**
  String get playGuideConvertCard3;

  /// No description provided for @playGuideConvertCard4.
  ///
  /// In en, this message translates to:
  /// **'Select .z64 as the output format and save the converted file, usually in Downloads.'**
  String get playGuideConvertCard4;

  /// No description provided for @playGuideConvertCard5.
  ///
  /// In en, this message translates to:
  /// **'Return here and continue with that .z64 file.'**
  String get playGuideConvertCard5;

  /// No description provided for @playGuideConvertCard6.
  ///
  /// In en, this message translates to:
  /// **'Conversion rearranges the file’s bytes. Renaming .n64 to .z64 does not convert it. This is an external tool; if it is unavailable, use another N64 byte-order converter with .z64 output.'**
  String get playGuideConvertCard6;

  /// No description provided for @playGuidePathsCard1.
  ///
  /// In en, this message translates to:
  /// **'Inside Internal storage → com.maniscat2.sm64coopdx:'**
  String get playGuidePathsCard1;

  /// No description provided for @playGuidePathsCard2.
  ///
  /// In en, this message translates to:
  /// **'user/mods → new Lua mod installations. A mod can be a .lua file or a folder with main.lua.'**
  String get playGuidePathsCard2;

  /// No description provided for @playGuidePathsCard3.
  ///
  /// In en, this message translates to:
  /// **'user/dynos/packs → new DynOS and Touch Controls packs. Touch Controls shares this destination.'**
  String get playGuidePathsCard3;

  /// No description provided for @playGuidePathsCard4.
  ///
  /// In en, this message translates to:
  /// **'user/baserom.us.z64 → the original USA ROM accepted by the game.'**
  String get playGuidePathsCard4;

  /// No description provided for @playGuidePathsCard5.
  ///
  /// In en, this message translates to:
  /// **'user/sm64config.txt → game settings and enabled items. Let the app manage it rather than editing it by hand.'**
  String get playGuidePathsCard5;

  /// No description provided for @playGuidePathsCard6.
  ///
  /// In en, this message translates to:
  /// **'The game also reads mods and dynos/packs outside user. This manager shows those too when the main folder is connected. For duplicate names, Lua uses user/mods first; DynOS uses the outer dynos/packs first. Avoid keeping two copies with the same name.'**
  String get playGuidePathsCard6;

  /// No description provided for @playGuideS1Title1.
  ///
  /// In en, this message translates to:
  /// **'Two apps, two jobs'**
  String get playGuideS1Title1;

  /// No description provided for @playGuideS1Title2.
  ///
  /// In en, this message translates to:
  /// **'Open the Android page'**
  String get playGuideS1Title2;

  /// No description provided for @playGuideS1Title3.
  ///
  /// In en, this message translates to:
  /// **'Choose the APK'**
  String get playGuideS1Title3;

  /// No description provided for @playGuideS1Title4.
  ///
  /// In en, this message translates to:
  /// **'Install the game'**
  String get playGuideS1Title4;

  /// No description provided for @playGuideS1Title5.
  ///
  /// In en, this message translates to:
  /// **'Open it once'**
  String get playGuideS1Title5;

  /// No description provided for @playGuideS1Title6.
  ///
  /// In en, this message translates to:
  /// **'A helping hand'**
  String get playGuideS1Title6;

  /// No description provided for @playGuideS2Title1.
  ///
  /// In en, this message translates to:
  /// **'What is a ROM?'**
  String get playGuideS2Title1;

  /// No description provided for @playGuideS2Title2.
  ///
  /// In en, this message translates to:
  /// **'The copy you need'**
  String get playGuideS2Title2;

  /// No description provided for @playGuideS2Title3.
  ///
  /// In en, this message translates to:
  /// **'Already .z64'**
  String get playGuideS2Title3;

  /// No description provided for @playGuideS2Title4.
  ///
  /// In en, this message translates to:
  /// **'I have .n64 or .v64'**
  String get playGuideS2Title4;

  /// No description provided for @playGuideS2Title5.
  ///
  /// In en, this message translates to:
  /// **'Region matters'**
  String get playGuideS2Title5;

  /// No description provided for @playGuideS3Title1.
  ///
  /// In en, this message translates to:
  /// **'Open SM64CoopDX'**
  String get playGuideS3Title1;

  /// No description provided for @playGuideS3Title2.
  ///
  /// In en, this message translates to:
  /// **'Choose your ROM'**
  String get playGuideS3Title2;

  /// No description provided for @playGuideS3Title3.
  ///
  /// In en, this message translates to:
  /// **'If there is no selector'**
  String get playGuideS3Title3;

  /// No description provided for @playGuideS3Title4.
  ///
  /// In en, this message translates to:
  /// **'Reach the game menu'**
  String get playGuideS3Title4;

  /// No description provided for @playGuideS3Title5.
  ///
  /// In en, this message translates to:
  /// **'Your ROM’s home'**
  String get playGuideS3Title5;

  /// No description provided for @playGuideS4Title1.
  ///
  /// In en, this message translates to:
  /// **'Return to this manager'**
  String get playGuideS4Title1;

  /// No description provided for @playGuideS4Title2.
  ///
  /// In en, this message translates to:
  /// **'Find the main folder'**
  String get playGuideS4Title2;

  /// No description provided for @playGuideS4Title3.
  ///
  /// In en, this message translates to:
  /// **'Allow that folder'**
  String get playGuideS4Title3;

  /// No description provided for @playGuideS4Title4.
  ///
  /// In en, this message translates to:
  /// **'One connection'**
  String get playGuideS4Title4;

  /// No description provided for @playGuideS4Title5.
  ///
  /// In en, this message translates to:
  /// **'Already connected?'**
  String get playGuideS4Title5;

  /// No description provided for @playGuideS5Title1.
  ///
  /// In en, this message translates to:
  /// **'Close the game first'**
  String get playGuideS5Title1;

  /// No description provided for @playGuideS5Title2.
  ///
  /// In en, this message translates to:
  /// **'Choose one mod'**
  String get playGuideS5Title2;

  /// No description provided for @playGuideS5Title3.
  ///
  /// In en, this message translates to:
  /// **'Wait for installation'**
  String get playGuideS5Title3;

  /// No description provided for @playGuideS5Title4.
  ///
  /// In en, this message translates to:
  /// **'Turn it on in Library'**
  String get playGuideS5Title4;

  /// No description provided for @playGuideS5Title5.
  ///
  /// In en, this message translates to:
  /// **'Restart and try it'**
  String get playGuideS5Title5;

  /// No description provided for @playGuideS6Title1.
  ///
  /// In en, this message translates to:
  /// **'Start your adventure'**
  String get playGuideS6Title1;

  /// No description provided for @playGuideS6Title2.
  ///
  /// In en, this message translates to:
  /// **'The game will not open'**
  String get playGuideS6Title2;

  /// No description provided for @playGuideS6Title3.
  ///
  /// In en, this message translates to:
  /// **'The ROM is rejected'**
  String get playGuideS6Title3;

  /// No description provided for @playGuideS6Title4.
  ///
  /// In en, this message translates to:
  /// **'The mod is missing'**
  String get playGuideS6Title4;

  /// No description provided for @playGuideS6Title5.
  ///
  /// In en, this message translates to:
  /// **'Folder permission lost'**
  String get playGuideS6Title5;

  /// No description provided for @playGuideS6Title6.
  ///
  /// In en, this message translates to:
  /// **'Try one at a time'**
  String get playGuideS6Title6;

  /// No description provided for @romPrepareNav.
  ///
  /// In en, this message translates to:
  /// **'Prepare ROM'**
  String get romPrepareNav;

  /// No description provided for @romPrepareTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare your ROM'**
  String get romPrepareTitle;

  /// No description provided for @romPrepareDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose your own Super Mario 64 file. The app creates and verifies a compatible .z64 copy without changing the original.'**
  String get romPrepareDescription;

  /// No description provided for @romPreparePrivacy.
  ///
  /// In en, this message translates to:
  /// **'SM64CDPY does not include, download or share ROMs. The selected file is processed locally on your device.'**
  String get romPreparePrivacy;

  /// No description provided for @romPrepareChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose ROM'**
  String get romPrepareChoose;

  /// No description provided for @romPrepareChooseAnother.
  ///
  /// In en, this message translates to:
  /// **'Choose another file'**
  String get romPrepareChooseAnother;

  /// No description provided for @romPrepareAnother.
  ///
  /// In en, this message translates to:
  /// **'Prepare another ROM'**
  String get romPrepareAnother;

  /// No description provided for @romPrepareSave.
  ///
  /// In en, this message translates to:
  /// **'Save .z64 copy'**
  String get romPrepareSave;

  /// No description provided for @romPrepareContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue with the guide'**
  String get romPrepareContinue;

  /// No description provided for @romPrepareCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get romPrepareCancel;

  /// No description provided for @romPrepareIdle.
  ///
  /// In en, this message translates to:
  /// **'Ready to check your file'**
  String get romPrepareIdle;

  /// No description provided for @romPreparePicking.
  ///
  /// In en, this message translates to:
  /// **'Choose your file in Android'**
  String get romPreparePicking;

  /// No description provided for @romPrepareInspecting.
  ///
  /// In en, this message translates to:
  /// **'Checking the selected file'**
  String get romPrepareInspecting;

  /// No description provided for @romPrepareConverting.
  ///
  /// In en, this message translates to:
  /// **'Preparing a compatible copy'**
  String get romPrepareConverting;

  /// No description provided for @romPrepareValidating.
  ///
  /// In en, this message translates to:
  /// **'Verifying the prepared ROM'**
  String get romPrepareValidating;

  /// No description provided for @romPrepareReady.
  ///
  /// In en, this message translates to:
  /// **'Compatible ROM ready'**
  String get romPrepareReady;

  /// No description provided for @romPrepareAlreadyCompatible.
  ///
  /// In en, this message translates to:
  /// **'Your ROM was already in the correct format'**
  String get romPrepareAlreadyCompatible;

  /// No description provided for @romPrepareChoosingDestination.
  ///
  /// In en, this message translates to:
  /// **'Choose where to save the copy'**
  String get romPrepareChoosingDestination;

  /// No description provided for @romPrepareExporting.
  ///
  /// In en, this message translates to:
  /// **'Saving your copy'**
  String get romPrepareExporting;

  /// No description provided for @romPrepareVerifyingExport.
  ///
  /// In en, this message translates to:
  /// **'Verifying the saved copy'**
  String get romPrepareVerifyingExport;

  /// No description provided for @romPrepareSaved.
  ///
  /// In en, this message translates to:
  /// **'Copy saved and verified'**
  String get romPrepareSaved;

  /// No description provided for @romPrepareCancelling.
  ///
  /// In en, this message translates to:
  /// **'Stopping safely'**
  String get romPrepareCancelling;

  /// No description provided for @romPrepareCancelled.
  ///
  /// In en, this message translates to:
  /// **'Preparation cancelled'**
  String get romPrepareCancelled;

  /// No description provided for @romPrepareFailed.
  ///
  /// In en, this message translates to:
  /// **'The ROM could not be prepared'**
  String get romPrepareFailed;

  /// No description provided for @romPrepareDetected.
  ///
  /// In en, this message translates to:
  /// **'Detected format: {format}'**
  String romPrepareDetected(String format);

  /// No description provided for @romPrepareSavedAs.
  ///
  /// In en, this message translates to:
  /// **'Saved as {name}'**
  String romPrepareSavedAs(String name);

  /// No description provided for @romPrepareErrorUnrecognized.
  ///
  /// In en, this message translates to:
  /// **'This file is not a recognized N64 ROM format.'**
  String get romPrepareErrorUnrecognized;

  /// No description provided for @romPrepareErrorSize.
  ///
  /// In en, this message translates to:
  /// **'The original Super Mario 64 ROM must be exactly 8 MiB.'**
  String get romPrepareErrorSize;

  /// No description provided for @romPrepareErrorIncompatible.
  ///
  /// In en, this message translates to:
  /// **'You need an unmodified original Super Mario 64 USA ROM.'**
  String get romPrepareErrorIncompatible;

  /// No description provided for @romPrepareErrorPermission.
  ///
  /// In en, this message translates to:
  /// **'Android no longer allows access to that file. Choose it again.'**
  String get romPrepareErrorPermission;

  /// No description provided for @romPrepareErrorStorage.
  ///
  /// In en, this message translates to:
  /// **'There is not enough available storage, or the file could not be read.'**
  String get romPrepareErrorStorage;

  /// No description provided for @romPrepareErrorExport.
  ///
  /// In en, this message translates to:
  /// **'The saved copy could not be verified. Choose another destination and try again.'**
  String get romPrepareErrorExport;

  /// No description provided for @romPrepareErrorBusy.
  ///
  /// In en, this message translates to:
  /// **'Another ROM operation is already active.'**
  String get romPrepareErrorBusy;

  /// No description provided for @romPrepareErrorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Something unexpected happened. Your original file was not changed.'**
  String get romPrepareErrorUnexpected;

  /// No description provided for @mangaNavMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get mangaNavMore;

  /// No description provided for @mangaNavPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get mangaNavPlay;

  /// No description provided for @mangaNavHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe to browse. Tap to open.'**
  String get mangaNavHint;

  /// No description provided for @mangaNavError.
  ///
  /// In en, this message translates to:
  /// **'Could not complete this action. Try again.'**
  String get mangaNavError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'es':
      {
        switch (locale.countryCode) {
          case '419':
            return AppLocalizationsEs419();
        }
        break;
      }
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
