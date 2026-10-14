## SM64CDPY v1.8.3 — Controle de mods e a interface Mario 64

A versão 1.8.3 traz ativação verificada de mods na Biblioteca, reúne informações dos mods locais e adiciona a interface Mario 64 ao lado de Retro Manga com seletores consistentes nas Configurações.

### Biblioteca e controle de mods do jogo

- Mods do jogo é a aba principal da Biblioteca. Substitui a aba Detectados e mostra tanto mods existentes quanto conteúdo instalado pelo SM64CDPY quando seguem a estrutura compatível com o jogo.
- A ativação usa o nome real da pasta ou arquivo Lua. Busca local, filtros de ativados/desativados, contadores e detalhes somente para leitura incluem autor, categoria, versão informativa e descrição quando disponíveis.
- Selecione uma vez a pasta user do jogo para conceder acesso persistente a sm64config.txt. Feche o jogo antes de editar: a seleção vale para a próxima abertura, e DynOS/Touch Controls mantêm sua configuração separada.
- A gravação verifica incompatibilidades locais conhecidas e o limite de tamanho do jogo, preserva as demais linhas de configuração, cria um backup privado e confirma o resultado gravado. A configuração anterior pode ser restaurada com confirmação.
- Cartões, controles, progresso, diálogos e avisos de gravação acompanham o tema escolhido. A aba removida não dispara outra busca automática; recibos de instalação, verificação de atualizações e histórico mantêm suas funções próprias.

### Temas Retro Manga e Mario 64

- Retro Manga continua como visual padrão. Mario 64 reconstrói a interface principal com materiais do seletor original, molduras quadradas, céus do jogo e HUD nos modos claro e escuro.
- Os temas são lembrados ao reabrir. Escolher Mario 64 pede a ROM uma vez se faltar o conjunto local completo; cancelar mantém o tema anterior. O brilho continua independente.
- Mario 64 usa fontes de menu, diálogo e HUD geradas privadamente da ROM. Cabeçalhos coloridos usam glifos originais; caracteres ausentes na ROM US mantêm um fallback legível para o idioma.
- Uma ROM US .z64 sem modificações fornece 151 imagens e três fontes geradas, com materiais, cursores, ícones e céus Clouds/BBH. Os recursos ficam privados e fora do backup Android; nenhuma ROM ou arte extraída é incluída no APK. Importações antigas de 15 texturas podem ser atualizadas sem perdê-las ao cancelar.
- SM64 Intro traz um menu dourado de dia e azul à noite, com painéis escuros, letras da ROM e controles de slot Mario para mods ativos/inativos confirmados. Reutiliza a importação de ROM do Mario 64.

### Configurações consistentes

- Tema de interface, modo de aparência e idioma mostram a seleção atual e expandem suas opções com o mesmo visual.
- O seletor de idioma mantém as animações da seta e da expansão e fecha depois de salvar a seleção.
- Mario 64 traz superfícies de menu, molduras com relevo e indicadores de seleção consistentes aos Ajustes.
- Os títulos de seção do Mario 64 aproveitam a largura disponível; as Configurações usam tamanhos legíveis para opções, descrições e caminhos.

### Recuperação de aparência e legibilidade

- Mudanças de aparência são confirmadas depois de salvar; solicitações simultâneas são bloqueadas e falhas preservam a seleção anterior.
- Instalações anteriores mantêm o modo de aparência. IDs de design ausentes ou indisponíveis retornam a Retro Manga.
- Botões preenchidos, etiquetas, filtros e superfícies de progresso usam a cor de texto correspondente ao contraste.

### Painel flutuante e atualizações

- O painel flutuante mantém seu visual escuro fixo e independente. A escolha de tema e a edição de mods se aplicam ao app principal.
- O funcionamento de downloads e instalações é preservado. A versão 1.8.3 é uma atualização opcional.
