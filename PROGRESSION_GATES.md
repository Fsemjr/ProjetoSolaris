# Bloqueios de progressão

## Gate 01

- Posição: `Vector2(900, 1165)`.
- Dimensão: `Vector2(36, 390)`, fechando a faixa inferior entre suas paredes.
- Encontro exigido: `encounter_01`.
- Estado inicial: fechado enquanto o primeiro encontro não estiver concluído.
- Comportamento: impede o acesso antecipado à memória e ao altar. Quando o
  primeiro spawn é derrotado e o encontro termina, a colisão é desativada
  imediatamente e o visual fechado desaparece com uma retração curta.

## Gate 02

- Posição: `Vector2(395, 450)`.
- Dimensão: `Vector2(710, 36)`, fechando a abertura esquerda do divisor
  superior.
- Encontro exigido: `encounter_02`.
- Estado inicial: fechado enquanto os dois spawns intermediários não tiverem
  sido derrotados pelo menos uma vez.
- Comportamento: impede o acesso antecipado ao encontro final. Ao concluir o
  encontro intermediário, a colisão é removida e a passagem superior fica
  disponível.

## Persistência

- Morte: nenhum estado específico de portão é reiniciado. Como os encontros
  concluídos permanecem no `GameState`, os portões correspondentes continuam
  abertos durante morte e respawn.
- Recarga: cada `ProgressionGate` consulta
  `GameState.is_encounter_completed(required_encounter_id)` ao entrar na
  árvore. Um portão restaurado aberto não emite novamente seus sinais.
- Reset: `reset_run_state()` já limpa o progresso dos encontros. Ao recarregar
  a arena para o novo run, ambos os portões derivam o estado fechado.

## Integração

- Sinais: a arena observa `GameState.encounter_completed` e encaminha somente
  os IDs relacionados aos portões. `gate_opened` e `gate_state_changed` são
  emitidos apenas em uma abertura real.
- GameState: não foi criado `opened_gate_ids`. O encontro concluído é a única
  fonte de verdade, evitando progresso paralelo ou divergente.
- PrototypeArena: contém exatamente `gate_01` e `gate_02` no container
  `ProgressionGates`. Nenhum inimigo, spawn, encontro ou condição da saída foi
  alterado.
- HUD: um portão fechado próximo disponibiliza `The path is sealed`. Abertura
  mostra brevemente `PATH OPENED` no canal temporário já usado pelos encontros,
  sem painel permanente e sem bloquear input.

A `ArenaExit` continua independente e exige os quatro spawns derrotados, a
memória coletada e o altar ativo. Ela não funciona como um terceiro portão.
