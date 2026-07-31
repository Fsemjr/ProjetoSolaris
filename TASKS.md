# Projeto Solaris — Lista de Tarefas

## 1. Objetivo deste documento

Este arquivo organiza o desenvolvimento do Projeto Solaris em tarefas pequenas, testáveis e sequenciais.

Cada tarefa deve:

* possuir um objetivo claro;
* modificar apenas os arquivos necessários;
* produzir um resultado verificável;
* ser testada antes de ser concluída;
* respeitar o `AGENTS.md`;
* respeitar o `GAME_DESIGN.md`;
* respeitar o `ARCHITECTURE.md`.

O agente de programação não deve implementar várias etapas futuras sem autorização.

---

# 2. Regras de execução

Antes de iniciar qualquer tarefa, o agente deve:

1. ler `AGENTS.md`;
2. ler `GAME_DESIGN.md`;
3. ler `ARCHITECTURE.md`;
4. ler este `TASKS.md`;
5. verificar o estado atual do projeto;
6. identificar arquivos relacionados;
7. confirmar que a tarefa anterior está funcional.

Durante a implementação:

* alterar somente arquivos necessários;
* não implementar recursos futuros;
* não instalar plugins externos;
* não alterar a arquitetura sem justificar;
* utilizar Godot 4.x;
* utilizar GDScript;
* utilizar tipagem sempre que possível;
* utilizar ações do Input Map;
* evitar código duplicado;
* manter cada script com responsabilidade clara.

Depois da implementação:

* executar o projeto;
* verificar erros de parser;
* verificar o debugger;
* testar manualmente;
* informar arquivos criados;
* informar arquivos modificados;
* explicar como testar;
* registrar limitações.

---

# 3. Status das tarefas

Utilizar os seguintes marcadores:

```text
[ ] Não iniciada
[~] Em andamento
[x] Concluída
[!] Bloqueada
```

Uma tarefa só pode receber `[x]` depois de ser testada.

---

# 4. Marco 1 — Configuração inicial

## TASK-001 — Verificar estrutura do projeto

**Status:** `[x]`

### Objetivo

Verificar se o projeto Godot possui a estrutura básica definida na arquitetura.

### Verificações

Confirmar a existência dos arquivos:

```text
AGENTS.md
GAME_DESIGN.md
ARCHITECTURE.md
TASKS.md
README.md
project.godot
```

Confirmar ou criar somente as pastas iniciais necessárias:

```text
autoload/
assets/
scenes/
scripts/
systems/
tests/
ui/
```

### Regras

* Não criar scripts vazios sem necessidade.
* Não criar todas as subpastas futuras antecipadamente.
* Não modificar o conteúdo dos documentos sem necessidade.

### Critérios de conclusão

* projeto abre no Godot;
* não existem erros de importação;
* arquivos Markdown estão na raiz;
* estrutura mínima está organizada.

### Como testar

1. Abrir o projeto no Godot.
2. Confirmar que `project.godot` foi reconhecido.
3. Verificar o painel FileSystem.
4. Confirmar ausência de erros no Output.

---

## TASK-002 — Configurar Input Map

**Status:** `[x]`

### Objetivo

Criar as ações de entrada necessárias para o primeiro protótipo.

### Ações obrigatórias

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

### Mapeamento inicial

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

### Regras

* Não verificar teclas diretamente nos scripts.
* Todo código futuro deverá utilizar as ações do Input Map.
* Não configurar controle de videogame nesta etapa.

### Critérios de conclusão

* todas as ações aparecem no Input Map;
* nenhuma ação possui nome duplicado;
* o projeto executa sem erros.

### Como testar

1. Abrir `Project Settings`.
2. Acessar `Input Map`.
3. Verificar todas as ações.
4. Confirmar as teclas associadas.

---

# 5. Marco 2 — Arena de protótipo

## TASK-003 — Criar cena da arena

**Status:** `[x]`

### Objetivo

Criar uma arena simples para testar movimentação e combate.

### Arquivo

```text
res://scenes/levels/prototype_arena/prototype_arena.tscn
```

### Estrutura mínima

```text
PrototypeArena (Node2D)
├── Environment (Node2D)
├── Objects (Node2D)
├── Entities (Node2D)
├── Pickups (Node2D)
├── PlayerSpawn (Marker2D)
└── CanvasLayer
```

### Requisitos

* arena deve possuir chão visível;
* arena deve possuir limites físicos;
* utilizar formas e cores provisórias;
* não utilizar arte final;
* possuir espaço suficiente para movimentação;
* possuir um ponto inicial para o jogador.

### Regras

* não criar mapa grande;
* não criar TileSet complexo;
* não criar decoração detalhada;
* não criar inimigos nesta tarefa.

### Critérios de conclusão

* arena pode ser executada como cena principal;
* chão aparece;
* limites existem;
* não há erros.

### Como testar

1. Executar `prototype_arena.tscn`.
2. Verificar se a arena aparece.
3. Confirmar ausência de erros no debugger.

---

# 6. Marco 3 — Jogador e câmera

## TASK-004 — Criar cena básica do jogador

**Status:** `[x]`

### Objetivo

Criar a cena inicial do jogador com colisão e representação visual provisória.

### Arquivo

```text
res://scenes/characters/player/player.tscn
```

### Estrutura mínima

```text
Player (CharacterBody2D)
├── Visuals (Node2D)
│   └── BodySprite (Sprite2D ou Polygon2D)
├── BodyCollision (CollisionShape2D)
└── Camera2D
```

### Requisitos

* utilizar `CharacterBody2D`;
* possuir representação visual provisória;
* possuir colisão;
* possuir câmera;
* jogador deve ser instanciado na arena.

