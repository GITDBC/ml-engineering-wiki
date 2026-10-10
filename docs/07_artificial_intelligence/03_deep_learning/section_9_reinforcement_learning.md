---
authors: Daniel Bazo Correa
description: Fundamentos del Aprendizaje por Refuerzo.
title: Aprendizaje por Refuerzo
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

El **Aprendizaje por Refuerzo** (_Reinforcement Learning_, RL) constituye un paradigma
del aprendizaje automático en el cual un agente aprende a tomar decisiones mediante la
interacción continua con un entorno. A diferencia del aprendizaje supervisado, en RL no
se proporcionan ejemplos etiquetados; el comportamiento deseado se induce mediante un
**sistema de recompensas**, cuyo propósito es incentivar al agente a ejecutar acciones
que maximicen su desempeño a largo plazo. La señal de recompensa actúa, por tanto, como
el principal mecanismo de guía del aprendizaje.

Este enfoque es particularmente adecuado en escenarios donde, dado un **estado**, el
agente debe seleccionar una **acción**, pero las trayectorias posibles pueden variar, y
una misma acción puede producir resultados distintos. La ausencia de una respuesta
correcta inmediata obliga al agente a descubrir progresivamente qué decisiones son más
efectivas, evaluando las consecuencias futuras de sus acciones.

## Elementos fundamentales

El marco conceptual de RL se estructura en torno a varios componentes esenciales que
interactúan de manera sistemática. El **agente** es la entidad que toma decisiones y
ejecuta acciones, mientras que el **entorno** representa todo aquello que el agente no
puede controlar directamente. Tras cada acción, el entorno proporciona una
**recompensa** y un nuevo **estado**, cerrando así el ciclo de interacción.

El **estado** $S$ describe la situación actual del agente y resume la información
relevante del entorno. Una hipótesis fundamental es la **propiedad de Markov**, según la
cual el futuro depende únicamente del estado presente y no de la secuencia completa de
eventos pasados. La **acción** $A$ es la decisión que el agente toma en un estado
determinado y que provoca una transición en el entorno. La **recompensa** $R$ es una
señal escalar inmediata que evalúa la acción realizada; en muchos modelos se define como
$R(S)$, dependiendo del estado alcanzado. En los **estados terminales** no se otorgan
recompensas adicionales.

