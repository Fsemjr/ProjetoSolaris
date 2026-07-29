# Solares — Game Design Document

## 1. Visão geral

Solares é um jogo de ação 2D top-down e dark fantasy desenvolvido na Godot.
O jogador controla o Camponês Sem Nome, um mortal que preserva suas memórias
depois de morrer e consegue transformar Luz Corrompida em poder temporário.

O jogo completo é planejado como uma sequência de fases fechadas, não como
mundo aberto. O repositório atual contém somente uma arena técnica destinada
a sessões de aproximadamente cinco a dez minutos.

## 2. Identidade e referências

O combate deve valorizar:

- controle manual;
- posicionamento;
- direção do ataque;
- leitura dos inimigos;
- esquiva;
- escolha do momento de absorver;
- risco e recompensa da Instabilidade.

Jogos de sobrevivência em arena podem servir como referência de perspectiva,
legibilidade e ritmo. O projeto não deve copiar personagens, arte, mapas,
código ou identidade visual de outros jogos.

## 3. Premissa

O Camponês Sem Nome vive em um mundo no qual a morte deixou de ser definitiva.
Diferentemente dos Retornados, ele mantém sua identidade e suas memórias ao
renascer. Inimigos carregam núcleos de Luz Corrompida que podem fortalecê-lo,
mas cada absorção aumenta a Instabilidade.

A morte faz parte do ciclo narrativo e mecânico:

- poder temporário é perdido;
- inimigos retornam;
- o altar permanece ativo;
- memórias e mortes permanecem registradas durante a execução.

## 4. Estado atual do protótipo

O protótipo implementa uma arena fechada de 1600 × 900 pixels com:

- um jogador equipado com foice;
- quatro instâncias do inimigo BasicReturned;
- um altar de renascimento;
- uma memória;
- HUD;
- limites físicos;
- ciclo completo de combate, absorção, morte e respawn.

A meta de duração da arena é de cinco a dez minutos. O balanceamento atual é
uma primeira passagem e ainda pode mudar após novos playtests.

## 5. Controles implementados

| Entrada | Ação |
| --- | --- |
| W, A, S, D | Movimento |
| Mouse | Direção da foice |
| Botão esquerdo | Ataque básico |
| Espaço | Esquiva |
| E | Interação, absorção, altar ou memória |

Esc está mapeado como `pause`, mas a pausa ainda não foi implementada.

## 6. Câmera e arena

A câmera:

- é filha do jogador;
- acompanha o movimento com suavização;
- mantém zoom constante;
- ignora a rotação da foice;
- respeita os limites da arena;
- não mostra áreas externas ao mapa.

A arena possui quatro paredes físicas, espaço para deslocamento e pontos
separados para jogador, inimigos, altar e memória.

## 7. Jogador

O jogador possui:

- 100 de vida;
- movimento em oito direções;
- velocidade normal de 220 px/s;
- foice direcionada pelo mouse;
- esquiva curta;
- HealthComponent;
- HurtboxComponent;
- CorruptionComponent;
- estados de ação e morte coordenados por scripts separados.

### Esquiva

```text
Velocidade: 520 px/s
Duração: 0,20 segundo
Cooldown: 1,00 segundo
Invulnerabilidade: não implementada
```

A esquiva segue a direção atual ou a última direção válida e respeita as
colisões da arena.

## 8. Combate com foice

O ataque é manual, corpo a corpo e orientado pelo mouse.

```text
Dano base: 20
Dano com 20 a 39 de Luz: 21
Cooldown: 0,50 segundo
Duração total: 0,15 segundo
Janela ativa aproximada: 0,069 segundo
Alcance frontal aproximado da hitbox: 89 pixels
```

O mesmo alvo recebe dano apenas uma vez por golpe. Ataques não se sobrepõem e
a Hitbox permanece desligada fora da janela ativa.

## 9. BasicReturned

O protótipo possui um tipo de inimigo e quatro instâncias na arena.

O BasicReturned:

- inicia parado;
- detecta o jogador;
- persegue;
- ataca em curta distância;
- recebe dano;
- entra em DEAD;
- deixa um núcleo;
- é restaurado pela arena após a morte do jogador.

Valores atuais:

```text
Vida: 60
Velocidade: 170 px/s
Detecção: 240 pixels
Alcance de ataque: 52 pixels
Dano: 10
Cooldown: 1,00 segundo
Janela ativa: 0,10 segundo
```

Sem bônus, três golpes de foice derrotam um BasicReturned.

## 10. Luz Corrompida

Cada inimigo derrotado deixa exatamente um CorruptedLightCore.

O núcleo:

- permanece no chão;
- não é coletado automaticamente;
- exige proximidade e a tecla E;
- bloqueia movimento e ataque durante a absorção;
- pode ser cancelado por distância, dano ou morte;
- desaparece ao concluir.

Valores atuais:

```text
Luz por núcleo: 10
Duração da absorção: 0,75 segundo
Luz máxima: 100
Bônus: +5% de dano a cada 20 de Luz
```

Progressão de dano:

| Luz | Multiplicador | Dano da foice |
| ---: | ---: | ---: |
| 0–19 | 1,00 | 20 |
| 20–39 | 1,05 | 21 |
| 40–59 | 1,10 | 22 |
| 60–79 | 1,15 | 23 |
| 80–99 | 1,20 | 24 |
| 100 | 1,25 | 25 |