### Regras

* não implementar movimento nesta tarefa;
* não implementar ataque;
* não implementar vida;
* não adicionar scripts vazios desnecessários.

### Critérios de conclusão

* jogador aparece na arena;
* jogador possui colisão configurada;
* câmera está ativa;
* não há erros.

---

## TASK-005 — Implementar movimentação do jogador

**Status:** `[x]`

### Objetivo

Permitir movimentação em oito direções utilizando WASD.

### Arquivo sugerido

```text
res://scripts/characters/player/player_movement.gd
```

### Requisitos

* ler ações do Input Map;
* criar vetor de direção;
* normalizar movimento diagonal;
* utilizar `velocity`;
* utilizar `move_and_slide()`;
* permitir alterar velocidade pelo Inspector;
* bloquear passagem pelas paredes.

### Valor inicial

```gdscript
@export var movement_speed: float = 220.0
```

### Regras

* não utilizar teclas físicas diretamente;
* não implementar esquiva;
* não implementar animação;
* não implementar stamina.

### Critérios de conclusão

* W move para cima;
* S move para baixo;
* A move para esquerda;
* D move para direita;
* movimento diagonal não é mais rápido;
* jogador colide com os limites;
* não existem erros.

### Como testar

1. Executar a arena.
2. Testar as quatro direções.
3. Testar diagonais.
4. Caminhar contra as paredes.
5. Verificar o debugger.

---

## TASK-006 — Configurar câmera centralizada

**Status:** `[x]`

### Objetivo

Configurar a câmera para acompanhar o jogador mantendo-o no centro.

### Requisitos

* câmera deve ser filha do jogador;
* câmera deve permanecer ativa;
* jogador deve ficar centralizado;
* câmera não deve rotacionar;
* zoom deve permanecer constante;
* suavização pode ser ativada;
* câmera deve respeitar limites da arena.

### Configuração inicial

```text
Position Smoothing Enabled: true
Position Smoothing Speed: 5
Zoom: Vector2(1, 1)
Ignore Rotation: true
```

### Regras

* não implementar zoom dinâmico;
* não deslocar a câmera em direção ao mouse;
* não criar efeitos de tremor nesta etapa.

### Critérios de conclusão

* câmera acompanha o jogador;
* movimento é suave;
* jogador permanece centralizado;
* áreas externas à arena não aparecem.

---

# 7. Marco 4 — Vida e dano

## TASK-007 — Criar componente de vida

**Status:** `[x]`

### Objetivo

Criar um componente reutilizável para armazenar vida, receber dano e emitir morte.

### Arquivo

```text
res://systems/health_component.gd
```

### Interface esperada

```gdscript
class_name HealthComponent
extends Node

signal health_changed(current_health: float, maximum_health: float)
signal died

@export var maximum_health: float = 100.0

var current_health: float
var is_dead: bool = false
```

### Funções necessárias

```text
take_damage(amount)
heal(amount)
restore_full_health()
```

### Requisitos

* iniciar com vida máxima;
* impedir vida negativa;
* impedir vida acima do máximo;
* ignorar dano depois da morte;
* emitir `health_changed`;
* emitir `died` somente uma vez;
* permitir restauração completa.

### Regras

* não implementar interface;
* não implementar morte do jogador;
* não criar dependência com jogador ou inimigo.

### Critérios de conclusão

* componente pode ser usado em qualquer entidade;
* dano reduz a vida;
* cura aumenta a vida;
* vida respeita limites;
* sinal de morte funciona;
* não há erros.

---

## TASK-008 — Adicionar vida ao jogador

**Status:** `[x]`

### Objetivo

Adicionar o `HealthComponent` ao jogador.

### Requisitos

* jogador deve iniciar com 100 de vida;
* jogador deve acessar o componente;
* criar método temporário de teste de dano;
* imprimir alterações de vida no Output;
* imprimir quando o jogador morrer.

### Regras

* não implementar renascimento;
* não implementar tela de morte;
* não implementar interface;
* método de teste deverá ser removido futuramente.

### Critérios de conclusão

* jogador recebe dano de teste;
* vida reduz corretamente;
* morte é detectada;
* não existem erros.

---

# 8. Marco 5 — Foice e ataque

## TASK-009 — Criar estrutura visual da foice

**Status:** `[x]`

### Objetivo

Adicionar a foice inspirada em Horiel à cena do jogador.

### Estrutura

```text
Visuals
└── ScythePivot (Node2D)
    ├── ScytheSprite
    └── AttackHitbox (Area2D)
        └── CollisionShape2D
```

### Requisitos

* utilizar recurso visual provisório;
* foice deve possuir pivô;
* pivô deve apontar para o mouse;
* hitbox deve iniciar desativada;
* câmera não deve rotacionar com a foice.

### Regras

* não causar dano ainda;
* não implementar animação completa;
* não utilizar arte final.

### Critérios de conclusão

* foice aparece próxima ao jogador;
* foice aponta para o mouse;
* câmera permanece estável;
* não há erros.

---

## TASK-010 — Implementar ataque básico da foice

**Status:** `[x]`

### Objetivo

Criar um ataque manual em arco com o botão esquerdo do mouse.

### Arquivo sugerido

```text
res://scripts/characters/player/player_combat.gd
```

### Requisitos

* utilizar ação `attack_primary`;
* respeitar tempo entre ataques;
* executar movimento em arco;
* ativar hitbox durante parte do ataque;
* desativar hitbox ao terminar;
* impedir ataques sobrepostos;
* permitir ajuste pelo Inspector.

### Valores provisórios

