# Balanceamento do protótipo

## Valores anteriores

### Jogador

| Sistema | Propriedade | Valor anterior | Arquivo ou cena |
| --- | --- | ---: | --- |
| Vida | Vida máxima | 100 | `scenes/characters/player/player.tscn` |
| Movimento | Velocidade normal | 220 px/s | `scripts/characters/player/player_movement.gd` |
| Esquiva | Velocidade | 520 px/s | `scripts/characters/player/player_movement.gd` |
| Esquiva | Duração | 0,20 s | `scripts/characters/player/player_movement.gd` |
| Esquiva | Cooldown | 1,00 s | `scripts/characters/player/player_movement.gd` |
| Esquiva | Invulnerabilidade | Não implementada | — |
| Foice | Dano base | 20 | `scripts/characters/player/player_combat.gd` |
| Foice | Cooldown | 0,50 s | `scripts/characters/player/player_combat.gd` |
| Foice | Duração total | 0,15 s | `scripts/characters/player/player_combat.gd` |
| Foice | Janela ativa | 46% da animação, aproximadamente 0,069 s | `scenes/characters/player/player.tscn` |
| Foice | Alcance | Hitbox 82 × 60 px, deslocada 48 px; alcance frontal aproximado de 89 px | `scenes/characters/player/player.tscn` |

### BasicReturned

| Sistema | Propriedade | Valor anterior | Arquivo ou cena |
| --- | --- | ---: | --- |
| Vida | Vida máxima | 60 | `scenes/enemies/basic_returned/basic_returned.tscn` |
| Movimento | Velocidade de perseguição | 110 px/s | `scripts/enemies/basic_returned/basic_returned.gd` |
| Detecção | Raio | 200 px | `scenes/enemies/basic_returned/basic_returned.tscn` |
| Ataque | Distância | Raio de 52 px | `scenes/enemies/basic_returned/basic_returned.tscn` |
| Ataque | Dano | 10 | `scripts/enemies/basic_returned/basic_returned.gd` |
| Ataque | Cooldown | 1,00 s | `scripts/enemies/basic_returned/basic_returned.gd` |
| Ataque | Janela ativa | 0,10 s | `scenes/enemies/basic_returned/basic_returned.tscn` |
| Morte | Atraso de remoção | 0,50 s | `scripts/enemies/basic_returned/basic_returned.gd` |

### Corrupção

| Sistema | Propriedade | Valor anterior | Arquivo ou cena |
| --- | --- | ---: | --- |
| Núcleo | Luz Corrompida recebida | 10 | `scripts/items/corrupted_light_core.gd` |
| Núcleo | Instabilidade recebida | 6 | `scripts/items/corrupted_light_core.gd` |
| Núcleo | Duração da absorção | 0,75 s | `scripts/items/corrupted_light_core.gd` |
| Luz | Pontos por estágio de bônus | 20 | `systems/corruption_component.gd` |
| Luz | Bônus por estágio | 5% | `systems/corruption_component.gd` |
| Instabilidade | Início do nível 1 | 70 | `systems/corruption_component.gd` |
| Instabilidade | Início do Colapso | 90 | `systems/corruption_component.gd` |
| Instabilidade | Multiplicador de dano recebido | 1,25 | `scripts/characters/player/player_corruption.gd` |
| Colapso | Dano periódico | 5 | `scripts/characters/player/player_corruption.gd` |
| Colapso | Intervalo | 1,00 s | `scripts/characters/player/player_corruption.gd` |

### Arena

| Propriedade | Valor anterior | Arquivo ou cena |
| --- | --- | --- |
| Inimigos comuns iniciais | 1 | `scenes/levels/prototype_arena/prototype_arena.tscn` |
| Posição do inimigo | (1040, 450) | `scenes/levels/prototype_arena/prototype_arena.tscn` |
| PlayerSpawn | (800, 450) | `scenes/levels/prototype_arena/prototype_arena.tscn` |
| Altar | (400, 250), 447,2 px do PlayerSpawn | `scenes/levels/prototype_arena/prototype_arena.tscn` |
| Memória | (650, 260), 242,1 px do PlayerSpawn e 250,2 px do altar | `scenes/levels/prototype_arena/prototype_arena.tscn` |
| Inimigo até PlayerSpawn | 240 px | `scenes/levels/prototype_arena/prototype_arena.tscn` |

## Primeira passagem

