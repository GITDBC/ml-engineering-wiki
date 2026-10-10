---
authors: Daniel Bazo Correa
description:
    Imputación de datos, detección de anomalías, sistemas de recomendación, redes
    neuronales bayesianas y modelos de mezcla de densidades.
title: Temas avanzados
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Este capítulo aborda técnicas avanzadas de machine learning, incluyendo imputación de
datos, detección de anomalías, sistemas de recomendación y modelos probabilísticos.

## Imputación de datos

La imputación de datos es una técnica fundamental en la preparación de datos,
especialmente cuando se enfrentan valores faltantes en un conjunto. Dependiendo del tipo
de variable (numérica o categórica), se aplican diferentes estrategias para completar
los valores ausentes de manera coherente y eficiente.

### Imputación simple

Para variables **numéricas**, se emplean habitualmente medidas de tendencia central como
la **media** o la **mediana**. No obstante, la mediana es preferida en contextos reales
debido a su mayor robustez frente a valores atípicos o fuera de distribución. La
decisión entre usar media o mediana puede fundamentarse en un análisis estadístico
preliminar, como el estudio de la función de distribución acumulada (CDF) y el **rango
intercuartílico (IQR)**, que corresponde a la diferencia entre el percentil 75 y el
percentil 25. Esta evaluación permite identificar valores anómalos y decidir si deben
eliminarse o si la imputación debe ajustarse a una medida más robusta como la mediana.

Para variables **categóricas**, la imputación más común se realiza mediante la **moda**,
es decir, el valor más frecuente en la columna correspondiente. Estas imputaciones se
aplican por columna, es decir, por cada característica del conjunto de datos.

### Imputación basada en vecinos

Una estrategia más avanzada es el uso de métodos basados en los **vecinos más
cercanos**, como el algoritmo **k-Nearest Neighbors (k-NN)**. Este enfoque consiste en
identificar, para una muestra con valores faltantes, las muestras más similares
(vecinas) utilizando métricas de distancia, como la distancia euclídea. Una vez
determinadas las $k$ muestras más cercanas, el valor faltante se imputa en función de
las características de esas vecinas, por ejemplo, mediante la media, la mediana o la
moda de los valores presentes en ese grupo. Esta técnica permite imputar valores de
forma contextualizada, mejorando la precisión respecto a métodos globales.

### Imputación con modelos predictivos

#### MissForest

**MissForest** emplea algoritmos de aprendizaje automático como **Random Forest** para
imputar valores faltantes. El proceso consiste en realizar una imputación inicial de los
valores faltantes utilizando técnicas simples (media, mediana o moda según el tipo de
variable), entrenar un modelo Random Forest con las características completas para
predecir los valores ausentes de cada característica incompleta, actualizar los valores
imputados con las predicciones obtenidas y repetir iterativamente el proceso hasta que
se alcanza la convergencia o un número máximo de iteraciones.

MissForest es especialmente útil en contextos donde las relaciones entre variables son
complejas y no lineales, ofreciendo un balance entre precisión y robustez. La selección
del método de imputación más adecuado depende de la naturaleza de los datos, del patrón
de ausencia y del nivel de precisión requerido en el análisis posterior.

## Detección de anomalías

Los sistemas de detección de anomalías se basan en la premisa de que el modelo se
entrena exclusivamente con datos no anómalos, de manera que pueda identificar
desviaciones significativas respecto al comportamiento normal aprendido.

### Métodos basados en densidad

Estos métodos consisten en calcular la probabilidad de que un dato pertenezca al
conjunto de datos normal. Se determina el centro del conjunto de datos y se calcula la
probabilidad de cada punto en función de su distancia respecto a dicho centro,
considerando dos o más características. Los puntos con baja probabilidad (alejados del
centro) se consideran anomalías. Para ello, se establece un **umbral de probabilidad**
que separa los datos normales de los anómalos.

### Métodos basados en distribuciones gaussianas

Otra aproximación consiste en modelar la media y la varianza de cada parámetro a partir
de una **distribución gaussiana**. Los datos que se encuentran en las colas de la
distribución (con probabilidad inferior al umbral establecido) se clasifican como
anomalías. Es recomendable incluir datos anómalos en el conjunto de validación para
evaluar correctamente el rendimiento del detector, y la validación cruzada resulta
especialmente útil en este contexto.

### Detección de anomalías frente al aprendizaje supervisado

La detección de anomalías se diferencia del aprendizaje supervisado en varios aspectos
fundamentales. En la detección de anomalías, se desconocen los tipos de anomalías
posibles y no se asume que los datos nuevos sigan la misma distribución que los datos de
entrenamiento. En cambio, un clasificador supervisado dispone de ejemplos tanto
positivos como negativos y espera que las muestras futuras sigan una distribución
similar a la observada durante el entrenamiento.

