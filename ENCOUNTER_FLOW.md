# Fluxo de encontros

## Encounter 01

- Zona: `EncounterZone01`, na entrada do primeiro espaço de combate, em
  `Vector2(500, 1165)`, com área de `Vector2(50, 390)`.
- Spawn: `enemy_spawn_01`.
- Objetivo: apresentar o combate com um único BasicReturned.
- Comportamento: o inimigo começa inativo e desperta quando o jogador avança
  pela passagem. O encontro termina após esse spawn ser derrotado pela
  primeira vez na execução.

## Encounter 02

- Zona: `EncounterZone02`, cobrindo a passagem direita para a área
  intermediária, em `Vector2(2000, 950)`, com área de `Vector2(710, 60)`.
- Spawns: `enemy_spawn_02` e `enemy_spawn_03`.
- Objetivo: criar pressão intermediária com dois BasicReturned ativos juntos.
- Comportamento: ambos despertam na mesma ativação. O encontro só termina
  depois que os dois IDs de spawn tiverem sido derrotados pelo menos uma vez.

## Encounter 03

- Zona: `EncounterZone03`, cobrindo a passagem esquerda para a área final, em
  `Vector2(400, 450)`, com área de `Vector2(700, 60)`.
- Spawn: `enemy_spawn_04`.
- Objetivo: apresentar o último combate antes da saída.
- Comportamento: o inimigo final permanece inativo até o jogador atravessar a
  zona e o encontro termina após a primeira derrota desse spawn.

## Persistência

- Morte: encontros ativados e concluídos permanecem registrados no
  `GameState`; o progresso dos IDs de spawn derrotados também é preservado.
- Restauração: os quatro inimigos usam as instâncias ou cenas já existentes.
  Ao restaurar, inimigos de encontros ativados voltam ativos e os demais
  permanecem inativos.
- Recarga: durante a mesma execução, cada zona consulta o `GameState` e não
  emite uma nova ativação para um encontro já registrado.
- Reset: `GameState.reset_run_state()` limpa os encontros junto com o restante
  do estado da execução. Uma nova fase volta a começar com as três zonas
  disponíveis e os quatro inimigos inativos.

## Sinais

- Ativação: `EncounterZone.encounter_activated` informa à arena o ID do
  encontro e seus IDs de spawn. `GameState.encounter_activated` é emitido
  somente na primeira ativação persistente.
- Conclusão: a arena reage às mortes e consulta
  `GameState.has_defeated_enemy_spawn()`. Quando todos os spawns do encontro
  foram derrotados, `GameState.encounter_completed` é emitido uma única vez.
- HUD: o `PlayerHUD` observa os sinais do `GameState` e mostra brevemente
  `ENCOUNTER STARTED` ou `ENCOUNTER CLEARED`. A mensagem é ocultada com
  segurança em morte ou conclusão da arena.

Inimigos inativos continuam visíveis no spawn com aparência escurecida, mas
sem Hurtbox, detecção, área de ataque, hitbox ou processamento de movimento.
Ao ativar, esses elementos retornam ao estado normal sem criar outra instância
e sem alterar o transform do inimigo.
