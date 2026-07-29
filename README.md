# Solares

Solares é um protótipo jogável de ação 2D top-down desenvolvido na Godot.
O jogador combate manualmente com uma foice, absorve Luz Corrompida, gerencia
Instabilidade e retorna à arena por meio de altares após morrer. Memórias,
altares e o contador de mortes persistem durante a execução atual.

O projeto ainda não é um jogo finalizado.

O título adotado pela documentação é **Solares**. A propriedade técnica
`config/name` do arquivo `project.godot` ainda permanece como `Solaris`.

## Estado atual

- Protótipo técnico jogável em uma arena fechada.
- Ciclo principal implementado e validado.
- Arte, efeitos, animações, áudio e narrativa ainda são provisórios ou
  inexistentes.
- Não existe salvamento persistente em disco.
- Não existe build pública final.

## Requisitos

- Godot 4.5.1.
- Windows, Linux ou macOS compatível com a Godot.
- Teclado e mouse.

O projeto usa GDScript. VS Code pode ser utilizado no desenvolvimento, mas
não é necessário para executar o protótipo.

## Como executar

1. Clone ou baixe o repositório.
2. Abra a Godot 4.5.1.
3. Importe o arquivo `project.godot`.
4. Abra o projeto.
5. Pressione F5 para executar a cena principal ou abra a cena e pressione F6.

A cena principal configurada em `project.godot` é:

```text
res://scenes/levels/prototype_arena/prototype_arena.tscn
```

## Controles

| Entrada | Ação |
| --- | --- |
| W, A, S, D | Movimento em oito direções |
| Mouse | Orientação da foice |
| Botão esquerdo do mouse | Ataque com a foice |
| Espaço | Esquiva |
| E | Interação, absorção, altar ou memória |

Existe uma ação `pause` mapeada para Esc no Input Map, mas o menu e a lógica
de pausa ainda não foram implementados.

## Ciclo principal

1. Explorar a arena.
2. Combater os BasicReturned.
3. Absorver os núcleos deixados pelos inimigos.
4. Ganhar Luz Corrompida e Instabilidade.
5. Ativar o altar e encontrar a memória.
6. Morrer e perder Luz e Instabilidade.
7. Remover núcleos antigos e restaurar inimigos.
8. Renascer no altar.
9. Preservar contador de mortes, altar e memórias durante a execução.

## Sistemas implementados

- Movimento com `CharacterBody2D`.
- Câmera centralizada, suavizada e limitada à arena.
- Combate manual direcionado pelo mouse.
- `HealthComponent`.
- `HitboxComponent` e `HurtboxComponent`.
- Inimigo BasicReturned com perseguição, ataque, morte e restauração.
- Núcleos de Luz Corrompida.
- Absorção manual e cancelável.
- Luz Corrompida e bônus temporário de dano.
- Níveis e penalidades de Instabilidade.
- Esquiva com duração e cooldown.
- HUD de vida, Luz, Instabilidade, mortes e prompts.
- Altar, ponto de respawn, morte e renascimento.
- Restauração dos inimigos e limpeza dos núcleos.
- Memórias persistentes durante a execução.
- Tela simples de morte e efeitos visuais provisórios.
- Primeira passagem de balanceamento.
- Ciclo principal validado manual e tecnicamente.
- Controle de versão com Git/GitHub.

## Limitações atuais

- Sem arte final.
- Sem animações finais.
- Sem áudio.
- Sem salvamento persistente em disco.
- Sem menu completo ou pausa funcional.
- Sem múltiplas fases.
- Sem chefe.
- Sem conteúdo narrativo completo.
- Formas, cores e efeitos são provisórios.
- O balanceamento ainda pode mudar.
- Memórias persistem somente enquanto o jogo está aberto.

## Estrutura do projeto

```text
autoload/  Estado global em memória durante a execução
assets/    Diretório reservado para recursos audiovisuais
scenes/    Cenas de entidades, objetos, interface e arena
scripts/   Coordenação e comportamentos específicos
systems/   Componentes reutilizáveis
tests/     Diretório reservado para validações controladas
ui/        Diretório reservado para recursos de interface
```

Algumas pastas reservadas ainda podem estar vazias porque o protótipo não
possui recursos finais.

## Documentação

- [GAME_DESIGN.md](GAME_DESIGN.md) — visão criativa e escopo.
- [ARCHITECTURE.md](ARCHITECTURE.md) — estrutura técnica real.
- [TASKS.md](TASKS.md) — histórico incremental de tarefas.
- [BALANCE_LOG.md](BALANCE_LOG.md) — primeira passagem de balanceamento.
- [CYCLE_TEST_LOG.md](CYCLE_TEST_LOG.md) — validação do ciclo completo.
- [CLEANUP_LOG.md](CLEANUP_LOG.md) — limpeza e regressão final.

## Status

- TASK-001 até TASK-039 concluídas.
- Primeiro protótipo técnico pronto para a próxima fase de desenvolvimento.