```gdscript
@export var base_damage: float = 20.0
@export var attack_cooldown: float = 0.5
@export var attack_duration: float = 0.15
```

### Regras

* não criar combo;
* não criar ataque carregado;
* não criar ataque secundário;
* não aplicar Luz Corrompida ainda.

### Critérios de conclusão

* clique esquerdo executa ataque;
* ataque aponta para o mouse;
* hitbox só fica ativa durante o golpe;
* spam de clique respeita o cooldown;
* não existem erros.

---

## TASK-011 — Criar Hitbox e Hurtbox

**Status:** `[x]`

### Objetivo

Criar componentes reutilizáveis para causar e receber dano.

### Arquivos

```text
res://systems/hitbox_component.gd
res://systems/hurtbox_component.gd
```

### Requisitos da Hitbox

* possuir valor de dano;
* possuir referência ao proprietário;
* evitar atingir o mesmo alvo várias vezes no mesmo golpe;
* não atingir o próprio proprietário.

### Requisitos da Hurtbox

* detectar Hitbox;
* localizar `HealthComponent`;
* aplicar dano;
* ignorar fontes inválidas;
* emitir evento opcional de dano recebido.

### Regras

* não adicionar efeitos elementais;
* não adicionar crítico;
* não adicionar armadura;
* não adicionar resistência.

### Critérios de conclusão

* sistema funciona entre duas entidades de teste;
* dano chega ao `HealthComponent`;
* uma entidade não causa dano em si mesma;
* um golpe não causa dano repetido sem intenção.

---

# 9. Marco 6 — Inimigo básico

## TASK-012 — Criar cena do inimigo básico

**Status:** `[x]`

### Objetivo

Criar o primeiro Retornado básico.

### Arquivo

```text
res://scenes/enemies/basic_returned/basic_returned.tscn
```

### Estrutura mínima

```text
BasicReturned (CharacterBody2D)
├── Visuals
├── BodyCollision
├── Hurtbox
├── DetectionArea
├── AttackArea
├── HealthComponent
└── AttackCooldown
```

### Requisitos

* possuir visual provisório diferente do jogador;
* possuir colisão;
* possuir vida;
* possuir Hurtbox;
* ser instanciado na arena;
* iniciar parado.

### Regras

* não implementar perseguição ainda;
* não implementar ataque;
* não implementar núcleo.

### Critérios de conclusão

* inimigo aparece;
* possui vida;
* recebe dano da foice;
* pode chegar a zero de vida;
* não há erros.

---

## TASK-013 — Implementar perseguição do inimigo

**Status:** `[x]`

### Objetivo

Permitir que o inimigo detecte e persiga o jogador.

### Estados iniciais

```text
IDLE
CHASE
DEAD
```

### Requisitos

* detectar jogador em uma distância limitada;
* mover-se em direção ao jogador;
* parar quando morto;
* respeitar colisões;
* velocidade configurável;
* não atravessar paredes simples.

### Valor provisório

```gdscript
@export var movement_speed: float = 110.0
```

### Regras

* não implementar navegação complexa;
* não implementar formação de grupo;
* não implementar fuga;
* não implementar comportamento avançado.

### Critérios de conclusão

* inimigo detecta jogador;
* inimigo persegue;
* inimigo não se move morto;
* não há erros.

---

## TASK-014 — Implementar ataque do inimigo

**Status:** `[x]`

### Objetivo

Permitir que o inimigo cause dano ao jogador quando estiver próximo.

### Requisitos

* utilizar `AttackArea`;
* possuir tempo de recarga;
* causar dano ao jogador;
* não causar dano a cada frame;
* interromper ataque quando morto;
* usar Hitbox ou fluxo compatível com os componentes.

### Valores provisórios

```text
Dano: 10
Recarga: 1 segundo
```

### Critérios de conclusão

* inimigo causa dano;
* jogador perde vida;
* dano respeita recarga;
* inimigo morto não ataca;
* não existem erros.

---

## TASK-015 — Implementar morte do inimigo

**Status:** `[x]`

### Objetivo

Finalizar corretamente o inimigo quando sua vida chegar a zero.

### Requisitos

* entrar no estado `DEAD`;
* parar movimento;
* desativar ataques;
* desativar colisões;
* impedir dano adicional;
* emitir sinal de morte;
* remover o inimigo depois de um pequeno atraso;
* registrar posição da morte para o futuro núcleo.

### Regras

* não criar núcleo nesta tarefa;
* não adicionar loot;
* não adicionar experiência.

### Critérios de conclusão

* inimigo morre ao chegar a zero;
* não continua perseguindo;
* não continua atacando;
* desaparece corretamente;
* não há erros.

---

# 10. Marco 7 — Luz Corrompida

## TASK-016 — Criar cena do núcleo corrompido

**Status:** `[x]`

### Objetivo

Criar o objeto deixado por inimigos mortos.

### Arquivo

```text
res://scenes/items/corrupted_light_core/corrupted_light_core.tscn
```

### Estrutura mínima

```text
CorruptedLightCore (Area2D)
├── Visual
├── CollisionShape2D
├── InteractionArea
└── AbsorptionTimer
```

### Requisitos

* possuir visual provisório;
* detectar jogador próximo;
* pertencer ao grupo `corrupted_light_cores`;
* não ser coletado automaticamente;
* permitir ajuste da quantidade de luz;
* permitir ajuste da instabilidade gerada.

### Valores provisórios

```text
Luz: 10
Instabilidade: 6
Tempo de absorção: 0,75 segundo
```

### Critérios de conclusão

* núcleo aparece na arena;
* detecta proximidade;
* não é coletado automaticamente;
* não existem erros.

