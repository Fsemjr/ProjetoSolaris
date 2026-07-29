# Solares — Arquitetura Técnica

## 1. Objetivo

Este documento descreve a arquitetura existente no protótipo, não uma
estrutura hipotética futura. O projeto usa cenas com responsabilidades
definidas, composição para sistemas reutilizáveis e sinais para comunicação.

## 2. Tecnologias

- Engine: Godot 4.5.1.
- Linguagem: GDScript com tipagem estática quando aplicável.
- Jogo: ação 2D top-down.
- Entrada: teclado e mouse.
- Plataforma de desenvolvimento inicial: Windows.
- Controle de versão: Git/GitHub.
- Dependências externas: nenhuma.

## 3. Organização real

```text
res://
├── autoload/
│   └── game_state.gd
├── assets/
├── scenes/
│   ├── characters/player/player.tscn
│   ├── enemies/basic_returned/basic_returned.tscn
│   ├── items/corrupted_light_core/corrupted_light_core.tscn
│   ├── levels/prototype_arena/prototype_arena.tscn
│   ├── objects/memory_fragment/memory_fragment.tscn
│   ├── objects/respawn_altar/respawn_altar.tscn
│   └── ui/player_hud.tscn
├── scripts/
│   ├── characters/player/
│   │   ├── player.gd
│   │   ├── player_movement.gd
│   │   ├── player_combat.gd
│   │   └── player_corruption.gd
│   ├── enemies/basic_returned/basic_returned.gd
│   ├── items/corrupted_light_core.gd
│   ├── objects/
│   │   ├── memory_fragment.gd
│   │   └── respawn_altar.gd
│   ├── ui/player_hud.gd
│   └── world/prototype_arena.gd
├── systems/
│   ├── corruption_component.gd
│   ├── health_component.gd
│   ├── hitbox_component.gd
│   └── hurtbox_component.gd
├── tests/
├── ui/
├── AGENTS.md
├── ARCHITECTURE.md
├── BALANCE_LOG.md
├── CLEANUP_LOG.md
├── CYCLE_TEST_LOG.md
├── GAME_DESIGN.md
├── README.md
├── TASKS.md
└── project.godot
```

`assets`, `tests` e `ui` são diretórios reservados e podem estar vazios no
estado atual.

Não existem `event_bus.gd`, `death_screen.tscn`, `NavigationAgent2D`,
`PointLight2D` ou gerenciador de fases no protótipo.

## 4. Configuração global

A documentação usa o título **Solares**, enquanto a propriedade
`config/name` de `project.godot` permanece tecnicamente como `Solaris`.
Nenhuma configuração foi renomeada nesta atualização documental.

### Cena principal

`project.godot` define:

```text
res://scenes/levels/prototype_arena/prototype_arena.tscn
```

### Autoload

```text
GameState → res://autoload/game_state.gd
```

Não existe outro singleton.

### Input Map

| Ação | Entrada |
| --- | --- |
| `move_up` | W |
| `move_down` | S |
| `move_left` | A |
| `move_right` | D |
| `attack_primary` | Botão esquerdo do mouse |
| `dodge` | Espaço |
| `interact` | E |
| `pause` | Esc |

`pause` está configurada, mas não é consumida por nenhum script.

## 5. PrototypeArena

Arquivo:

```text
res://scenes/levels/prototype_arena/prototype_arena.tscn
```

Estrutura real:

```text
PrototypeArena (Node2D)
├── Environment (Node2D)
│   ├── Floor (Polygon2D)
│   └── Walls (Node2D)
│       ├── TopWall (StaticBody2D)
│       ├── BottomWall (StaticBody2D)
│       ├── LeftWall (StaticBody2D)
│       └── RightWall (StaticBody2D)
├── Objects (Node2D)
│   ├── RespawnAltar (Area2D)
│   └── MemoryFragment (Area2D)
├── Entities (Node2D)
│   ├── Player (CharacterBody2D)
│   └── BasicReturned × 4 (CharacterBody2D)
├── Pickups (Node2D)
├── PlayerSpawn (Marker2D)
└── CanvasLayer
    └── PlayerHUD (Control)
```

Responsabilidades de `prototype_arena.gd`:

- fornecer o PlayerSpawn fallback;
- vincular Player e HUD;
- observar a morte do jogador;
- registrar os quatro spawns iniciais;
- conectar `enemy_died`;
- instanciar núcleos no container Pickups;
- remover núcleos após a morte do jogador;
- reutilizar ou recriar exatamente um inimigo por spawn;
- solicitar `reset_enemy()` antes do jogador recuperar o controle.

A arena não controla movimento, ataque, vida interna ou corrupção.

## 6. GameState

Arquivo:

```text
res://autoload/game_state.gd
```

Responsabilidades:

- armazenar `death_count`;
- armazenar `current_respawn_position`;
- armazenar `active_altar_id`;
- indicar `has_respawn_point`;
- armazenar `collected_memory_ids`;
- impedir IDs de memória duplicados;
- limpar altar, memórias ou todo o estado do run por métodos explícitos.

O GameState:

- não procura entidades na cena;
- não movimenta o jogador;
- não controla combate;
- não salva em disco;
- persiste somente enquanto a aplicação está aberta.

## 7. Player

Cena:

```text
res://scenes/characters/player/player.tscn
```

Estrutura principal:

```text
Player (CharacterBody2D)
├── Visuals (Node2D)
│   ├── BodyVisual (Polygon2D)
│   └── ScythePivot (Node2D)
│       ├── ScytheVisual (Line2D)
│       ├── ScytheTrail (Line2D)
│       ├── AttackHitbox (HitboxComponent)
│       │   └── CollisionShape2D
│       └── AnimationPlayer
├── BodyCollision (CollisionShape2D)
├── Hurtbox (HurtboxComponent)
│   └── CollisionShape2D
├── HealthComponent
├── CorruptionComponent
├── PlayerCorruption
├── CollapseDamageTimer
├── AttackCooldown
├── DodgeDuration
├── DodgeCooldown
├── RespawnDelay
└── Camera2D
```

### `player.gd`

Coordena:

- estado global ACTIVE/DEAD;
- componentes;
- entrada e saída do estado de morte;
- cancelamento de ações;
- registro de morte no GameState;
- escolha entre altar e PlayerSpawn;
- restauração de vida e corrupção;
- emissão de morte e respawn;
- flash visual de dano.

### `player_movement.gd`

Responsável por:

- ler as ações de movimento;
- armazenar a última direção válida;
- aplicar `velocity` e `move_and_slide()`;
- estados NORMAL, DODGING e DEAD;
- duração e cooldown da esquiva;
- colisão durante esquiva.

### `player_combat.gd`

Responsável por:

- apontar o ScythePivot para o mouse;
- iniciar ataque manual;
- calcular dano a cada golpe;
- consultar o multiplicador do CorruptionComponent;
- controlar cooldown e sobreposição;
- animar o arco;
- abrir e fechar a Hitbox;
- mostrar e ocultar o rastro;
- cancelar o ataque na morte.

### `player_corruption.gd`

Responsável por:

- localizar núcleo válido pela proximidade;
- estados IDLE, ABSORBING e DEAD;
- bloquear movimento e ataque durante absorção;
- cancelar por distância, dano, remoção ou morte;
- encaminhar os valores ao CorruptionComponent;
- aplicar multiplicador de dano recebido;
- iniciar e parar o dano periódico do Colapso.

Os estados do jogador são distribuídos entre os controladores; não há uma
máquina de estados global complexa.

## 8. HealthComponent

Classe:

```gdscript
class_name HealthComponent
extends Node
```

Responsabilidades:

- vida máxima e atual;
- dano e cura;
- clamp entre zero e máximo;
- estado `is_dead`;
- emissão única de `died`;
- restauração completa e remoção do estado morto.

É reutilizado pelo jogador e pelo BasicReturned.

## 9. HitboxComponent e HurtboxComponent

### HitboxComponent

- estende `Area2D`;
- armazena dano e proprietário;
- inicia e encerra janelas de ataque;
- registra alvos atingidos no golpe atual;
- impede dano repetido no mesmo golpe;
- impede que o proprietário acerte a si próprio;
- inicia desativada.

### HurtboxComponent

- estende `Area2D`;
- referencia um HealthComponent;
- recebe HitboxComponent;
- valida alvo e proprietário;
- aplica multiplicador de dano recebido;
- encaminha dano ao HealthComponent;
- emite `damage_received`.

Fluxo:

```text
HitboxComponent entra na HurtboxComponent
↓
Hurtbox valida origem e repetição
↓
HealthComponent.take_damage()
↓
health_changed e, se necessário, died
```

Não existe sinal chamado `damaged`; o contrato implementado é
`damage_received(amount, source)`.

## 10. BasicReturned

Cena:

```text
res://scenes/enemies/basic_returned/basic_returned.tscn
```

Responsabilidades:

- estados IDLE, CHASE, ATTACK e DEAD;
- detecção por DetectionArea;
- perseguição com `velocity` e `move_and_slide()`;
- alcance por AttackArea;
- ataque com HitboxComponent e cooldown;
- vida e HurtboxComponent;
- feedback de dano;
- cancelamento de ataque e colisões na morte;
- emissão de `enemy_died`;
- fornecimento da PackedScene do núcleo uma única vez;
- remoção após atraso;
- `reset_enemy()` para restauração pela arena.

Não existe NavigationAgent2D ou pathfinding. A perseguição usa direção direta.

## 11. CorruptedLightCore

Cena:

```text
res://scenes/items/corrupted_light_core/corrupted_light_core.tscn
```

Responsabilidades:

- detectar proximidade pela InteractionArea;
- expor valores de Luz, Instabilidade e duração;
- impedir absorções simultâneas;
- controlar AbsorptionTimer;
- emitir início, conclusão e cancelamento;
- restaurar o visual ao cancelar;
- desaparecer ao concluir;
- pertencer ao grupo `corrupted_light_cores`.

O PlayerCorruption concede os recursos somente depois que
`finish_absorption()` valida o jogador e a proximidade.

## 12. CorruptionComponent

Classe:

```gdscript
class_name CorruptionComponent
extends Node
```

Responsabilidades:

- armazenar Luz e Instabilidade;
- limitar ambos entre zero e máximo;
- calcular o multiplicador de dano;
- calcular níveis de Instabilidade;
- emitir mudanças;
- zerar poder temporário.

Não acessa Input, Player, inimigos ou HUD.

## 13. RespawnAltar

Cena:

```text
res://scenes/objects/respawn_altar/respawn_altar.tscn
```

Responsabilidades:

- detectar jogador próximo;
- aceitar interação somente quando inativo;
- registrar ID e posição do RespawnMarker no GameState;
- emitir `altar_activated` uma única vez;
- esconder o prompt depois da ativação;
- manter brilho ativo;
- restaurar visual se o ID já for o altar atual.

O protótipo não usa PointLight2D; o brilho é provisório e feito com Polygon2D
e AnimationPlayer.

## 14. MemoryFragment

Cena:

```text
res://scenes/objects/memory_fragment/memory_fragment.tscn
```

Responsabilidades:

- detectar proximidade;
- registrar um `StringName` não vazio;
- delegar prevenção de duplicação ao GameState;
- emitir `memory_remembered` quando o registro é novo;
- desaparecer após coleta;
- não reaparecer se seu ID já estiver registrado;
- pertencer ao grupo `persistent_memories`.

A persistência existe apenas durante a execução.

## 15. PlayerHUD

Cena:

```text
res://scenes/ui/player_hud.tscn
```

Responsabilidades:

- observar HealthComponent e CorruptionComponent;
- mostrar vida, Luz e Instabilidade;
- observar o contador do GameState;
- mostrar prompts de núcleo, altar e memória;
- mostrar `COLLAPSE`;
- pulsar conforme o nível de Instabilidade;
- mostrar e ocultar DeathOverlay;
- substituir Tweens anteriores para evitar acúmulo.

O HUD não altera vida, corrupção, altar, memória ou estado do jogador.

## 16. Sinais principais

| Origem | Sinal | Consumidor principal |
| --- | --- | --- |
| HealthComponent | `health_changed` | HUD e feedback inimigo |
| HealthComponent | `died` | Player ou BasicReturned |
| HurtboxComponent | `damage_received` | Player e PlayerCorruption |
| CorruptionComponent | `corrupted_light_changed` | HUD |
| CorruptionComponent | `instability_changed` | HUD |
| CorruptionComponent | `instability_level_changed` | HUD e PlayerCorruption |
| Player | `player_died` | PrototypeArena e HUD |
| Player | `player_respawned` | HUD |
| BasicReturned | `enemy_died` | PrototypeArena |
| CorruptedLightCore | sinais de interação/absorção | PlayerCorruption e HUD |
| RespawnAltar | `altar_activated` | HUD |
| MemoryFragment | `memory_remembered` | contrato do objeto |
| GameState | `death_count_changed` | HUD |
| GameState | `respawn_point_changed` | contrato global |
| GameState | `memory_collected` | contrato global |