## 11. Instabilidade

Cada núcleo concede 24 de Instabilidade.

| Nível | Faixa | Efeito implementado |
| --- | --- | --- |
| 0 — Estável | 0–69 | Sem penalidade |
| 1 — Sobrecarregado | 70–89 | Jogador recebe 25% mais dano |
| 2 — Colapso | 90–100 | Mantém dano ampliado e perde 5 de vida por segundo |

Um ataque inimigo de 10 causa 12,5 no nível 1 ou 2. O HUD pulsa em níveis
elevados e mostra `COLLAPSE` no nível 2.

Com os quatro núcleos da arena, a progressão possível é:

```text
24 → 48 → 72 → 96
```

## 12. Altar

O altar é ativado manualmente com E. Ao ativar:

- registra seu ID;
- registra a posição global do RespawnMarker;
- mostra um brilho persistente;
- torna-se o ponto atual de renascimento;
- não precisa ser ativado novamente após a morte.

O protótipo possui um altar.

## 13. Morte e renascimento

Quando a vida chega a zero:

1. o jogador entra em DEAD;
2. ações e hitboxes são bloqueadas;
3. absorções e efeitos ativos são cancelados;
4. o contador de mortes aumenta uma vez;
5. a tela `YOU DIED` aparece;
6. a arena remove núcleos e restaura inimigos;
7. após o atraso, o jogador retorna ao altar ou ao PlayerSpawn;
8. vida volta a 100;
9. Luz e Instabilidade voltam a zero;
10. controles são reativados.

O protótipo não recarrega a aplicação inteira para renascer.

## 14. Memórias

A MemoryFragment registra um `StringName` único no GameState.

Uma memória coletada:

- não pode ser registrada duas vezes;
- desaparece da arena;
- permanece registrada após mortes;
- não persiste depois que a aplicação é fechada.

O protótipo possui uma memória e ainda não possui diário ou narrativa
completa.

## 15. HUD e feedback

O HUD observa sinais e apresenta:

- vida;
- Luz Corrompida;
- Instabilidade;
- contador de mortes;
- prompts de interação;
- indicação de Colapso;
- tela simples de morte.

Feedbacks provisórios incluem flashes de dano, brilho do altar, pulsação de
núcleos e Instabilidade, efeito de absorção e rastro da foice.

## 16. Ciclo principal implementado

```text
Explorar a arena
↓
Combater BasicReturned
↓
Gerar e absorver núcleos
↓
Ganhar Luz e Instabilidade
↓
Ativar altar e coletar memória
↓
Receber dano e morrer
↓
Perder poder temporário
↓
Limpar núcleos e restaurar inimigos
↓
Renascer no altar
↓
Preservar mortes, altar e memórias durante a execução
```

Esse ciclo foi validado manualmente por sete mortes consecutivas e também por
regressões técnicas.

## 17. Implementado no protótipo

- Arena fechada única.
- Movimento, câmera, ataque e esquiva.
- Vida, dano, hitboxes e hurtboxes.
- BasicReturned com estados IDLE, CHASE, ATTACK e DEAD.
- Núcleos e absorção manual.
- Luz Corrompida, bônus de dano e Instabilidade.
- HUD e feedbacks provisórios.
- Altar, morte e respawn.
- Restauração de quatro inimigos sem duplicação.
- Limpeza de núcleos.
- Memória persistente durante a execução.
- Contador de mortes.
- Primeira passagem de balanceamento.

## 18. Planejado / não implementado

- Arte e animações finais.
- Áudio e música.
- Salvamento em disco.
- Menu completo e pausa funcional.
- Múltiplas fases prontas.
- Fases finais de 20 a 30 minutos.
- Chefe.
- Outros tipos de inimigo.
- Habilidades secundárias e múltiplas armas.
- Inventário, equipamentos e crafting.
- Melhorias temporárias escolhidas pelo jogador.
- Progressão permanente.
- Refúgio.
- Diário de memórias.
- Narrativa, diálogos e eventos completos.
- Suporte a controle, consoles, multiplayer ou mundo aberto.

## 19. Visão futura

O jogo completo poderá ter regiões contaminadas, objetivos, exploração,
eventos narrativos, chefes e progressão entre fases. Essas ideias representam
a direção criativa e não funcionalidades existentes no protótipo atual.

Questões futuras incluem:

- aparência final do Camponês Sem Nome;
- identidade visual;
- estrutura do refúgio;
- sistema de melhorias;
- tipos de inimigos e chefes;
- quantidade e objetivos das fases;
- sete fragmentos e sua função narrativa;
- progressão permanente;
- história da primeira região.

## 20. Critérios atuais de sucesso

O protótipo é considerado tecnicamente funcional porque:

- o ciclo principal pode ser concluído repetidamente;
- combate e absorção exigem ação manual;
- Luz oferece benefício;
- Instabilidade produz risco;
- morte restaura a arena sem duplicações;
- altares, mortes e memórias são preservados durante a execução;
- o projeto abre no Godot 4.5.1 sem erros de parser ou runtime.

Isso não significa que o jogo esteja finalizado.