---

## TASK-017 — Fazer inimigo deixar núcleo

**Status:** `[x]`

### Objetivo

Instanciar um núcleo quando o inimigo morrer.

### Requisitos

* carregar a cena do núcleo;
* criar núcleo na posição da morte;
* adicionar o núcleo ao container `Pickups`;
* criar apenas um núcleo por inimigo;
* impedir duplicação após morte;
* manter referência desacoplada da arena quando possível.

### Critérios de conclusão

* derrotar inimigo cria núcleo;
* núcleo aparece na posição correta;
* somente um núcleo é criado;
* não existem erros.

---

## TASK-018 — Criar componente de corrupção

**Status:** `[x]`

### Objetivo

Criar sistema reutilizável de Luz Corrompida e Instabilidade.

### Arquivo

```text
res://systems/corruption_component.gd
```

### Dados iniciais

```gdscript
@export var maximum_corrupted_light: float = 100.0
@export var maximum_instability: float = 100.0

var corrupted_light: float = 0.0
var instability: float = 0.0
```

### Sinais necessários

```text
corrupted_light_changed
instability_changed
instability_level_changed
```

### Funções necessárias

```text
absorb(light_amount, instability_amount)
reset_temporary_power()
get_damage_multiplier()
```

### Requisitos

* limitar valores entre zero e máximo;
* emitir sinais ao alterar;
* calcular nível de instabilidade;
* permitir limpar recursos temporários;
* não depender diretamente do jogador.

### Critérios de conclusão

* valores aumentam;
* valores respeitam limites;
* sinais funcionam;
* reset funciona;
* não há erros.

---

## TASK-019 — Implementar absorção do núcleo

**Status:** `[x]`

### Objetivo

Permitir que o jogador absorva um núcleo utilizando `E`.

### Requisitos

* jogador precisa estar próximo;
* utilizar ação `interact`;
* absorção deve durar 0,75 segundo;
* jogador entra no estado `ABSORBING`;
* movimento fica bloqueado;
* ataque fica bloqueado;
* absorção pode ser interrompida por dano;
* ao concluir, adicionar Luz e Instabilidade;
* remover núcleo depois da absorção.

### Regras

* não permitir absorção automática;
* não permitir absorver à distância;
* não permitir absorver vários núcleos ao mesmo tempo.

### Critérios de conclusão

* aproximação permite interação;
* `E` inicia absorção;
* jogador fica vulnerável;
* valor é adicionado;
* núcleo desaparece;
* interrupção por dano funciona;
* não há erros.

---

## TASK-020 — Aplicar bônus da Luz Corrompida

**Status:** `[x]`

### Objetivo

Fazer a Luz Corrompida aumentar temporariamente o dano da foice.

### Regra provisória

```text
A cada 20 pontos de Luz Corrompida:
+5% de dano
```

### Requisitos

* dano base não deve ser modificado permanentemente;
* multiplicador deve ser calculado pelo componente;
* ataque deve consultar o multiplicador;
* reset deve remover o bônus;
* valor deve ser fácil de balancear.

### Critérios de conclusão

* dano aumenta conforme a luz;
* dano retorna ao normal após reset;
* não há acúmulo incorreto;
* não existem erros.

---

## TASK-021 — Implementar níveis de Instabilidade

**Status:** `[x]`

### Objetivo

Aplicar as primeiras penalidades da Instabilidade.

### Níveis

```text
0 a 69: Estável
70 a 89: Sobrecarregado
90 a 100: Colapso
```

### Efeitos provisórios

```text
Estável:
Sem penalidade grave.

Sobrecarregado:
Jogador recebe 25% mais dano.

Colapso:
Jogador perde vida lentamente.
```

### Requisitos

* mudança de nível deve emitir sinal;
* dano adicional deve ser calculado corretamente;
* dano contínuo deve respeitar intervalo;
* efeitos param após reset;
* não causar dano depois da morte.

### Critérios de conclusão

* nível muda nos valores corretos;
* penalidade de dano funciona;
* perda de vida funciona;
* reset remove efeitos;
* não há erros.

---

# 11. Marco 8 — Interface

## TASK-022 — Criar HUD básico

**Status:** `[x]`

### Objetivo

Criar a interface básica do jogador.

### Arquivo

```text
res://scenes/ui/player_hud.tscn
```

### Elementos

```text
Barra de vida
Barra de Luz Corrompida
Barra de Instabilidade
Contador de mortes
Texto de interação
```

### Requisitos

* usar nós `Control`;
* adaptar-se à resolução;
* utilizar aparência provisória;
* não controlar gameplay;
* atualizar por sinais;
* ficar visível durante a arena.

### Critérios de conclusão

* HUD aparece;
* elementos estão alinhados;
* interface não bloqueia o jogador;
* não existem erros.

---

## TASK-023 — Conectar HUD aos sistemas

**Status:** `[x]`

### Objetivo

Atualizar o HUD com dados reais.

### Requisitos

* vida observa `health_changed`;
* Luz observa `corrupted_light_changed`;
* Instabilidade observa `instability_changed`;
* contador observa `death_count_changed`;
* prompt aparece perto de interações;
* valores iniciais são mostrados corretamente.

### Regras

* HUD não deve alterar componentes;
* evitar consulta constante por frame;
* preferir sinais.

### Critérios de conclusão

* barras atualizam;
* contador atualiza;
* prompt aparece e desaparece;
* não há erros.

---

# 12. Marco 9 — Esquiva

## TASK-024 — Implementar esquiva

**Status:** `[x]`

### Objetivo

Permitir deslocamento rápido usando Espaço.

### Valores provisórios

