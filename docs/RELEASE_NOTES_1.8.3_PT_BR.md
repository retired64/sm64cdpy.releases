<!-- Generated preview from release-manifests/v1.8.3.json; edit that manifest, not this file. -->

## SM64CDPY v1.8.3 — Controle de mods e a interface Mario 64

A versão 1.8.3 traz ativação verificada de mods na Biblioteca, reúne informações dos mods locais e adiciona a interface Mario 64 ao lado de Retro Manga com seletores consistentes nas Configurações.

### Biblioteca e controle de mods do jogo

- Mods do jogo é a aba principal da Biblioteca. Substitui a aba Detectados e mostra tanto mods existentes quanto conteúdo instalado pelo SM64CDPY quando seguem a estrutura compatível com o jogo.
- A ativação usa o nome real da pasta ou arquivo Lua. Busca local, filtros de ativados/desativados, contadores e detalhes somente para leitura incluem autor, categoria, versão informativa e descrição quando disponíveis.
- Selecione uma vez a pasta user do jogo para conceder acesso persistente a sm64config.txt. Feche o jogo antes de editar: a seleção vale para a próxima abertura, e DynOS/Touch Controls mantêm sua configuração separada.
- A gravação verifica incompatibilidades locais conhecidas e o limite de tamanho do jogo, preserva as demais linhas de configuração, cria um backup privado e confirma o resultado gravado. A configuração anterior pode ser restaurada com confirmação.
- Cartões, controles, progresso, diálogos e avisos de gravação acompanham o tema escolhido. A aba removida não dispara outra busca automática; recibos de instalação, verificação de atualizações e histórico mantêm suas funções próprias.

### Temas Retro Manga e Mario 64

- Retro Manga continua como padrão. Mario 64 inclui paletas clara e escura, superfícies com relevo, fundos inspirados em céus e detalhes de estrelas no app principal.
- Os temas vêm incluídos offline, são lembrados ao reabrir o app e podem ser escolhidos independentemente do modo claro, escuro ou do sistema.
- Mario 64 usa TypefaceMario64 em títulos e cabeçalhos grandes, incluindo nomes de mods em Top downloads na Home. As descrições mantêm a fonte padrão e Roboto fornece os caracteres acentuados ausentes na fonte dos títulos.
- Mario 64 permite importar a pedra do menu, cursores, estrelas e dígitos do HUD de uma ROM americana sem modificações escolhida pelo usuário. Os recursos ficam privados no dispositivo; falhas ou cancelamento preservam o visual anterior. Nenhuma ROM ou imagem extraída é incluída.

### Configurações consistentes

- Tema de interface, modo de aparência e idioma mostram a seleção atual e expandem suas opções com o mesmo visual.
- O seletor de idioma mantém as animações da seta e da expansão e fecha depois de salvar a seleção.
- Mario 64 traz superfícies de menu, molduras com relevo e indicadores de seleção consistentes aos Ajustes.

### Recuperação de aparência e legibilidade

- Mudanças de aparência são confirmadas depois de salvar; solicitações simultâneas são bloqueadas e falhas preservam a seleção anterior.
- Instalações anteriores mantêm o modo de aparência. IDs de design ausentes ou indisponíveis retornam a Retro Manga.
- Botões preenchidos, etiquetas, filtros e superfícies de progresso usam a cor de texto correspondente ao contraste.

### Painel flutuante e atualizações

- O painel flutuante mantém seu visual escuro fixo e independente. A escolha de tema e a edição de mods se aplicam ao app principal.
- O funcionamento de downloads e instalações é preservado. A versão 1.8.3 é uma atualização opcional.
