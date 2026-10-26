## SM64CDPY v1.9.1 — Navegação mais fluida e permissões guiadas

A versão 1.9.1 é um patch de navegação: Voltar, os menus, o dock e a seta visual compartilham um único histórico de destinos principais, e uma nova central Permissões e acessos com um guia de quatro passos explica e solicita os acessos do Android só quando são necessários.

### Voltar leva você aonde espera

- Os destinos principais compartilham um histórico de no máximo 20 entradas, identificadas pela rota, com duplicatas consecutivas recolhidas e query strings preservadas.
- A ordem de Voltar é explícita: fechar gaveta, diálogo, modal ou submenu; fechar uma tela secundária; voltar ao destino principal anterior; voltar ao Início; e permitir a saída somente do Início sem histórico.
- A gaveta clássica, o menu Retro Manga, o dock, os links internos e a seta temática usam a mesma política, então a mesma ação é alcançada por qualquer entrada.
- Os destinos principais mantêm o botão de menu onde o tema espera e as telas secundárias mostram uma seta temática, incluindo Permissões e acessos.
- O Jogador mantém o diálogo de alterações não salvas; o descarte confirmado volta ao destino anterior pela mesma política e não por um fechamento separado.

### Permissões guiadas

- Permissões e acessos é uma tela secundária dentro das Configurações e mostra a pasta do jogo, notificações, acesso a todos os arquivos quando o dispositivo suporta, a bolha flutuante e a otimização de bateria.
- Cada cartão indica permitido, não permitido ou opcional, oferece a ação Gerenciar e bloqueia solicitações simultâneas; o estado é atualizado ao retomar o app.
- As notificações são solicitadas no momento de iniciar uma operação em segundo plano; recusá-las nunca bloqueia o download ou a instalação.
- O guia cobre boas-vindas, seleção de pasta, instalação automática e verificação final, com indicador de progresso e opção de adiar no primeiro passo.
- Apenas o progresso educativo é persistido, então uma permissão revogada nas Configurações do Android aparece como não permitida na próxima abertura da tela.

### Antes de publicar

- Este patch não força atualização e mantém o comportamento de download, instalação, armazenamento e overlay da 1.9.0.
- A data do manifesto é provisória até a publicação.
- Ainda falta validar fisicamente Voltar a partir de cada destino, a gaveta e os diálogos abertos, os rascunhos do Jogador, a rotação e a reabertura.
- Também falta validar conceder e revogar cada permissão, retornar das Configurações do Android, a recusa de notificações no Android 13+ e uma pasta do jogo revogada.
