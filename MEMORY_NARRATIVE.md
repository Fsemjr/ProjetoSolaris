# Memória narrativa do protótipo

## ID

`prototype_memory_01`

## Título

`ECHO OF THE FALL`

## Texto

> When the sky split, no one understood the light that fell upon us.
>
> Some called it a blessing. Others, corruption.
>
> I remember only the sound...  
> like glass breaking inside the world.

## Fluxo de interação

- Coleta: o HUD apresenta `Press E to remember` enquanto o jogador está
  próximo. Uma pressão de E registra o ID no `GameState`.
- Abertura: quando o registro é novo, o `MemoryFragment` emite título e texto
  para a arena, que abre o `MemoryPanel`.
- Bloqueio: o jogador entra em `READING_MEMORY`; movimento, ataque, esquiva,
  absorção, Hurtbox e dano de Colapso ficam interrompidos. A árvore é pausada,
  mas o painel continua processando.
- Fechamento: depois que E for solto, uma nova pressão inicia o fade de saída.
  Ao final, o jogador retorna ao estado ativo e a árvore é despausada.
- Persistência: morte e recarga não apresentam novamente uma memória já
  registrada. `reset_run_state()` limpa o ID e permite uma nova leitura no
  próximo run.

## Decisões técnicas

- Ação usada para continuar: `interact`, já mapeada para E.
- Prevenção de input residual: o painel exige a liberação de E antes de aceitar
  a próxima pressão. Segurar a tecla da coleta não fecha o texto.
- Proteção contra dano: a Hurtbox do jogador é desativada, o dano de Colapso é
  interrompido e a arena fica pausada durante a leitura.
- Integração: `MemoryFragment` emite `memory_opened`; `PrototypeArena`
  coordena `Player`, `MemoryPanel` e `PlayerHUD` sem caminhos absolutos ou
  buscas por frame.
- Interface: o painel usa o mesmo idioma inglês predominante no HUD e possui
  fades curtos de entrada e saída.

## Limitações

- Existe somente uma memória.
- Não há sistema genérico de diálogo.
- Não há escolhas, diário ou releitura durante o mesmo run.
- Não há áudio ou voz.
- Não há arte final.
- Não há persistência em disco.
