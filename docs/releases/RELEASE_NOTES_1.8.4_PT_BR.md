# SM64CDPY v1.8.4 — Uma Biblioteca mais rápida e fluida

A versão 1.8.4 agiliza o carregamento da Biblioteca e faz os controles de mods responderem na hora enquanto o Android confirma as alterações de configuração.

### Uma Biblioteca mais fluida

- Abrir Mods do jogo ou DynOS não inicia mais a verificação de recibos e o carregamento do catálogo de atualizações em segundo plano.
- Ao voltar para essas seções, o snapshot recente é reutilizado. A lista continua visível durante a atualização; trocar a pasta e concluir uma instalação invalida os dados; retomar o app com a seção aberta ou atualizar manualmente solicita dados atuais.
- Os contadores aparecem conforme cada seção recebe seus dados, sem atrasar a tela ativa para mostrar informações que ainda não são necessárias.

### Resposta mais rápida na ativação

- Depois da confirmação, o mod Lua ou pacote DynOS muda na tela imediatamente enquanto o Android salva a configuração do jogo.
- O Android verifica cada gravação silenciosamente em uma fila ordenada em segundo plano. Se falhar, o controle volta ao último estado confirmado e mostra o erro.
- O gerenciador valida o item escolhido e os metadados Lua ativos necessários, sem reconstruir a lista completa após cada alteração. A verificação de tamanho Lua, o backup da configuração, a proteção contra conflitos e durante instalações continuam ativos.
- O jogo aplica as alterações na próxima inicialização. A velocidade do provedor SAF e pastas grandes ainda podem afetar a confirmação de uma gravação real.
