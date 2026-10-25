// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get hello => 'Bonjour';

  @override
  String get navHome => 'Accueil';

  @override
  String get navCatalog => 'Catalogue';

  @override
  String get navFavourites => 'Favoris';

  @override
  String get navPopular => 'Populaires';

  @override
  String get navVIPMods => 'Mods';

  @override
  String get navDynOS => 'DynOS';

  @override
  String get navTouchControls => 'Commandes tactiles';

  @override
  String get navOmmRebirth => 'Pack OMM';

  @override
  String get navLinksResource => 'Liens';

  @override
  String get navDisclaimer => 'Informations légales';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get sectionExclusive => 'Exclusivités';

  @override
  String get sectionNavigation => 'NAVIGATION';

  @override
  String get sectionExplore => 'Explorer';

  @override
  String get sectionCategories => 'CATÉGORIES';

  @override
  String get sectionSortBy => 'TRIER PAR';

  @override
  String get sectionSocialLinks => 'RÉSEAUX SOCIAUX';

  @override
  String get sortDefault => 'Par défaut';

  @override
  String get sortRating => 'Note';

  @override
  String get sortDownloads => 'Téléchargements';

  @override
  String get sortNewest => 'Dernière mise à jour';

  @override
  String get socialYouTube => 'YouTube';

  @override
  String get socialDiscord => 'Discord';

  @override
  String get socialGitHub => 'GitHub';

  @override
  String get categoryCharacters => 'Personnages';

  @override
  String get categoryGameModes => 'Modes de jeu';

  @override
  String get categoryROMHacks => 'ROM hacks et niveaux';

  @override
  String get categoryGameplay => 'Gameplay et mécaniques';

  @override
  String get categoryVisual => 'Graphismes et modèles';

  @override
  String get categoryAudio => 'Audio et voix';

  @override
  String get categoryUtilities => 'Utilitaires et outils';

  @override
  String get categoryMisc => 'Divers et détente';

  @override
  String get badgeFeatured => 'À LA UNE';

  @override
  String get updateRequired => 'MISE À JOUR REQUISE';

  @override
  String get updateAvailable => 'NOUVELLE VERSION DISPONIBLE';

  @override
  String updateVersion(String version) {
    return 'Version $version';
  }

  @override
  String updateSize(String size) {
    return 'Taille : $size Mo';
  }

  @override
  String updateDownloading(String pct) {
    return 'Téléchargement… $pct %';
  }

  @override
  String get updateAlreadyDownloading =>
      'Un téléchargement est déjà en cours. Patientez ou redémarrez l’application.';

  @override
  String get updatePermissionDenied =>
      'Installation non autorisée.\nOuvrez Paramètres → Applications → cette application → Installation d’applications inconnues.';

  @override
  String updateInternalError(String detail) {
    return 'Une erreur interne s’est produite. Réessayez. Détails : $detail';
  }

  @override
  String get updateDownloadError =>
      'Le téléchargement a échoué. Vérifiez votre connexion.';

  @override
  String get updateChecksumError =>
      'Le fichier téléchargé est endommagé. Réessayez.';

  @override
  String updateInstallError(String detail) {
    return 'L’installation a échoué. Réessayez. Détails : $detail';
  }

  @override
  String updateUnexpectedError(String detail) {
    return 'Une erreur inattendue s’est produite. Détails : $detail';
  }

  @override
  String updateCantStart(String detail) {
    return 'Impossible de lancer la mise à jour : $detail';
  }

  @override
  String get updateButtonOpenBrowser => 'OUVRIR DANS LE NAVIGATEUR';

  @override
  String get updateButtonLater => 'PLUS TARD';

  @override
  String get updateButtonExit => 'QUITTER';

  @override
  String get updateButtonUpdateNow => 'METTRE À JOUR';

  @override
  String get updateButtonGoToDownloads => 'VOIR LES TÉLÉCHARGEMENTS';

  @override
  String get postInstallTitle => 'Mod installé';

  @override
  String get postInstallGameRunning =>
      'Si le jeu était ouvert, fermez-le complètement, sans simplement le réduire, puis rouvrez-le pour charger les nouveaux fichiers.';

  @override
  String get postInstallNoRoot =>
      'Aucun arrêt forcé ni accès root nécessaire : fermez le jeu normalement, puis rouvrez-le.';

  @override
  String get postInstallFilesCopied =>
      'Les fichiers ont été copiés dans le dossier des mods.';

  @override
  String get postInstallClose => 'Fermer';

  @override
  String get postInstallLaunchGame => 'LANCER LE JEU';

  @override
  String get homeExclusiveContent => 'Exclusivités';

  @override
  String get homeTopDownloads => 'Les plus téléchargés';

  @override
  String get homeSeeAll => 'Tout voir';

  @override
  String get homeFeatured => 'À la une';

  @override
  String get homeCatalog => 'Catalogue';

  @override
  String get homeCatalogDesc =>
      'Parcourez, recherchez et filtrez tous les mods';

  @override
  String get homeFavorites => 'Favoris';

  @override
  String get homeFavoritesDesc =>
      'Vos mods enregistrés, toutes sections confondues';

  @override
  String get homePopular => 'Populaires';

  @override
  String get homePopularDesc =>
      'Les mods classés par nombre de téléchargements';

  @override
  String get homeBrowse => 'Parcourir';

  @override
  String get homeGoTo => 'OUVRIR';

  @override
  String get homeVipMods => 'Mods VIP';

  @override
  String get homeVipModsDesc => 'Packs exclusifs de personnages et de modèles';

  @override
  String get homeDynos => 'DynOS';

  @override
  String get homeDynosDesc =>
      'Textures personnalisées et remplacement de modèles';

  @override
  String get homeTouchControls => 'Commandes tactiles';

  @override
  String get homeTouchControlsDesc =>
      'Dispositions personnalisées des boutons et joysticks';

  @override
  String get homeOmmrPack => 'PACK OMMR';

  @override
  String get homeOmmrPackDesc => 'Pack de textures complet d’OMM Rebirth';

  @override
  String get homeGameNotInstalled => 'Jeu non installé';

  @override
  String get homeGameNotInstalledBody =>
      'SM64CoopDX (com.maniscat2.sm64coopdx)\nn’est pas installé sur cet appareil.';

  @override
  String get homeClose => 'Fermer';

  @override
  String get homeDownload => 'Télécharger';

  @override
  String get homeLaunchGame => 'LANCER LE JEU';

  @override
  String get homeSoon => 'BIENTÔT';

  @override
  String get homeFailedToLoad => 'Impossible de charger les mods';

  @override
  String get homeRetry => 'Réessayer';

  @override
  String get catalogueTitle => 'PARCOURIR LES MODS';

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
      other: '$count RÉSULTATS',
      one: '$count RÉSULTAT',
    );
    return '$_temp0';
  }

  @override
  String get catalogueSearchHint => 'RECHERCHER MODS, AUTEURS, TAGS…';

  @override
  String get catalogueSortDefault => 'Par défaut';

  @override
  String get catalogueSortTopRated => 'Les mieux notés';

  @override
  String get catalogueSortMostDownloaded => 'Les plus téléchargés';

  @override
  String get catalogueSortRecentlyUpdated => 'Mis à jour récemment';

  @override
  String get catalogueClearAll => 'TOUT EFFACER';

  @override
  String cataloguePaginationRange(int start, int end, int total) {
    return '$start–$end SUR $total MODS';
  }

  @override
  String get catalogueNoModsFound => 'AUCUN MOD TROUVÉ';

  @override
  String get catalogueNothingHere => 'AUCUN CONTENU POUR LE MOMENT';

  @override
  String get catalogueEmptyHint1 =>
      'Essayez d’autres mots-clés ou retirez des filtres.';

  @override
  String get catalogueEmptyHint2 =>
      'Revenez plus tard pour découvrir du nouveau contenu.';

  @override
  String get catalogueClearFilters => 'EFFACER LES FILTRES';

  @override
  String get catalogueFailedToLoad => 'IMPOSSIBLE DE CHARGER LES MODS';

  @override
  String get catalogueRating => 'NOTE';

  @override
  String get catalogueDownloads => 'TÉLÉCHARGEMENTS';

  @override
  String get catalogueNewest => 'RÉCENTS';

  @override
  String get catalogueSort => 'TRIER';

  @override
  String get catalogueEllipsis => '···';

  @override
  String get popularTitle => 'POPULAIRES';

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
  String get popularMoreRankings => 'AUTRES CLASSEMENTS';

  @override
  String get popularRankings => 'CLASSEMENTS';

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
  String get popularFailedToLoad => 'CHARGEMENT IMPOSSIBLE';

  @override
  String get favouritesTitle => 'Favoris';

  @override
  String get favTabMods => 'Mods';

  @override
  String get favTabVip => 'VIP';

  @override
  String get favTabDynos => 'DynOS';

  @override
  String get favTabTouch => 'Tactile';

  @override
  String get favEmptyMods => 'Aucun mod dans vos favoris';

  @override
  String get favEmptyVip => 'Aucun mod VIP dans vos favoris';

  @override
  String get favEmptyDynos => 'Aucun pack DynOS dans vos favoris';

  @override
  String get favEmptyTouch => 'Aucune commande tactile dans vos favoris';

  @override
  String favEmptyHint(String type) {
    return 'Touchez ♥ sur un élément « $type » pour l’enregistrer ici.';
  }

  @override
  String get favBrowse => 'Parcourir';

  @override
  String get sharedAddedToFavorites => 'Ajouté aux favoris';

  @override
  String get sharedRemovedFromFavorites => 'Retiré des favoris';

  @override
  String sharedDownloaded(String name) {
    return 'Téléchargé : $name';
  }

  @override
  String sharedDownloadedType(String type, String name) {
    return 'Téléchargement terminé ($type) : $name';
  }

  @override
  String get sharedDownloadFailed => 'Échec du téléchargement';

  @override
  String get sharedAddToFavorites => 'AJOUTER AUX FAVORIS';

  @override
  String get sharedRemoveFromFavorites => 'RETIRER DES FAVORIS';

  @override
  String get sharedDownload => 'TÉLÉCHARGER';

  @override
  String get installationChecking => 'VÉRIFICATION…';

  @override
  String get installationCancel => 'ANNULER';

  @override
  String get installationInstalled => 'INSTALLÉ';

  @override
  String get installationUpdate => 'METTRE À JOUR';

  @override
  String get installationInstall => 'INSTALLER';

  @override
  String get installationReinstall => 'RÉINSTALLER';

  @override
  String get installationVerify => 'VÉRIFIER';

  @override
  String get installationSelectFolder => 'CHOISIR UN DOSSIER';

  @override
  String get sharedReadMore => 'LIRE LA SUITE';

  @override
  String get sharedShowLess => 'RÉDUIRE';

  @override
  String get vipTitle => 'MODS VIP';

  @override
  String get vipEmpty => 'AUCUN MOD VIP POUR LE MOMENT';

  @override
  String get vipEmptyHint => 'Revenez plus tard pour du contenu exclusif.';

  @override
  String get vipFailedToLoad => 'IMPOSSIBLE DE CHARGER LES MODS VIP';

  @override
  String get dynosTitle => 'DYNOS';

  @override
  String get dynosEmpty => 'AUCUN PACK DYNOS POUR LE MOMENT';

  @override
  String get dynosEmptyHint =>
      'Revenez plus tard pour de nouveaux packs DynOS.';

  @override
  String get dynosFailedToLoad => 'IMPOSSIBLE DE CHARGER DYNOS';

  @override
  String get touchTitle => 'COMMANDES TACTILES';

  @override
  String touchModCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count DISPOSITIONS',
      one: '$count DISPOSITION',
    );
    return '$_temp0';
  }

  @override
  String get touchEmpty => 'AUCUNE DISPOSITION TACTILE POUR LE MOMENT';

  @override
  String get touchEmptyHint =>
      'Revenez plus tard pour de nouvelles dispositions de commandes.';

  @override
  String get touchFailedToLoad =>
      'IMPOSSIBLE DE CHARGER LES COMMANDES TACTILES';

  @override
  String get ommTitle => 'OMM REBIRTH';

  @override
  String get ommEmpty => 'AUCUN MOD OMM REBIRTH POUR LE MOMENT';

  @override
  String get ommEmptyHint => 'Revenez plus tard pour du contenu OMM Rebirth.';

  @override
  String get ommFailedToLoad => 'IMPOSSIBLE DE CHARGER LES MODS OMM REBIRTH';

  @override
  String get detailDownload => 'Télécharger';

  @override
  String get detailDownloadButton => 'TÉLÉCHARGER';

  @override
  String get detailModNotFound => 'Mod introuvable';

  @override
  String get detailModNotFoundBody =>
      'Ce mod a peut-être été retiré ou le lien est incorrect.';

  @override
  String get detailGoBack => 'Retour';

  @override
  String get detailFailedToLoad => 'Impossible de charger le mod';

  @override
  String get detailRetry => 'Réessayer';

  @override
  String get detailNotificationsNeeded => 'Autoriser les notifications';

  @override
  String get detailNotificationsBody =>
      'Autorisez les notifications pour suivre le téléchargement et l’installation, même lorsque vous quittez l’application.';

  @override
  String get detailNotNow => 'Pas maintenant';

  @override
  String get detailContinue => 'Continuer';

  @override
  String get detailNotificationsSkipped =>
      'La progression ne sera pas visible hors de l’application. Vous pouvez autoriser les notifications dans les paramètres.';

  @override
  String get detailModsFolderNotSelected => 'Dossier des mods non sélectionné';

  @override
  String get detailModsFolderBody =>
      'Choisissez un dossier avant d’installer des mods dans le jeu.\n\nOuvrez Paramètres → Intégration au jeu pour le sélectionner.';

  @override
  String get detailCancel => 'Annuler';

  @override
  String get detailGoToSettings => 'Ouvrir les paramètres';

  @override
  String detailDownloading(String filename) {
    return 'Téléchargement de « $filename »…';
  }

  @override
  String detailSavedToModsFolder(String name) {
    return 'Enregistré dans le dossier des mods : $name';
  }

  @override
  String detailSavedToFolder(String type, String name) {
    return 'Enregistré dans le dossier $type : $name';
  }

  @override
  String get detailDownloadFailed => 'Échec du téléchargement';

  @override
  String detailError(String detail) {
    return 'Erreur : $detail';
  }

  @override
  String detailDownloaded(String name) {
    return 'Téléchargé : $name';
  }

  @override
  String detailDownloadedType(String type, String name) {
    return 'Téléchargement terminé ($type) : $name';
  }

  @override
  String get detailDownloadingBanner => 'Téléchargement du mod…';

  @override
  String detailDownloadingBannerType(String type) {
    return 'Téléchargement : $type…';
  }

  @override
  String detailFilesProgress(int current, int total) {
    return '$current/$total fichiers';
  }

  @override
  String get detailExtracting => 'Extraction…';

  @override
  String get detailInstallingMod => 'Installation du mod…';

  @override
  String get detailInstallComplete => 'Installation terminée';

  @override
  String detailInstallFilesExtracted(int count, String dir) {
    return '$count fichiers extraits dans « $dir »';
  }

  @override
  String get detailInstallFailed => 'Échec de l’installation';

  @override
  String get detailOperationCancelled => 'Opération annulée';

  @override
  String detailDownloadingPct(String pct) {
    return 'Téléchargement $pct %';
  }

  @override
  String get detailInstalling => 'Installation…';

  @override
  String get overlayCancelling => 'Annulation…';

  @override
  String get detailDynosFolderNotSelected =>
      'Dossier DynOS et commandes tactiles non sélectionné';

  @override
  String get detailDynosFolderBody =>
      'Choisissez le dossier partagé DynOS et commandes tactiles dans Paramètres → Intégration au jeu avant d’installer ce contenu.';

  @override
  String get detailInstallDownloadedTitle =>
      'Installer le contenu téléchargé ?';

  @override
  String detailInstallDownloadedBody(String name) {
    return 'Le téléchargement de $name est terminé. L’installer maintenant dans le dossier DynOS et commandes tactiles ?';
  }

  @override
  String get detailInstallNow => 'Installer maintenant';

  @override
  String get detailKeepDownload => 'Pas maintenant';

  @override
  String detailDownloadedNotInstalled(String name) {
    return 'Téléchargé, mais pas installé : $name';
  }

  @override
  String detailInstallQueued(String name) {
    return 'Téléchargement et installation mis en attente : $name';
  }

  @override
  String get detailContentUnavailable =>
      'Ce téléchargement n’est plus disponible (404). Le lien a peut-être été retiré ou modifié.';

  @override
  String get detailFriendlyDownloadError =>
      'Le téléchargement n’a pas pu se terminer. Vérifiez votre connexion et réessayez.';

  @override
  String get detailScreenshots => 'Captures d’écran';

  @override
  String get detailYoutubeVideos => 'Vidéos YouTube';

  @override
  String get detailDirectVideos => 'Vidéos';

  @override
  String get detailTags => 'Tags';

  @override
  String get detailAbout => 'À propos';

  @override
  String get detailRating => 'Note';

  @override
  String get detailDownloads => 'Téléchargements';

  @override
  String get detailViews => 'Vues';

  @override
  String get detailReviews => 'Avis';

  @override
  String detailDownloadFiles(int count) {
    return 'Fichiers à télécharger ($count)';
  }

  @override
  String detailVersions(int count) {
    return 'Versions ($count)';
  }

  @override
  String get detailVersionFallback => 'v?';

  @override
  String get detailLatestVersion => 'DERNIÈRE VERSION';

  @override
  String get detailPreviousVersions => 'Versions précédentes';

  @override
  String detailViewPreviousVersions(int count) {
    return 'Voir $count versions précédentes';
  }

  @override
  String get detailNoDownloadFiles =>
      'Aucun fichier téléchargeable n’est disponible.';

  @override
  String get detailFirstRelease => 'Première publication';

  @override
  String get detailLastUpdate => 'Dernière mise à jour';

  @override
  String get detailChangelog => 'Historique des modifications';

  @override
  String get detailCollapseChangelog => 'Réduire l’historique';

  @override
  String detailViewAllUpdates(int count) {
    return 'Voir les $count mises à jour';
  }

  @override
  String get detailShowLess => 'Réduire';

  @override
  String get detailShowMore => 'Afficher plus';

  @override
  String get detailNotificationsDisabled =>
      'Notifications désactivées. La progression ne sera pas visible hors de l’application.';

  @override
  String get settingsTitle => 'PARAMÈTRES';

  @override
  String get settingsData => 'DONNÉES';

  @override
  String get settingsClearFavourites => 'Effacer les favoris';

  @override
  String get settingsClearFavouritesDesc => 'Retirer tous les mods enregistrés';

  @override
  String get settingsExportFavourites => 'Exporter les favoris';

  @override
  String get settingsExportFavouritesDesc => 'Partager vos mods enregistrés';

  @override
  String get settingsImportFavourites => 'Importer des favoris';

  @override
  String get settingsImportFavouritesDesc =>
      'Restaurer un fichier exporté précédemment';

  @override
  String get settingsGameIntegration => 'INTÉGRATION AU JEU';

  @override
  String get settingsAppearance => 'APPARENCE';

  @override
  String get settingsAbout => 'À PROPOS';

  @override
  String get settingsGoToReleases => 'Voir les versions publiées';

  @override
  String settingsViewAllVersions(String version) {
    return 'Toutes les versions sur GitHub · v$version';
  }

  @override
  String get settingsDataSource => 'Source des données';

  @override
  String get settingsNoFavouritesToExport =>
      'Vous n’avez aucun favori à exporter.';

  @override
  String settingsImportAdded(int count) {
    return '$count ajoutés';
  }

  @override
  String settingsImportAlreadySaved(int count) {
    return '$count déjà enregistrés';
  }

  @override
  String settingsImportNotFound(int count) {
    return '$count introuvables dans le catalogue';
  }

  @override
  String get settingsImportNothingNew => 'Aucun nouvel élément à importer.';

  @override
  String get settingsImportComplete => 'Importation terminée';

  @override
  String get settingsClearFavouritesTitle => 'EFFACER LES FAVORIS ?';

  @override
  String get settingsClearFavouritesBody =>
      'Tous vos mods enregistrés seront retirés des favoris. Cette action est irréversible.';

  @override
  String get settingsClearButton => 'EFFACER';

  @override
  String get settingsFavouritesCleared => 'Favoris effacés';

  @override
  String settingsCannotOpenUrl(String url) {
    return 'Impossible d’ouvrir le lien : $url';
  }

  @override
  String get settingsCancel => 'ANNULER';

  @override
  String get settingsModsFolderSelected =>
      'Dossier des mods sélectionné. Les mods seront installés ici.';

  @override
  String get settingsClearModsFolderTitle => 'OUBLIER LE DOSSIER DES MODS ?';

  @override
  String get settingsClearModsFolderBody =>
      'Vous devrez sélectionner à nouveau le dossier avant d’installer des mods dans le jeu.';

  @override
  String get settingsModsFolderCleared =>
      'Sélection du dossier des mods effacée.';

  @override
  String get settingsModsFolder => 'Dossier des mods';

  @override
  String get settingsSelectModsFolder => 'Choisir le dossier des mods';

  @override
  String get settingsModsFolderHint =>
      'Toucher pour changer · Appui long pour oublier';

  @override
  String get settingsModsFolderDesc =>
      'Choisissez où installer les mods téléchargés';

  @override
  String get settingsAutoInstall => 'Installer après le téléchargement';

  @override
  String get settingsAutoInstallOn =>
      'Les téléchargements seront installés automatiquement dans leur dossier de jeu configuré';

  @override
  String get settingsAutoInstallOff =>
      'Une confirmation sera demandée après chaque téléchargement';

  @override
  String get autoInstallPromptTitle =>
      'Installer les mods après téléchargement ?';

  @override
  String get autoInstallPromptBody =>
      'Activez l’installation automatique pour placer les mods téléchargés dans leur dossier de jeu configuré. Vous pourrez changer ce choix dans les paramètres.';

  @override
  String get autoInstallPromptEnable => 'Activer';

  @override
  String get autoInstallPromptDownloadOnly => 'Télécharger uniquement';

  @override
  String get settingsThemeMode => 'Mode d’affichage';

  @override
  String settingsDatabaseUpdated(int count, String date) {
    return 'Base mise à jour · $count mods$date';
  }

  @override
  String get settingsUnknownError => 'Erreur inconnue';

  @override
  String get settingsReloadDatabase => 'Actualiser la base de données';

  @override
  String get settingsDownloading => 'Téléchargement…';

  @override
  String get settingsDownloadLatest => 'Télécharger la dernière liste de mods';

  @override
  String settingsUpToDate(String version) {
    return 'Application à jour · v$version';
  }

  @override
  String get settingsCheckForUpdates => 'Rechercher des mises à jour';

  @override
  String get settingsChecking => 'Vérification…';

  @override
  String get generalSettings => 'Paramètres';

  @override
  String get generalRetry => 'Réessayer';

  @override
  String get linksTitle => 'LIENS';

  @override
  String get linksSubtitle => 'ET RESSOURCES';

  @override
  String get linksOfficiaSection => 'OFFICIEL';

  @override
  String get linksOfficialDesc => 'Canaux vérifiés du projet SM64CoopDX.';

  @override
  String get linksSm64cdpySection => 'SM64CDPY';

  @override
  String get linksSm64cdpyDesc =>
      'Téléchargements et contenu de cette application.';

  @override
  String get linksResourcesSection => 'RESSOURCES';

  @override
  String get linksResourcesDesc =>
      'Communauté, guides et installation étape par étape.';

  @override
  String get linksHeroTitle => 'LIENS UTILES';

  @override
  String get linksHeroDesc =>
      'Sites officiels, communauté et ressources du projet au même endroit.';

  @override
  String get linksChipTap => 'TOUCHER = OUVRIR';

  @override
  String get linksChipHold => 'APPUI LONG = COPIER';

  @override
  String get linksWebsite => 'Site SM64CoopDX';

  @override
  String get linksWebsiteUrl => 'sm64coopdx.com';

  @override
  String get linksAppWebsite => 'Site officiel SM64CDPY';

  @override
  String get linksAppWebsiteDesc =>
      'Actualités, téléchargements et informations sur le projet';

  @override
  String get linksKindWeb => 'WEB';

  @override
  String get linksDiscordServer => 'Serveur Discord';

  @override
  String get linksDiscordOfficial =>
      'Serveur officiel de la communauté · Android';

  @override
  String get linksKindDiscord => 'DISCORD';

  @override
  String get linksGithubRepo => 'Dépôt GitHub';

  @override
  String get linksGithubDesc => 'Code source et signalement de problèmes';

  @override
  String get linksKindGithub => 'GITHUB';

  @override
  String get linksGithubReleases => 'Versions sur GitHub';

  @override
  String get linksGithubReleasesDesc => 'Télécharger le dernier APK';

  @override
  String get linksKindDownload => 'TÉLÉCHARGEMENT';

  @override
  String get linksYoutubeChannel => 'Chaîne YouTube';

  @override
  String get linksYoutubeHandle => '@retired64';

  @override
  String get linksKindYoutube => 'YOUTUBE';

  @override
  String get linksDiscordCommunity => 'Serveur communautaire et assistance';

  @override
  String get linksWiki => 'Wiki et guides';

  @override
  String get linksWikiDesc => 'Guides d’installation et documentation';

  @override
  String get linksKindWiki => 'WIKI';

  @override
  String get linksTools => 'Outils et extensions';

  @override
  String get linksToolsDesc => 'Création de mods et ressources utiles';

  @override
  String get linksKindTools => 'OUTILS';

  @override
  String get linksCouldNotOpen => 'Impossible d’ouvrir le lien';

  @override
  String get linksCopied => 'Lien copié';

  @override
  String get disclaimerTitle => 'Informations légales';

  @override
  String get disclaimerDeveloperContact => 'Contacter le développeur';

  @override
  String get disclaimerDiscordReach => 'Contactez-moi sur mon serveur Discord';

  @override
  String get disclaimerDiscord => 'Discord';

  @override
  String disclaimerFooter(String version) {
    return 'v$version · usage personnel · Non officiel';
  }

  @override
  String get disclaimerUnofficialBanner => 'Création de fan non officielle';

  @override
  String get disclaimerAppSubtitle => 'Gestionnaire de mods SM64CoopDX';

  @override
  String get disclaimerWarningBody =>
      'SM64CDPY est un logiciel indépendant. Adressez vos questions, problèmes techniques et demandes concernant cette application au développeur de SM64CDPY, et non à Nintendo, à l’équipe SM64CoopDX ou aux auteurs des mods présentés.';

  @override
  String get disclaimerCouldNotOpenLink => 'Impossible d’ouvrir le lien';

  @override
  String get disclaimerSectionPersonalPurpose =>
      'À propos de cette application';

  @override
  String get disclaimerBodyPersonalPurpose =>
      'SM64CDPY est un catalogue et gestionnaire Android indépendant pour les mods SM64CoopDX créés par la communauté. Il permet de parcourir, télécharger, organiser et installer du contenu compatible dans les dossiers choisis par l’utilisateur. L’application ne distribue et n’installe ni Super Mario 64, ni fichiers ROM, ni SM64CoopDX, ni ses versions Android. Elle ne demande ni ne vérifie de fichiers de jeu et ne fournit pas d’instructions pour s’en procurer.';

  @override
  String get disclaimerSectionNoAffiliation => 'Aucune affiliation officielle';

  @override
  String get disclaimerBodyNoAffiliation =>
      'Ce projet n’est ni associé à Nintendo, à l’équipe SM64CoopDX ou aux auteurs des mods présentés, ni soutenu ou approuvé par eux. Les noms de produits et marques servent uniquement à indiquer la compatibilité. Titres, descriptions, images, fichiers et autres éléments crédités restent la propriété de leurs auteurs ou ayants droit respectifs.';

  @override
  String get disclaimerSectionDataSource => 'Source des données';

  @override
  String get disclaimerBodyDataSource =>
      'Le catalogue principal présente les publications publiques de la communauté Coop DX Mods (mods.sm64coopdx.com) en conservant l’auteur, le titre, les dates, les versions et la source publiés. SM64CDPY fournit une interface mobile et récupère les téléchargements depuis la source disponible pour chaque ressource. La présence au catalogue n’implique ni propriété ni approbation officielle de SM64CDPY.';

  @override
  String get disclaimerSectionExclusive =>
      'Sélections dédiées (VIP · DynOS · commandes tactiles)';

  @override
  String disclaimerBodyExclusive(Object version) {
    return 'Dans la v$version, les mods VIP, packs DynOS, dispositions tactiles, OMM Rebirth et Render96 peuvent provenir de sources sélectionnées indépendamment. Lorsque le contenu n’a pas été créé par le développeur de SM64CDPY, son créateur crédité en conserve la paternité. Ces sections sont distinctes du catalogue principal Coop DX Mods et ne sont pas des services officiels Nintendo ou SM64CoopDX.';
  }

  @override
  String get disclaimerSectionLocalData => 'Account et données locales';

  @override
  String get disclaimerBodyLocalData =>
      'SM64CDPY ne crée actuellement aucun compte utilisateur. Favoris, historique d’installation, dossiers sélectionnés et préférences sont stockés localement sur l’appareil. Désinstaller l’application ou effacer ses données peut supprimer ces informations.';

  @override
  String get disclaimerSectionExternalServices => 'Services externes';

  @override
  String get disclaimerBodyExternalServices =>
      'La navigation, l’actualisation des catalogues, l’ouverture des liens et les téléchargements peuvent se connecter à Coop DX Mods, GitHub, Google Drive, Dropbox ou GameBanana. Ces services appliquent leurs propres conditions et pratiques de confidentialité, que SM64CDPY ne contrôle pas.';

  @override
  String get disclaimerSectionBugs => 'Assistance et corrections du contenu';

  @override
  String get disclaimerBodyBugs =>
      'Contactez le développeur de SM64CDPY pour signaler un problème de l’application, une attribution incorrecte, des informations périmées ou un contenu à corriger ou retirer. Indiquez le titre du mod et sa source si nécessaire. Les demandes concernant l’application ne doivent pas être adressées à Nintendo, à l’équipe SM64CoopDX ou aux auteurs des mods.';

  @override
  String get vipSectionHeader => 'CONTENU EXCLUSIF';

  @override
  String get dynosSectionHeader => 'DYNOS PERSONNALISÉS';

  @override
  String get touchSectionHeader => 'DISPOSITIONS MOBILES';

  @override
  String get ommSectionHeader => 'MODS OMM REBIRTH';

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
  String get settingsDynosFolder => 'Dossier DynOS et commandes tactiles';

  @override
  String get settingsSelectDynosFolder => 'Choisir le dossier DynOS';

  @override
  String get settingsDynosFolderHint =>
      'Toucher pour changer · Appui long pour oublier';

  @override
  String get settingsDynosFolderDesc =>
      'Choisissez où installer les packs DynOS et commandes tactiles';

  @override
  String get settingsDynosFolderSelected =>
      'Dossier DynOS et commandes tactiles sélectionné. Les deux types de contenu seront installés ici.';

  @override
  String get settingsClearDynosFolderTitle => 'OUBLIER LE DOSSIER DYNOS ?';

  @override
  String get settingsClearDynosFolderBody =>
      'Vous devrez choisir à nouveau le dossier avant d’installer des packs DynOS ou de commandes tactiles.';

  @override
  String get settingsDynosFolderCleared =>
      'Sélection du dossier DynOS effacée.';

  @override
  String get settingsLanguageMode => 'Langue';

  @override
  String get languageFollowSystem => 'Langue du système';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get overlaySearchHint => 'RECHERCHER…';

  @override
  String get overlayChooseFile => 'Choisir un fichier';

  @override
  String overlayFileFallback(int number) {
    return 'Fichier $number';
  }

  @override
  String get overlayNoResponse =>
      'Aucune réponse : ouvrez l’application principale une fois, puis réessayez';

  @override
  String get overlaySelectFolder =>
      'Choisissez d’abord un dossier dans les paramètres';

  @override
  String get overlayEnableAutoInstall =>
      'Activez d’abord l’installation automatique dans les paramètres';

  @override
  String get overlayDownloadFailed => 'Échec du téléchargement';

  @override
  String get overlayTapToCancel => 'TOUCHER POUR ANNULER';

  @override
  String get overlayInstalling => 'Installation…';

  @override
  String get overlayConnecting => 'Connexion…';

  @override
  String get overlayNoResults => 'AUCUN RÉSULTAT';

  @override
  String get overlayError => 'ERREUR';

  @override
  String get settingsOverlayActive => 'Bulle flottante active';

  @override
  String get settingsOverlayInactive => 'Bulle flottante';

  @override
  String get settingsOverlayActiveDesc => 'Touchez pour masquer la bulle';

  @override
  String get settingsOverlayInactiveDesc =>
      'Touchez pour afficher la bulle au-dessus du jeu';

  @override
  String get navRender96 => 'Render96';

  @override
  String get render96Title => 'RENDER96';

  @override
  String get render96SectionHeader => 'COLLECTION EXCLUSIVE';

  @override
  String get render96Empty => 'BIENTÔT DISPONIBLE';

  @override
  String get render96EmptyHint => 'Le nouveau contenu Render96 apparaîtra ici.';

  @override
  String get render96FailedToLoad => 'CHARGEMENT IMPOSSIBLE';

  @override
  String get navLibrary => 'Bibliothèque';

  @override
  String get libraryTitle => 'BIBLIOTHÈQUE';

  @override
  String get libraryInstalled => 'Installés';

  @override
  String get libraryUpdates => 'Mises à jour';

  @override
  String get libraryRecent => 'Récents';

  @override
  String get libraryViewAll => 'Tout voir';

  @override
  String get libraryRefresh => 'Actualiser la bibliothèque';

  @override
  String get libraryAllSections => 'Toutes les sections';

  @override
  String get libraryAllDestinations => 'Tous les dossiers';

  @override
  String get libraryModsDestination => 'Dossier des mods';

  @override
  String get libraryDynosDestination => 'Dossier DynOS';

  @override
  String get libraryPresent => 'Installé';

  @override
  String get libraryMissing => 'Absent';

  @override
  String get libraryPermissionRevoked => 'Autorisation requise';

  @override
  String get libraryFolderNotSelected => 'Dossier requis';

  @override
  String get libraryNotVerified => 'Non vérifié';

  @override
  String get libraryOpenSource => 'OUVRIR LE CONTENU';

  @override
  String get libraryEmptyTitle => 'AUCUNE INSTALLATION POUR LE MOMENT';

  @override
  String get libraryEmptyBody =>
      'Les mods installés par SM64CDPY apparaîtront ici.';

  @override
  String get libraryUpdatesEmptyTitle => 'AUCUNE MISE À JOUR CONNUE';

  @override
  String get libraryUpdatesEmptyBody =>
      'Les mises à jour confirmées par le catalogue apparaîtront ici. Vous pouvez aussi consulter chaque section de contenu.';

  @override
  String get libraryDiscoveryHeaderIdentified => 'En-tête identifié';

  @override
  String get libraryDiscoveryProbable => 'Mod probable';

  @override
  String get libraryDiscoveryUnlinked => 'Lua non associé';

  @override
  String get libraryErrorTitle => 'BIBLIOTHÈQUE INDISPONIBLE';

  @override
  String get libraryErrorBody =>
      'Impossible de lire l’historique d’installation. Réessayez sans modifier les fichiers du jeu.';

  @override
  String get libraryPartialWarning =>
      'Certains enregistrements sont illisibles. Les installations valides restent affichées.';

  @override
  String get libraryCatalogLoading => 'Vérification du catalogue actuel…';

  @override
  String get libraryCatalogError =>
      'Impossible de vérifier le catalogue. Le contenu installé reste disponible.';

  @override
  String libraryUpdateVersions(String installed, String available) {
    return '$installed → $available';
  }

  @override
  String get libraryEventInstall => 'Installé';

  @override
  String get libraryEventUpdate => 'Mis à jour';

  @override
  String get libraryEventReinstall => 'Réinstallé';

  @override
  String get libraryEventReplaced => 'Remplacé par une version plus récente';

  @override
  String get libraryForgetAction => 'OUBLIER L’INSTALLATION';

  @override
  String get libraryForgetTitle => 'OUBLIER CETTE INSTALLATION ?';

  @override
  String get libraryForgetBody =>
      'SM64CDPY retirera cet élément de la bibliothèque sans supprimer les fichiers du jeu.';

  @override
  String get libraryForgetConfirm => 'OUBLIER';

  @override
  String get libraryRemoveHistoryAction => 'RETIRER DE L’HISTORIQUE';

  @override
  String get libraryRemoveHistoryTitle => 'RETIRER CET ÉVÉNEMENT ?';

  @override
  String get libraryRemoveHistoryBody =>
      'Seule cette entrée sera retirée de l’historique. L’installation actuelle et les fichiers du jeu ne changeront pas.';

  @override
  String get libraryRemoveHistoryConfirm => 'RETIRER';

  @override
  String get libraryMaintenanceError =>
      'Impossible d’actualiser la bibliothèque. Réessayez.';

  @override
  String get detailOpenExternalFolder => 'OUVRIR LE DOSSIER SOURCE';

  @override
  String get detailSourceUnavailable =>
      'Cette version n’a aucun fichier téléchargeable disponible actuellement.';

  @override
  String get detailViewDiscussion => 'VOIR LA DISCUSSION COMMUNAUTAIRE';

  @override
  String get settingsInterfaceTheme => 'Thème de l’interface';

  @override
  String get settingsInterfaceThemeDesc =>
      'Choisissez un thème inclus. Il s’applique à l’application ; le panneau flottant conserve son thème sombre.';

  @override
  String get themeMinimal => 'Minimaliste';

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
  String get themeModeLight => 'Clair';

  @override
  String get themeModeDark => 'Sombre';

  @override
  String get themeModeSystem => 'Suivre le système';

  @override
  String get themeSaveFailed =>
      'Impossible d’enregistrer l’apparence. Réessayez.';

  @override
  String get themeSaving => 'Enregistrement de l’apparence';

  @override
  String get gameModsTitle => 'Mods du jeu';

  @override
  String get gameModsSubtitle =>
      'Choisissez les mods pour le prochain lancement';

  @override
  String get gameModsHint =>
      'Fermez le jeu avant toute modification. Ces interrupteurs configurent les mods Lua et packs DynOS/commandes tactiles pour le prochain lancement.';

  @override
  String get gameModsSelectHint =>
      'Choisissez le dossier user du jeu contenant sm64config.txt et mods.';

  @override
  String get gameModsConfirm =>
      'Fermez d’abord le jeu. Appliquer cette sélection pour le prochain lancement ?';

  @override
  String get gameModsCancel => 'Annuler';

  @override
  String get gameModsApply => 'Appliquer';

  @override
  String get gameModsSelect => 'Choisir le dossier user';

  @override
  String get gameModsDisconnect => 'Déconnecter';

  @override
  String get gameModsConflict =>
      'La configuration a changé ou un autre mod activé est incompatible. Actualisez et réessayez.';

  @override
  String get gameModsBlocked =>
      'Impossible d’activer ce mod en toute sécurité. Vérifiez sa structure et ses métadonnées ou désactivez un mod incompatible.';

  @override
  String get gameModsMismatch =>
      'Ce dossier user ne correspond pas au dossier des mods sélectionné. Choisissez la même installation du jeu.';

  @override
  String get gameModsWriteError =>
      'Impossible de confirmer l’enregistrement. Fermez le jeu et restaurez la configuration précédente si nécessaire.';

  @override
  String get gameModsFormat =>
      'La configuration ou le dossier dépasse les limites prises en charge ou utilise un format incompatible. Aucune modification n’a été appliquée.';

  @override
  String get gameModsAccess =>
      'Configuration indisponible. Vérifiez que user contient sm64config.txt et mods, puis sélectionnez à nouveau le dossier avec accès en lecture et écriture.';

  @override
  String get gameModsRestore => 'Restaurer la configuration précédente';

  @override
  String get gameModsRestoreConfirm =>
      'Le jeu fermé, remplacer la configuration par la sauvegarde privée créée avant la dernière modification ? Les autres paramètres seront également restaurés.';

  @override
  String get gameModsInstalling =>
      'Attendez la fin des téléchargements et installations avant de modifier les mods du jeu.';

  @override
  String get gameModsEmpty =>
      'Aucun mod Lua compatible trouvé dans les dossiers du jeu.';

  @override
  String get gameModsEnabled => 'Activé au prochain lancement';

  @override
  String get gameModsDisabled => 'Désactivé au prochain lancement';

  @override
  String get gameModsMore => 'Afficher plus';

  @override
  String get gameModsSize =>
      'Ce mod atteint la limite de 35 Mio du jeu et ne peut pas être activé.';

  @override
  String get gameModsSaved =>
      'Sélection enregistrée et vérifiée pour le prochain lancement du jeu.';

  @override
  String get gameModsManage => 'Gérer le dossier du jeu';

  @override
  String gameModsCount(int enabled, int total) {
    return '$enabled sur $total activés';
  }

  @override
  String get gameModsSearch => 'Rechercher mods, auteurs, catégories…';

  @override
  String get gameModsAll => 'Tous';

  @override
  String get gameModsEnabledFilter => 'Activés';

  @override
  String get gameModsDisabledFilter => 'Désactivés';

  @override
  String get gameModsNoResults =>
      'Aucun mod ne correspond à cette recherche ou à ce filtre.';

  @override
  String get gameModsClearSearch => 'Effacer la recherche';

  @override
  String get gameModsDetails => 'Détails du mod';

  @override
  String get gameModsCloseDetails => 'Fermer';

  @override
  String get marioRomTitle => 'Ressources du jeu original';

  @override
  String get marioRomBuiltIn => 'ROM non sélectionnée';

  @override
  String get marioRomReady => 'Interface originale prête';

  @override
  String get marioRomDescription =>
      'Les thèmes Mario utilisent la ROM du dossier user connecté. Les images et polices sont préparées une seule fois en privé, puis réutilisées. Aucune sélection de ROM distincte n’est nécessaire.';

  @override
  String get marioRomImport => 'Préparer depuis le dossier du jeu';

  @override
  String get marioRomPreparing => 'Préparation des ressources du jeu…';

  @override
  String get marioRomCancel => 'Annuler l’importation';

  @override
  String get marioRomRemove => 'Utiliser le thème intégré';

  @override
  String get marioRomUnsupported =>
      'Cette ROM n’est pas compatible. Choisissez une ROM USA .z64 non modifiée. Votre thème précédent reste disponible.';

  @override
  String get marioRomFailed =>
      'Impossible de lire ou d’enregistrer les ressources. Sélectionnez à nouveau le fichier et vérifiez l’espace disponible. Votre thème précédent reste disponible.';

  @override
  String get marioRomSuccess => 'Les ressources du jeu original sont prêtes.';

  @override
  String get marioRomUpgrade =>
      'Sélectionnez à nouveau la ROM pour actualiser l’interface originale';

  @override
  String get gameFolderTitle => 'Connecter SM64CoopDX';

  @override
  String get gameFolderSummary =>
      'Choisissez une seule fois le dossier principal du jeu pour trouver les mods et packs DynOS dans user et en dehors, ainsi que la ROM pour les thèmes Mario.';

  @override
  String get gameFolderGuide =>
      'Choisissez le dossier principal com.maniscat2.sm64coopdx, celui qui contient user. Nous chercherons mods et dynos/packs ici et dans user. La configuration, la ROM et les nouvelles installations restent dans user. Choisissez le dossier principal, pas user ni un fichier individuel.';

  @override
  String get gameFolderChoose => 'Choisir le dossier du jeu';

  @override
  String get gameFolderLater => 'Pas maintenant';

  @override
  String get gameFolderConnected => 'Jeu connecté';

  @override
  String get gameFolderResolved =>
      'Bibliothèque : mods, user/mods, dynos/packs et user/dynos/packs. Nouvelles installations : user/mods et user/dynos/packs.';

  @override
  String get gameFolderConfigReady => 'Paramètres des mods du jeu trouvés.';

  @override
  String get gameFolderConfigMissing =>
      'Ouvrez le jeu une fois pour créer les paramètres des mods. Les téléchargements et thèmes restent disponibles.';

  @override
  String get gameFolderRomFound =>
      'ROM du jeu trouvée. Les thèmes Mario pourront préparer leurs ressources lors de leur sélection.';

  @override
  String get gameFolderRomMissing =>
      'Aucune ROM compatible trouvée dans user. Ouvrez SM64CoopDX et configurez sa ROM, puis réessayez.';

  @override
  String get gameFolderChange => 'Changer de dossier du jeu';

  @override
  String get gameFolderInvalid =>
      'Choisissez le dossier principal contenant user, généralement com.maniscat2.sm64coopdx. Ouvrez le jeu une fois si user n’existe pas encore.';

  @override
  String get gameFolderAccessLost =>
      'Le dossier du jeu est inaccessible. Sélectionnez-le à nouveau pour le reconnecter.';

  @override
  String get gameFolderDisconnect => 'Déconnecter le jeu';

  @override
  String get gameFolderDisconnectBody =>
      'Cesser d’utiliser ce dossier pour les mods, DynOS et la détection de ROM. Les fichiers du jeu, mods installés et ressources de thème préparées resteront sur l’appareil.';

  @override
  String get gameFolderPrepareTitle => 'Préparer le thème Mario';

  @override
  String get gameFolderPrepareBody =>
      'Nous lirons la ROM du dossier connecté pour préparer les images et polices du thème. Cette opération n’est nécessaire qu’une fois ; la ROM et la configuration du jeu resteront inchangées.';

  @override
  String get gameFolderPrepare => 'Préparer le thème';

  @override
  String get gameFolderBusy =>
      'Attendez la fin des téléchargements et installations avant de changer le dossier du jeu.';

  @override
  String get gameModsLuaType => 'Mods Lua';

  @override
  String get gameModsDynosType => 'DynOS / commandes tactiles';

  @override
  String get gameFolderUpgrade =>
      'L’accès est limité à user. Choisissez le dossier principal pour inclure aussi les mods et packs DynOS situés en dehors de user.';

  @override
  String get gameDynosEmpty =>
      'Aucun dossier de pack DynOS ou de commandes tactiles trouvé dans les dossiers du jeu.';

  @override
  String get gameDynosSearch =>
      'Rechercher des packs DynOS / commandes tactiles…';

  @override
  String get navPlayer => 'Joueur';

  @override
  String get playerTitle => 'JOUEUR';

  @override
  String get playerCharacter => 'PERSONNAGE';

  @override
  String get player3DLoading => 'Création de votre personnage à partir du jeu…';

  @override
  String get player3DUnavailable =>
      'L’aperçu 3D est indisponible. Vérifiez que SM64CoopDX et une ROM USA compatible sont connectés.';

  @override
  String get playerName => 'Nom du joueur';

  @override
  String get playerNameHint => 'Nom affiché dans SM64CoopDX';

  @override
  String get playerCloseGameHint =>
      'Fermez SM64CoopDX avant d’appliquer. Les changements seront utilisés au prochain lancement.';

  @override
  String get playerPresets => 'PALETTES';

  @override
  String get playerParts => 'COULEURS DU PERSONNAGE';

  @override
  String get playerUnsavedTitle => 'Abandonner les modifications ?';

  @override
  String get playerUnsavedBody =>
      'Les couleurs ou le nom du joueur n’ont pas été appliqués au jeu.';

  @override
  String get playerKeepEditing => 'Continuer à modifier';

  @override
  String get playerDiscard => 'Abandonner';

  @override
  String get playerDeletePreset => 'Supprimer la palette ?';

  @override
  String playerDeletePresetBody(String name) {
    return 'Supprimer votre palette « $name » ?';
  }

  @override
  String get playerCancel => 'Annuler';

  @override
  String get playerDelete => 'Supprimer';

  @override
  String get playerConflict =>
      'La configuration du jeu a changé. Rechargez-la avant d’appliquer votre profil.';

  @override
  String get playerInvalid =>
      'Saisissez un nom et des couleurs valides. Le nom ne peut pas contenir d’espaces ni dépasser 63 octets UTF-8.';

  @override
  String get playerPresetExists => 'Une palette porte déjà ce nom.';

  @override
  String get playerAccessError =>
      'La configuration du joueur est inaccessible. Vérifiez le dossier du jeu connecté et son autorisation.';

  @override
  String get playerSavePreset => 'Enregistrer la palette';

  @override
  String get playerPresetName => 'Nom de la palette';

  @override
  String get playerSave => 'Enregistrer';

  @override
  String playerOverwritePreset(String name) {
    return 'Remplacer votre palette « $name » ?';
  }

  @override
  String get playerOverwrite => 'Remplacer';

  @override
  String get playerPresetSaved => 'Palette enregistrée pour SM64CoopDX.';

  @override
  String get playerApplied =>
      'Profil enregistré et vérifié pour le prochain lancement du jeu.';

  @override
  String get playerConnectGame =>
      'Connectez le dossier principal SM64CoopDX pour modifier le joueur.';

  @override
  String get playerMissingConfig =>
      'Ouvrez SM64CoopDX une fois pour créer user/sm64config.txt.';

  @override
  String get playerRetry => 'Réessayer';

  @override
  String get playerHex => 'Couleur hexadécimale';

  @override
  String get playerRed => 'R';

  @override
  String get playerGreen => 'V';

  @override
  String get playerBlue => 'B';

  @override
  String get playerReset => 'Réinitialiser';

  @override
  String get playerApply => 'Appliquer au jeu';

  @override
  String get playerPants => 'Salopette';

  @override
  String get playerShirt => 'Chemise';

  @override
  String get playerGloves => 'Gants';

  @override
  String get playerShoes => 'Chaussures';

  @override
  String get playerHair => 'Cheveux';

  @override
  String get playerSkin => 'Peau';

  @override
  String get playerCap => 'Casquette';

  @override
  String get playerEmblem => 'Emblème';

  @override
  String get playerRestore => 'Restaurer la configuration précédente';

  @override
  String get playerRestoreBody =>
      'SM64CoopDX fermé, restaurer la sauvegarde privée créée avant la dernière modification des mods ou du joueur ? Toute la configuration sera restaurée.';

  @override
  String get playerRestored => 'Configuration précédente du jeu restaurée.';

  @override
  String get retroAccentTitle => 'Couleur d’accent de l’interface';

  @override
  String get retroAccentDescription =>
      'Choisissez la couleur d’accent de Retro Manga ou Mario Kart 64. MK64 l’utilise aussi pour le fond, les panneaux et la grille de course.';

  @override
  String get retroAccentCyan => 'Cyan';

  @override
  String get retroAccentBlue => 'Bleu';

  @override
  String get retroAccentViolet => 'Violet';

  @override
  String get retroAccentPink => 'Rose';

  @override
  String get retroAccentCoral => 'Corail';

  @override
  String get retroAccentAmber => 'Ambre';

  @override
  String get retroAccentGreen => 'Vert';

  @override
  String get retroAccentLime => 'Vert citron';

  @override
  String get gameToolTitle => 'Outils du jeu';

  @override
  String get saveFileTitle => 'Sauvegardes';

  @override
  String get saveFileHint => 'Choisir un fichier · jeu original';

  @override
  String get saveFileConfirm =>
      'Fermez d’abord SM64CoopDX. Les changements s’appliquent au prochain lancement. Copier et effacer affectent les progressions normale et alternative de l’emplacement choisi. Restaurer remplace les quatre emplacements. Une sauvegarde complète est créée avant toute écriture.';

  @override
  String get saveFileDone => 'Enregistré';

  @override
  String get saveFileMissing =>
      'Connectez le dossier du jeu et lancez le jeu une fois pour créer son fichier de sauvegarde.';

  @override
  String get saveFileError =>
      'Impossible de vérifier ou d’enregistrer le fichier. Actualisez et réessayez ; les copies de récupération restent dans Copies de secours.';

  @override
  String get saveFilePrimary => 'Normale';

  @override
  String get saveFileAlternate => 'Alternative';

  @override
  String get saveFileEmpty => 'Vide';

  @override
  String get saveFileUnsigned => 'Copie non signée ou endommagée';

  @override
  String get saveFileCopy => 'Copier';

  @override
  String get saveFileProgress => 'Progression';

  @override
  String get saveFileBackup => 'Créer une copie de secours';

  @override
  String get saveFileBackups => 'Copies de secours';

  @override
  String get saveFileCannon => 'Canon';

  @override
  String get saveFileCoins => 'Pièces';

  @override
  String get saveFileCastle => 'Étoiles du château';

  @override
  String get saveFileUnlocks => 'Déblocages';

  @override
  String get saveFileWing => 'Casquette ailée';

  @override
  String get saveFileMetal => 'Casquette de métal';

  @override
  String get saveFileVanish => 'Casquette d’invisibilité';

  @override
  String get saveFileKey1 => 'Première clé';

  @override
  String get saveFileKey2 => 'Deuxième clé';

  @override
  String get saveFileBasement => 'Porte du sous-sol';

  @override
  String get saveFileUpstairs => 'Porte de l’étage';

  @override
  String get saveFileMoat => 'Vider les douves';

  @override
  String get saveFileComplete => 'Compléter la progression : 120 étoiles';

  @override
  String get saveFileClearStars => 'Effacer les étoiles';

  @override
  String get saveFileCourseNames =>
      'Bataille de Bob-omb|Forteresse de Whomp|Baie des pirates|Montagne enneigée|Manoir de Big Boo|Caverne labyrinthique|Terre de lave|Désert mouvant|Quais sombres|Pays du bonhomme de neige|Ville sèche et humide|Haute montagne|Île grande et petite|Horloge|Route arc-en-ciel|Bowser dans le monde obscur|Bowser dans la mer de feu|Bowser dans le ciel|Toboggan secret de la princesse|Caverne de la casquette de métal|Tour de la casquette ailée|Casquette invisible sous les douves|Mario ailé au-dessus de l’arc-en-ciel|Aquarium secret';

  @override
  String get saveFileCopies => 'Progression du jeu';

  @override
  String get saveFileCopiesHint =>
      'Normale correspond à votre progression habituelle. Certains mods utilisent Alternative pour des modes spéciaux, comme un mode difficile. Ce n’est pas une copie de secours. La sélectionner ici ne change pas la progression utilisée par le jeu.';

  @override
  String get saveFileOpenSlot => 'Toucher pour modifier';

  @override
  String get saveFileActions => 'Actions de l’emplacement';

  @override
  String get saveFileDraft => 'Aperçu · enregistré uniquement après Appliquer';

  @override
  String get drawerResources => 'Ressources';

  @override
  String get fastInstallTitle => 'Accélérer l’installation';

  @override
  String get fastInstallDescription =>
      'Facultatif : autorisez l’accès à tous les fichiers dans Android pour accélérer l’installation dans les dossiers compatibles. Sans cette autorisation, l’installation fonctionne normalement.';

  @override
  String get fastInstallAccessError =>
      'Impossible d’ouvrir les paramètres d’autorisation. Vous pouvez continuer les installations normalement.';

  @override
  String get playGuideTitle => 'Comment jouer';

  @override
  String get playGuideIntro =>
      'Votre première aventure, étape par étape. Commencez par le jeu, puis ajoutez vos mods ici.';

  @override
  String get playGuideNext => 'Étape suivante';

  @override
  String get playGuideBack => 'Étape précédente';

  @override
  String get playGuideOpenDownload => 'Ouvrir les téléchargements Android';

  @override
  String get playGuideRepository => 'Dépôt du portage Android';

  @override
  String get playGuideConnect => 'Connecter le dossier du jeu';

  @override
  String get playGuideLibrary => 'Ouvrir la bibliothèque';

  @override
  String get playGuideLaunch => 'Ouvrir le jeu';

  @override
  String get playGuideMissingTitle => 'Préparons votre jeu';

  @override
  String get playGuideMissingBody =>
      'SM64CoopDX Android n’est pas installé. Suivez le guide pour l’installer, préparer votre ROM et connecter vos mods.';

  @override
  String get playGuideRead => 'Voir le guide de démarrage';

  @override
  String get playGuideLater => 'Pas maintenant';

  @override
  String get playGuideLinkError =>
      'Impossible d’ouvrir la page. Vérifiez votre connexion et réessayez.';

  @override
  String get playGuideLaunchError =>
      'Le jeu est installé, mais Android n’a pas pu l’ouvrir. Essayez son icône sur l’écran d’accueil.';

  @override
  String get playGuideInstalled => 'Jeu installé';

  @override
  String get playGuideNotInstalled => 'Jeu pas encore détecté';

  @override
  String get playGuideConnected => 'Dossier du jeu connecté';

  @override
  String get playGuideNotConnected => 'Dossier du jeu pas encore connecté';

  @override
  String get playGuideReady =>
      'L’aventure vous attend ! Vous pouvez revoir chaque étape quand vous en avez besoin.';

  @override
  String get playGuideStep1Title => 'Obtenir le jeu';

  @override
  String get playGuideStep2Title => 'Préparer votre propre ROM';

  @override
  String get playGuideConvertTitle => 'Convertir ma ROM (.n64 / .v64)';

  @override
  String get playGuideStep3Title => 'Fournir la ROM au jeu';

  @override
  String get playGuideStep4Title => 'Connecter le gestionnaire';

  @override
  String get playGuideStep5Title => 'Ajouter votre premier mod';

  @override
  String get playGuidePathsTitle => 'Où vont les fichiers ?';

  @override
  String get playGuideStep6Title => 'Jouer et trouver de l’aide';

  @override
  String get playGuideMap => 'La carte de votre aventure';

  @override
  String get playGuideSwipe =>
      'Balayez à gauche ou à droite pour changer de chapitre';

  @override
  String get playGuideChapter => 'CHAPITRE';

  @override
  String get playGuideTip => 'À retenir';

  @override
  String get playGuideOverview => 'Toutes les étapes';

  @override
  String get playGuideS1Card1 =>
      'SM64CDPY gère les mods. SM64CoopDX Android est l’application distincte qui fait fonctionner le jeu.';

  @override
  String get playGuideS1Card2 =>
      'Touchez Ouvrir les téléchargements Android. Votre navigateur ouvrira la page GitHub du portage Android.';

  @override
  String get playGuideS1Card3 =>
      'Trouvez la version publiée et développez Assets si nécessaire. Téléchargez le fichier se terminant par .apk, pas Source code. Si plusieurs versions sont proposées, suivez les exigences indiquées pour votre appareil.';

  @override
  String get playGuideS1Card4 =>
      'Ouvrez l’APK téléchargé et touchez Installer. Si Android le demande, autorisez ce navigateur ou gestionnaire de fichiers à installer cet APK, puis reprenez l’installation.';

  @override
  String get playGuideS1Card5 =>
      'Ouvrez SM64CoopDX une fois. Suivez ses instructions de stockage pour qu’il crée son dossier de jeu.';

  @override
  String get playGuideS1Card6 =>
      'Si les demandes d’Android vous semblent peu claires, demandez de l’aide à une personne de confiance.';

  @override
  String get playGuideS2Card1 =>
      'La ROM est une copie de la cartouche originale de Super Mario 64. L’APK seul ne contient pas les images et sons du jeu original.';

  @override
  String get playGuideS2Card2 =>
      'Utilisez votre propre copie USA non modifiée au format .z64. Ce guide ne fournit pas de ROM. Un ZIP est une archive : extrayez-le d’abord pour voir le fichier qu’il contient.';

  @override
  String get playGuideS2Card3 => 'Déjà en .z64 ? Passez à l’étape suivante.';

  @override
  String get playGuideS2Card4 =>
      'Le fichier se termine par .n64 ou .v64 ? Ouvrez « Convertir ma ROM » ci-dessous.';

  @override
  String get playGuideS2Card5 =>
      'Autre région ou jeu modifié ? Changer son nom ou son format n’en fera pas un original USA.';

  @override
  String get playGuideS3Card1 => 'Ouvrez SM64CoopDX Android.';

  @override
  String get playGuideS3Card2 =>
      'S’il demande une ROM, choisissez votre fichier USA .z64, généralement dans Téléchargements. Laissez le jeu terminer sa préparation.';

  @override
  String get playGuideS3Card3 =>
      'Si votre version n’a pas de sélecteur, fermez le jeu. Avec votre gestionnaire de fichiers, copiez le .z64 dans Stockage interne → com.maniscat2.sm64coopdx → user. Rouvrez le jeu.';

  @override
  String get playGuideS3Card4 =>
      'Attendez de pouvoir accéder au menu du jeu. Si la ROM est refusée, vérifiez la région, le contenu original non modifié et la véritable conversion en .z64.';

  @override
  String get playGuideS3Card5 =>
      'Le jeu conserve sa ROM USA acceptée dans user/baserom.us.z64. Le dossier peut dépendre des autorisations de stockage du jeu ; suivez l’emplacement qu’il vous indique.';

  @override
  String get playGuideS4Card1 =>
      'Revenez dans SM64CDPY et touchez Connecter le dossier du jeu. Nous expliquons quoi choisir avant d’ouvrir la fenêtre de dossiers Android.';

  @override
  String get playGuideS4Card2 =>
      'Ouvrez Stockage interne → com.maniscat2.sm64coopdx.';

  @override
  String get playGuideS4Card3 =>
      'Sélectionnez ce dossier principal, celui contenant user, puis touchez Utiliser ce dossier / Autoriser. Ne choisissez ni Téléchargements, ni user seul, ni le fichier ROM.';

  @override
  String get playGuideS4Card4 =>
      'Une sélection connecte mods, DynOS, paramètres du jeu et détection de ROM. Si user manque, ouvrez et préparez d’abord le jeu. Si Android bloque l’accès, vérifiez le stockage du jeu ; choisir un dossier vide sans rapport ne résoudra pas le problème.';

  @override
  String get playGuideS4Card5 =>
      'Déjà connecté ? Continuez. Vous n’avez pas besoin de choisir les mêmes dossiers pour chaque mod.';

  @override
  String get playGuideS5Card1 =>
      'Fermez le jeu avant d’installer ou de modifier des mods.';

  @override
  String get playGuideS5Card2 =>
      'Ouvrez Catalogue et choisissez un mod. Lisez ses notes de compatibilité.';

  @override
  String get playGuideS5Card3 =>
      'Téléchargez-le. Si l’installation automatique est activée, attendez Installé : la fin du téléchargement ne signifie pas la fin de l’installation. Sinon, suivez la demande d’installation manuelle ou activez l’option dans Paramètres.';

  @override
  String get playGuideS5Card4 =>
      'Ouvrez Outils du jeu → Bibliothèque. Mods du jeu contient les mods Lua. DynOS / commandes tactiles contient les packs de modèles, textures et commandes. Activez l’élément souhaité.';

  @override
  String get playGuideS5Card5 =>
      'Rouvrez le jeu pour charger vos modifications. Certains packs nécessitent des réglages dans le jeu ; suivez les instructions de l’auteur.';

  @override
  String get playGuideS6Card1 =>
      'Touchez Ouvrir le jeu ci-dessous. Choisissez un emplacement de sauvegarde dans le jeu et profitez de l’aventure.';

  @override
  String get playGuideS6Card2 =>
      'Le jeu ne s’ouvre pas ? Essayez d’abord depuis l’écran d’accueil Android.';

  @override
  String get playGuideS6Card3 =>
      'ROM refusée ? Revérifiez l’original USA et le format .z64 à l’étape 2.';

  @override
  String get playGuideS6Card4 =>
      'Mod absent ? Vérifiez la fin de l’installation, activez-le dans la bibliothèque et redémarrez le jeu. Vérifiez s’il dépend d’un autre mod.';

  @override
  String get playGuideS6Card5 =>
      'Accès au dossier perdu ? Reconnectez le dossier principal du jeu à l’étape 4.';

  @override
  String get playGuideS6Card6 =>
      'Essayez un mod à la fois. En cas de problème, désactivez-le puis rouvrez le jeu. Gardez une copie de secours avant de supprimer des fichiers du jeu.';

  @override
  String get playGuideConvertCard1 =>
      'Conservez votre fichier original comme copie de secours.';

  @override
  String get playGuideConvertCard2 =>
      'Ouvrez le convertisseur de ROM dans le navigateur.';

  @override
  String get playGuideConvertCard3 =>
      'Choisissez votre propre fichier .n64 ou .v64.';

  @override
  String get playGuideConvertCard4 =>
      'Choisissez .z64 comme format de sortie et enregistrez le fichier converti, généralement dans Téléchargements.';

  @override
  String get playGuideConvertCard5 =>
      'Revenez ici et continuez avec ce fichier .z64.';

  @override
  String get playGuideConvertCard6 =>
      'La conversion réorganise les octets du fichier. Renommer .n64 en .z64 ne le convertit pas. Cet outil est externe ; s’il est indisponible, utilisez un autre convertisseur d’ordre des octets N64 proposant une sortie .z64.';

  @override
  String get playGuidePathsCard1 =>
      'Dans Stockage interne → com.maniscat2.sm64coopdx :';

  @override
  String get playGuidePathsCard2 =>
      'user/mods → nouvelles installations de mods Lua. Un mod peut être un fichier .lua ou un dossier contenant main.lua.';

  @override
  String get playGuidePathsCard3 =>
      'user/dynos/packs → nouveaux packs DynOS et commandes tactiles. Les commandes tactiles partagent cet emplacement.';

  @override
  String get playGuidePathsCard4 =>
      'user/baserom.us.z64 → ROM USA originale acceptée par le jeu.';

  @override
  String get playGuidePathsCard5 =>
      'user/sm64config.txt → paramètres du jeu et éléments activés. Laissez l’application le gérer plutôt que de le modifier à la main.';

  @override
  String get playGuidePathsCard6 =>
      'Le jeu lit aussi mods et dynos/packs en dehors de user. Ce gestionnaire les affiche lorsque le dossier principal est connecté. En cas de noms identiques, Lua privilégie user/mods ; DynOS privilégie dynos/packs à l’extérieur de user. Évitez deux copies portant le même nom.';

  @override
  String get playGuideS1Title1 => 'Deux applications, deux rôles';

  @override
  String get playGuideS1Title2 => 'Ouvrir la page Android';

  @override
  String get playGuideS1Title3 => 'Choisir l’APK';

  @override
  String get playGuideS1Title4 => 'Installer le jeu';

  @override
  String get playGuideS1Title5 => 'L’ouvrir une fois';

  @override
  String get playGuideS1Title6 => 'Un coup de main';

  @override
  String get playGuideS2Title1 => 'Qu’est-ce qu’une ROM ?';

  @override
  String get playGuideS2Title2 => 'La copie nécessaire';

  @override
  String get playGuideS2Title3 => 'Déjà en .z64';

  @override
  String get playGuideS2Title4 => 'J’ai un fichier .n64 ou .v64';

  @override
  String get playGuideS2Title5 => 'La région compte';

  @override
  String get playGuideS3Title1 => 'Ouvrir SM64CoopDX';

  @override
  String get playGuideS3Title2 => 'Choisir votre ROM';

  @override
  String get playGuideS3Title3 => 'Sans sélecteur de ROM';

  @override
  String get playGuideS3Title4 => 'Atteindre le menu du jeu';

  @override
  String get playGuideS3Title5 => 'L’emplacement de votre ROM';

  @override
  String get playGuideS4Title1 => 'Revenir au gestionnaire';

  @override
  String get playGuideS4Title2 => 'Trouver le dossier principal';

  @override
  String get playGuideS4Title3 => 'Autoriser ce dossier';

  @override
  String get playGuideS4Title4 => 'Une seule connexion';

  @override
  String get playGuideS4Title5 => 'Déjà connecté ?';

  @override
  String get playGuideS5Title1 => 'Fermer d’abord le jeu';

  @override
  String get playGuideS5Title2 => 'Choisir un mod';

  @override
  String get playGuideS5Title3 => 'Attendre l’installation';

  @override
  String get playGuideS5Title4 => 'L’activer dans la bibliothèque';

  @override
  String get playGuideS5Title5 => 'Redémarrer et essayer';

  @override
  String get playGuideS6Title1 => 'Commencer votre aventure';

  @override
  String get playGuideS6Title2 => 'Le jeu ne s’ouvre pas';

  @override
  String get playGuideS6Title3 => 'La ROM est refusée';

  @override
  String get playGuideS6Title4 => 'Le mod est absent';

  @override
  String get playGuideS6Title5 => 'Autorisation du dossier perdue';

  @override
  String get playGuideS6Title6 => 'Essayer un à la fois';

  @override
  String get romPrepareNav => 'Préparer une ROM';

  @override
  String get romPrepareTitle => 'Préparer votre ROM';

  @override
  String get romPrepareDescription =>
      'Choisissez votre propre fichier Super Mario 64. L’application crée et vérifie une copie .z64 compatible sans modifier l’original.';

  @override
  String get romPreparePrivacy =>
      'SM64CDPY ne contient, ne télécharge et ne partage aucune ROM. Le fichier choisi est traité localement sur votre appareil.';

  @override
  String get romPrepareChoose => 'Choisir une ROM';

  @override
  String get romPrepareChooseAnother => 'Choisir un autre fichier';

  @override
  String get romPrepareAnother => 'Préparer une autre ROM';

  @override
  String get romPrepareSave => 'Enregistrer la copie .z64';

  @override
  String get romPrepareContinue => 'Continuer le guide';

  @override
  String get romPrepareCancel => 'Annuler';

  @override
  String get romPrepareIdle => 'Prêt à vérifier votre fichier';

  @override
  String get romPreparePicking => 'Choisissez votre fichier dans Android';

  @override
  String get romPrepareInspecting => 'Vérification du fichier choisi';

  @override
  String get romPrepareConverting => 'Préparation d’une copie compatible';

  @override
  String get romPrepareValidating => 'Vérification de la ROM préparée';

  @override
  String get romPrepareReady => 'ROM compatible prête';

  @override
  String get romPrepareAlreadyCompatible =>
      'Votre ROM était déjà au bon format';

  @override
  String get romPrepareChoosingDestination =>
      'Choisissez où enregistrer la copie';

  @override
  String get romPrepareExporting => 'Enregistrement de votre copie';

  @override
  String get romPrepareVerifyingExport =>
      'Vérification de la copie enregistrée';

  @override
  String get romPrepareSaved => 'Copie enregistrée et vérifiée';

  @override
  String get romPrepareCancelling => 'Arrêt en toute sécurité';

  @override
  String get romPrepareCancelled => 'Préparation annulée';

  @override
  String get romPrepareFailed => 'Impossible de préparer la ROM';

  @override
  String romPrepareDetected(String format) {
    return 'Format détecté : $format';
  }

  @override
  String romPrepareSavedAs(String name) {
    return 'Enregistré sous $name';
  }

  @override
  String get romPrepareErrorUnrecognized =>
      'Le format de ce fichier n’est pas reconnu comme une ROM N64.';

  @override
  String get romPrepareErrorSize =>
      'La ROM originale de Super Mario 64 doit faire exactement 8 Mio.';

  @override
  String get romPrepareErrorIncompatible =>
      'Vous devez utiliser une ROM USA originale de Super Mario 64 non modifiée.';

  @override
  String get romPrepareErrorPermission =>
      'Android n’autorise plus l’accès à ce fichier. Sélectionnez-le à nouveau.';

  @override
  String get romPrepareErrorStorage =>
      'L’espace disponible est insuffisant ou le fichier est illisible.';

  @override
  String get romPrepareErrorExport =>
      'Impossible de vérifier la copie enregistrée. Choisissez une autre destination et réessayez.';

  @override
  String get romPrepareErrorBusy =>
      'Une autre opération sur une ROM est déjà en cours.';

  @override
  String get romPrepareErrorUnexpected =>
      'Une erreur inattendue s’est produite. Votre fichier original n’a pas été modifié.';

  @override
  String get mangaNavLibrary => 'Bibliothèque';

  @override
  String get mangaNavExplore => 'Explorer';

  @override
  String get mangaMenuLabel => 'Menu';

  @override
  String get mangaMenuOpen => 'Ouvrir le menu';

  @override
  String get mangaMenuClose => 'Fermer le menu';

  @override
  String get mangaNavTools => 'Outils';

  @override
  String get mangaNavMore => 'Plus';

  @override
  String get mangaNavPlay => 'Jouer';

  @override
  String get mangaNavHint => 'Balayez pour parcourir. Touchez pour ouvrir.';

  @override
  String get mangaNavError => 'Impossible d’effectuer cette action. Réessayez.';

  @override
  String get mangaMenuSoundsTitle => 'Sons du menu';

  @override
  String get mangaMenuSoundsDescription =>
      'Effets sonores à l’ouverture, à la sélection et au défilement du menu.';

  @override
  String get appEffectsVolume => 'Volume des effets';

  @override
  String get appEffectsVolumeDescription =>
      'Règle uniquement les effets de cette application. Le volume multimédia de l’appareil reste la limite.';

  @override
  String get ambientMusicTitle => 'Musique d’ambiance';

  @override
  String get ambientMusicDescription =>
      'Une musique douce pendant l’utilisation de Retro Manga. Elle se met en pause lorsque vous quittez l’application.';

  @override
  String get ambientMusicVolume => 'Volume de la musique';

  @override
  String get mangaNavAudio => 'Audio';

  @override
  String get themeMangaDeluxe => 'Manga Deluxe';

  @override
  String get deluxeWelcome => 'Bienvenue dans CoopDX';

  @override
  String get deluxeWelcomeBody =>
      'Votre compagnon Android pour les mods : préparez le jeu, découvrez des mods et retrouvez la communauté CoopDX.';

  @override
  String get deluxeSpotlight => 'À découvrir dans CoopDX';

  @override
  String get deluxeDncBody =>
      'Ciels et éclairages changeants, cycle jour/nuit complet. Découvrez le mod en mouvement avant de consulter ses détails.';

  @override
  String get deluxeViewMod => 'Voir le mod';

  @override
  String get deluxeWatchDemo => 'Voir la démo';

  @override
  String get deluxeDemoHint =>
      'Ouvre la vidéo officielle hors de l’application. Internet requis.';

  @override
  String get deluxeLinkError =>
      'Impossible d’ouvrir le lien. Vérifiez votre connexion et réessayez.';

  @override
  String get deluxeHelpTitle => 'Aide rapide';

  @override
  String get deluxeFaqRom => 'Quelle ROM me faut-il ?';

  @override
  String get deluxeFaqRomAnswer =>
      'Utilisez votre propre copie USA vérifiée au format .z64. Préparer une ROM permet de convertir une copie sans modifier l’original.';

  @override
  String get deluxeFaqFolders => 'Quel dossier choisir ?';

  @override
  String get deluxeFaqFoldersAnswer =>
      'Utilisez Connecter le dossier du jeu. Le guide explique l’emplacement à choisir et le gestionnaire détecte les mods et packs compatibles.';

  @override
  String get deluxeFaqPacks => 'Mods du jeu ou DynOS ?';

  @override
  String get deluxeFaqPacksAnswer =>
      'Les mods Lua modifient le fonctionnement du jeu. Les packs DynOS fournissent modèles, textures et commandes tactiles. Gérez-les dans leurs sections distinctes de la bibliothèque.';

  @override
  String get deluxeOpenGuide => 'Ouvrir';

  @override
  String get deluxeCommunity => 'Communauté et liens';

  @override
  String get deluxeGameNews => 'Actualités du jeu Android';

  @override
  String get deluxeMotion => 'Fond animé';

  @override
  String get deluxeMotionHint =>
      'Défilement facultatif des casquettes et du motif. Laissez désactivé pour économiser la batterie.';

  @override
  String get deluxeReducedMotion =>
      'Les animations sont en pause selon vos paramètres d’accessibilité.';

  @override
  String get deluxeReset => 'Réinitialiser l’apparence et l’audio Deluxe';

  @override
  String get deluxeResetDone => 'Apparence et audio Deluxe réinitialisés.';

  @override
  String get deluxeMusicDescription =>
      'Une musique douce pour Manga Deluxe. Elle se met en pause lorsque vous quittez l’application.';

  @override
  String get deluxeAccentDescription =>
      'Choisissez les couleurs d’encre et du motif de fond de Manga Deluxe.';

  @override
  String get deluxeResetHint =>
      'Rétablit la couleur d’accent partagée et les volumes audio. Vos dossiers, mods et sauvegardes restent inchangés.';

  @override
  String get deluxeWelcomeCompact =>
      'Vous débutez ? Préparez le jeu avec notre guide rapide.';

  @override
  String get deluxeSkip => 'Passer';

  @override
  String get deluxeSkipHint =>
      'Masquer définitivement cette introduction. Le guide reste dans le menu.';

  @override
  String get coopTitle => 'Jouer entre amis';

  @override
  String get coopNav => 'Jouer';

  @override
  String get coopIntro =>
      'Créez un salon privé ou rejoignez celui d’un ami avec son code. L’assistant relie SM64CoopDX par internet pendant que le jeu utilise sa connexion directe locale.';

  @override
  String get coopPrivacy =>
      'Le code du salon est un secret partagé. La signalisation utilise le service Cloudflare compatible ; le trafic du jeu passe directement si possible et par TURN seulement si nécessaire.';

  @override
  String get coopConsentTitle => 'Confidentialité du réseau';

  @override
  String get coopConsentIntro =>
      'Avant de créer ou rejoindre un salon, découvrez comment fonctionne la connexion.';

  @override
  String get coopConsentEncrypted =>
      'Le code du salon sert à dériver la clé qui chiffre la signalisation WebRTC. Partagez-le uniquement avec des personnes de confiance.';

  @override
  String get coopConsentIp =>
      'Votre adresse internet peut être visible par l’ami invité et par les services de découverte d’adresse de Google et Cloudflare.';

  @override
  String get coopConsentThirdParty =>
      'La signalisation et l’accès au relais utilisent un service Cloudflare tiers compatible. Sa disponibilité et la conservation des données dépendent de ce service.';

  @override
  String get coopConsentAccept => 'J’ai compris, continuer';

  @override
  String get coopConsentCancel => 'Pas maintenant';

  @override
  String get coopConsentReview => 'Revoir la confidentialité du réseau';

  @override
  String get coopConsentSaveError =>
      'Impossible d’enregistrer votre choix. Aucune session réseau n’a été lancée.';

  @override
  String get coopCreate => 'Créer un salon';

  @override
  String get coopJoin => 'Rejoindre un salon';

  @override
  String get coopCode => 'Code ami';

  @override
  String get coopCodeHint => 'ABCD-1234';

  @override
  String get coopRecent => 'Codes récents';

  @override
  String get coopClearRecent => 'Effacer';

  @override
  String get coopWaiting => 'En attente d’amis';

  @override
  String get coopConnecting => 'Recherche de votre ami';

  @override
  String get coopConnected => 'Session connectée';

  @override
  String get coopReconnecting => 'Reconnexion';

  @override
  String get coopPreparing => 'Préparation du salon sécurisé';

  @override
  String get coopStop => 'Arrêter la session';

  @override
  String get coopOpenGame => 'Ouvrir SM64CoopDX';

  @override
  String get coopGameMissing =>
      'SM64CoopDX n’est pas installé sur cet appareil.';

  @override
  String get coopGameReady => 'SM64CoopDX détecté';

  @override
  String get coopHostInstruction =>
      'Dans le jeu, ouvrez Multiplayer > Direct Connection > Host. Vos amis vous rejoignent avec le code affiché ici.';

  @override
  String coopJoinInstruction(int port) {
    return 'Dans le jeu, ouvrez Multiplayer > Direct Connection et connectez-vous à 127.0.0.1 sur le port $port.';
  }

  @override
  String get coopCopy => 'Copier le code';

  @override
  String get coopCopied => 'Code copié';

  @override
  String get coopShare => 'Partager l’invitation';

  @override
  String get coopShareSubject => 'Invitation à une partie SM64CoopDX';

  @override
  String coopShareMessage(String code) {
    return 'Rejoins ma partie SM64CoopDX !\n\nCode ami : $code\n\nOuvre SM64CDPY, va dans Jouer, choisis Rejoindre un salon et saisis ce code. Partage-le uniquement avec des personnes de confiance.';
  }

  @override
  String get coopShareError =>
      'Impossible de partager l’invitation. Essayez plutôt de copier le code.';

  @override
  String coopPeers(int count) {
    return 'Amis : $count';
  }

  @override
  String get coopDirect => 'Direct';

  @override
  String get coopRelay => 'Relais';

  @override
  String get coopNoCode => 'Saisissez un code valide de huit caractères.';

  @override
  String get coopNetworkError =>
      'Impossible de lancer la session. Vérifiez votre connexion et réessayez.';

  @override
  String get coopBatteryTitle => 'Connexion en arrière-plan';

  @override
  String get coopBatteryDescription =>
      'Facultatif : autorisez l’utilisation sans restriction de la batterie pour limiter les interruptions de session par Android pendant que le jeu est ouvert.';

  @override
  String get coopBatteryAllowed =>
      'L’utilisation sans restriction de la batterie est autorisée. Android peut maintenir la session plus efficacement.';

  @override
  String get coopBatteryAllow => 'Autoriser dans Android';

  @override
  String get coopBatteryManage => 'Gérer dans Android';

  @override
  String get coopBatteryOpenError =>
      'Impossible d’ouvrir les paramètres de batterie Android sur cet appareil.';

  @override
  String get coopDiagnosticsTitle => 'Diagnostic de connexion';

  @override
  String coopDiagnosticsSignal(int count) {
    return 'Connexions de signalisation : $count';
  }

  @override
  String coopDiagnosticsPackets(int toGame, int toPage) {
    return 'Paquets du jeu : $toGame reçus · $toPage envoyés';
  }

  @override
  String coopDiagnosticsDelay(int average, int max) {
    return 'Délai de liaison : $average ms en moyenne · $max ms au maximum';
  }

  @override
  String get homeCardSoundsTitle => 'Sons des cartes d’accueil';

  @override
  String get homeCardSoundsDescription =>
      'Un son lors du changement de carte À la une ou Parcourir. Indépendant des effets du menu et de la musique.';

  @override
  String get homeCardSoundsVolume => 'Volume des cartes';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageSaveFailed =>
      'Impossible d’enregistrer la langue. Réessayez.';

  @override
  String get sharedCopyDetails => 'Copier les détails';

  @override
  String get sharedCopied => 'Copié dans le presse-papiers';

  @override
  String sharedAuthor(String author) {
    return 'Auteur : $author';
  }

  @override
  String get sharedUntitled => 'Sans titre';

  @override
  String get render96Required => 'REQUIS';

  @override
  String get render96Optional => 'FACULTATIF';

  @override
  String get render96Skinpack => 'PACK DE MODÈLES';

  @override
  String get settingsExportFailed =>
      'Impossible d’exporter vos favoris. Réessayez.';

  @override
  String get settingsImportFailed =>
      'Impossible d’importer ce fichier. Choisissez un fichier de favoris exporté par SM64CDPY.';

  @override
  String get settingsDatabaseFailed =>
      'Impossible d’actualiser le catalogue. Vérifiez votre connexion et réessayez.';

  @override
  String get updateActionFailed =>
      'Impossible de terminer la mise à jour. Réessayez ou téléchargez-la dans le navigateur.';

  @override
  String get render96WatchTrailer => 'VOIR LA BANDE-ANNONCE';

  @override
  String get render96CategoryOther => 'CONTENU';

  @override
  String get coopConnectionFailed =>
      'La partie n’a pas pu continuer. Vérifiez votre connexion et relancez-la.';

  @override
  String get catalogLoadFailed =>
      'Impossible de charger ce contenu. Vérifiez votre connexion et réessayez.';

  @override
  String get settingsFavouritesShareSubject => 'Favoris SM64CoopDX';

  @override
  String get favEmptyActionHint =>
      'Touchez ♥ sur une carte pour l’enregistrer ici.';
}
