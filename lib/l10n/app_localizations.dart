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
  /// **'VIP Mods'**
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
  /// **'OMMR PACK'**
  String get navOmmRebirth;

  /// Drawer navigation label for the links & resources screen
  ///
  /// In en, this message translates to:
  /// **'Links Resource'**
  String get navLinksResource;

  /// Drawer navigation label for the disclaimer screen
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get navDisclaimer;

  /// Drawer navigation label for the changelog screen
  ///
  /// In en, this message translates to:
  /// **'Changelog'**
  String get navChangelog;

  /// Drawer navigation label for the settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Section header in the drawer for exclusive content items
  ///
  /// In en, this message translates to:
  /// **'EXCLUSIVE'**
  String get sectionExclusive;

  /// Section header in the drawer for category browsing
  ///
  /// In en, this message translates to:
  /// **'EXPLORE'**
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

  /// Label before the changelog text in the update dialog
  ///
  /// In en, this message translates to:
  /// **'What\'s new:'**
  String get updateWhatIsNew;

  /// Fallback text shown when no changelog is available in the update dialog
  ///
  /// In en, this message translates to:
  /// **'Minor improvements and bug fixes.'**
  String get updateGenericDescription;

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
  /// **'Mods will be automatically installed to the game folder'**
  String get settingsAutoInstallOn;

  /// Settings screen message when auto-install is off
  ///
  /// In en, this message translates to:
  /// **'You will be asked after each download'**
  String get settingsAutoInstallOff;

  /// Settings screen section header for theme mode selection
  ///
  /// In en, this message translates to:
  /// **'THEME MODE'**
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

  /// Changelog screen title
  ///
  /// In en, this message translates to:
  /// **'Changelog'**
  String get changelogTitle;

  /// Changelog screen section header for new features
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get changelogNew;

  /// Changelog screen section header for improvements
  ///
  /// In en, this message translates to:
  /// **'Improved'**
  String get changelogImproved;

  /// Changelog screen section header for bug fixes
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get changelogFixed;

  /// Changelog screen section header for removed items
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get changelogRemoved;

  /// Changelog screen section header for changes
  ///
  /// In en, this message translates to:
  /// **'Changed'**
  String get changelogChanged;

  /// Changelog screen badge label for the latest release
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get changelogLatest;

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
  /// **'This app is a personal project. Any issues related to it (functionality, bugs, etc.) are the sole responsibility of the developer. The SM64CoopDX developers and mod creators bear no responsibility whatsoever for this application.'**
  String get disclaimerWarningBody;

  /// Disclaimer screen error message when a link cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open the link'**
  String get disclaimerCouldNotOpenLink;

  /// Disclaimer screen section header for personal purpose
  ///
  /// In en, this message translates to:
  /// **'Personal purpose'**
  String get disclaimerSectionPersonalPurpose;

  /// Disclaimer screen body text for the personal purpose section
  ///
  /// In en, this message translates to:
  /// **'This application was independently developed as a personal project. Its sole purpose is to give me faster access, organization, and download management for mods I use for my own entertainment. It is not an application supported by the SM64CoopDX team or an official service of any kind.'**
  String get disclaimerBodyPersonalPurpose;

  /// Disclaimer screen section header for no official affiliation
  ///
  /// In en, this message translates to:
  /// **'No official affiliation'**
  String get disclaimerSectionNoAffiliation;

  /// Disclaimer screen body text for the no affiliation section
  ///
  /// In en, this message translates to:
  /// **'This project is not associated with, endorsed by, or approved by the developers of SM64CoopDX, Super Mario 64, Nintendo, or any of the mod creators listed. All names, images, and content displayed belong to their respective authors.'**
  String get disclaimerBodyNoAffiliation;

  /// Disclaimer screen section header for data source
  ///
  /// In en, this message translates to:
  /// **'Data source'**
  String get disclaimerSectionDataSource;

  /// Disclaimer screen body text for the data source section
  ///
  /// In en, this message translates to:
  /// **'Mod information comes from the public catalog at mods.sm64coopdx.com. This app only presents that information in a more accessible way; it does not host, modify, or redistribute any mod files.'**
  String get disclaimerBodyDataSource;

  /// Disclaimer screen section header for exclusive sections
  ///
  /// In en, this message translates to:
  /// **'Exclusive sections (VIP · DynOS · Touch Controls)'**
  String get disclaimerSectionExclusive;

  /// Disclaimer screen body text for the exclusive sections
  ///
  /// In en, this message translates to:
  /// **'Starting with v{version}, the app includes curated sections with content not officially listed on the SM64CoopDX website. These sections (VIP Mods, DynOS packs, and Touch Control layouts) are maintained independently by the developer and are not affiliated with any official source. All credit goes to the original creators.'**
  String disclaimerBodyExclusive(Object version);

  /// Disclaimer screen section header for bugs and suggestions
  ///
  /// In en, this message translates to:
  /// **'Bugs, suggestions & requests'**
  String get disclaimerSectionBugs;

  /// Disclaimer screen body text for the bugs and suggestions section
  ///
  /// In en, this message translates to:
  /// **'If you find an issue with this app, have a suggestion, or want to request something, contact me directly through my social media. Please do not contact the official SM64CoopDX developers or mod creators about anything related to this application.'**
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
  /// **'DynOS folder'**
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
  /// **'DynOS folder selected. Packs will be installed here.'**
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
  /// **'LANGUAGE'**
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
