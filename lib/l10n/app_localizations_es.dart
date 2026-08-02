// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get hello => 'Hola';

  @override
  String get navHome => 'Inicio';

  @override
  String get navCatalog => 'Catálogo';

  @override
  String get navFavourites => 'Favoritos';

  @override
  String get navPopular => 'Popular';

  @override
  String get navVIPMods => 'VIP Mods';

  @override
  String get navDynOS => 'DynOS';

  @override
  String get navTouchControls => 'Controles Táctiles';

  @override
  String get navOmmRebirth => 'OMMR PACK';

  @override
  String get navLinksResource => 'Enlaces y Recursos';

  @override
  String get navDisclaimer => 'Aviso Legal';

  @override
  String get navChangelog => 'Registro de Cambios';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get sectionExclusive => 'EXCLUSIVO';

  @override
  String get sectionExplore => 'EXPLORAR';

  @override
  String get sectionCategories => 'CATEGORÍAS';

  @override
  String get sectionSortBy => 'ORDENAR POR';

  @override
  String get sectionSocialLinks => 'ENLACES SOCIALES';

  @override
  String get sortDefault => 'Predeterminado';

  @override
  String get sortRating => 'Calificación';

  @override
  String get sortDownloads => 'Descargas';

  @override
  String get sortNewest => 'Más Reciente';

  @override
  String get socialYouTube => 'YouTube';

  @override
  String get socialDiscord => 'Discord';

  @override
  String get socialGitHub => 'GitHub';

  @override
  String get categoryCharacters => 'Personajes';

  @override
  String get categoryGameModes => 'Modos de Juego';

  @override
  String get categoryROMHacks => 'ROM Hacks y Niveles';

  @override
  String get categoryGameplay => 'Jugabilidad y Mecánicas';

  @override
  String get categoryVisual => 'Visual y Modelos';

  @override
  String get categoryAudio => 'Audio y Voz';

  @override
  String get categoryUtilities => 'Utilidades y Herramientas';

  @override
  String get categoryMisc => 'Misceláneos y Diversión';

  @override
  String get badgeFeatured => 'DESTACADO';

  @override
  String get updateRequired => 'ACTUALIZACIÓN REQUERIDA';

  @override
  String get updateAvailable => 'NUEVA VERSIÓN DISPONIBLE';

  @override
  String updateVersion(String version) {
    return 'Versión $version';
  }

  @override
  String updateSize(String size) {
    return 'Tamaño: $size MB';
  }

  @override
  String get updateWhatIsNew => 'Novedades:';

  @override
  String get updateGenericDescription =>
      'Mejoras menores y corrección de errores.';

  @override
  String updateDownloading(String pct) {
    return 'Descargando... $pct%';
  }

  @override
  String get updateAlreadyDownloading =>
      'Ya hay una descarga en curso. Espere o reinicie la app.';

  @override
  String get updatePermissionDenied =>
      'Permiso de instalación denegado.\nVaya a Ajustes → Apps → esta app → Instalar apps desconocidas.';

  @override
  String updateInternalError(String detail) {
    return 'Error interno: $detail';
  }

  @override
  String get updateDownloadError => 'Error de descarga. Verifique su conexión.';

  @override
  String get updateChecksumError =>
      'El archivo descargado está dañado. Intente de nuevo.';

  @override
  String updateInstallError(String detail) {
    return 'Error de instalación: $detail';
  }

  @override
  String updateUnexpectedError(String detail) {
    return 'Error inesperado: $detail';
  }

  @override
  String updateCantStart(String detail) {
    return 'No se pudo iniciar la actualización: $detail';
  }

  @override
  String get updateButtonOpenBrowser => 'ABRIR EN NAVEGADOR';

  @override
  String get updateButtonLater => 'DESPUÉS';

  @override
  String get updateButtonExit => 'SALIR';

  @override
  String get updateButtonUpdateNow => 'ACTUALIZAR AHORA';

  @override
  String get updateButtonGoToDownloads => 'IR A DESCARGAS';

  @override
  String get postInstallTitle => 'Mod instalado';

  @override
  String get postInstallGameRunning =>
      'Si el juego ya estaba abierto, ciérrelo por completo (no solo minimizar) y vuelva a abrirlo para que los nuevos archivos se carguen correctamente.';

  @override
  String get postInstallNoRoot =>
      'No necesita forzar cierre ni root. Solo cierre el juego normalmente y vuelva a abrirlo.';

  @override
  String get postInstallFilesCopied =>
      'Los archivos se copiaron a la carpeta de mods.';

  @override
  String get postInstallClose => 'Cerrar';

  @override
  String get postInstallLaunchGame => 'ABRIR JUEGO';

  @override
  String get homeExclusiveContent => 'Contenido Exclusivo';

  @override
  String get homeTopDownloads => 'Más Descargados';

  @override
  String get homeSeeAll => 'Ver todo';

  @override
  String get homeFeatured => 'Destacados';

  @override
  String get homeCatalog => 'Catálogo';

  @override
  String get homeCatalogDesc =>
      'Explora, busca y filtra toda la colección de mods';

  @override
  String get homeFavorites => 'Favoritos';

  @override
  String get homeFavoritesDesc => 'Tus mods guardados de todas las secciones';

  @override
  String get homePopular => 'Popular';

  @override
  String get homePopularDesc => 'Mejores mods por total de descargas';

  @override
  String get homeBrowse => 'Explorar';

  @override
  String get homeGoTo => 'IR A';

  @override
  String get homeVipMods => 'VIP Mods';

  @override
  String get homeVipModsDesc => 'Packs exclusivos de personajes y modelos';

  @override
  String get homeDynos => 'DynOS';

  @override
  String get homeDynosDesc =>
      'Texturas personalizadas e intercambio de modelos';

  @override
  String get homeTouchControls => 'Controles Táctiles';

  @override
  String get homeTouchControlsDesc =>
      'Diseños personalizados de botones y joysticks';

  @override
  String get homeOmmrPack => 'OMMR PACK';

  @override
  String get homeOmmrPackDesc => 'Pack de texturas completo OMM Rebirth';

  @override
  String get homeGameNotInstalled => 'Juego no instalado';

  @override
  String get homeGameNotInstalledBody =>
      'SM64CoopDX (com.maniscat2.sm64coopdx)\nno está instalado en este dispositivo.';

  @override
  String get homeClose => 'Cerrar';

  @override
  String get homeDownload => 'Descargar';

  @override
  String get homeLaunchGame => 'ABRIR JUEGO';

  @override
  String get homeSoon => 'PRONTO';

  @override
  String get homeFailedToLoad => 'Error al cargar mods';

  @override
  String get homeRetry => 'Reintentar';

  @override
  String get catalogueTitle => 'EXPLORAR MODS';

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
      other: '$count RESULTADOS',
      one: '$count RESULTADO',
    );
    return '$_temp0';
  }

  @override
  String get catalogueSearchHint => 'BUSCAR MODS, AUTORES, ETIQUETAS…';

  @override
  String get catalogueSortDefault => 'Predeterminado';

  @override
  String get catalogueSortTopRated => 'Mejor Calificados';

  @override
  String get catalogueSortMostDownloaded => 'Más Descargados';

  @override
  String get catalogueSortRecentlyUpdated => 'Actualizados Recientemente';

  @override
  String get catalogueClearAll => 'LIMPIAR TODO';

  @override
  String cataloguePaginationRange(int start, int end, int total) {
    return '$start–$end DE $total MODS';
  }

  @override
  String get catalogueNoModsFound => 'NO SE ENCONTRARON MODS';

  @override
  String get catalogueNothingHere => 'NADA AQUÍ AÚN';

  @override
  String get catalogueEmptyHint1 =>
      'Prueba otras palabras o quita los filtros.';

  @override
  String get catalogueEmptyHint2 =>
      'Vuelve más tarde para ver nuevo contenido.';

  @override
  String get catalogueClearFilters => 'LIMPIAR FILTROS';

  @override
  String get catalogueFailedToLoad => 'ERROR AL CARGAR MODS';

  @override
  String get catalogueRating => 'CALIFICACIÓN';

  @override
  String get catalogueDownloads => 'DESCARGAS';

  @override
  String get catalogueNewest => 'MÁS RECIENTE';

  @override
  String get catalogueSort => 'ORDENAR';

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
  String get popularMoreRankings => 'MÁS RANKINGS';

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
  String get popularFailedToLoad => 'ERROR AL CARGAR';

  @override
  String get favouritesTitle => 'Favoritos';

  @override
  String get favTabMods => 'Mods';

  @override
  String get favTabVip => 'VIP';

  @override
  String get favTabDynos => 'DynOS';

  @override
  String get favTabTouch => 'Táctil';

  @override
  String get favEmptyMods => 'Aún no hay mods en favoritos';

  @override
  String get favEmptyVip => 'Aún no hay VIP mods en favoritos';

  @override
  String get favEmptyDynos => 'Aún no hay DynOS en favoritos';

  @override
  String get favEmptyTouch => 'Aún no hay Controles Táctiles en favoritos';

  @override
  String favEmptyHint(String type) {
    return 'Toca ♥ en cualquier $type para guardarlo aquí.';
  }

  @override
  String get favBrowse => 'Explorar';

  @override
  String get sharedAddedToFavorites => 'Agregado a favoritos';

  @override
  String get sharedRemovedFromFavorites => 'Eliminado de favoritos';

  @override
  String sharedDownloaded(String name) {
    return 'Descargado: $name';
  }

  @override
  String sharedDownloadedType(String type, String name) {
    return 'Descargado $type: $name';
  }

  @override
  String get sharedDownloadFailed => 'Descarga fallida';

  @override
  String get sharedAddToFavorites => 'AGREGAR A FAVORITOS';

  @override
  String get sharedRemoveFromFavorites => 'QUITAR DE FAVORITOS';

  @override
  String get sharedDownload => 'DESCARGAR';

  @override
  String get sharedReadMore => 'LEER MÁS';

  @override
  String get sharedShowLess => 'MOSTRAR MENOS';

  @override
  String get vipTitle => 'VIP MODS';

  @override
  String get vipEmpty => 'AÚN NO HAY VIP MODS';

  @override
  String get vipEmptyHint => 'Vuelve más tarde para ver contenido exclusivo.';

  @override
  String get vipFailedToLoad => 'ERROR AL CARGAR VIP MODS';

  @override
  String get dynosTitle => 'DYNOS';

  @override
  String get dynosEmpty => 'AÚN NO HAY DYNOS';

  @override
  String get dynosEmptyHint =>
      'Vuelve más tarde para ver parches en tiempo de ejecución.';

  @override
  String get dynosFailedToLoad => 'ERROR AL CARGAR DYNOS';

  @override
  String get touchTitle => 'CONTROLES TÁCTILES';

  @override
  String touchModCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count DISEÑOS',
      one: '$count DISEÑO',
    );
    return '$_temp0';
  }

  @override
  String get touchEmpty => 'AÚN NO HAY DISEÑOS TÁCTILES';

  @override
  String get touchEmptyHint =>
      'Vuelve más tarde para ver diseños de controles móviles.';

  @override
  String get touchFailedToLoad => 'ERROR AL CARGAR CONTROLES TÁCTILES';

  @override
  String get ommTitle => 'OMM REBIRTH';

  @override
  String get ommEmpty => 'AÚN NO HAY MODS DE OMM REBIRTH';

  @override
  String get ommEmptyHint =>
      'Vuelve más tarde para ver contenido de OMM Rebirth.';

  @override
  String get ommFailedToLoad => 'ERROR AL CARGAR MODS DE OMM REBIRTH';

  @override
  String get detailDownload => 'Descargar';

  @override
  String get detailDownloadButton => 'DESCARGAR';

  @override
  String get detailModNotFound => 'Mod no encontrado';

  @override
  String get detailModNotFoundBody =>
      'Este mod pudo haber sido eliminado o el enlace no es válido.';

  @override
  String get detailGoBack => 'Volver';

  @override
  String get detailFailedToLoad => 'Error al cargar mod';

  @override
  String get detailRetry => 'Reintentar';

  @override
  String get detailNotificationsNeeded => 'Notificaciones necesarias';

  @override
  String get detailNotificationsBody =>
      'Necesitamos permiso de notificaciones para mostrar el progreso de descarga e instalación, incluso si sales de la app.';

  @override
  String get detailNotNow => 'Ahora no';

  @override
  String get detailContinue => 'Continuar';

  @override
  String get detailNotificationsSkipped =>
      'No verás el progreso fuera de la app. Concede el permiso en Ajustes para activar notificaciones.';

  @override
  String get detailModsFolderNotSelected => 'Carpeta de mods no seleccionada';

  @override
  String get detailModsFolderBody =>
      'Debes seleccionar una carpeta de mods antes de instalar mods en el juego.\n\nVe a Ajustes → Integración del Juego para seleccionarla.';

  @override
  String get detailCancel => 'Cancelar';

  @override
  String get detailGoToSettings => 'Ir a Ajustes';

  @override
  String detailDownloading(String filename) {
    return 'Descargando \"$filename\"...';
  }

  @override
  String detailSavedToModsFolder(String name) {
    return 'Guardado en carpeta de mods: $name';
  }

  @override
  String detailSavedToFolder(String type, String name) {
    return 'Guardado en carpeta $type: $name';
  }

  @override
  String get detailDownloadFailed => 'Descarga fallida';

  @override
  String detailError(String detail) {
    return 'Error: $detail';
  }

  @override
  String detailDownloaded(String name) {
    return 'Descargado: $name';
  }

  @override
  String detailDownloadedType(String type, String name) {
    return 'Descargado $type: $name';
  }

  @override
  String get detailDownloadingBanner => 'Descargando mod...';

  @override
  String detailDownloadingBannerType(String type) {
    return 'Descargando $type...';
  }

  @override
  String detailFilesProgress(int current, int total) {
    return '$current/$total archivos';
  }

  @override
  String get detailExtracting => 'Extrayendo...';

  @override
  String get detailInstallingMod => 'Instalando mod...';

  @override
  String get detailInstallComplete => 'Instalación completa';

  @override
  String detailInstallFilesExtracted(int count, String dir) {
    return '$count archivos extraídos en \"$dir\"';
  }

  @override
  String get detailInstallFailed => 'Instalación fallida';

  @override
  String get detailOperationCancelled => 'Operación cancelada';

  @override
  String detailDownloadingPct(String pct) {
    return 'Descargando $pct%';
  }

  @override
  String get detailInstalling => 'Instalando...';

  @override
  String get detailScreenshots => 'Capturas';

  @override
  String get detailTags => 'Etiquetas';

  @override
  String get detailAbout => 'Acerca de';

  @override
  String get detailRating => 'Calificación';

  @override
  String get detailDownloads => 'Descargas';

  @override
  String get detailViews => 'Vistas';

  @override
  String get detailReviews => 'Reseñas';

  @override
  String detailDownloadFiles(int count) {
    return 'Descargar archivos ($count)';
  }

  @override
  String detailVersions(int count) {
    return 'Versiones ($count)';
  }

  @override
  String get detailVersionFallback => 'v?';

  @override
  String get detailFirstRelease => 'Primer Lanzamiento';

  @override
  String get detailLastUpdate => 'Última Actualización';

  @override
  String get detailChangelog => 'Registro de Cambios';

  @override
  String get detailCollapseChangelog => 'Colapsar registro';

  @override
  String detailViewAllUpdates(int count) {
    return 'Ver todas las $count actualizaciones';
  }

  @override
  String get detailShowLess => 'Mostrar menos';

  @override
  String get detailShowMore => 'Mostrar más';

  @override
  String get detailNotificationsDisabled =>
      'Notificaciones no activadas. No verás el progreso de descarga fuera de la app.';

  @override
  String get settingsTitle => 'AJUSTES';

  @override
  String get settingsData => 'DATOS';

  @override
  String get settingsClearFavourites => 'Limpiar favoritos';

  @override
  String get settingsClearFavouritesDesc => 'Eliminar todos los mods guardados';

  @override
  String get settingsExportFavourites => 'Exportar favoritos';

  @override
  String get settingsExportFavouritesDesc => 'Comparte tus mods guardados';

  @override
  String get settingsImportFavourites => 'Importar favoritos';

  @override
  String get settingsImportFavouritesDesc =>
      'Restaurar desde un archivo exportado previamente';

  @override
  String get settingsGameIntegration => 'INTEGRACIÓN DEL JUEGO';

  @override
  String get settingsAppearance => 'APARIENCIA';

  @override
  String get settingsAbout => 'ACERCA DE';

  @override
  String get settingsGoToReleases => 'Ir a versiones';

  @override
  String settingsViewAllVersions(String version) {
    return 'Ver todas las versiones en GitHub · v$version';
  }

  @override
  String get settingsDataSource => 'Fuente de datos';

  @override
  String get settingsNoFavouritesToExport =>
      'No tienes favoritos para exportar.';

  @override
  String settingsImportAdded(int count) {
    return '$count agregados';
  }

  @override
  String settingsImportAlreadySaved(int count) {
    return '$count ya guardados';
  }

  @override
  String settingsImportNotFound(int count) {
    return '$count no encontrados en el catálogo';
  }

  @override
  String get settingsImportNothingNew => 'Nada nuevo para importar.';

  @override
  String get settingsImportComplete => 'Importación completa';

  @override
  String get settingsClearFavouritesTitle => '¿LIMPIAR FAVORITOS?';

  @override
  String get settingsClearFavouritesBody =>
      'Esto eliminará todos tus mods guardados. Esta acción no se puede deshacer.';

  @override
  String get settingsClearButton => 'LIMPIAR';

  @override
  String get settingsFavouritesCleared => 'Favoritos eliminados';

  @override
  String settingsCannotOpenUrl(String url) {
    return 'No se puede abrir URL: $url';
  }

  @override
  String get settingsCancel => 'CANCELAR';

  @override
  String get settingsModsFolderSelected =>
      'Carpeta de mods seleccionada. Los mods se instalarán aquí.';

  @override
  String get settingsClearModsFolderTitle => '¿LIMPIAR CARPETA DE MODS?';

  @override
  String get settingsClearModsFolderBody =>
      'Deberás seleccionar la carpeta de nuevo antes de instalar mods en el juego.';

  @override
  String get settingsModsFolderCleared =>
      'Selección de carpeta de mods eliminada.';

  @override
  String get settingsModsFolder => 'Carpeta de mods';

  @override
  String get settingsSelectModsFolder => 'Seleccionar carpeta de mods';

  @override
  String get settingsModsFolderHint =>
      'Toca para cambiar · Mantén para limpiar';

  @override
  String get settingsModsFolderDesc =>
      'Elige dónde instalar los mods descargados';

  @override
  String get settingsAutoInstall => 'Auto-instalar después de descargar';

  @override
  String get settingsAutoInstallOn =>
      'Los mods se instalarán automáticamente en la carpeta del juego';

  @override
  String get settingsAutoInstallOff =>
      'Se te preguntará después de cada descarga';

  @override
  String get settingsThemeMode => 'MODO TEMA';

  @override
  String settingsDatabaseUpdated(int count, String date) {
    return 'Base de datos actualizada · $count mods$date';
  }

  @override
  String get settingsUnknownError => 'Error desconocido';

  @override
  String get settingsReloadDatabase => 'Recargar base de datos';

  @override
  String get settingsDownloading => 'Descargando...';

  @override
  String get settingsDownloadLatest => 'Descargar lista de mods más reciente';

  @override
  String settingsUpToDate(String version) {
    return 'Estás al día · v$version';
  }

  @override
  String get settingsCheckForUpdates => 'Buscar actualizaciones';

  @override
  String get settingsChecking => 'Verificando...';

  @override
  String get changelogTitle => 'Registro de Cambios';

  @override
  String get changelogNew => 'Nuevo';

  @override
  String get changelogImproved => 'Mejorado';

  @override
  String get changelogFixed => 'Corregido';

  @override
  String get changelogRemoved => 'Eliminado';

  @override
  String get changelogChanged => 'Cambiado';

  @override
  String get changelogLatest => 'Más Reciente';

  @override
  String get generalSettings => 'Ajustes';

  @override
  String get generalRetry => 'Reintentar';

  @override
  String get linksTitle => 'ENLACES ';

  @override
  String get linksSubtitle => 'Y RECURSOS';

  @override
  String get linksOfficiaSection => 'OFICIAL';

  @override
  String get linksOfficialDesc =>
      'Canales verificados del proyecto SM64CoopDX.';

  @override
  String get linksSm64cdpySection => 'SM64CDPY';

  @override
  String get linksSm64cdpyDesc => 'Descargas y contenido de esta app.';

  @override
  String get linksResourcesSection => 'RECURSOS';

  @override
  String get linksResourcesDesc =>
      'Comunidad, guías e instalación paso a paso.';

  @override
  String get linksHeroTitle => 'CENTRO DE ENLACES';

  @override
  String get linksHeroDesc =>
      'Todo lo oficial, la comunidad y los recursos del proyecto, en un solo lugar.';

  @override
  String get linksChipTap => 'TOCA = ABRIR';

  @override
  String get linksChipHold => 'MANTÉN = COPIAR';

  @override
  String get linksWebsite => 'Sitio Web SM64CoopDX';

  @override
  String get linksWebsiteUrl => 'sm64coopdx.com';

  @override
  String get linksKindWeb => 'WEB';

  @override
  String get linksDiscordServer => 'Servidor Discord';

  @override
  String get linksDiscordOfficial =>
      'Servidor oficial de la comunidad · Android';

  @override
  String get linksKindDiscord => 'DISCORD';

  @override
  String get linksGithubRepo => 'Repositorio GitHub';

  @override
  String get linksGithubDesc => 'Código fuente y reportes';

  @override
  String get linksKindGithub => 'GITHUB';

  @override
  String get linksGithubReleases => 'Versiones en GitHub';

  @override
  String get linksGithubReleasesDesc => 'Descargar último APK';

  @override
  String get linksKindDownload => 'DESCARGAR';

  @override
  String get linksYoutubeChannel => 'Canal de YouTube';

  @override
  String get linksYoutubeHandle => '@retired64';

  @override
  String get linksKindYoutube => 'YOUTUBE';

  @override
  String get linksDiscordCommunity => 'Servidor de comunidad y soporte';

  @override
  String get linksWiki => 'Wiki y Guías';

  @override
  String get linksWikiDesc => 'Guías de instalación y docs';

  @override
  String get linksKindWiki => 'WIKI';

  @override
  String get linksTools => 'Herramientas y Complementos';

  @override
  String get linksToolsDesc => 'Cómo crear mods y recursos';

  @override
  String get linksKindTools => 'HERRAMIENTAS';

  @override
  String get linksCouldNotOpen => 'No se pudo abrir el enlace';

  @override
  String get linksCopied => 'Enlace copiado';

  @override
  String get disclaimerTitle => 'Aviso Legal';

  @override
  String get disclaimerDeveloperContact => 'Contacto del desarrollador';

  @override
  String get disclaimerDiscordReach => 'Escríbeme en mi servidor de Discord';

  @override
  String get disclaimerDiscord => 'Discord';

  @override
  String disclaimerFooter(String version) {
    return 'v$version · para uso personal · No oficial';
  }

  @override
  String get disclaimerUnofficialBanner => 'App No Oficial';

  @override
  String get disclaimerAppSubtitle => 'SM64CoopDX Mods Manager';

  @override
  String get disclaimerWarningBody =>
      'Esta app es un proyecto personal. Cualquier problema relacionado con ella (Funcionalidad, errores, etc.) es responsabilidad exclusiva del desarrollador. Los desarrolladores de SM64CoopDX y los creadores de mods no tienen ninguna responsabilidad sobre esta aplicación.';

  @override
  String get disclaimerCouldNotOpenLink => 'No se pudo abrir el enlace';

  @override
  String get disclaimerSectionPersonalPurpose => 'Propósito personal';

  @override
  String get disclaimerBodyPersonalPurpose =>
      'Esta aplicación fue desarrollada de forma independiente como un proyecto personal. Su único objetivo es facilitarme el acceso, organización y descarga de mods que uso para mi propio entretenimiento. No es una aplicación respaldada por el equipo de SM64CoopDX ni un servicio oficial de ningún tipo.';

  @override
  String get disclaimerSectionNoAffiliation => 'Sin afiliación oficial';

  @override
  String get disclaimerBodyNoAffiliation =>
      'Este proyecto no está asociado, respaldado ni aprobado por los desarrolladores de SM64CoopDX, Super Mario 64, Nintendo, ni por ninguno de los creadores de los mods listados. Los nombres, imágenes y contenido mostrados pertenecen a sus respectivos autores.';

  @override
  String get disclaimerSectionDataSource => 'Fuente de datos';

  @override
  String get disclaimerBodyDataSource =>
      'La información de los mods proviene del catálogo público de mods.sm64coopdx.com. Esta app únicamente presenta esa información de manera más accesible; no aloja, modifica ni redistribuye ningún archivo de mod.';

  @override
  String get disclaimerSectionExclusive =>
      'Secciones exclusivas (VIP · DynOS · Touch Controls)';

  @override
  String disclaimerBodyExclusive(Object version) {
    return 'A partir de la v$version, la app incluye secciones curadas con contenido que no está listado oficialmente en el sitio de SM64CoopDX. Estas secciones (VIP Mods, packs de DynOS y layouts de Touch Controls) son mantenidas de forma independiente por el desarrollador y no tienen ninguna afiliación con ninguna fuente oficial. Todo el crédito pertenece a los creadores originales.';
  }

  @override
  String get disclaimerSectionBugs => 'Errores, sugerencias o solicitudes';

  @override
  String get disclaimerBodyBugs =>
      'Si encuentras algún problema con esta app, tienes una sugerencia o quieres pedir algo, contáctame directamente a través de mis redes sociales. Por favor, no contactes a los desarrolladores oficiales de SM64CoopDX ni a los creadores de mods por asuntos relacionados con esta aplicación.';

  @override
  String get vipSectionHeader => 'CONTENIDO EXCLUSIVO';

  @override
  String get dynosSectionHeader => 'DYNOS PERSONALIZADOS';

  @override
  String get touchSectionHeader => 'LAYOUTS MÓVILES';

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
  String get settingsDynosFolder => 'Carpeta DynOS';

  @override
  String get settingsSelectDynosFolder => 'Seleccionar carpeta DynOS';

  @override
  String get settingsDynosFolderHint =>
      'Toca para cambiar · Mantén para limpiar';

  @override
  String get settingsDynosFolderDesc =>
      'Elige dónde instalar los packs de DynOS y Touch Controls';

  @override
  String get settingsDynosFolderSelected =>
      'Carpeta DynOS seleccionada. Los packs se instalarán aquí.';

  @override
  String get settingsClearDynosFolderTitle => '¿LIMPIAR CARPETA DYNOS?';

  @override
  String get settingsClearDynosFolderBody =>
      'Deberás seleccionar la carpeta de nuevo antes de instalar packs de DynOS o Touch Controls.';

  @override
  String get settingsDynosFolderCleared =>
      'Selección de carpeta DynOS eliminada.';

  @override
  String get settingsLanguageMode => 'IDIOMA';

  @override
  String get languageFollowSystem => 'Seguir sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get overlaySearchHint => 'BUSCAR...';

  @override
  String get overlayNoResponse =>
      'Sin respuesta — abre la app principal una vez y vuelve a intentarlo';

  @override
  String get overlaySelectFolder => 'Selecciona una carpeta primero (Ajustes)';

  @override
  String get overlayEnableAutoInstall =>
      'Activa auto-instalación primero (Ajustes)';

  @override
  String get overlayDownloadFailed => 'Descarga fallida';

  @override
  String get overlayTapToCancel => 'TOCA PARA CANCELAR';

  @override
  String get overlayInstalling => 'Instalando...';

  @override
  String get overlayConnecting => 'Conectando...';

  @override
  String get overlayNoResults => 'SIN RESULTADOS';

  @override
  String get overlayError => 'ERROR';
}

