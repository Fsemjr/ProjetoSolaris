# Layout da primeira fase

## Estado anterior

A arena técnica possuía `1600 × 900` pixels, somente quatro paredes externas
e todos os elementos distribuídos no mesmo espaço aberto.

| Elemento | Posição anterior |
| --- | ---: |
| Player e PlayerSpawn | `(800, 450)` |
| `enemy_spawn_01` | `(1100, 450)` |
| `enemy_spawn_02` | `(1040, 220)` |
| `enemy_spawn_03` | `(1040, 680)` |
| `enemy_spawn_04` | `(520, 680)` |
| MemoryFragment | `(650, 260)` |
| RespawnAltar | `(400, 250)` |
| RespawnMarker global | `(400, 308)` |
| ArenaExit | `(1420, 120)` |

Os inimigos não utilizam nós `EnemySpawnPoint` separados. Cada
`BasicReturned` é instanciado diretamente em `Entities`, possui um
`spawn_id` estável e tem seu `global_transform` inicial registrado por
`PrototypeArena`. Esse transform continua sendo usado na restauração.

O GameState preserva a posição global do RespawnMarker quando o altar é
ativado. Transforms de inimigos e posições de objetos não são persistidos no
GameState.

## Fluxo

O novo percurso usa um formato em S:

1. Zona de Entrada, no canto inferior esquerdo.
2. Primeiro Encontro, seguindo para a direita.
3. Área da Memória, depois do primeiro inimigo.
4. Área do Altar, antes da passagem para a faixa intermediária.
5. Encontro Intermediário, percorrido da direita para a esquerda.
6. Encontro Final, acessado pela abertura superior esquerda.
7. Saída da Arena, no extremo superior direito.

As paredes horizontais alternam suas aberturas. A primeira abre à direita e
a segunda abre à esquerda, impedindo um caminho externo direto entre início
e saída sem introduzir portões ou triggers.

## Objetos

| Objeto | Zona | Posição | Função |
| --- | --- | ---: | --- |
| PlayerSpawn | Entrada | `(220, 1180)` | Início seguro e fallback de respawn |
| Player | Entrada | `(220, 1180)` | Instância inicial do jogador |
| MemoryFragment | Memória | `(1050, 1180)` | Registra `prototype_memory_01` |
| RespawnAltar | Altar | `(1450, 1150)` | Ativa o ponto de renascimento |
| RespawnMarker | Altar | `(1450, 1208)` global | Destino seguro de respawn |
| ArenaExit | Saída | `(2180, 180)` | Conclui a arena quando liberada |

## Spawns

| spawn_id | Zona | Posição | Inimigos |
| --- | --- | ---: | ---: |
| `enemy_spawn_01` | Primeiro Encontro | `(750, 1160)` | 1 |
| `enemy_spawn_02` | Encontro Intermediário | `(1800, 700)` | 1 |
| `enemy_spawn_03` | Encontro Intermediário | `(1250, 700)` | 1 |
| `enemy_spawn_04` | Encontro Final | `(1750, 240)` | 1 |

Os quatro IDs e a quantidade total de inimigos foram preservados. As
instâncias intermediárias estão separadas por 550 pixels e nenhum spawn
intersecta uma parede, objeto interativo ou outro inimigo.

## Limites

- Tamanho anterior: `1600 × 900`.
- Tamanho atual: `2400 × 1400`.
- Limites anteriores da câmera: `(0, 0)` até `(1600, 900)`.
- Limites atuais da câmera: `(0, 0)` até `(2400, 1400)`.
- Zoom, suavização e rotação da câmera foram preservados.

Paredes externas:

- superior: centro `(1200, 20)`, tamanho `2400 × 40`;
- inferior: centro `(1200, 1380)`, tamanho `2400 × 40`;
- esquerda: centro `(20, 700)`, tamanho `40 × 1400`;
- direita: centro `(2380, 700)`, tamanho `40 × 1400`.

Divisores do percurso:

- divisor inferior: `x = 0–1650`, `y = 930–970`;
- divisor superior: `x = 750–2400`, `y = 430–470`.

As três faixas jogáveis possuem aproximadamente 390, 460 e 390 pixels de
altura útil. As passagens alternadas possuem cerca de 710 pixels de largura,
permitindo movimento, combate e esquiva sem criar gargalos estreitos.

## Hierarquia e referências

Foram preservados os caminhos usados por `prototype_arena.gd`:

```text
PrototypeArena
├── Environment
│   ├── Floor
│   ├── ZoneFloors
│   ├── ZoneMarkers
│   └── Walls
├── Objects
├── Entities
├── Pickups
├── PlayerSpawn
└── CanvasLayer
```

`Entities`, `Objects`, `Pickups`, `PlayerSpawn` e
`CanvasLayer/PlayerHUD` permaneceram na hierarquia original. Nenhum NodePath,
grupo, owner, sinal ou regra de restauração precisou ser alterado.

## Decisões

- O altar fica próximo ao centro do percurso e antes da área com dois
  inimigos, criando um ponto de retorno seguro antes da maior pressão.
- A memória aparece depois do primeiro encontro para associar exploração e
  combate antes de apresentar o objetivo persistente.
- Os dois inimigos intermediários ocupam uma área de `2320 × 460` pixels,
  com separação suficiente para esquiva e divisão dos alvos.
- O último inimigo fica na faixa superior, entre a entrada dessa área e a
  saída.
- A saída ocupa o final do S, distante do PlayerSpawn e protegida somente
  pela condição já existente de quatro inimigos, memória e altar.
- Cores de piso e uma linha discreta diferenciam o percurso sem introduzir
  arte final ou instruções de tutorial.

## Arte futura

Elementos provisórios que poderão ser substituídos:

- polígonos coloridos dos pisos;
- linha indicativa do percurso;
- paredes retangulares;
- cores de identificação das zonas;
- visuais geométricos do altar, memória e saída;
- formas provisórias do jogador e dos inimigos.

Nenhuma imagem, animação final, iluminação definitiva ou áudio foi criado
nesta reorganização.