Formalmente, la dinámica del proceso se describe mediante la tupla $(S, A, R(S), S')$,
donde $S'$ es el nuevo estado resultante de ejecutar la acción $A$ en el estado $S$.

## Retorno y factor de descuento

El desempeño del agente se evalúa no solo por las recompensas inmediatas, sino por el
**retorno** acumulado. El **retorno** $G_t$ representa la suma total de recompensas
esperadas a partir de un instante $t$, constituyendo una medida global del éxito de la
estrategia seguida. Matemáticamente se expresa como:

$G_t = R_{t+1} + \gamma R_{t+2} + \gamma^2 R_{t+3} + \dots$

donde $\gamma$ es el **factor de descuento**, con $0 < \gamma \le 1$. Este parámetro
ajusta la importancia relativa de las recompensas futuras: valores pequeños de $\gamma$
inducen un comportamiento más “impaciente”, priorizando beneficios inmediatos, mientras
que valores cercanos a uno favorecen estrategias orientadas al largo plazo.

## Políticas y objetivo del aprendizaje

La **política** $\pi$ define la estrategia del agente, determinando qué acción
seleccionar en cada estado. Una política puede ser **determinista**, asignando una
acción específica a cada estado, o **estocástica**, describiendo una distribución de
probabilidad $\pi(a \mid S)$ sobre las acciones posibles en un estado dado.

El objetivo del aprendizaje por refuerzo es encontrar una **política óptima** $\pi^*$
que maximice el retorno esperado a lo largo del tiempo, equilibrando de manera eficiente
las recompensas inmediatas y futuras dentro del entorno.

## Procesos de decisión de Markov (MDP)

El **Proceso de Decisión de Markov** (MDP) proporciona el marco matemático para modelar
situaciones donde los resultados son parcialmente aleatorios y parcialmente
controlables. Un MDP integra estados, acciones y recompensas, y, gracias a la propiedad
de Markov, la evolución del sistema depende únicamente del estado actual y de la acción
ejecutada, lo que simplifica el análisis y el diseño de algoritmos de aprendizaje.

### Componentes de la interacción

- **Agente**: Entidad que ejecuta acciones y toma decisiones.
- **Entorno**: Todo lo que el agente no controla directamente, cuya evolución depende de
  las acciones del agente.
- **Acción** ($A_t$): Decisión tomada en el estado $S_t$.
- **Estado** ($S_t$): Información relevante del entorno después de ejecutar una acción.
- **Recompensa** ($R_t$): Señal escalar que evalúa la acción realizada.

## Funciones de valor

Las **funciones de valor** estiman las recompensas futuras esperadas y proporcionan una
base cuantitativa para comparar decisiones. La **función de valor de estado**
$V^{\pi}(s)$ calcula el retorno esperado al iniciar en el estado $s$ y seguir la
política $\pi$:

$V^{\pi}(s) = \mathbb{E}_{\pi}\left[\sum_{t=0}^{\infty} \gamma^t R_t \mid S_0 = s\right]$

La **función de valor acción–estado** $Q^{\pi}(s,a)$ estima el retorno esperado al
ejecutar la acción $a$ en el estado $s$ y continuar siguiendo la política $\pi$:

$Q^{\pi}(s,a) = \mathbb{E}_{\pi}\left[\sum_{t=0}^{\infty} \gamma^t R_t \mid S_0 = s, A_0 = a\right]$

Estas funciones permiten al agente seleccionar acciones que maximizan el retorno a largo
plazo.

## Optimalidad y ecuación de Bellman

Las **funciones de valor óptimas**, $V^*(S)$ y $Q^*(S,a)$, representan el mejor
desempeño alcanzable por cualquier política:

$V^*(S) = \max_{\pi} V^{\pi}(S) = \max_a Q^*(S,a)$

La **ecuación de Bellman** establece una relación recursiva que permite calcular estos
valores. Para entornos deterministas:

$Q^*(s,a) = R(s) + \gamma \max_{a'} Q^*(s', a')$

donde $s'$ es el estado alcanzado tras ejecutar la acción $a$ en $s$. En entornos
estocásticos, esta relación se expresa en términos de valor esperado, considerando la
probabilidad de transitar a cada posible estado siguiente.

## Profundización y métodos avanzados

Los estados pueden representarse como vectores que incluyen múltiples características,
como posición, rotación y velocidades, lo que permite describir entornos complejos. En
tales casos, se pueden utilizar **redes neuronales** para aproximar funciones de valor
$Q(s,a)$ en espacios de estados y acciones continuos, generando un **aproximador de
función** que mapea estados a valores de acción.

La **política $\epsilon$-greedy** equilibra exploración y explotación, permitiendo al
agente probar nuevas acciones con una probabilidad $\epsilon$ y, simultáneamente,
aprovechar el conocimiento actual para maximizar recompensas. Durante el entrenamiento,
$\epsilon$ puede ajustarse dinámicamente para priorizar inicialmente la exploración y,
posteriormente, la explotación.

### Episodios y métodos de aprendizaje

Un **episodio** comprende la secuencia completa de interacciones entre el agente y el
entorno, desde un estado inicial hasta un estado terminal. Los métodos de aprendizaje
pueden clasificarse en **basados en modelo** (model-based) o **sin modelo**
(model-free). Los primeros utilizan un modelo del entorno para predecir estados futuros
y recompensas, mientras que los segundos aprenden directamente a partir de la
experiencia generada por la interacción.

### Métodos de policy gradient y temporal difference

Los **métodos de Policy Gradient** ajustan la probabilidad de seleccionar cada acción
para maximizar el retorno esperado $G_t$. Por su parte, el **Temporal Difference (TD)
Learning** permite actualizar valores de estado o acción dentro de un episodio sin
necesidad de esperar a su finalización, combinando ideas de Monte Carlo y de predicción
basada en estimaciones.

Ejemplos de algoritmos incluyen **SARSA**, **Expected SARSA** y **Q-learning**, que se
diferencian en su enfoque **on-policy** u **off-policy** y en la forma de actualizar los
valores de acción $Q(s,a)$:

$Q(S_t, a_t) \leftarrow Q(S_t, a_t) + \alpha [r_t + \gamma Q(S_{t+1}, a_{t+1}) - Q(S_t, a_t)]$

donde $\alpha$ es la tasa de aprendizaje.

### Deep Q-Learning

Para entornos con estados y acciones continuos, se emplean **Deep Q-Networks (DQN)** que
combinan redes neuronales con aprendizaje basado en valores. Estas redes aproximan la
función $Q(s,a)$ y permiten manejar un gran número de estados de manera eficiente,
aunque el número de acciones sigue siendo limitado en comparación con métodos de
política continua.

### Ejemplos de cálculo

Si un agente transita desde el estado $S=3$ al estado $S=1$ con $\gamma = 0.25$, el
retorno acumulado se calcula como:

$G = 0 + 0.25 \cdot 0 + 0.25^2 \cdot 100 = 6.25$

En un ejemplo de función $Q$ con $\gamma = 0.5$, si el estado $S=2$ puede transitar a
$S=3$ o $S=4$:

$Q(S=2, a=\rightarrow) = 0 + 0.5^3 \cdot 100 = 12.5$,
$Q(S=2, a=\leftarrow) = 0 + 0.5 \cdot 100 = 50$

La acción óptima se selecciona como $\max Q(S, a) = 50$, correspondiendo a la acción
izquierda.

En conclusión, el aprendizaje por refuerzo proporciona un marco riguroso y flexible para
el diseño de agentes autónomos capaces de aprender estrategias óptimas en entornos
complejos, combinando teoría de procesos de decisión de Markov, funciones de valor,
políticas estocásticas y métodos avanzados de aproximación y actualización.
