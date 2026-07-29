# Projeto Solaris — Arquitetura Técnica

## 1. Objetivo deste documento

Este documento define a arquitetura técnica inicial do Projeto Solaris.

Ele deve orientar a criação de:

* cenas;
* scripts;
* componentes;
* sistemas;
* sinais;
* interface;
* fluxo de morte e renascimento;
* primeiro protótipo jogável.

O projeto será desenvolvido em pequenas etapas.

A arquitetura poderá evoluir, mas alterações estruturais deverão ser justificadas e documentadas.

---

# 2. Tecnologias

* Engine: Godot 4.x.
* Linguagem: GDScript.
* Plataforma inicial: Windows PC.
* Tipo de jogo: ação 2D com visão superior.
* Controles: teclado e mouse.
* Controle de versão: Git.
* Documentação: Markdown.

---

# 3. Organização inicial do projeto

```text
res://
├── autoload/
│   ├── game_state.gd
│   └── event_bus.gd
│
├── assets/
│   ├── audio/
│   │   ├── music/
│   │   └── sound_effects/
│   ├── fonts/
│   ├── sprites/
│   │   ├── characters/
│   │   ├── enemies/
│   │   ├── environment/
│   │   ├── effects/
│   │   └── ui/
│   └── tilesets/
│
├── scenes/
│   ├── characters/
│   │   └── player/
│   │       └── player.tscn
│   ├── enemies/
│   │   └── basic_returned/
│   │       └── basic_returned.tscn
│   ├── items/
│   │   └── corrupted_light_core/
│   │       └── corrupted_light_core.tscn
│   ├── levels/
│   │   └── prototype_arena/
│   │       └── prototype_arena.tscn
│   ├── objects/
│   │   └── respawn_altar/
│   │       └── respawn_altar.tscn
│   └── ui/
│       ├── player_hud.tscn
│       └── death_screen.tscn
│
├── scripts/
│   ├── characters/
│   │   └── player/
│   │       ├── player.gd
│   │       ├── player_movement.gd
│   │       ├── player_combat.gd
│   │       └── player_corruption.gd
│   ├── enemies/
│   │   └── basic_returned/
│   │       └── basic_returned.gd
│   ├── items/
│   │   └── corrupted_light_core.gd
│   ├── objects/
│   │   └── respawn_altar.gd
│   └── world/
│       └── prototype_arena.gd
│
├── systems/
│   ├── health_component.gd
│   ├── hitbox_component.gd
│   ├── hurtbox_component.gd
│   └── corruption_component.gd
│
├── tests/
├── ui/
├── AGENTS.md
├── ARCHITECTURE.md
├── GAME_DESIGN.md
├── README.md
├── TASKS.md
└── project.godot
```

Pastas e arquivos devem ser criados apenas quando forem necessários para a tarefa atual.

Não criar todos os scripts vazios antecipadamente.

---

# 4. Cena principal do protótipo

A primeira fase jogável será representada por:

```text
res://scenes/levels/prototype_arena/prototype_arena.tscn
```

Estrutura inicial:

```text
PrototypeArena (Node2D)
├── Environment (Node2D)
│   ├── Floor (TileMapLayer)
│   ├── Walls (TileMapLayer)
│   └── Decorations (Node2D)
│
├── Objects (Node2D)
│   └── RespawnAltar (Area2D)
│
├── Entities (Node2D)
│   ├── Player (CharacterBody2D)
│   └── Enemies (Node2D)
│
├── Pickups (Node2D)
├── CameraLimits (Node2D)
├── CanvasLayer
│   └── PlayerHUD (Control)
└── PrototypeArenaController (Node)
```

## Responsabilidades da fase

A fase deverá:

* conter os limites do mapa;
* instanciar ou posicionar o jogador;
* conter inimigos;
* conter altares;
* receber núcleos deixados por inimigos;
* configurar os limites da câmera;
* controlar objetivos específicos da arena;
* reagir à morte e ao renascimento do jogador.

A fase não deverá controlar diretamente:

* movimentação do jogador;
* ataque;
* vida interna dos inimigos;
* atualização visual das barras;
* lógica interna da Luz Corrompida.

