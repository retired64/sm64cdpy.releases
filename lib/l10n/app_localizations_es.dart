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
    return 'Descarga e instalación iniciadas: $name';
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
  String get disclaimerAppSubtitle => 'SM64CoopDX Mods Manager';

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
  String get retroAccentTitle => 'Acento de Retro Manga';

  @override
  String get retroAccentDescription =>
      'Elige el color de los elementos destacados. El contraste del texto se adapta al modo claro y oscuro. Los demás temas conservan sus colores.';

  @override
  String get retroAccentCyan => 'Cian (original)';

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
      'Cierra SM64CoopDX primero. Los cambios se aplican al volver a abrirlo. Copiar y borrar afectan ambas copias de la ranura. Restaurar reemplaza las cuatro ranuras. Se guarda un respaldo completo antes de escribir.';

  @override
  String get saveFileDone => 'Guardado';

  @override
  String get saveFileMissing =>
      'Conecta la carpeta del juego e inicia el juego una vez para crear su partida.';

  @override
  String get saveFileError =>
      'No se pudo verificar o guardar el archivo. Actualiza e inténtalo de nuevo; las copias de recuperación se conservan en Respaldos.';

  @override
  String get saveFilePrimary => 'Principal';

  @override
  String get saveFileAlternate => 'Secundaria';

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
      'Bob-omb Battlefield|Whomp\'s Fortress|Jolly Roger Bay|Cool, Cool Mountain|Big Boo\'s Haunt|Hazy Maze Cave|Lethal Lava Land|Shifting Sand Land|Dire, Dire Docks|Snowman\'s Land|Wet-Dry World|Tall, Tall Mountain|Tiny-Huge Island|Tick Tock Clock|Rainbow Ride|Bowser in the Dark World|Bowser in the Fire Sea|Bowser in the Sky|The Princess\'s Secret Slide|Cavern of the Metal Cap|Tower of the Wing Cap|Vanish Cap Under the Moat|Wing Mario Over the Rainbow|The Secret Aquarium';

  @override
  String get saveFileCopies => 'Copias internas';

  @override
  String get saveFileCopiesHint =>
      'El archivo guarda dos copias de cada partida. Edita la principal normalmente; la secundaria es una opción avanzada, no un respaldo por fecha.';

  @override
  String get saveFileOpenSlot => 'Toca para editar';

  @override
  String get saveFileActions => 'Acciones de partida';

  @override
  String get saveFileDraft => 'Vista previa · se guarda al aplicar';

  @override
  String get drawerResources => 'Recursos';
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
    return 'Descarga e instalación iniciadas: $name';
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
  String get disclaimerAppSubtitle => 'SM64CoopDX Mods Manager';

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
  String get retroAccentTitle => 'Acento de Retro Manga';

  @override
  String get retroAccentDescription =>
      'Elige el color de los elementos destacados. El contraste del texto se adapta al modo claro y oscuro. Los demás temas conservan sus colores.';

  @override
  String get retroAccentCyan => 'Cian (original)';

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
      'Cierra SM64CoopDX primero. Los cambios se aplican al volver a abrirlo. Copiar y borrar afectan ambas copias de la ranura. Restaurar reemplaza las cuatro ranuras. Se guarda un respaldo completo antes de escribir.';

  @override
  String get saveFileDone => 'Guardado';

  @override
  String get saveFileMissing =>
      'Conecta la carpeta del juego e inicia el juego una vez para crear su partida.';

  @override
  String get saveFileError =>
      'No se pudo verificar o guardar el archivo. Actualiza e inténtalo de nuevo; las copias de recuperación se conservan en Respaldos.';

  @override
  String get saveFilePrimary => 'Principal';

  @override
  String get saveFileAlternate => 'Secundaria';

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
      'Bob-omb Battlefield|Whomp\'s Fortress|Jolly Roger Bay|Cool, Cool Mountain|Big Boo\'s Haunt|Hazy Maze Cave|Lethal Lava Land|Shifting Sand Land|Dire, Dire Docks|Snowman\'s Land|Wet-Dry World|Tall, Tall Mountain|Tiny-Huge Island|Tick Tock Clock|Rainbow Ride|Bowser in the Dark World|Bowser in the Fire Sea|Bowser in the Sky|The Princess\'s Secret Slide|Cavern of the Metal Cap|Tower of the Wing Cap|Vanish Cap Under the Moat|Wing Mario Over the Rainbow|The Secret Aquarium';

  @override
  String get saveFileCopies => 'Copias internas';

  @override
  String get saveFileCopiesHint =>
      'El archivo guarda dos copias de cada partida. Edita la principal normalmente; la secundaria es una opción avanzada, no un respaldo por fecha.';

  @override
  String get saveFileOpenSlot => 'Toca para editar';

  @override
  String get saveFileActions => 'Acciones de partida';

  @override
  String get saveFileDraft => 'Vista previa · se guarda al aplicar';

  @override
  String get drawerResources => 'Recursos';
}
