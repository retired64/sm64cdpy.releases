// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get hello => 'Ciao';

  @override
  String get navHome => 'Home';

  @override
  String get navCatalog => 'Catalogo';

  @override
  String get navFavourites => 'Preferiti';

  @override
  String get navPopular => 'Popolari';

  @override
  String get navVIPMods => 'Mod';

  @override
  String get navDynOS => 'DynOS';

  @override
  String get navTouchControls => 'Comandi touch';

  @override
  String get navOmmRebirth => 'Pacchetto OMM';

  @override
  String get navLinksResource => 'Link';

  @override
  String get navDisclaimer => 'Note legali';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get sectionExclusive => 'Esclusivi';

  @override
  String get sectionNavigation => 'NAVIGAZIONE';

  @override
  String get sectionExplore => 'Esplora';

  @override
  String get sectionCategories => 'CATEGORIE';

  @override
  String get sectionSortBy => 'ORDINA PER';

  @override
  String get sectionSocialLinks => 'SOCIAL';

  @override
  String get sortDefault => 'Predefinito';

  @override
  String get sortRating => 'Valutazione';

  @override
  String get sortDownloads => 'Download';

  @override
  String get sortNewest => 'Ultimo aggiornamento';

  @override
  String get socialYouTube => 'YouTube';

  @override
  String get socialDiscord => 'Discord';

  @override
  String get socialGitHub => 'GitHub';

  @override
  String get categoryCharacters => 'Personaggi';

  @override
  String get categoryGameModes => 'Modalità di gioco';

  @override
  String get categoryROMHacks => 'ROM hack e livelli';

  @override
  String get categoryGameplay => 'Gameplay e meccaniche';

  @override
  String get categoryVisual => 'Grafica e modelli';

  @override
  String get categoryAudio => 'Audio e voci';

  @override
  String get categoryUtilities => 'Utilità e strumenti';

  @override
  String get categoryMisc => 'Varie e divertimento';

  @override
  String get badgeFeatured => 'IN EVIDENZA';

  @override
  String get updateRequired => 'AGGIORNAMENTO NECESSARIO';

  @override
  String get updateAvailable => 'NUOVA VERSIONE DISPONIBILE';

  @override
  String updateVersion(String version) {
    return 'Versione $version';
  }

  @override
  String updateSize(String size) {
    return 'Dimensione: $size MB';
  }

  @override
  String updateDownloading(String pct) {
    return 'Download… $pct%';
  }

  @override
  String get updateAlreadyDownloading =>
      'Un download è già in corso. Attendi o riavvia l’app.';

  @override
  String get updatePermissionDenied =>
      'Installazione non autorizzata.\nVai in Impostazioni → App → questa app → Installa app sconosciute.';

  @override
  String updateInternalError(String detail) {
    return 'Si è verificato un errore interno. Riprova. Dettagli: $detail';
  }

  @override
  String get updateDownloadError =>
      'Download non riuscito. Controlla la connessione.';

  @override
  String get updateChecksumError => 'Il file scaricato è danneggiato. Riprova.';

  @override
  String updateInstallError(String detail) {
    return 'Installazione non riuscita. Riprova. Dettagli: $detail';
  }

  @override
  String updateUnexpectedError(String detail) {
    return 'Si è verificato un errore imprevisto. Dettagli: $detail';
  }

  @override
  String updateCantStart(String detail) {
    return 'Impossibile avviare l’aggiornamento: $detail';
  }

  @override
  String get updateButtonOpenBrowser => 'APRI NEL BROWSER';

  @override
  String get updateButtonLater => 'PIÙ TARDI';

  @override
  String get updateButtonExit => 'ESCI';

  @override
  String get updateButtonUpdateNow => 'AGGIORNA ORA';

  @override
  String get updateButtonGoToDownloads => 'VAI AI DOWNLOAD';

  @override
  String get postInstallTitle => 'Mod installata';

  @override
  String get postInstallGameRunning =>
      'Se il gioco era aperto, chiudilo completamente, senza lasciarlo in background, poi riaprilo per caricare i nuovi file.';

  @override
  String get postInstallNoRoot =>
      'Non servono l’arresto forzato o i permessi di root: chiudi il gioco normalmente e riaprilo.';

  @override
  String get postInstallFilesCopied =>
      'I file sono stati copiati nella cartella delle mod.';

  @override
  String get postInstallClose => 'Chiudi';

  @override
  String get postInstallLaunchGame => 'AVVIA IL GIOCO';

  @override
  String get homeExclusiveContent => 'Esclusivi';

  @override
  String get homeTopDownloads => 'Più scaricati';

  @override
  String get homeSeeAll => 'Mostra tutti';

  @override
  String get homeFeatured => 'In evidenza';

  @override
  String get homeCatalog => 'Catalogo';

  @override
  String get homeCatalogDesc => 'Sfoglia, cerca e filtra tutte le mod';

  @override
  String get homeFavorites => 'Preferiti';

  @override
  String get homeFavoritesDesc => 'Le mod salvate da tutte le sezioni';

  @override
  String get homePopular => 'Popolari';

  @override
  String get homePopularDesc => 'Le mod ordinate per numero di download';

  @override
  String get homeBrowse => 'Sfoglia';

  @override
  String get homeGoTo => 'APRI';

  @override
  String get homeVipMods => 'Mod VIP';

  @override
  String get homeVipModsDesc => 'Pacchetti esclusivi di personaggi e modelli';

  @override
  String get homeDynos => 'DynOS';

  @override
  String get homeDynosDesc => 'Texture personalizzate e modelli alternativi';

  @override
  String get homeTouchControls => 'Comandi touch';

  @override
  String get homeTouchControlsDesc =>
      'Disposizioni personalizzate di pulsanti e joystick';

  @override
  String get homeOmmrPack => 'PACCHETTO OMMR';

  @override
  String get homeOmmrPackDesc => 'Pacchetto completo di texture OMM Rebirth';

  @override
  String get homeGameNotInstalled => 'Gioco non installato';

  @override
  String get homeGameNotInstalledBody =>
      'SM64CoopDX (com.maniscat2.sm64coopdx)\nnon è installato su questo dispositivo.';

  @override
  String get homeClose => 'Chiudi';

  @override
  String get homeDownload => 'Scarica';

  @override
  String get homeLaunchGame => 'AVVIA IL GIOCO';

  @override
  String get homeSoon => 'IN ARRIVO';

  @override
  String get homeFailedToLoad => 'Impossibile caricare le mod';

  @override
  String get homeRetry => 'Riprova';

  @override
  String get catalogueTitle => 'SFOGLIA LE MOD';

  @override
  String catalogueModCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count MOD',
      one: '$count MOD',
    );
    return '$_temp0';
  }

  @override
  String catalogueResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count RISULTATI',
      one: '$count RISULTATO',
    );
    return '$_temp0';
  }

  @override
  String get catalogueSearchHint => 'CERCA MOD, AUTORI, TAG…';

  @override
  String get catalogueSortDefault => 'Predefinito';

  @override
  String get catalogueSortTopRated => 'Più votate';

  @override
  String get catalogueSortMostDownloaded => 'Più scaricate';

  @override
  String get catalogueSortRecentlyUpdated => 'Aggiornate di recente';

  @override
  String get catalogueClearAll => 'CANCELLA TUTTO';

  @override
  String cataloguePaginationRange(int start, int end, int total) {
    return '$start–$end DI $total MOD';
  }

  @override
  String get catalogueNoModsFound => 'NESSUNA MOD TROVATA';

  @override
  String get catalogueNothingHere => 'ANCORA NESSUN CONTENUTO';

  @override
  String get catalogueEmptyHint1 =>
      'Prova altre parole chiave o rimuovi i filtri.';

  @override
  String get catalogueEmptyHint2 => 'Torna più tardi per nuovi contenuti.';

  @override
  String get catalogueClearFilters => 'RIMUOVI I FILTRI';

  @override
  String get catalogueFailedToLoad => 'IMPOSSIBILE CARICARE LE MOD';

  @override
  String get catalogueRating => 'VALUTAZIONE';

  @override
  String get catalogueDownloads => 'DOWNLOAD';

  @override
  String get catalogueNewest => 'RECENTI';

  @override
  String get catalogueSort => 'ORDINA';

  @override
  String get catalogueEllipsis => '···';

  @override
  String get popularTitle => 'POPOLARI';

  @override
  String popularModCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count MOD',
      one: '$count MOD',
    );
    return '$_temp0';
  }

  @override
  String get popularMoreRankings => 'ALTRE CLASSIFICHE';

  @override
  String get popularRankings => 'CLASSIFICHE';

  @override
  String popularPage(int page, int total) {
    return 'Pagina $page/$total';
  }

  @override
  String get popularTop3 => 'TOP 3';

  @override
  String popularRank(int rank) {
    return '#$rank';
  }

  @override
  String get popularFailedToLoad => 'CARICAMENTO NON RIUSCITO';

  @override
  String get favouritesTitle => 'Preferiti';

  @override
  String get favTabMods => 'Mod';

  @override
  String get favTabVip => 'VIP';

  @override
  String get favTabDynos => 'DynOS';

  @override
  String get favTabTouch => 'Touch';

  @override
  String get favEmptyMods => 'Nessuna mod nei preferiti';

  @override
  String get favEmptyVip => 'Nessuna mod VIP nei preferiti';

  @override
  String get favEmptyDynos => 'Nessun pacchetto DynOS nei preferiti';

  @override
  String get favEmptyTouch => 'Nessun comando touch nei preferiti';

  @override
  String favEmptyHint(String type) {
    return 'Tocca ♥ su un elemento «$type» per salvarlo qui.';
  }

  @override
  String get favBrowse => 'Sfoglia';

  @override
  String get sharedAddedToFavorites => 'Aggiunto ai preferiti';

  @override
  String get sharedRemovedFromFavorites => 'Rimosso dai preferiti';

  @override
  String sharedDownloaded(String name) {
    return 'Scaricato: $name';
  }

  @override
  String sharedDownloadedType(String type, String name) {
    return 'Download completato ($type): $name';
  }

  @override
  String get sharedDownloadFailed => 'Download non riuscito';

  @override
  String get sharedAddToFavorites => 'AGGIUNGI AI PREFERITI';

  @override
  String get sharedRemoveFromFavorites => 'RIMUOVI DAI PREFERITI';

  @override
  String get sharedDownload => 'SCARICA';

  @override
  String get installationChecking => 'VERIFICA…';

  @override
  String get installationCancel => 'ANNULLA';

  @override
  String get installationInstalled => 'INSTALLATO';

  @override
  String get installationUpdate => 'AGGIORNA';

  @override
  String get installationInstall => 'INSTALLA';

  @override
  String get installationReinstall => 'REINSTALLA';

  @override
  String get installationVerify => 'VERIFICA';

  @override
  String get installationSelectFolder => 'SCEGLI CARTELLA';

  @override
  String get sharedReadMore => 'LEGGI DI PIÙ';

  @override
  String get sharedShowLess => 'MOSTRA MENO';

  @override
  String get vipTitle => 'MOD VIP';

  @override
  String get vipEmpty => 'ANCORA NESSUNA MOD VIP';

  @override
  String get vipEmptyHint => 'Torna più tardi per contenuti esclusivi.';

  @override
  String get vipFailedToLoad => 'IMPOSSIBILE CARICARE LE MOD VIP';

  @override
  String get dynosTitle => 'DYNOS';

  @override
  String get dynosEmpty => 'ANCORA NESSUN PACCHETTO DYNOS';

  @override
  String get dynosEmptyHint => 'Torna più tardi per nuovi pacchetti DynOS.';

  @override
  String get dynosFailedToLoad => 'IMPOSSIBILE CARICARE DYNOS';

  @override
  String get touchTitle => 'COMANDI TOUCH';

  @override
  String touchModCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count DISPOSIZIONI',
      one: '$count DISPOSIZIONE',
    );
    return '$_temp0';
  }

  @override
  String get touchEmpty => 'ANCORA NESSUNA DISPOSIZIONE TOUCH';

  @override
  String get touchEmptyHint =>
      'Torna più tardi per nuove disposizioni dei comandi.';

  @override
  String get touchFailedToLoad => 'IMPOSSIBILE CARICARE I COMANDI TOUCH';

  @override
  String get ommTitle => 'OMM REBIRTH';

  @override
  String get ommEmpty => 'ANCORA NESSUNA MOD OMM REBIRTH';

  @override
  String get ommEmptyHint => 'Torna più tardi per contenuti OMM Rebirth.';

  @override
  String get ommFailedToLoad => 'IMPOSSIBILE CARICARE LE MOD OMM REBIRTH';

  @override
  String get detailDownload => 'Scarica';

  @override
  String get detailDownloadButton => 'SCARICA';

  @override
  String get detailModNotFound => 'Mod non trovata';

  @override
  String get detailModNotFoundBody =>
      'La mod potrebbe essere stata rimossa o il link non è valido.';

  @override
  String get detailGoBack => 'Indietro';

  @override
  String get detailFailedToLoad => 'Impossibile caricare la mod';

  @override
  String get detailRetry => 'Riprova';

  @override
  String get detailNotificationsNeeded => 'Consenti le notifiche';

  @override
  String get detailNotificationsBody =>
      'Consenti le notifiche per seguire download e installazione anche quando esci dall’app.';

  @override
  String get detailNotNow => 'Non ora';

  @override
  String get detailContinue => 'Continua';

  @override
  String get detailNotificationsSkipped =>
      'L’avanzamento non sarà visibile fuori dall’app. Puoi consentire le notifiche nelle impostazioni.';

  @override
  String get detailModsFolderNotSelected =>
      'Cartella delle mod non selezionata';

  @override
  String get detailModsFolderBody =>
      'Scegli una cartella prima di installare mod nel gioco.\n\nVai in Impostazioni → Integrazione con il gioco per selezionarla.';

  @override
  String get detailCancel => 'Annulla';

  @override
  String get detailGoToSettings => 'Vai alle impostazioni';

  @override
  String detailDownloading(String filename) {
    return 'Download di «$filename»…';
  }

  @override
  String detailSavedToModsFolder(String name) {
    return 'Salvato nella cartella delle mod: $name';
  }

  @override
  String detailSavedToFolder(String type, String name) {
    return 'Salvato nella cartella $type: $name';
  }

  @override
  String get detailDownloadFailed => 'Download non riuscito';

  @override
  String detailError(String detail) {
    return 'Errore: $detail';
  }

  @override
  String detailDownloaded(String name) {
    return 'Scaricato: $name';
  }

  @override
  String detailDownloadedType(String type, String name) {
    return 'Download completato ($type): $name';
  }

  @override
  String get detailDownloadingBanner => 'Download della mod…';

  @override
  String detailDownloadingBannerType(String type) {
    return 'Download: $type…';
  }

  @override
  String detailFilesProgress(int current, int total) {
    return '$current/$total file';
  }

  @override
  String get detailExtracting => 'Estrazione…';

  @override
  String get detailInstallingMod => 'Installazione della mod…';

  @override
  String get detailInstallComplete => 'Installazione completata';

  @override
  String detailInstallFilesExtracted(int count, String dir) {
    return '$count file estratti in «$dir»';
  }

  @override
  String get detailInstallFailed => 'Installazione non riuscita';

  @override
  String get detailOperationCancelled => 'Operazione annullata';

  @override
  String detailDownloadingPct(String pct) {
    return 'Download $pct%';
  }

  @override
  String get detailInstalling => 'Installazione…';

  @override
  String get overlayCancelling => 'Annullamento…';

  @override
  String get detailDynosFolderNotSelected =>
      'Cartella DynOS e comandi touch non selezionata';

  @override
  String get detailDynosFolderBody =>
      'Scegli la cartella condivisa di DynOS e comandi touch in Impostazioni → Integrazione con il gioco prima di installare questo contenuto.';

  @override
  String get detailInstallDownloadedTitle =>
      'Installare il contenuto scaricato?';

  @override
  String detailInstallDownloadedBody(String name) {
    return 'Il download di $name è terminato. Vuoi installarlo ora nella cartella DynOS e comandi touch?';
  }

  @override
  String get detailInstallNow => 'Installa ora';

  @override
  String get detailKeepDownload => 'Non ora';

  @override
  String detailDownloadedNotInstalled(String name) {
    return 'Scaricato, ma non installato: $name';
  }

  @override
  String detailInstallQueued(String name) {
    return 'Download e installazione in coda: $name';
  }

  @override
  String get detailContentUnavailable =>
      'Questo download non è più disponibile (404). Il link potrebbe essere stato rimosso o modificato.';

  @override
  String get detailFriendlyDownloadError =>
      'Impossibile completare il download. Controlla la connessione e riprova.';

  @override
  String get detailScreenshots => 'Schermate';

  @override
  String get detailYoutubeVideos => 'Video YouTube';

  @override
  String get detailDirectVideos => 'Video';

  @override
  String get detailTags => 'Tag';

  @override
  String get detailAbout => 'Informazioni';

  @override
  String get detailDescriptionViewOriginal => 'Vedi originale';

  @override
  String get detailDescriptionViewTranslation => 'Vedi traduzione';

  @override
  String get detailRating => 'Valutazione';

  @override
  String get detailDownloads => 'Download';

  @override
  String get detailViews => 'Visualizzazioni';

  @override
  String get detailReviews => 'Recensioni';

  @override
  String detailDownloadFiles(int count) {
    return 'File da scaricare ($count)';
  }

  @override
  String detailVersions(int count) {
    return 'Versioni ($count)';
  }

  @override
  String get detailVersionFallback => 'v?';

  @override
  String get detailLatestVersion => 'ULTIMA VERSIONE';

  @override
  String get detailPreviousVersions => 'Versioni precedenti';

  @override
  String detailViewPreviousVersions(int count) {
    return 'Mostra $count versioni precedenti';
  }

  @override
  String get detailNoDownloadFiles => 'Non sono disponibili file da scaricare.';

  @override
  String get detailFirstRelease => 'Prima pubblicazione';

  @override
  String get detailLastUpdate => 'Ultimo aggiornamento';

  @override
  String get detailChangelog => 'Novità';

  @override
  String get detailCollapseChangelog => 'Comprimi le novità';

  @override
  String detailViewAllUpdates(int count) {
    return 'Mostra tutti i $count aggiornamenti';
  }

  @override
  String get detailShowLess => 'Mostra meno';

  @override
  String get detailShowMore => 'Mostra altro';

  @override
  String get detailNotificationsDisabled =>
      'Notifiche disattivate. L’avanzamento non sarà visibile fuori dall’app.';

  @override
  String get settingsTitle => 'IMPOSTAZIONI';

  @override
  String get settingsData => 'DATI';

  @override
  String get settingsClearFavourites => 'Cancella i preferiti';

  @override
  String get settingsClearFavouritesDesc => 'Rimuovi tutte le mod salvate';

  @override
  String get settingsExportFavourites => 'Esporta i preferiti';

  @override
  String get settingsExportFavouritesDesc => 'Condividi le mod salvate';

  @override
  String get settingsImportFavourites => 'Importa i preferiti';

  @override
  String get settingsImportFavouritesDesc =>
      'Ripristina da un file esportato in precedenza';

  @override
  String get settingsGameIntegration => 'INTEGRAZIONE CON IL GIOCO';

  @override
  String get settingsAppearance => 'ASPETTO';

  @override
  String get settingsAbout => 'INFORMAZIONI';

  @override
  String get settingsGoToReleases => 'Vai alle versioni pubblicate';

  @override
  String settingsViewAllVersions(String version) {
    return 'Tutte le versioni su GitHub · v$version';
  }

  @override
  String get settingsDataSource => 'Origine dei dati';

  @override
  String get settingsNoFavouritesToExport => 'Non hai preferiti da esportare.';

  @override
  String settingsImportAdded(int count) {
    return '$count aggiunti';
  }

  @override
  String settingsImportAlreadySaved(int count) {
    return '$count già salvati';
  }

  @override
  String settingsImportNotFound(int count) {
    return '$count non trovati nel catalogo';
  }

  @override
  String get settingsImportNothingNew => 'Nessun nuovo elemento da importare.';

  @override
  String get settingsImportComplete => 'Importazione completata';

  @override
  String get settingsClearFavouritesTitle => 'CANCELLARE I PREFERITI?';

  @override
  String get settingsClearFavouritesBody =>
      'Tutte le mod salvate verranno rimosse dai preferiti. L’azione non può essere annullata.';

  @override
  String get settingsClearButton => 'CANCELLA';

  @override
  String get settingsFavouritesCleared => 'Preferiti cancellati';

  @override
  String settingsCannotOpenUrl(String url) {
    return 'Impossibile aprire il link: $url';
  }

  @override
  String get settingsCancel => 'ANNULLA';

  @override
  String get settingsModsFolderSelected =>
      'Cartella delle mod selezionata. Le mod verranno installate qui.';

  @override
  String get settingsClearModsFolderTitle =>
      'DIMENTICARE LA CARTELLA DELLE MOD?';

  @override
  String get settingsClearModsFolderBody =>
      'Dovrai selezionare nuovamente la cartella prima di installare mod nel gioco.';

  @override
  String get settingsModsFolderCleared =>
      'Selezione della cartella delle mod rimossa.';

  @override
  String get settingsModsFolder => 'Cartella delle mod';

  @override
  String get settingsSelectModsFolder => 'Scegli la cartella delle mod';

  @override
  String get settingsModsFolderHint =>
      'Tocca per cambiare · Tieni premuto per dimenticare';

  @override
  String get settingsModsFolderDesc =>
      'Scegli dove installare le mod scaricate';

  @override
  String get settingsAutoInstall => 'Installa dopo il download';

  @override
  String get settingsAutoInstallOn =>
      'I download verranno installati automaticamente nella cartella di gioco configurata';

  @override
  String get settingsAutoInstallOff =>
      'Verrà chiesta conferma dopo ogni download';

  @override
  String get autoInstallPromptTitle => 'Installare le mod dopo il download?';

  @override
  String get autoInstallPromptBody =>
      'Attiva l’installazione automatica per collocare le mod scaricate nella cartella di gioco configurata. Puoi cambiare questa scelta nelle impostazioni.';

  @override
  String get autoInstallPromptEnable => 'Attiva';

  @override
  String get autoInstallPromptDownloadOnly => 'Scarica soltanto';

  @override
  String get settingsThemeMode => 'Modalità del tema';

  @override
  String settingsDatabaseUpdated(int count, String date) {
    return 'Database aggiornato · $count mod$date';
  }

  @override
  String get settingsUnknownError => 'Errore sconosciuto';

  @override
  String get settingsReloadDatabase => 'Ricarica il database';

  @override
  String get settingsDownloading => 'Download…';

  @override
  String get settingsDownloadLatest => 'Scarica l’elenco aggiornato delle mod';

  @override
  String settingsUpToDate(String version) {
    return 'L’app è aggiornata · v$version';
  }

  @override
  String get settingsCheckForUpdates => 'Controlla aggiornamenti';

  @override
  String get settingsChecking => 'Controllo…';

  @override
  String get generalSettings => 'Impostazioni';

  @override
  String get generalRetry => 'Riprova';

  @override
  String get linksTitle => 'LINK';

  @override
  String get linksSubtitle => 'E RISORSE';

  @override
  String get linksOfficiaSection => 'UFFICIALI';

  @override
  String get linksOfficialDesc => 'Canali verificati del progetto SM64CoopDX.';

  @override
  String get linksSm64cdpySection => 'SM64CDPY';

  @override
  String get linksSm64cdpyDesc => 'Download e contenuti di questa app.';

  @override
  String get linksResourcesSection => 'RISORSE';

  @override
  String get linksResourcesDesc =>
      'Community, guide e installazione passo dopo passo.';

  @override
  String get linksHeroTitle => 'RACCOLTA DI LINK';

  @override
  String get linksHeroDesc =>
      'Siti ufficiali, community e risorse del progetto in un unico posto.';

  @override
  String get linksChipTap => 'TOCCA = APRI';

  @override
  String get linksChipHold => 'TIENI PREMUTO = COPIA';

  @override
  String get linksWebsite => 'Sito SM64CoopDX';

  @override
  String get linksWebsiteUrl => 'sm64coopdx.com';

  @override
  String get linksAppWebsite => 'Sito ufficiale SM64CDPY';

  @override
  String get linksAppWebsiteDesc =>
      'Notizie, download e informazioni sul progetto';

  @override
  String get linksKindWeb => 'WEB';

  @override
  String get linksDiscordServer => 'Server Discord';

  @override
  String get linksDiscordOfficial =>
      'Server ufficiale della community · Android';

  @override
  String get linksKindDiscord => 'DISCORD';

  @override
  String get linksGithubRepo => 'Repository GitHub';

  @override
  String get linksGithubDesc => 'Codice sorgente e segnalazioni';

  @override
  String get linksKindGithub => 'GITHUB';

  @override
  String get linksGithubReleases => 'Versioni su GitHub';

  @override
  String get linksGithubReleasesDesc => 'Scarica l’APK più recente';

  @override
  String get linksKindDownload => 'DOWNLOAD';

  @override
  String get linksYoutubeChannel => 'Canale YouTube';

  @override
  String get linksYoutubeHandle => '@retired64';

  @override
  String get linksKindYoutube => 'YOUTUBE';

  @override
  String get linksDiscordCommunity => 'Server della community e assistenza';

  @override
  String get linksWiki => 'Wiki e guide';

  @override
  String get linksWikiDesc => 'Guide all’installazione e documentazione';

  @override
  String get linksKindWiki => 'WIKI';

  @override
  String get linksTools => 'Strumenti e componenti aggiuntivi';

  @override
  String get linksToolsDesc => 'Creazione di mod e risorse utili';

  @override
  String get linksKindTools => 'STRUMENTI';

  @override
  String get linksCouldNotOpen => 'Impossibile aprire il link';

  @override
  String get linksCopied => 'Link copiato';

  @override
  String get disclaimerTitle => 'Note legali';

  @override
  String get disclaimerDeveloperContact => 'Contatta lo sviluppatore';

  @override
  String get disclaimerDiscordReach => 'Contattami sul mio server Discord';

  @override
  String get disclaimerDiscord => 'Discord';

  @override
  String disclaimerFooter(String version) {
    return 'v$version · uso personale · Non ufficiale';
  }

  @override
  String get disclaimerUnofficialBanner =>
      'Progetto non ufficiale creato da un fan';

  @override
  String get disclaimerAppSubtitle => 'Gestore di mod per SM64CoopDX';

  @override
  String get disclaimerWarningBody =>
      'SM64CDPY è un software indipendente. Domande, problemi tecnici e richieste relative a questa app vanno rivolti allo sviluppatore di SM64CDPY, non a Nintendo, al team SM64CoopDX o agli autori delle mod elencate.';

  @override
  String get disclaimerCouldNotOpenLink => 'Impossibile aprire il link';

  @override
  String get disclaimerSectionPersonalPurpose => 'Informazioni sull’app';

  @override
  String get disclaimerBodyPersonalPurpose =>
      'SM64CDPY è un catalogo e gestore Android indipendente per le mod SM64CoopDX create dalla community. Aiuta a sfogliare, scaricare, organizzare e installare contenuti compatibili nelle cartelle scelte dall’utente. L’app non distribuisce né installa Super Mario 64, file ROM, SM64CoopDX o le sue versioni Android. Non richiede né verifica file di gioco e non fornisce istruzioni per procurarseli.';

  @override
  String get disclaimerSectionNoAffiliation => 'Nessuna affiliazione ufficiale';

  @override
  String get disclaimerBodyNoAffiliation =>
      'Questo progetto non è associato, sostenuto o approvato da Nintendo, dal team SM64CoopDX o dagli autori delle mod elencate. Nomi di prodotti e marchi indicano soltanto la compatibilità. Titoli, descrizioni, immagini, file e altro materiale accreditato restano di proprietà dei rispettivi autori o titolari dei diritti.';

  @override
  String get disclaimerSectionDataSource => 'Origine dei dati';

  @override
  String get disclaimerBodyDataSource =>
      'Il catalogo principale presenta le risorse pubbliche della community Coop DX Mods (mods.sm64coopdx.com), conservando autore, titolo, date, versioni e fonte pubblicati. SM64CDPY offre un’interfaccia mobile e recupera i download dalla fonte disponibile per ogni risorsa. La presenza nel catalogo non implica proprietà o approvazione ufficiale da parte di SM64CDPY.';

  @override
  String get disclaimerSectionExclusive =>
      'Sezioni curate (VIP · DynOS · comandi touch)';

  @override
  String disclaimerBodyExclusive(Object version) {
    return 'Nella v$version, mod VIP, pacchetti DynOS, disposizioni touch, OMM Rebirth e Render96 possono usare fonti curate separatamente. Quando il contenuto non è stato creato dallo sviluppatore di SM64CDPY, la paternità resta al creatore accreditato. Queste sezioni sono separate dal catalogo principale Coop DX Mods e non sono servizi ufficiali Nintendo o SM64CoopDX.';
  }

  @override
  String get disclaimerSectionLocalData => 'Account e dati locali';

  @override
  String get disclaimerBodyLocalData =>
      'SM64CDPY attualmente non crea account utente. Preferiti, cronologia delle installazioni, cartelle selezionate e preferenze dell’app sono memorizzati localmente sul dispositivo. Disinstallare l’app o cancellarne i dati può rimuovere queste informazioni.';

  @override
  String get disclaimerSectionExternalServices => 'Servizi esterni';

  @override
  String get disclaimerBodyExternalServices =>
      'Navigazione, aggiornamento dei cataloghi, apertura di link e download possono collegarsi a servizi come Coop DX Mods, GitHub, Google Drive, Dropbox o GameBanana. Questi servizi applicano condizioni e pratiche sulla privacy proprie, che SM64CDPY non controlla.';

  @override
  String get disclaimerSectionBugs => 'Assistenza e correzioni dei contenuti';

  @override
  String get disclaimerBodyBugs =>
      'Contatta lo sviluppatore di SM64CDPY per problemi dell’app, attribuzioni errate, informazioni obsolete o contenuti da correggere o rimuovere. Includi il titolo della mod e la fonte quando opportuno. Le richieste relative all’app non vanno rivolte a Nintendo, al team SM64CoopDX o agli autori delle mod.';

  @override
  String get vipSectionHeader => 'CONTENUTI ESCLUSIVI';

  @override
  String get dynosSectionHeader => 'DYNOS PERSONALIZZATI';

  @override
  String get touchSectionHeader => 'DISPOSIZIONI PER DISPOSITIVI MOBILI';

  @override
  String get ommSectionHeader => 'MOD OMM REBIRTH';

  @override
  String sharedModCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count MOD',
      one: '$count MOD',
    );
    return '$_temp0';
  }

  @override
  String get settingsDynosFolder => 'Cartella DynOS e comandi touch';

  @override
  String get settingsSelectDynosFolder => 'Scegli la cartella DynOS';

  @override
  String get settingsDynosFolderHint =>
      'Tocca per cambiare · Tieni premuto per dimenticare';

  @override
  String get settingsDynosFolderDesc =>
      'Scegli dove installare i pacchetti DynOS e comandi touch';

  @override
  String get settingsDynosFolderSelected =>
      'Cartella DynOS e comandi touch selezionata. Entrambi i tipi di contenuto verranno installati qui.';

  @override
  String get settingsClearDynosFolderTitle => 'DIMENTICARE LA CARTELLA DYNOS?';

  @override
  String get settingsClearDynosFolderBody =>
      'Dovrai scegliere nuovamente la cartella prima di installare pacchetti DynOS o comandi touch.';

  @override
  String get settingsDynosFolderCleared =>
      'Selezione della cartella DynOS rimossa.';

  @override
  String get settingsLanguageMode => 'Lingua';

  @override
  String get languageFollowSystem => 'Lingua di sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get overlaySearchHint => 'CERCA…';

  @override
  String get overlayChooseFile => 'Scegli un file';

  @override
  String overlayFileFallback(int number) {
    return 'File $number';
  }

  @override
  String get overlayNoResponse =>
      'Nessuna risposta: apri una volta l’app principale e riprova';

  @override
  String get overlaySelectFolder =>
      'Scegli prima una cartella nelle impostazioni';

  @override
  String get overlayEnableAutoInstall =>
      'Attiva prima l’installazione automatica nelle impostazioni';

  @override
  String get overlayDownloadFailed => 'Download non riuscito';

  @override
  String get overlayTapToCancel => 'TOCCA PER ANNULLARE';

  @override
  String get overlayInstalling => 'Installazione…';

  @override
  String get overlayConnecting => 'Connessione…';

  @override
  String get overlayNoResults => 'NESSUN RISULTATO';

  @override
  String get overlayError => 'ERRORE';

  @override
  String get settingsOverlayActive => 'Bolla flottante attiva';

  @override
  String get settingsOverlayInactive => 'Bolla flottante';

  @override
  String get settingsOverlayActiveDesc => 'Tocca per nascondere la bolla';

  @override
  String get settingsOverlayInactiveDesc =>
      'Tocca per mostrare la bolla sopra il gioco';

  @override
  String get navRender96 => 'Render96';

  @override
  String get render96Title => 'RENDER96';

  @override
  String get render96SectionHeader => 'COLLEZIONE ESCLUSIVA';

  @override
  String get render96Empty => 'IN ARRIVO';

  @override
  String get render96EmptyHint => 'I nuovi contenuti Render96 appariranno qui.';

  @override
  String get render96FailedToLoad => 'CARICAMENTO NON RIUSCITO';

  @override
  String get navLibrary => 'Libreria';

  @override
  String get libraryTitle => 'LIBRERIA';

  @override
  String get libraryInstalled => 'Installati';

  @override
  String get libraryUpdates => 'Aggiornamenti';

  @override
  String get libraryRecent => 'Recenti';

  @override
  String get libraryViewAll => 'Mostra tutti';

  @override
  String get libraryRefresh => 'Aggiorna la libreria';

  @override
  String get libraryAllSections => 'Tutte le sezioni';

  @override
  String get libraryAllDestinations => 'Tutte le cartelle';

  @override
  String get libraryModsDestination => 'Cartella delle mod';

  @override
  String get libraryDynosDestination => 'Cartella DynOS';

  @override
  String get libraryPresent => 'Installato';

  @override
  String get libraryMissing => 'Mancante';

  @override
  String get libraryPermissionRevoked => 'Autorizzazione necessaria';

  @override
  String get libraryFolderNotSelected => 'Cartella necessaria';

  @override
  String get libraryNotVerified => 'Non verificato';

  @override
  String get libraryOpenSource => 'APRI CONTENUTO';

  @override
  String get libraryEmptyTitle => 'ANCORA NESSUNA INSTALLAZIONE';

  @override
  String get libraryEmptyBody =>
      'Le mod installate da SM64CDPY appariranno qui.';

  @override
  String get libraryUpdatesEmptyTitle => 'NESSUN AGGIORNAMENTO NOTO';

  @override
  String get libraryUpdatesEmptyBody =>
      'Gli aggiornamenti confermati dal catalogo appariranno qui. Puoi comunque controllare ogni sezione dei contenuti.';

  @override
  String get libraryDiscoveryHeaderIdentified => 'Intestazione identificata';

  @override
  String get libraryDiscoveryProbable => 'Probabile mod';

  @override
  String get libraryDiscoveryUnlinked => 'Lua non associato';

  @override
  String get libraryErrorTitle => 'LIBRERIA NON DISPONIBILE';

  @override
  String get libraryErrorBody =>
      'Impossibile leggere la cronologia delle installazioni. Riprova senza modificare i file del gioco.';

  @override
  String get libraryPartialWarning =>
      'Alcuni record non sono leggibili. Le installazioni valide sono comunque mostrate.';

  @override
  String get libraryCatalogLoading => 'Controllo del catalogo attuale…';

  @override
  String get libraryCatalogError =>
      'Impossibile controllare il catalogo. I contenuti installati restano disponibili.';

  @override
  String libraryUpdateVersions(String installed, String available) {
    return '$installed → $available';
  }

  @override
  String get libraryEventInstall => 'Installato';

  @override
  String get libraryEventUpdate => 'Aggiornato';

  @override
  String get libraryEventReinstall => 'Reinstallato';

  @override
  String get libraryEventReplaced => 'Sostituito da una versione più recente';

  @override
  String get libraryForgetAction => 'DIMENTICA INSTALLAZIONE';

  @override
  String get libraryForgetTitle => 'DIMENTICARE QUESTA INSTALLAZIONE?';

  @override
  String get libraryForgetBody =>
      'SM64CDPY rimuoverà questo elemento dalla Libreria senza eliminare i file del gioco.';

  @override
  String get libraryForgetConfirm => 'DIMENTICA';

  @override
  String get libraryRemoveHistoryAction => 'RIMUOVI DALLA CRONOLOGIA';

  @override
  String get libraryRemoveHistoryTitle => 'RIMUOVERE QUESTO EVENTO?';

  @override
  String get libraryRemoveHistoryBody =>
      'Verrà rimossa solo questa voce della cronologia. L’installazione attuale e i file del gioco non cambieranno.';

  @override
  String get libraryRemoveHistoryConfirm => 'RIMUOVI';

  @override
  String get libraryMaintenanceError =>
      'Impossibile aggiornare la Libreria. Riprova.';

  @override
  String get detailOpenExternalFolder => 'APRI CARTELLA DI ORIGINE';

  @override
  String get detailSourceUnavailable =>
      'Questa versione al momento non ha file disponibili da scaricare.';

  @override
  String get detailViewDiscussion => 'VEDI DISCUSSIONE DELLA COMMUNITY';

  @override
  String get settingsInterfaceTheme => 'Tema dell’interfaccia';

  @override
  String get settingsInterfaceThemeDesc =>
      'Scegli un tema incluso. Si applica all’app; il pannello flottante mantiene il suo tema scuro.';

  @override
  String get themeMinimal => 'Minimalista';

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
  String get themeModeLight => 'Chiaro';

  @override
  String get themeModeDark => 'Scuro';

  @override
  String get themeModeSystem => 'Segui il sistema';

  @override
  String get themeSaveFailed => 'Impossibile salvare l’aspetto. Riprova.';

  @override
  String get themeSaving => 'Salvataggio dell’aspetto';

  @override
  String get gameModsTitle => 'Mod del gioco';

  @override
  String get gameModsSubtitle => 'Scegli le mod per il prossimo avvio';

  @override
  String get gameModsHint =>
      'Chiudi il gioco prima di apportare modifiche. Questi interruttori configurano mod Lua e pacchetti DynOS/comandi touch per il prossimo avvio.';

  @override
  String get gameModsSelectHint =>
      'Scegli la cartella user del gioco che contiene sm64config.txt e mods.';

  @override
  String get gameModsConfirm =>
      'Chiudi prima il gioco. Applicare questa selezione al prossimo avvio?';

  @override
  String get gameModsCancel => 'Annulla';

  @override
  String get gameModsApply => 'Applica';

  @override
  String get gameModsSelect => 'Scegli cartella user';

  @override
  String get gameModsDisconnect => 'Scollega';

  @override
  String get gameModsConflict =>
      'La configurazione è cambiata o un’altra mod attiva è incompatibile. Aggiorna e riprova.';

  @override
  String get gameModsBlocked =>
      'Impossibile attivare questa mod in sicurezza. Controllane struttura e metadati o disattiva una mod incompatibile.';

  @override
  String get gameModsMismatch =>
      'Questa cartella user non corrisponde alla cartella delle mod selezionata. Scegli la stessa installazione del gioco.';

  @override
  String get gameModsWriteError =>
      'Impossibile confermare il salvataggio. Chiudi il gioco e, se necessario, ripristina la configurazione precedente.';

  @override
  String get gameModsFormat =>
      'La configurazione o la cartella supera i limiti supportati o usa un formato non compatibile. Nessuna modifica è stata applicata.';

  @override
  String get gameModsAccess =>
      'Configurazione non disponibile. Controlla che user contenga sm64config.txt e mods, poi seleziona di nuovo la cartella con accesso in lettura e scrittura.';

  @override
  String get gameModsRestore => 'Ripristina configurazione precedente';

  @override
  String get gameModsRestoreConfirm =>
      'Con il gioco chiuso, sostituire la configurazione con il backup privato precedente all’ultima modifica? Verranno ripristinate anche le altre impostazioni.';

  @override
  String get gameModsInstalling =>
      'Attendi la fine di download e installazioni prima di modificare le mod del gioco.';

  @override
  String get gameModsEmpty =>
      'Nessuna mod Lua compatibile trovata nelle cartelle del gioco.';

  @override
  String get gameModsEnabled => 'Attiva al prossimo avvio';

  @override
  String get gameModsDisabled => 'Disattiva al prossimo avvio';

  @override
  String get gameModsMore => 'Mostra altro';

  @override
  String get gameModsSize =>
      'Questa mod raggiunge il limite di 35 MiB del gioco e non può essere attivata.';

  @override
  String get gameModsSaved =>
      'Selezione salvata e verificata per il prossimo avvio del gioco.';

  @override
  String get gameModsManage => 'Gestisci cartella del gioco';

  @override
  String gameModsCount(int enabled, int total) {
    return '$enabled di $total attive';
  }

  @override
  String get gameModsSearch => 'Cerca mod, autori, categorie…';

  @override
  String get gameModsAll => 'Tutte';

  @override
  String get gameModsEnabledFilter => 'Attive';

  @override
  String get gameModsDisabledFilter => 'Disattive';

  @override
  String get gameModsNoResults =>
      'Nessuna mod corrisponde alla ricerca o al filtro.';

  @override
  String get gameModsClearSearch => 'Cancella ricerca';

  @override
  String get gameModsDetails => 'Dettagli della mod';

  @override
  String get gameModsCloseDetails => 'Chiudi';

  @override
  String get marioRomTitle => 'Risorse del gioco originale';

  @override
  String get marioRomBuiltIn => 'ROM non selezionata';

  @override
  String get marioRomReady => 'Interfaccia originale pronta';

  @override
  String get marioRomDescription =>
      'I temi Mario usano la ROM nella cartella user collegata. Immagini e caratteri vengono preparati privatamente una volta e poi riutilizzati. Non serve selezionare un’altra ROM.';

  @override
  String get marioRomImport => 'Prepara dalla cartella del gioco';

  @override
  String get marioRomPreparing => 'Preparazione delle risorse del gioco…';

  @override
  String get marioRomCancel => 'Annulla importazione';

  @override
  String get marioRomRemove => 'Usa il tema integrato';

  @override
  String get marioRomUnsupported =>
      'Questa ROM non è compatibile. Scegli una ROM USA .z64 non modificata. Il tema precedente resta disponibile.';

  @override
  String get marioRomFailed =>
      'Impossibile leggere o salvare le risorse. Seleziona di nuovo il file e controlla lo spazio disponibile. Il tema precedente resta disponibile.';

  @override
  String get marioRomSuccess => 'Le risorse del gioco originale sono pronte.';

  @override
  String get marioRomUpgrade =>
      'Seleziona di nuovo la ROM per aggiornare l’interfaccia originale';

  @override
  String get gameFolderTitle => 'Collega SM64CoopDX';

  @override
  String get gameFolderSummary =>
      'Scegli una volta la cartella principale del gioco per trovare mod e pacchetti DynOS dentro e fuori user, oltre alla ROM per i temi Mario.';

  @override
  String get gameFolderGuide =>
      'Scegli la cartella principale com.maniscat2.sm64coopdx, quella che contiene user. Cercheremo mods e dynos/packs sia qui sia in user. Configurazione, ROM e nuove installazioni restano in user. Scegli la cartella principale, non user o un singolo file.';

  @override
  String get gameFolderChoose => 'Scegli cartella del gioco';

  @override
  String get gameFolderLater => 'Non ora';

  @override
  String get gameFolderConnected => 'Gioco collegato';

  @override
  String get gameFolderResolved =>
      'Libreria: mods, user/mods, dynos/packs e user/dynos/packs. Nuove installazioni: user/mods e user/dynos/packs.';

  @override
  String get gameFolderConfigReady =>
      'Impostazioni delle mod del gioco trovate.';

  @override
  String get gameFolderConfigMissing =>
      'Apri una volta il gioco per creare le impostazioni delle mod. Download e temi restano disponibili.';

  @override
  String get gameFolderRomFound =>
      'ROM del gioco trovata. I temi Mario potranno preparare le risorse quando li selezioni.';

  @override
  String get gameFolderRomMissing =>
      'Nessuna ROM compatibile trovata in user. Apri SM64CoopDX e configura la ROM, poi riprova.';

  @override
  String get gameFolderChange => 'Cambia cartella del gioco';

  @override
  String get gameFolderInvalid =>
      'Scegli la cartella principale che contiene user, di solito com.maniscat2.sm64coopdx. Apri una volta il gioco se user non esiste ancora.';

  @override
  String get gameFolderAccessLost =>
      'La cartella del gioco non è accessibile. Selezionala di nuovo per ricollegarla.';

  @override
  String get gameFolderDisconnect => 'Scollega il gioco';

  @override
  String get gameFolderDisconnectBody =>
      'Smetti di usare questa cartella per mod, DynOS e rilevamento ROM. File del gioco, mod installate e risorse dei temi preparate resteranno sul dispositivo.';

  @override
  String get gameFolderPrepareTitle => 'Prepara il tema Mario';

  @override
  String get gameFolderPrepareBody =>
      'Leggeremo la ROM nella cartella collegata per preparare immagini e caratteri del tema. Basta farlo una volta; ROM e configurazione del gioco resteranno invariate.';

  @override
  String get gameFolderPrepare => 'Prepara il tema';

  @override
  String get gameFolderBusy =>
      'Attendi la fine di download e installazioni prima di cambiare cartella del gioco.';

  @override
  String get gameModsLuaType => 'Mod Lua';

  @override
  String get gameModsDynosType => 'DynOS / comandi touch';

  @override
  String get gameFolderUpgrade =>
      'L’accesso è limitato a user. Scegli la cartella principale per includere anche mod e pacchetti DynOS fuori da user.';

  @override
  String get gameDynosEmpty =>
      'Nessuna cartella di pacchetti DynOS o comandi touch trovata nelle cartelle del gioco.';

  @override
  String get gameDynosSearch => 'Cerca pacchetti DynOS / comandi touch…';

  @override
  String get navPlayer => 'Giocatore';

  @override
  String get playerTitle => 'GIOCATORE';

  @override
  String get playerCharacter => 'PERSONAGGIO';

  @override
  String get player3DLoading => 'Creazione del personaggio dai dati del gioco…';

  @override
  String get player3DUnavailable =>
      'Anteprima 3D non disponibile. Verifica che SM64CoopDX e una ROM USA compatibile siano collegati.';

  @override
  String get playerName => 'Nome del giocatore';

  @override
  String get playerNameHint => 'Nome mostrato in SM64CoopDX';

  @override
  String get playerCloseGameHint =>
      'Chiudi SM64CoopDX prima di applicare. Le modifiche verranno usate al prossimo avvio.';

  @override
  String get playerPresets => 'PALETTE';

  @override
  String get playerParts => 'COLORI DEL PERSONAGGIO';

  @override
  String get playerUnsavedTitle => 'Scartare le modifiche?';

  @override
  String get playerUnsavedBody =>
      'I colori o il nome del giocatore non sono stati applicati al gioco.';

  @override
  String get playerKeepEditing => 'Continua a modificare';

  @override
  String get playerDiscard => 'Scarta';

  @override
  String get playerDeletePreset => 'Eliminare la palette?';

  @override
  String playerDeletePresetBody(String name) {
    return 'Eliminare la palette «$name»?';
  }

  @override
  String get playerCancel => 'Annulla';

  @override
  String get playerDelete => 'Elimina';

  @override
  String get playerConflict =>
      'La configurazione del gioco è cambiata. Ricaricala prima di applicare il profilo.';

  @override
  String get playerInvalid =>
      'Inserisci nome e colori validi. Il nome non può contenere spazi e può occupare fino a 63 byte UTF-8.';

  @override
  String get playerPresetExists => 'Esiste già una palette con questo nome.';

  @override
  String get playerAccessError =>
      'La configurazione del giocatore non è accessibile. Controlla la cartella del gioco collegata e la relativa autorizzazione.';

  @override
  String get playerSavePreset => 'Salva palette';

  @override
  String get playerPresetName => 'Nome della palette';

  @override
  String get playerSave => 'Salva';

  @override
  String playerOverwritePreset(String name) {
    return 'Sostituire la palette «$name»?';
  }

  @override
  String get playerOverwrite => 'Sostituisci';

  @override
  String get playerPresetSaved => 'Palette salvata per SM64CoopDX.';

  @override
  String get playerApplied =>
      'Profilo salvato e verificato per il prossimo avvio del gioco.';

  @override
  String get playerConnectGame =>
      'Collega la cartella principale di SM64CoopDX per modificare il giocatore.';

  @override
  String get playerMissingConfig =>
      'Apri una volta SM64CoopDX per creare user/sm64config.txt.';

  @override
  String get playerRetry => 'Riprova';

  @override
  String get playerHex => 'Colore esadecimale';

  @override
  String get playerRed => 'R';

  @override
  String get playerGreen => 'V';

  @override
  String get playerBlue => 'B';

  @override
  String get playerReset => 'Reimposta';

  @override
  String get playerApply => 'Applica al gioco';

  @override
  String get playerPants => 'Salopette';

  @override
  String get playerShirt => 'Maglia';

  @override
  String get playerGloves => 'Guanti';

  @override
  String get playerShoes => 'Scarpe';

  @override
  String get playerHair => 'Capelli';

  @override
  String get playerSkin => 'Pelle';

  @override
  String get playerCap => 'Cappello';

  @override
  String get playerEmblem => 'Emblema';

  @override
  String get playerRestore => 'Ripristina configurazione precedente';

  @override
  String get playerRestoreBody =>
      'Con SM64CoopDX chiuso, ripristinare il backup privato precedente all’ultima modifica di mod o giocatore? Verrà ripristinata l’intera configurazione.';

  @override
  String get playerRestored =>
      'Configurazione precedente del gioco ripristinata.';

  @override
  String get retroAccentTitle => 'Colore principale dell’interfaccia';

  @override
  String get retroAccentDescription =>
      'Scegli il colore principale per Retro Manga o Mario Kart 64. MK64 lo usa anche per sfondo, pannelli e griglia di gara.';

  @override
  String get retroAccentCyan => 'Ciano';

  @override
  String get retroAccentBlue => 'Blu';

  @override
  String get retroAccentViolet => 'Viola';

  @override
  String get retroAccentPink => 'Rosa';

  @override
  String get retroAccentCoral => 'Corallo';

  @override
  String get retroAccentAmber => 'Ambra';

  @override
  String get retroAccentGreen => 'Verde';

  @override
  String get retroAccentLime => 'Verde lime';

  @override
  String get gameToolTitle => 'Strumenti di gioco';

  @override
  String get saveFileTitle => 'Salvataggi';

  @override
  String get saveFileHint => 'Scegli un file · gioco originale';

  @override
  String get saveFileConfirm =>
      'Chiudi prima SM64CoopDX. Le modifiche si applicano al prossimo avvio. Copia e cancellazione interessano i progressi normali e alternativi dello slot scelto. Il ripristino sostituisce tutti e quattro gli slot. Prima di scrivere viene creato un backup completo.';

  @override
  String get saveFileDone => 'Salvato';

  @override
  String get saveFileMissing =>
      'Collega la cartella del gioco e avvialo una volta per creare il file di salvataggio.';

  @override
  String get saveFileError =>
      'Impossibile verificare o salvare il file. Aggiorna e riprova; le copie di recupero restano in Backup.';

  @override
  String get saveFilePrimary => 'Normale';

  @override
  String get saveFileAlternate => 'Alternativa';

  @override
  String get saveFileEmpty => 'Vuoto';

  @override
  String get saveFileUnsigned => 'Copia senza firma o danneggiata';

  @override
  String get saveFileCopy => 'Copia';

  @override
  String get saveFileProgress => 'Progressi';

  @override
  String get saveFileBackup => 'Crea backup';

  @override
  String get saveFileBackups => 'Backup';

  @override
  String get saveFileCannon => 'Cannone';

  @override
  String get saveFileCoins => 'Monete';

  @override
  String get saveFileCastle => 'Stelle del castello';

  @override
  String get saveFileUnlocks => 'Sblocchi';

  @override
  String get saveFileWing => 'Cappello alato';

  @override
  String get saveFileMetal => 'Cappello di metallo';

  @override
  String get saveFileVanish => 'Cappello invisibile';

  @override
  String get saveFileKey1 => 'Prima chiave';

  @override
  String get saveFileKey2 => 'Seconda chiave';

  @override
  String get saveFileBasement => 'Porta del seminterrato';

  @override
  String get saveFileUpstairs => 'Porta del piano superiore';

  @override
  String get saveFileMoat => 'Prosciuga il fossato';

  @override
  String get saveFileComplete => 'Completa i progressi: 120 stelle';

  @override
  String get saveFileClearStars => 'Cancella le stelle';

  @override
  String get saveFileCourseNames =>
      'Campo di battaglia Bob-omb|Fortezza di Whomp|Baia dei pirati|Montagna innevata|Dimora di Gran Boo|Grotta labirintica|Terra di lava|Deserto delle sabbie mobili|Moli oscuri|Paese del pupazzo di neve|Città asciutta e bagnata|Alta montagna|Isola grande e piccola|Orologio|Percorso arcobaleno|Bowser nel mondo oscuro|Bowser nel mare di fuoco|Bowser nel cielo|Scivolo segreto della principessa|Grotta del cappello di metallo|Torre del cappello alato|Cappello invisibile sotto il fossato|Mario alato sopra l’arcobaleno|Acquario segreto';

  @override
  String get saveFileCopies => 'Progressi di gioco';

  @override
  String get saveFileCopiesHint =>
      'Normale indica i progressi abituali. Alcune mod usano Alternativa per modalità speciali, come quella difficile. Non è un backup. Selezionarla qui non cambia i progressi usati dal gioco.';

  @override
  String get saveFileOpenSlot => 'Tocca per modificare';

  @override
  String get saveFileActions => 'Azioni dello slot';

  @override
  String get saveFileDraft => 'Anteprima · salvata solo dopo Applica';

  @override
  String get drawerResources => 'Risorse';

  @override
  String get fastInstallTitle => 'Attiva installazione più rapida';

  @override
  String get fastInstallDescription =>
      'Facoltativo: consenti l’accesso a tutti i file in Android per velocizzare l’installazione nelle cartelle compatibili. Senza questa autorizzazione l’installazione funziona normalmente.';

  @override
  String get fastInstallAccessError =>
      'Impossibile aprire le impostazioni dei permessi. Puoi continuare a installare normalmente.';

  @override
  String get playGuideTitle => 'Come giocare';

  @override
  String get playGuideIntro =>
      'La tua prima avventura, un passo alla volta. Inizia dal gioco, poi porta qui le tue mod.';

  @override
  String get playGuideNext => 'Passaggio successivo';

  @override
  String get playGuideBack => 'Passaggio precedente';

  @override
  String get playGuideOpenDownload => 'Apri download per Android';

  @override
  String get playGuideRepository => 'Repository del port Android';

  @override
  String get playGuideConnect => 'Collega cartella del gioco';

  @override
  String get playGuideLibrary => 'Apri Libreria';

  @override
  String get playGuideLaunch => 'Apri il gioco';

  @override
  String get playGuideMissingTitle => 'Prepariamo il gioco';

  @override
  String get playGuideMissingBody =>
      'SM64CoopDX Android non è installato. Segui la guida per installarlo, preparare la ROM e collegare le mod.';

  @override
  String get playGuideRead => 'Consulta la guida iniziale';

  @override
  String get playGuideLater => 'Non ora';

  @override
  String get playGuideLinkError =>
      'Impossibile aprire la pagina. Controlla la connessione e riprova.';

  @override
  String get playGuideLaunchError =>
      'Il gioco è installato, ma Android non riesce ad aprirlo. Prova la sua icona nella schermata Home.';

  @override
  String get playGuideInstalled => 'Gioco installato';

  @override
  String get playGuideNotInstalled => 'Gioco non ancora rilevato';

  @override
  String get playGuideConnected => 'Cartella del gioco collegata';

  @override
  String get playGuideNotConnected => 'Cartella del gioco non ancora collegata';

  @override
  String get playGuideReady =>
      'L’avventura ti aspetta! Puoi rivedere qualsiasi passaggio quando serve.';

  @override
  String get playGuideStep1Title => 'Procurati il gioco';

  @override
  String get playGuideStep2Title => 'Prepara la tua ROM';

  @override
  String get playGuideConvertTitle => 'Converti la mia ROM (.n64 / .v64)';

  @override
  String get playGuideStep3Title => 'Fornisci la ROM al gioco';

  @override
  String get playGuideStep4Title => 'Collega il gestore';

  @override
  String get playGuideStep5Title => 'Aggiungi la prima mod';

  @override
  String get playGuidePathsTitle => 'Dove vanno i file?';

  @override
  String get playGuideStep6Title => 'Gioca e trova aiuto';

  @override
  String get playGuideMap => 'La mappa della tua avventura';

  @override
  String get playGuideSwipe =>
      'Scorri a sinistra o a destra per cambiare capitolo';

  @override
  String get playGuideChapter => 'CAPITOLO';

  @override
  String get playGuideTip => 'Ricorda';

  @override
  String get playGuideOverview => 'Tutti i passaggi';

  @override
  String get playGuideS1Card1 =>
      'SM64CDPY gestisce le mod. SM64CoopDX Android è l’app separata che esegue il gioco.';

  @override
  String get playGuideS1Card2 =>
      'Tocca Apri download per Android. Il browser aprirà la pagina GitHub del port Android.';

  @override
  String get playGuideS1Card3 =>
      'Trova la versione pubblicata ed espandi Assets se necessario. Scarica il file che termina in .apk, non Source code. Se ci sono più build, segui i requisiti indicati per il dispositivo.';

  @override
  String get playGuideS1Card4 =>
      'Apri l’APK scaricato e tocca Installa. Se Android lo richiede, consenti a questo browser o gestore di file di installare l’APK, poi torna all’installazione.';

  @override
  String get playGuideS1Card5 =>
      'Apri una volta SM64CoopDX. Segui le sue istruzioni di archiviazione per creare la cartella del gioco.';

  @override
  String get playGuideS1Card6 =>
      'Se le richieste di Android non sono chiare, chiedi aiuto a una persona fidata.';

  @override
  String get playGuideS2Card1 =>
      'La ROM è una copia della cartuccia originale di Super Mario 64. L’APK da solo non include immagini e suoni del gioco originale.';

  @override
  String get playGuideS2Card2 =>
      'Usa la tua copia USA non modificata in formato .z64. Questa guida non fornisce ROM. Un ZIP è un archivio: estrailo prima per vedere il file al suo interno.';

  @override
  String get playGuideS2Card3 => 'È già .z64? Vai al passaggio successivo.';

  @override
  String get playGuideS2Card4 =>
      'Il file termina in .n64 o .v64? Apri «Converti la mia ROM» qui sotto.';

  @override
  String get playGuideS2Card5 =>
      'Regione diversa o gioco modificato? Cambiare nome o formato non lo renderà un originale USA.';

  @override
  String get playGuideS3Card1 => 'Apri SM64CoopDX Android.';

  @override
  String get playGuideS3Card2 =>
      'Se chiede una ROM, seleziona il file USA .z64, di solito in Download. Lascia che il gioco finisca di prepararlo.';

  @override
  String get playGuideS3Card3 =>
      'Se la tua versione non ha un selettore, chiudi il gioco. Con il gestore di file copia il .z64 in Memoria interna → com.maniscat2.sm64coopdx → user. Riapri il gioco.';

  @override
  String get playGuideS3Card4 =>
      'Attendi di raggiungere il menu del gioco. Se la ROM viene rifiutata, controlla regione, contenuto originale non modificato e conversione effettiva in .z64.';

  @override
  String get playGuideS3Card5 =>
      'Il gioco conserva la ROM USA accettata in user/baserom.us.z64. La cartella può dipendere dai suoi permessi di archiviazione; segui il percorso indicato dal gioco.';

  @override
  String get playGuideS4Card1 =>
      'Torna in SM64CDPY e tocca Collega cartella del gioco. Spieghiamo cosa scegliere prima di aprire la finestra delle cartelle di Android.';

  @override
  String get playGuideS4Card2 =>
      'Apri Memoria interna → com.maniscat2.sm64coopdx.';

  @override
  String get playGuideS4Card3 =>
      'Seleziona questa cartella principale, quella che contiene user, poi tocca Usa questa cartella / Consenti. Non scegliere Download, solo user o il file ROM.';

  @override
  String get playGuideS4Card4 =>
      'Una selezione collega mod, DynOS, impostazioni del gioco e rilevamento ROM. Se manca user, apri e prepara prima il gioco. Se Android blocca l’accesso, controlla l’archiviazione del gioco; una cartella vuota non pertinente non risolve il problema.';

  @override
  String get playGuideS4Card5 =>
      'È già collegato? Continua. Non serve scegliere le stesse cartelle per ogni mod.';

  @override
  String get playGuideS5Card1 =>
      'Chiudi il gioco prima di installare o modificare mod.';

  @override
  String get playGuideS5Card2 =>
      'Apri Catalogo e scegli una mod. Leggi le note di compatibilità.';

  @override
  String get playGuideS5Card3 =>
      'Scaricala. Con l’installazione automatica attiva, attendi Installato: la fine del download non significa che l’installazione sia finita. Altrimenti segui la richiesta di installazione manuale o attiva l’opzione in Impostazioni.';

  @override
  String get playGuideS5Card4 =>
      'Apri Strumenti di gioco → Libreria. Mod del gioco contiene le mod Lua. DynOS / comandi touch contiene pacchetti di modelli, texture e comandi. Attiva l’elemento desiderato.';

  @override
  String get playGuideS5Card5 =>
      'Riapri il gioco per caricare le modifiche. Alcuni pacchetti richiedono impostazioni nel gioco; segui le istruzioni dell’autore.';

  @override
  String get playGuideS6Card1 =>
      'Tocca Apri il gioco qui sotto. Scegli uno slot di salvataggio nel gioco e goditi l’avventura.';

  @override
  String get playGuideS6Card2 =>
      'Il gioco non si apre? Prova prima dalla schermata Home di Android.';

  @override
  String get playGuideS6Card3 =>
      'ROM rifiutata? Ricontrolla l’originale USA e il formato .z64 al passaggio 2.';

  @override
  String get playGuideS6Card4 =>
      'La mod non compare? Controlla che l’installazione sia finita, attivala in Libreria e riavvia il gioco. Verifica se richiede un’altra mod.';

  @override
  String get playGuideS6Card5 =>
      'Accesso alla cartella perso? Ricollega la cartella principale al passaggio 4.';

  @override
  String get playGuideS6Card6 =>
      'Prova una mod alla volta. Se qualcosa non funziona, disattivala e riapri il gioco. Conserva un backup prima di eliminare file del gioco.';

  @override
  String get playGuideConvertCard1 => 'Conserva il file originale come backup.';

  @override
  String get playGuideConvertCard2 =>
      'Apri il convertitore di ROM nel browser.';

  @override
  String get playGuideConvertCard3 => 'Scegli il tuo file .n64 o .v64.';

  @override
  String get playGuideConvertCard4 =>
      'Scegli .z64 come formato di uscita e salva il file convertito, di solito in Download.';

  @override
  String get playGuideConvertCard5 =>
      'Torna qui e continua con quel file .z64.';

  @override
  String get playGuideConvertCard6 =>
      'La conversione riordina i byte del file. Rinominare .n64 in .z64 non lo converte. È uno strumento esterno; se non è disponibile, usa un altro convertitore dell’ordine dei byte N64 con uscita .z64.';

  @override
  String get playGuidePathsCard1 =>
      'In Memoria interna → com.maniscat2.sm64coopdx:';

  @override
  String get playGuidePathsCard2 =>
      'user/mods → nuove installazioni di mod Lua. Una mod può essere un file .lua o una cartella con main.lua.';

  @override
  String get playGuidePathsCard3 =>
      'user/dynos/packs → nuovi pacchetti DynOS e comandi touch. I comandi touch condividono questa destinazione.';

  @override
  String get playGuidePathsCard4 =>
      'user/baserom.us.z64 → ROM USA originale accettata dal gioco.';

  @override
  String get playGuidePathsCard5 =>
      'user/sm64config.txt → impostazioni del gioco ed elementi attivi. Lascia che lo gestisca l’app anziché modificarlo a mano.';

  @override
  String get playGuidePathsCard6 =>
      'Il gioco legge anche mods e dynos/packs fuori da user. Il gestore li mostra quando è collegata la cartella principale. Con nomi duplicati, Lua dà priorità a user/mods; DynOS a dynos/packs fuori da user. Evita due copie con lo stesso nome.';

  @override
  String get playGuideS1Title1 => 'Due app, due ruoli';

  @override
  String get playGuideS1Title2 => 'Apri la pagina Android';

  @override
  String get playGuideS1Title3 => 'Scegli l’APK';

  @override
  String get playGuideS1Title4 => 'Installa il gioco';

  @override
  String get playGuideS1Title5 => 'Aprilo una volta';

  @override
  String get playGuideS1Title6 => 'Una mano d’aiuto';

  @override
  String get playGuideS2Title1 => 'Che cos’è una ROM?';

  @override
  String get playGuideS2Title2 => 'La copia necessaria';

  @override
  String get playGuideS2Title3 => 'È già .z64';

  @override
  String get playGuideS2Title4 => 'Ho un file .n64 o .v64';

  @override
  String get playGuideS2Title5 => 'La regione conta';

  @override
  String get playGuideS3Title1 => 'Apri SM64CoopDX';

  @override
  String get playGuideS3Title2 => 'Scegli la ROM';

  @override
  String get playGuideS3Title3 => 'Se non c’è un selettore';

  @override
  String get playGuideS3Title4 => 'Raggiungi il menu del gioco';

  @override
  String get playGuideS3Title5 => 'Dove risiede la ROM';

  @override
  String get playGuideS4Title1 => 'Torna al gestore';

  @override
  String get playGuideS4Title2 => 'Trova la cartella principale';

  @override
  String get playGuideS4Title3 => 'Autorizza la cartella';

  @override
  String get playGuideS4Title4 => 'Un solo collegamento';

  @override
  String get playGuideS4Title5 => 'Già collegato?';

  @override
  String get playGuideS5Title1 => 'Chiudi prima il gioco';

  @override
  String get playGuideS5Title2 => 'Scegli una mod';

  @override
  String get playGuideS5Title3 => 'Attendi l’installazione';

  @override
  String get playGuideS5Title4 => 'Attivala in Libreria';

  @override
  String get playGuideS5Title5 => 'Riavvia e prova';

  @override
  String get playGuideS6Title1 => 'Inizia l’avventura';

  @override
  String get playGuideS6Title2 => 'Il gioco non si apre';

  @override
  String get playGuideS6Title3 => 'La ROM viene rifiutata';

  @override
  String get playGuideS6Title4 => 'La mod non compare';

  @override
  String get playGuideS6Title5 => 'Permesso della cartella perso';

  @override
  String get playGuideS6Title6 => 'Prova una alla volta';

  @override
  String get romPrepareNav => 'Prepara ROM';

  @override
  String get romPrepareTitle => 'Prepara la tua ROM';

  @override
  String get romPrepareDescription =>
      'Scegli il tuo file Super Mario 64. L’app crea e verifica una copia .z64 compatibile senza modificare l’originale.';

  @override
  String get romPreparePrivacy =>
      'SM64CDPY non include, scarica o condivide ROM. Il file scelto viene elaborato localmente sul dispositivo.';

  @override
  String get romPrepareChoose => 'Scegli ROM';

  @override
  String get romPrepareChooseAnother => 'Scegli un altro file';

  @override
  String get romPrepareAnother => 'Prepara un’altra ROM';

  @override
  String get romPrepareSave => 'Salva copia .z64';

  @override
  String get romPrepareContinue => 'Continua con la guida';

  @override
  String get romPrepareCancel => 'Annulla';

  @override
  String get romPrepareIdle => 'Pronto a controllare il file';

  @override
  String get romPreparePicking => 'Scegli il file in Android';

  @override
  String get romPrepareInspecting => 'Controllo del file scelto';

  @override
  String get romPrepareConverting => 'Preparazione di una copia compatibile';

  @override
  String get romPrepareValidating => 'Verifica della ROM preparata';

  @override
  String get romPrepareReady => 'ROM compatibile pronta';

  @override
  String get romPrepareAlreadyCompatible =>
      'La ROM era già nel formato corretto';

  @override
  String get romPrepareChoosingDestination => 'Scegli dove salvare la copia';

  @override
  String get romPrepareExporting => 'Salvataggio della copia';

  @override
  String get romPrepareVerifyingExport => 'Verifica della copia salvata';

  @override
  String get romPrepareSaved => 'Copia salvata e verificata';

  @override
  String get romPrepareCancelling => 'Arresto in sicurezza';

  @override
  String get romPrepareCancelled => 'Preparazione annullata';

  @override
  String get romPrepareFailed => 'Impossibile preparare la ROM';

  @override
  String romPrepareDetected(String format) {
    return 'Formato rilevato: $format';
  }

  @override
  String romPrepareSavedAs(String name) {
    return 'Salvato come $name';
  }

  @override
  String get romPrepareErrorUnrecognized =>
      'Il formato di questo file non è riconosciuto come ROM N64.';

  @override
  String get romPrepareErrorSize =>
      'La ROM originale di Super Mario 64 deve essere esattamente di 8 MiB.';

  @override
  String get romPrepareErrorIncompatible =>
      'Serve una ROM USA originale di Super Mario 64 non modificata.';

  @override
  String get romPrepareErrorPermission =>
      'Android non consente più l’accesso al file. Selezionalo di nuovo.';

  @override
  String get romPrepareErrorStorage =>
      'Lo spazio disponibile non è sufficiente o il file non è leggibile.';

  @override
  String get romPrepareErrorExport =>
      'Impossibile verificare la copia salvata. Scegli un’altra destinazione e riprova.';

  @override
  String get romPrepareErrorBusy =>
      'Un’altra operazione su una ROM è già attiva.';

  @override
  String get romPrepareErrorUnexpected =>
      'Si è verificato un errore imprevisto. Il file originale non è stato modificato.';

  @override
  String get mangaNavLibrary => 'Libreria';

  @override
  String get mangaNavExplore => 'Esplora';

  @override
  String get mangaMenuLabel => 'Menu';

  @override
  String get mangaMenuOpen => 'Apri menu';

  @override
  String get mangaMenuClose => 'Chiudi menu';

  @override
  String get mangaNavTools => 'Strumenti';

  @override
  String get mangaNavMore => 'Altro';

  @override
  String get mangaNavPlay => 'Gioca';

  @override
  String get mangaNavHint => 'Scorri per sfogliare. Tocca per aprire.';

  @override
  String get mangaNavError => 'Impossibile completare l’azione. Riprova.';

  @override
  String get mangaMenuSoundsTitle => 'Suoni del menu';

  @override
  String get mangaMenuSoundsDescription =>
      'Effetti sonori all’apertura, alla selezione e allo scorrimento del menu.';

  @override
  String get appEffectsVolume => 'Volume degli effetti';

  @override
  String get appEffectsVolumeDescription =>
      'Regola solo gli effetti di questa app. Il volume multimediale del dispositivo resta il limite.';

  @override
  String get ambientMusicTitle => 'Musica di sottofondo';

  @override
  String get ambientMusicDescription =>
      'Una musica leggera mentre usi Retro Manga. Si mette in pausa quando esci dall’app.';

  @override
  String get ambientMusicVolume => 'Volume della musica';

  @override
  String get mangaNavAudio => 'Audio';

  @override
  String get themeMangaDeluxe => 'Manga Deluxe';

  @override
  String get deluxeWelcome => 'Benvenuto in CoopDX';

  @override
  String get deluxeWelcomeBody =>
      'Il tuo compagno Android per le mod: prepara il gioco, scopri mod e incontra la community CoopDX.';

  @override
  String get deluxeSpotlight => 'Dalla vetrina CoopDX';

  @override
  String get deluxeDncBody =>
      'Cieli e illuminazione variabili, con un ciclo giorno/notte completo. Guarda la mod in azione prima di esplorarne i dettagli.';

  @override
  String get deluxeViewMod => 'Vedi mod';

  @override
  String get deluxeWatchDemo => 'Guarda la demo';

  @override
  String get deluxeDemoHint =>
      'Apre il video ufficiale fuori dall’app. Richiede internet.';

  @override
  String get deluxeLinkError =>
      'Impossibile aprire il link. Controlla la connessione e riprova.';

  @override
  String get deluxeHelpTitle => 'Aiuto rapido';

  @override
  String get deluxeFaqRom => 'Quale ROM serve?';

  @override
  String get deluxeFaqRomAnswer =>
      'Usa la tua copia USA verificata in formato .z64. Prepara ROM può convertirne una copia senza modificare l’originale.';

  @override
  String get deluxeFaqFolders => 'Quale cartella devo scegliere?';

  @override
  String get deluxeFaqFoldersAnswer =>
      'Usa Collega cartella del gioco. La guida spiega il percorso da scegliere e il gestore rileva mod e pacchetti compatibili.';

  @override
  String get deluxeFaqPacks => 'Mod del gioco o DynOS?';

  @override
  String get deluxeFaqPacksAnswer =>
      'Le mod Lua cambiano il funzionamento del gioco. I pacchetti DynOS forniscono modelli, texture e comandi touch. Gestiscili nelle sezioni separate della Libreria.';

  @override
  String get deluxeOpenGuide => 'Apri';

  @override
  String get deluxeCommunity => 'Community e link';

  @override
  String get deluxeGameNews => 'Novità del gioco Android';

  @override
  String get deluxeMotion => 'Sfondo in movimento';

  @override
  String get deluxeMotionHint =>
      'Scorrimento facoltativo di cappelli e motivo. Lascialo disattivato per risparmiare batteria.';

  @override
  String get deluxeReducedMotion =>
      'Il movimento è in pausa per le impostazioni di accessibilità.';

  @override
  String get deluxeReset => 'Reimposta aspetto e audio Deluxe';

  @override
  String get deluxeResetDone => 'Aspetto e audio Deluxe ripristinati.';

  @override
  String get deluxeMusicDescription =>
      'Una musica leggera per Manga Deluxe. Si mette in pausa quando esci dall’app.';

  @override
  String get deluxeAccentDescription =>
      'Scegli i colori dell’inchiostro e del motivo di sfondo per Manga Deluxe.';

  @override
  String get deluxeResetHint =>
      'Ripristina il colore principale condiviso e i livelli audio. Cartelle, mod e salvataggi restano invariati.';

  @override
  String get deluxeWelcomeCompact =>
      'Sei nuovo? Configura il gioco con la guida rapida.';

  @override
  String get deluxeSkip => 'Salta';

  @override
  String get deluxeSkipHint =>
      'Nascondi definitivamente questa introduzione. La guida resta nel menu.';

  @override
  String get coopTitle => 'Gioca con gli amici';

  @override
  String get coopNav => 'Gioca';

  @override
  String get coopIntro =>
      'Crea una stanza privata o unisciti con il codice di un amico. L’assistente collega SM64CoopDX via internet mentre il gioco usa la connessione diretta locale.';

  @override
  String get coopPrivacy =>
      'Il codice della stanza è un segreto condiviso. La segnalazione usa il servizio Cloudflare compatibile; il traffico di gioco passa direttamente quando possibile e usa TURN solo quando necessario.';

  @override
  String get coopConsentTitle => 'Privacy di rete';

  @override
  String get coopConsentIntro =>
      'Prima di creare o unirti a una stanza, controlla come funziona la connessione.';

  @override
  String get coopConsentEncrypted =>
      'Dal codice della stanza viene derivata la chiave che cifra la segnalazione WebRTC. Condividilo solo con persone fidate.';

  @override
  String get coopConsentIp =>
      'Il tuo indirizzo internet può essere visibile all’amico invitato e ai servizi di rilevamento degli indirizzi di Google e Cloudflare.';

  @override
  String get coopConsentThirdParty =>
      'Segnalazione e accesso al relay usano un servizio Cloudflare di terze parti compatibile. Disponibilità e conservazione dei dati dipendono da quel servizio.';

  @override
  String get coopConsentAccept => 'Ho capito, continua';

  @override
  String get coopConsentCancel => 'Non ora';

  @override
  String get coopConsentReview => 'Rivedi privacy di rete';

  @override
  String get coopConsentSaveError =>
      'Impossibile salvare la scelta. Nessuna sessione di rete è stata avviata.';

  @override
  String get coopCreate => 'Crea stanza';

  @override
  String get coopJoin => 'Unisciti alla stanza';

  @override
  String get coopCode => 'Codice amico';

  @override
  String get coopCodeHint => 'ABCD-1234';

  @override
  String get coopRecent => 'Codici recenti';

  @override
  String get coopClearRecent => 'Cancella';

  @override
  String get coopWaiting => 'In attesa di amici';

  @override
  String get coopConnecting => 'Ricerca del tuo amico';

  @override
  String get coopConnected => 'Sessione connessa';

  @override
  String get coopReconnecting => 'Riconnessione';

  @override
  String get coopPreparing => 'Preparazione della stanza sicura';

  @override
  String get coopStop => 'Termina sessione';

  @override
  String get coopOpenGame => 'Apri SM64CoopDX';

  @override
  String get coopGameMissing =>
      'SM64CoopDX non è installato su questo dispositivo.';

  @override
  String get coopGameReady => 'SM64CoopDX rilevato';

  @override
  String get coopHostInstruction =>
      'Nel gioco apri Multiplayer > Direct Connection > Host. Gli amici si uniscono con il codice mostrato qui.';

  @override
  String coopJoinInstruction(int port) {
    return 'Nel gioco apri Multiplayer > Direct Connection e collegati a 127.0.0.1 usando la porta $port.';
  }

  @override
  String get coopCopy => 'Copia codice';

  @override
  String get coopCopied => 'Codice copiato';

  @override
  String get coopShare => 'Condividi invito';

  @override
  String get coopShareSubject => 'Invito a una partita SM64CoopDX';

  @override
  String coopShareMessage(String code) {
    return 'Unisciti alla mia partita SM64CoopDX!\n\nCodice amico: $code\n\nApri SM64CDPY, vai in Gioca, scegli Unisciti alla stanza e inserisci questo codice. Condividilo solo con persone fidate.';
  }

  @override
  String get coopShareError =>
      'Impossibile condividere l’invito. Prova a copiare il codice.';

  @override
  String coopPeers(int count) {
    return 'Amici: $count';
  }

  @override
  String get coopDirect => 'Diretto';

  @override
  String get coopRelay => 'Relay';

  @override
  String get coopNoCode => 'Inserisci un codice valido di otto caratteri.';

  @override
  String get coopNetworkError =>
      'Impossibile avviare la sessione. Controlla la connessione e riprova.';

  @override
  String get coopBatteryTitle => 'Connessione in background';

  @override
  String get coopBatteryDescription =>
      'Facoltativo: consenti l’uso senza restrizioni della batteria per ridurre la probabilità che Android sospenda la sessione mentre il gioco è aperto.';

  @override
  String get coopBatteryAllowed =>
      'L’uso senza restrizioni della batteria è consentito. Android può mantenere la sessione attiva più facilmente.';

  @override
  String get coopBatteryAllow => 'Consenti in Android';

  @override
  String get coopBatteryManage => 'Gestisci in Android';

  @override
  String get coopBatteryOpenError =>
      'Impossibile aprire le impostazioni della batteria di Android su questo dispositivo.';

  @override
  String get coopDiagnosticsTitle => 'Diagnostica della connessione';

  @override
  String coopDiagnosticsSignal(int count) {
    return 'Connessioni di segnalazione: $count';
  }

  @override
  String coopDiagnosticsPackets(int toGame, int toPage) {
    return 'Pacchetti di gioco: $toGame ricevuti · $toPage inviati';
  }

  @override
  String coopDiagnosticsDelay(int average, int max) {
    return 'Ritardo del collegamento: $average ms in media · $max ms massimo';
  }

  @override
  String get homeCardSoundsTitle => 'Suoni delle schede Home';

  @override
  String get homeCardSoundsDescription =>
      'Un suono quando cambi scheda In evidenza o Sfoglia. Separato dagli effetti del menu e dalla musica.';

  @override
  String get homeCardSoundsVolume => 'Volume delle schede';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageSaveFailed => 'Impossibile salvare la lingua. Riprova.';

  @override
  String get sharedCopyDetails => 'Copia dettagli';

  @override
  String get sharedCopied => 'Copiato negli appunti';

  @override
  String sharedAuthor(String author) {
    return 'Autore: $author';
  }

  @override
  String get sharedUntitled => 'Senza titolo';

  @override
  String get render96Required => 'NECESSARIO';

  @override
  String get render96Optional => 'FACOLTATIVO';

  @override
  String get render96Skinpack => 'PACCHETTO DI MODELLI';

  @override
  String get settingsExportFailed =>
      'Impossibile esportare i preferiti. Riprova.';

  @override
  String get settingsImportFailed =>
      'Impossibile importare il file. Scegli un file di preferiti esportato da SM64CDPY.';

  @override
  String get settingsDatabaseFailed =>
      'Impossibile aggiornare il catalogo. Controlla la connessione e riprova.';

  @override
  String get updateActionFailed =>
      'Impossibile completare l’aggiornamento. Riprova o scaricalo dal browser.';

  @override
  String get render96WatchTrailer => 'GUARDA IL TRAILER';

  @override
  String get render96CategoryOther => 'CONTENUTO';

  @override
  String get coopConnectionFailed =>
      'La partita non è potuta continuare. Controlla la connessione e avviala di nuovo.';

  @override
  String get catalogLoadFailed =>
      'Impossibile caricare questo contenuto. Controlla la connessione e riprova.';

  @override
  String get settingsFavouritesShareSubject => 'Preferiti SM64CoopDX';

  @override
  String get favEmptyActionHint => 'Tocca ♥ su una scheda per salvarla qui.';

  @override
  String get guidedSetupWelcomeTitle => 'Benvenuto';

  @override
  String get guidedSetupWelcomeBody =>
      'Che bello averti qui! Prepariamo insieme la tua avventura tra i mod. Mantieni sempre il controllo e gli accessi facoltativi possono aspettare finché non servono.';

  @override
  String guidedSetupProgress(int current, int total) {
    return 'Passaggio $current di $total';
  }

  @override
  String get guidedSetupStart => 'Inizia';

  @override
  String get guidedSetupLater => 'Più tardi';

  @override
  String get guidedSetupAudioTitle => 'Audio dell’app';

  @override
  String get guidedSetupAudioBody =>
      'Vuoi ascoltare musica di sottofondo ed effetti sonori mentre esplori i tuoi mod? Potrai regolarli separatamente in seguito nelle Impostazioni.';

  @override
  String get guidedSetupAudioOn => 'Con audio';

  @override
  String get guidedSetupAudioOff => 'Modalità silenziosa';

  @override
  String get guidedSetupAudioSaveError =>
      'Impossibile salvare la preferenza audio. Riprova.';

  @override
  String get guidedSetupDoneTitle => 'Tutto pronto';

  @override
  String get guidedSetupDoneBody =>
      'La configurazione di base è completa. Gli accessi facoltativi restano disponibili nelle Impostazioni.';

  @override
  String get guidedSetupFinish => 'Fine';

  @override
  String get permissionCenterTitle => 'Autorizzazioni e accessi';

  @override
  String get permissionCenterSubtitle => 'Controlla cosa usa l’app e perché';

  @override
  String get permissionCenterIntro =>
      'Concedi un accesso solo quando ne comprendi lo scopo. Gli accessi facoltativi vengono richiesti nel contesto e lo stato arriva da Android.';

  @override
  String get permissionStatusAllowed => 'Consentito';

  @override
  String get permissionStatusNotAllowed => 'Non consentito';

  @override
  String get permissionStatusOptional => 'Facoltativo · verifica';

  @override
  String get permissionManage => 'Gestisci';

  @override
  String get permissionFolderDescription =>
      'Consente di trovare, installare e gestire mod e file del giocatore nella cartella scelta.';

  @override
  String get permissionNotificationsDescription =>
      'Mostra l’avanzamento di download e installazioni. Richiesto solo quando serve.';

  @override
  String get permissionAllFilesDescription =>
      'Installazione rapida facoltativa sui dispositivi compatibili. L’accesso alla cartella funziona anche senza.';

  @override
  String get permissionOverlayDescription =>
      'Bolla di download facoltativa sopra altre app.';

  @override
  String get permissionBatteryDescription =>
      'Facoltativo per sessioni di gioco più lunghe in background.';

  @override
  String get permissionUpdatesTitle => 'Installa aggiornamenti';

  @override
  String get permissionUpdatesDescription =>
      'Android richiede questo accesso speciale solo durante l’installazione di un aggiornamento.';

  @override
  String get permissionNetworkTitle => 'Rete e Gioca';

  @override
  String get permissionNetworkDescription =>
      'Internet alimenta il catalogo e le sessioni online. Gioca chiede il consenso prima della connessione.';

  @override
  String get permissionRunGuide => 'Ripeti configurazione guidata';

  @override
  String get permissionRunGuideDescription =>
      'Riapre i passaggi senza modificare direttamente le autorizzazioni Android.';

  @override
  String get detailArtifactRecommended => 'CONSIGLIATO';

  @override
  String get detailArtifactTextures => 'Texture';

  @override
  String get detailArtifactVoices => 'Voci aggiuntive';

  @override
  String get detailArtifactPrimaryDescription =>
      'Pacchetto principale completo. Inizia da questo file.';

  @override
  String get detailArtifactLiteDescription =>
      'Variante leggera senza alcune funzioni non essenziali.';

  @override
  String get detailArtifactApiDescription =>
      'Componenti opzionali che usano l’API della mod; non è la mod principale.';

  @override
  String get detailArtifactTexturesDescription =>
      'Risorse grafiche opzionali per questa mod.';

  @override
  String get detailArtifactVoicesDescription =>
      'Pacchetto di voci opzionale; installa prima la mod principale.';

  @override
  String get detailArtifactOptionalDescription =>
      'File complementare opzionale. Controlla la descrizione prima di installarlo.';
}