---

# 5. Cena do jogador

Arquivo:

```text
res://scenes/characters/player/player.tscn
```

Estrutura proposta:

```text
Player (CharacterBody2D)
├── Visuals (Node2D)
│   ├── BodySprite (Sprite2D)
│   ├── ScythePivot (Node2D)
│   │   ├── ScytheSprite (Sprite2D)
│   │   └── AttackHitbox (Area2D)
│   │       └── CollisionShape2D
│   └── AnimationPlayer
│
├── BodyCollision (CollisionShape2D)
├── Hurtbox (Area2D)
│   └── CollisionShape2D
├── HealthComponent (Node)
├── CorruptionComponent (Node)
├── AttackCooldown (Timer)
├── DodgeCooldown (Timer)
├── DodgeDuration (Timer)
└── Camera2D
```

## Nó principal

O jogador deverá utilizar:

```text
CharacterBody2D
```

Isso permitirá:

* movimentação;
* detecção de colisão;
* interação com paredes;
* uso de `move_and_slide()`.

---

# 6. Scripts do jogador

## 6.1 `player.gd`

Responsável por coordenar os sistemas do jogador.

Responsabilidades:

* acessar os componentes;
* reagir à morte;
* ativar ou desativar controles;
* coordenar movimento e combate;
* emitir eventos gerais do jogador;
* iniciar o processo de renascimento.

Não deverá conter toda a implementação de movimento, combate e corrupção.

---

## 6.2 `player_movement.gd`

Responsável por:

* ler entradas de movimento;
* normalizar a direção;
* alterar a velocidade;
* executar `move_and_slide()`;
* controlar a esquiva;
* impedir movimento quando o jogador estiver morto;
* impedir ações durante estados incompatíveis.

Variáveis exportadas sugeridas:

```gdscript
@export var movement_speed: float = 220.0
@export var dodge_speed: float = 520.0
@export var dodge_duration: float = 0.20
@export var dodge_cooldown: float = 1.0
```

Esses valores são provisórios.

---

## 6.3 `player_combat.gd`

Responsável por:

* detectar a posição do mouse;
* calcular a direção do ataque;
* rotacionar o pivô da foice;
* controlar o ataque básico;
* ativar e desativar a hitbox;
* respeitar o intervalo entre ataques;
* calcular o dano atual;
* aplicar bônus de Luz Corrompida.

Variáveis exportadas sugeridas:

```gdscript
@export var base_damage: float = 20.0
@export var attack_cooldown: float = 0.5
@export var attack_duration: float = 0.15
```

O primeiro ataque será um golpe frontal em arco com a foice.

---

## 6.4 `player_corruption.gd`

Responsável pela interação do jogador com:

* Luz Corrompida;
* Instabilidade;
* núcleos absorvíveis;
* bônus temporários;
* penalidades temporárias;
* perda dos recursos após a morte.

A lógica numérica reutilizável deverá ficar no `CorruptionComponent`.

---

# 7. Foice de Horiel

A arma inicial será uma foice inspirada em Horiel, personagem do criador do Projeto Solaris.

Essa referência deverá ser tratada como homenagem interna ao projeto.

## Funcionamento inicial

A foice deverá:

* acompanhar a direção do mouse;
* permanecer presa a um pivô;
* executar um movimento em arco;
* possuir alcance corpo a corpo;
* poder atingir múltiplos inimigos próximos;
* causar dano apenas durante a janela ativa do ataque.

## Estrutura

```text
ScythePivot (Node2D)
├── ScytheSprite (Sprite2D)
└── AttackHitbox (Area2D)
    └── CollisionShape2D
```

O `ScythePivot` deverá rotacionar na direção do mouse.

Durante o ataque, o pivô ou o sprite deverá realizar uma rotação em arco.

## Primeira implementação

No primeiro protótipo, a animação poderá ser feita por:

* `Tween`; ou
* `AnimationPlayer`.

Preferência inicial:

```text
AnimationPlayer
```

A hitbox deverá ser ativada somente durante uma parte da animação.

---

