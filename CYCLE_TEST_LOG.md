# Validação do ciclo completo

## Escopo

Registro da validação técnica da TASK-037. Nenhuma mecânica, conteúdo ou
propriedade de balanceamento foi alterada.

O teste automatizado serve como regressão técnica. A conclusão da tarefa
depende também de uma execução manual contínua no Godot 4.5.1.

## Estado inicial validado

| Item | Resultado técnico |
| --- | --- |
| Jogador | Vivo, 100/100 |
| Luz Corrompida | 0/100 |
| Instabilidade | 0/100, nível 0 |
| Mortes | 0 |
| Altar | Inativo, sem ponto no GameState |
| Inimigos | 4, sem duplicação |
| Núcleos | 0 |
| Memória | Disponível |
| DeathOverlay | Oculto |
| Rastro da foice | Oculto |
| HUD | Vida e recursos sincronizados |

## Movimento e combate

- WASD alterou a posição do jogador.
- A parede direita bloqueou o CharacterBody2D.
- A câmera permaneceu habilitada e com `ignore_rotation = true`.
- A foice apontou para a direção fornecida.
- O rastro apareceu apenas durante o ataque.
- A Hitbox ativou dentro da janela e desligou ao final.
- O BasicReturned entrou em perseguição.
- O ataque inimigo causou exatamente 10 de dano no nível 0.
- O flash de dano do jogador foi acionado.
- Cada BasicReturned morreu após três golpes de 20.
- Cada morte de inimigo gerou exatamente um núcleo.

## Absorção e corrupção

- Três núcleos foram absorvidos durante a validação.
- Cada absorção concedeu recursos uma única vez.
- Dois núcleos produziram 20 de Luz e dano de foice igual a 21.
- Três núcleos produziram 72 de Instabilidade e nível 1.
- Uma chamada controlada adicionou os 24 pontos restantes para validar
  Instabilidade 96 e Colapso sem alterar conteúdo permanente.
- O Colapso aplicou 5 de dano após um segundo.
- No nível 2, um ataque inimigo de 10 aplicou 12,5.
- A morte interrompeu o timer de Colapso.
- Reset e respawn voltaram ao nível 0.

## Altar e memória

- O altar emitiu `altar_activated` exatamente uma vez.
- Uma segunda ativação foi recusada sem novo sinal.
- `active_altar_id`, `current_respawn_position` e `has_respawn_point`
  permaneceram corretos.
- A memória foi registrada e preservada nos três ciclos.
- O altar permaneceu visualmente ativo.

## Repetições técnicas

Posição de respawn usada em todos os ciclos: `(400, 308)`.

| Ciclo | Estado crítico da morte | Inimigos vivos antes | Inimigos após respawn | Núcleos antes | Núcleos após | Vida após | Luz após | Instabilidade após | Mortes |
| ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | Ataque, rastro e Colapso | 0 | 4 | 1 | 0 | 100 | 0 | 0 | 1 |
| 2 | Absorção em andamento | 3 | 4 | 1 em absorção | 0 | 100 | 0 | 0 | 2 |
| 3 | Esquiva, flash e Colapso | 3 | 4 | 1 | 0 | 100 | 0 | 0 | 3 |

Em todos os ciclos:

- o jogador entrou em DEAD imediatamente;
- movimento, ataque, esquiva e interação foram bloqueados;
- velocity e Hitbox ficaram seguros;
- o DeathOverlay apareceu;
- recursos temporários foram zerados;
- núcleos foram removidos;
- inimigos foram restaurados sem duplicação;
- o jogador renasceu no altar;
- controles foram reativados;
- efeitos visuais temporários foram limpos.

## Contagem final técnica

```text
Deaths: 3
Health: 100 / 100
Corrupted Light: 0 / 100
Instability: 0 / 100
Enemies: 4
CorruptedLightCores: 0
Altar active: true
Memory preserved: true
Controls active: true
```

Sinais observados:

- `player_died`: 3 emissões;
- `player_respawned`: 3 emissões;
- `altar_activated`: 1 emissão.

## Bugs encontrados

Nenhum bug foi encontrado na validação técnica.

Nenhum arquivo de gameplay foi corrigido durante a TASK-037.

## Output e Debugger

- Godot utilizado: 4.5.1 stable.
- Falhas do teste técnico: 0.
- Erros de parser: 0.
- Erros de runtime: 0.
- Referências inválidas: 0.
- Harness temporário removido após o teste.

## Validação manual obrigatória

Executar `prototype_arena.tscn` no editor e realizar três ciclos contínuos.

### Antes do primeiro ciclo

1. Confirmar vida 100, Luz 0, Instabilidade 0 e contador esperado.
2. Confirmar quatro inimigos, zero núcleos e memória disponível.
3. Confirmar DeathOverlay e rastro ocultos.
4. Observar o Remote Scene Tree para contagens.

### Em cada ciclo

1. Mover com WASD e colidir com as quatro paredes.
2. Apontar e atacar com a foice.
3. Usar esquiva.
4. Receber ao menos um ataque inimigo.
5. Derrotar um inimigo em três golpes sem bônus.
6. Confirmar exatamente um núcleo.
7. Absorver o núcleo ou deixá-lo no chão.
8. No primeiro ciclo, ativar o altar e coletar a memória.
9. Morrer e observar o estado DEAD e `YOU DIED`.
10. Após renascer, preencher a tabela abaixo.

| Ciclo | Mortes | Inimigos antes | Inimigos depois | Núcleos antes | Núcleos depois | Respawn | Vida | Luz | Instabilidade | Altar | Memória | Erros |
| ---: | ---: | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | --- | --- | --- |
| 1 |  |  |  |  |  |  |  |  |  |  |  |  |
| 2 |  |  |  |  |  |  |  |  |  |  |  |  |
| 3 |  |  |  |  |  |  |  |  |  |  |  |  |

### Estados críticos manuais

Distribuir entre os três ciclos:

- morrer durante ataque e rastro;
- morrer durante esquiva;
- morrer durante absorção;
- morrer durante Colapso;
- morrer durante flash de dano.

Após cada retorno, verificar visualmente:

- jogador e HUD normais;
- `COLLAPSE` oculto;
- DeathOverlay desaparecido;
- rastro oculto;
- hitbox desativada fora do ataque;
- altar ainda brilhando;
- controles sem travamento;
- nenhum erro no Output ou Debugger.

## Resultado do teste manual

Validação manual concluída pelo jogador em uma única execução contínua:

- sete mortes consecutivas;
- contador avançou corretamente de 1 até 7;
- movimento, câmera, combate e esquiva permaneceram funcionais;
- BasicReturned morreu em três golpes de 20;
- cada inimigo derrotado deixou um núcleo;
- absorção concedeu Luz e Instabilidade uma única vez;
- dano da foice passou de 20 para 21 com 20 de Luz;
- nível 1 foi ativado em 72 de Instabilidade;
- dano inimigo passou de 10 para 12,5 no nível 1;
- altar foi ativado uma única vez e permaneceu ativo;
- memória coletada permaneceu registrada;
- morte, limpeza, restauração e respawn funcionaram repetidamente;
- vida retornou para 100 após cada renascimento;
- Luz, Instabilidade e nível voltaram para zero;
- inimigos retornaram com 60 de vida;
- núcleos antigos foram removidos;
- respawn permaneceu no altar ativo;
- nenhum controle ou estado ficou travado;
- Output e Debugger permaneceram sem erros.

Verificação técnica complementar de spawns:

- quatro registros de spawn;
- quatro instâncias distintas após cada restauração;
- sete restaurações consecutivas verificadas;
- casos com inimigo ainda em DEAD e após `queue_free()` cobertos;
- cada instância retornou ao transform do próprio spawn;
- no máximo um BasicReturned por ponto de spawn;
- zero falhas.

Resultado final: ciclo principal validado manual e tecnicamente.
