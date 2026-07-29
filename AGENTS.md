# Regras do Projeto

- O projeto deve utilizar Godot 4.x.
- Todo código deve ser escrito em GDScript.
- Usar tipagem estática sempre que possível.
- Não modificar arquivos fora do escopo da tarefa.
- Não criar funcionalidades que não estejam documentadas.
- Cenas devem ter responsabilidades bem definidas.
- Sistemas reutilizáveis devem usar composição.
- Não programar o jogo inteiro em um único script.
- Sempre informar quais arquivos foram criados ou modificados.
- Sempre testar o projeto após uma alteração.

# Projeto Solaris — Regras para Agentes de Programação

## 1. Objetivo do projeto

Projeto Solaris é um jogo 2D de ação dark fantasy desenvolvido na Godot Engine.

O projeto deve priorizar:

* código simples e compreensível;
* sistemas desacoplados;
* cenas reutilizáveis;
* baixo acoplamento entre jogador, inimigos e interface;
* facilidade de manutenção;
* escopo controlado;
* compatibilidade com Godot 4.x.

O projeto está em fase inicial. Não criar sistemas complexos sem que estejam definidos no `GAME_DESIGN.md` ou no `TASKS.md`.

---

## 2. Tecnologias obrigatórias

* Engine: Godot 4.x.
* Linguagem principal: GDScript.
* Plataforma inicial: Windows PC.
* Tipo de jogo: 2D.
* Controle principal: teclado e mouse.
* Controle de versão: Git.
* Documentação: Markdown.

Não utilizar C#, C++, plugins externos ou bibliotecas externas sem autorização explícita.

---

## 3. Regras de programação

### 3.1 Tipagem

Utilizar tipagem estática sempre que possível.

Exemplo correto:

```gdscript
var movement_speed: float = 200.0
var current_health: int = 100

func take_damage(amount: int) -> void:
    current_health -= amount
```

Evitar variáveis sem tipo quando o tipo já for conhecido.

---

### 3.2 Responsabilidade dos scripts

Cada script deve possuir uma responsabilidade clara.

Exemplos:

* `player_movement.gd`: movimentação do jogador;
* `health_component.gd`: vida e dano;
* `player_combat.gd`: ataques do jogador;
* `corrupted_light_component.gd`: Luz Corrompida;
* `enemy_ai.gd`: comportamento do inimigo.

Não colocar movimentação, combate, inventário, interface, salvamento e inimigos em um único script.

---

### 3.3 Composição

Preferir composição em vez de scripts gigantes.

Sistemas reutilizáveis deverão ser criados como componentes.

Exemplos:

* componente de vida;
* componente de hitbox;
* componente de hurtbox;
* componente de Luz Corrompida;
* componente de status;
* componente de detecção.

Jogadores e inimigos poderão utilizar os mesmos componentes quando fizer sentido.

---

### 3.4 Comunicação entre sistemas

Utilizar sinais para comunicar eventos entre sistemas.

Exemplos:

```gdscript
signal health_changed(current_health: int, maximum_health: int)
signal died
signal corrupted_light_changed(current_value: float)
```

A interface não deve controlar diretamente a lógica do jogador.

A interface deve observar sinais e atualizar seus elementos visuais.

---

### 3.5 Nomes

Utilizar nomes em inglês para:

* arquivos;
* pastas;
* classes;
* funções;
* variáveis;
* sinais;
* nós das cenas.

Comentários e documentação podem ser escritos em português.

Exemplos:

```text
player.gd
health_component.gd
prototype_arena.tscn
corrupted_light.gd
```

Utilizar `snake_case` para arquivos, funções e variáveis.

Utilizar `PascalCase` para classes declaradas com `class_name`.

---

## 4. Organização do projeto

Estrutura inicial:

```text
res://
├── autoload/
├── assets/
│   ├── audio/
│   ├── fonts/
│   ├── sprites/
│   └── tilesets/
├── scenes/
│   ├── characters/
│   ├── enemies/
│   ├── levels/
│   └── ui/
├── scripts/
│   ├── characters/
│   ├── enemies/
│   └── world/
├── systems/
├── tests/
├── ui/
├── AGENTS.md
├── ARCHITECTURE.md
├── GAME_DESIGN.md
├── README.md
├── TASKS.md
└── project.godot
```

Não criar novas pastas sem necessidade clara.

Não reorganizar arquivos existentes sem autorização ou justificativa técnica.

---

## 5. Regras para cenas

Cada cena deve representar uma entidade ou responsabilidade clara.

Exemplos:

```text
player.tscn
basic_enemy.tscn
prototype_arena.tscn
player_hud.tscn
corrupted_light_orb.tscn
```

O jogador deve utilizar `CharacterBody2D`.

Inimigos móveis devem utilizar `CharacterBody2D`.

Áreas de ataque, dano e coleta devem utilizar `Area2D`.

Elementos da interface devem utilizar nós derivados de `Control`.

A câmera principal deve utilizar `Camera2D`.

---

## 6. Regras do jogador

O jogador:

* deve permanecer próximo ao centro da câmera;
* deve ser controlado por teclado e mouse;
* deve possuir movimentação em oito direções;
* deve controlar manualmente seus ataques;
* deve possuir vida;
* deve possuir esquiva;
* deve conseguir receber dano;
* deve poder morrer;
* deve renascer;
* deve acumular Luz Corrompida temporária.

Não implementar habilidades, armas ou atributos que ainda não estejam documentados.

---

## 7. Regras da câmera

A câmera:

* deve acompanhar o jogador;
* deve manter o jogador centralizado;
* não deve rotacionar;
* deve possuir zoom constante durante o combate;
* pode utilizar suavização de movimento;
* deve respeitar os limites da fase;
* não deve mostrar áreas externas ao mapa.

Não implementar mudanças automáticas de zoom no primeiro protótipo.

---

## 8. Regras do combate

O combate inicial será manual.

Controles previstos:

```text
W, A, S, D: movimentação
Mouse: direção do personagem ou da mira
Botão esquerdo: ataque básico
Botão direito: habilidade secundária futura
Espaço: esquiva
E: interação ou absorção
Esc: pausa
```

No primeiro protótipo, implementar somente:

* movimentação;
* ataque básico;
* dano;
* vida;
* inimigo básico;
* morte;
* renascimento;
* absorção de Luz Corrompida.

Não implementar árvores de habilidades, armas múltiplas ou sistemas avançados antes do funcionamento desse ciclo básico.

---

## 9. Regras da Luz Corrompida

A Luz Corrompida é um recurso temporário obtido dos inimigos.

Ela deve:

* ser obtida após a derrota de inimigos;
* possuir valor máximo;
* fortalecer temporariamente o jogador;
* aumentar a instabilidade;
* ser perdida quando o jogador morrer;
* ser representada visualmente na interface.

A Luz Corrompida não deve funcionar como moeda permanente.

Os valores de balanceamento devem ser exportados para o Inspector sempre que possível.

Exemplo:

```gdscript
@export var corrupted_light_reward: float = 10.0
@export var maximum_corrupted_light: float = 100.0
```

---

## 10. Regras da morte

Quando o jogador morrer:

1. os controles devem ser desativados;
2. o estado de morte deve ser ativado;
3. a Luz Corrompida temporária deve ser removida;
4. o contador de mortes deve aumentar;
5. o jogador deve retornar ao ponto de renascimento;
6. sua vida deve ser restaurada;
7. seus controles devem ser reativados.

A morte não deve simplesmente recarregar toda a aplicação.

A memória e os dados permanentes não devem ser apagados.

---

## 11. Limites de escopo

Não implementar sem tarefa específica:

* mundo aberto;
* multiplayer;
* geração procedural;
* sistema completo de inventário;
* crafting;
* árvores de habilidades extensas;
* dezenas de inimigos;
* sete regiões completas;
* sistema complexo de diálogos;
* cinemáticas;
* integração online;
* conquistas da Steam;
* suporte para consoles;
* sistema de mods.

O primeiro objetivo é criar uma arena jogável de aproximadamente cinco a dez minutos.

---

## 12. Procedimento obrigatório para cada tarefa

Antes de programar:

1. ler `AGENTS.md`;
2. ler `GAME_DESIGN.md`;
3. ler `ARCHITECTURE.md`;
4. verificar a tarefa atual em `TASKS.md`;
5. examinar os arquivos relacionados;
6. identificar quais arquivos precisarão ser modificados.

Durante a implementação:

1. alterar somente os arquivos necessários;
2. manter compatibilidade com Godot 4.x;
3. não inventar funcionalidades;
4. evitar duplicação de código;
5. documentar decisões não óbvias;
6. tratar referências nulas quando necessário.

Depois da implementação:

1. verificar erros de sintaxe;
2. executar o projeto;
3. verificar erros no debugger;
4. testar manualmente a funcionalidade;
5. informar arquivos criados;
6. informar arquivos modificados;
7. informar como testar;
8. registrar limitações conhecidas.

---

## 13. Formato da resposta do agente

Ao terminar uma tarefa, responder com:

```text
Resumo:
- O que foi implementado.

Arquivos criados:
- Caminho dos arquivos.

Arquivos modificados:
- Caminho dos arquivos.

Como testar:
1. Instruções de teste.

Limitações:
- Funcionalidades ainda não implementadas.
```

---

## 14. Proibições

O agente não deve:

* apagar arquivos sem autorização;
* substituir sistemas funcionais sem justificativa;
* modificar todo o projeto para resolver um problema pequeno;
* criar código fora do escopo da tarefa;
* instalar dependências externas;
* alterar configurações globais sem explicar;
* criar arte ou áudio como se fossem recursos finais;
* afirmar que uma funcionalidade foi testada quando não foi;
* esconder erros encontrados;
* deixar erros de parser conhecidos;
* programar o jogo inteiro em uma única tarefa.

---

## 15. Regra principal

Sempre escolher a solução mais simples que cumpra os requisitos atuais.

O projeto deve crescer em pequenas etapas testáveis.