# 8. Componente de vida

Arquivo:

```text
res://systems/health_component.gd
```

Esse componente deverá ser reutilizável por jogadores e inimigos.

Responsabilidades:

* armazenar vida máxima;
* armazenar vida atual;
* receber dano;
* recuperar vida;
* impedir valores inválidos;
* emitir alterações de vida;
* emitir morte.

Interface sugerida:

```gdscript
class_name HealthComponent
extends Node

signal health_changed(current_health: float, maximum_health: float)
signal died

@export var maximum_health: float = 100.0

var current_health: float
var is_dead: bool = false

func take_damage(amount: float) -> void:
    pass

func heal(amount: float) -> void:
    pass

func restore_full_health() -> void:
    pass
```

Esse código é apenas uma definição arquitetural.

A implementação será feita em uma tarefa separada.

---

# 9. Hitbox e Hurtbox

## Hitbox

A Hitbox representa uma área que causa dano.

Arquivo:

```text
res://systems/hitbox_component.gd
```

Ela deverá armazenar ou receber:

* quantidade de dano;
* origem do ataque;
* proprietário do ataque;
* possibilidade de atingir um alvo apenas uma vez por golpe.

## Hurtbox

A Hurtbox representa uma área que pode receber dano.

Arquivo:

```text
res://systems/hurtbox_component.gd
```

Ela deverá:

* detectar uma Hitbox;
* localizar o componente de vida;
* solicitar a aplicação do dano;
* impedir dano de fontes inválidas;
* evitar que uma entidade cause dano a si mesma.

## Fluxo de dano

```text
Ataque é iniciado
↓
Hitbox da foice é ativada
↓
Hitbox entra na Hurtbox do inimigo
↓
Hurtbox solicita dano ao HealthComponent
↓
HealthComponent reduz a vida
↓
HealthComponent emite health_changed
↓
Se a vida chegar a zero, emite died
```

---

# 10. Cena do inimigo básico

Arquivo:

```text
res://scenes/enemies/basic_returned/basic_returned.tscn
```

Estrutura proposta:

```text
BasicReturned (CharacterBody2D)
├── Visuals (Node2D)
│   ├── BodySprite (Sprite2D)
│   └── AnimationPlayer
├── BodyCollision (CollisionShape2D)
├── Hurtbox (Area2D)
│   └── CollisionShape2D
├── AttackArea (Area2D)
│   └── CollisionShape2D
├── DetectionArea (Area2D)
│   └── CollisionShape2D
├── HealthComponent (Node)
├── AttackCooldown (Timer)
└── NavigationAgent2D
```

## Comportamento inicial

O inimigo deverá possuir os estados:

```text
IDLE
CHASE
ATTACK
DEAD
```

### IDLE

* permanece parado ou realiza pequeno movimento;
* procura pelo jogador;
* muda para `CHASE` ao detectar o jogador.

### CHASE

* move-se em direção ao jogador;
* muda para `ATTACK` quando estiver próximo;
* volta para `IDLE` caso perca o jogador.

### ATTACK

* interrompe ou reduz o movimento;
* causa dano ao jogador;
* respeita tempo de recarga;
* retorna para `CHASE` se o jogador se afastar.

### DEAD

* interrompe movimento;
* desativa colisões;
* impede novos ataques;
* reproduz efeito provisório;
* cria um núcleo de Luz Corrompida;
* remove o inimigo da cena.

---

# 11. Núcleo de Luz Corrompida

Arquivo:

```text
res://scenes/items/corrupted_light_core/corrupted_light_core.tscn
```

Estrutura proposta:

```text
CorruptedLightCore (Area2D)
├── Sprite2D
├── CollisionShape2D
├── InteractionArea (Area2D)
│   └── CollisionShape2D
├── AbsorptionTimer (Timer)
└── AnimationPlayer
```

## Funcionamento

Quando um inimigo morrer:

1. o inimigo instancia um núcleo;
2. o núcleo aparece próximo ao local da morte;
3. o núcleo permanece no chão;
4. o jogador precisa se aproximar;
5. o jogador mantém ou pressiona `E`;
6. a absorção é iniciada;
7. o jogador fica temporariamente vulnerável;
8. a Luz Corrompida é adicionada;
9. a Instabilidade aumenta;
10. o núcleo é removido.