/// The translations for Spanish Castilian, as used in Latin America and the Caribbean (`es_419`).
class AppLocalizationsEs419 extends AppLocalizationsEs {
  AppLocalizationsEs419() : super('es_419');

  @override
  String get hello => 'Hola';

  @override
  String get navHome => 'Inicio';

  @override
  String get navCatalog => 'Catálogo';

  @override
  String get navFavourites => 'Favoritos';

  @override
  String get navPopular => 'Popular';

  @override
  String get navVIPMods => 'VIP Mods';

  @override
  String get navDynOS => 'DynOS';

  @override
  String get navTouchControls => 'Controles Táctiles';

  @override
  String get navOmmRebirth => 'OMMR PACK';

  @override
  String get navLinksResource => 'Enlaces y Recursos';

  @override
  String get navDisclaimer => 'Aviso Legal';

  @override
  String get navChangelog => 'Registro de Cambios';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get sectionExclusive => 'EXCLUSIVO';

  @override
  String get sectionExplore => 'EXPLORAR';

  @override
  String get sectionCategories => 'CATEGORÍAS';

  @override
  String get sectionSortBy => 'ORDENAR POR';

  @override
  String get sectionSocialLinks => 'ENLACES SOCIALES';

  @override
  String get sortDefault => 'Predeterminado';

