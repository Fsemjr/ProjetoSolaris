# Sistema de pausa

## Input

- A ação `pause`, já existente no Input Map, é reutilizada sem bindings adicionais.
- A tecla configurada é `Esc`.
- Com o jogo ativo, `Esc` abre o menu; com o menu aberto, `Esc` executa a mesma retomada do botão `Resume`.

## PauseMenu

A cena `res://scenes/ui/pause_menu/pause_menu.tscn` é instanciada uma única vez no `CanvasLayer` da `PrototypeArena`. Sua estrutura é:

```text
PauseMenu (Control)
├── DimBackground (ColorRect)
├── Panel (PanelContainer)
│   └── Content (VBoxContainer)
│       ├── TitleLabel
│       ├── ResumeButton
│       └── QuitButton
└── InputGuardTimer
```

O `Control` usa `PROCESS_MODE_ALWAYS`, configuração equivalente necessária para detectar `Esc` tanto antes quanto durante a pausa. Seus filhos herdam esse modo, mantendo botões e o temporizador de proteção responsivos. Ao abrir, `ResumeButton` recebe foco.

## Regras

- `open_pause()` ignora chamadas quando o menu já está aberto, durante o fechamento ou em um estado prioritário.
- A abertura exibe o menu, oculta temporariamente o tutorial e define `get_tree().paused = true`.
- `close_pause()` inicia uma proteção curta de input e, ao terminá-la, oculta o menu, limpa o foco e define `get_tree().paused = false`.
- `Resume` e `Esc` fecham a pausa pelo mesmo fluxo.
- `Quit to Desktop` chama `get_tree().quit()` diretamente, sem confirmação ou tela intermediária.

## Prioridades

- `MemoryPanel`: `Esc` é ignorado durante `READING_MEMORY`; a pausa nunca abre sobre a leitura.
- `DeathOverlay`: `DEAD` impede a abertura. Se a morte for registrada no mesmo frame, o menu é fechado imediatamente e a árvore é despausada para o fluxo de morte e respawn continuar.
- `CompletionOverlay`: `COMPLETED` impede a abertura; `Enter` mantém sua responsabilidade exclusiva de iniciar uma nova execução.
- `TutorialPrompt`: fica oculto durante a pausa e só reaparece ao retomar se ainda houver um passo contextual pendente.

## Gameplay

O sistema usa somente a pausa nativa da `SceneTree`; não percorre entidades e não altera individualmente seus estados. Enquanto pausados, Player, câmera, inimigos, pickups, encontros, portões, Tweens e timers comuns deixam de processar.

A absorção segue a regra de continuar de onde parou: `AbsorptionTimer` e seu efeito congelam durante a pausa, não concedem recursos, e retomam o tempo restante após `Resume`. O mesmo vale para cooldowns de ataque e esquiva, ataque inimigo, mensagens temporárias e animações de portão. O `CollapseDamageTimer` não reduz a vida durante a pausa e volta a aplicar dano após a retomada.

## Proteções

- O estado `is_open` mantém visibilidade e `SceneTree.paused` sincronizados.
- Chamadas repetidas de abrir ou fechar são ignoradas, sem novas instâncias, conexões ou Tweens.
- Ao fechar, `InputGuardTimer` mantém a árvore pausada por `0,05` segundo antes de liberar o gameplay. Isso impede que o clique de `Resume`, `Esc`, `Enter` ou `E` alcance uma ação do jogo no mesmo input.
- A saída da arena força `SceneTree.paused = false`, evitando que uma troca ou reinicialização de cena herde a pausa.
- Pausa é estado local e não é gravada no `GameState`.
