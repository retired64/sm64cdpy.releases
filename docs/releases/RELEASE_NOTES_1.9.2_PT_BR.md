## SM64CDPY v1.9.2 — Downloads mais resistentes e Jogador animado

A versão 1.9.2 integra a branch de fallback R2 na main: prioridade opcional do mirror, suporte ao catálogo enriquecido, ativação da Biblioteca alinhada ao jogo e prévias articuladas dos cinco personagens do Jogador.

### Downloads e catálogo

- Um mirror Cloudflare R2 válido pode recuperar um download original indisponível ou com conteúdo inválido. Preferir mirror inverte a ordem sem remover a origem como alternativa.
- App, download manual e overlay compartilham a resolução de fontes; a troca preserva a identidade da operação e a cadeia de instalação em segundo plano.
- O leitor preserva metadados opcionais de artefatos e compatibilidade com catálogos anteriores. Escolher uma fonte não altera o artefato instalado.

### Ativação pela Biblioteca

- Descrições Lua longas seguem o truncamento de cabeçalhos do jogo em vez de invalidar um mod que pode ser lido.
- Scripts desativados ilegíveis não bloqueiam outras seleções; as verificações de incompatibilidades ativas são mantidas.
- Após confirmar uma gravação, os interruptores relacionados são atualizados pela seleção real. A ativação continua configurando o próximo início do jogo.

### Jogador animado

- O visor local WebView/Three.js reconstrói a hierarquia articulada dos cinco personagens e reproduz repouso derivado da ROM do usuário. Uma animação opcional inválida retorna à pose de referência.
- A superfície AndroidView estável e a escala uniforme evitam redimensionar repetidamente o buffer durante a rolagem vertical lenta.
- Ambos os workflows testam o motor JavaScript local e verificam o grafo de módulos aninhados dentro de cada APK antes de enviar artifacts. Nenhuma ROM ou recurso extraído de personagem é incluído.

### Preparação do lançamento

- A candidata 1.9.2+30 mantém pacote, configuração de assinatura, Android mínimo e nomes de APK por ABI. Não força atualização.
- O estado integrado ainda precisa de sua própria build de testing e testes físicos de downloads, ativação, gestos do visor e ciclo de vida. O sucesso da branch de origem não comprova um novo APK de release.
- A data do manifesto é provisória até a publicação. Preparar esta candidata não publica tag, GitHub Release, aviso Discord ou atualização do site.