  @override
  String get sortRating => 'Calificación';

  @override
  String get sortDownloads => 'Descargas';

  @override
  String get sortNewest => 'Más Reciente';

  @override
  String get socialYouTube => 'YouTube';

  @override
  String get socialDiscord => 'Discord';

  @override
  String get socialGitHub => 'GitHub';

  @override
  String get categoryCharacters => 'Personajes';

  @override
  String get categoryGameModes => 'Modos de Juego';

  @override
  String get categoryROMHacks => 'ROM Hacks y Niveles';

  @override
  String get categoryGameplay => 'Jugabilidad y Mecánicas';

  @override
  String get categoryVisual => 'Visual y Modelos';

  @override
  String get categoryAudio => 'Audio y Voz';

  @override
  String get categoryUtilities => 'Utilidades y Herramientas';

  @override
  String get categoryMisc => 'Misceláneos y Diversión';

  @override
  String get badgeFeatured => 'DESTACADO';

  @override
  String get updateRequired => 'ACTUALIZACIÓN REQUERIDA';

  @override
  String get updateAvailable => 'NUEVA VERSIÓN DISPONIBLE';

  @override
  String updateVersion(String version) {
    return 'Versión $version';
  }

  @override
  String updateSize(String size) {
    return 'Tamaño: $size MB';
  }