## Valores provisórios

```text
Luz recebida: 10
Instabilidade recebida: 6
Tempo de absorção: 0,75 segundo
Tempo até desaparecer: ainda não definido
```

O núcleo não deverá ser coletado automaticamente.

---

# 12. Componente de corrupção

Arquivo:

```text
res://systems/corruption_component.gd
```

Responsabilidades:

* armazenar Luz Corrompida;
* armazenar Instabilidade;
* limitar valores;
* calcular bônus temporários;
* calcular penalidades;
* emitir sinais;
* limpar os valores temporários após a morte.

Interface inicial sugerida:

```gdscript
class_name CorruptionComponent
extends Node

signal corrupted_light_changed(current: float, maximum: float)
signal instability_changed(current: float, maximum: float)
signal instability_level_changed(level: int)

@export var maximum_corrupted_light: float = 100.0
@export var maximum_instability: float = 100.0

var corrupted_light: float = 0.0
var instability: float = 0.0

func absorb(light_amount: float, instability_amount: float) -> void:
    pass

func reset_temporary_power() -> void:
    pass

func get_damage_multiplier() -> float:
    return 1.0
```

---

# 13. Instabilidade

A primeira versão deverá possuir três níveis:

```text
Nível 0 — Estável
Instabilidade entre 0 e 69.

Nível 1 — Sobrecarregado
Instabilidade entre 70 e 89.

Nível 2 — Colapso
Instabilidade entre 90 e 100.
```

## Penalidades provisórias

### Estável

* sem penalidade grave.

### Sobrecarregado

* jogador recebe mais dano.

### Colapso

* jogador perde vida ao longo do tempo.

As penalidades deverão ser implementadas apenas após o sistema básico de corrupção funcionar.

---

# 14. Altar de renascimento

Arquivo:

```text
res://scenes/objects/respawn_altar/respawn_altar.tscn
```

Estrutura proposta:

```text
RespawnAltar (Area2D)
├── Sprite2D
├── CollisionShape2D
├── InteractionArea (Area2D)
│   └── CollisionShape2D
├── RespawnMarker (Marker2D)
├── AnimationPlayer
└── PointLight2D
```

## Funcionamento

O altar deverá:

* ser ativado quando o jogador interagir;
* armazenar a posição do `RespawnMarker`;
* tornar-se o novo ponto de renascimento;
* apresentar uma indicação visual de ativação;
* informar ao `GameState` qual altar está ativo.

Somente um altar deverá ser considerado o último altar ativo.

## Ativação

Fluxo inicial:

```text
Jogador entra na área
↓
Interface mostra “Pressione E para ativar”
↓
Jogador pressiona E
↓
Altar é ativado
↓
Posição do RespawnMarker é registrada
↓
GameState atualiza o ponto de renascimento
↓
Efeito visual é reproduzido
```

---

# 15. GameState

Arquivo:

```text
res://autoload/game_state.gd
```

Esse script deverá ser configurado como Autoload.

Responsabilidades iniciais:

* armazenar quantidade de mortes;
* armazenar posição atual de renascimento;
* identificar o último altar ativado;
* preservar informações durante recarregamentos de cenas;
* coordenar dados permanentes simples.

Estrutura sugerida:

```gdscript
extends Node

signal death_count_changed(new_value: int)
signal respawn_point_changed(new_position: Vector2)

var death_count: int = 0
var current_respawn_position: Vector2 = Vector2.ZERO
var active_altar_id: StringName = &""

func register_death() -> void:
    pass

func set_respawn_point(position: Vector2, altar_id: StringName) -> void:
    pass
```

O `GameState` não deverá controlar diretamente movimentação ou combate.

---

# 16. EventBus

Arquivo:

```text
res://autoload/event_bus.gd
```

O EventBus deverá conter somente eventos globais realmente necessários.

Possíveis sinais iniciais:

