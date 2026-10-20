## SM64CDPY v1.9.0 — Prepare sua ROM e um Retro Manga mais consistente

A versão 1.9.0 adiciona um preparador local de ROM para o jogo Android e completa o sistema visual de papel e tinta do Retro Manga em cartões, diálogos, campos, menus e controles secundários, mantendo os outros temas isolados.

### Preparação local de ROM

- Abra o preparador no capítulo 2 de Como jogar ou no GameTool. Os dois acessos compartilham o mesmo serviço, provider e estado da operação.
- Escolha seu próprio arquivo .z64, .v64 ou .n64. A ferramenta detecta o formato pelo cabeçalho, normaliza quando necessário e valida o dump USA de 8 MiB e seu MD5.
- A conversão roda nativamente em blocos limitados com um staging isolado. O original permanece somente leitura e nenhum byte da ROM passa para o Flutter.
- A exportação usa o seletor de documentos do Android e depois reabre a cópia para verificar tamanho e hash antes de confirmar o sucesso. Não é necessária a permissão geral para gerenciar todos os arquivos.
- Há progresso real por fase, cancelamento, nova tentativa e erros acionáveis. A cópia privada preparada e a cópia externa verificada aparecem como estados diferentes.

### Consistência do Retro Manga

- Cartões e painéis neutros completam automaticamente a borda de tinta e a sombra dura, incluindo o preparador de ROM, Save Files, os grupos de Ajustes e as linhas ativas do menu lateral.
- Diálogos, campos de texto, menus, chips, botões padrão, switches, checkboxes, sliders, barras de progresso, abas, ExpansionTile e tooltips agora compartilham a mesma geometria retangular de papel e tinta.
- Save Files, Como jogar, o detalhe de mods, Jogador e o diálogo pós-instalação não substituem mais o tema compartilhado por bordas ou controles arredondados locais.
- Os cabeçalhos de seção mantêm a identidade mangá inclinada, aplicam as maiúsculas do tema e truncam títulos longos apenas quando falta espaço.
- Minimalista, Minish Cap, Mario Kart 64, Mario 64 e SM64 Intro mantêm seus próprios tratamentos. A bolha flutuante também não muda.

### Otimizações menores

- Uma única política de decoração compartilhada substitui condições repetidas por tela e evita overrides locais redundantes.
- Não são introduzidos blur, shaders, animações ou recursos raster novos. O fundo de meio-tom permanece isolado em seu RepaintBoundary.
- As transições de tema mantêm estilos de texto compatíveis e os testes cobrem layouts de 320/360 px com texto espanhol ampliado.

### Limites conhecidos

- O preparador aceita o dump USA original de Super Mario 64 para o jogo Android. Ele não altera regiões, aplica patches, repara dumps nem lê arquivos ZIP/7z.
- Esta versão exporta uma cópia verificada; ela não substitui a ROM que o jogo já usa. Feche o jogo antes de mover a cópia manualmente.
- A validação física com provedores SAF locais, remotos e lentos, rotação, pouco espaço, cancelamento e um dump real de cartucho ainda está pendente.

### Primeiros passos

- O guia Como jogar explica o jogo Android, sua própria ROM, as pastas e o primeiro mod. Abrir sem o jogo instalado oferece o guia.
- Você pode voltar ao preparador pelo GameTool sem percorrer novamente todo o guia.