  @override
  String get updateWhatIsNew => 'Novedades:';

  @override
  String get updateGenericDescription =>
      'Mejoras menores y corrección de errores.';

  @override
  String updateDownloading(String pct) {
    return 'Descargando... $pct%';
  }

  @override
  String get updateAlreadyDownloading =>
      'Ya hay una descarga en curso. Espere o reinicie la app.';

  @override
  String get updatePermissionDenied =>
      'Permiso de instalación denegado.\nVaya a Ajustes → Apps → esta app → Instalar apps desconocidas.';

  @override
  String updateInternalError(String detail) {
    return 'Error interno: $detail';
  }

  @override
  String get updateDownloadError => 'Error de descarga. Verifique su conexión.';

  @override
  String get updateChecksumError =>
      'El archivo descargado está dañado. Intente de nuevo.';

  @override
  String updateInstallError(String detail) {
    return 'Error de instalación: $detail';
  }

  @override
  String updateUnexpectedError(String detail) {
    return 'Error inesperado: $detail';
  }

  @override
  String updateCantStart(String detail) {
    return 'No se pudo iniciar la actualización: $detail';
  }

  @override
  String get updateButtonOpenBrowser => 'ABRIR EN NAVEGADOR';

  @override
  String get updateButtonLater => 'DESPUÉS';