```gdscript
@export var dodge_speed: float = 520.0
@export var dodge_duration: float = 0.20
@export var dodge_cooldown: float = 1.0
```

### Requisitos

* utilizar ação `dodge`;
* seguir direção de movimento atual;
* utilizar última direção válida caso parado;
* entrar no estado `DODGING`;
* bloquear ataque durante esquiva;
* respeitar cooldown;
* impedir esquivas consecutivas.

### Regras

* não implementar stamina;
* invulnerabilidade ainda é opcional;
* não atravessar paredes.

### Critérios de conclusão

* Espaço executa esquiva;
* direção está correta;
* cooldown funciona;
* paredes bloqueiam;
* não existem erros.

---

# 13. Marco 10 — Altar

## TASK-025 — Criar cena do altar

**Status:** `[x]`

### Objetivo

Criar o altar que servirá como ponto de renascimento.

### Arquivo

```text
res://scenes/objects/respawn_altar/respawn_altar.tscn
```

### Estrutura

```text
RespawnAltar (Area2D)
├── Visual
├── CollisionShape2D
├── InteractionArea
├── RespawnMarker
└── AnimationPlayer
```

### Requisitos

* possuir visual inativo;
* possuir visual ativo;
* detectar jogador;
* permitir ativação com `E`;
* pertencer ao grupo `respawn_altars`;
* possuir identificador único;
* registrar posição do `RespawnMarker`.

### Critérios de conclusão

* altar aparece;
* prompt aparece;
* `E` ativa;
* aparência muda;
* não há erros.

---

## TASK-026 — Criar GameState

**Status:** `[x]`

### Objetivo

Criar o Autoload que preservará dados durante a partida.

### Arquivo

```text
res://autoload/game_state.gd
```

### Dados iniciais

```gdscript
var death_count: int = 0
var current_respawn_position: Vector2 = Vector2.ZERO
var active_altar_id: StringName = &""
```

### Sinais

```text
death_count_changed
respawn_point_changed
```

### Funções

```text
register_death()
set_respawn_point(position, altar_id)
reset_run_state()
```

### Requisitos

* configurar como Autoload;
* não controlar diretamente o jogador;
* não controlar combate;
* preservar dados ao reiniciar entidades;
* usar tipos adequados.

### Critérios de conclusão

* Autoload fica disponível;
* contador aumenta;
* posição é registrada;
* sinais funcionam;
* não existem erros.

---

## TASK-027 — Conectar altar ao GameState

**Status:** `[x]`

### Objetivo

Fazer o altar ativo definir o ponto de renascimento.

### Requisitos

* ativar altar atualiza `GameState`;
* novo altar substitui o anterior;
* altar ativo permanece ativo após morte;
* jogador não precisa reativá-lo;
* primeiro ponto da fase funciona como fallback.

### Critérios de conclusão

* posição correta é armazenada;
* identificador correto é armazenado;
* trocar de altar funciona;
* não há erros.

---

# 14. Marco 11 — Morte e renascimento

## TASK-028 — Implementar estado de morte do jogador

**Status:** `[x]`

### Objetivo

Desativar corretamente o jogador quando sua vida chegar a zero.

### Requisitos

* entrar no estado `DEAD`;
* bloquear movimento;
* bloquear ataque;
* bloquear esquiva;
* cancelar absorção;
* desativar hitbox;
* incrementar contador de mortes;
* iniciar atraso antes do renascimento.

### Regras

* ainda não restaurar inimigos;
* não recarregar toda a aplicação;
* não apagar memórias ou altares.

### Critérios de conclusão

* jogador para ao morrer;
* comandos são bloqueados;
* contador aumenta uma vez;
* não há erros.

---

## TASK-029 — Implementar renascimento

**Status:** `[x]`

### Objetivo

Renascer o jogador no último altar ativado.

### Fluxo

```text
Jogador morre
↓
Aguarda pequeno intervalo
↓
Luz Corrompida é removida
↓
Instabilidade é removida
↓
Jogador vai ao ponto de renascimento
↓
Vida é restaurada
↓
Estados são reiniciados
↓
Controles são reativados
```

### Requisitos

* utilizar posição do `GameState`;
* usar ponto inicial se não houver altar;
* restaurar vida;
* limpar poder temporário;
* reativar colisões;
* emitir evento de renascimento.

### Critérios de conclusão

* jogador volta ao altar;
* vida volta ao máximo;
* luz volta a zero;
* instabilidade volta a zero;
* controles voltam;
* não há erros.

---

# 15. Marco 12 — Restauração da fase

## TASK-030 — Remover núcleos após morte

**Status:** `[x]`

### Objetivo

Remover todos os núcleos existentes quando o jogador morrer.

### Requisitos

* localizar grupo `corrupted_light_cores`;
* cancelar absorções em andamento;
* remover todos os núcleos;
* executar antes do jogador recuperar controle.

### Critérios de conclusão

* núcleos desaparecem após morte;
* nenhum núcleo antigo permanece;
* não há erros.

---

## TASK-031 — Restaurar inimigos comuns

**Status:** `[x]`

### Objetivo

Fazer todos os inimigos comuns reaparecerem após a morte do jogador.

### Requisitos

* registrar posição inicial;
* registrar estado inicial;
* restaurar vida máxima;
* restaurar colisões;
* restaurar IA;
* remover efeitos temporários;
* recriar inimigos já removidos;
* impedir duplicações.

### Estratégia recomendada

A arena poderá armazenar os dados iniciais ou recriar os inimigos a partir de pontos de spawn.

### Critérios de conclusão

