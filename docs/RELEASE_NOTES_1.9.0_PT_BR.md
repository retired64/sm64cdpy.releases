## SM64CDPY v1.9.0 — Jogue com amigos, prepare sua ROM e navegue em cinco idiomas

A versão 1.9.0 adiciona o fluxo multiplayer Jogar, preparação local de ROM, um guia completo de Como jogar, francês e italiano, mídia enriquecida de mods e uma interface Manga refinada com entrada mais rápida na Biblioteca e nos Saves por cache persistente.

### Jogar com amigos

- Jogar é um destino principal. Crie uma sala ou digite um código de oito caracteres, copie ou compartilhe o convite como texto e abra o SM64CoopDX no mesmo fluxo.
- A ponte Android usa um serviço em primeiro plano somente durante uma sessão ativa, libera os bloqueios de rede e CPU ao parar e mostra diagnósticos de conexão, tráfego e recuperação sem expor endereços IP.
- O consentimento de rede é explícito e versionado. A isenção de otimização de bateria é opcional, iniciada pelo usuário e verificada novamente ao retornar das Configurações do Android.
- Os códigos recentes ficam salvos localmente com um limite pequeno. Falhas terminais encerram sinalização, WebRTC, UDP e serviço antes de uma nova tentativa.

### Configuração e ferramentas de ROM

- O novo guia Como jogar usa cartões temáticos, navegação por capítulos e ações contextuais para instalar o jogo Android, preparar a ROM, escolher a pasta e instalar o primeiro mod.
- Preparar ROM detecta z64, v64 e n64 pelo cabeçalho, valida o dump USA esperado, converte nativamente em blocos e verifica a cópia exportada sem modificar o arquivo original.
- Progresso, cancelamento, nova tentativa e erros acionáveis mantêm a interface responsiva em dispositivos com pouca memória; as cópias preparada e salva externamente aparecem como estados distintos.

### Interface, mídia e desempenho

- Retro Manga recebe navegação deslizante compacta, controles consistentes de papel e tinta e personalização ampliada em Início, Catálogo, Popular, Favoritos, Biblioteca, detalhes do mod, Jogador, Saves, Preparar ROM e Jogar.
- Manga Deluxe adiciona tipografia, gráficos otimizados, fundo móvel opcional, boas-vindas compactas, navegação temática e visuais próprios para ROM, saves e multiplayer.
- Música ambiente, sons do menu e sons dos cartões da Home possuem controles independentes e persistentes de ativação e volume, com padrões conservadores.
- Biblioteca e Saves mostram imediatamente um snapshot persistido e o validam em segundo plano. O perfil do Jogador também é restaurado sem reconstruções visíveis desnecessárias.
- Os detalhes dos mods aceitam imagens normalizadas, miniaturas de vídeo e reprodução externa do YouTube com estados limitados de carregamento e erro.

### Idiomas e dados do catálogo

- Francês e italiano se juntam ao inglês, espanhol e português brasileiro na interface Flutter, nos diagnósticos compartilhados e nas notificações nativas do Android.
- O idioma escolhido persiste entre aberturas. Datas, números, paginação, cursos e categorias Render96 usam apresentação localizada.
- Touch Controls exibe autoria em listas, detalhes e favoritos, com Release Soon quando a fonte não informa autor.

### Antes de publicar

- Esta candidata não força atualização. A data do manifesto permanece provisória até a publicação.
- Ainda é necessária validação física da continuidade multiplayer, ajustes de bateria, provedores de ROM, pouco espaço, rotação, layouts em cinco idiomas, mídia e APKs das três ABI.
- O idioma da bolha flutuante e o fluxo planejado de desinstalação segura não fazem parte da versão 1.9.0.