  @override
  String get updateButtonExit => 'SALIR';

  @override
  String get updateButtonUpdateNow => 'ACTUALIZAR AHORA';

  @override
  String get updateButtonGoToDownloads => 'IR A DESCARGAS';

  @override
  String get postInstallTitle => 'Mod instalado';

  @override
  String get postInstallGameRunning =>
      'Si el juego ya estaba abierto, ciérrelo por completo (no solo minimizar) y vuelva a abrirlo para que los nuevos archivos se carguen correctamente.';

  @override
  String get postInstallNoRoot =>
      'No necesita forzar cierre ni root. Solo cierre el juego normalmente y vuelva a abrirlo.';

  @override
  String get postInstallFilesCopied =>
      'Los archivos se copiaron a la carpeta de mods.';

  @override
  String get postInstallClose => 'Cerrar';

  @override
  String get postInstallLaunchGame => 'ABRIR JUEGO';

  @override
  String get homeExclusiveContent => 'Contenido Exclusivo';

  @override
  String get homeTopDownloads => 'Más Descargados';

  @override
  String get homeSeeAll => 'Ver todo';

  @override
  String get homeFeatured => 'Destacados';

  @override
  String get homeCatalog => 'Catálogo';

  @override
  String get homeCatalogDesc =>
      'Explora, busca y filtra toda la colección de mods';

  @override
  String get homeFavorites => 'Favoritos';

  @override
  String get homeFavoritesDesc => 'Tus mods guardados de todas las secciones';

  @override
  String get homePopular => 'Popular';

  @override
  String get homePopularDesc => 'Mejores mods por total de descargas';

  @override
  String get homeBrowse => 'Explorar';

  @override
  String get homeGoTo => 'IR A';

  @override
  String get homeVipMods => 'VIP Mods';

  @override
  String get homeVipModsDesc => 'Packs exclusivos de personajes y modelos';

  @override
  String get homeDynos => 'DynOS';

  @override
  String get homeDynosDesc =>
      'Texturas personalizadas e intercambio de modelos';

  @override
  String get homeTouchControls => 'Controles Táctiles';

  @override
  String get homeTouchControlsDesc =>
      'Diseños personalizados de botones y joysticks';

  @override
  String get homeOmmrPack => 'OMMR PACK';

  @override
  String get homeOmmrPackDesc => 'Pack de texturas completo OMM Rebirth';

  @override
  String get homeGameNotInstalled => 'Juego no instalado';

  @override
  String get homeGameNotInstalledBody =>
      'SM64CoopDX (com.maniscat2.sm64coopdx)\nno está instalado en este dispositivo.';

  @override
  String get homeClose => 'Cerrar';

  @override
  String get homeDownload => 'Descargar';

  @override
  String get homeLaunchGame => 'ABRIR JUEGO';

  @override
  String get homeSoon => 'PRONTO';

  @override
  String get homeFailedToLoad => 'Error al cargar mods';

  @override
  String get homeRetry => 'Reintentar';