* inimigos mortos reaparecem;
* inimigos vivos voltam ao estado inicial;
* posições são restauradas;
* vida volta ao máximo;
* não há duplicações;
* não existem erros.

---

## TASK-032 — Preservar altares ativados

**Status:** `[x]`

### Objetivo

Garantir que altares continuem ativos após a morte.

### Requisitos

* altar ativo mantém aparência;
* ponto de respawn continua registrado;
* jogador não precisa reativar;
* outros altares mantêm seus estados anteriores;
* novo altar ainda pode substituir o atual.

### Critérios de conclusão

* altar permanece ativo;
* renascimento continua correto;
* não há erros.

---

## TASK-033 — Criar estrutura de memórias persistentes

**Status:** `[x]`

### Objetivo

Criar uma estrutura mínima para preservar memórias coletadas durante a partida.

### Requisitos

* `GameState` deve armazenar IDs de memórias;
* IDs não podem ser duplicados;
* memória coletada permanece registrada após morte;
* objeto de memória pode desaparecer da arena;
* não criar sistema completo de diário.

### Critérios de conclusão

* memória pode ser registrada;
* morte não apaga registro;
* duplicação é evitada;
* não existem erros.

---

# 16. Marco 13 — Polimento do protótipo

## TASK-034 — Adicionar tela simples de morte

**Status:** `[x]`

### Objetivo

Mostrar uma transição visual breve entre morte e renascimento.

### Requisitos

* mostrar mensagem provisória;
* bloquear interação;
* desaparecer ao renascer;
* não substituir o fluxo de morte;
* evitar tela excessivamente longa.

### Critérios de conclusão

* tela aparece;
* tela desaparece;
* fluxo não quebra;
* não há erros.

---

## TASK-035 — Adicionar efeitos provisórios

**Status:** `[x]`

### Objetivo

Melhorar a leitura visual sem utilizar arte final.

### Efeitos possíveis

* flash ao receber dano;
* flash no inimigo;
* efeito ao absorver;
* brilho no altar ativo;
* rastro simples na foice;
* indicação de Instabilidade.

### Regras

* não usar shaders complexos;
* não adicionar dependências;
* não comprometer desempenho.

### Critérios de conclusão

* ações ficam mais legíveis;
* efeitos não quebram gameplay;
* não existem erros.

---

## TASK-036 — Balancear protótipo

**Status:** `[x]`

### Objetivo

Ajustar valores para uma sessão de cinco a dez minutos.

### Valores a avaliar

* velocidade do jogador;
* velocidade do inimigo;
* dano da foice;
* dano do inimigo;
* vida do inimigo;
* alcance;
* cooldown;
* duração da esquiva;
* quantidade de Luz;
* Instabilidade;
* quantidade de inimigos.

### Regras

* registrar mudanças;
* alterar pelo Inspector quando possível;
* não criar conteúdo novo durante balanceamento.

### Critérios de conclusão

* protótipo é jogável;
* jogador consegue sobreviver;
* inimigos representam ameaça;
* absorção apresenta risco;
* morte e retorno funcionam;
* duração fica entre cinco e dez minutos.

---

## TASK-037 — Testar ciclo completo

**Status:** `[x]`

### Objetivo

Validar todo o ciclo principal do protótipo.

### Fluxo obrigatório

```text
Entrar na arena
↓
Mover-se
↓
Atacar com a foice
↓
Derrotar inimigo
↓
Absorver núcleo
↓
Receber bônus
↓
Aumentar Instabilidade
↓
Ativar altar
↓
Receber dano
↓
Morrer
↓
Perder Luz e Instabilidade
↓
Remover núcleos
↓
Restaurar inimigos
↓
Renascer no altar
↓
Preservar contador e altar
```

### Critérios de conclusão

* todas as etapas funcionam;
* nenhuma etapa gera erro;
* nenhum estado fica travado;
* inimigos não duplicam;
* núcleos não permanecem;
* altar continua ativo;
* contador aumenta corretamente.

---

## TASK-038 — Limpar código provisório

**Status:** `[x]`

### Objetivo

Remover código de teste antes de considerar o protótipo concluído.

### Verificações

* remover atalhos temporários de dano;
* remover prints desnecessários;
* remover nós não utilizados;
* remover arquivos vazios;
* revisar nomes;
* revisar tipagem;
* revisar comentários;
* revisar caminhos de nós;
* revisar sinais desconectados.

### Critérios de conclusão

* projeto continua funcionando;
* código está organizado;
* debugger está limpo;
* não há erros de parser.

---

## TASK-039 — Atualizar documentação

**Status:** `[x]`

### Objetivo

Atualizar os documentos com o estado real do projeto.

### Arquivos

```text
README.md
GAME_DESIGN.md
ARCHITECTURE.md
TASKS.md
```

### Requisitos

* marcar tarefas concluídas;
* registrar decisões alteradas;
* explicar como executar;
* explicar controles;
* registrar limitações;
* não declarar funcionalidades inexistentes.

### Critérios de conclusão

* documentação corresponde ao projeto;
* controles estão corretos;
* instruções de execução funcionam.

---
## TASK-040 — Criar objetivo e conclusão da arena

**Status:** `[x]`

### Objetivo

Dar à arena uma condição clara de conclusão e permitir que o jogador finalize o protótipo.

### Fluxo

* entrar na arena;
* derrotar os quatro spawns ao menos uma vez no run;
* coletar `prototype_memory_01`;
* ativar `prototype_altar_01`;
* liberar a saída;
* interagir com a saída;
* mostrar uma tela simples de conclusão.

### Regras