Puede darse el caso de que las características de los datos no presenten una forma
gaussiana, lo que requiere aplicar **transformaciones** para normalizar su distribución.
Algunas transformaciones habituales incluyen el logaritmo de los datos ($\log(x)$), el
logaritmo más una constante ($\log(x + c)$) o la aplicación de funciones exponenciales
con diferentes parámetros. El objetivo es encontrar la transformación que haga que los
datos se aproximen a una distribución normal.

### Flujos de normalización

Los **flujos de normalización** (_Normalizing Flows_) son modelos generativos
invertibles que transforman una distribución de datos compleja en una distribución
conocida, como la distribución normal, preservando la dimensionalidad de los datos. A
diferencia de otros modelos generativos como los VAE o las GAN, los flujos de
normalización aprenden directamente la función de densidad de probabilidad $p(x)$ de los
datos.

El principio fundamental se basa en una función biyectiva $f$ que mapea los datos $x$ a
un espacio latente $z$:

$$
f: x \rightarrow z,
$$

donde $z$ sigue una distribución conocida (generalmente gaussiana) y $x$ tiene la misma
dimensionalidad que $z$. La función $f$ es invertible, lo que permite tanto la
generación de nuevos datos como la evaluación de la densidad de probabilidad.

La relación entre las distribuciones se establece mediante la **regla del cambio de
variables**. Dada una distribución prior $p(z)$ (gaussiana) y una función invertible
$f$, la densidad de probabilidad de $x$ se determina como:

$$
\log p(x) = \log p(z) + \log \left| \det \frac{\partial f}{\partial x} \right|,
$$

donde el segundo término es el logaritmo del valor absoluto del determinante de la
matriz Jacobiana de la transformación. Para hacer la función más expresiva, se pueden
componer múltiples funciones invertibles aprendibles:

$$
z_0 \xrightarrow{f_1} z_1 \xrightarrow{f_2} \cdots \xrightarrow{f_K} z_K = x.
$$

De esta forma, partiendo de una distribución gaussiana simple, se aplican sucesivas
transformaciones invertibles que permiten modelar distribuciones de datos
arbitrariamente complejas. El entrenamiento se realiza minimizando el negativo del
log-likelihood de los datos observados.

## Sistemas de recomendación

Los **sistemas de recomendación** se utilizan para predecir las preferencias de los
usuarios sobre elementos que aún no han evaluado. Un ejemplo típico es un conjunto de
usuarios con puntuaciones de películas, donde ciertos usuarios no han visto todas las
películas disponibles. El objetivo es estimar la puntuación que un usuario asignaría a
las películas no vistas.

Existen dos enfoques principales. El **filtrado colaborativo** se basa en las
similitudes entre usuarios o entre elementos: si dos usuarios han puntuado de forma
similar un conjunto de películas, es probable que sus preferencias coincidan en
películas no evaluadas. El **filtrado basado en contenido** utiliza las características
de los elementos (género, director, actores) y las preferencias previas del usuario para
recomendar elementos con características similares a los que el usuario ha valorado
positivamente.

## Redes neuronales bayesianas

Las **Redes Neuronales Bayesianas** (_Bayesian Neural Networks_, BNNs) representan un
paradigma que integra la inferencia bayesiana en los modelos de aprendizaje profundo. A
diferencia de las redes neuronales tradicionales, donde los parámetros (pesos y sesgos)
son valores fijos determinados mediante algoritmos de optimización como la
retropropagación y el descenso del gradiente, las BNNs modelan estos parámetros como
**distribuciones de probabilidad**. Este cambio conceptual permite capturar la
incertidumbre inherente tanto en los parámetros del modelo como en sus predicciones,
ofreciendo una comprensión más completa de las limitaciones y la fiabilidad del modelo.

### Fundamentos teóricos de la inferencia bayesiana

La inferencia bayesiana se basa en el **Teorema de Bayes**, que proporciona un marco
matemático para actualizar las creencias sobre un modelo cuando se dispone de nuevas
observaciones. El teorema se expresa matemáticamente como:

$$
P(\theta | D) = \frac{P(D | \theta) P(\theta)}{P(D)},
$$

donde cada componente representa un aspecto específico del proceso de aprendizaje:

- $P(\theta)$ — **Conocimiento previo (distribución prior)**: Representa las creencias
  iniciales sobre los parámetros del modelo antes de observar los datos. Por ejemplo, si
  se desea predecir la altura de una persona, la prior podría establecer que la mayoría
  de las alturas se encuentran entre 1.50 y 2.00 metros, con una media alrededor de 1.70
  metros.
