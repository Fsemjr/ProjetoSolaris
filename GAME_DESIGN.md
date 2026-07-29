# Visão Geral

Projeto Solaris será um jogo 2D de ação dark fantasy desenvolvido em Godot 4.

## Estrutura

O jogo será dividido em fases fechadas, não utilizando mundo aberto.

Cada fase representará uma região contaminada pela luz corrompida e terá:

- área limitada;
- grupos ou ondas de inimigos;
- objetivos específicos;
- eventos narrativos;
- um inimigo especial ou chefe;
- ponto de entrada e saída.

## Câmera

O jogo utilizará visão superior.

A câmera:

- acompanhará o jogador;
- não terá rotação;
- manterá zoom constante;
- utilizará suavização de movimento;
- respeitará os limites de cada fase.

## Referência

Zombie Survivors será usado apenas como referência para:

- perspectiva;
- legibilidade do combate;
- quantidade de inimigos;
- progressão durante a partida;
- organização visual da interface.

O projeto não deverá copiar personagens, arte, mapas, código ou identidade visual.

# Projeto Solaris — Game Design Document

## 1. Visão geral

Projeto Solaris é um jogo 2D de ação dark fantasy para PC, desenvolvido na Godot Engine 4.

O jogador controla o Camponês Sem Nome, um mortal preso em um mundo no qual a morte deixou de ser definitiva.

Diferentemente dos demais Retornados, o protagonista mantém suas memórias depois de morrer. Ele também consegue absorver a Luz Corrompida presente nas criaturas do mundo, transformando-a temporariamente em poder.

O jogo será dividido em fases. Não será um mundo aberto.

---

## 2. Conceito principal

O ciclo principal do jogo será:

```text
Entrar em uma fase
↓
Explorar a região
↓
Enfrentar inimigos
↓
Absorver Luz Corrompida
↓
Escolher melhorias temporárias
↓
Encontrar memórias e eventos
↓
Enfrentar o chefe ou cumprir o objetivo
↓
Concluir a fase ou morrer
↓
Retornar ao refúgio ou ponto de renascimento
```

O jogador deve sentir que cada morte faz parte da história e não é apenas uma tela de derrota.

---

## 3. Plataforma

Plataforma inicial:

* Windows PC.

Controles principais:

* teclado;
* mouse.

Suporte para controle poderá ser avaliado futuramente, mas não faz parte do primeiro protótipo.

---

## 4. Gênero

O jogo combina elementos de:

* ação 2D;
* dark fantasy;
* sobrevivência;
* progressão durante a fase;
* progressão permanente limitada;
* exploração;
* combate contra grupos de inimigos;
* elementos roguelite.

O jogo não será uma cópia de nenhum título específico.

---

## 5. Referências

Zombie Survivors será usado como referência para:

* perspectiva superior;
* legibilidade do combate;
* presença de múltiplos inimigos;
* evolução durante uma partida;
* interface de vida e recursos;
* estrutura de sobrevivência em arenas.

O projeto deverá desenvolver identidade própria por meio de:

* combate manual;
* narrativa da morte;
* absorção da Luz Corrompida;
* protagonista que mantém suas memórias;
* ambientação dark fantasy;
* fases com exploração e objetivos;
* consequências narrativas das mortes.

Não copiar personagens, nomes, arte, código, mapas, interface ou identidade visual de outros jogos.

---

## 6. Estrutura das fases

O jogo completo deverá possuir fases maiores, com duração média planejada de aproximadamente 20 a 30 minutos.

Essa duração poderá variar conforme:

* habilidade do jogador;
* exploração;
* dificuldade;
* eventos;
* quantidade de combates;
* chefe da região.

As fases serão áreas fechadas, com limites definidos.

Cada fase poderá conter:

* ponto inicial;
* caminhos principais;
* caminhos opcionais;
* arenas de combate;
* inimigos comuns;
* inimigos especiais;
* eventos narrativos;
* lembranças;
* altares ou pontos de renascimento;
* objetivo principal;
* chefe;
* saída.

O primeiro protótipo não deverá possuir uma fase de 30 minutos.

O primeiro protótipo deverá testar aproximadamente cinco a dez minutos de gameplay.

---

## 7. Câmera

O jogo utilizará visão superior 2D.

A câmera:

* acompanhará o jogador;
* manterá o jogador centralizado;
* não rotacionará;
* utilizará zoom constante;
* poderá utilizar suavização;
* respeitará os limites da fase.