* não criar uma nova fase;
* não criar chefe;
* não adicionar arte final;
* não alterar balanceamento;
* preservar morte, respawn, altar e memórias;
* preservar o progresso durante mortes e recargas da arena;
* exibir progresso e conclusão no HUD;
* bloquear o jogador depois da conclusão;
* permitir reiniciar um run limpo com Enter;
* impedir progresso, desbloqueio e conclusão duplicados;
* não criar salvamento em disco.

### Critérios de conclusão

* saída começa bloqueada;
* objetivo é compreensível;
* condição de liberação funciona;
* saída fornece feedback visual;
* jogador consegue concluir a arena;
* morte não quebra o fluxo;
* reinício limpa mortes, progresso, memória, altar e conclusão;
* duas repetições não duplicam sinais, nós ou inimigos;
* validação manual concluída no Godot 4.5.1;
* nenhum erro é gerado.

### Validação

A implementação e a regressão técnica estão concluídas. A tarefa aguarda
validação manual do jogador antes de receber `[x]`.

## Estado do protótipo

- ciclo principal implementado;
- regressão concluída;
- código provisório limpo;
- documentação atualizada;
- protótipo pronto para a próxima fase de desenvolvimento.
# Marco 15 — Primeira fase jogável

## TASK-041 — Reorganizar o layout da arena como fase

**Status:** `[x]`

### Objetivo

Transformar a arena técnica atual em uma fase com percurso, zonas e progressão visual clara.

### Requisitos

* dividir a fase em áreas reconhecíveis;
* criar entrada, área inicial, área de combate, altar, memória e saída;
* usar apenas formas e visuais provisórios;
* preservar os quatro pontos de spawn;
* preservar todos os sistemas existentes;
* impedir que o jogador alcance a saída por caminhos inválidos;
* manter espaço suficiente para combate e esquiva;
* manter a fase dentro da duração planejada;
* não adicionar arte final.

### Critérios de conclusão

* o percurso da fase é compreensível;
* os locais importantes são distinguíveis;
* não existem colisões quebradas;
* inimigos não surgem em paredes;
* altar, memória e saída continuam acessíveis;
* câmera funciona em toda a fase;
* morte e renascimento continuam funcionando;
* não existem erros.

### Validação

Layout e validação técnica aguardam confirmação manual do jogador antes de
a tarefa receber `[x]`.

---

## TASK-042 — Criar progressão por encontros

**Status:** `[x]`

### Objetivo

Organizar os quatro inimigos em encontros progressivos, evitando que todos ataquem ao mesmo tempo desde o início.

### Requisitos

* dividir os inimigos em grupos ou zonas de encontro;
* primeiro encontro simples;
* encontro intermediário com maior pressão;
* encontro final antes da saída;
* ativar inimigos por entrada em área ou evento;
* inimigos ainda devem retornar após a morte do jogador;
* progresso de inimigos derrotados deve continuar funcionando;
* não alterar o número total de quatro inimigos;
* não criar novo tipo de inimigo;
* não alterar balanceamento nesta tarefa.

### Critérios de conclusão

* encontros ativam no momento correto;
* inimigos não atacam através de toda a fase;
* restauração após morte funciona;
* progresso não duplica;
* o percurso apresenta aumento de dificuldade;
* não existem erros.

### Validação

Implementação, validação técnica automatizada e validação manual do jogador
concluídas.

---

## TASK-043 — Criar bloqueios de progressão

**Status:** `[x]`

### Objetivo

Controlar o avanço entre áreas da fase através dos objetivos já existentes.

### Requisitos

* criar portões ou barreiras provisórias;
* não usar arte final;
* primeiro bloqueio abre após o primeiro encontro;
* área do altar fica acessível no momento planejado;
* área final exige progressão anterior;
* saída final continua dependendo dos quatro inimigos, memória e altar;
* barreiras abertas permanecem abertas após morte;
* reiniciar a execução restaura as barreiras;
* não criar salvamento em disco.

### Critérios de conclusão

* jogador não pula etapas;
* bloqueios apresentam feedback visual;
* abertura ocorre uma única vez;
* morte não fecha bloqueios já concluídos;
* reset restaura estado inicial;
* não existem erros.

### Validação

Implementação, validação técnica automatizada e validação manual do jogador
concluídas.

---

## TASK-044 — Adicionar texto narrativo à memória

**Status:** `[x]`

### Objetivo

Dar função narrativa real ao fragmento de memória existente.

### Requisitos

* criar um texto curto ligado à história de Solares;
* mostrar o texto ao coletar a memória;
* bloquear controles durante a leitura;
* permitir avançar ou fechar com uma tecla;
* registrar a memória como coletada somente uma vez;
* preservar a memória após morte;
* não criar sistema completo de diálogo;
* não adicionar voz ou áudio;
* não criar múltiplas memórias nesta tarefa.

### Critérios de conclusão

* texto aparece na coleta;
* texto é legível;
* jogador consegue fechar;
* controles retornam corretamente;
* memória não reaparece após morte;
* não existem erros.

### Validação

Implementação, validação técnica automatizada e validação manual do jogador
concluídas.

---

## TASK-045 — Criar tutorial contextual

**Status:** `[x]`

### Objetivo

Ensinar os controles e sistemas durante o percurso da fase sem criar uma tela longa de tutorial.

### Requisitos

* ensinar movimento próximo ao início;
* ensinar ataque antes do primeiro inimigo;
* ensinar esquiva durante ou antes do primeiro combate;
* ensinar interação próximo à memória ou ao altar;
* ensinar absorção quando surgir o primeiro núcleo;
* mensagens devem desaparecer após uso ou progresso;
* não repetir mensagens já concluídas durante a mesma execução;
* reset da execução permite mostrar o tutorial novamente;
* não bloquear excessivamente o jogador.

