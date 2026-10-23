# SM64CDPY — Navegador de mods para SM64CoopDX

[English](README.md) · [Español](README_ES.md) · **Português do Brasil**

SM64CDPY é um navegador e gerenciador de mods não oficial, voltado para Android,
para o **SM64CoopDX**. Ele reúne descoberta, download e instalação de conteúdo,
integração com o jogo e atualização do catálogo em uma interface móvel.

O projeto está em manutenção ativa. A versão de desenvolvimento é **1.9.0+28**. A
bolha flutuante da linha 1.7 está implementada, mas continua experimental até a
conclusão de testes em dispositivos Android reais.

![SM64CDPY para Android mostrando as telas inicial, catálogo e detalhes de um mod](assets/sm64cdpy-readme-banner.webp)

## Para que serve e qual é o potencial

O aplicativo pretende ser um companheiro móvel completo para o SM64CoopDX, e
não apenas uma lista de mods. Ele pode conectar o processo de encontrar
conteúdo, baixá-lo e colocá-lo em uma pasta acessível ao jogo, mostrando o
progresso do download e da instalação.

- O guia **Como jogar**, em Recursos, explica como instalar o jogo Android, preparar sua ROM dos EUA, conectar a pasta e adicionar o primeiro mod.
- Catálogo comunitário com pesquisa, categorias, filtros e favoritos.
- Gerenciador de downloads em segundo plano com progresso, cancelamento e
  notificações.
- Instalador de ZIP, 7z e arquivos avulsos por meio do Storage Access Framework.
- A instalação rápida opcional usa gravação direta em pastas compatíveis do jogo após conceder o acesso nos Ajustes; a instalação normal por SAF continua disponível.
- Bolha flutuante acessível enquanto o jogo está aberto.
- Atualização de catálogos e do APK conforme a arquitetura do dispositivo.
- Base para melhorar a instalação automática, a recuperação após encerramentos
  do Android e uma experiência mais direta dentro do jogo.

## Funcionalidades atuais

- Catálogo principal, conteúdo popular e destaques.
- Prepare sua própria ROM USA de Super Mario 64 localmente: a ferramenta detecta `.z64`, `.v64` e `.n64`, valida o dump esperado e exporta uma cópia `.z64` verificada sem modificar o original. [Detalhes do preparador](ROM_CONVERTER.md).
- Seções VIP, DynOS, controles de toque, OMM Rebirth e Render96.
- Importação e exportação de favoritos em JSON.
- Biblioteca local de conteúdo instalado, recente, mods do jogo e com
  atualizações disponíveis.
- Interface em inglês, espanhol e português brasileiro; visuais Minimal, Retro Manga, Manga Deluxe e Mario Kart 64, com aparência clara, escura ou do celular. O painel flutuante mantém seu visual escuro fixo.
- Manga Deluxe remasteriza a interface de tinta e papel com imagens do CoopDX, fundo móvel opcional, introdução compacta que pode ser ocultada, links para vídeos oficiais sob demanda e ajuda rápida. [Design e funcionamento](docs/MANGA_DELUXE.md).
- Atualização manual das bases JSON remotas.
- Conecte uma vez a pasta user do jogo pelo seletor do Android. Mods, DynOS/Touch Controls e detecção da ROM reutilizam essa conexão.
- Resolução de links, incluindo assets do GitHub Releases.
- Download e instalação pelo WorkManager com progresso e cancelamento.
- Cópia de arquivos avulsos e extração de ZIP/7z.
- Inicialização do SM64CoopDX e atualização OTA do aplicativo.
- Espaço de Jogador para editar nome, personagem e paleta dentro do jogo,
  gerenciar presets reutilizáveis e conferir as mudanças em uma visualização 3D
  interativa gerada a partir dos recursos locais conectados pelo usuário.
- Interface Minimalista de baixo custo disponível nos Ajustes; Retro Manga
  volta a ser o visual padrão e Mario 64/SM64 Intro continuam como opções.

## Bolha flutuante

O overlay utiliza um segundo engine Flutter sobre o jogo. Ele permite pesquisar,
solicitar ou cancelar downloads e receber o progresso encaminhado pelo engine
principal. Como os engines não compartilham memória e o Android pode recriar o
processo, ainda são necessários testes de concorrência, permissões e recuperação
no Android 7–16.

## Estado atual

- Catálogo, downloads, instalação e atualização OTA: implementados.
- Overlay: implementado, em estabilização e testes.
- Plataforma compatível: Android 7.0 ou superior (`minSdk 24`).
- Testes automatizados: testes unitários/widgets Flutter, contrato Python dos
  manifestos e testes unitários nativos do Android executados no CI.

Consulte [Estado e próximos passos](docs/PROJECT_STATUS.md).

## Compilação rápida

Requer Flutter **3.41.7**, Dart **3.11.x**, Java 17 e Android SDK.

```bash
flutter pub get
flutter analyze --no-fatal-infos
flutter build apk --release --target-platform android-arm64 --split-per-abi
```

O guia completo está em [BUILDING.md](BUILDING.md) e o índice técnico em
[docs/README.md](docs/README.md).

## Repositórios locais de referência

Komi Store, Floating Apps e outros repositórios clonados são exemplos locais
para pesquisa. Eles estão excluídos pelo `.gitignore`, não fazem parte do
aplicativo e não devem ser enviados ao GitHub nem entrar na análise ou build do
projeto. Apenas sua finalidade está registrada no
[arquivo de documentação](docs/archive/README.md).

## Privacidade e aviso

O app não possui contas, publicidade nem telemetria. Ele usa a Internet para
catálogos, downloads, atualizações e recursos externos; favoritos e preferências
ficam armazenados localmente.

Este é um projeto pessoal não oficial, sem vínculo com SM64CoopDX, Nintendo ou
os autores dos mods. O conteúdo pertence aos respectivos criadores.

[Releases](https://github.com/retired64/sm64cdpy.releases/releases) ·
[Discord](https://discord.com/invite/thuhUH2WNX)

A Biblioteca também permite configurar mods Lua locais compatíveis para a próxima abertura do jogo, selecionando a pasta principal do jogo, com gravação verificada e backup privado. Feche o jogo antes de editar. Os pacotes DynOS e Touch Controls em dynos/packs e user/dynos/packs têm seus próprios controles na mesma Biblioteca, usando a configuração dynos-pack do jogo.

A versão 1.8.4 melhorou a resposta da Biblioteca. A versão 1.8.5 adiciona o
espaço de Jogador e a visualização 3D interativa; consulte a [preparação do lançamento](docs/RELEASE_1.8.5.md)
e a [arquitetura do renderizador](docs/PLAYER_3D_RENDERER.md).

Escolha a pasta principal `com.maniscat2.sm64coopdx` para incluir mods e pacotes DynOS dentro e fora de `user`. Conexões antigas de user podem ser ampliadas nos Ajustes. Novas instalações, configuração e ROM permanecem em `user`.