  @override
  String get catalogueTitle => 'EXPLORAR MODS';

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
      other: '$count RESULTADOS',
      one: '$count RESULTADO',
    );
    return '$_temp0';
  }

  @override
  String get catalogueSearchHint => 'BUSCAR MODS, AUTORES, ETIQUETAS…';

  @override
  String get catalogueSortDefault => 'Predeterminado';

  @override
  String get catalogueSortTopRated => 'Mejor Calificados';

  @override
  String get catalogueSortMostDownloaded => 'Más Descargados';

  @override
  String get catalogueSortRecentlyUpdated => 'Actualizados Recientemente';

  @override
  String get catalogueClearAll => 'LIMPIAR TODO';

  @override
  String cataloguePaginationRange(int start, int end, int total) {
    return '$start–$end DE $total MODS';
  }

  @override
  String get catalogueNoModsFound => 'NO SE ENCONTRARON MODS';

  @override
  String get catalogueNothingHere => 'NADA AQUÍ AÚN';

  @override
  String get catalogueEmptyHint1 =>
      'Prueba otras palabras o quita los filtros.';

  @override
  String get catalogueEmptyHint2 =>
      'Vuelve más tarde para ver nuevo contenido.';

  @override
  String get catalogueClearFilters => 'LIMPIAR FILTROS';

  @override
  String get catalogueFailedToLoad => 'ERROR AL CARGAR MODS';

  @override
  String get catalogueRating => 'CALIFICACIÓN';

  @override
  String get catalogueDownloads => 'DESCARGAS';

  @override
  String get catalogueNewest => 'MÁS RECIENTE';

  @override
  String get catalogueSort => 'ORDENAR';

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
  String get popularMoreRankings => 'MÁS RANKINGS';

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
  String get popularFailedToLoad => 'ERROR AL CARGAR';

  @override
  String get favouritesTitle => 'Favoritos';

  @override
  String get favTabMods => 'Mods';

  @override
  String get favTabVip => 'VIP';

  @override
  String get favTabDynos => 'DynOS';

  @override
  String get favTabTouch => 'Táctil';

  @override
  String get favEmptyMods => 'Aún no hay mods en favoritos';

  @override
  String get favEmptyVip => 'Aún no hay VIP mods en favoritos';

  @override
  String get favEmptyDynos => 'Aún no hay DynOS en favoritos';

  @override
  String get favEmptyTouch => 'Aún no hay Controles Táctiles en favoritos';

  @override
  String favEmptyHint(String type) {
    return 'Toca ♥ en cualquier $type para guardarlo aquí.';
  }

  @override
  String get favBrowse => 'Explorar';

  @override
  String get sharedAddedToFavorites => 'Agregado a favoritos';

  @override
  String get sharedRemovedFromFavorites => 'Eliminado de favoritos';

  @override
  String sharedDownloaded(String name) {
    return 'Descargado: $name';
  }

  @override
  String sharedDownloadedType(String type, String name) {
    return 'Descargado $type: $name';
  }

  @override
  String get sharedDownloadFailed => 'Descarga fallida';

  @override
  String get sharedAddToFavorites => 'AGREGAR A FAVORITOS';

  @override
  String get sharedRemoveFromFavorites => 'QUITAR DE FAVORITOS';

  @override
  String get sharedDownload => 'DESCARGAR';

  @override
  String get sharedReadMore => 'LEER MÁS';

  @override
  String get sharedShowLess => 'MOSTRAR MENOS';

  @override
  String get vipTitle => 'VIP MODS';

  @override
  String get vipEmpty => 'AÚN NO HAY VIP MODS';

  @override
  String get vipEmptyHint => 'Vuelve más tarde para ver contenido exclusivo.';

  @override
  String get vipFailedToLoad => 'ERROR AL CARGAR VIP MODS';

  @override
  String get dynosTitle => 'DYNOS';

  @override
  String get dynosEmpty => 'AÚN NO HAY DYNOS';

  @override
  String get dynosEmptyHint =>
      'Vuelve más tarde para ver parches en tiempo de ejecución.';

  @override
  String get dynosFailedToLoad => 'ERROR AL CARGAR DYNOS';

  @override
  String get touchTitle => 'CONTROLES TÁCTILES';

  @override
  String touchModCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count DISEÑOS',
      one: '$count DISEÑO',
    );
    return '$_temp0';
  }

  @override
  String get touchEmpty => 'AÚN NO HAY DISEÑOS TÁCTILES';

  @override
  String get touchEmptyHint =>
      'Vuelve más tarde para ver diseños de controles móviles.';

  @override
  String get touchFailedToLoad => 'ERROR AL CARGAR CONTROLES TÁCTILES';

  @override
  String get ommTitle => 'OMM REBIRTH';

  @override
  String get ommEmpty => 'AÚN NO HAY MODS DE OMM REBIRTH';

  @override
  String get ommEmptyHint =>
      'Vuelve más tarde para ver contenido de OMM Rebirth.';

  @override
  String get ommFailedToLoad => 'ERROR AL CARGAR MODS DE OMM REBIRTH';

  @override
  String get detailDownload => 'Descargar';

  @override
  String get detailDownloadButton => 'DESCARGAR';

  @override
  String get detailModNotFound => 'Mod no encontrado';

  @override
  String get detailModNotFoundBody =>
      'Este mod pudo haber sido eliminado o el enlace no es válido.';

  @override
  String get detailGoBack => 'Volver';

  @override
  String get detailFailedToLoad => 'Error al cargar mod';

  @override
  String get detailRetry => 'Reintentar';

  @override
  String get detailNotificationsNeeded => 'Notificaciones necesarias';

  @override
  String get detailNotificationsBody =>
      'Necesitamos permiso de notificaciones para mostrar el progreso de descarga e instalación, incluso si sales de la app.';

  @override
  String get detailNotNow => 'Ahora no';

  @override
  String get detailContinue => 'Continuar';

  @override
  String get detailNotificationsSkipped =>
      'No verás el progreso fuera de la app. Concede el permiso en Ajustes para activar notificaciones.';

  @override
  String get detailModsFolderNotSelected => 'Carpeta de mods no seleccionada';

  @override
  String get detailModsFolderBody =>
      'Debes seleccionar una carpeta de mods antes de instalar mods en el juego.\n\nVe a Ajustes → Integración del Juego para seleccionarla.';

  @override
  String get detailCancel => 'Cancelar';

  @override
  String get detailGoToSettings => 'Ir a Ajustes';

  @override
  String detailDownloading(String filename) {
    return 'Descargando \"$filename\"...';
  }

  @override
  String detailSavedToModsFolder(String name) {
    return 'Guardado en carpeta de mods: $name';
  }

  @override
  String detailSavedToFolder(String type, String name) {
    return 'Guardado en carpeta $type: $name';
  }

  @override
  String get detailDownloadFailed => 'Descarga fallida';

  @override
  String detailError(String detail) {
    return 'Error: $detail';
  }

  @override
  String detailDownloaded(String name) {
    return 'Descargado: $name';
  }

  @override
  String detailDownloadedType(String type, String name) {
    return 'Descargado $type: $name';
  }

  @override
  String get detailDownloadingBanner => 'Descargando mod...';

  @override
  String detailDownloadingBannerType(String type) {
    return 'Descargando $type...';
  }

  @override
  String detailFilesProgress(int current, int total) {
    return '$current/$total archivos';
  }

  @override
  String get detailExtracting => 'Extrayendo...';

  @override
  String get detailInstallingMod => 'Instalando mod...';

  @override
  String get detailInstallComplete => 'Instalación completa';

  @override
  String detailInstallFilesExtracted(int count, String dir) {
    return '$count archivos extraídos en \"$dir\"';
  }

  @override
  String get detailInstallFailed => 'Instalación fallida';

  @override
  String get detailOperationCancelled => 'Operación cancelada';

  @override
  String detailDownloadingPct(String pct) {
    return 'Descargando $pct%';
  }

  @override
  String get detailInstalling => 'Instalando...';

  @override
  String get detailScreenshots => 'Capturas';

  @override
  String get detailTags => 'Etiquetas';

  @override
  String get detailAbout => 'Acerca de';

  @override
  String get detailRating => 'Calificación';

  @override
  String get detailDownloads => 'Descargas';

  @override
  String get detailViews => 'Vistas';

  @override
  String get detailReviews => 'Reseñas';

  @override
  String detailDownloadFiles(int count) {
    return 'Descargar archivos ($count)';
  }

  @override
  String detailVersions(int count) {
    return 'Versiones ($count)';
  }

  @override
  String get detailVersionFallback => 'v?';

  @override
  String get detailFirstRelease => 'Primer Lanzamiento';

  @override
  String get detailLastUpdate => 'Última Actualización';

  @override
  String get detailChangelog => 'Registro de Cambios';

  @override
  String get detailCollapseChangelog => 'Colapsar registro';

  @override
  String detailViewAllUpdates(int count) {
    return 'Ver todas las $count actualizaciones';
  }

  @override
  String get detailShowLess => 'Mostrar menos';

  @override
  String get detailShowMore => 'Mostrar más';

  @override
  String get detailNotificationsDisabled =>
      'Notificaciones no activadas. No verás el progreso de descarga fuera de la app.';

  @override
  String get settingsTitle => 'AJUSTES';

  @override
  String get settingsData => 'DATOS';

  @override
  String get settingsClearFavourites => 'Limpiar favoritos';

  @override
  String get settingsClearFavouritesDesc => 'Eliminar todos los mods guardados';

  @override
  String get settingsExportFavourites => 'Exportar favoritos';

  @override
  String get settingsExportFavouritesDesc => 'Comparte tus mods guardados';

  @override
  String get settingsImportFavourites => 'Importar favoritos';

  @override
  String get settingsImportFavouritesDesc =>
      'Restaurar desde un archivo exportado previamente';

  @override
  String get settingsGameIntegration => 'INTEGRACIÓN DEL JUEGO';

  @override
  String get settingsAppearance => 'APARIENCIA';

  @override
  String get settingsAbout => 'ACERCA DE';

  @override
  String get settingsGoToReleases => 'Ir a versiones';

  @override
  String settingsViewAllVersions(String version) {
    return 'Ver todas las versiones en GitHub · v$version';
  }

  @override
  String get settingsDataSource => 'Fuente de datos';

  @override
  String get settingsNoFavouritesToExport =>
      'No tienes favoritos para exportar.';

  @override
  String settingsImportAdded(int count) {
    return '$count agregados';
  }

  @override
  String settingsImportAlreadySaved(int count) {
    return '$count ya guardados';
  }

  @override
  String settingsImportNotFound(int count) {
    return '$count no encontrados en el catálogo';
  }

  @override
  String get settingsImportNothingNew => 'Nada nuevo para importar.';

  @override
  String get settingsImportComplete => 'Importación completa';

  @override
  String get settingsClearFavouritesTitle => '¿LIMPIAR FAVORITOS?';

  @override
  String get settingsClearFavouritesBody =>
      'Esto eliminará todos tus mods guardados. Esta acción no se puede deshacer.';

  @override
  String get settingsClearButton => 'LIMPIAR';

  @override
  String get settingsFavouritesCleared => 'Favoritos eliminados';

  @override
  String settingsCannotOpenUrl(String url) {
    return 'No se puede abrir URL: $url';
  }

  @override
  String get settingsCancel => 'CANCELAR';

  @override
  String get settingsModsFolderSelected =>
      'Carpeta de mods seleccionada. Los mods se instalarán aquí.';

  @override
  String get settingsClearModsFolderTitle => '¿LIMPIAR CARPETA DE MODS?';

  @override
  String get settingsClearModsFolderBody =>
      'Deberás seleccionar la carpeta de nuevo antes de instalar mods en el juego.';

  @override
  String get settingsModsFolderCleared =>
      'Selección de carpeta de mods eliminada.';

  @override
  String get settingsModsFolder => 'Carpeta de mods';

  @override
  String get settingsSelectModsFolder => 'Seleccionar carpeta de mods';

  @override
  String get settingsModsFolderHint =>
      'Toca para cambiar · Mantén para limpiar';

  @override
  String get settingsModsFolderDesc =>
      'Elige dónde instalar los mods descargados';

  @override
  String get settingsAutoInstall => 'Auto-instalar después de descargar';

  @override
  String get settingsAutoInstallOn =>
      'Los mods se instalarán automáticamente en la carpeta del juego';

  @override
  String get settingsAutoInstallOff =>
      'Se te preguntará después de cada descarga';

  @override
  String get settingsThemeMode => 'MODO TEMA';

  @override
  String settingsDatabaseUpdated(int count, String date) {
    return 'Base de datos actualizada · $count mods$date';
  }

  @override
  String get settingsUnknownError => 'Error desconocido';

  @override
  String get settingsReloadDatabase => 'Recargar base de datos';

  @override
  String get settingsDownloading => 'Descargando...';

  @override
  String get settingsDownloadLatest => 'Descargar lista de mods más reciente';

  @override
  String settingsUpToDate(String version) {
    return 'Estás al día · v$version';
  }

  @override
  String get settingsCheckForUpdates => 'Buscar actualizaciones';

  @override
  String get settingsChecking => 'Verificando...';

  @override
  String get changelogTitle => 'Registro de Cambios';

  @override
  String get changelogNew => 'Nuevo';

  @override
  String get changelogImproved => 'Mejorado';

  @override
  String get changelogFixed => 'Corregido';

  @override
  String get changelogRemoved => 'Eliminado';

  @override
  String get changelogChanged => 'Cambiado';

  @override
  String get changelogLatest => 'Más Reciente';

  @override
  String get generalSettings => 'Ajustes';

  @override
  String get generalRetry => 'Reintentar';

  @override
  String get linksTitle => 'ENLACES ';

  @override
  String get linksSubtitle => 'Y RECURSOS';

  @override
  String get linksOfficiaSection => 'OFICIAL';

  @override
  String get linksOfficialDesc =>
      'Canales verificados del proyecto SM64CoopDX.';

  @override
  String get linksSm64cdpySection => 'SM64CDPY';

  @override
  String get linksSm64cdpyDesc => 'Descargas y contenido de esta app.';

  @override
  String get linksResourcesSection => 'RECURSOS';

  @override
  String get linksResourcesDesc =>
      'Comunidad, guías e instalación paso a paso.';

  @override
  String get linksHeroTitle => 'CENTRO DE ENLACES';

  @override
  String get linksHeroDesc =>
      'Todo lo oficial, la comunidad y los recursos del proyecto, en un solo lugar.';

  @override
  String get linksChipTap => 'TOCA = ABRIR';

  @override
  String get linksChipHold => 'MANTÉN = COPIAR';

  @override
  String get linksWebsite => 'Sitio Web SM64CoopDX';

  @override
  String get linksWebsiteUrl => 'sm64coopdx.com';

  @override
  String get linksKindWeb => 'WEB';

  @override
  String get linksDiscordServer => 'Servidor Discord';

  @override
  String get linksDiscordOfficial =>
      'Servidor oficial de la comunidad · Android';

  @override
  String get linksKindDiscord => 'DISCORD';

  @override
  String get linksGithubRepo => 'Repositorio GitHub';

  @override
  String get linksGithubDesc => 'Código fuente y reportes';

  @override
  String get linksKindGithub => 'GITHUB';

  @override
  String get linksGithubReleases => 'Versiones en GitHub';

  @override
  String get linksGithubReleasesDesc => 'Descargar último APK';

  @override
  String get linksKindDownload => 'DESCARGAR';

  @override
  String get linksYoutubeChannel => 'Canal de YouTube';

  @override
  String get linksYoutubeHandle => '@retired64';

  @override
  String get linksKindYoutube => 'YOUTUBE';

  @override
  String get linksDiscordCommunity => 'Servidor de comunidad y soporte';

  @override
  String get linksWiki => 'Wiki y Guías';

  @override
  String get linksWikiDesc => 'Guías de instalación y docs';

  @override
  String get linksKindWiki => 'WIKI';

  @override
  String get linksTools => 'Herramientas y Complementos';

  @override
  String get linksToolsDesc => 'Cómo crear mods y recursos';

  @override
  String get linksKindTools => 'HERRAMIENTAS';

  @override
  String get linksCouldNotOpen => 'No se pudo abrir el enlace';

  @override
  String get linksCopied => 'Enlace copiado';

  @override
  String get disclaimerTitle => 'Aviso Legal';

  @override
  String get disclaimerDeveloperContact => 'Contacto del desarrollador';

  @override
  String get disclaimerDiscordReach => 'Escríbeme en mi servidor de Discord';

  @override
  String get disclaimerDiscord => 'Discord';

  @override
  String disclaimerFooter(String version) {
    return 'v$version · para uso personal · No oficial';
  }

  @override
  String get disclaimerUnofficialBanner => 'App No Oficial';

  @override
  String get disclaimerAppSubtitle => 'SM64CoopDX Mods Manager';

  @override
  String get disclaimerWarningBody =>
      'Esta app es un proyecto personal. Cualquier problema relacionado con ella (Funcionalidad, errores, etc.) es responsabilidad exclusiva del desarrollador. Los desarrolladores de SM64CoopDX y los creadores de mods no tienen ninguna responsabilidad sobre esta aplicación.';

  @override
  String get disclaimerCouldNotOpenLink => 'No se pudo abrir el enlace';

  @override
  String get disclaimerSectionPersonalPurpose => 'Propósito personal';

  @override
  String get disclaimerBodyPersonalPurpose =>
      'Esta aplicación fue desarrollada de forma independiente como un proyecto personal. Su único objetivo es facilitarme el acceso, organización y descarga de mods que uso para mi propio entretenimiento. No es una aplicación respaldada por el equipo de SM64CoopDX ni un servicio oficial de ningún tipo.';

  @override
  String get disclaimerSectionNoAffiliation => 'Sin afiliación oficial';

  @override
  String get disclaimerBodyNoAffiliation =>
      'Este proyecto no está asociado, respaldado ni aprobado por los desarrolladores de SM64CoopDX, Super Mario 64, Nintendo, ni por ninguno de los creadores de los mods listados. Los nombres, imágenes y contenido mostrados pertenecen a sus respectivos autores.';

  @override
  String get disclaimerSectionDataSource => 'Fuente de datos';

  @override
  String get disclaimerBodyDataSource =>
      'La información de los mods proviene del catálogo público de mods.sm64coopdx.com. Esta app únicamente presenta esa información de manera más accesible; no aloja, modifica ni redistribuye ningún archivo de mod.';

  @override
  String get disclaimerSectionExclusive =>
      'Secciones exclusivas (VIP · DynOS · Touch Controls)';

  @override
  String disclaimerBodyExclusive(Object version) {
    return 'A partir de la v$version, la app incluye secciones curadas con contenido que no está listado oficialmente en el sitio de SM64CoopDX. Estas secciones (VIP Mods, packs de DynOS y layouts de Touch Controls) son mantenidas de forma independiente por el desarrollador y no tienen ninguna afiliación con ninguna fuente oficial. Todo el crédito pertenece a los creadores originales.';
  }

  @override
  String get disclaimerSectionBugs => 'Errores, sugerencias y solicitudes';

  @override
  String get disclaimerBodyBugs =>
      'Si encuentras algún problema con esta app, tienes una sugerencia o quieres pedir algo, contáctame directamente a través de mis redes sociales. Por favor, no contactes a los desarrolladores oficiales de SM64CoopDX ni a los creadores de mods por asuntos relacionados con esta aplicación.';

  @override
  String get vipSectionHeader => 'CONTENIDO EXCLUSIVO';

  @override
  String get dynosSectionHeader => 'DYNOS PERSONALIZADOS';

  @override
  String get touchSectionHeader => 'LAYOUTS MÓVILES';

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
  String get settingsDynosFolder => 'Carpeta DynOS';

  @override
  String get settingsSelectDynosFolder => 'Seleccionar carpeta DynOS';

  @override
  String get settingsDynosFolderHint =>
      'Toca para cambiar · Mantén para limpiar';

  @override
  String get settingsDynosFolderDesc =>
      'Elige dónde instalar los packs de DynOS y Touch Controls';

  @override
  String get settingsDynosFolderSelected =>
      'Carpeta DynOS seleccionada. Los packs se instalarán aquí.';

  @override
  String get settingsClearDynosFolderTitle => '¿LIMPIAR CARPETA DYNOS?';

  @override
  String get settingsClearDynosFolderBody =>
      'Deberás seleccionar la carpeta de nuevo antes de instalar packs de DynOS o Touch Controls.';

  @override
  String get settingsDynosFolderCleared =>
      'Selección de carpeta DynOS eliminada.';

  @override
  String get settingsLanguageMode => 'IDIOMA';

  @override
  String get languageFollowSystem => 'Seguir sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get overlaySearchHint => 'BUSCAR...';

  @override
  String get overlayNoResponse =>
      'Sin respuesta — abre la app principal una vez y vuelve a intentarlo';

  @override
  String get overlaySelectFolder => 'Selecciona una carpeta primero (Ajustes)';

  @override
  String get overlayEnableAutoInstall =>
      'Activa auto-instalación primero (Ajustes)';

  @override
  String get overlayDownloadFailed => 'Descarga fallida';

  @override
  String get overlayTapToCancel => 'TOCA PARA CANCELAR';

  @override
  String get overlayInstalling => 'Instalando...';

  @override
  String get overlayConnecting => 'Conectando...';

  @override
  String get overlayNoResults => 'SIN RESULTADOS';

  @override
  String get overlayError => 'ERROR';
}
