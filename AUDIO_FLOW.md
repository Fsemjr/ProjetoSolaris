# Áudio provisório

## Foice

Arquivo utilizado:

```text
res://assets/audio/sfx/scythe_attack.wav
```

- Nó responsável: `ScytheAttackAudio`, um `AudioStreamPlayer2D` filho de
  `Player/Visuals/ScythePivot`.
- Evento: início confirmado de um ataque primário válido em
  `player_combat.gd`.
- Volume: `-6 dB`, ajustado somente no player; o WAV não é modificado.
- Cooldown: o som é disparado depois das validações de estado, ataque em
  andamento e cooldown. Cliques recusados não chegam a `play()`.
- Repetição: a mesma instância é reutilizada. Um novo ataque válido reinicia
  o stream, evitando acumular várias reproduções.
- Pausa: o player herda o processamento pausável do gameplay. O stream para
  com a `SceneTree` e continua após `Resume`, sem novo disparo.
- Origem: arquivo fornecido no próprio repositório para a foice.
- Licença: não há metadado de licença junto ao arquivo; sua autorização para
  distribuição deve ser confirmada antes de uma publicação.

## Eventos

O repositório contém somente o WAV da foice. Nenhum som foi baixado, gerado,
copiado ou reutilizado artificialmente nos outros eventos.

| Evento | Estado | Asset ou ponto de integração |
| --- | --- | --- |
| Player attack | Implementado | `scythe_attack.wav`; início de ataque válido |
| Player hurt | Pendente por ausência de asset | `HurtboxComponent.damage_received` |
| Enemy death | Pendente por ausência de asset | `BasicReturned.enemy_died` |
| Core absorption | Pendente por ausência de asset | `PlayerCorruption.absorption_succeeded` |
| Memory | Pendente por ausência de asset | `MemoryFragment.memory_remembered` / `memory_opened` |
| Altar | Pendente por ausência de asset | `RespawnAltar.altar_activated` |
| Gate | Pendente por ausência de asset | `ProgressionGate.gate_opened` |
| Completion | Pendente por ausência de asset | `GameState.arena_completed` |

Esses sinais já são emitidos apenas por transições válidas e formam os pontos
de integração futuros. Não foram criados players vazios nem lógica duplicada.

## Pause

- A entrada do ataque não é processada enquanto a árvore está pausada.
- Nenhum novo som da foice é disparado pelo PauseMenu.
- Uma reprodução em andamento acompanha a pausa nativa e não reinicia ao
  despausar.
- `DEAD`, `COMPLETED` e `READING_MEMORY` já bloqueiam `_try_attack()`, portanto
  também bloqueiam o SFX.
- Respawn apenas restaura o controlador; não inicia áudio automaticamente.

## Prioridades futuras

Quando houver assets próprios e com licença registrada, as próximas
prioridades são:

1. dano real recebido pelo jogador;
2. conclusão da absorção;
3. morte real do BasicReturned;
4. coleta inédita da memória;
5. primeira ativação do altar;
6. transição real dos portões de fechado para aberto;
7. conclusão única da fase.

Uma estrutura futura de buses `Master`, `Music` e `SFX` pode ser considerada
quando existirem música, controle de volume e mais efeitos. Ela não é
necessária para esta primeira integração.