### Critérios de conclusão

* jogador entende os controles sem consultar documentação;
* mensagens aparecem no momento adequado;
* mensagens não ficam presas;
* morte e respawn não duplicam tutoriais;
* não existem erros.

### Validação

Implementação, validação técnica automatizada e validação manual do jogador
concluídas.

---

## TASK-046 — Implementar pausa funcional

**Status:** `[x]`

### Objetivo

Fazer a ação Esc abrir e fechar um menu simples de pausa.

### Requisitos

* utilizar a ação de pausa já mapeada;
* abrir com Esc;
* fechar com Esc;
* bloquear gameplay enquanto pausado;
* manter HUD e menu responsivos;
* incluir opções provisórias:
  * continuar;
  * sair para o desktop;
* sair diretamente, sem confirmação ou tela intermediária;
* não quebrar timers após continuar;
* não interferir com tela de morte ou conclusão.

### Critérios de conclusão

* menu abre e fecha;
* gameplay pausa corretamente;
* continuar não quebra estados;
* saída funciona;
* não existem erros.

### Validação

Implementação, validação técnica automatizada e validação manual do jogador
concluídas no Godot 4.5.1, sem erros no Output ou Debugger.

---

## TASK-047 — Adicionar áudio provisório

**Status:** `[ ]`

### Objetivo

Adicionar feedback sonoro temporário para validar a leitura das ações.

### Requisitos

* utilizar apenas sons próprios, livres ou provisórios devidamente identificados;
* som de ataque;
* som de acerto;
* som de dano no jogador;
* som de absorção;
* som de ativação do altar;
* som de morte;
* som de desbloqueio da saída;
* música ambiente provisória opcional;
* controlar volumes básicos;
* evitar sons acumulados ou excessivamente altos;
* documentar origem e licença dos arquivos.

### Critérios de conclusão

* ações possuem feedback sonoro;
* volumes são consistentes;
* sons não duplicam;
* morte e respawn não deixam áudio preso;
* não existem erros.

---

## TASK-048 — Preparar integração de arte

**Status:** `[ ]`

### Objetivo

Organizar cenas e recursos para que os visuais provisórios possam ser substituídos pela arte produzida pela equipe.

### Requisitos

* listar todos os assets necessários;
* definir dimensões aproximadas;
* definir pivôs e orientações;
* definir nomes de arquivos;
* definir animações necessárias;
* separar visual de lógica e colisão;
* preservar scripts ao trocar sprites;
* criar documento ART_REQUIREMENTS.md;
* não produzir arte final nesta tarefa.

### Critérios de conclusão

* lista de assets está completa;
* cenas aceitam substituição visual;
* colisões não dependem do desenho provisório;
* nomes e pastas estão padronizados;
* artistas conseguem trabalhar sem editar scripts;
* não existem erros.

---

## TASK-049 — Integrar primeira passagem de arte

**Status:** `[ ]`

### Objetivo

Substituir os visuais provisórios pelos primeiros assets entregues pela equipe.

### Requisitos

* importar assets sem alterar gameplay;
* configurar filtros e compressão adequados ao estilo escolhido;
* ajustar pivôs;
* configurar animações disponíveis;
* manter colisões coerentes;
* preservar escala visual entre personagens e ambiente;
* não alterar balanceamento;
* registrar assets ainda ausentes.

### Critérios de conclusão

* assets aparecem corretamente;
* animações não quebram lógica;
* colisões continuam funcionando;
* não existem referências quebradas;
* desempenho permanece estável;
* não existem erros.

---

## TASK-050 — Testar primeira fase completa

**Status:** `[ ]`

### Objetivo

Validar a primeira fase do início ao fim após layout, progressão, narrativa, tutorial, pausa, áudio e integração visual.

### Fluxo obrigatório

```text
iniciar execução
↓
aprender movimento
↓
entrar no primeiro encontro
↓
usar ataque e esquiva
↓
absorver núcleo
↓
encontrar memória
↓
ativar altar
↓
avançar pelos encontros
↓
derrotar os quatro inimigos
↓
liberar saída
↓
concluir a fase
↓
reiniciar execução

# 17. Marco 14 — Protótipo concluído

O primeiro protótipo será considerado concluído quando possuir:

* arena jogável;
* personagem controlável;
* câmera centralizada;
* ataque manual com foice;
* inimigo básico;
* dano e vida;
* esquiva;
* núcleos de Luz Corrompida;
* absorção manual;
* bônus temporário;
* Instabilidade;
* HUD;
* altar;
* morte;
* renascimento;
* restauração dos inimigos;
* desaparecimento dos núcleos;
* preservação dos altares;
* contador de mortes;
* estrutura mínima de memórias;
* ausência de erros de parser;
* ciclo jogável de cinco a dez minutos.

---

# 18. Recursos fora do primeiro protótipo

Não implementar neste momento:

* chefe;
* fase de 30 minutos;
* múltiplas armas;
* combos avançados;
* árvores de habilidade;
* inventário completo;
* sistema de equipamentos;
* crafting;
* diálogos complexos;
* mundo aberto;
* multiplayer;
* salvamento em disco;
* configurações gráficas completas;
* suporte a controle;
* localização;
* integração com Steam;
* conquistas;
* geração procedural;
* sete fragmentos completos;
* arte final;
* áudio final.

---

# 19. Primeira tarefa autorizada

A primeira tarefa autorizada para execução é:

```text
TASK-001 — Verificar estrutura do projeto
```

O agente deverá concluir e testar essa tarefa antes de iniciar a próxima.

O agente não está autorizado a executar toda a lista de uma vez.