```gdscript
signal player_died
signal player_respawned
signal altar_activated(altar_id: StringName)
signal corrupted_light_absorbed(amount: float)
```

Não utilizar o EventBus para toda comunicação do projeto.

Comunicação local deverá utilizar referências diretas ou sinais locais.

---

# 17. Fluxo de morte e renascimento

Quando a vida do jogador chegar a zero:

```text
HealthComponent emite died
↓
Player entra no estado DEAD
↓
Movimentação é desativada
↓
Ataques são desativados
↓
Colisões ofensivas são desativadas
↓
GameState incrementa o contador de mortes
↓
CorruptionComponent remove Luz Corrompida e Instabilidade
↓
Efeito ou tela de morte é mostrado
↓
Jogador é movido para o último RespawnMarker
↓
Vida é restaurada
↓
Estados são reiniciados
↓
Controles são reativados
↓
Player emite player_respawned
```

## Primeiro ponto de renascimento

Caso nenhum altar tenha sido ativado, o jogador deverá renascer no ponto inicial da fase.

A fase deverá possuir um `Marker2D` inicial para esse propósito.

---

# 18. Restauração da fase após a morte

Quando o jogador morrer e renascer no último altar ativado, a fase deverá restaurar seus elementos de gameplay conforme as regras abaixo.

## 18.1 Inimigos comuns

Todos os inimigos comuns deverão reaparecer.

Ao serem restaurados, deverão retornar com:

* vida máxima;
* posição inicial;
* estado inicial;
* colisões ativadas;
* inteligência artificial reiniciada;
* efeitos temporários removidos.

Inimigos comuns mortos antes da morte do jogador não permanecerão mortos.

---

## 18.2 Núcleos de Luz Corrompida

Todos os núcleos de Luz Corrompida que estiverem no chão deverão desaparecer quando o jogador morrer.

Isso inclui:

* núcleos ainda não absorvidos;
* núcleos em processo de absorção;
* núcleos deixados por inimigos antes da morte.

Após o renascimento, novos núcleos somente poderão ser obtidos derrotando novamente os inimigos.

Essa regra impede que o jogador acumule núcleos sem enfrentar novamente os riscos da fase.

---

## 18.3 Chefes

Quando o jogador morrer durante uma batalha contra um chefe, o chefe deverá ser completamente restaurado.

O chefe deverá retornar com:

* vida máxima;
* posição inicial;
* fase inicial do combate;
* estados reiniciados;
* efeitos temporários removidos;
* arena restaurada;
* ataques e recargas reiniciados.

O dano causado antes da morte do jogador não deverá permanecer.

Chefes derrotados permanentemente não deverão reaparecer, salvo quando a fase for repetida por escolha do jogador ou por alguma regra futura.

O primeiro protótipo não terá chefe.

---

## 18.4 Memórias

Memórias coletadas deverão permanecer registradas após a morte.

Uma memória já coletada:

* não deverá ser perdida;
* não precisará ser coletada novamente;
* deverá permanecer registrada no estado da partida;
* poderá desaparecer visualmente do mapa;
* poderá continuar disponível para consulta futura.

Memórias representam conhecimento preservado pelo Camponês Sem Nome e fazem parte da progressão permanente.

No primeiro protótipo, essa permanência existirá somente durante a execução atual do jogo.

A persistência após fechar o jogo será implementada futuramente por um sistema de salvamento.

---

## 18.5 Altares

Altares já ativados deverão continuar ativos após a morte do jogador.

O último altar ativado continuará sendo o ponto atual de renascimento.

Ao renascer:

* o altar deverá permanecer visualmente ativo;
* sua identificação deverá continuar registrada;
* sua posição deverá continuar sendo o ponto de renascimento;
* o jogador não precisará ativá-lo novamente.

Ativar um novo altar substituirá o altar anterior como ponto de renascimento atual.

No primeiro protótipo, os altares permanecerão ativos somente enquanto o jogo estiver aberto.

A persistência entre sessões será adicionada posteriormente pelo sistema de salvamento.

---

## 18.6 Objetos e ambiente

Elementos permanentes do cenário deverão manter seu estado quando fizer sentido narrativo.

