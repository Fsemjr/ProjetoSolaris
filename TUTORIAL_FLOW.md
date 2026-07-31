# Tutorial contextual

O tutorial da primeira fase apresenta uma instrução curta por vez. Ele não
pausa o jogo, não bloqueia o percurso e não exige que cada passo seja
concluído para liberar encontros, portões ou a saída.

## Movimento

- Gatilho: início de uma execução enquanto `movement` estiver pendente.
- Conclusão: primeiro deslocamento real produzido pelo input de movimento do
  jogador.
- Texto:

```text
WASD
MOVE
```

## Ataque

- Gatilho: ativação do `encounter_01`, caso `attack` ainda esteja pendente.
- Conclusão: início de um ataque válido, fora de estados que bloqueiam o
  combate.
- Texto:

```text
LEFT MOUSE
ATTACK
```

## Esquiva

- Gatilho: depois do ataque no contexto do primeiro encontro, caso `dodge`
  ainda esteja pendente.
- Conclusão: emissão de `dodge_started`, que ocorre somente quando uma esquiva
  realmente começa. Pressionar Espaço durante bloqueio ou cooldown não
  conclui o passo.
- Texto:

```text
SPACE
DODGE
```

## Interação

- Gatilho: primeira proximidade de uma memória não coletada ou de um altar
  inativo, caso `interact` esteja pendente.
- Conclusão: coleta válida da memória ou ativação válida do altar.
- Texto:

```text
E
INTERACT
```

A coleta da memória continua abrindo o `MemoryPanel` normalmente.

## Absorção

- Gatilho: proximidade de um CorruptedLightCore enquanto `absorb` estiver
  pendente.
- Conclusão: absorção validada pelo `PlayerCorruption`, depois de
  `finish_absorption()` e da concessão dos recursos.
- Cancelamento: distância, dano ou morte mantêm o passo pendente e permitem
  que o prompt reapareça quando o núcleo voltar a estar disponível.
- Texto coerente com o comportamento atual, que exige uma pressão de E e
  permanência na área durante 0,75 segundo:

```text
E
ABSORB CORRUPTED LIGHT
```

## Ordem contextual

Somente um passo é exibido por vez. Entre os contextos disponíveis, a ordem
é:

1. movimento inicial;
2. núcleo próximo;
3. memória ou altar próximo;
4. ataque no primeiro encontro;
5. esquiva no primeiro encontro.

Um passo executado validamente antes de seu prompt aparecer também é
registrado e não será apresentado depois.

## Prioridades de UI

1. `MemoryPanel`, `DeathOverlay` e `CompletionOverlay`;
2. `TutorialPrompt`;
3. prompt normal de interação do `PlayerHUD`.

- Memória: o tutorial é ocultado imediatamente durante a leitura. Ao fechar,
  apenas um passo ainda pendente e contextual pode voltar.
- Morte: o tutorial é ocultado durante `DEAD`. Após o respawn, passos já
  concluídos continuam ocultos e um passo pendente pode retornar quando seu
  contexto ainda for válido.
- Conclusão: o tutorial permanece oculto enquanto a tela de conclusão estiver
  ativa.
- Tutorial: enquanto visível, suprime o prompt normal de interação para evitar
  mensagens concorrentes.
- Interação: volta a usar o HUD existente quando nenhum tutorial contextual
  está sendo exibido.

O `TutorialPrompt` fica no canto inferior esquerdo, separado do HUD de status,
do objetivo, das mensagens de encontro e do prompt normal central. Entrada e
saída usam fade de 0,2 segundo e sempre substituem o Tween anterior.

## Persistência

O `GameState` mantém `completed_tutorial_steps` durante a execução atual.

- Morte: não limpa passos concluídos.
- Respawn: não duplica conclusões ou sinais.
- Recarga da arena: consulta os mesmos IDs preservados no Autoload.
- Reset: `reset_run_state()` chama `clear_tutorial_progress()`. A nova
  execução volta a apresentar movimento e os demais passos conforme seus
  contextos.
- Disco: não existe persistência ou preferência permanente para ignorar o
  tutorial.

IDs utilizados:

```text
movement
attack
dodge
interact
absorb
```