A câmera deverá permitir que o jogador identifique ameaças próximas sem revelar toda a fase.

Mudanças dinâmicas de câmera poderão ser avaliadas futuramente para chefes ou eventos, mas não fazem parte do primeiro protótipo.

---

## 8. Jogador

O jogador controla o Camponês Sem Nome.

Características narrativas:

* preserva suas memórias após morrer;
* sente e recorda todas as mortes;
* não é fisicamente imortal;
* pode morrer por ferimentos;
* renasce depois da morte;
* absorve Luz Corrompida;
* perde o poder temporário quando morre;
* mantém sua identidade;
* acumula o peso psicológico de suas experiências.

Características iniciais de gameplay:

* movimentação em oito direções;
* ataque controlado pelo jogador;
* direção do ataque baseada no mouse;
* vida;
* esquiva;
* absorção;
* morte;
* renascimento;
* melhorias temporárias.

---

## 9. Controles iniciais

```text
W: mover para cima
A: mover para a esquerda
S: mover para baixo
D: mover para a direita

Mouse: apontar ou determinar a direção do ataque
Botão esquerdo: ataque básico
Espaço: esquiva
E: interagir ou absorver
Esc: menu de pausa
```

O botão direito será reservado para uma habilidade secundária futura.

Os controles poderão ser alterados nas configurações em versões futuras.

---

## 10. Combate

O jogador terá controle manual sobre os ataques.

O combate deverá valorizar:

* movimentação;
* posicionamento;
* direção do ataque;
* tempo de ataque;
* esquiva;
* leitura dos inimigos;
* gerenciamento de Luz Corrompida;
* decisão entre atacar, fugir e absorver.

O jogador não deve permanecer parado enquanto ataques automáticos resolvem todo o combate.

---

## 11. Ataque básico

O ataque inicial do protótipo poderá ser corpo a corpo.

Proposta inicial:

* ataque frontal;
* pequeno arco de alcance;
* curto tempo de recuperação;
* dano fixo inicial;
* direção determinada pelo mouse;
* possibilidade de atingir mais de um inimigo próximo.

Os valores finais ainda serão definidos por testes.

Valores provisórios:

```text
Dano base: 20
Alcance: 60 pixels
Tempo entre ataques: 0,5 segundo
```

Esses números não são definitivos.

---

## 12. Esquiva

O jogador possuirá uma esquiva curta.

A esquiva deverá:

* mover o jogador rapidamente;
* seguir a direção de movimento;
* possuir tempo de recarga;
* impedir uso contínuo;
* ajudar a escapar de grupos de inimigos.

A existência de quadros de invulnerabilidade ainda deverá ser testada.

Configuração provisória:

```text
Duração: 0,2 segundo
Recarga: 1 segundo
```

---

## 13. Vida

O protagonista terá:

```text
Vida máxima inicial: 100
Vida inicial: 100
```

Quando a vida chegar a zero, o jogador morrerá.

No primeiro protótipo, não haverá ferimentos permanentes.

---

## 14. Luz Corrompida

A Luz Corrompida é o principal recurso temporário do jogo.

Criaturas retornadas carregam núcleos dessa energia.

Quando um inimigo é derrotado, o jogador poderá absorver sua Luz Corrompida.

A absorção poderá:

* aumentar dano temporariamente;
* alimentar habilidades;
* aumentar a instabilidade;
* alterar efeitos visuais;
* criar riscos para o jogador.

A Luz Corrompida deverá ser perdida quando o jogador morrer.

Valor provisório:

```text
Luz Corrompida máxima: 100
```

---

## 15. Instabilidade

Absorver poder não deve ser uma escolha automaticamente positiva.

Cada absorção também aumentará a Instabilidade.

A Instabilidade representa o esforço do fragmento de luz para converter a energia corrompida.

Possíveis consequências:

* perda gradual de vida;
* distorção visual;
* redução de defesa;
* surgimento de ecos;
* ataques mais fortes;
* habilidades instáveis;
* eventos narrativos;
* risco de colapso.

No primeiro protótipo, a Instabilidade poderá aplicar somente um efeito simples.

Proposta inicial:

```text
De 0 a 69:
Sem penalidade grave.

De 70 a 89:
O jogador recebe mais dano.

De 90 a 100:
O jogador perde vida lentamente.
```

Os valores deverão ser balanceados em testes.

---

## 16. Absorção

A absorção deverá exigir uma ação do jogador.

O jogador não deverá coletar automaticamente toda Luz Corrompida sem risco.

Proposta inicial:

1. o inimigo é derrotado;
2. deixa um núcleo ou estado absorvível;
3. o jogador se aproxima;
4. pressiona `E`;
5. permanece vulnerável durante um curto período;
6. recebe Luz Corrompida;
7. aumenta sua Instabilidade.

Isso transforma a absorção em uma decisão de risco.

---

## 17. Morte e renascimento

Quando o jogador morrer:

* perderá a Luz Corrompida acumulada;
* perderá melhorias temporárias da fase;
* retornará ao último ponto de renascimento;
* manterá memórias descobertas;
* manterá informações narrativas;
* aumentará seu contador de mortes;
* poderá encontrar mudanças em diálogos ou eventos.

O jogador não deverá perder todo o progresso narrativo.

A morte deverá ser integrada ao universo do jogo.

---

## 18. Memórias

As memórias são uma forma de progressão narrativa permanente.

O jogador poderá encontrar:

* lembranças de vidas anteriores;
* registros da guerra entre Sol e Lua;
* memórias de criaturas;
* ecos de inimigos derrotados;
* informações sobre os Paladinos;
* pistas sobre os sete fragmentos;
* fragmentos da identidade do protagonista.

Depois de descobertas, essas memórias permanecerão registradas mesmo após a morte.

---

## 19. Progressão temporária

Durante cada fase, o jogador poderá receber melhorias temporárias.

Exemplos:

* aumento de dano;
* aumento de alcance;
* recuperação de vida;
* redução da recarga da esquiva;
* ataque adicional;
* efeito de Luz Corrompida;
* maior resistência;
* absorção mais rápida.

Essas melhorias serão perdidas após a morte ou conclusão da fase, conforme o sistema final de progressão.

O primeiro protótipo poderá utilizar somente três melhorias.

---

## 20. Progressão permanente

A progressão permanente deverá ser limitada.

O objetivo não é tornar o jogador tão forte que a morte deixe de importar.

Possíveis progressões permanentes:

* novas informações;
* novas regiões;
* novas armas;
* novas opções de melhoria;
* lembranças;
* atalhos;
* alterações no refúgio;
* habilidades narrativamente justificadas.

Atributos permanentes ainda não estão definidos.

---

## 21. Inimigos

O primeiro protótipo terá apenas um inimigo básico.

Características iniciais:

* identifica o jogador a uma distância limitada;
* move-se em direção ao jogador;
* ataca quando estiver próximo;
* recebe dano;
* morre;
* deixa Luz Corrompida;
* pode renascer quando a fase for reiniciada.

Futuramente poderão existir:

* inimigos rápidos;
* inimigos resistentes;
* inimigos de longa distância;
* inimigos de suporte;
* criaturas deformadas;
* antigos membros das Guildas;
* chefes ligados aos fragmentos.

---

## 22. Primeiro protótipo

O primeiro protótipo deverá conter:

* uma arena;
* um jogador;
* câmera;
* movimentação;
* direção pelo mouse;
* ataque básico;
* esquiva;
* vida;
* um tipo de inimigo;
* dano;
* morte;
* renascimento;
* Luz Corrompida;
* Instabilidade;
* interface básica;
* contador de mortes.

Duração esperada:

```text
Cinco a dez minutos.
```

A arte poderá utilizar formas simples e recursos temporários.

O objetivo é testar a jogabilidade, não a qualidade visual.

---

## 23. Critérios de sucesso do protótipo

O protótipo será considerado funcional quando:

* o jogador puder se movimentar sem erros;
* a câmera acompanhar corretamente;
* o ataque seguir a direção do mouse;
* inimigos perseguirem o jogador;
* ataques causarem dano;
* inimigos puderem morrer;
* o jogador puder absorver Luz Corrompida;
* a Luz aumentar temporariamente seu poder;
* a Instabilidade gerar uma penalidade;
* o jogador puder morrer;
* o jogador puder renascer;
* recursos temporários forem perdidos após a morte;
* o projeto executar sem erros de parser.

---

## 24. Questões ainda não definidas

As seguintes decisões ainda precisam ser tomadas:

* arma inicial do protagonista;
* aparência do Camponês;
* estilo artístico;
* sistema exato de melhorias;
* comportamento completo da Instabilidade;
* estrutura do refúgio;
* tipos de chefes;
* quantidade total de fases;
* funcionamento dos sete fragmentos;
* progressão permanente;
* história da primeira região;
* condições para concluir cada fase.

Essas decisões deverão ser feitas antes da implementação dos respectivos sistemas.