Exemplos de elementos que podem permanecer alterados:

* memórias coletadas;
* atalhos abertos;
* portas permanentes;
* altares ativados;
* eventos narrativos concluídos.

Elementos ligados ao combate deverão ser restaurados.

Exemplos:

* inimigos comuns;
* vida dos chefes;
* projéteis;
* armadilhas temporárias;
* efeitos de área;
* núcleos de Luz Corrompida;
* objetos temporários criados durante combates.

No primeiro protótipo, somente inimigos, núcleos, jogador e altar precisarão seguir essas regras.

---

## 18.7 Ordem de restauração

O fluxo inicial deverá seguir esta ordem:

```text
Jogador morre
↓
Controles e ataques são desativados
↓
Contador de mortes aumenta
↓
Luz Corrompida e Instabilidade são removidas
↓
Núcleos existentes são removidos
↓
Inimigos comuns são restaurados
↓
Chefes ativos são restaurados
↓
Memórias coletadas são preservadas
↓
Altares ativados são preservados
↓
Jogador retorna ao último altar
↓
Vida do jogador é restaurada
↓
Controles são reativados
```

A restauração deverá acontecer antes de o jogador recuperar o controle.

---

## 18.8 Responsabilidade técnica

A restauração não deverá ficar concentrada inteiramente no script do jogador.

Responsabilidades recomendadas:

* `Player`: informar que morreu e executar seu renascimento;
* `GameState`: preservar contador de mortes, altar ativo e memórias;
* `PrototypeArena`: restaurar inimigos e remover núcleos;
* inimigos: possuir uma função de restauração individual;
* chefes: possuir uma função própria de reinicialização;
* núcleos: pertencer a um grupo que possa ser removido pela fase.

Grupos sugeridos:

```text
common_enemies
bosses
corrupted_light_cores
respawn_altars
persistent_memories
```

A fase poderá utilizar esses grupos para localizar e restaurar elementos sem depender de caminhos frágeis na árvore de nós.

---

## 18.9 Regra confirmada

Após a morte do jogador:

* inimigos comuns reaparecem;
* núcleos de Luz Corrompida desaparecem;
* chefes recuperam toda a vida;
* memórias permanecem coletadas;
* altares permanecem ativados;
* o jogador renasce no último altar ativado.


---

# 19. Câmera

A câmera será filha do jogador.

Configuração inicial:

```text
Camera2D
├── Enabled: true
├── Position Smoothing Enabled: true
├── Position Smoothing Speed: 5
├── Zoom: Vector2(1, 1)
└── Ignore Rotation: true
```

A câmera deverá:

* manter o jogador no centro;
* acompanhar suavemente seu movimento;
* não rotacionar com a foice;
* respeitar os limites da arena;
* não mostrar áreas fora do mapa.

Os limites deverão ser configurados pela fase.

---

# 20. Interface do jogador

Arquivo:

```text
res://scenes/ui/player_hud.tscn
```

Estrutura proposta:

```text
PlayerHUD (Control)
├── MarginContainer
│   └── VBoxContainer
│       ├── HealthSection
│       │   ├── HealthLabel
│       │   └── HealthBar
│       ├── CorruptedLightSection
│       │   ├── CorruptedLightLabel
│       │   └── CorruptedLightBar
│       └── InstabilitySection
│           ├── InstabilityLabel
│           └── InstabilityBar
├── DeathCounterLabel
└── InteractionPrompt
```

## Regras

A interface deverá:

* observar sinais;
* não alterar diretamente vida ou corrupção;
* mostrar vida;
* mostrar Luz Corrompida;
* mostrar Instabilidade;
* mostrar contador de mortes;
* mostrar instruções de interação;
* permanecer separada da lógica do jogador.

---

# 21. Camadas de colisão

Proposta inicial:

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

As máscaras deverão ser configuradas para evitar colisões desnecessárias.

Exemplo:

* `PlayerHitbox` detecta `EnemyHurtbox`;
* `EnemyHitbox` detecta `PlayerHurtbox`;
* `Interactable` detecta o jogador;
* núcleos detectam a área de interação do jogador.

