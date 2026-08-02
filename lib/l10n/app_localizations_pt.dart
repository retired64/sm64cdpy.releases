// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get hello => 'Olá';

  @override
  String get navHome => 'Início';

  @override
  String get navCatalog => 'Catálogo';

  @override
  String get navFavourites => 'Favoritos';

  @override
  String get navPopular => 'Populares';

  @override
  String get navVIPMods => 'Mods VIP';

  @override
  String get navDynOS => 'DynOS';

  @override
  String get navTouchControls => 'Controles de Toque';

  @override
  String get navOmmRebirth => 'OMMR PACK';

  @override
  String get navLinksResource => 'Links & Recursos';

  @override
  String get navDisclaimer => 'Aviso Legal';

  @override
  String get navChangelog => 'Registro de Mudanças';

  @override
  String get navSettings => 'Configurações';

  @override
  String get sectionExclusive => 'EXCLUSIVO';

  @override
  String get sectionExplore => 'EXPLORAR';

  @override
  String get sectionCategories => 'CATEGORIAS';

  @override
  String get sectionSortBy => 'ORDENAR POR';

  @override
  String get sectionSocialLinks => 'REDES SOCIAIS';

  @override
  String get sortDefault => 'Padrão';

  @override
  String get sortRating => 'Avaliação';

  @override
  String get sortDownloads => 'Downloads';

  @override
  String get sortNewest => 'Mais Recente';

  @override
  String get socialYouTube => 'YouTube';

  @override
  String get socialDiscord => 'Discord';

  @override
  String get socialGitHub => 'GitHub';

  @override
  String get categoryCharacters => 'Personagens';

  @override
  String get categoryGameModes => 'Modos de Jogo';

  @override
  String get categoryROMHacks => 'ROM Hacks & Fases';

  @override
  String get categoryGameplay => 'Jogabilidade & Mecânicas';

  @override
  String get categoryVisual => 'Visuais & Modelos';

  @override
  String get categoryAudio => 'Áudio & Voz';

  @override
  String get categoryUtilities => 'Utilidades & Ferramentas';

  @override
  String get categoryMisc => 'Diversos & Diversão';

  @override
  String get badgeFeatured => 'DESTAQUE';

  @override
  String get updateRequired => 'ATUALIZAÇÃO NECESSÁRIA';

  @override
  String get updateAvailable => 'NOVA VERSÃO DISPONÍVEL';

  @override
  String updateVersion(String version) {
    return 'Versão $version';
  }

  @override
  String updateSize(String size) {
    return 'Tamanho: $size MB';
  }

  @override
  String get updateWhatIsNew => 'Novidades:';

  @override
  String get updateGenericDescription =>
      'Pequenas melhorias e correções de bugs.';

  @override
  String updateDownloading(String pct) {
    return 'Baixando... $pct%';
  }

  @override
  String get updateAlreadyDownloading =>
      'Um download já está em andamento. Aguarde ou reinicie o app.';

  @override
  String get updatePermissionDenied =>
      'Permissão de instalação negada.\nVá em Configurações → Apps → este app → Instalar apps desconhecidos.';

  @override
  String updateInternalError(String detail) {
    return 'Erro interno: $detail';
  }

  @override
  String get updateDownloadError => 'Erro de download. Verifique sua conexão.';

  @override
  String get updateChecksumError =>
      'O arquivo baixado está corrompido. Tente novamente.';

  @override
  String updateInstallError(String detail) {
    return 'Erro de instalação: $detail';
  }

  @override
  String updateUnexpectedError(String detail) {
    return 'Erro inesperado: $detail';
  }

  @override
  String updateCantStart(String detail) {
    return 'Não foi possível iniciar a atualização: $detail';
  }

  @override
  String get updateButtonOpenBrowser => 'ABRIR NO NAVEGADOR';

  @override
  String get updateButtonLater => 'DEPOIS';

  @override
  String get updateButtonExit => 'SAIR';

  @override
  String get updateButtonUpdateNow => 'ATUALIZAR AGORA';

  @override
  String get updateButtonGoToDownloads => 'IR PARA DOWNLOADS';

  @override
  String get postInstallTitle => 'Mod instalado';

  @override
  String get postInstallGameRunning =>
      'Se o jogo já estava aberto, feche-o completamente (não só minimize) e reabra para que os novos arquivos sejam carregados corretamente.';

  @override
  String get postInstallNoRoot =>
      'Não é necessário forçar parada nem root — apenas feche o jogo normalmente e reabra.';

  @override
  String get postInstallFilesCopied =>
      'Os arquivos foram copiados para a pasta de mods.';

  @override
  String get postInstallClose => 'Fechar';

  @override
  String get postInstallLaunchGame => 'ABRIR JOGO';

  @override
  String get homeExclusiveContent => 'Conteúdo Exclusivo';

  @override
  String get homeTopDownloads => 'Mais Baixados';

  @override
  String get homeSeeAll => 'Ver tudo';

  @override
  String get homeFeatured => 'Destaques';

  @override
  String get homeCatalog => 'Catálogo';

  @override
  String get homeCatalogDesc =>
      'Navegue, pesquise e filtre a coleção completa de mods';

  @override
  String get homeFavorites => 'Favoritos';

  @override
  String get homeFavoritesDesc => 'Seus mods salvos em todas as seções';

  @override
  String get homePopular => 'Populares';

  @override
  String get homePopularDesc => 'Melhores mods ranqueados por downloads';

  @override
  String get homeBrowse => 'Explorar';

  @override
  String get homeGoTo => 'IR PARA';

  @override
  String get homeVipMods => 'Mods VIP';

  @override
  String get homeVipModsDesc => 'Pacotes exclusivos de personagens e modelos';

  @override
  String get homeDynos => 'DynOS';

  @override
  String get homeDynosDesc => 'Texturas e trocas de modelos personalizados';

  @override
  String get homeTouchControls => 'Controles de Toque';

  @override
  String get homeTouchControlsDesc =>
      'Layouts personalizados de botões e analógicos';

  @override
  String get homeOmmrPack => 'OMMR PACK';

  @override
  String get homeOmmrPackDesc => 'Pacote completo de texturas OMM Rebirth';

  @override
  String get homeGameNotInstalled => 'Jogo não instalado';

  @override
  String get homeGameNotInstalledBody =>
      'SM64CoopDX (com.maniscat2.sm64coopdx)\nnão está instalado neste dispositivo.';

  @override
  String get homeClose => 'Fechar';

  @override
  String get homeDownload => 'Download';

  @override
  String get homeLaunchGame => 'ABRIR JOGO';

  @override
  String get homeSoon => 'EM BREVE';

  @override
  String get homeFailedToLoad => 'Falha ao carregar mods';

  @override
  String get homeRetry => 'Tentar novamente';

  @override
  String get catalogueTitle => 'NAVEGAR MODS';

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
  String get catalogueSearchHint => 'BUSCAR MODS, AUTORES, TAGS…';

  @override
  String get catalogueSortDefault => 'Padrão';

  @override
  String get catalogueSortTopRated => 'Mais Bem Avaliados';

  @override
  String get catalogueSortMostDownloaded => 'Mais Baixados';

  @override
  String get catalogueSortRecentlyUpdated => 'Atualizados Recentemente';

  @override
  String get catalogueClearAll => 'LIMPAR TUDO';

  @override
  String cataloguePaginationRange(int start, int end, int total) {
    return '$start–$end DE $total MODS';
  }

  @override
  String get catalogueNoModsFound => 'NENHUM MOD ENCONTRADO';

  @override
  String get catalogueNothingHere => 'NADA AQUI AINDA';

  @override
  String get catalogueEmptyHint1 =>
      'Tente palavras-chave diferentes ou remova os filtros.';

  @override
  String get catalogueEmptyHint2 => 'Volte mais tarde para novos conteúdos.';

  @override
  String get catalogueClearFilters => 'LIMPAR FILTROS';

  @override
  String get catalogueFailedToLoad => 'FALHA AO CARREGAR MODS';

  @override
  String get catalogueRating => 'AVALIAÇÃO';

  @override
  String get catalogueDownloads => 'DOWNLOADS';

  @override
  String get catalogueNewest => 'MAIS NOVO';

  @override
  String get catalogueSort => 'ORDENAR';

  @override
  String get catalogueEllipsis => '···';

  @override
  String get popularTitle => 'POPULARES';

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
  String get popularMoreRankings => 'MAIS RANKINGS';

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
  String get popularFailedToLoad => 'FALHA AO CARREGAR';

  @override
  String get favouritesTitle => 'Favoritos';

  @override
  String get favTabMods => 'Mods';

  @override
  String get favTabVip => 'VIP';

  @override
  String get favTabDynos => 'DynOS';

  @override
  String get favTabTouch => 'Toque';

  @override
  String get favEmptyMods => 'Nenhum mod favoritado ainda';

  @override
  String get favEmptyVip => 'Nenhum mod VIP favoritado ainda';

  @override
  String get favEmptyDynos => 'Nenhum DynOS favoritado ainda';

  @override
  String get favEmptyTouch => 'Nenhum Controle de Toque favoritado ainda';

  @override
  String favEmptyHint(String type) {
    return 'Toque em ♥ em qualquer $type para salvar aqui.';
  }

  @override
  String get favBrowse => 'Explorar';

  @override
  String get sharedAddedToFavorites => 'Adicionado aos favoritos';

  @override
  String get sharedRemovedFromFavorites => 'Removido dos favoritos';

  @override
  String sharedDownloaded(String name) {
    return 'Baixado: $name';
  }

  @override
  String sharedDownloadedType(String type, String name) {
    return 'Baixado $type: $name';
  }

  @override
  String get sharedDownloadFailed => 'Falha no download';

  @override
  String get sharedAddToFavorites => 'ADICIONAR AOS FAVORITOS';

  @override
  String get sharedRemoveFromFavorites => 'REMOVER DOS FAVORITOS';

  @override
  String get sharedDownload => 'BAIXAR';

  @override
  String get sharedReadMore => 'LER MAIS';

  @override
  String get sharedShowLess => 'MOSTRAR MENOS';

  @override
  String get vipTitle => 'MODS VIP';

  @override
  String get vipEmpty => 'NENHUM MOD VIP AINDA';

  @override
  String get vipEmptyHint => 'Volte mais tarde para conteúdo exclusivo.';

  @override
  String get vipFailedToLoad => 'FALHA AO CARREGAR MODS VIP';

  @override
  String get dynosTitle => 'DYNOS';

  @override
  String get dynosEmpty => 'NENHUM DYNOS AINDA';

  @override
  String get dynosEmptyHint => 'Volte mais tarde para patches em tempo real.';

  @override
  String get dynosFailedToLoad => 'FALHA AO CARREGAR DYNOS';

  @override
  String get touchTitle => 'CONTROLES DE TOQUE';

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
  String get touchEmpty => 'NENHUM LAYOUT DE TOQUE AINDA';

  @override
  String get touchEmptyHint =>
      'Volte mais tarde para layouts de controle mobile.';

  @override
  String get touchFailedToLoad => 'FALHA AO CARREGAR CONTROLES DE TOQUE';

  @override
  String get ommTitle => 'OMM REBIRTH';

  @override
  String get ommEmpty => 'NENHUM MOD OMM REBIRTH AINDA';

  @override
  String get ommEmptyHint => 'Volte mais tarde para conteúdo OMM Rebirth.';

  @override
  String get ommFailedToLoad => 'FALHA AO CARREGAR MODS OMM REBIRTH';

  @override
  String get detailDownload => 'Download';

  @override
  String get detailDownloadButton => 'BAIXAR';

  @override
  String get detailModNotFound => 'Mod não encontrado';

  @override
  String get detailModNotFoundBody =>
      'Este mod pode ter sido removido ou o link é inválido.';

  @override
  String get detailGoBack => 'Voltar';

  @override
  String get detailFailedToLoad => 'Falha ao carregar mod';

  @override
  String get detailRetry => 'Tentar novamente';

  @override
  String get detailNotificationsNeeded => 'Notificações necessárias';

  @override
  String get detailNotificationsBody =>
      'Precisamos da permissão de notificações para mostrar o progresso de download e instalação, mesmo se você sair do app.';

  @override
  String get detailNotNow => 'Agora não';

  @override
  String get detailContinue => 'Continuar';

  @override
  String get detailNotificationsSkipped =>
      'Você não verá o progresso fora do app. Conceda a permissão nas Configurações para ativar notificações.';

  @override
  String get detailModsFolderNotSelected => 'Pasta de mods não selecionada';

  @override
  String get detailModsFolderBody =>
      'Você precisa selecionar uma pasta de mods antes de instalar mods no jogo.\n\nVá em Configurações → Integração com o Jogo para selecioná-la.';

  @override
  String get detailCancel => 'Cancelar';

  @override
  String get detailGoToSettings => 'Ir para Configurações';

  @override
  String detailDownloading(String filename) {
    return 'Baixando \"$filename\"...';
  }

  @override
  String detailSavedToModsFolder(String name) {
    return 'Salvo na pasta de mods: $name';
  }

  @override
  String detailSavedToFolder(String type, String name) {
    return 'Salvo na pasta $type: $name';
  }

  @override
  String get detailDownloadFailed => 'Falha no download';

  @override
  String detailError(String detail) {
    return 'Erro: $detail';
  }

  @override
  String detailDownloaded(String name) {
    return 'Baixado: $name';
  }

  @override
  String detailDownloadedType(String type, String name) {
    return 'Baixado $type: $name';
  }

  @override
  String get detailDownloadingBanner => 'Baixando mod...';

  @override
  String detailDownloadingBannerType(String type) {
    return 'Baixando $type...';
  }

  @override
  String detailFilesProgress(int current, int total) {
    return '$current/$total arquivos';
  }

  @override
  String get detailExtracting => 'Extraindo...';

  @override
  String get detailInstallingMod => 'Instalando mod...';

  @override
  String get detailInstallComplete => 'Instalação concluída';

  @override
  String detailInstallFilesExtracted(int count, String dir) {
    return '$count arquivos extraídos para \"$dir\"';
  }

  @override
  String get detailInstallFailed => 'Falha na instalação';

  @override
  String get detailOperationCancelled => 'Operação cancelada';

  @override
  String detailDownloadingPct(String pct) {
    return 'Baixando $pct%';
  }

  @override
  String get detailInstalling => 'Instalando...';

  @override
  String get detailScreenshots => 'Capturas de Tela';

  @override
  String get detailTags => 'Tags';

  @override
  String get detailAbout => 'Sobre';

  @override
  String get detailRating => 'Avaliação';

  @override
  String get detailDownloads => 'Downloads';

  @override
  String get detailViews => 'Visualizações';

  @override
  String get detailReviews => 'Avaliações';

  @override
  String detailDownloadFiles(int count) {
    return 'Arquivos para download ($count)';
  }

  @override
  String detailVersions(int count) {
    return 'Versões ($count)';
  }

  @override
  String get detailVersionFallback => 'v?';

  @override
  String get detailFirstRelease => 'Primeiro Lançamento';

  @override
  String get detailLastUpdate => 'Última Atualização';

  @override
  String get detailChangelog => 'Registro de Mudanças';

  @override
  String get detailCollapseChangelog => 'Recolher changelog';

  @override
  String detailViewAllUpdates(int count) {
    return 'Ver todas as $count atualizações';
  }

  @override
  String get detailShowLess => 'Mostrar menos';

  @override
  String get detailShowMore => 'Mostrar mais';

  @override
  String get detailNotificationsDisabled =>
      'Notificações não ativadas. Você não verá o progresso de download fora do app.';

  @override
  String get settingsTitle => 'CONFIGURAÇÕES';

  @override
  String get settingsData => 'DADOS';

  @override
  String get settingsClearFavourites => 'Limpar favoritos';

  @override
  String get settingsClearFavouritesDesc => 'Remover todos os mods salvos';

  @override
  String get settingsExportFavourites => 'Exportar favoritos';

  @override
  String get settingsExportFavouritesDesc => 'Compartilhar seus mods salvos';

  @override
  String get settingsImportFavourites => 'Importar favoritos';

  @override
  String get settingsImportFavouritesDesc =>
      'Restaurar de um arquivo exportado anteriormente';

  @override
  String get settingsGameIntegration => 'INTEGRAÇÃO COM O JOGO';

  @override
  String get settingsAppearance => 'APARÊNCIA';

  @override
  String get settingsAbout => 'SOBRE';

  @override
  String get settingsGoToReleases => 'Ir para releases';

  @override
  String settingsViewAllVersions(String version) {
    return 'Ver todas as versões no GitHub · v$version';
  }

  @override
  String get settingsDataSource => 'Fonte de dados';

  @override
  String get settingsNoFavouritesToExport =>
      'Você não tem favoritos para exportar.';

  @override
  String settingsImportAdded(int count) {
    return '$count adicionados';
  }

  @override
  String settingsImportAlreadySaved(int count) {
    return '$count já salvos';
  }

  @override
  String settingsImportNotFound(int count) {
    return '$count não encontrados no catálogo';
  }

  @override
  String get settingsImportNothingNew => 'Nada novo para importar.';

  @override
  String get settingsImportComplete => 'Importação concluída';

  @override
  String get settingsClearFavouritesTitle => 'LIMPAR FAVORITOS?';

  @override
  String get settingsClearFavouritesBody =>
      'Isso removerá todos os seus mods salvos. Esta ação não pode ser desfeita.';

  @override
  String get settingsClearButton => 'LIMPAR';

  @override
  String get settingsFavouritesCleared => 'Favoritos limpos';

  @override
  String settingsCannotOpenUrl(String url) {
    return 'Não foi possível abrir a URL: $url';
  }

  @override
  String get settingsCancel => 'CANCELAR';

  @override
  String get settingsModsFolderSelected =>
      'Pasta de mods selecionada. Os mods serão instalados aqui.';

  @override
  String get settingsClearModsFolderTitle => 'LIMPAR PASTA DE MODS?';

  @override
  String get settingsClearModsFolderBody =>
      'Você precisará selecionar a pasta novamente antes de instalar mods no jogo.';

  @override
  String get settingsModsFolderCleared => 'Seleção da pasta de mods removida.';

  @override
  String get settingsModsFolder => 'Pasta de mods';

  @override
  String get settingsSelectModsFolder => 'Selecionar pasta de mods';

  @override
  String get settingsModsFolderHint =>
      'Toque para alterar · Segure para limpar';

  @override
  String get settingsModsFolderDesc => 'Escolha onde instalar os mods baixados';

  @override
  String get settingsAutoInstall => 'Instalação automática após download';

  @override
  String get settingsAutoInstallOn =>
      'Os mods serão instalados automaticamente na pasta do jogo';

  @override
  String get settingsAutoInstallOff =>
      'Você será perguntado após cada download';

  @override
  String get settingsThemeMode => 'MODO DE TEMA';

  @override
  String settingsDatabaseUpdated(int count, String date) {
    return 'Banco de dados atualizado · $count mods$date';
  }

  @override
  String get settingsUnknownError => 'Erro desconhecido';

  @override
  String get settingsReloadDatabase => 'Recarregar banco de dados';

  @override
  String get settingsDownloading => 'Baixando...';

  @override
  String get settingsDownloadLatest => 'Baixar lista de mods mais recente';

  @override
  String settingsUpToDate(String version) {
    return 'Você está atualizado · v$version';
  }

  @override
  String get settingsCheckForUpdates => 'Verificar atualizações';

  @override
  String get settingsChecking => 'Verificando...';

  @override
  String get changelogTitle => 'Registro de Mudanças';

  @override
  String get changelogNew => 'Novo';

  @override
  String get changelogImproved => 'Melhorado';

  @override
  String get changelogFixed => 'Corrigido';

  @override
  String get changelogRemoved => 'Removido';

  @override
  String get changelogChanged => 'Alterado';

  @override
  String get changelogLatest => 'Mais Recente';

  @override
  String get generalSettings => 'Configurações';

  @override
  String get generalRetry => 'Tentar novamente';

  @override
  String get linksTitle => 'LINKS ';

  @override
  String get linksSubtitle => '& RECURSOS';

  @override
  String get linksOfficiaSection => 'OFICIAL';

  @override
  String get linksOfficialDesc => 'Canais verificados do projeto SM64CoopDX.';

  @override
  String get linksSm64cdpySection => 'SM64CDPY';

  @override
  String get linksSm64cdpyDesc => 'Downloads e conteúdo deste app.';

  @override
  String get linksResourcesSection => 'RECURSOS';

  @override
  String get linksResourcesDesc =>
      'Comunidade, guias e instalação passo a passo.';

  @override
  String get linksHeroTitle => 'LINK HUB';

  @override
  String get linksHeroDesc =>
      'Tudo oficial, a comunidade e os recursos do projeto, em um só lugar.';

  @override
  String get linksChipTap => 'TOQUE = ABRIR';

  @override
  String get linksChipHold => 'SEGURE = COPIAR';

  @override
  String get linksWebsite => 'Site SM64CoopDX';

  @override
  String get linksWebsiteUrl => 'sm64coopdx.com';

  @override
  String get linksKindWeb => 'WEB';

  @override
  String get linksDiscordServer => 'Servidor Discord';

  @override
  String get linksDiscordOfficial => 'Servidor oficial da comunidade · Android';

  @override
  String get linksKindDiscord => 'DISCORD';

  @override
  String get linksGithubRepo => 'Repositório GitHub';

  @override
  String get linksGithubDesc => 'Código fonte & issues';

  @override
  String get linksKindGithub => 'GITHUB';

  @override
  String get linksGithubReleases => 'GitHub Releases';

  @override
  String get linksGithubReleasesDesc => 'Baixar APK mais recente';

  @override
  String get linksKindDownload => 'DOWNLOAD';

  @override
  String get linksYoutubeChannel => 'Canal do YouTube';

  @override
  String get linksYoutubeHandle => '@retired64';

  @override
  String get linksKindYoutube => 'YOUTUBE';

  @override
  String get linksDiscordCommunity => 'Servidor da comunidade & suporte';

  @override
  String get linksWiki => 'Wiki & Guias';

  @override
  String get linksWikiDesc => 'Guias de instalação & docs';

  @override
  String get linksKindWiki => 'WIKI';

  @override
  String get linksTools => 'Ferramentas & Complementos';

  @override
  String get linksToolsDesc => 'Como fazer mods & recursos';

  @override
  String get linksKindTools => 'FERRAMENTAS';

  @override
  String get linksCouldNotOpen => 'Não foi possível abrir o link';

  @override
  String get linksCopied => 'Link copiado';

  @override
  String get disclaimerTitle => 'Aviso Legal';

  @override
  String get disclaimerDeveloperContact => 'Contato do desenvolvedor';

  @override
  String get disclaimerDiscordReach => 'Fale comigo no meu servidor do Discord';

  @override
  String get disclaimerDiscord => 'Discord';

  @override
  String disclaimerFooter(String version) {
    return 'v$version · para uso pessoal · Não oficial';
  }

  @override
  String get disclaimerUnofficialBanner => 'App Não Oficial';

  @override
  String get disclaimerAppSubtitle => 'SM64CoopDX Mods Manager';

  @override
  String get disclaimerWarningBody =>
      'Este app é um projeto pessoal. Quaisquer problemas relacionados a ele (funcionalidade, bugs, etc.) são de responsabilidade exclusiva do desenvolvedor. Os desenvolvedores do SM64CoopDX e os criadores de mods não têm nenhuma responsabilidade sobre este aplicativo.';

  @override
  String get disclaimerCouldNotOpenLink => 'Não foi possível abrir o link';

  @override
  String get disclaimerSectionPersonalPurpose => 'Propósito pessoal';

  @override
  String get disclaimerBodyPersonalPurpose =>
      'Este aplicativo foi desenvolvido de forma independente como um projeto pessoal. Seu único objetivo é me proporcionar acesso mais rápido, organização e gerenciamento de downloads de mods que uso para meu próprio entretenimento. Não é um aplicativo apoiado pela equipe do SM64CoopDX nem um serviço oficial de nenhum tipo.';

  @override
  String get disclaimerSectionNoAffiliation => 'Sem afiliação oficial';

  @override
  String get disclaimerBodyNoAffiliation =>
      'Este projeto não está associado, endossado ou aprovado pelos desenvolvedores do SM64CoopDX, Super Mario 64, Nintendo, ou por nenhum dos criadores de mods listados. Todos os nomes, imagens e conteúdo exibidos pertencem aos seus respectivos autores.';

  @override
  String get disclaimerSectionDataSource => 'Fonte de dados';

  @override
  String get disclaimerBodyDataSource =>
      'As informações dos mods vêm do catálogo público em mods.sm64coopdx.com. Este app apenas apresenta essas informações de forma mais acessível; ele não hospeda, modifica ou redistribui nenhum arquivo de mod.';

  @override
  String get disclaimerSectionExclusive =>
      'Seções exclusivas (VIP · DynOS · Touch Controls)';

  @override
  String disclaimerBodyExclusive(Object version) {
    return 'A partir da v$version, o app inclui seções selecionadas com conteúdo não listado oficialmente no site do SM64CoopDX. Estas seções (VIP Mods, pacotes DynOS e layouts de Touch Controls) são mantidas de forma independente pelo desenvolvedor e não têm afiliação com nenhuma fonte oficial. Todo o crédito pertence aos criadores originais.';
  }

  @override
  String get disclaimerSectionBugs => 'Erros, sugestões ou solicitações';

  @override
  String get disclaimerBodyBugs =>
      'Se você encontrar algum problema com este app, tiver uma sugestão ou quiser solicitar algo, entre em contato diretamente comigo pelas minhas redes sociais. Por favor, não entre em contato com os desenvolvedores oficiais do SM64CoopDX nem com os criadores de mods sobre assuntos relacionados a este aplicativo.';

  @override
  String get vipSectionHeader => 'CONTEÚDO EXCLUSIVO';

  @override
  String get dynosSectionHeader => 'DYNOS PERSONALIZADOS';

  @override
  String get touchSectionHeader => 'LAYOUTS MÓVEIS';

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
  String get settingsDynosFolder => 'Pasta DynOS';

  @override
  String get settingsSelectDynosFolder => 'Selecionar pasta DynOS';

  @override
  String get settingsDynosFolderHint =>
      'Toque para alterar · Segure para limpar';

  @override
  String get settingsDynosFolderDesc =>
      'Escolha onde instalar os pacotes DynOS e Touch Controls';

  @override
  String get settingsDynosFolderSelected =>
      'Pasta DynOS selecionada. Os pacotes serão instalados aqui.';

  @override
  String get settingsClearDynosFolderTitle => 'LIMPAR PASTA DYNOS?';

  @override
  String get settingsClearDynosFolderBody =>
      'Você precisará selecionar a pasta novamente antes de instalar pacotes DynOS ou Touch Controls.';

  @override
  String get settingsDynosFolderCleared => 'Seleção da pasta DynOS removida.';

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
      'Sem resposta — abra o app principal uma vez e tente novamente';

  @override
  String get overlaySelectFolder =>
      'Selecione uma pasta primeiro (Configurações)';

  @override
  String get overlayEnableAutoInstall =>
      'Ative a instalação automática primeiro (Configurações)';

  @override
  String get overlayDownloadFailed => 'Falha no download';

  @override
  String get overlayTapToCancel => 'TOQUE PARA CANCELAR';

  @override
  String get overlayInstalling => 'Instalando...';

  @override
  String get overlayConnecting => 'Conectando...';

  @override
  String get overlayNoResults => 'SEM RESULTADOS';

  @override
  String get overlayError => 'ERRO';

  @override
  String get settingsOverlayActive => 'Chathead ativo';

  @override
  String get settingsOverlayInactive => 'Overlay flutuante';

  @override
  String get settingsOverlayActiveDesc => 'Toque para esconder o chathead';

  @override
  String get settingsOverlayInactiveDesc =>
      'Toque para mostrar o chathead sobre o jogo';

  @override
  String get navRender96 => 'Render96';

  @override
  String get render96Title => 'RENDER96';

  @override
  String get render96SectionHeader => 'COLEÇÃO EXCLUSIVA';

  @override
  String get render96Empty => 'EM BREVE';

  @override
  String get render96EmptyHint =>
      'Novos conteúdos do Render96 aparecerão aqui.';

  @override
  String get render96FailedToLoad => 'FALHA AO CARREGAR';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get hello => 'Olá';

  @override
  String get navHome => 'Início';

  @override
  String get navCatalog => 'Catálogo';

  @override
  String get navFavourites => 'Favoritos';

  @override
  String get navPopular => 'Populares';

  @override
  String get navVIPMods => 'Mods VIP';

  @override
  String get navDynOS => 'DynOS';

  @override
  String get navTouchControls => 'Controles de Toque';

  @override
  String get navOmmRebirth => 'OMMR PACK';

  @override
  String get navLinksResource => 'Links & Recursos';

  @override
  String get navDisclaimer => 'Aviso Legal';

  @override
  String get navChangelog => 'Registro de Mudanças';

  @override
  String get navSettings => 'Configurações';

  @override
  String get sectionExclusive => 'EXCLUSIVO';

  @override
  String get sectionExplore => 'EXPLORAR';

  @override
  String get sectionCategories => 'CATEGORIAS';

  @override
  String get sectionSortBy => 'ORDENAR POR';

  @override
  String get sectionSocialLinks => 'REDES SOCIAIS';

  @override
  String get sortDefault => 'Padrão';

  @override
  String get sortRating => 'Avaliação';

  @override
  String get sortDownloads => 'Downloads';

  @override
  String get sortNewest => 'Mais Recente';

  @override
  String get socialYouTube => 'YouTube';

  @override
  String get socialDiscord => 'Discord';

  @override
  String get socialGitHub => 'GitHub';

  @override
  String get categoryCharacters => 'Personagens';

  @override
  String get categoryGameModes => 'Modos de Jogo';

  @override
  String get categoryROMHacks => 'ROM Hacks & Fases';

  @override
  String get categoryGameplay => 'Jogabilidade & Mecânicas';

  @override
  String get categoryVisual => 'Visuais & Modelos';

  @override
  String get categoryAudio => 'Áudio & Voz';

  @override
  String get categoryUtilities => 'Utilidades & Ferramentas';

  @override
  String get categoryMisc => 'Diversos & Diversão';

  @override
  String get badgeFeatured => 'DESTAQUE';

  @override
  String get updateRequired => 'ATUALIZAÇÃO NECESSÁRIA';

  @override
  String get updateAvailable => 'NOVA VERSÃO DISPONÍVEL';

  @override
  String updateVersion(String version) {
    return 'Versão $version';
  }

  @override
  String updateSize(String size) {
    return 'Tamanho: $size MB';
  }

  @override
  String get updateWhatIsNew => 'Novidades:';

  @override
  String get updateGenericDescription =>
      'Pequenas melhorias e correções de bugs.';

  @override
  String updateDownloading(String pct) {
    return 'Baixando... $pct%';
  }

  @override
  String get updateAlreadyDownloading =>
      'Um download já está em andamento. Aguarde ou reinicie o app.';

  @override
  String get updatePermissionDenied =>
      'Permissão de instalação negada.\nVá em Configurações → Apps → este app → Instalar apps desconhecidos.';

  @override
  String updateInternalError(String detail) {
    return 'Erro interno: $detail';
  }

  @override
  String get updateDownloadError => 'Erro de download. Verifique sua conexão.';

  @override
  String get updateChecksumError =>
      'O arquivo baixado está corrompido. Tente novamente.';

  @override
  String updateInstallError(String detail) {
    return 'Erro de instalação: $detail';
  }

  @override
  String updateUnexpectedError(String detail) {
    return 'Erro inesperado: $detail';
  }

  @override
  String updateCantStart(String detail) {
    return 'Não foi possível iniciar a atualização: $detail';
  }

  @override
  String get updateButtonOpenBrowser => 'ABRIR NO NAVEGADOR';

  @override
  String get updateButtonLater => 'DEPOIS';

  @override
  String get updateButtonExit => 'SAIR';

  @override
  String get updateButtonUpdateNow => 'ATUALIZAR AGORA';

  @override
  String get updateButtonGoToDownloads => 'IR PARA DOWNLOADS';

  @override
  String get postInstallTitle => 'Mod instalado';

  @override
  String get postInstallGameRunning =>
      'Se o jogo já estava aberto, feche-o completamente (não só minimize) e reabra para que os novos arquivos sejam carregados corretamente.';

  @override
  String get postInstallNoRoot =>
      'Não é necessário forçar parada nem root — apenas feche o jogo normalmente e reabra.';

  @override
  String get postInstallFilesCopied =>
      'Os arquivos foram copiados para a pasta de mods.';

  @override
  String get postInstallClose => 'Fechar';

  @override
  String get postInstallLaunchGame => 'ABRIR JOGO';

  @override
  String get homeExclusiveContent => 'Conteúdo Exclusivo';

  @override
  String get homeTopDownloads => 'Mais Baixados';

  @override
  String get homeSeeAll => 'Ver tudo';

  @override
  String get homeFeatured => 'Destaques';

  @override
  String get homeCatalog => 'Catálogo';

  @override
  String get homeCatalogDesc =>
      'Navegue, pesquise e filtre a coleção completa de mods';

  @override
  String get homeFavorites => 'Favoritos';

  @override
  String get homeFavoritesDesc => 'Seus mods salvos em todas as seções';

  @override
  String get homePopular => 'Populares';

  @override
  String get homePopularDesc => 'Melhores mods ranqueados por downloads';

  @override
  String get homeBrowse => 'Explorar';

  @override
  String get homeGoTo => 'IR PARA';

  @override
  String get homeVipMods => 'Mods VIP';

  @override
  String get homeVipModsDesc => 'Pacotes exclusivos de personagens e modelos';

  @override
  String get homeDynos => 'DynOS';

  @override
  String get homeDynosDesc => 'Texturas e trocas de modelos personalizados';

  @override
  String get homeTouchControls => 'Controles de Toque';

  @override
  String get homeTouchControlsDesc =>
      'Layouts personalizados de botões e analógicos';

  @override
  String get homeOmmrPack => 'OMMR PACK';

  @override
  String get homeOmmrPackDesc => 'Pacote completo de texturas OMM Rebirth';

  @override
  String get homeGameNotInstalled => 'Jogo não instalado';

  @override
  String get homeGameNotInstalledBody =>
      'SM64CoopDX (com.maniscat2.sm64coopdx)\nnão está instalado neste dispositivo.';

  @override
  String get homeClose => 'Fechar';

  @override
  String get homeDownload => 'Download';

  @override
  String get homeLaunchGame => 'ABRIR JOGO';

  @override
  String get homeSoon => 'EM BREVE';

  @override
  String get homeFailedToLoad => 'Falha ao carregar mods';

  @override
  String get homeRetry => 'Tentar novamente';

  @override
  String get catalogueTitle => 'NAVEGAR MODS';

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
  String get catalogueSearchHint => 'BUSCAR MODS, AUTORES, TAGS…';

  @override
  String get catalogueSortDefault => 'Padrão';

  @override
  String get catalogueSortTopRated => 'Mais Bem Avaliados';

  @override
  String get catalogueSortMostDownloaded => 'Mais Baixados';

  @override
  String get catalogueSortRecentlyUpdated => 'Atualizados Recentemente';

  @override
  String get catalogueClearAll => 'LIMPAR TUDO';

  @override
  String cataloguePaginationRange(int start, int end, int total) {
    return '$start–$end DE $total MODS';
  }

  @override
  String get catalogueNoModsFound => 'NENHUM MOD ENCONTRADO';

  @override
  String get catalogueNothingHere => 'NADA AQUI AINDA';

  @override
  String get catalogueEmptyHint1 =>
      'Tente palavras-chave diferentes ou remova os filtros.';

  @override
  String get catalogueEmptyHint2 => 'Volte mais tarde para novos conteúdos.';

  @override
  String get catalogueClearFilters => 'LIMPAR FILTROS';

  @override
  String get catalogueFailedToLoad => 'FALHA AO CARREGAR MODS';

  @override
  String get catalogueRating => 'AVALIAÇÃO';

  @override
  String get catalogueDownloads => 'DOWNLOADS';

  @override
  String get catalogueNewest => 'MAIS NOVO';

  @override
  String get catalogueSort => 'ORDENAR';

  @override
  String get catalogueEllipsis => '···';

  @override
  String get popularTitle => 'POPULARES';

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
  String get popularMoreRankings => 'MAIS RANKINGS';

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
  String get popularFailedToLoad => 'FALHA AO CARREGAR';

  @override
  String get favouritesTitle => 'Favoritos';

  @override
  String get favTabMods => 'Mods';

  @override
  String get favTabVip => 'VIP';

  @override
  String get favTabDynos => 'DynOS';

  @override
  String get favTabTouch => 'Toque';

  @override
  String get favEmptyMods => 'Nenhum mod favoritado ainda';

  @override
  String get favEmptyVip => 'Nenhum mod VIP favoritado ainda';

  @override
  String get favEmptyDynos => 'Nenhum DynOS favoritado ainda';

  @override
  String get favEmptyTouch => 'Nenhum Controle de Toque favoritado ainda';

  @override
  String favEmptyHint(String type) {
    return 'Toque em ♥ em qualquer $type para salvar aqui.';
  }

  @override
  String get favBrowse => 'Explorar';

  @override
  String get sharedAddedToFavorites => 'Adicionado aos favoritos';

  @override
  String get sharedRemovedFromFavorites => 'Removido dos favoritos';

  @override
  String sharedDownloaded(String name) {
    return 'Baixado: $name';
  }

  @override
  String sharedDownloadedType(String type, String name) {
    return 'Baixado $type: $name';
  }

  @override
  String get sharedDownloadFailed => 'Falha no download';

  @override
  String get sharedAddToFavorites => 'ADICIONAR AOS FAVORITOS';

  @override
  String get sharedRemoveFromFavorites => 'REMOVER DOS FAVORITOS';

  @override
  String get sharedDownload => 'BAIXAR';

  @override
  String get sharedReadMore => 'LER MAIS';

  @override
  String get sharedShowLess => 'MOSTRAR MENOS';

  @override
  String get vipTitle => 'MODS VIP';

  @override
  String get vipEmpty => 'NENHUM MOD VIP AINDA';

  @override
  String get vipEmptyHint => 'Volte mais tarde para conteúdo exclusivo.';

  @override
  String get vipFailedToLoad => 'FALHA AO CARREGAR MODS VIP';

  @override
  String get dynosTitle => 'DYNOS';

  @override
  String get dynosEmpty => 'NENHUM DYNOS AINDA';

  @override
  String get dynosEmptyHint => 'Volte mais tarde para patches em tempo real.';

  @override
  String get dynosFailedToLoad => 'FALHA AO CARREGAR DYNOS';

  @override
  String get touchTitle => 'CONTROLES DE TOQUE';

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
  String get touchEmpty => 'NENHUM LAYOUT DE TOQUE AINDA';

  @override
  String get touchEmptyHint =>
      'Volte mais tarde para layouts de controle mobile.';

  @override
  String get touchFailedToLoad => 'FALHA AO CARREGAR CONTROLES DE TOQUE';

  @override
  String get ommTitle => 'OMM REBIRTH';

  @override
  String get ommEmpty => 'NENHUM MOD OMM REBIRTH AINDA';

  @override
  String get ommEmptyHint => 'Volte mais tarde para conteúdo OMM Rebirth.';

  @override
  String get ommFailedToLoad => 'FALHA AO CARREGAR MODS OMM REBIRTH';

  @override
  String get detailDownload => 'Download';

  @override
  String get detailDownloadButton => 'BAIXAR';

  @override
  String get detailModNotFound => 'Mod não encontrado';

  @override
  String get detailModNotFoundBody =>
      'Este mod pode ter sido removido ou o link é inválido.';

  @override
  String get detailGoBack => 'Voltar';

  @override
  String get detailFailedToLoad => 'Falha ao carregar mod';

  @override
  String get detailRetry => 'Tentar novamente';

  @override
  String get detailNotificationsNeeded => 'Notificações necessárias';

  @override
  String get detailNotificationsBody =>
      'Precisamos da permissão de notificações para mostrar o progresso de download e instalação, mesmo se você sair do app.';

  @override
  String get detailNotNow => 'Agora não';

  @override
  String get detailContinue => 'Continuar';

  @override
  String get detailNotificationsSkipped =>
      'Você não verá o progresso fora do app. Conceda a permissão nas Configurações para ativar notificações.';

  @override
  String get detailModsFolderNotSelected => 'Pasta de mods não selecionada';

  @override
  String get detailModsFolderBody =>
      'Você precisa selecionar uma pasta de mods antes de instalar mods no jogo.\n\nVá em Configurações → Integração com o Jogo para selecioná-la.';

  @override
  String get detailCancel => 'Cancelar';

  @override
  String get detailGoToSettings => 'Ir para Configurações';

  @override
  String detailDownloading(String filename) {
    return 'Baixando \"$filename\"...';
  }

  @override
  String detailSavedToModsFolder(String name) {
    return 'Salvo na pasta de mods: $name';
  }

  @override
  String detailSavedToFolder(String type, String name) {
    return 'Salvo na pasta $type: $name';
  }

  @override
  String get detailDownloadFailed => 'Falha no download';

  @override
  String detailError(String detail) {
    return 'Erro: $detail';
  }

  @override
  String detailDownloaded(String name) {
    return 'Baixado: $name';
  }

  @override
  String detailDownloadedType(String type, String name) {
    return 'Baixado $type: $name';
  }

  @override
  String get detailDownloadingBanner => 'Baixando mod...';

  @override
  String detailDownloadingBannerType(String type) {
    return 'Baixando $type...';
  }

  @override
  String detailFilesProgress(int current, int total) {
    return '$current/$total arquivos';
  }

  @override
  String get detailExtracting => 'Extraindo...';

  @override
  String get detailInstallingMod => 'Instalando mod...';

  @override
  String get detailInstallComplete => 'Instalação concluída';

  @override
  String detailInstallFilesExtracted(int count, String dir) {
    return '$count arquivos extraídos para \"$dir\"';
  }

  @override
  String get detailInstallFailed => 'Falha na instalação';

  @override
  String get detailOperationCancelled => 'Operação cancelada';

  @override
  String detailDownloadingPct(String pct) {
    return 'Baixando $pct%';
  }

  @override
  String get detailInstalling => 'Instalando...';

  @override
  String get detailScreenshots => 'Capturas de Tela';

  @override
  String get detailTags => 'Tags';

  @override
  String get detailAbout => 'Sobre';

  @override
  String get detailRating => 'Avaliação';

  @override
  String get detailDownloads => 'Downloads';

  @override
  String get detailViews => 'Visualizações';

  @override
  String get detailReviews => 'Avaliações';

  @override
  String detailDownloadFiles(int count) {
    return 'Arquivos para download ($count)';
  }

  @override
  String detailVersions(int count) {
    return 'Versões ($count)';
  }

  @override
  String get detailVersionFallback => 'v?';

  @override
  String get detailFirstRelease => 'Primeiro Lançamento';

  @override
  String get detailLastUpdate => 'Última Atualização';

  @override
  String get detailChangelog => 'Registro de Mudanças';

  @override
  String get detailCollapseChangelog => 'Recolher changelog';

  @override
  String detailViewAllUpdates(int count) {
    return 'Ver todas as $count atualizações';
  }

  @override
  String get detailShowLess => 'Mostrar menos';

  @override
  String get detailShowMore => 'Mostrar mais';

  @override
  String get detailNotificationsDisabled =>
      'Notificações não ativadas. Você não verá o progresso de download fora do app.';

  @override
  String get settingsTitle => 'CONFIGURAÇÕES';

  @override
  String get settingsData => 'DADOS';

  @override
  String get settingsClearFavourites => 'Limpar favoritos';

  @override
  String get settingsClearFavouritesDesc => 'Remover todos os mods salvos';

  @override
  String get settingsExportFavourites => 'Exportar favoritos';

  @override
  String get settingsExportFavouritesDesc => 'Compartilhar seus mods salvos';

  @override
  String get settingsImportFavourites => 'Importar favoritos';

  @override
  String get settingsImportFavouritesDesc =>
      'Restaurar de um arquivo exportado anteriormente';

  @override
  String get settingsGameIntegration => 'INTEGRAÇÃO COM O JOGO';

  @override
  String get settingsAppearance => 'APARÊNCIA';

  @override
  String get settingsAbout => 'SOBRE';

  @override
  String get settingsGoToReleases => 'Ir para releases';

  @override
  String settingsViewAllVersions(String version) {
    return 'Ver todas as versões no GitHub · v$version';
  }

  @override
  String get settingsDataSource => 'Fonte de dados';

  @override
  String get settingsNoFavouritesToExport =>
      'Você não tem favoritos para exportar.';

  @override
  String settingsImportAdded(int count) {
    return '$count adicionados';
  }

  @override
  String settingsImportAlreadySaved(int count) {
    return '$count já salvos';
  }

  @override
  String settingsImportNotFound(int count) {
    return '$count não encontrados no catálogo';
  }

  @override
  String get settingsImportNothingNew => 'Nada novo para importar.';

  @override
  String get settingsImportComplete => 'Importação concluída';

  @override
  String get settingsClearFavouritesTitle => 'LIMPAR FAVORITOS?';

  @override
  String get settingsClearFavouritesBody =>
      'Isso removerá todos os seus mods salvos. Esta ação não pode ser desfeita.';

  @override
  String get settingsClearButton => 'LIMPAR';

  @override
  String get settingsFavouritesCleared => 'Favoritos limpos';

  @override
  String settingsCannotOpenUrl(String url) {
    return 'Não foi possível abrir a URL: $url';
  }

  @override
  String get settingsCancel => 'CANCELAR';

  @override
  String get settingsModsFolderSelected =>
      'Pasta de mods selecionada. Os mods serão instalados aqui.';

  @override
  String get settingsClearModsFolderTitle => 'LIMPAR PASTA DE MODS?';

  @override
  String get settingsClearModsFolderBody =>
      'Você precisará selecionar a pasta novamente antes de instalar mods no jogo.';

  @override
  String get settingsModsFolderCleared => 'Seleção da pasta de mods removida.';

  @override
  String get settingsModsFolder => 'Pasta de mods';

  @override
  String get settingsSelectModsFolder => 'Selecionar pasta de mods';

  @override
  String get settingsModsFolderHint =>
      'Toque para alterar · Segure para limpar';

  @override
  String get settingsModsFolderDesc => 'Escolha onde instalar os mods baixados';

  @override
  String get settingsAutoInstall => 'Instalação automática após download';

  @override
  String get settingsAutoInstallOn =>
      'Os mods serão instalados automaticamente na pasta do jogo';

  @override
  String get settingsAutoInstallOff =>
      'Você será perguntado após cada download';

  @override
  String get settingsThemeMode => 'MODO DE TEMA';

  @override
  String settingsDatabaseUpdated(int count, String date) {
    return 'Banco de dados atualizado · $count mods$date';
  }

  @override
  String get settingsUnknownError => 'Erro desconhecido';

  @override
  String get settingsReloadDatabase => 'Recarregar banco de dados';

  @override
  String get settingsDownloading => 'Baixando...';

  @override
  String get settingsDownloadLatest => 'Baixar lista de mods mais recente';

  @override
  String settingsUpToDate(String version) {
    return 'Você está atualizado · v$version';
  }

  @override
  String get settingsCheckForUpdates => 'Verificar atualizações';

  @override
  String get settingsChecking => 'Verificando...';

  @override
  String get changelogTitle => 'Registro de Mudanças';

  @override
  String get changelogNew => 'Novo';

  @override
  String get changelogImproved => 'Melhorado';

  @override
  String get changelogFixed => 'Corrigido';

  @override
  String get changelogRemoved => 'Removido';

  @override
  String get changelogChanged => 'Alterado';

  @override
  String get changelogLatest => 'Mais Recente';

  @override
  String get generalSettings => 'Configurações';

  @override
  String get generalRetry => 'Tentar novamente';

  @override
  String get linksTitle => 'LINKS ';

  @override
  String get linksSubtitle => '& RECURSOS';

  @override
  String get linksOfficiaSection => 'OFICIAL';

  @override
  String get linksOfficialDesc => 'Canais verificados do projeto SM64CoopDX.';

  @override
  String get linksSm64cdpySection => 'SM64CDPY';

  @override
  String get linksSm64cdpyDesc => 'Downloads e conteúdo deste app.';

  @override
  String get linksResourcesSection => 'RECURSOS';

  @override
  String get linksResourcesDesc =>
      'Comunidade, guias e instalação passo a passo.';

  @override
  String get linksHeroTitle => 'LINK HUB';

  @override
  String get linksHeroDesc =>
      'Tudo oficial, a comunidade e os recursos do projeto, em um só lugar.';

  @override
  String get linksChipTap => 'TOQUE = ABRIR';

  @override
  String get linksChipHold => 'SEGURE = COPIAR';

  @override
  String get linksWebsite => 'Site SM64CoopDX';

  @override
  String get linksWebsiteUrl => 'sm64coopdx.com';

  @override
  String get linksKindWeb => 'WEB';

  @override
  String get linksDiscordServer => 'Servidor Discord';

  @override
  String get linksDiscordOfficial => 'Servidor oficial da comunidade · Android';

  @override
  String get linksKindDiscord => 'DISCORD';

  @override
  String get linksGithubRepo => 'Repositório GitHub';

  @override
  String get linksGithubDesc => 'Código fonte & issues';

  @override
  String get linksKindGithub => 'GITHUB';

  @override
  String get linksGithubReleases => 'GitHub Releases';

  @override
  String get linksGithubReleasesDesc => 'Baixar APK mais recente';

  @override
  String get linksKindDownload => 'DOWNLOAD';

  @override
  String get linksYoutubeChannel => 'Canal do YouTube';

  @override
  String get linksYoutubeHandle => '@retired64';

  @override
  String get linksKindYoutube => 'YOUTUBE';

  @override
  String get linksDiscordCommunity => 'Servidor da comunidade & suporte';

  @override
  String get linksWiki => 'Wiki & Guias';

  @override
  String get linksWikiDesc => 'Guias de instalação & docs';

  @override
  String get linksKindWiki => 'WIKI';

  @override
  String get linksTools => 'Ferramentas & Complementos';

  @override
  String get linksToolsDesc => 'Como fazer mods & recursos';

  @override
  String get linksKindTools => 'FERRAMENTAS';

  @override
  String get linksCouldNotOpen => 'Não foi possível abrir o link';

  @override
  String get linksCopied => 'Link copiado';

  @override
  String get disclaimerTitle => 'Aviso Legal';

  @override
  String get disclaimerDeveloperContact => 'Contato do desenvolvedor';

  @override
  String get disclaimerDiscordReach => 'Fale comigo no meu servidor do Discord';

  @override
  String get disclaimerDiscord => 'Discord';

  @override
  String disclaimerFooter(String version) {
    return 'v$version · para uso pessoal · Não oficial';
  }

  @override
  String get disclaimerUnofficialBanner => 'App Não Oficial';

  @override
  String get disclaimerAppSubtitle => 'SM64CoopDX Mods Manager';

  @override
  String get disclaimerWarningBody =>
      'Este app é um projeto pessoal. Quaisquer problemas relacionados a ele (funcionalidade, bugs, etc.) são de responsabilidade exclusiva do desenvolvedor. Os desenvolvedores do SM64CoopDX e os criadores de mods não têm nenhuma responsabilidade sobre este aplicativo.';

  @override
  String get disclaimerCouldNotOpenLink => 'Não foi possível abrir o link';

  @override
  String get disclaimerSectionPersonalPurpose => 'Propósito pessoal';

  @override
  String get disclaimerBodyPersonalPurpose =>
      'Este aplicativo foi desenvolvido de forma independente como um projeto pessoal. Seu único objetivo é me proporcionar acesso mais rápido, organização e gerenciamento de downloads de mods que uso para meu próprio entretenimento. Não é um aplicativo apoiado pela equipe do SM64CoopDX nem um serviço oficial de nenhum tipo.';

  @override
  String get disclaimerSectionNoAffiliation => 'Sem afiliação oficial';

  @override
  String get disclaimerBodyNoAffiliation =>
      'Este projeto não está associado, endossado ou aprovado pelos desenvolvedores do SM64CoopDX, Super Mario 64, Nintendo, ou por nenhum dos criadores de mods listados. Todos os nomes, imagens e conteúdo exibidos pertencem aos seus respectivos autores.';

  @override
  String get disclaimerSectionDataSource => 'Fonte de dados';

  @override
  String get disclaimerBodyDataSource =>
      'As informações dos mods vêm do catálogo público em mods.sm64coopdx.com. Este app apenas apresenta essas informações de forma mais acessível; ele não hospeda, modifica ou redistribui nenhum arquivo de mod.';

  @override
  String get disclaimerSectionExclusive =>
      'Seções exclusivas (VIP · DynOS · Touch Controls)';

  @override
  String disclaimerBodyExclusive(Object version) {
    return 'A partir da v$version, o app inclui seções selecionadas com conteúdo não listado oficialmente no site do SM64CoopDX. Estas seções (VIP Mods, pacotes DynOS e layouts de Touch Controls) são mantidas de forma independente pelo desenvolvedor e não têm afiliação com nenhuma fonte oficial. Todo o crédito pertence aos criadores originais.';
  }

  @override
  String get disclaimerSectionBugs => 'Erros, sugestões ou solicitações';

  @override
  String get disclaimerBodyBugs =>
      'Se você encontrar algum problema com este app, tiver uma sugestão ou quiser solicitar algo, entre em contato diretamente comigo pelas minhas redes sociais. Por favor, não entre em contato com os desenvolvedores oficiais do SM64CoopDX nem com os criadores de mods sobre assuntos relacionados a este aplicativo.';

  @override
  String get vipSectionHeader => 'CONTEÚDO EXCLUSIVO';

  @override
  String get dynosSectionHeader => 'DYNOS PERSONALIZADOS';

  @override
  String get touchSectionHeader => 'LAYOUTS MÓVEIS';

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
  String get settingsDynosFolder => 'Pasta DynOS';

  @override
  String get settingsSelectDynosFolder => 'Selecionar pasta DynOS';

  @override
  String get settingsDynosFolderHint =>
      'Toque para alterar · Segure para limpar';

  @override
  String get settingsDynosFolderDesc =>
      'Escolha onde instalar os pacotes DynOS e Touch Controls';

  @override
  String get settingsDynosFolderSelected =>
      'Pasta DynOS selecionada. Os pacotes serão instalados aqui.';

  @override
  String get settingsClearDynosFolderTitle => 'LIMPAR PASTA DYNOS?';

  @override
  String get settingsClearDynosFolderBody =>
      'Você precisará selecionar a pasta novamente antes de instalar pacotes DynOS ou Touch Controls.';

  @override
  String get settingsDynosFolderCleared => 'Seleção da pasta DynOS removida.';

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
      'Sem resposta — abra o app principal uma vez e tente novamente';

  @override
  String get overlaySelectFolder =>
      'Selecione uma pasta primeiro (Configurações)';

  @override
  String get overlayEnableAutoInstall =>
      'Ative a instalação automática primeiro (Configurações)';

  @override
  String get overlayDownloadFailed => 'Falha no download';

  @override
  String get overlayTapToCancel => 'TOQUE PARA CANCELAR';

  @override
  String get overlayInstalling => 'Instalando...';

  @override
  String get overlayConnecting => 'Conectando...';

  @override
  String get overlayNoResults => 'SEM RESULTADOS';

  @override
  String get overlayError => 'ERRO';

  @override
  String get settingsOverlayActive => 'Chathead ativo';

  @override
  String get settingsOverlayInactive => 'Overlay flutuante';

  @override
  String get settingsOverlayActiveDesc => 'Toque para esconder o chathead';

  @override
  String get settingsOverlayInactiveDesc =>
      'Toque para mostrar o chathead sobre o jogo';

  @override
  String get navRender96 => 'Render96';

  @override
  String get render96Title => 'RENDER96';

  @override
  String get render96SectionHeader => 'COLEÇÃO EXCLUSIVA';

  @override
  String get render96Empty => 'EM BREVE';

  @override
  String get render96EmptyHint =>
      'Novos conteúdos do Render96 aparecerão aqui.';

  @override
  String get render96FailedToLoad => 'FALHA AO CARREGAR';
}