Conexões dinâmicas de núcleos e HUD são verificadas com `is_connected()` ou
desconectadas quando o objeto deixa de ser válido.

## 17. Grupos

| Grupo | Uso |
| --- | --- |
| `common_enemies` | Registro e restauração dos quatro spawns |
| `corrupted_light_cores` | Localização para absorção e limpeza na morte |
| `respawn_altars` | Identificação de altares |
| `persistent_memories` | Identificação de memórias do run |

Não existe grupo `bosses` no protótipo atual.

## 18. Camadas de colisão

```text
Camada 1: World
Camada 2: PlayerBody
Camada 3: EnemyBody
Camada 4: PlayerHitbox
Camada 5: EnemyHitbox
Camada 6: PlayerHurtbox
Camada 7: EnemyHurtbox
Camada 8: Interactable
Camada 9: Pickup
```

Relações principais:

- PlayerHitbox detecta EnemyHurtbox;
- EnemyHitbox detecta PlayerHurtbox;
- corpos colidem com o mundo e entre si conforme as máscaras;
- áreas de interação detectam PlayerBody;
- núcleos não bloqueiam movimento.

## 19. Fluxo completo

```text
BasicReturned recebe dano
↓
HealthComponent emite died
↓
BasicReturned entra em DEAD e emite enemy_died
↓
PrototypeArena instancia CorruptedLightCore em Pickups
↓
Jogador inicia e conclui absorção
↓
PlayerCorruption chama CorruptionComponent.absorb()
↓
Luz e Instabilidade aumentam e HUD recebe sinais
↓
Jogador recebe dano e morre
↓
Player bloqueia ações e registra morte no GameState
↓
Player emite player_died
↓
PrototypeArena cancela/remover núcleos e restaura inimigos
↓
RespawnDelay termina
↓
Player retorna ao altar ou PlayerSpawn
↓
Vida é restaurada; Luz e Instabilidade são zeradas
↓
Controles retornam e player_respawned é emitido
```

Preservado durante a execução:

- contador de mortes;
- último altar;
- posição de respawn;
- IDs de memórias.

Não preservado após a morte:

- vida reduzida;
- Luz;
- Instabilidade;
- núcleos;
- estado dos inimigos.

## 20. Prevenção de duplicação

- HitboxComponent registra alvos por golpe.
- HealthComponent emite morte uma vez por estado de vida.
- BasicReturned protege emissão e drop com flags.
- Cada Dictionary de spawn mantém uma única referência de inimigo.
- PrototypeArena reutiliza a referência válida ou recria somente quando ela
  foi removida.
- GameState recusa IDs de memória já coletados.
- RespawnAltar recusa nova ativação quando ativo.
- Tweens visuais anteriores são mortos antes de substituição.

Sete restaurações consecutivas confirmaram no máximo um BasicReturned por
spawn.

## 21. Limitações arquiteturais

- Sem salvamento em disco.
- Sem gerenciador de fases.
- Sem EventBus.
- Sem sistema global de áudio.
- Sem recursos audiovisuais finais.
- Uma única arena de protótipo.
- Um tipo de inimigo.
- Sem chefe.
- Sem NavigationAgent2D ou pathfinding.
- Sem menu ou lógica de pausa.
- GameState persiste somente durante a execução atual.
- Estados do jogador são coordenados por controladores simples.

## 22. Princípios preservados

- Composição para sistemas reutilizáveis.
- Responsabilidades separadas.
- Sinais para eventos.
- HUD observador, não controlador.
- Valores de balanceamento exportados.
- Ausência de caminhos absolutos frágeis.
- Crescimento incremental e compatibilidade com Godot 4.x.
- Nenhuma dependência externa.

## 23. Estado arquitetural

O ciclo técnico do protótipo foi implementado, balanceado inicialmente,
validado, repetido sem duplicações e limpo de instrumentação provisória.

A arquitetura está pronta para uma próxima fase de desenvolvimento, mas não
representa a arquitetura de um jogo completo.