---

# 22. Input Map

As seguintes ações deverão ser configuradas no Godot:

```text
move_up
move_down
move_left
move_right
attack_primary
dodge
interact
pause
```

Mapeamento inicial:

```text
move_up: W
move_down: S
move_left: A
move_right: D
attack_primary: botão esquerdo do mouse
dodge: Espaço
interact: E
pause: Esc
```

O código não deverá verificar teclas físicas diretamente.

Sempre utilizar ações do Input Map.

---

# 23. Estados do jogador

O jogador deverá possuir estados simples:

```text
NORMAL
ATTACKING
DODGING
ABSORBING
DEAD
```

## Regras

### NORMAL

* pode mover;
* pode atacar;
* pode esquivar;
* pode interagir.

### ATTACKING

* executa ataque;
* pode ter movimento limitado;
* não inicia outro ataque durante a recuperação.

### DODGING

* executa deslocamento rápido;
* não pode atacar;
* não pode absorver.

### ABSORBING

* permanece vulnerável;
* movimento fica desativado ou reduzido;
* absorção pode ser interrompida por dano.

### DEAD

* todos os comandos ficam desativados;
* aguarda renascimento.

No primeiro protótipo, os estados poderão ser controlados por enumeração simples.

Não é necessário criar uma máquina de estados complexa antecipadamente.

---

# 24. Persistência

No primeiro protótipo, o projeto deverá preservar apenas durante a execução:

* contador de mortes;
* último altar;
* posição de renascimento;
* memórias provisórias, caso existam.

Um sistema de salvamento em disco não será implementado inicialmente.

O sistema de save será criado somente após o ciclo principal funcionar.

---

# 25. Ordem de implementação

A implementação deverá seguir esta ordem:

1. configurar estrutura mínima;
2. configurar Input Map;
3. criar arena de teste;
4. criar jogador;
5. implementar movimentação;
6. adicionar câmera;
7. implementar componente de vida;
8. implementar foice e ataque;
9. implementar inimigo básico;
10. implementar dano;
11. implementar morte do inimigo;
12. criar núcleo de Luz Corrompida;
13. implementar absorção;
14. implementar Instabilidade;
15. criar interface;
16. criar altar;
17. implementar morte do jogador;
18. implementar renascimento;
19. restaurar inimigos;
20. ajustar e testar o ciclo completo.

Cada item deverá ser tratado como uma tarefa separada ou como um pequeno grupo de tarefas relacionadas.

---

# 26. Princípios técnicos

O projeto deverá seguir estes princípios:

* começar simples;
* testar cada sistema isoladamente;
* reutilizar componentes;
* usar sinais para eventos;
* não misturar interface e gameplay;
* não criar sistemas futuros antecipadamente;
* exportar valores de balanceamento;
* evitar referências frágeis;
* validar nós obrigatórios;
* documentar decisões;
* manter compatibilidade com Godot 4.x.

---

# 27. Critério arquitetural do protótipo

A arquitetura inicial será considerada funcional quando:

* o jogador puder mover-se;
* a câmera funcionar;
* a foice atacar;
* o inimigo perseguir;
* o dano funcionar;
* jogador e inimigo puderem morrer;
* o inimigo deixar um núcleo;
* o jogador puder absorver o núcleo;
* a corrupção alterar temporariamente o jogador;
* o altar puder ser ativado;
* o jogador renascer no último altar;
* o contador de mortes permanecer;
* o projeto executar sem erros.

---

# 28. Decisões confirmadas

As seguintes decisões já foram aprovadas:

* jogo 2D;
* visão superior;
* fases fechadas;
* fases completas planejadas para aproximadamente 30 minutos;
* primeiro protótipo entre cinco e dez minutos;
* câmera acompanhando o jogador;
* jogador centralizado;
* ataque manual;
* teclado e mouse;
* arma inicial: foice;
* foice inspirada em Horiel;
* inimigos deixam núcleos de Luz Corrompida;
* absorção exige interação;
* renascimento no último altar ativado;
* progressão temporária perdida após a morte;
* memórias e contador de mortes permanecem.