- $P(D | \theta)$ — **Compatibilidad con los datos (verosimilitud)**: Mide la
  probabilidad de los datos observados dado un conjunto específico de parámetros. Evalúa
  qué tan compatibles son las observaciones con las predicciones del modelo.
- $P(D)$ — **Normalización (evidencia)**: Actúa como factor de normalización que
  garantiza que la distribución posterior sume uno, satisfaciendo las propiedades de una
  distribución de probabilidad válida. Representa la probabilidad total de observar los
  datos bajo todos los valores posibles de los parámetros.
- $P(\theta | D)$ — **Conocimiento actualizado (distribución posterior)**: Es el
  resultado final del proceso bayesiano: las creencias actualizadas sobre los parámetros
  después de considerar tanto el conocimiento previo como los datos observados.

### Modelado probabilístico de parámetros

En una BNN, cada peso y sesgo se representa mediante una distribución de probabilidad,
típicamente una distribución normal con media 0 y desviación típica 1, denotada como
$\mathcal{N}(0, 1)$. El proceso de entrenamiento no busca estimar un único valor para
cada parámetro, sino ajustar la distribución posterior que mejor explique los datos
observados.

Este enfoque requiere parametrizar las distribuciones a través de la media y la
desviación típica, actualizándolas iterativamente durante el entrenamiento. El objetivo
es aprender una distribución posterior $P(\theta | D)$ sobre los parámetros $\theta$
dados los datos $D$, donde la distribución prior $P(\theta)$ típicamente asume una forma
gaussiana estándar y la distribución posterior se ajusta durante el entrenamiento para
reflejar el conocimiento adquirido a partir de los datos.

### Métodos de aproximación de la distribución posterior

Dado que el cálculo exacto de la distribución posterior es computacionalmente intratable
en la mayoría de los casos prácticos, se emplean técnicas de inferencia aproximada:

- **Inferencia variacional**: Aproxima la distribución posterior con una distribución
  más simple $q(\theta)$, optimizando la divergencia de Kullback-Leibler (KL) entre
  $q(\theta)$ y $P(\theta | D)$. Este método ofrece eficiencia computacional y
  escalabilidad para modelos grandes, siendo la opción más común en aplicaciones
  prácticas.
- **Markov Chain Monte Carlo (MCMC)**: Métodos basados en muestreo que aproximan la
  posterior generando múltiples muestras. Aunque son computacionalmente más costosos,
  proporcionan aproximaciones más precisas y resultan útiles cuando se prioriza la
  precisión sobre la eficiencia.

### Función de pérdida ELBO

La optimización en las BNNs se basa fundamentalmente en maximizar el **Evidence Lower
Bound (ELBO)**:

$$
\mathcal{L} = \mathbb{E}_{q(\theta)}[\log P(D | \theta)] - KL(q(\theta) \| P(\theta)).
$$

Esta función objetivo equilibra dos componentes críticos. El primer componente,
denominado **término de verosimilitud** $\mathbb{E}_{q(\theta)}[\log P(D | \theta)]$,
maximiza la probabilidad de los datos observados bajo la distribución aproximada
$q(\theta)$, asegurando que el modelo mantenga un buen ajuste a los datos de
entrenamiento. El segundo componente, denominado **término de regularización**
$KL(q(\theta) \| P(\theta))$, minimiza la divergencia KL entre la distribución posterior
aproximada y la distribución prior, actuando como fuerza regularizadora que previene el
sobreajuste.

La divergencia KL se formula de manera diferente según el tipo de distribución. Para
distribuciones discretas:

$$
KL(P \| Q) = \sum_{x} P(x) \log \frac{P(x)}{Q(x)}.
$$

Para distribuciones continuas:

$$
KL(P \| Q) = \int_{-\infty}^{\infty} p(x) \log \frac{p(x)}{q(x)} \, dx.
$$

### Inferencia y cuantificación de la incertidumbre

Durante la fase de inferencia, una BNN genera predicciones muestreando repetidamente de
la distribución de pesos. Este proceso típicamente implica múltiples inferencias
independientes (comúnmente entre 50 y 1000 repeticiones) para la misma entrada,
produciendo un conjunto de predicciones que permite calcular la **media** de las
predicciones como estimación final y determinar la **varianza** o desviación típica como
medida cuantitativa de la incertidumbre asociada.

Esta capacidad de cuantificar la incertidumbre es la principal ventaja de las BNNs,
proporcionando información sobre la fiabilidad de cada predicción individual.

### Tipos de incertidumbre

En el contexto de las BNNs, se distinguen dos tipos fundamentales de incertidumbre:

- **Incertidumbre epistémica**: Se refiere a lo que el modelo no sabe y está
  directamente relacionada con los parámetros del modelo ($y = f(x)$). Es **reducible**
  con más datos o mayor complejidad del modelo.
- **Incertidumbre aleatoria**: Se refiere a la variabilidad inherente en el entorno y
  está relacionada con los datos de entrada. Es **irreducible**, ya que proviene del
  ruido intrínseco del proceso generador de datos.

### Aplicaciones

Las BNNs son particularmente valiosas en contextos donde la cuantificación de la
incertidumbre es crítica: bioquímica y descubrimiento de fármacos, diagnóstico médico,
finanzas, robótica y aprendizaje por refuerzo, y telecomunicaciones. Sus ventajas sobre
los modelos deterministas incluyen la cuantificación formal de la incertidumbre, una
regularización efectiva mediante las distribuciones prior, un mejor rendimiento con
datos limitados y una mayor interpretabilidad de las predicciones.

Las BNNs se integran de forma natural con la **programación probabilística**, un
paradigma que permite describir modelos estadísticos complejos mediante código
declarativo, ampliando significativamente su aplicabilidad en sistemas donde el modelado
explícito de la incertidumbre es esencial.

## Modelos de mezcla de densidades

Los **Modelos de Mezcla de Densidades** (_Mixture Density Networks_, MDN) combinan redes
neuronales con modelos de mezcla para obtener a la salida del modelo la distribución de
probabilidad completa $P(y|x)$, en lugar de un único valor puntual. La salida del modelo
describe la distribución que modela los datos objetivo dados los datos de entrada.

Un MDN modela la distribución condicional como una **mezcla de distribuciones
gaussianas**, donde cada componente de la mezcla se caracteriza por tres parámetros:

- $\mu_i$: La media (centro de la distribución).
- $\sigma_i^2$: La varianza (ancho de la distribución).
- $w_i$: El peso (importancia relativa de cada componente), donde $\sum w_i = 1$.

La red neuronal recibe la entrada $x$ y produce como salida los parámetros de todas las
componentes de la mezcla. La función de pérdida se basa en el negativo del
log-likelihood:

$$
-\log p(y|x) = -\log \left( \sum_{j=1}^{m} w_j \cdot \mathcal{N}(y | \mu_j, \sigma_j^2) \right).
$$

Para la implementación práctica, se utilizan las distribuciones de probabilidad de las
bibliotecas de aprendizaje profundo (como `torch.distributions.Normal`) y la función
`logsumexp` para garantizar la estabilidad numérica en el cálculo del log-likelihood.

### Consideraciones de implementación

Para la **varianza**, se recomienda utilizar la función de activación **ELU
modificada**: $\text{ELU}(z) + 1 + \epsilon$ (donde $\epsilon = 10^{-15}$). La función
ELU se desplaza a la zona de los positivos sumando 1, y se añade un valor pequeño
$\epsilon$ para garantizar la estabilidad numérica. Esta elección evita que la varianza
crezca excesivamente y proporciona un comportamiento suave que se aproxima a lineal para
valores altos.

Para los **pesos** de la mezcla, se puede sustituir la función **Softmax** estándar por
**Gumbel-Softmax**, que genera distribuciones más agresivas y puede asignar probabilidad
cercana a cero a componentes sin importancia, mientras que Softmax produce
distribuciones más suaves. Otras técnicas para evitar el colapso de componentes (donde
el modelo ignora alguna distribución) incluyen la regularización de pesos y la
inicialización del centro de cada gaussiana a partir de un precálculo sobre los datos.

### Intervalos de confianza

A partir de las distribuciones obtenidas por el MDN, es posible calcular **intervalos de
confianza** (_confidence intervals_), que representan un rango de valores que, con
cierta probabilidad (nivel de confianza), contiene el verdadero valor de un parámetro
desconocido. Por ejemplo, un intervalo de confianza del 95% indica que, al repetir un
experimento varias veces, aproximadamente el 95% de los intervalos calculados contendrán
el valor verdadero. Además, se pueden obtener la media, la varianza, los percentiles y
realizar comparaciones visuales y cuantitativas con las distribuciones observadas en los
datos de entrenamiento.

### Estabilidad numérica

Durante el entrenamiento de MDNs, pueden aparecer valores `NaN` debido a varias causas:
el logaritmo de un valor cercano a cero, divisiones con denominador muy pequeño o la
exponencial de un valor muy grande. Para mitigar estos problemas, se pueden emplear
técnicas como el **gradient clipping** (limitación del gradiente), la **regularización
de pesos** y la **normalización por lotes** (_Batch Normalization_) en la capa de
salida.
