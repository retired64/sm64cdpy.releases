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
  String get navVIPMods => 'Mods';

  @override
  String get navDynOS => 'DynOS';

  @override
  String get navTouchControls => 'Controles Táctiles';

  @override
  String get navOmmRebirth => 'Omm Pack';

  @override
  String get navLinksResource => 'Enlaces';

  @override
  String get navDisclaimer => 'Aviso Legal';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get sectionExclusive => 'Exclusivo';

  @override
  String get sectionNavigation => 'NAVEGACIÓN';

  @override
  String get sectionExplore => 'Explorar';

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
  String get homeExclusiveContent => 'Exclusivo';

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
  String get homeLaunchGame => 'INICIAR JUEGO';

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
    return 'Pág. $page/$total';
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
  String get installationChecking => 'COMPROBANDO...';

  @override
  String get installationCancel => 'CANCELAR';

  @override
  String get installationInstalled => 'INSTALADO';

  @override
  String get installationUpdate => 'ACTUALIZAR';

  @override
  String get installationInstall => 'INSTALAR';

  @override
  String get installationReinstall => 'REINSTALAR';

  @override
  String get installationVerify => 'VERIFICAR';

  @override
  String get installationSelectFolder => 'SELECCIONAR CARPETA';

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
      'Vuelve más tarde para encontrar nuevos packs DynOS.';

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
  String get overlayCancelling => 'Cancelando...';

  @override
  String get detailDynosFolderNotSelected =>
      'Carpeta de DynOS y controles táctiles no seleccionada';

  @override
  String get detailDynosFolderBody =>
      'Selecciona la carpeta compartida de DynOS y controles táctiles en Ajustes → Integración del Juego antes de instalar este contenido.';

  @override
  String get detailInstallDownloadedTitle =>
      '¿Instalar el contenido descargado?';

  @override
  String detailInstallDownloadedBody(String name) {
    return '$name terminó de descargarse. ¿Quieres instalarlo ahora en la carpeta de DynOS y controles táctiles?';
  }

  @override
  String get detailInstallNow => 'Instalar ahora';

  @override
  String get detailKeepDownload => 'Ahora no';

  @override
  String detailDownloadedNotInstalled(String name) {
    return 'Descargado, pero no instalado: $name';
  }

  @override
  String detailInstallQueued(String name) {
    return 'Descarga e instalación en cola: $name';
  }

  @override
  String get detailContentUnavailable =>
      'Esta descarga ya no está disponible (404). Es posible que el enlace haya sido eliminado o cambiado.';

  @override
  String get detailFriendlyDownloadError =>
      'No se pudo completar la descarga. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get detailScreenshots => 'Capturas';

  @override
  String get detailYoutubeVideos => 'Videos de YouTube';

  @override
  String get detailDirectVideos => 'Videos';

  @override
  String get detailTags => 'Etiquetas';

  @override
  String get detailAbout => 'Acerca de';

  @override
  String get detailDescriptionViewOriginal => 'Ver original';

  @override
  String get detailDescriptionViewTranslation => 'Ver traducción';

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
  String get detailLatestVersion => 'ÚLTIMA VERSIÓN';

  @override
  String get detailPreviousVersions => 'Versiones anteriores';

  @override
  String detailViewPreviousVersions(int count) {
    return 'Ver $count versiones anteriores';
  }

  @override
  String get detailNoDownloadFiles =>
      'No hay archivos disponibles para descargar.';

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
      'Las descargas se instalarán automáticamente en la carpeta del juego configurada';

  @override
  String get settingsAutoInstallOff =>
      'Se te preguntará después de cada descarga';

  @override
  String get autoInstallPromptTitle =>
      '¿Instalar los mods después de descargarlos?';

  @override
  String get autoInstallPromptBody =>
      'Activa la instalación automática para colocar los mods descargados en la carpeta configurada del juego. Puedes cambiarlo después en Ajustes.';

  @override
  String get autoInstallPromptEnable => 'Activar';

  @override
  String get autoInstallPromptDownloadOnly => 'Solo descargar';

  @override
  String get settingsThemeMode => 'Modo de tema';

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
  String get linksAppWebsite => 'Sitio oficial de SM64CDPY';

  @override
  String get linksAppWebsiteDesc =>
      'Novedades, descargas e información del proyecto';

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
  String get disclaimerAppSubtitle => 'Gestor de mods de SM64CoopDX';

  @override
  String get disclaimerWarningBody =>
      'SM64CDPY es software independiente. Las preguntas, problemas técnicos y solicitudes relacionadas con esta aplicación deben dirigirse al desarrollador de SM64CDPY, no a Nintendo, al equipo de SM64CoopDX ni a los autores de los mods listados.';

  @override
  String get disclaimerCouldNotOpenLink => 'No se pudo abrir el enlace';

  @override
  String get disclaimerSectionPersonalPurpose => 'Acerca de esta aplicación';

  @override
  String get disclaimerBodyPersonalPurpose =>
      'SM64CDPY es un catálogo y gestor independiente para Android de mods de SM64CoopDX creados por la comunidad. Permite explorar, descargar, organizar e instalar contenido compatible en carpetas elegidas por el usuario. La aplicación no distribuye ni instala Super Mario 64, archivos ROM, SM64CoopDX ni versiones de SM64CoopDX para Android. Tampoco solicita, verifica ni ofrece instrucciones para obtener archivos del juego.';

  @override
  String get disclaimerSectionNoAffiliation => 'Sin afiliación oficial';

  @override
  String get disclaimerBodyNoAffiliation =>
      'Este proyecto no está asociado, respaldado ni aprobado por Nintendo, el equipo de SM64CoopDX ni los autores de los mods listados. Los nombres de productos y las marcas solo identifican compatibilidad. Los títulos, descripciones, imágenes, archivos y demás material acreditado pertenecen a sus respectivos autores o titulares.';

  @override
  String get disclaimerSectionDataSource => 'Fuente de datos';

  @override
  String get disclaimerBodyDataSource =>
      'El catálogo principal presenta publicaciones comunitarias públicas de Coop DX Mods (mods.sm64coopdx.com) y conserva el autor, título, fechas, versiones y fuente publicados. SM64CDPY proporciona una interfaz móvil y obtiene las descargas desde la fuente ofrecida para cada recurso; aparecer en el catálogo no implica propiedad ni respaldo oficial de SM64CDPY.';

  @override
  String get disclaimerSectionExclusive =>
      'Secciones curadas (VIP · DynOS · Touch Controls)';

  @override
  String disclaimerBodyExclusive(Object version) {
    return 'En la v$version, VIP Mods, paquetes DynOS, controles táctiles, OMM Rebirth y Render96 pueden usar fuentes curadas de forma independiente. Cuando el contenido no fue creado por el desarrollador de SM64CDPY, su creador acreditado conserva la autoría. Estas secciones son independientes del catálogo principal de Coop DX Mods y no son servicios oficiales de Nintendo ni de SM64CoopDX.';
  }

  @override
  String get disclaimerSectionLocalData => 'Cuentas y datos locales';

  @override
  String get disclaimerBodyLocalData =>
      'Actualmente SM64CDPY no crea cuentas de usuario. Los favoritos, el historial de instalaciones, las carpetas seleccionadas y las preferencias se guardan localmente en el dispositivo. Desinstalar la aplicación o borrar sus datos puede eliminar esta información.';

  @override
  String get disclaimerSectionExternalServices => 'Servicios externos';

  @override
  String get disclaimerBodyExternalServices =>
      'Explorar contenido, actualizar catálogos, abrir enlaces y descargar archivos puede conectar con servicios como Coop DX Mods, GitHub, Google Drive, Dropbox o GameBanana. Esos servicios funcionan bajo sus propios términos y prácticas de privacidad, que SM64CDPY no controla.';

  @override
  String get disclaimerSectionBugs => 'Soporte y correcciones de contenido';

  @override
  String get disclaimerBodyBugs =>
      'Contacta al desarrollador de SM64CDPY si encuentras un problema de la aplicación, una atribución incorrecta, información desactualizada o contenido que deba corregirse o retirarse. Cuando corresponda, incluye el título y la fuente del mod. Las solicitudes sobre la aplicación no deben dirigirse a Nintendo, al equipo de SM64CoopDX ni a los autores de mods.';

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
  String get settingsDynosFolder => 'Carpeta de DynOS y controles táctiles';

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
      'Carpeta de DynOS y controles táctiles seleccionada. Ambos tipos de contenido se instalarán aquí.';

  @override
  String get settingsClearDynosFolderTitle => '¿LIMPIAR CARPETA DYNOS?';

  @override
  String get settingsClearDynosFolderBody =>
      'Deberás seleccionar la carpeta de nuevo antes de instalar packs de DynOS o Touch Controls.';

  @override
  String get settingsDynosFolderCleared =>
      'Selección de carpeta DynOS eliminada.';

  @override
  String get settingsLanguageMode => 'Idioma';

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
  String get overlayChooseFile => 'Elige un archivo';

  @override
  String overlayFileFallback(int number) {
    return 'Archivo $number';
  }

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

  @override
  String get settingsOverlayActive => 'Burbuja activa';

  @override
  String get settingsOverlayInactive => 'Overlay flotante';

  @override
  String get settingsOverlayActiveDesc => 'Toca para ocultar la burbuja';

  @override
  String get settingsOverlayInactiveDesc =>
      'Toca para mostrar la burbuja sobre el juego';

  @override
  String get navRender96 => 'Render96';

  @override
  String get render96Title => 'RENDER96';

  @override
  String get render96SectionHeader => 'COLECCIÓN EXCLUSIVA';

  @override
  String get render96Empty => 'PRÓXIMAMENTE';

  @override
  String get render96EmptyHint =>
      'El nuevo contenido de Render96 aparecerá aquí.';

  @override
  String get render96FailedToLoad => 'ERROR AL CARGAR';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get libraryTitle => 'BIBLIOTECA';

  @override
  String get libraryInstalled => 'Instalados';

  @override
  String get libraryUpdates => 'Actualizaciones';

  @override
  String get libraryRecent => 'Recientes';

  @override
  String get libraryViewAll => 'Ver todo';

  @override
  String get libraryRefresh => 'Actualizar biblioteca';

  @override
  String get libraryAllSections => 'Todas las secciones';

  @override
  String get libraryAllDestinations => 'Todas las carpetas';

  @override
  String get libraryModsDestination => 'Carpeta de mods';

  @override
  String get libraryDynosDestination => 'Carpeta DynOS';

  @override
  String get libraryPresent => 'Instalado';

  @override
  String get libraryMissing => 'No encontrado';

  @override
  String get libraryPermissionRevoked => 'Permiso requerido';

  @override
  String get libraryFolderNotSelected => 'Carpeta requerida';

  @override
  String get libraryNotVerified => 'Sin verificar';

  @override
  String get libraryOpenSource => 'ABRIR CONTENIDO';

  @override
  String get libraryEmptyTitle => 'AÚN NO HAY INSTALACIONES';

  @override
  String get libraryEmptyBody =>
      'Los mods instalados por SM64CDPY aparecerán aquí.';

  @override
  String get libraryUpdatesEmptyTitle => 'NO HAY ACTUALIZACIONES CONOCIDAS';

  @override
  String get libraryUpdatesEmptyBody =>
      'Aquí aparecerán las actualizaciones confirmadas por el catálogo. También puedes revisar cada sección.';

  @override
  String get libraryDiscoveryHeaderIdentified => 'Encabezado identificado';

  @override
  String get libraryDiscoveryProbable => 'Mod probable';

  @override
  String get libraryDiscoveryUnlinked => 'Lua sin vincular';

  @override
  String get libraryErrorTitle => 'BIBLIOTECA NO DISPONIBLE';

  @override
  String get libraryErrorBody =>
      'No se pudo leer el historial de instalaciones. Reintenta sin modificar los archivos del juego.';

  @override
  String get libraryPartialWarning =>
      'Algunos registros no se pudieron leer. Las instalaciones válidas siguen visibles.';

  @override
  String get libraryCatalogLoading => 'Comprobando el catálogo actual…';

  @override
  String get libraryCatalogError =>
      'No se pudo comprobar el catálogo. El contenido instalado sigue disponible.';

  @override
  String libraryUpdateVersions(String installed, String available) {
    return '$installed → $available';
  }

  @override
  String get libraryEventInstall => 'Instalado';

  @override
  String get libraryEventUpdate => 'Actualizado';

  @override
  String get libraryEventReinstall => 'Reinstalado';

  @override
  String get libraryEventReplaced => 'Reemplazado por una versión más reciente';

  @override
  String get libraryForgetAction => 'OLVIDAR INSTALACIÓN';

  @override
  String get libraryForgetTitle => '¿OLVIDAR ESTA INSTALACIÓN?';

  @override
  String get libraryForgetBody =>
      'SM64CDPY retirará este elemento de la Biblioteca, pero no borrará ningún archivo del juego.';

  @override
  String get libraryForgetConfirm => 'OLVIDAR';

  @override
  String get libraryRemoveHistoryAction => 'QUITAR DEL HISTORIAL';

  @override
  String get libraryRemoveHistoryTitle => '¿QUITAR ESTE EVENTO?';

  @override
  String get libraryRemoveHistoryBody =>
      'Solo se quitará esta entrada del historial. La instalación actual y los archivos del juego no cambiarán.';

  @override
  String get libraryRemoveHistoryConfirm => 'QUITAR';

  @override
  String get libraryMaintenanceError =>
      'No se pudo actualizar la Biblioteca. Inténtalo de nuevo.';

  @override
  String get detailOpenExternalFolder => 'ABRIR CARPETA DE ORIGEN';

  @override
  String get detailSourceUnavailable =>
      'Esta versión no tiene un archivo descargable disponible por ahora.';

  @override
  String get detailViewDiscussion => 'VER CONVERSACIÓN DE LA COMUNIDAD';

  @override
  String get settingsInterfaceTheme => 'Tema de interfaz';

  @override
  String get settingsInterfaceThemeDesc =>
      'Elige un diseño incluido. Se aplica a la app; el panel flotante conserva su diseño oscuro.';

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
  String get themeModeLight => 'Claro';

  @override
  String get themeModeDark => 'Oscuro';

  @override
  String get themeModeSystem => 'Seguir el sistema';

  @override
  String get themeSaveFailed =>
      'No se pudo guardar la apariencia. Inténtalo de nuevo.';

  @override
  String get themeSaving => 'Guardando apariencia';

  @override
  String get gameModsTitle => 'Mods del juego';

  @override
  String get gameModsSubtitle => 'Elige los mods para el próximo inicio';

  @override
  String get gameModsHint =>
      'Cierra el juego antes de cambiar opciones. Estos interruptores configuran mods Lua y packs DynOS/Touch Controls para el próximo inicio.';

  @override
  String get gameModsSelectHint =>
      'Selecciona la carpeta user del juego que contiene sm64config.txt y mods.';

  @override
  String get gameModsConfirm =>
      'Cierra primero el juego. ¿Aplicar esta selección para el próximo inicio?';

  @override
  String get gameModsCancel => 'Cancelar';

  @override
  String get gameModsApply => 'Aplicar';

  @override
  String get gameModsSelect => 'Seleccionar carpeta user';

  @override
  String get gameModsDisconnect => 'Desconectar';

  @override
  String get gameModsConflict =>
      'La configuración cambió o hay otro mod activado incompatible. Actualiza e inténtalo de nuevo.';

  @override
  String get gameModsBlocked =>
      'No se puede activar este mod con seguridad. Revisa su estructura y datos, o desactiva un mod incompatible.';

  @override
  String get gameModsMismatch =>
      'Esta carpeta user no corresponde a la carpeta de mods seleccionada. Elige la misma instalación del juego.';

  @override
  String get gameModsWriteError =>
      'No se pudo confirmar la escritura. Cierra el juego y restaura la configuración anterior si hace falta.';

  @override
  String get gameModsFormat =>
      'La configuración o carpeta supera los límites admitidos o tiene un formato no compatible. No se aplicó el cambio.';

  @override
  String get gameModsAccess =>
      'Configuración no disponible. Comprueba que user contiene sm64config.txt y mods, y vuelve a seleccionar la carpeta con acceso de lectura y escritura.';

  @override
  String get gameModsRestore => 'Restaurar configuración anterior';

  @override
  String get gameModsRestoreConfirm =>
      'Con el juego cerrado, ¿reemplazar la configuración por el respaldo privado anterior a la última edición? También restaura sus otros ajustes.';

  @override
  String get gameModsInstalling =>
      'Espera a que terminen las descargas e instalaciones antes de cambiar los mods del juego.';

  @override
  String get gameModsEmpty =>
      'No se encontraron mods Lua compatibles en las carpetas del juego.';

  @override
  String get gameModsEnabled => 'Activado para el próximo inicio';

  @override
  String get gameModsDisabled => 'Desactivado para el próximo inicio';

  @override
  String get gameModsMore => 'Mostrar más';

  @override
  String get gameModsSize =>
      'Este mod alcanza el límite de 35 MiB del juego y no se puede activar.';

  @override
  String get gameModsSaved =>
      'Selección guardada y verificada para el próximo inicio del juego.';

  @override
  String get gameModsManage => 'Gestionar carpeta del juego';

  @override
  String gameModsCount(int enabled, int total) {
    return '$enabled de $total activados';
  }

  @override
  String get gameModsSearch => 'Buscar mods, autores, categorías…';

  @override
  String get gameModsAll => 'Todos';

  @override
  String get gameModsEnabledFilter => 'Activados';

  @override
  String get gameModsDisabledFilter => 'Desactivados';

  @override
  String get gameModsNoResults =>
      'No hay mods que coincidan con la búsqueda o el filtro.';

  @override
  String get gameModsClearSearch => 'Borrar búsqueda';

  @override
  String get gameModsDetails => 'Detalles del mod';

  @override
  String get gameModsCloseDetails => 'Cerrar';

  @override
  String get marioRomTitle => 'Recursos del juego original';

  @override
  String get marioRomBuiltIn => 'ROM sin seleccionar';

  @override
  String get marioRomReady => 'Interfaz original lista';

  @override
  String get marioRomDescription =>
      'Los temas Mario usan la ROM de tu carpeta user conectada. Las imágenes y fuentes se preparan una vez en privado y después se reutilizan. No necesitas seleccionar la ROM por separado.';

  @override
  String get marioRomImport => 'Preparar desde la carpeta del juego';

  @override
  String get marioRomPreparing => 'Preparando recursos del juego…';

  @override
  String get marioRomCancel => 'Cancelar importación';

  @override
  String get marioRomRemove => 'Usar diseño incluido';

  @override
  String get marioRomUnsupported =>
      'Esta ROM no es compatible. Selecciona una ROM estadounidense .z64 sin modificar. Tu diseño anterior sigue disponible.';

  @override
  String get marioRomFailed =>
      'No se pudieron leer o guardar los recursos. Elige el archivo de nuevo y comprueba el espacio disponible. Tu diseño anterior sigue disponible.';

  @override
  String get marioRomSuccess => 'Los recursos del juego original están listos.';

  @override
  String get marioRomUpgrade =>
      'Elige la ROM de nuevo para actualizar la interfaz original';

  @override
  String get gameFolderTitle => 'Conectar SM64CoopDX';

  @override
  String get gameFolderSummary =>
      'Elige una vez la carpeta principal del juego para encontrar mods y packs DynOS dentro y fuera de user, además de la ROM para los temas Mario.';

  @override
  String get gameFolderGuide =>
      'Elige la carpeta principal com.maniscat2.sm64coopdx, la que contiene user. Buscaremos mods y dynos/packs tanto aquí como dentro de user. La configuración y la ROM permanecen en user; las instalaciones nuevas también van dentro de user. Selecciona la carpeta principal, no user ni un archivo.';

  @override
  String get gameFolderChoose => 'Elegir carpeta del juego';

  @override
  String get gameFolderLater => 'Ahora no';

  @override
  String get gameFolderConnected => 'Juego conectado';

  @override
  String get gameFolderResolved =>
      'Biblioteca: mods, user/mods, dynos/packs y user/dynos/packs. Instalaciones nuevas: user/mods y user/dynos/packs.';

  @override
  String get gameFolderConfigReady => 'Configuración de mods encontrada.';

  @override
  String get gameFolderConfigMissing =>
      'Abre el juego una vez para crear su configuración de mods. Las descargas y los temas siguen disponibles.';

  @override
  String get gameFolderRomFound =>
      'ROM del juego encontrada. Los temas Mario prepararán sus recursos al seleccionarlos.';

  @override
  String get gameFolderRomMissing =>
      'No encontramos una ROM compatible en user. Abre SM64CoopDX y configura su ROM; después vuelve a intentarlo.';

  @override
  String get gameFolderChange => 'Cambiar carpeta del juego';

  @override
  String get gameFolderInvalid =>
      'Elige la carpeta principal del juego que contiene user, normalmente com.maniscat2.sm64coopdx. Abre el juego una vez si su carpeta user aún no está preparada.';

  @override
  String get gameFolderAccessLost =>
      'La carpeta del juego no está disponible. Elígela de nuevo para reconectar.';

  @override
  String get gameFolderDisconnect => 'Desconectar juego';

  @override
  String get gameFolderDisconnectBody =>
      'Dejar de usar esta carpeta para mods, DynOS y detección de ROM. Los archivos del juego, mods instalados y recursos de temas preparados permanecerán en el dispositivo.';

  @override
  String get gameFolderPrepareTitle => 'Preparar tema Mario';

  @override
  String get gameFolderPrepareBody =>
      'Leeremos la ROM de la carpeta del juego conectada y prepararemos las imágenes y fuentes del tema. Se hace una sola vez; la ROM y la configuración del juego no se modifican.';

  @override
  String get gameFolderPrepare => 'Preparar tema';

  @override
  String get gameFolderBusy =>
      'Espera a que terminen las descargas e instalaciones antes de cambiar la carpeta del juego.';

  @override
  String get gameModsLuaType => 'Mods Lua';

  @override
  String get gameModsDynosType => 'DynOS / Touch Controls';

  @override
  String get gameFolderUpgrade =>
      'El acceso está limitado a user. Elige la carpeta principal del juego para incluir también los mods y packs DynOS fuera de user.';

  @override
  String get gameDynosEmpty =>
      'No se encontraron carpetas de packs DynOS / Touch Controls en las carpetas del juego.';

  @override
  String get gameDynosSearch => 'Buscar packs DynOS / Touch Controls…';

  @override
  String get navPlayer => 'Jugador';

  @override
  String get playerTitle => 'JUGADOR';

  @override
  String get playerCharacter => 'PERSONAJE';

  @override
  String get player3DLoading => 'Preparando tu personaje desde el juego…';

  @override
  String get player3DUnavailable =>
      'La vista 3D no está disponible. Comprueba que SM64CoopDX y una ROM estadounidense compatible estén conectados.';

  @override
  String get playerName => 'Nombre del jugador';

  @override
  String get playerNameHint => 'Nombre que aparecerá en SM64CoopDX';

  @override
  String get playerCloseGameHint =>
      'Cierra SM64CoopDX antes de aplicar. Los cambios se usarán en el próximo inicio.';

  @override
  String get playerPresets => 'PALETAS';

  @override
  String get playerParts => 'COLORES DEL PERSONAJE';

  @override
  String get playerUnsavedTitle => '¿Descartar cambios?';

  @override
  String get playerUnsavedBody =>
      'Los colores o el nombre del jugador todavía no se aplicaron al juego.';

  @override
  String get playerKeepEditing => 'Seguir editando';

  @override
  String get playerDiscard => 'Descartar';

  @override
  String get playerDeletePreset => '¿Eliminar paleta?';

  @override
  String playerDeletePresetBody(String name) {
    return '¿Eliminar tu paleta «$name»?';
  }

  @override
  String get playerCancel => 'Cancelar';

  @override
  String get playerDelete => 'Eliminar';

  @override
  String get playerConflict =>
      'La configuración del juego cambió. Vuelve a cargarla antes de aplicar el perfil.';

  @override
  String get playerInvalid =>
      'Introduce un nombre y colores válidos. El nombre no puede contener espacios y admite hasta 63 bytes UTF-8.';

  @override
  String get playerPresetExists => 'Ya existe una paleta con ese nombre.';

  @override
  String get playerAccessError =>
      'La configuración del jugador no está disponible. Revisa la carpeta conectada y su permiso.';

  @override
  String get playerSavePreset => 'Guardar paleta';

  @override
  String get playerPresetName => 'Nombre de la paleta';

  @override
  String get playerSave => 'Guardar';

  @override
  String playerOverwritePreset(String name) {
    return '¿Reemplazar tu paleta «$name»?';
  }

  @override
  String get playerOverwrite => 'Reemplazar';

  @override
  String get playerPresetSaved => 'Paleta guardada para SM64CoopDX.';

  @override
  String get playerApplied =>
      'Perfil guardado y verificado para el próximo inicio del juego.';

  @override
  String get playerConnectGame =>
      'Conecta la carpeta principal de SM64CoopDX para editar el jugador.';

  @override
  String get playerMissingConfig =>
      'Abre SM64CoopDX una vez para crear user/sm64config.txt.';

  @override
  String get playerRetry => 'Reintentar';

  @override
  String get playerHex => 'Color hexadecimal';

  @override
  String get playerRed => 'R';

  @override
  String get playerGreen => 'V';

  @override
  String get playerBlue => 'A';

  @override
  String get playerReset => 'Restablecer';

  @override
  String get playerApply => 'Aplicar al juego';

  @override
  String get playerPants => 'Overol';

  @override
  String get playerShirt => 'Camisa';

  @override
  String get playerGloves => 'Guantes';

  @override
  String get playerShoes => 'Zapatos';

  @override
  String get playerHair => 'Cabello';

  @override
  String get playerSkin => 'Piel';

  @override
  String get playerCap => 'Gorra';

  @override
  String get playerEmblem => 'Emblema';

  @override
  String get playerRestore => 'Restaurar configuración anterior';

  @override
  String get playerRestoreBody =>
      'Con SM64CoopDX cerrado, ¿restaurar el respaldo privado anterior al último cambio de mods o jugador? Se restaurará toda la configuración.';

  @override
  String get playerRestored => 'Configuración anterior del juego restaurada.';

  @override
  String get retroAccentTitle => 'Acento de interfaz';

  @override
  String get retroAccentDescription =>
      'Elige el color destacado de Retro Manga o Mario Kart 64. MK64 también coordina el fondo, los paneles y la cuadrícula de carrera.';

  @override
  String get retroAccentCyan => 'Cian';

  @override
  String get retroAccentBlue => 'Azul';

  @override
  String get retroAccentViolet => 'Violeta';

  @override
  String get retroAccentPink => 'Rosa';

  @override
  String get retroAccentCoral => 'Coral';

  @override
  String get retroAccentAmber => 'Ámbar';

  @override
  String get retroAccentGreen => 'Verde';

  @override
  String get retroAccentLime => 'Lima';

  @override
  String get gameToolTitle => 'Herramientas';

  @override
  String get saveFileTitle => 'Partidas';

  @override
  String get saveFileHint => 'Elige una partida · juego original';

  @override
  String get saveFileConfirm =>
      'Cierra SM64CoopDX primero. Los cambios se aplican al volver a abrirlo. Copiar y borrar afectan el progreso normal y el alternativo de la partida elegida. Restaurar reemplaza las cuatro partidas. Se guarda un respaldo completo antes de escribir.';

  @override
  String get saveFileDone => 'Guardado';

  @override
  String get saveFileMissing =>
      'Conecta la carpeta del juego e inicia el juego una vez para crear su partida.';

  @override
  String get saveFileError =>
      'No se pudo verificar o guardar el archivo. Actualiza e inténtalo de nuevo; las copias de recuperación se conservan en Respaldos.';

  @override
  String get saveFilePrimary => 'Normal';

  @override
  String get saveFileAlternate => 'Alternativo';

  @override
  String get saveFileEmpty => 'Vacía';

  @override
  String get saveFileUnsigned => 'Copia sin firma o dañada';

  @override
  String get saveFileCopy => 'Copiar';

  @override
  String get saveFileProgress => 'Progreso';

  @override
  String get saveFileBackup => 'Crear respaldo';

  @override
  String get saveFileBackups => 'Respaldos';

  @override
  String get saveFileCannon => 'Cañón';

  @override
  String get saveFileCoins => 'Monedas';

  @override
  String get saveFileCastle => 'Estrellas del castillo';

  @override
  String get saveFileUnlocks => 'Desbloqueos';

  @override
  String get saveFileWing => 'Gorra alada';

  @override
  String get saveFileMetal => 'Gorra metálica';

  @override
  String get saveFileVanish => 'Gorra invisible';

  @override
  String get saveFileKey1 => 'Primera llave';

  @override
  String get saveFileKey2 => 'Segunda llave';

  @override
  String get saveFileBasement => 'Puerta del sótano';

  @override
  String get saveFileUpstairs => 'Puerta de la planta superior';

  @override
  String get saveFileMoat => 'Vaciar foso';

  @override
  String get saveFileComplete => 'Completar progreso: 120 estrellas';

  @override
  String get saveFileClearStars => 'Quitar estrellas';

  @override
  String get saveFileCourseNames =>
      'Campo de los Bob-omb|Fortaleza de Whomp|Bahía del Capitán|Montaña helada|Mansión encantada|Cueva laberíntica|Tierra de lava|Desierto cambiante|Muelles sombríos|País de nieve|Ciudad acuática|Montaña alta|Isla cambiante|Reloj|Camino del arcoíris|Bowser en el mundo oscuro|Bowser en el mar de fuego|Bowser en el cielo|Tobogán secreto de la princesa|Caverna de la gorra de metal|Torre de la gorra alada|Gorra invisible bajo el foso|Mario alado sobre el arcoíris|Acuario secreto';

  @override
  String get saveFileCopies => 'Progreso del juego';

  @override
  String get saveFileCopiesHint =>
      'Normal es el progreso habitual de tu partida. Algunos mods usan Alternativo para modos especiales, como el modo difícil. No es un respaldo. Elegirlo aquí no cambia el progreso que utiliza el juego.';

  @override
  String get saveFileOpenSlot => 'Toca para editar';

  @override
  String get saveFileActions => 'Acciones de partida';

  @override
  String get saveFileDraft => 'Vista previa · se guarda al aplicar';

  @override
  String get drawerResources => 'Recursos';

  @override
  String get fastInstallTitle => 'Activar instalación rápida';

  @override
  String get fastInstallDescription =>
      'Opcional: permite el acceso a todos los archivos en Android para acelerar la instalación en carpetas compatibles del juego. Sin él, puedes seguir instalando normalmente.';

  @override
  String get fastInstallAccessError =>
      'No se pudieron abrir los permisos. Puedes seguir instalando normalmente.';

  @override
  String get playGuideTitle => 'Cómo jugar';

  @override
  String get playGuideIntro =>
      'Tu primera aventura, paso a paso. Primero prepara el juego y después trae tus mods aquí.';

  @override
  String get playGuideNext => 'Siguiente paso';

  @override
  String get playGuideBack => 'Paso anterior';

  @override
  String get playGuideOpenDownload => 'Abrir descargas de Android';

  @override
  String get playGuideRepository => 'Repositorio del port Android';

  @override
  String get playGuideConnect => 'Conectar carpeta del juego';

  @override
  String get playGuideLibrary => 'Abrir Biblioteca';

  @override
  String get playGuideLaunch => 'Abrir el juego';

  @override
  String get playGuideMissingTitle => 'Vamos a preparar tu juego';

  @override
  String get playGuideMissingBody =>
      'SM64CoopDX Android no está instalado. Sigue la guía para instalarlo, preparar tu ROM y conectar tus mods.';

  @override
  String get playGuideRead => 'Ver guía de inicio';

  @override
  String get playGuideLater => 'Ahora no';

  @override
  String get playGuideLinkError =>
      'No se pudo abrir la página. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get playGuideLaunchError =>
      'El juego está instalado, pero Android no pudo abrirlo. Prueba desde su icono en la pantalla de inicio.';

  @override
  String get playGuideInstalled => 'Juego instalado';

  @override
  String get playGuideNotInstalled => 'Todavía no detectamos el juego';

  @override
  String get playGuideConnected => 'Carpeta del juego conectada';

  @override
  String get playGuideNotConnected => 'Carpeta del juego sin conectar';

  @override
  String get playGuideReady =>
      '¡Tu aventura te espera! Puedes volver a cualquier paso cuando lo necesites.';

  @override
  String get playGuideStep1Title => 'Consigue el juego';

  @override
  String get playGuideStep2Title => 'Prepara tu propia ROM';

  @override
  String get playGuideConvertTitle => 'Convertir mi ROM (.n64 / .v64)';

  @override
  String get playGuideStep3Title => 'Dale la ROM al juego';

  @override
  String get playGuideStep4Title => 'Conecta el manager';

  @override
  String get playGuideStep5Title => 'Añade tu primer mod';

  @override
  String get playGuidePathsTitle => '¿Dónde va cada cosa?';

  @override
  String get playGuideStep6Title => 'Juega y encuentra ayuda';

  @override
  String get playGuideMap => 'El mapa de tu aventura';

  @override
  String get playGuideSwipe => 'Desliza a los lados para cambiar de capítulo';

  @override
  String get playGuideChapter => 'CAPÍTULO';

  @override
  String get playGuideTip => 'Recuerda';

  @override
  String get playGuideOverview => 'Ver pasos';

  @override
  String get playGuideS1Card1 =>
      'SM64CDPY organiza mods. SM64CoopDX Android es otra aplicación: la que ejecuta el juego.';

  @override
  String get playGuideS1Card2 =>
      'Pulsa Abrir descargas de Android. Tu navegador abrirá GitHub, la página del port Android.';

  @override
  String get playGuideS1Card3 =>
      'Busca la versión y despliega Assets si hace falta. Descarga el archivo que termina en .apk, no Source code. Si hay varias opciones, sigue los requisitos para tu teléfono de esa versión.';

  @override
  String get playGuideS1Card4 =>
      'Abre el APK descargado y pulsa Instalar. Si Android lo pide, permite que ese navegador o explorador instale este APK y vuelve a la instalación.';

  @override
  String get playGuideS1Card5 =>
      'Abre SM64CoopDX una vez. Sigue sus indicaciones de almacenamiento para que cree su carpeta.';

  @override
  String get playGuideS1Card6 =>
      'Si no entiendes un aviso de Android, pide ayuda a alguien de confianza.';

  @override
  String get playGuideS2Card1 =>
      'La ROM es una copia del cartucho original de Super Mario 64. El APK por sí solo no incluye las imágenes y los sonidos originales del juego.';

  @override
  String get playGuideS2Card2 =>
      'Usa tu propia copia original de USA, sin modificar y en formato .z64. Esta guía no proporciona ROMs. Un ZIP es un paquete: extráelo primero para ver el archivo que contiene.';

  @override
  String get playGuideS2Card3 =>
      '¿Ya termina en .z64? Continúa al siguiente paso.';

  @override
  String get playGuideS2Card4 =>
      '¿Termina en .n64 o .v64? Abre «Convertir mi ROM» aquí abajo.';

  @override
  String get playGuideS2Card5 =>
      '¿Es de otra región o está modificada? Cambiar su nombre o formato no la convierte en una copia original de USA.';

  @override
  String get playGuideS3Card1 => 'Abre SM64CoopDX Android.';

  @override
  String get playGuideS3Card2 =>
      'Si te pide elegir una ROM, selecciona tu archivo .z64 de USA, normalmente en Descargas. Espera a que el juego termine de prepararlo.';

  @override
  String get playGuideS3Card3 =>
      'Si tu versión no tiene selector, cierra el juego. En tu explorador de archivos, copia el .z64 a Almacenamiento interno → com.maniscat2.sm64coopdx → user. Abre el juego de nuevo.';

  @override
  String get playGuideS3Card4 =>
      'Espera hasta llegar al menú del juego. Si rechaza la ROM, revisa que sea la original de USA, sin modificar, y que esté convertida de verdad a .z64.';

  @override
  String get playGuideS3Card5 =>
      'El juego conserva la ROM de USA aceptada como user/baserom.us.z64. La carpeta puede variar según sus permisos de almacenamiento; sigue la ubicación que te muestre el juego.';

  @override
  String get playGuideS4Card1 =>
      'Vuelve a SM64CDPY y pulsa Conectar carpeta del juego. Antes de abrir la ventana de carpetas de Android, explicaremos qué debes elegir.';

  @override
  String get playGuideS4Card2 =>
      'Abre Almacenamiento interno → com.maniscat2.sm64coopdx.';

  @override
  String get playGuideS4Card3 =>
      'Selecciona esa carpeta principal, la que contiene user, y pulsa Usar esta carpeta / Permitir. No elijas Descargas, user sola ni el archivo ROM.';

  @override
  String get playGuideS4Card4 =>
      'Una sola selección conecta mods, DynOS, ajustes del juego y detección de ROM. Si falta user, abre y prepara primero el juego. Si Android bloquea el acceso, revisa el almacenamiento del juego: elegir una carpeta vacía diferente no lo arregla.';

  @override
  String get playGuideS4Card5 =>
      '¿Ya está conectada? Continúa. No necesitas elegir las mismas carpetas para cada mod.';

  @override
  String get playGuideS5Card1 =>
      'Cierra el juego antes de instalar o cambiar mods.';

  @override
  String get playGuideS5Card2 =>
      'Abre Catálogo y elige un mod. Lee sus notas de compatibilidad.';

  @override
  String get playGuideS5Card3 =>
      'Descárgalo. Con instalación automática activada, espera a ver Instalado: terminar la descarga no significa que termine la instalación. Si la instalación automática está desactivada, sigue el aviso de instalación manual o actívala en Ajustes.';

  @override
  String get playGuideS5Card4 =>
      'Abre Herramientas → Biblioteca. Mods del juego reúne los mods Lua. DynOS / Touch Controls reúne modelos, texturas y controles. Activa el elemento que quieras usar.';

  @override
  String get playGuideS5Card5 =>
      'Abre de nuevo el juego para cargar los cambios. Algunos packs requieren sus propios ajustes dentro del juego: sigue las instrucciones de su autor.';

  @override
  String get playGuideS6Card1 =>
      'Pulsa Abrir el juego aquí abajo. Elige una partida dentro del juego y disfruta de tu aventura.';

  @override
  String get playGuideS6Card2 =>
      '¿El juego no abre? Prueba primero desde su icono en el inicio de Android.';

  @override
  String get playGuideS6Card3 =>
      '¿No acepta la ROM? Revisa la copia original de USA y el formato .z64 en el paso 2.';

  @override
  String get playGuideS6Card4 =>
      '¿No aparece el mod? Comprueba que terminó la instalación, actívalo en Biblioteca y reinicia el juego. Revisa si necesita otro mod.';

  @override
  String get playGuideS6Card5 =>
      '¿Perdiste el acceso a la carpeta? Reconecta la carpeta principal en el paso 4.';

  @override
  String get playGuideS6Card6 =>
      'Prueba un mod a la vez. Si algo falla, desactiva ese mod y vuelve a abrir el juego. Guarda un respaldo antes de borrar archivos del juego.';

  @override
  String get playGuideConvertCard1 =>
      'Conserva el archivo original como respaldo.';

  @override
  String get playGuideConvertCard2 =>
      'Abre el conversor de ROM en tu navegador.';

  @override
  String get playGuideConvertCard3 => 'Elige tu archivo .n64 o .v64.';

  @override
  String get playGuideConvertCard4 =>
      'Selecciona .z64 como formato de salida y guarda el resultado, normalmente en Descargas.';

  @override
  String get playGuideConvertCard5 =>
      'Regresa aquí y continúa con ese archivo .z64.';

  @override
  String get playGuideConvertCard6 =>
      'Convertir reorganiza los datos del archivo. Cambiar el nombre de .n64 a .z64 no lo convierte. Es una herramienta externa: si no está disponible, usa otro conversor de orden de bytes de N64 con salida .z64.';

  @override
  String get playGuidePathsCard1 =>
      'Dentro de Almacenamiento interno → com.maniscat2.sm64coopdx:';

  @override
  String get playGuidePathsCard2 =>
      'user/mods → nuevas instalaciones de mods Lua. Un mod puede ser un archivo .lua o una carpeta con main.lua.';

  @override
  String get playGuidePathsCard3 =>
      'user/dynos/packs → nuevos packs DynOS y Touch Controls. Touch Controls comparte este destino.';

  @override
  String get playGuidePathsCard4 =>
      'user/baserom.us.z64 → ROM original de USA aceptada por el juego.';

  @override
  String get playGuidePathsCard5 =>
      'user/sm64config.txt → ajustes del juego y elementos activados. Deja que la app lo gestione en vez de editarlo a mano.';

  @override
  String get playGuidePathsCard6 =>
      'El juego también lee mods y dynos/packs fuera de user. El manager también los muestra al conectar la carpeta principal. Si repites nombres, Lua prefiere user/mods; DynOS prefiere dynos/packs exterior. Evita mantener dos copias con el mismo nombre.';

  @override
  String get playGuideS1Title1 => 'Dos apps, dos tareas';

  @override
  String get playGuideS1Title2 => 'Abre la página de Android';

  @override
  String get playGuideS1Title3 => 'Elige el APK';

  @override
  String get playGuideS1Title4 => 'Instala el juego';

  @override
  String get playGuideS1Title5 => 'Ábrelo una vez';

  @override
  String get playGuideS1Title6 => 'Una mano amiga';

  @override
  String get playGuideS2Title1 => '¿Qué es una ROM?';

  @override
  String get playGuideS2Title2 => 'La copia que necesitas';

  @override
  String get playGuideS2Title3 => 'Ya tengo .z64';

  @override
  String get playGuideS2Title4 => 'Tengo .n64 o .v64';

  @override
  String get playGuideS2Title5 => 'La región importa';

  @override
  String get playGuideS3Title1 => 'Abre SM64CoopDX';

  @override
  String get playGuideS3Title2 => 'Elige tu ROM';

  @override
  String get playGuideS3Title3 => 'Si no aparece un selector';

  @override
  String get playGuideS3Title4 => 'Llega al menú del juego';

  @override
  String get playGuideS3Title5 => 'El hogar de tu ROM';

  @override
  String get playGuideS4Title1 => 'Vuelve al manager';

  @override
  String get playGuideS4Title2 => 'Busca la carpeta principal';

  @override
  String get playGuideS4Title3 => 'Permite usar esa carpeta';

  @override
  String get playGuideS4Title4 => 'Una sola conexión';

  @override
  String get playGuideS4Title5 => '¿Ya está conectada?';

  @override
  String get playGuideS5Title1 => 'Primero cierra el juego';

  @override
  String get playGuideS5Title2 => 'Elige un mod';

  @override
  String get playGuideS5Title3 => 'Espera la instalación';

  @override
  String get playGuideS5Title4 => 'Actívalo en Biblioteca';

  @override
  String get playGuideS5Title5 => 'Reinicia y pruébalo';

  @override
  String get playGuideS6Title1 => 'Empieza tu aventura';

  @override
  String get playGuideS6Title2 => 'El juego no abre';

  @override
  String get playGuideS6Title3 => 'No acepta la ROM';

  @override
  String get playGuideS6Title4 => 'No aparece el mod';

  @override
  String get playGuideS6Title5 => 'Perdiste el acceso';

  @override
  String get playGuideS6Title6 => 'Prueba uno a la vez';

  @override
  String get romPrepareNav => 'Preparar ROM';

  @override
  String get romPrepareTitle => 'Prepara tu ROM';

  @override
  String get romPrepareDescription =>
      'Elige tu propio archivo de Super Mario 64. La aplicación crea y verifica una copia .z64 compatible sin modificar el original.';

  @override
  String get romPreparePrivacy =>
      'SM64CDPY no incluye, descarga ni comparte ROMs. El archivo se procesa localmente en tu dispositivo.';

  @override
  String get romPrepareChoose => 'Elegir ROM';

  @override
  String get romPrepareChooseAnother => 'Elegir otro archivo';

  @override
  String get romPrepareAnother => 'Preparar otra ROM';

  @override
  String get romPrepareSave => 'Guardar copia .z64';

  @override
  String get romPrepareContinue => 'Continuar con la guía';

  @override
  String get romPrepareCancel => 'Cancelar';

  @override
  String get romPrepareIdle => 'Listo para comprobar tu archivo';

  @override
  String get romPreparePicking => 'Elige tu archivo en Android';

  @override
  String get romPrepareInspecting => 'Comprobando el archivo seleccionado';

  @override
  String get romPrepareConverting => 'Preparando una copia compatible';

  @override
  String get romPrepareValidating => 'Verificando la ROM preparada';

  @override
  String get romPrepareReady => 'ROM compatible lista';

  @override
  String get romPrepareAlreadyCompatible =>
      'Tu ROM ya estaba en el formato correcto';

  @override
  String get romPrepareChoosingDestination => 'Elige dónde guardar la copia';

  @override
  String get romPrepareExporting => 'Guardando tu copia';

  @override
  String get romPrepareVerifyingExport => 'Verificando la copia guardada';

  @override
  String get romPrepareSaved => 'Copia guardada y verificada';

  @override
  String get romPrepareCancelling => 'Deteniendo de forma segura';

  @override
  String get romPrepareCancelled => 'Preparación cancelada';

  @override
  String get romPrepareFailed => 'No se pudo preparar la ROM';

  @override
  String romPrepareDetected(String format) {
    return 'Formato detectado: $format';
  }

  @override
  String romPrepareSavedAs(String name) {
    return 'Guardada como $name';
  }

  @override
  String get romPrepareErrorUnrecognized =>
      'El archivo no tiene un formato de ROM de N64 reconocido.';

  @override
  String get romPrepareErrorSize =>
      'La ROM original de Super Mario 64 debe medir exactamente 8 MiB.';

  @override
  String get romPrepareErrorIncompatible =>
      'Necesitas una ROM original sin modificar de Super Mario 64 USA.';

  @override
  String get romPrepareErrorPermission =>
      'Android ya no permite acceder a ese archivo. Elígelo nuevamente.';

  @override
  String get romPrepareErrorStorage =>
      'No hay almacenamiento suficiente o no se pudo leer el archivo.';

  @override
  String get romPrepareErrorExport =>
      'No se pudo verificar la copia guardada. Elige otro destino e inténtalo de nuevo.';

  @override
  String get romPrepareErrorBusy => 'Ya hay otra operación de ROM activa.';

  @override
  String get romPrepareErrorUnexpected =>
      'Ocurrió algo inesperado. Tu archivo original no fue modificado.';

  @override
  String get mangaNavLibrary => 'Mis Mods';

  @override
  String get mangaNavExplore => 'Mods';

  @override
  String get mangaMenuLabel => 'Menú';

  @override
  String get mangaMenuOpen => 'Abrir menú';

  @override
  String get mangaMenuClose => 'Cerrar menú';

  @override
  String get mangaNavTools => 'Taller';

  @override
  String get mangaNavMore => 'MAS';

  @override
  String get mangaNavPlay => 'Jugar';

  @override
  String get mangaNavHint => 'Desliza para explorar. Toca para abrir.';

  @override
  String get mangaNavError =>
      'No se pudo completar la acción. Inténtalo de nuevo.';

  @override
  String get mangaMenuSoundsTitle => 'Sonidos del menú';

  @override
  String get mangaMenuSoundsDescription =>
      'Efectos al abrir, seleccionar y deslizar el menú.';

  @override
  String get appEffectsVolume => 'Volumen de efectos';

  @override
  String get appEffectsVolumeDescription =>
      'Ajusta solo los efectos de esta app. El volumen multimedia del teléfono sigue siendo el límite.';

  @override
  String get ambientMusicTitle => 'Música ambiental';

  @override
  String get ambientMusicDescription =>
      'Una pista suave mientras usas Retro Manga. Se pausa al salir de la app.';

  @override
  String get ambientMusicVolume => 'Volumen de música';

  @override
  String get mangaNavAudio => 'Audio';

  @override
  String get themeMangaDeluxe => 'Manga Deluxe';

  @override
  String get deluxeWelcome => 'Bienvenido a CoopDX';

  @override
  String get deluxeWelcomeBody =>
      'Tu compañero de mods en Android: prepara el juego, descubre mods y encuentra la comunidad de CoopDX.';

  @override
  String get deluxeSpotlight => 'De la selección de CoopDX';

  @override
  String get deluxeDncBody =>
      'Cielos, iluminación y un ciclo completo de día y noche. Mira el mod en acción antes de explorar sus detalles.';

  @override
  String get deluxeViewMod => 'Ver mod';

  @override
  String get deluxeWatchDemo => 'Ver demostración';

  @override
  String get deluxeDemoHint =>
      'Abre el vídeo oficial fuera de la app. Requiere internet.';

  @override
  String get deluxeLinkError =>
      'No se pudo abrir el enlace. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get deluxeHelpTitle => 'Ayuda rápida';

  @override
  String get deluxeFaqRom => '¿Qué ROM necesito?';

  @override
  String get deluxeFaqRomAnswer =>
      'Usa tu propio volcado USA verificado en formato .z64. El Preparador de ROM puede convertir una copia sin cambiar el original.';

  @override
  String get deluxeFaqFolders => '¿Qué carpeta selecciono?';

  @override
  String get deluxeFaqFoldersAnswer =>
      'Usa Conectar carpeta del juego. La guía explica qué ubicación seleccionar y el gestor detecta los mods y packs compatibles.';

  @override
  String get deluxeFaqPacks => '¿Mods del juego o DynOS?';

  @override
  String get deluxeFaqPacksAnswer =>
      'Los mods Lua cambian el comportamiento del juego. Los packs DynOS aportan modelos, texturas y Touch Controls. Adminístralos desde sus secciones separadas en Biblioteca.';

  @override
  String get deluxeOpenGuide => 'Abrir';

  @override
  String get deluxeCommunity => 'Comunidad y enlaces';

  @override
  String get deluxeGameNews => 'Novedades del juego Android';

  @override
  String get deluxeMotion => 'Fondo en movimiento';

  @override
  String get deluxeMotionHint =>
      'Desplazamiento opcional de gorros y patrón. Déjalo apagado para ahorrar batería.';

  @override
  String get deluxeReducedMotion =>
      'El movimiento está pausado por tus ajustes de accesibilidad.';

  @override
  String get deluxeReset => 'Restablecer diseño y audio Deluxe';

  @override
  String get deluxeResetDone => 'Diseño y audio Deluxe restablecidos.';

  @override
  String get deluxeMusicDescription =>
      'Una pista suave para Manga Deluxe. Se pausa al salir de la app.';

  @override
  String get deluxeAccentDescription =>
      'Elige los acentos y el color del patrón de fondo de Manga Deluxe.';

  @override
  String get deluxeResetHint =>
      'Restaura el acento y el audio compartidos. Conserva tus carpetas, mods y partidas.';

  @override
  String get deluxeWelcomeCompact =>
      '¿Primera vez? Prepara el juego con nuestra guía.';

  @override
  String get deluxeSkip => 'Omitir';

  @override
  String get deluxeSkipHint =>
      'Ocultar esta introducción. La guía seguirá en el menú.';

  @override
  String get coopTitle => 'Jugar con amigos';

  @override
  String get coopNav => 'Jugar';

  @override
  String get coopIntro =>
      'Crea una sala privada o únete con el código de tu amigo. El asistente conecta SM64CoopDX por internet mientras el juego usa su Conexión directa local.';

  @override
  String get coopPrivacy =>
      'El código de sala es un secreto compartido. La señalización usa el servicio compatible de Cloudflare; el tráfico del juego se conecta directamente cuando es posible y usa TURN solo cuando hace falta.';

  @override
  String get coopConsentTitle => 'Privacidad de red';

  @override
  String get coopConsentIntro =>
      'Antes de crear o unirte a una sala, revisa cómo funciona la conexión.';

  @override
  String get coopConsentEncrypted =>
      'El código de sala deriva la clave que cifra la señalización WebRTC. Compártelo solo con personas de confianza.';

  @override
  String get coopConsentIp =>
      'Tu dirección de internet puede ser visible para el amigo invitado y para los servicios de búsqueda de dirección de Google y Cloudflare.';

  @override
  String get coopConsentThirdParty =>
      'La señalización y el relay usan un servicio compatible de Cloudflare operado por terceros. Su disponibilidad y retención dependen de ese servicio.';

  @override
  String get coopConsentAccept => 'Entiendo y quiero continuar';

  @override
  String get coopConsentCancel => 'Ahora no';

  @override
  String get coopConsentReview => 'Revisar privacidad de red';

  @override
  String get coopConsentSaveError =>
      'No se pudo guardar tu elección. No se inició ninguna sesión de red.';

  @override
  String get coopCreate => 'Crear partida';

  @override
  String get coopJoin => 'Unirse a partida';

  @override
  String get coopCode => 'Código de amigo';

  @override
  String get coopCodeHint => 'ABCD-1234';

  @override
  String get coopRecent => 'Códigos recientes';

  @override
  String get coopClearRecent => 'Borrar';

  @override
  String get coopWaiting => 'Esperando amigos';

  @override
  String get coopConnecting => 'Buscando a tu amigo';

  @override
  String get coopConnected => 'Partida conectada';

  @override
  String get coopReconnecting => 'Reconectando';

  @override
  String get coopPreparing => 'Preparando sala segura';

  @override
  String get coopStop => 'Detener partida';

  @override
  String get coopOpenGame => 'Abrir SM64CoopDX';

  @override
  String get coopGameMissing =>
      'SM64CoopDX no está instalado en este dispositivo.';

  @override
  String get coopGameReady => 'SM64CoopDX detectado';

  @override
  String get coopHostInstruction =>
      'En el juego abre Multijugador > Conexión directa > Host. Tus amigos se unen con el código mostrado aquí.';

  @override
  String coopJoinInstruction(int port) {
    return 'En el juego abre Multijugador > Conexión directa y conéctate a 127.0.0.1 usando el puerto $port.';
  }

  @override
  String get coopCopy => 'Copiar código';

  @override
  String get coopCopied => 'Código copiado';

  @override
  String get coopShare => 'Compartir invitación';

  @override
  String get coopShareSubject => 'Invitación a partida de SM64CoopDX';

  @override
  String coopShareMessage(String code) {
    return '¡Únete a mi partida de SM64CoopDX!\n\nCódigo de amigo: $code\n\nAbre SM64CDPY, entra en Jugar, pulsa Unirse a partida y escribe este código. Compártelo solo con personas de confianza.';
  }

  @override
  String get coopShareError =>
      'No se pudo compartir la invitación. Intenta copiar el código.';

  @override
  String coopPeers(int count) {
    return 'Amigos: $count';
  }

  @override
  String get coopDirect => 'Directa';

  @override
  String get coopRelay => 'Relay';

  @override
  String get coopNoCode => 'Introduce un código válido de ocho caracteres.';

  @override
  String get coopNetworkError =>
      'No se pudo iniciar la partida. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get coopBatteryTitle => 'Conexión en segundo plano';

  @override
  String get coopBatteryDescription =>
      'Opcional: permite uso de batería sin restricciones para reducir el riesgo de que Android pause la partida mientras el juego está abierto.';

  @override
  String get coopBatteryAllowed =>
      'El uso de batería sin restricciones está permitido. Android podrá mantener la partida activa con mayor fiabilidad.';

  @override
  String get coopBatteryAllow => 'Permitir en Android';

  @override
  String get coopBatteryManage => 'Administrar en Android';

  @override
  String get coopBatteryOpenError =>
      'No se pudieron abrir los ajustes de batería de Android en este dispositivo.';

  @override
  String get coopDiagnosticsTitle => 'Diagnóstico de conexión';

  @override
  String coopDiagnosticsSignal(int count) {
    return 'Conexiones de señalización: $count';
  }

  @override
  String coopDiagnosticsPackets(int toGame, int toPage) {
    return 'Paquetes del juego: $toGame recibidos · $toPage enviados';
  }

  @override
  String coopDiagnosticsDelay(int average, int max) {
    return 'Demora del puente: $average ms promedio · $max ms máxima';
  }

  @override
  String get homeCardSoundsTitle => 'Sonidos de tarjetas de Inicio';

  @override
  String get homeCardSoundsDescription =>
      'Sonido al cambiar tarjetas de Destacados o Explorar. Independiente del menú y la música.';

  @override
  String get homeCardSoundsVolume => 'Volumen de tarjetas';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageSaveFailed =>
      'No se pudo guardar el idioma. Inténtalo de nuevo.';

  @override
  String get sharedCopyDetails => 'Copiar detalles';

  @override
  String get sharedCopied => 'Copiado al portapapeles';

  @override
  String sharedAuthor(String author) {
    return 'Autor: $author';
  }

  @override
  String get sharedUntitled => 'Sin título';

  @override
  String get render96Required => 'NECESARIO';

  @override
  String get render96Optional => 'OPCIONAL';

  @override
  String get render96Skinpack => 'PACK DE MODELOS';

  @override
  String get settingsExportFailed =>
      'No se pudieron exportar tus favoritos. Inténtalo de nuevo.';

  @override
  String get settingsImportFailed =>
      'No se pudo importar este archivo. Elige un archivo de favoritos exportado por SM64CDPY.';

  @override
  String get settingsDatabaseFailed =>
      'No se pudo actualizar el catálogo. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get updateActionFailed =>
      'No se pudo completar la actualización. Inténtalo de nuevo o descárgala desde el navegador.';

  @override
  String get render96WatchTrailer => 'VER TRÁILER';

  @override
  String get render96CategoryOther => 'CONTENIDO';

  @override
  String get coopConnectionFailed =>
      'La partida no pudo continuar. Revisa tu conexión e iníciala de nuevo.';

  @override
  String get catalogLoadFailed =>
      'No se pudo cargar este contenido. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get settingsFavouritesShareSubject => 'Favoritos de SM64CoopDX';

  @override
  String get favEmptyActionHint => 'Toca ♥ en una tarjeta para guardarla aquí.';

  @override
  String get guidedSetupWelcomeTitle => 'Bienvenido';

  @override
  String get guidedSetupWelcomeBody =>
      '¡Qué gusto verte por aquí! Preparemos juntos tu aventura de mods. Tú siempre tendrás el control y los accesos opcionales pueden esperar hasta que los necesites.';

  @override
  String guidedSetupProgress(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get guidedSetupStart => 'Iniciar';

  @override
  String get guidedSetupLater => 'Más tarde';

  @override
  String get guidedSetupAudioTitle => 'Sonido de la aplicación';

  @override
  String get guidedSetupAudioBody =>
      '¿Quieres disfrutar música ambiental y efectos mientras exploras tus mods? Después podrás ajustar la música y los efectos por separado en Ajustes.';

  @override
  String get guidedSetupAudioOn => 'Con sonido';

  @override
  String get guidedSetupAudioOff => 'Modo silencioso';

  @override
  String get guidedSetupAudioSaveError =>
      'No se pudo guardar tu preferencia de sonido. Inténtalo de nuevo.';

  @override
  String get guidedSetupDoneTitle => 'Todo listo';

  @override
  String get guidedSetupDoneBody =>
      'La configuración básica terminó. Los accesos opcionales seguirán disponibles en Ajustes cuando una función los necesite.';

  @override
  String get guidedSetupFinish => 'Finalizar';

  @override
  String get permissionCenterTitle => 'Permisos y accesos';

  @override
  String get permissionCenterSubtitle =>
      'Revisa qué puede usar la app y por qué';

  @override
  String get permissionCenterIntro =>
      'Concede acceso solo cuando entiendas su finalidad. Los accesos opcionales se solicitan en contexto y la app consulta su estado actual en Android.';

  @override
  String get permissionStatusAllowed => 'Permitido';

  @override
  String get permissionStatusNotAllowed => 'No permitido';

  @override
  String get permissionStatusOptional => 'Opcional · verificando estado';

  @override
  String get permissionManage => 'Administrar';

  @override
  String get permissionFolderDescription =>
      'Permite encontrar, instalar y administrar mods y archivos del jugador en la carpeta del juego que elijas.';

  @override
  String get permissionNotificationsDescription =>
      'Muestra el progreso de descargas e instalaciones. Solo se solicita cuando una descarga lo necesita.';

  @override
  String get permissionAllFilesDescription =>
      'Instalación rápida opcional en dispositivos Android compatibles. El acceso por carpeta sigue funcionando sin este permiso.';

  @override
  String get permissionOverlayDescription =>
      'Burbuja flotante opcional de descargas sobre otras aplicaciones.';

  @override
  String get permissionBatteryDescription =>
      'Opcional para mantener sesiones de Jugar más largas cuando la app está en segundo plano.';

  @override
  String get permissionUpdatesTitle => 'Instalar actualizaciones';

  @override
  String get permissionUpdatesDescription =>
      'Android solicita este acceso especial solo cuando decides instalar una actualización de la app.';

  @override
  String get permissionNetworkTitle => 'Red y Jugar';

  @override
  String get permissionNetworkDescription =>
      'Internet permite consultar el catálogo y usar sesiones en línea. Jugar pide consentimiento explícito antes de conectarse a su servicio.';

  @override
  String get permissionRunGuide => 'Repetir recorrido guiado';

  @override
  String get permissionRunGuideDescription =>
      'Vuelve a mostrar la bienvenida sin cambiar por sí solo ningún permiso de Android.';
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
  String get navVIPMods => 'Mods';

  @override
  String get navDynOS => 'DynOS';

  @override
  String get navTouchControls => 'Controles Táctiles';

  @override
  String get navOmmRebirth => 'Omm Pack';

  @override
  String get navLinksResource => 'Enlaces';

  @override
  String get navDisclaimer => 'Aviso Legal';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get sectionExclusive => 'Exclusivo';

  @override
  String get sectionNavigation => 'NAVEGACIÓN';

  @override
  String get sectionExplore => 'Explorar';

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
  String get homeExclusiveContent => 'Exclusivo';

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
  String get homeLaunchGame => 'INICIAR JUEGO';

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
    return 'Pág. $page/$total';
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
  String get installationChecking => 'COMPROBANDO...';

  @override
  String get installationCancel => 'CANCELAR';

  @override
  String get installationInstalled => 'INSTALADO';

  @override
  String get installationUpdate => 'ACTUALIZAR';

  @override
  String get installationInstall => 'INSTALAR';

  @override
  String get installationReinstall => 'REINSTALAR';

  @override
  String get installationVerify => 'VERIFICAR';

  @override
  String get installationSelectFolder => 'SELECCIONAR CARPETA';

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
      'Vuelve más tarde para encontrar nuevos packs DynOS.';

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
  String get overlayCancelling => 'Cancelando...';

  @override
  String get detailDynosFolderNotSelected =>
      'Carpeta de DynOS y controles táctiles no seleccionada';

  @override
  String get detailDynosFolderBody =>
      'Selecciona la carpeta compartida de DynOS y controles táctiles en Ajustes → Integración del Juego antes de instalar este contenido.';

  @override
  String get detailInstallDownloadedTitle =>
      '¿Instalar el contenido descargado?';

  @override
  String detailInstallDownloadedBody(String name) {
    return '$name terminó de descargarse. ¿Quieres instalarlo ahora en la carpeta de DynOS y controles táctiles?';
  }

  @override
  String get detailInstallNow => 'Instalar ahora';

  @override
  String get detailKeepDownload => 'Ahora no';

  @override
  String detailDownloadedNotInstalled(String name) {
    return 'Descargado, pero no instalado: $name';
  }

  @override
  String detailInstallQueued(String name) {
    return 'Descarga e instalación en cola: $name';
  }

  @override
  String get detailContentUnavailable =>
      'Esta descarga ya no está disponible (404). Es posible que el enlace haya sido eliminado o cambiado.';

  @override
  String get detailFriendlyDownloadError =>
      'No se pudo completar la descarga. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get detailScreenshots => 'Capturas';

  @override
  String get detailYoutubeVideos => 'Videos de YouTube';

  @override
  String get detailDirectVideos => 'Videos';

  @override
  String get detailTags => 'Etiquetas';

  @override
  String get detailAbout => 'Acerca de';

  @override
  String get detailDescriptionViewOriginal => 'Ver original';

  @override
  String get detailDescriptionViewTranslation => 'Ver traducción';

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
  String get detailLatestVersion => 'ÚLTIMA VERSIÓN';

  @override
  String get detailPreviousVersions => 'Versiones anteriores';

  @override
  String detailViewPreviousVersions(int count) {
    return 'Ver $count versiones anteriores';
  }

  @override
  String get detailNoDownloadFiles =>
      'No hay archivos disponibles para descargar.';

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
      'Las descargas se instalarán automáticamente en la carpeta del juego configurada';

  @override
  String get settingsAutoInstallOff =>
      'Se te preguntará después de cada descarga';

  @override
  String get autoInstallPromptTitle =>
      '¿Instalar los mods después de descargarlos?';

  @override
  String get autoInstallPromptBody =>
      'Activa la instalación automática para colocar los mods descargados en la carpeta configurada del juego. Puedes cambiarlo después en Ajustes.';

  @override
  String get autoInstallPromptEnable => 'Activar';

  @override
  String get autoInstallPromptDownloadOnly => 'Solo descargar';

  @override
  String get settingsThemeMode => 'Modo de tema';

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
  String get linksAppWebsite => 'Sitio oficial de SM64CDPY';

  @override
  String get linksAppWebsiteDesc =>
      'Novedades, descargas e información del proyecto';

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
  String get disclaimerAppSubtitle => 'Gestor de mods de SM64CoopDX';

  @override
  String get disclaimerWarningBody =>
      'SM64CDPY es software independiente. Las preguntas, problemas técnicos y solicitudes relacionadas con esta aplicación deben dirigirse al desarrollador de SM64CDPY, no a Nintendo, al equipo de SM64CoopDX ni a los autores de los mods listados.';

  @override
  String get disclaimerCouldNotOpenLink => 'No se pudo abrir el enlace';

  @override
  String get disclaimerSectionPersonalPurpose => 'Acerca de esta aplicación';

  @override
  String get disclaimerBodyPersonalPurpose =>
      'SM64CDPY es un catálogo y gestor independiente para Android de mods de SM64CoopDX creados por la comunidad. Permite explorar, descargar, organizar e instalar contenido compatible en carpetas elegidas por el usuario. La aplicación no distribuye ni instala Super Mario 64, archivos ROM, SM64CoopDX ni versiones de SM64CoopDX para Android. Tampoco solicita, verifica ni ofrece instrucciones para obtener archivos del juego.';

  @override
  String get disclaimerSectionNoAffiliation => 'Sin afiliación oficial';

  @override
  String get disclaimerBodyNoAffiliation =>
      'Este proyecto no está asociado, respaldado ni aprobado por Nintendo, el equipo de SM64CoopDX ni los autores de los mods listados. Los nombres de productos y las marcas solo identifican compatibilidad. Los títulos, descripciones, imágenes, archivos y demás material acreditado pertenecen a sus respectivos autores o titulares.';

  @override
  String get disclaimerSectionDataSource => 'Fuente de datos';

  @override
  String get disclaimerBodyDataSource =>
      'El catálogo principal presenta publicaciones comunitarias públicas de Coop DX Mods (mods.sm64coopdx.com) y conserva el autor, título, fechas, versiones y fuente publicados. SM64CDPY proporciona una interfaz móvil y obtiene las descargas desde la fuente ofrecida para cada recurso; aparecer en el catálogo no implica propiedad ni respaldo oficial de SM64CDPY.';

  @override
  String get disclaimerSectionExclusive =>
      'Secciones curadas (VIP · DynOS · Touch Controls)';

  @override
  String disclaimerBodyExclusive(Object version) {
    return 'En la v$version, VIP Mods, paquetes DynOS, controles táctiles, OMM Rebirth y Render96 pueden usar fuentes curadas de forma independiente. Cuando el contenido no fue creado por el desarrollador de SM64CDPY, su creador acreditado conserva la autoría. Estas secciones son independientes del catálogo principal de Coop DX Mods y no son servicios oficiales de Nintendo ni de SM64CoopDX.';
  }

  @override
  String get disclaimerSectionLocalData => 'Cuentas y datos locales';

  @override
  String get disclaimerBodyLocalData =>
      'Actualmente SM64CDPY no crea cuentas de usuario. Los favoritos, el historial de instalaciones, las carpetas seleccionadas y las preferencias se guardan localmente en el dispositivo. Desinstalar la aplicación o borrar sus datos puede eliminar esta información.';

  @override
  String get disclaimerSectionExternalServices => 'Servicios externos';

  @override
  String get disclaimerBodyExternalServices =>
      'Explorar contenido, actualizar catálogos, abrir enlaces y descargar archivos puede conectar con servicios como Coop DX Mods, GitHub, Google Drive, Dropbox o GameBanana. Esos servicios funcionan bajo sus propios términos y prácticas de privacidad, que SM64CDPY no controla.';

  @override
  String get disclaimerSectionBugs => 'Soporte y correcciones de contenido';

  @override
  String get disclaimerBodyBugs =>
      'Contacta al desarrollador de SM64CDPY si encuentras un problema de la aplicación, una atribución incorrecta, información desactualizada o contenido que deba corregirse o retirarse. Cuando corresponda, incluye el título y la fuente del mod. Las solicitudes sobre la aplicación no deben dirigirse a Nintendo, al equipo de SM64CoopDX ni a los autores de mods.';

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
  String get settingsDynosFolder => 'Carpeta de DynOS y controles táctiles';

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
      'Carpeta de DynOS y controles táctiles seleccionada. Ambos tipos de contenido se instalarán aquí.';

  @override
  String get settingsClearDynosFolderTitle => '¿LIMPIAR CARPETA DYNOS?';

  @override
  String get settingsClearDynosFolderBody =>
      'Deberás seleccionar la carpeta de nuevo antes de instalar packs de DynOS o Touch Controls.';

  @override
  String get settingsDynosFolderCleared =>
      'Selección de carpeta DynOS eliminada.';

  @override
  String get settingsLanguageMode => 'Idioma';

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
  String get overlayChooseFile => 'Elige un archivo';

  @override
  String overlayFileFallback(int number) {
    return 'Archivo $number';
  }

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

  @override
  String get settingsOverlayActive => 'Burbuja activa';

  @override
  String get settingsOverlayInactive => 'Overlay flotante';

  @override
  String get settingsOverlayActiveDesc => 'Toca para ocultar la burbuja';

  @override
  String get settingsOverlayInactiveDesc =>
      'Toca para mostrar la burbuja sobre el juego';

  @override
  String get navRender96 => 'Render96';

  @override
  String get render96Title => 'RENDER96';

  @override
  String get render96SectionHeader => 'COLECCIÓN EXCLUSIVA';

  @override
  String get render96Empty => 'PRÓXIMAMENTE';

  @override
  String get render96EmptyHint =>
      'El nuevo contenido de Render96 aparecerá aquí.';

  @override
  String get render96FailedToLoad => 'ERROR AL CARGAR';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get libraryTitle => 'BIBLIOTECA';

  @override
  String get libraryInstalled => 'Instalados';

  @override
  String get libraryUpdates => 'Actualizaciones';

  @override
  String get libraryRecent => 'Recientes';

  @override
  String get libraryViewAll => 'Ver todo';

  @override
  String get libraryRefresh => 'Actualizar biblioteca';

  @override
  String get libraryAllSections => 'Todas las secciones';

  @override
  String get libraryAllDestinations => 'Todas las carpetas';

  @override
  String get libraryModsDestination => 'Carpeta de mods';

  @override
  String get libraryDynosDestination => 'Carpeta DynOS';

  @override
  String get libraryPresent => 'Instalado';

  @override
  String get libraryMissing => 'No encontrado';

  @override
  String get libraryPermissionRevoked => 'Permiso requerido';

  @override
  String get libraryFolderNotSelected => 'Carpeta requerida';

  @override
  String get libraryNotVerified => 'Sin verificar';

  @override
  String get libraryOpenSource => 'ABRIR CONTENIDO';

  @override
  String get libraryEmptyTitle => 'AÚN NO HAY INSTALACIONES';

  @override
  String get libraryEmptyBody =>
      'Los mods instalados por SM64CDPY aparecerán aquí.';

  @override
  String get libraryUpdatesEmptyTitle => 'NO HAY ACTUALIZACIONES CONOCIDAS';

  @override
  String get libraryUpdatesEmptyBody =>
      'Aquí aparecerán las actualizaciones confirmadas por el catálogo. También puedes revisar cada sección.';

  @override
  String get libraryDiscoveryHeaderIdentified => 'Encabezado identificado';

  @override
  String get libraryDiscoveryProbable => 'Mod probable';

  @override
  String get libraryDiscoveryUnlinked => 'Lua sin vincular';

  @override
  String get libraryErrorTitle => 'BIBLIOTECA NO DISPONIBLE';

  @override
  String get libraryErrorBody =>
      'No se pudo leer el historial de instalaciones. Reintenta sin modificar los archivos del juego.';

  @override
  String get libraryPartialWarning =>
      'Algunos registros no se pudieron leer. Las instalaciones válidas siguen visibles.';

  @override
  String get libraryCatalogLoading => 'Comprobando el catálogo actual…';

  @override
  String get libraryCatalogError =>
      'No se pudo comprobar el catálogo. El contenido instalado sigue disponible.';

  @override
  String libraryUpdateVersions(String installed, String available) {
    return '$installed → $available';
  }

  @override
  String get libraryEventInstall => 'Instalado';

  @override
  String get libraryEventUpdate => 'Actualizado';

  @override
  String get libraryEventReinstall => 'Reinstalado';

  @override
  String get libraryEventReplaced => 'Reemplazado por una versión más reciente';

  @override
  String get libraryForgetAction => 'OLVIDAR INSTALACIÓN';

  @override
  String get libraryForgetTitle => '¿OLVIDAR ESTA INSTALACIÓN?';

  @override
  String get libraryForgetBody =>
      'SM64CDPY retirará este elemento de la Biblioteca, pero no borrará ningún archivo del juego.';

  @override
  String get libraryForgetConfirm => 'OLVIDAR';

  @override
  String get libraryRemoveHistoryAction => 'QUITAR DEL HISTORIAL';

  @override
  String get libraryRemoveHistoryTitle => '¿QUITAR ESTE EVENTO?';

  @override
  String get libraryRemoveHistoryBody =>
      'Solo se quitará esta entrada del historial. La instalación actual y los archivos del juego no cambiarán.';

  @override
  String get libraryRemoveHistoryConfirm => 'QUITAR';

  @override
  String get libraryMaintenanceError =>
      'No se pudo actualizar la Biblioteca. Inténtalo de nuevo.';

  @override
  String get detailOpenExternalFolder => 'ABRIR CARPETA DE ORIGEN';

  @override
  String get detailSourceUnavailable =>
      'Esta versión no tiene un archivo descargable disponible por ahora.';

  @override
  String get detailViewDiscussion => 'VER CONVERSACIÓN DE LA COMUNIDAD';

  @override
  String get settingsInterfaceTheme => 'Tema de interfaz';

  @override
  String get settingsInterfaceThemeDesc =>
      'Elige un diseño incluido. Se aplica a la app; el panel flotante conserva su diseño oscuro.';

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
  String get themeModeLight => 'Claro';

  @override
  String get themeModeDark => 'Oscuro';

  @override
  String get themeModeSystem => 'Seguir el sistema';

  @override
  String get themeSaveFailed =>
      'No se pudo guardar la apariencia. Inténtalo de nuevo.';

  @override
  String get themeSaving => 'Guardando apariencia';

  @override
  String get gameModsTitle => 'Mods del juego';

  @override
  String get gameModsSubtitle => 'Elige los mods para el próximo inicio';

  @override
  String get gameModsHint =>
      'Cierra el juego antes de cambiar opciones. Estos interruptores configuran mods Lua y packs DynOS/Touch Controls para el próximo inicio.';

  @override
  String get gameModsSelectHint =>
      'Selecciona la carpeta user del juego que contiene sm64config.txt y mods.';

  @override
  String get gameModsConfirm =>
      'Cierra primero el juego. ¿Aplicar esta selección para el próximo inicio?';

  @override
  String get gameModsCancel => 'Cancelar';

  @override
  String get gameModsApply => 'Aplicar';

  @override
  String get gameModsSelect => 'Seleccionar carpeta user';

  @override
  String get gameModsDisconnect => 'Desconectar';

  @override
  String get gameModsConflict =>
      'La configuración cambió o hay otro mod activado incompatible. Actualiza e inténtalo de nuevo.';

  @override
  String get gameModsBlocked =>
      'No se puede activar este mod con seguridad. Revisa su estructura y datos, o desactiva un mod incompatible.';

  @override
  String get gameModsMismatch =>
      'Esta carpeta user no corresponde a la carpeta de mods seleccionada. Elige la misma instalación del juego.';

  @override
  String get gameModsWriteError =>
      'No se pudo confirmar la escritura. Cierra el juego y restaura la configuración anterior si hace falta.';

  @override
  String get gameModsFormat =>
      'La configuración o carpeta supera los límites admitidos o tiene un formato no compatible. No se aplicó el cambio.';

  @override
  String get gameModsAccess =>
      'Configuración no disponible. Comprueba que user contiene sm64config.txt y mods, y vuelve a seleccionar la carpeta con acceso de lectura y escritura.';

  @override
  String get gameModsRestore => 'Restaurar configuración anterior';

  @override
  String get gameModsRestoreConfirm =>
      'Con el juego cerrado, ¿reemplazar la configuración por el respaldo privado anterior a la última edición? También restaura sus otros ajustes.';

  @override
  String get gameModsInstalling =>
      'Espera a que terminen las descargas e instalaciones antes de cambiar los mods del juego.';

  @override
  String get gameModsEmpty =>
      'No se encontraron mods Lua compatibles en las carpetas del juego.';

  @override
  String get gameModsEnabled => 'Activado para el próximo inicio';

  @override
  String get gameModsDisabled => 'Desactivado para el próximo inicio';

  @override
  String get gameModsMore => 'Mostrar más';

  @override
  String get gameModsSize =>
      'Este mod alcanza el límite de 35 MiB del juego y no se puede activar.';

  @override
  String get gameModsSaved =>
      'Selección guardada y verificada para el próximo inicio del juego.';

  @override
  String get gameModsManage => 'Gestionar carpeta del juego';

  @override
  String gameModsCount(int enabled, int total) {
    return '$enabled de $total activados';
  }

  @override
  String get gameModsSearch => 'Buscar mods, autores, categorías…';

  @override
  String get gameModsAll => 'Todos';

  @override
  String get gameModsEnabledFilter => 'Activados';

  @override
  String get gameModsDisabledFilter => 'Desactivados';

  @override
  String get gameModsNoResults =>
      'No hay mods que coincidan con la búsqueda o el filtro.';

  @override
  String get gameModsClearSearch => 'Borrar búsqueda';

  @override
  String get gameModsDetails => 'Detalles del mod';

  @override
  String get gameModsCloseDetails => 'Cerrar';

  @override
  String get marioRomTitle => 'Recursos del juego original';

  @override
  String get marioRomBuiltIn => 'ROM sin seleccionar';

  @override
  String get marioRomReady => 'Interfaz original lista';

  @override
  String get marioRomDescription =>
      'Los temas Mario usan la ROM de tu carpeta user conectada. Las imágenes y fuentes se preparan una vez en privado y después se reutilizan. No necesitas seleccionar la ROM por separado.';

  @override
  String get marioRomImport => 'Preparar desde la carpeta del juego';

  @override
  String get marioRomPreparing => 'Preparando recursos del juego…';

  @override
  String get marioRomCancel => 'Cancelar importación';

  @override
  String get marioRomRemove => 'Usar diseño incluido';

  @override
  String get marioRomUnsupported =>
      'Esta ROM no es compatible. Selecciona una ROM estadounidense .z64 sin modificar. Tu diseño anterior sigue disponible.';

  @override
  String get marioRomFailed =>
      'No se pudieron leer o guardar los recursos. Elige el archivo de nuevo y comprueba el espacio disponible. Tu diseño anterior sigue disponible.';

  @override
  String get marioRomSuccess => 'Los recursos del juego original están listos.';

  @override
  String get marioRomUpgrade =>
      'Elige la ROM de nuevo para actualizar la interfaz original';

  @override
  String get gameFolderTitle => 'Conectar SM64CoopDX';

  @override
  String get gameFolderSummary =>
      'Elige una vez la carpeta principal del juego para encontrar mods y packs DynOS dentro y fuera de user, además de la ROM para los temas Mario.';

  @override
  String get gameFolderGuide =>
      'Elige la carpeta principal com.maniscat2.sm64coopdx, la que contiene user. Buscaremos mods y dynos/packs tanto aquí como dentro de user. La configuración y la ROM permanecen en user; las instalaciones nuevas también van dentro de user. Selecciona la carpeta principal, no user ni un archivo.';

  @override
  String get gameFolderChoose => 'Elegir carpeta del juego';

  @override
  String get gameFolderLater => 'Ahora no';

  @override
  String get gameFolderConnected => 'Juego conectado';

  @override
  String get gameFolderResolved =>
      'Biblioteca: mods, user/mods, dynos/packs y user/dynos/packs. Instalaciones nuevas: user/mods y user/dynos/packs.';

  @override
  String get gameFolderConfigReady => 'Configuración de mods encontrada.';

  @override
  String get gameFolderConfigMissing =>
      'Abre el juego una vez para crear su configuración de mods. Las descargas y los temas siguen disponibles.';

  @override
  String get gameFolderRomFound =>
      'ROM del juego encontrada. Los temas Mario prepararán sus recursos al seleccionarlos.';

  @override
  String get gameFolderRomMissing =>
      'No encontramos una ROM compatible en user. Abre SM64CoopDX y configura su ROM; después vuelve a intentarlo.';

  @override
  String get gameFolderChange => 'Cambiar carpeta del juego';

  @override
  String get gameFolderInvalid =>
      'Elige la carpeta principal del juego que contiene user, normalmente com.maniscat2.sm64coopdx. Abre el juego una vez si su carpeta user aún no está preparada.';

  @override
  String get gameFolderAccessLost =>
      'La carpeta del juego no está disponible. Elígela de nuevo para reconectar.';

  @override
  String get gameFolderDisconnect => 'Desconectar juego';

  @override
  String get gameFolderDisconnectBody =>
      'Dejar de usar esta carpeta para mods, DynOS y detección de ROM. Los archivos del juego, mods instalados y recursos de temas preparados permanecerán en el dispositivo.';

  @override
  String get gameFolderPrepareTitle => 'Preparar tema Mario';

  @override
  String get gameFolderPrepareBody =>
      'Leeremos la ROM de la carpeta del juego conectada y prepararemos las imágenes y fuentes del tema. Se hace una sola vez; la ROM y la configuración del juego no se modifican.';

  @override
  String get gameFolderPrepare => 'Preparar tema';

  @override
  String get gameFolderBusy =>
      'Espera a que terminen las descargas e instalaciones antes de cambiar la carpeta del juego.';

  @override
  String get gameModsLuaType => 'Mods Lua';

  @override
  String get gameModsDynosType => 'DynOS / Touch Controls';

  @override
  String get gameFolderUpgrade =>
      'El acceso está limitado a user. Elige la carpeta principal del juego para incluir también los mods y packs DynOS fuera de user.';

  @override
  String get gameDynosEmpty =>
      'No se encontraron carpetas de packs DynOS / Touch Controls en las carpetas del juego.';

  @override
  String get gameDynosSearch => 'Buscar packs DynOS / Touch Controls…';

  @override
  String get navPlayer => 'Jugador';

  @override
  String get playerTitle => 'JUGADOR';

  @override
  String get playerCharacter => 'PERSONAJE';

  @override
  String get player3DLoading => 'Preparando tu personaje desde el juego…';

  @override
  String get player3DUnavailable =>
      'La vista 3D no está disponible. Comprueba que SM64CoopDX y una ROM estadounidense compatible estén conectados.';

  @override
  String get playerName => 'Nombre del jugador';

  @override
  String get playerNameHint => 'Nombre que aparecerá en SM64CoopDX';

  @override
  String get playerCloseGameHint =>
      'Cierra SM64CoopDX antes de aplicar. Los cambios se usarán en el próximo inicio.';

  @override
  String get playerPresets => 'PALETAS';

  @override
  String get playerParts => 'COLORES DEL PERSONAJE';

  @override
  String get playerUnsavedTitle => '¿Descartar cambios?';

  @override
  String get playerUnsavedBody =>
      'Los colores o el nombre del jugador todavía no se aplicaron al juego.';

  @override
  String get playerKeepEditing => 'Seguir editando';

  @override
  String get playerDiscard => 'Descartar';

  @override
  String get playerDeletePreset => '¿Eliminar paleta?';

  @override
  String playerDeletePresetBody(String name) {
    return '¿Eliminar tu paleta «$name»?';
  }

  @override
  String get playerCancel => 'Cancelar';

  @override
  String get playerDelete => 'Eliminar';

  @override
  String get playerConflict =>
      'La configuración del juego cambió. Vuelve a cargarla antes de aplicar el perfil.';

  @override
  String get playerInvalid =>
      'Introduce un nombre y colores válidos. El nombre no puede contener espacios y admite hasta 63 bytes UTF-8.';

  @override
  String get playerPresetExists => 'Ya existe una paleta con ese nombre.';

  @override
  String get playerAccessError =>
      'La configuración del jugador no está disponible. Revisa la carpeta conectada y su permiso.';

  @override
  String get playerSavePreset => 'Guardar paleta';

  @override
  String get playerPresetName => 'Nombre de la paleta';

  @override
  String get playerSave => 'Guardar';

  @override
  String playerOverwritePreset(String name) {
    return '¿Reemplazar tu paleta «$name»?';
  }

  @override
  String get playerOverwrite => 'Reemplazar';

  @override
  String get playerPresetSaved => 'Paleta guardada para SM64CoopDX.';

  @override
  String get playerApplied =>
      'Perfil guardado y verificado para el próximo inicio del juego.';

  @override
  String get playerConnectGame =>
      'Conecta la carpeta principal de SM64CoopDX para editar el jugador.';

  @override
  String get playerMissingConfig =>
      'Abre SM64CoopDX una vez para crear user/sm64config.txt.';

  @override
  String get playerRetry => 'Reintentar';

  @override
  String get playerHex => 'Color hexadecimal';

  @override
  String get playerRed => 'R';

  @override
  String get playerGreen => 'V';

  @override
  String get playerBlue => 'A';

  @override
  String get playerReset => 'Restablecer';

  @override
  String get playerApply => 'Aplicar al juego';

  @override
  String get playerPants => 'Overol';

  @override
  String get playerShirt => 'Camisa';

  @override
  String get playerGloves => 'Guantes';

  @override
  String get playerShoes => 'Zapatos';

  @override
  String get playerHair => 'Cabello';

  @override
  String get playerSkin => 'Piel';

  @override
  String get playerCap => 'Gorra';

  @override
  String get playerEmblem => 'Emblema';

  @override
  String get playerRestore => 'Restaurar configuración anterior';

  @override
  String get playerRestoreBody =>
      'Con SM64CoopDX cerrado, ¿restaurar el respaldo privado anterior al último cambio de mods o jugador? Se restaurará toda la configuración.';

  @override
  String get playerRestored => 'Configuración anterior del juego restaurada.';

  @override
  String get retroAccentTitle => 'Acento de interfaz';

  @override
  String get retroAccentDescription =>
      'Elige el color destacado de Retro Manga o Mario Kart 64. MK64 también coordina el fondo, los paneles y la cuadrícula de carrera.';

  @override
  String get retroAccentCyan => 'Cian';

  @override
  String get retroAccentBlue => 'Azul';

  @override
  String get retroAccentViolet => 'Violeta';

  @override
  String get retroAccentPink => 'Rosa';

  @override
  String get retroAccentCoral => 'Coral';

  @override
  String get retroAccentAmber => 'Ámbar';

  @override
  String get retroAccentGreen => 'Verde';

  @override
  String get retroAccentLime => 'Lima';

  @override
  String get gameToolTitle => 'Herramientas';

  @override
  String get saveFileTitle => 'Partidas';

  @override
  String get saveFileHint => 'Elige una partida · juego original';

  @override
  String get saveFileConfirm =>
      'Cierra SM64CoopDX primero. Los cambios se aplican al volver a abrirlo. Copiar y borrar afectan el progreso normal y el alternativo de la partida elegida. Restaurar reemplaza las cuatro partidas. Se guarda un respaldo completo antes de escribir.';

  @override
  String get saveFileDone => 'Guardado';

  @override
  String get saveFileMissing =>
      'Conecta la carpeta del juego e inicia el juego una vez para crear su partida.';

  @override
  String get saveFileError =>
      'No se pudo verificar o guardar el archivo. Actualiza e inténtalo de nuevo; las copias de recuperación se conservan en Respaldos.';

  @override
  String get saveFilePrimary => 'Normal';

  @override
  String get saveFileAlternate => 'Alternativo';

  @override
  String get saveFileEmpty => 'Vacía';

  @override
  String get saveFileUnsigned => 'Copia sin firma o dañada';

  @override
  String get saveFileCopy => 'Copiar';

  @override
  String get saveFileProgress => 'Progreso';

  @override
  String get saveFileBackup => 'Crear respaldo';

  @override
  String get saveFileBackups => 'Respaldos';

  @override
  String get saveFileCannon => 'Cañón';

  @override
  String get saveFileCoins => 'Monedas';

  @override
  String get saveFileCastle => 'Estrellas del castillo';

  @override
  String get saveFileUnlocks => 'Desbloqueos';

  @override
  String get saveFileWing => 'Gorra alada';

  @override
  String get saveFileMetal => 'Gorra metálica';

  @override
  String get saveFileVanish => 'Gorra invisible';

  @override
  String get saveFileKey1 => 'Primera llave';

  @override
  String get saveFileKey2 => 'Segunda llave';

  @override
  String get saveFileBasement => 'Puerta del sótano';

  @override
  String get saveFileUpstairs => 'Puerta de la planta superior';

  @override
  String get saveFileMoat => 'Vaciar foso';

  @override
  String get saveFileComplete => 'Completar progreso: 120 estrellas';

  @override
  String get saveFileClearStars => 'Quitar estrellas';

  @override
  String get saveFileCourseNames =>
      'Campo de los Bob-omb|Fortaleza de Whomp|Bahía del Capitán|Montaña helada|Mansión encantada|Cueva laberíntica|Tierra de lava|Desierto cambiante|Muelles sombríos|País de nieve|Ciudad acuática|Montaña alta|Isla cambiante|Reloj|Camino del arcoíris|Bowser en el mundo oscuro|Bowser en el mar de fuego|Bowser en el cielo|Tobogán secreto de la princesa|Caverna de la gorra de metal|Torre de la gorra alada|Gorra invisible bajo el foso|Mario alado sobre el arcoíris|Acuario secreto';

  @override
  String get saveFileCopies => 'Progreso del juego';

  @override
  String get saveFileCopiesHint =>
      'Normal es el progreso habitual de tu partida. Algunos mods usan Alternativo para modos especiales, como el modo difícil. No es un respaldo. Elegirlo aquí no cambia el progreso que utiliza el juego.';

  @override
  String get saveFileOpenSlot => 'Toca para editar';

  @override
  String get saveFileActions => 'Acciones de partida';

  @override
  String get saveFileDraft => 'Vista previa · se guarda al aplicar';

  @override
  String get drawerResources => 'Recursos';

  @override
  String get fastInstallTitle => 'Activar instalación rápida';

  @override
  String get fastInstallDescription =>
      'Opcional: permite el acceso a todos los archivos en Android para acelerar la instalación en carpetas compatibles del juego. Sin él, puedes seguir instalando normalmente.';

  @override
  String get fastInstallAccessError =>
      'No se pudieron abrir los permisos. Puedes seguir instalando normalmente.';

  @override
  String get playGuideTitle => 'Cómo jugar';

  @override
  String get playGuideIntro =>
      'Tu primera aventura, paso a paso. Primero prepara el juego y después trae tus mods aquí.';

  @override
  String get playGuideNext => 'Siguiente paso';

  @override
  String get playGuideBack => 'Paso anterior';

  @override
  String get playGuideOpenDownload => 'Abrir descargas de Android';

  @override
  String get playGuideRepository => 'Repositorio del port Android';

  @override
  String get playGuideConnect => 'Conectar carpeta del juego';

  @override
  String get playGuideLibrary => 'Abrir Biblioteca';

  @override
  String get playGuideLaunch => 'Abrir el juego';

  @override
  String get playGuideMissingTitle => 'Vamos a preparar tu juego';

  @override
  String get playGuideMissingBody =>
      'SM64CoopDX Android no está instalado. Sigue la guía para instalarlo, preparar tu ROM y conectar tus mods.';

  @override
  String get playGuideRead => 'Ver guía de inicio';

  @override
  String get playGuideLater => 'Ahora no';

  @override
  String get playGuideLinkError =>
      'No se pudo abrir la página. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get playGuideLaunchError =>
      'El juego está instalado, pero Android no pudo abrirlo. Prueba desde su icono en la pantalla de inicio.';

  @override
  String get playGuideInstalled => 'Juego instalado';

  @override
  String get playGuideNotInstalled => 'Todavía no detectamos el juego';

  @override
  String get playGuideConnected => 'Carpeta del juego conectada';

  @override
  String get playGuideNotConnected => 'Carpeta del juego sin conectar';

  @override
  String get playGuideReady =>
      '¡Tu aventura te espera! Puedes volver a cualquier paso cuando lo necesites.';

  @override
  String get playGuideStep1Title => 'Consigue el juego';

  @override
  String get playGuideStep2Title => 'Prepara tu propia ROM';

  @override
  String get playGuideConvertTitle => 'Convertir mi ROM (.n64 / .v64)';

  @override
  String get playGuideStep3Title => 'Dale la ROM al juego';

  @override
  String get playGuideStep4Title => 'Conecta el manager';

  @override
  String get playGuideStep5Title => 'Añade tu primer mod';

  @override
  String get playGuidePathsTitle => '¿Dónde va cada cosa?';

  @override
  String get playGuideStep6Title => 'Juega y encuentra ayuda';

  @override
  String get playGuideMap => 'El mapa de tu aventura';

  @override
  String get playGuideSwipe => 'Desliza a los lados para cambiar de capítulo';

  @override
  String get playGuideChapter => 'CAPÍTULO';

  @override
  String get playGuideTip => 'Recuerda';

  @override
  String get playGuideOverview => 'Ver pasos';

  @override
  String get playGuideS1Card1 =>
      'SM64CDPY organiza mods. SM64CoopDX Android es otra aplicación: la que ejecuta el juego.';

  @override
  String get playGuideS1Card2 =>
      'Pulsa Abrir descargas de Android. Tu navegador abrirá GitHub, la página del port Android.';

  @override
  String get playGuideS1Card3 =>
      'Busca la versión y despliega Assets si hace falta. Descarga el archivo que termina en .apk, no Source code. Si hay varias opciones, sigue los requisitos para tu teléfono de esa versión.';

  @override
  String get playGuideS1Card4 =>
      'Abre el APK descargado y pulsa Instalar. Si Android lo pide, permite que ese navegador o explorador instale este APK y vuelve a la instalación.';

  @override
  String get playGuideS1Card5 =>
      'Abre SM64CoopDX una vez. Sigue sus indicaciones de almacenamiento para que cree su carpeta.';

  @override
  String get playGuideS1Card6 =>
      'Si no entiendes un aviso de Android, pide ayuda a alguien de confianza.';

  @override
  String get playGuideS2Card1 =>
      'La ROM es una copia del cartucho original de Super Mario 64. El APK por sí solo no incluye las imágenes y los sonidos originales del juego.';

  @override
  String get playGuideS2Card2 =>
      'Usa tu propia copia original de USA, sin modificar y en formato .z64. Esta guía no proporciona ROMs. Un ZIP es un paquete: extráelo primero para ver el archivo que contiene.';

  @override
  String get playGuideS2Card3 =>
      '¿Ya termina en .z64? Continúa al siguiente paso.';

  @override
  String get playGuideS2Card4 =>
      '¿Termina en .n64 o .v64? Abre «Convertir mi ROM» aquí abajo.';

  @override
  String get playGuideS2Card5 =>
      '¿Es de otra región o está modificada? Cambiar su nombre o formato no la convierte en una copia original de USA.';

  @override
  String get playGuideS3Card1 => 'Abre SM64CoopDX Android.';

  @override
  String get playGuideS3Card2 =>
      'Si te pide elegir una ROM, selecciona tu archivo .z64 de USA, normalmente en Descargas. Espera a que el juego termine de prepararlo.';

  @override
  String get playGuideS3Card3 =>
      'Si tu versión no tiene selector, cierra el juego. En tu explorador de archivos, copia el .z64 a Almacenamiento interno → com.maniscat2.sm64coopdx → user. Abre el juego de nuevo.';

  @override
  String get playGuideS3Card4 =>
      'Espera hasta llegar al menú del juego. Si rechaza la ROM, revisa que sea la original de USA, sin modificar, y que esté convertida de verdad a .z64.';

  @override
  String get playGuideS3Card5 =>
      'El juego conserva la ROM de USA aceptada como user/baserom.us.z64. La carpeta puede variar según sus permisos de almacenamiento; sigue la ubicación que te muestre el juego.';

  @override
  String get playGuideS4Card1 =>
      'Vuelve a SM64CDPY y pulsa Conectar carpeta del juego. Antes de abrir la ventana de carpetas de Android, explicaremos qué debes elegir.';

  @override
  String get playGuideS4Card2 =>
      'Abre Almacenamiento interno → com.maniscat2.sm64coopdx.';

  @override
  String get playGuideS4Card3 =>
      'Selecciona esa carpeta principal, la que contiene user, y pulsa Usar esta carpeta / Permitir. No elijas Descargas, user sola ni el archivo ROM.';

  @override
  String get playGuideS4Card4 =>
      'Una sola selección conecta mods, DynOS, ajustes del juego y detección de ROM. Si falta user, abre y prepara primero el juego. Si Android bloquea el acceso, revisa el almacenamiento del juego: elegir una carpeta vacía diferente no lo arregla.';

  @override
  String get playGuideS4Card5 =>
      '¿Ya está conectada? Continúa. No necesitas elegir las mismas carpetas para cada mod.';

  @override
  String get playGuideS5Card1 =>
      'Cierra el juego antes de instalar o cambiar mods.';

  @override
  String get playGuideS5Card2 =>
      'Abre Catálogo y elige un mod. Lee sus notas de compatibilidad.';

  @override
  String get playGuideS5Card3 =>
      'Descárgalo. Con instalación automática activada, espera a ver Instalado: terminar la descarga no significa que termine la instalación. Si la instalación automática está desactivada, sigue el aviso de instalación manual o actívala en Ajustes.';

  @override
  String get playGuideS5Card4 =>
      'Abre Herramientas → Biblioteca. Mods del juego reúne los mods Lua. DynOS / Touch Controls reúne modelos, texturas y controles. Activa el elemento que quieras usar.';

  @override
  String get playGuideS5Card5 =>
      'Abre de nuevo el juego para cargar los cambios. Algunos packs requieren sus propios ajustes dentro del juego: sigue las instrucciones de su autor.';

  @override
  String get playGuideS6Card1 =>
      'Pulsa Abrir el juego aquí abajo. Elige una partida dentro del juego y disfruta de tu aventura.';

  @override
  String get playGuideS6Card2 =>
      '¿El juego no abre? Prueba primero desde su icono en el inicio de Android.';

  @override
  String get playGuideS6Card3 =>
      '¿No acepta la ROM? Revisa la copia original de USA y el formato .z64 en el paso 2.';

  @override
  String get playGuideS6Card4 =>
      '¿No aparece el mod? Comprueba que terminó la instalación, actívalo en Biblioteca y reinicia el juego. Revisa si necesita otro mod.';

  @override
  String get playGuideS6Card5 =>
      '¿Perdiste el acceso a la carpeta? Reconecta la carpeta principal en el paso 4.';

  @override
  String get playGuideS6Card6 =>
      'Prueba un mod a la vez. Si algo falla, desactiva ese mod y vuelve a abrir el juego. Guarda un respaldo antes de borrar archivos del juego.';

  @override
  String get playGuideConvertCard1 =>
      'Conserva el archivo original como respaldo.';

  @override
  String get playGuideConvertCard2 =>
      'Abre el conversor de ROM en tu navegador.';

  @override
  String get playGuideConvertCard3 => 'Elige tu archivo .n64 o .v64.';

  @override
  String get playGuideConvertCard4 =>
      'Selecciona .z64 como formato de salida y guarda el resultado, normalmente en Descargas.';

  @override
  String get playGuideConvertCard5 =>
      'Regresa aquí y continúa con ese archivo .z64.';

  @override
  String get playGuideConvertCard6 =>
      'Convertir reorganiza los datos del archivo. Cambiar el nombre de .n64 a .z64 no lo convierte. Es una herramienta externa: si no está disponible, usa otro conversor de orden de bytes de N64 con salida .z64.';

  @override
  String get playGuidePathsCard1 =>
      'Dentro de Almacenamiento interno → com.maniscat2.sm64coopdx:';

  @override
  String get playGuidePathsCard2 =>
      'user/mods → nuevas instalaciones de mods Lua. Un mod puede ser un archivo .lua o una carpeta con main.lua.';

  @override
  String get playGuidePathsCard3 =>
      'user/dynos/packs → nuevos packs DynOS y Touch Controls. Touch Controls comparte este destino.';

  @override
  String get playGuidePathsCard4 =>
      'user/baserom.us.z64 → ROM original de USA aceptada por el juego.';

  @override
  String get playGuidePathsCard5 =>
      'user/sm64config.txt → ajustes del juego y elementos activados. Deja que la app lo gestione en vez de editarlo a mano.';

  @override
  String get playGuidePathsCard6 =>
      'El juego también lee mods y dynos/packs fuera de user. El manager también los muestra al conectar la carpeta principal. Si repites nombres, Lua prefiere user/mods; DynOS prefiere dynos/packs exterior. Evita mantener dos copias con el mismo nombre.';

  @override
  String get playGuideS1Title1 => 'Dos apps, dos tareas';

  @override
  String get playGuideS1Title2 => 'Abre la página de Android';

  @override
  String get playGuideS1Title3 => 'Elige el APK';

  @override
  String get playGuideS1Title4 => 'Instala el juego';

  @override
  String get playGuideS1Title5 => 'Ábrelo una vez';

  @override
  String get playGuideS1Title6 => 'Una mano amiga';

  @override
  String get playGuideS2Title1 => '¿Qué es una ROM?';

  @override
  String get playGuideS2Title2 => 'La copia que necesitas';

  @override
  String get playGuideS2Title3 => 'Ya tengo .z64';

  @override
  String get playGuideS2Title4 => 'Tengo .n64 o .v64';

  @override
  String get playGuideS2Title5 => 'La región importa';

  @override
  String get playGuideS3Title1 => 'Abre SM64CoopDX';

  @override
  String get playGuideS3Title2 => 'Elige tu ROM';

  @override
  String get playGuideS3Title3 => 'Si no aparece un selector';

  @override
  String get playGuideS3Title4 => 'Llega al menú del juego';

  @override
  String get playGuideS3Title5 => 'El hogar de tu ROM';

  @override
  String get playGuideS4Title1 => 'Vuelve al manager';

  @override
  String get playGuideS4Title2 => 'Busca la carpeta principal';

  @override
  String get playGuideS4Title3 => 'Permite usar esa carpeta';

  @override
  String get playGuideS4Title4 => 'Una sola conexión';

  @override
  String get playGuideS4Title5 => '¿Ya está conectada?';

  @override
  String get playGuideS5Title1 => 'Primero cierra el juego';

  @override
  String get playGuideS5Title2 => 'Elige un mod';

  @override
  String get playGuideS5Title3 => 'Espera la instalación';

  @override
  String get playGuideS5Title4 => 'Actívalo en Biblioteca';

  @override
  String get playGuideS5Title5 => 'Reinicia y pruébalo';

  @override
  String get playGuideS6Title1 => 'Empieza tu aventura';

  @override
  String get playGuideS6Title2 => 'El juego no abre';

  @override
  String get playGuideS6Title3 => 'No acepta la ROM';

  @override
  String get playGuideS6Title4 => 'No aparece el mod';

  @override
  String get playGuideS6Title5 => 'Perdiste el acceso';

  @override
  String get playGuideS6Title6 => 'Prueba uno a la vez';

  @override
  String get romPrepareNav => 'Preparar ROM';

  @override
  String get romPrepareTitle => 'Prepara tu ROM';

  @override
  String get romPrepareDescription =>
      'Elige tu propio archivo de Super Mario 64. La aplicación crea y verifica una copia .z64 compatible sin modificar el original.';

  @override
  String get romPreparePrivacy =>
      'SM64CDPY no incluye, descarga ni comparte ROMs. El archivo se procesa localmente en tu dispositivo.';

  @override
  String get romPrepareChoose => 'Elegir ROM';

  @override
  String get romPrepareChooseAnother => 'Elegir otro archivo';

  @override
  String get romPrepareAnother => 'Preparar otra ROM';

  @override
  String get romPrepareSave => 'Guardar copia .z64';

  @override
  String get romPrepareContinue => 'Continuar con la guía';

  @override
  String get romPrepareCancel => 'Cancelar';

  @override
  String get romPrepareIdle => 'Listo para comprobar tu archivo';

  @override
  String get romPreparePicking => 'Elige tu archivo en Android';

  @override
  String get romPrepareInspecting => 'Comprobando el archivo seleccionado';

  @override
  String get romPrepareConverting => 'Preparando una copia compatible';

  @override
  String get romPrepareValidating => 'Verificando la ROM preparada';

  @override
  String get romPrepareReady => 'ROM compatible lista';

  @override
  String get romPrepareAlreadyCompatible =>
      'Tu ROM ya estaba en el formato correcto';

  @override
  String get romPrepareChoosingDestination => 'Elige dónde guardar la copia';

  @override
  String get romPrepareExporting => 'Guardando tu copia';

  @override
  String get romPrepareVerifyingExport => 'Verificando la copia guardada';

  @override
  String get romPrepareSaved => 'Copia guardada y verificada';

  @override
  String get romPrepareCancelling => 'Deteniendo de forma segura';

  @override
  String get romPrepareCancelled => 'Preparación cancelada';

  @override
  String get romPrepareFailed => 'No se pudo preparar la ROM';

  @override
  String romPrepareDetected(String format) {
    return 'Formato detectado: $format';
  }

  @override
  String romPrepareSavedAs(String name) {
    return 'Guardada como $name';
  }

  @override
  String get romPrepareErrorUnrecognized =>
      'El archivo no tiene un formato de ROM de N64 reconocido.';

  @override
  String get romPrepareErrorSize =>
      'La ROM original de Super Mario 64 debe medir exactamente 8 MiB.';

  @override
  String get romPrepareErrorIncompatible =>
      'Necesitas una ROM original sin modificar de Super Mario 64 USA.';

  @override
  String get romPrepareErrorPermission =>
      'Android ya no permite acceder a ese archivo. Elígelo nuevamente.';

  @override
  String get romPrepareErrorStorage =>
      'No hay almacenamiento suficiente o no se pudo leer el archivo.';

  @override
  String get romPrepareErrorExport =>
      'No se pudo verificar la copia guardada. Elige otro destino e inténtalo de nuevo.';

  @override
  String get romPrepareErrorBusy => 'Ya hay otra operación de ROM activa.';

  @override
  String get romPrepareErrorUnexpected =>
      'Ocurrió algo inesperado. Tu archivo original no fue modificado.';

  @override
  String get mangaNavLibrary => 'Mis Mods';

  @override
  String get mangaNavExplore => 'Mods';

  @override
  String get mangaMenuLabel => 'Menú';

  @override
  String get mangaMenuOpen => 'Abrir menú';

  @override
  String get mangaMenuClose => 'Cerrar menú';

  @override
  String get mangaNavTools => 'Taller';

  @override
  String get mangaNavMore => 'MAS';

  @override
  String get mangaNavPlay => 'Jugar';

  @override
  String get mangaNavHint => 'Desliza para explorar. Toca para abrir.';

  @override
  String get mangaNavError =>
      'No se pudo completar la acción. Inténtalo de nuevo.';

  @override
  String get mangaMenuSoundsTitle => 'Sonidos del menú';

  @override
  String get mangaMenuSoundsDescription =>
      'Efectos al abrir, seleccionar y deslizar el menú.';

  @override
  String get appEffectsVolume => 'Volumen de efectos';

  @override
  String get appEffectsVolumeDescription =>
      'Ajusta solo los efectos de esta app. El volumen multimedia del teléfono sigue siendo el límite.';

  @override
  String get ambientMusicTitle => 'Música ambiental';

  @override
  String get ambientMusicDescription =>
      'Una pista suave mientras usas Retro Manga. Se pausa al salir de la app.';

  @override
  String get ambientMusicVolume => 'Volumen de música';

  @override
  String get mangaNavAudio => 'Audio';

  @override
  String get themeMangaDeluxe => 'Manga Deluxe';

  @override
  String get deluxeWelcome => 'Bienvenido a CoopDX';

  @override
  String get deluxeWelcomeBody =>
      'Tu compañero de mods en Android: prepara el juego, descubre mods y encuentra la comunidad de CoopDX.';

  @override
  String get deluxeSpotlight => 'De la selección de CoopDX';

  @override
  String get deluxeDncBody =>
      'Cielos, iluminación y un ciclo completo de día y noche. Mira el mod en acción antes de explorar sus detalles.';

  @override
  String get deluxeViewMod => 'Ver mod';

  @override
  String get deluxeWatchDemo => 'Ver demostración';

  @override
  String get deluxeDemoHint =>
      'Abre el vídeo oficial fuera de la app. Requiere internet.';

  @override
  String get deluxeLinkError =>
      'No se pudo abrir el enlace. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get deluxeHelpTitle => 'Ayuda rápida';

  @override
  String get deluxeFaqRom => '¿Qué ROM necesito?';

  @override
  String get deluxeFaqRomAnswer =>
      'Usa tu propio volcado USA verificado en formato .z64. El Preparador de ROM puede convertir una copia sin cambiar el original.';

  @override
  String get deluxeFaqFolders => '¿Qué carpeta selecciono?';

  @override
  String get deluxeFaqFoldersAnswer =>
      'Usa Conectar carpeta del juego. La guía explica qué ubicación seleccionar y el gestor detecta los mods y packs compatibles.';

  @override
  String get deluxeFaqPacks => '¿Mods del juego o DynOS?';

  @override
  String get deluxeFaqPacksAnswer =>
      'Los mods Lua cambian el comportamiento del juego. Los packs DynOS aportan modelos, texturas y Touch Controls. Adminístralos desde sus secciones separadas en Biblioteca.';

  @override
  String get deluxeOpenGuide => 'Abrir';

  @override
  String get deluxeCommunity => 'Comunidad y enlaces';

  @override
  String get deluxeGameNews => 'Novedades del juego Android';

  @override
  String get deluxeMotion => 'Fondo en movimiento';

  @override
  String get deluxeMotionHint =>
      'Desplazamiento opcional de gorros y patrón. Déjalo apagado para ahorrar batería.';

  @override
  String get deluxeReducedMotion =>
      'El movimiento está pausado por tus ajustes de accesibilidad.';

  @override
  String get deluxeReset => 'Restablecer diseño y audio Deluxe';

  @override
  String get deluxeResetDone => 'Diseño y audio Deluxe restablecidos.';

  @override
  String get deluxeMusicDescription =>
      'Una pista suave para Manga Deluxe. Se pausa al salir de la app.';

  @override
  String get deluxeAccentDescription =>
      'Elige los acentos y el color del patrón de fondo de Manga Deluxe.';

  @override
  String get deluxeResetHint =>
      'Restaura el acento y el audio compartidos. Conserva tus carpetas, mods y partidas.';

  @override
  String get deluxeWelcomeCompact =>
      '¿Primera vez? Prepara el juego con nuestra guía.';

  @override
  String get deluxeSkip => 'Omitir';

  @override
  String get deluxeSkipHint =>
      'Ocultar esta introducción. La guía seguirá en el menú.';

  @override
  String get coopTitle => 'Jugar con amigos';

  @override
  String get coopNav => 'Jugar';

  @override
  String get coopIntro =>
      'Crea una sala privada o únete con el código de tu amigo. El asistente conecta SM64CoopDX por internet mientras el juego usa su Conexión directa local.';

  @override
  String get coopPrivacy =>
      'El código de sala es un secreto compartido. La señalización usa el servicio compatible de Cloudflare; el tráfico del juego se conecta directamente cuando es posible y usa TURN solo cuando hace falta.';

  @override
  String get coopConsentTitle => 'Privacidad de red';

  @override
  String get coopConsentIntro =>
      'Antes de crear o unirte a una sala, revisa cómo funciona la conexión.';

  @override
  String get coopConsentEncrypted =>
      'El código de sala deriva la clave que cifra la señalización WebRTC. Compártelo solo con personas de confianza.';

  @override
  String get coopConsentIp =>
      'Tu dirección de internet puede ser visible para el amigo invitado y para los servicios de búsqueda de dirección de Google y Cloudflare.';

  @override
  String get coopConsentThirdParty =>
      'La señalización y el relay usan un servicio compatible de Cloudflare operado por terceros. Su disponibilidad y retención dependen de ese servicio.';

  @override
  String get coopConsentAccept => 'Entiendo y quiero continuar';

  @override
  String get coopConsentCancel => 'Ahora no';

  @override
  String get coopConsentReview => 'Revisar privacidad de red';

  @override
  String get coopConsentSaveError =>
      'No se pudo guardar tu elección. No se inició ninguna sesión de red.';

  @override
  String get coopCreate => 'Crear partida';

  @override
  String get coopJoin => 'Unirse a partida';

  @override
  String get coopCode => 'Código de amigo';

  @override
  String get coopCodeHint => 'ABCD-1234';

  @override
  String get coopRecent => 'Códigos recientes';

  @override
  String get coopClearRecent => 'Borrar';

  @override
  String get coopWaiting => 'Esperando amigos';

  @override
  String get coopConnecting => 'Buscando a tu amigo';

  @override
  String get coopConnected => 'Partida conectada';

  @override
  String get coopReconnecting => 'Reconectando';

  @override
  String get coopPreparing => 'Preparando sala segura';

  @override
  String get coopStop => 'Detener partida';

  @override
  String get coopOpenGame => 'Abrir SM64CoopDX';

  @override
  String get coopGameMissing =>
      'SM64CoopDX no está instalado en este dispositivo.';

  @override
  String get coopGameReady => 'SM64CoopDX detectado';

  @override
  String get coopHostInstruction =>
      'En el juego abre Multijugador > Conexión directa > Host. Tus amigos se unen con el código mostrado aquí.';

  @override
  String coopJoinInstruction(int port) {
    return 'En el juego abre Multijugador > Conexión directa y conéctate a 127.0.0.1 usando el puerto $port.';
  }

  @override
  String get coopCopy => 'Copiar código';

  @override
  String get coopCopied => 'Código copiado';

  @override
  String get coopShare => 'Compartir invitación';

  @override
  String get coopShareSubject => 'Invitación a partida de SM64CoopDX';

  @override
  String coopShareMessage(String code) {
    return '¡Únete a mi partida de SM64CoopDX!\n\nCódigo de amigo: $code\n\nAbre SM64CDPY, entra en Jugar, pulsa Unirse a partida y escribe este código. Compártelo solo con personas de confianza.';
  }

  @override
  String get coopShareError =>
      'No se pudo compartir la invitación. Intenta copiar el código.';

  @override
  String coopPeers(int count) {
    return 'Amigos: $count';
  }

  @override
  String get coopDirect => 'Directa';

  @override
  String get coopRelay => 'Relay';

  @override
  String get coopNoCode => 'Ingresa un código válido de ocho caracteres.';

  @override
  String get coopNetworkError =>
      'No se pudo iniciar la partida. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get coopBatteryTitle => 'Conexión en segundo plano';

  @override
  String get coopBatteryDescription =>
      'Opcional: permite uso de batería sin restricciones para reducir el riesgo de que Android pause la partida mientras el juego está abierto.';

  @override
  String get coopBatteryAllowed =>
      'El uso de batería sin restricciones está permitido. Android podrá mantener la partida activa con mayor fiabilidad.';

  @override
  String get coopBatteryAllow => 'Permitir en Android';

  @override
  String get coopBatteryManage => 'Administrar en Android';

  @override
  String get coopBatteryOpenError =>
      'No se pudieron abrir los ajustes de batería de Android en este dispositivo.';

  @override
  String get coopDiagnosticsTitle => 'Diagnóstico de conexión';

  @override
  String coopDiagnosticsSignal(int count) {
    return 'Conexiones de señalización: $count';
  }

  @override
  String coopDiagnosticsPackets(int toGame, int toPage) {
    return 'Paquetes del juego: $toGame recibidos · $toPage enviados';
  }

  @override
  String coopDiagnosticsDelay(int average, int max) {
    return 'Demora del puente: $average ms promedio · $max ms máxima';
  }

  @override
  String get homeCardSoundsTitle => 'Sonidos de tarjetas de Inicio';

  @override
  String get homeCardSoundsDescription =>
      'Sonido al cambiar tarjetas de Destacados o Explorar. Independiente del menú y la música.';

  @override
  String get homeCardSoundsVolume => 'Volumen de tarjetas';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageSaveFailed =>
      'No se pudo guardar el idioma. Inténtalo de nuevo.';

  @override
  String get sharedCopyDetails => 'Copiar detalles';

  @override
  String get sharedCopied => 'Copiado al portapapeles';

  @override
  String sharedAuthor(String author) {
    return 'Autor: $author';
  }

  @override
  String get sharedUntitled => 'Sin título';

  @override
  String get render96Required => 'NECESARIO';

  @override
  String get render96Optional => 'OPCIONAL';

  @override
  String get render96Skinpack => 'PACK DE MODELOS';

  @override
  String get settingsExportFailed =>
      'No se pudieron exportar tus favoritos. Inténtalo de nuevo.';

  @override
  String get settingsImportFailed =>
      'No se pudo importar este archivo. Elige un archivo de favoritos exportado por SM64CDPY.';

  @override
  String get settingsDatabaseFailed =>
      'No se pudo actualizar el catálogo. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get updateActionFailed =>
      'No se pudo completar la actualización. Inténtalo de nuevo o descárgala desde el navegador.';

  @override
  String get render96WatchTrailer => 'VER TRÁILER';

  @override
  String get render96CategoryOther => 'CONTENIDO';

  @override
  String get coopConnectionFailed =>
      'La partida no pudo continuar. Revisa tu conexión e iníciala de nuevo.';

  @override
  String get catalogLoadFailed =>
      'No se pudo cargar este contenido. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get settingsFavouritesShareSubject => 'Favoritos de SM64CoopDX';

  @override
  String get favEmptyActionHint => 'Toca ♥ en una tarjeta para guardarla aquí.';

  @override
  String get guidedSetupWelcomeTitle => 'Bienvenido';

  @override
  String get guidedSetupWelcomeBody =>
      '¡Qué gusto verte por aquí! Preparemos juntos tu aventura de mods. Tú siempre tendrás el control y los accesos opcionales pueden esperar hasta que los necesites.';

  @override
  String guidedSetupProgress(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get guidedSetupStart => 'Iniciar';

  @override
  String get guidedSetupLater => 'Más tarde';

  @override
  String get guidedSetupAudioTitle => 'Sonido de la aplicación';

  @override
  String get guidedSetupAudioBody =>
      '¿Quieres disfrutar música ambiental y efectos mientras exploras tus mods? Después podrás ajustar la música y los efectos por separado en Ajustes.';

  @override
  String get guidedSetupAudioOn => 'Con sonido';

  @override
  String get guidedSetupAudioOff => 'Modo silencioso';

  @override
  String get guidedSetupAudioSaveError =>
      'No se pudo guardar tu preferencia de sonido. Inténtalo de nuevo.';

  @override
  String get guidedSetupDoneTitle => 'Todo listo';

  @override
  String get guidedSetupDoneBody =>
      'La configuración básica terminó. Los accesos opcionales seguirán disponibles en Ajustes cuando una función los necesite.';

  @override
  String get guidedSetupFinish => 'Finalizar';

  @override
  String get permissionCenterTitle => 'Permisos y accesos';

  @override
  String get permissionCenterSubtitle =>
      'Revisa qué puede usar la app y por qué';

  @override
  String get permissionCenterIntro =>
      'Concede acceso solo cuando entiendas su finalidad. Los accesos opcionales se solicitan en contexto y la app consulta su estado actual en Android.';

  @override
  String get permissionStatusAllowed => 'Permitido';

  @override
  String get permissionStatusNotAllowed => 'No permitido';

  @override
  String get permissionStatusOptional => 'Opcional · verificando estado';

  @override
  String get permissionManage => 'Administrar';

  @override
  String get permissionFolderDescription =>
      'Permite encontrar, instalar y administrar mods y archivos del jugador en la carpeta del juego que elijas.';

  @override
  String get permissionNotificationsDescription =>
      'Muestra el progreso de descargas e instalaciones. Solo se solicita cuando una descarga lo necesita.';

  @override
  String get permissionAllFilesDescription =>
      'Instalación rápida opcional en dispositivos Android compatibles. El acceso por carpeta sigue funcionando sin este permiso.';

  @override
  String get permissionOverlayDescription =>
      'Burbuja flotante opcional de descargas sobre otras aplicaciones.';

  @override
  String get permissionBatteryDescription =>
      'Opcional para mantener sesiones de Jugar más largas cuando la app está en segundo plano.';

  @override
  String get permissionUpdatesTitle => 'Instalar actualizaciones';

  @override
  String get permissionUpdatesDescription =>
      'Android solicita este acceso especial solo cuando decides instalar una actualización de la app.';

  @override
  String get permissionNetworkTitle => 'Red y Jugar';

  @override
  String get permissionNetworkDescription =>
      'Internet permite consultar el catálogo y usar sesiones en línea. Jugar pide consentimiento explícito antes de conectarse a su servicio.';

  @override
  String get permissionRunGuide => 'Repetir recorrido guiado';

  @override
  String get permissionRunGuideDescription =>
      'Vuelve a mostrar la bienvenida sin cambiar por sí solo ningún permiso de Android.';
}