| Propriedade | Valor anterior | Valor novo | Motivo da alteração |
| --- | ---: | ---: | --- |
| Velocidade do BasicReturned | 110 px/s | 170 px/s | O jogador continua 29% mais rápido, mas fugir exige posicionamento e a esquiva mantém utilidade. |
| Raio de detecção | 200 px | 240 px | Aumenta a pressão ao explorar sem iniciar todos os combates no PlayerSpawn. |
| Instabilidade por núcleo | 6 | 24 | Com quatro núcleos finitos, produz progressão observável: 24, 48, 72 (nível 1) e 96 (Colapso). |
| Inimigos iniciais | 1 | 4 | Uma única ameaça não exercitava esquiva, absorção sob risco, progressão de Luz ou Instabilidade. |
| Posição dos inimigos | (1040, 450) | (1100, 450), (1040, 220), (1040, 680), (520, 680) | Distribui encontros pela arena, sem sobrepor PlayerSpawn, altar ou memória. |
| Limites e bônus da corrupção | Constantes nos scripts | Exports com os mesmos valores | Permite ajuste pelo Inspector mantendo uma única fonte de verdade por propriedade. |
| Multiplicador de dano recebido | Valor fixo 1,25 | Export com valor 1,25 | Permite ajuste pelo Inspector sem mudar o comportamento desta passagem. |

Valores centrais preservados nesta passagem:

- vida do jogador: 100;
- vida do BasicReturned: 60;
- dano base da foice: 20;
- dano do BasicReturned: 10;
- cooldown da foice: 0,50 segundo;
- cooldown do inimigo: 1,00 segundo;
- Luz por núcleo: 10;
- absorção: 0,75 segundo;
- bônus: 5% a cada 20 de Luz;
- nível 1: 70;
- Colapso: 90;
- movimento e esquiva do jogador.

Distribuição atual:

| Elemento | Posição | Distância do PlayerSpawn |
| --- | --- | ---: |
| BasicReturned | (1100, 450) | 300,0 px |
| BasicReturned2 | (1040, 220) | 332,4 px |
| BasicReturned3 | (1040, 680) | 332,4 px |
| BasicReturned4 | (520, 680) | 362,4 px |
| Altar | (400, 250) | 447,2 px |
| Memória | (650, 260) | 242,1 px |

## Instrumentação de playtest

`prototype_arena.gd` registra somente eventos discretos:

- início da sessão;
- inimigos derrotados;
- núcleos absorvidos;
- mortes do jogador;
- primeira ativação do altar;
- coleta da memória.

Ao encerrar a execução, o Output mostra automaticamente:

```text
Prototype playtest:
Duration: MM:SS
Enemies defeated: N
Cores absorbed: N
Player deaths: N
Memory collected: true/false
Altar activated: true/false
```

O método público `print_playtest_summary()` também disponibiliza o mesmo
resumo para inspeção de desenvolvimento. Não há telemetria por frame nem
persistência em disco.

## Testes necessários

1. Jogar normalmente sem consultar esta tabela e medir tempo e mortes.
2. Confirmar se quatro inimigos criam pressão justa sem cercar o jogador de
   forma inevitável.
3. Comparar movimento normal (220 px/s) com perseguição (170 px/s).
4. Avaliar a esquiva de 0,20 segundo com cooldown de 1,00 segundo.
5. Confirmar três golpes por BasicReturned sem bônus.
6. Tentar absorver durante combate e verificar o risco dos 0,75 segundo.
7. Absorver os quatro núcleos e avaliar a progressão:
   - primeiro: Luz 10, Instabilidade 24;
   - segundo: Luz 20, Instabilidade 48;
   - terceiro: Luz 30, Instabilidade 72, nível 1;
   - quarto: Luz 40, Instabilidade 96, Colapso.
8. Confirmar se o bônus de dano em 20 e 40 de Luz é perceptível sem tornar a
   foice excessiva.
9. Morrer com núcleos no chão e durante absorção.
10. Confirmar limpeza de núcleos, restauração dos quatro inimigos, retorno ao
    altar e persistência da memória.
11. Conferir se a duração total fica entre cinco e dez minutos.

## Resultado do teste manual

Aguardando validação manual do jogador.

## Validação técnica

Validação automatizada controlada executada no Godot 4.5.1:

- scripts e cenas carregaram sem erros;
- quatro inimigos foram registrados;
- perseguição utilizou 170 px/s;
- esquiva iniciou e terminou normalmente;
- três golpes de 20 derrotaram um BasicReturned de 60 de vida;
- o núcleo concedeu 10 de Luz e 24 de Instabilidade em 0,75 segundo;
- 72 ativou o nível 1 e 96 ativou o Colapso;
- ataque inimigo continuou causando 10 de dano;
- morte limpou núcleos e restaurou exatamente quatro inimigos;
- vida, altar, memória, respawn e tela de morte permaneceram funcionais;
- zero falhas e nenhum erro de parser ou runtime.

Essa validação não mede dificuldade, clareza, ritmo ou duração da sessão.
