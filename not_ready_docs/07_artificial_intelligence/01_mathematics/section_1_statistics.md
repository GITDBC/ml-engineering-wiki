---
authors: Daniel Bazo Correa
description: Selección de datos, validación cruzada y fundamentos de estadística.
title: Estadística
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Este capítulo cubre los fundamentos estadísticos necesarios para el aprendizaje
automático, incluyendo distribuciones de probabilidad, validación cruzada y métricas de
error.

## Selección y validación de datos

Los datos son un elemento esencial en los algoritmos de aprendizaje automático. Sin una
selección adecuada, es posible obtener relaciones no significativas o incluso
perjudiciales.

No todos los datos o métricas son útiles, por lo que es fundamental ajustarse al
problema, asegurar la coherencia dentro de la misma distribución y minimizar la
presencia de valores atípicos. Una correcta selección de los datos permite desarrollar
modelos más robustos. Para ello, se emplea la **validación cruzada**.

### Validación cruzada

<figure markdown="span">
  ![Funcionamiento de la validación cruzada](https://www.sharpsightlabs.com/wp-content/uploads/2024/02/cross-validation-explained_FEATURED-IMAGE.png)
  <figcaption>Esquema de funcionamiento de la validación cruzada. <a href="https://www.sharpsightlabs.com/wp-content/uploads/2024/02/cross-validation-explained_FEATURED-IMAGE.png">Referencia</a></figcaption>
</figure>

La selección de muestras para el entrenamiento y validación de un modelo puede resultar
compleja, ya que una elección inadecuada puede generar sesgos en el modelo. Por ejemplo,
en conjuntos de datos con dependencia temporal, como el tráfico de una red a lo largo
del día, la distribución de las muestras puede influir en el desempeño del modelo. Si
los datos se registran en orden cronológico y las primeras muestras corresponden a la
mañana mientras que las últimas a la noche, seleccionar las primeras muestras para
entrenamiento y las últimas para prueba podría generar un modelo que no capture
correctamente patrones generales.

Para evitar este problema, se recomienda introducir aleatoriedad en la selección de las
muestras y definir un porcentaje para cada partición del conjunto de datos.

!!! note "Reproducibilidad con semillas aleatorias"

    Es fundamental establecer una **semilla aleatoria** antes de cualquier proceso que requiera aleatorización, garantizando así la reproducibilidad de los resultados.

Por ejemplo, el siguiente código establece semillas para las bibliotecas más utilizadas
en Python para aprendizaje automático y profundo, garantizando la reproducibilidad de
los experimentos:

```py linenums="1"
import random
import numpy as np
import tensorflow as tf
import torch
import sklearn.utils

# Valor de la semilla
SEED = 42

# Establecer semilla en Python (random)
random.seed(SEED)

# Establecer semilla en NumPy
np.random.seed(SEED)

# Establecer semilla en TensorFlow
tf.random.set_seed(SEED)

# Establecer semilla en PyTorch
torch.manual_seed(SEED)
torch.cuda.manual_seed(SEED)  # Para GPUs
torch.cuda.manual_seed_all(SEED)  # Para múltiples GPUs
torch.backends.cudnn.deterministic = True  # Para reproducibilidad en CUDA
torch.backends.cudnn.benchmark = False

# Establecer semilla en Scikit-learn
sklearn.utils.check_random_state(SEED)
```

La **validación cruzada** es una técnica fundamental en aprendizaje automático para
evaluar y comparar diferentes modelos. Su objetivo es estimar el rendimiento de un
modelo en datos no vistos y seleccionar el algoritmo más adecuado. El proceso consiste
en dividir el conjunto de datos en múltiples subconjuntos denominados **_folds_**,
generalmente de tamaño similar, y entrenar el modelo de manera iterativa. El caso más
común es el **k-Fold Cross Validation**, donde $k$ suele ser cinco o diez, dependiendo
del tamaño del conjunto de datos y de la complejidad del modelo. El procedimiento se
desarrolla de la siguiente manera:

1. Se separa el conjunto de datos en $k$ folds.
2. En cada iteración, se utiliza un fold como conjunto de prueba y los restantes como
   conjunto de entrenamiento.
3. El modelo se entrena con los folds de entrenamiento y se evalúa con el fold de
   prueba.
4. Este procedimiento se repite hasta que todos los folds hayan sido utilizados como
   conjunto de prueba una vez.
5. Finalmente, se promedian las métricas de evaluación obtenidas en cada iteración, como
   precisión, error o sensibilidad.

Una ventaja de la validación cruzada es la reducción del problema conocido como **_data
leakage_**, que ocurre cuando características utilizadas en el entrenamiento también
están presentes en la fase de prueba, generando una evaluación artificialmente optimista
del modelo.

### Distribuciones

Antes de realizar predicciones, es fundamental recopilar datos. En muchas ocasiones,
esta recopilación genera histogramas, que permiten visualizar la distribución de los
datos. Un histograma se compone de dos ejes principales: el eje $x$, donde se
representan los datos agrupados en categorías, y el eje $y$, que indica la frecuencia de
cada categoría, es decir, el número de muestras que pertenecen a cada grupo. Las
divisiones en el eje $x$ para agrupar los datos en rangos similares se conocen como
**_bins_** o contenedores.

El uso de histogramas facilita la identificación de tendencias en los datos. En casos
donde los valores pueden solaparse, los _bins_ ayudan a agrupar puntos de datos dentro
de un intervalo definido. De este modo, se generan distribuciones que permiten analizar
el comportamiento de los datos.

!!! note "Elección del número de bins"

    La elección del número de _bins_ es crucial, ya que debe reflejar correctamente la distribución de los datos. Este tipo de histogramas resulta especialmente útil en algoritmos como **Naïve Bayes**, donde se generan distribuciones de probabilidad en cada iteración, permitiendo obtener valores como medias e intervalos de confianza.

El conjunto completo de datos recopilados se denomina **población** y se representa con
la letra $N$. Un subconjunto de la población se denomina **muestra** y se representa con
la letra $n$.

La probabilidad de que un dato pertenezca a una determinada parte del histograma se
calcula dividiendo el número de muestras en esa sección entre el número total de
muestras en la población.

!!! note "Confianza y tamaño de muestra"

    La confianza en los resultados depende del tamaño de la muestra: cuanto mayor sea el número de muestras, mayor será la confianza en la estimación. La confianza representa el grado de incertidumbre asociado a una probabilidad.

### Características de la probabilidad

La probabilidad está normalizada en un rango de 0 a 1, donde 0 indica imposibilidad y 1
certeza absoluta. Cuando todos los resultados posibles tienen la misma probabilidad, se
habla de **equiprobabilidad**. Además, la suma de todas las probabilidades en un sistema
debe ser 1.

Conviene precisar el vocabulario formal que sustenta estas afirmaciones. El **espacio
muestral**, denotado $\Omega$, es el conjunto de resultados posibles de un experimento.
Al lanzar dos monedas, el espacio muestral es $\{CC, XX, CX, XC\}$, donde $C$ representa
cara y $X$ cruz. Un **suceso** es cualquier subconjunto del espacio muestral, es decir,
un resultado potencial del experimento. La **probabilidad** $P$ asocia a cada suceso $A$
un número $P(A)$ que mide el grado de creencia de que ocurra.

Una **variable aleatoria** $X$ sobre $\Omega$ es una aplicación de $\Omega$ en
$\mathbb{R}$ que toma elementos del espacio muestral y devuelve una cantidad de interés.
Al lanzar dos monedas y contar el número de caras, la variable aleatoria $X$ asigna
$X(CC)=2$, $X(CX)=1$, $X(XC)=1$ y $X(XX)=0$, de modo que los valores posibles son
$\{0,1,2\}$. El **soporte** de una variable aleatoria es el conjunto de valores reales
que puede tomar, y es lo que determina su naturaleza discreta o continua.

Cuando el número de datos disponibles es insuficiente, las estimaciones de probabilidad
pueden no ser precisas. No obstante, recopilar más datos puede resultar costoso en
términos de tiempo, esfuerzo y dinero. Para mitigar esta limitación, se emplean
**distribuciones de probabilidad**, que pueden ser **discretas** (cuando los datos toman
valores específicos y finitos) o **continuas** (cuando los datos pueden tomar cualquier
valor dentro de un rango determinado).

Las variables aleatorias discretas son aquellas cuyo soporte es un conjunto finito o
infinito numerable. En aprendizaje automático modelan variables categóricas, es decir,
variables que toman un conjunto finito de valores no ordenados, como las letras del
alfabeto en el reconocimiento de escritura. Su función de probabilidad se escribe como:

$$
p(x_i) = P(\omega \in \Omega \mid X(\omega) = x_i) = P(X = x_i)
$$

Cuando el espacio es discreto y se consideran varias variables a la vez, la probabilidad
conjunta se obtiene como la frecuencia relativa de cada combinación de estados:

$$
P(X=x_i, Y=y_j) = \frac{n_{ij}}{N}
$$

donde $n_{ij}$ es el número de eventos con estado $x_i$ e $y_j$, y $N$ el número total
de eventos.

Las variables aleatorias continuas son aquellas cuyo soporte es un intervalo real,
finito o infinito, o una unión de intervalos, como ocurre con la temperatura, el peso o
la duración de un componente. En este caso la probabilidad se asigna a intervalos y no a
valores individuales:

$$
P(a < \xi \le b) = P(\omega \in \Omega \mid a < \xi(\omega) \le b)
$$

La distinción entre ambos casos es la que separa, en la práctica, una capa de salida con
_softmax_ sobre un conjunto finito de clases de un modelo que predice una magnitud
continua.

A continuación, se presentan algunas de las distribuciones más comunes.

#### Distribución binomial (discreta)

Cuando se trabaja con datos discretos y se requiere calcular probabilidades en eventos
independientes con solo dos posibles resultados, **éxito** o **fracaso** (representados
por 1 y 0, respectivamente), se trata de un **problema binario**.

Para modelar este tipo de situaciones, se utiliza la **distribución binomial**, que
permite calcular la probabilidad de obtener una determinada cantidad de éxitos en una
secuencia de ensayos independientes. La distribución binomial se expresa mediante la
siguiente fórmula:

$$
P(X = k | n, p) = \binom{n}{k} \cdot p^k \cdot (1 - p)^{n - k},
$$

donde:

- $X$ representa el número de éxitos en los ensayos.
- $n$ es el número total de ensayos.
- $p$ es la probabilidad de éxito en un único ensayo.
- $k$ es el número de éxitos deseados.
- $\binom{n}{k}$ es el coeficiente binomial, que calcula de cuántas formas se pueden
  obtener $k$ éxitos en $n$ ensayos, sin importar el orden. Se calcula mediante la
  siguiente fórmula:

$$
\binom{n}{k} = \frac{n!}{k! \cdot (n-k)!}.
$$

Esta distribución es útil en situaciones donde se realizan múltiples intentos
independientes de un mismo experimento y se desea conocer la probabilidad de obtener un
número específico de éxitos.

???+ example "Distribución binomial"

    Supongamos que se lanza una moneda equilibrada (equiprobable, la probabilidad de obtener cara es la misma que la de obtener cruz) 5 veces y se quiere calcular la probabilidad de obtener exactamente 3 caras.

    Se definen los parámetros:

    - $n = 5$ (número total de lanzamientos).
    - $p = 0.5$ (probabilidad de obtener cara en un solo lanzamiento).
    - $k = 3$ (número de caras que se desean obtener).

    Aplicando la fórmula de la distribución binomial:

    $$
    P(X = 3 | n=5, p=0.5) = \binom{5}{3} \cdot (0.5)^3 \cdot (1 - 0.5)^{5 - 3}
    $$

    Calculamos el coeficiente binomial:

    $$
    \binom{5}{3} = \frac{5!}{3! \cdot (5-3)!} = \frac{5!}{3! \cdot 2!} = 10
    $$

    Sustituyendo en la ecuación:

    $$
    P(X = 3) = 10 \cdot (0.5)^3 \cdot (0.5)^2 = 0.3125
    $$

    Por lo tanto, la probabilidad de obtener exactamente 3 caras en 5 lanzamientos de una moneda equilibrada es del 31.25%.

#### Distribución de Poisson (discreta)

La **distribución de Poisson** se utiliza para modelar la probabilidad de que ocurra un
número determinado de eventos en un intervalo de tiempo o espacio, siempre que los
eventos ocurran de manera independiente y a una tasa promedio constante. Algunos
ejemplos de aplicación incluyen: el número de llamadas recibidas en una central
telefónica durante una hora, el número de accidentes en una intersección en un día, o la
cantidad de errores tipográficos en una página de texto.

La distribución de Poisson se expresa mediante la siguiente fórmula:

$$
P(X = k) = \frac{\lambda^k e^{-\lambda}}{k!},
$$

donde:

- $X$ es el número de eventos que ocurren en un intervalo específico.
- $\lambda$ es el número promedio de eventos en dicho intervalo.
- $k$ es el número de eventos cuya probabilidad se desea calcular.
- $e$ es la base del logaritmo natural.

Esta distribución es especialmente útil cuando se estudian eventos raros o poco
frecuentes en un período de tiempo determinado.

???+ example "Distribución de Poisson"

    Supongamos que una central telefónica recibe en promedio 10 llamadas por hora y se desea calcular la probabilidad de que en una hora lleguen exactamente 7 llamadas.

    Se definen los parámetros:

    - $\lambda = 10$ (promedio de llamadas por hora).
    - $k = 7$ (número específico de llamadas que se desea calcular).

    Aplicamos la fórmula de la distribución de Poisson:

    $$
    P(X = 7) = \frac{10^7 e^{-10}}{7!} \approx 0.0902
    $$

    Por lo tanto, la probabilidad de recibir exactamente 7 llamadas en una hora es del 9.02%.

#### Distribución normal o gaussiana (continua)

La distribución normal, también denominada distribución gaussiana, se representa
mediante una curva en forma de campana. En esta distribución, el eje $y$ indica la
**verosimilitud** (**_likelihood_**) de observar un determinado valor en el eje $x$.

!!! note "Verosimilitud vs. Probabilidad"

    Aunque son conceptos relacionados, la verosimilitud y la probabilidad tienen diferencias clave:

    - **Probabilidad**: Representa la posibilidad de que ocurra un evento dado un modelo y sus parámetros. Se expresa como $P(D|\theta)$, donde $D$ son los datos y $\theta$ los parámetros del modelo. Responde a la pregunta: _Dado que los parámetros del modelo son conocidos, ¿qué tan probable es observar ciertos datos?_
    - **Verosimilitud**: Mide qué tan bien un conjunto de parámetros explica un conjunto de datos observados. Se denota como $L(\theta | D)$ y representa la plausibilidad de los parámetros $\theta$ dados los datos $D$. Responde a la pregunta: _Dado que los datos han sido observados, ¿qué tan plausible es que provengan de un modelo con ciertos parámetros?_

    Mientras que la probabilidad se emplea para predecir eventos futuros basándose en un modelo conocido, la verosimilitud se usa para evaluar qué tan bien un modelo con ciertos parámetros explica los datos observados. Para obtener probabilidades a partir de la verosimilitud, se puede utilizar el Teorema de Bayes.

La distribución normal es **simétrica** respecto a su **media** ($\mu$), lo que implica
que el valor más verosímil es precisamente la media. La forma de la curva normal está
determinada por dos parámetros: la media ($\mu$) y la desviación típica ($\sigma$). Una
curva alta y estrecha indica que los datos están más concentrados alrededor de la media,
lo que corresponde a una baja varianza. Una curva baja y ancha sugiere una mayor
dispersión de los datos, es decir, mayor varianza.

La **desviación típica** ($\sigma$) mide la dispersión de los datos respecto a la media,
mientras que la **varianza** ($\sigma^2$) es el cuadrado de la desviación típica. La
varianza se puede calcular de las siguientes dos maneras:

- **Varianza muestral**:

$$
s^2 = \frac{\sum_{i=1}^{n} (x_i - \bar{x})^2}{n-1}.
$$

- **Varianza poblacional**:

$$
\sigma^2 = \frac{\sum_{i=1}^{N} (x_i - \mu)^2}{N}.
$$

Donde $x_i$ son los valores de la muestra o población, $\bar{x}$ es la media muestral,
$\mu$ es la media poblacional, $n$ es el tamaño de la muestra y $N$ es el tamaño de la
población.

La distribución normal es fundamental en estadística y aprendizaje automático debido a
su presencia en numerosos fenómenos naturales y conjuntos de datos del mundo real.

##### Función de densidad de probabilidad

La **función de densidad de probabilidad** (_Probability Density Function_, PDF) de la
distribución normal se define como:

$$
f(X|\mu, \sigma) = \frac{1}{\sqrt{2\pi\sigma^2}} e^{-\frac{(x_i - \mu)^2}{2\sigma^2}}.
$$

En las distribuciones continuas, el cálculo de probabilidades requiere la integración de
la función de densidad de probabilidad (PDF). Esta integración permite obtener el área
bajo la curva entre dos puntos, lo que representa la probabilidad acumulada en dicho
intervalo. Dado que el área total bajo la curva es igual a 1, el área acumulada hasta la
media en una distribución normal es de 0.5.

Es importante destacar que la probabilidad exacta en un único punto es igual a 0. Esto
se debe a que, gráficamente, un punto no tiene ancho y, por lo tanto, no contribuye con
área bajo la curva. En consecuencia, solo es posible calcular probabilidades en
intervalos.

La **función de distribución acumulada** (_Cumulative Distribution Function_, CDF)
expresa la probabilidad acumulada hasta un determinado valor. Matemáticamente,
representa el área bajo la curva de la función de densidad desde $-\infty$ hasta dicho
punto.

##### Propiedades de la función de distribución acumulada

Sea $F$ la función de distribución acumulada (CDF) y $\mathbb{R}$ el conjunto de números
reales, entonces se cumple que $F: \mathbb{R} \to [0,1]$, lo que significa que el rango
de valores de la función de distribución está comprendido entre 0 y 1.

!!! note "Notación de la CDF"

    Se usa mayúscula para $F(x)$ porque se refiere a la función matemática que mapea los valores de la variable aleatoria $X$ a la probabilidad acumulada, distinguiéndola de la función de densidad de probabilidad que se representa en minúscula, como $f(x)$.

Algunas de sus propiedades fundamentales son:

- $F(x) = P(A_x) = P(X \leq x)$, donde $A_x$ representa el evento $X \leq x$.
- $P(X \leq x) = F(x)$, lo que corresponde a la función de distribución acumulada (CDF).
- $P(X > x) = 1 - P(X \leq x) = 1 - F(x)$, es decir, la probabilidad complementaria a
  $P(X \leq x)$.
- $P(a < X \leq b) = F(b) - F(a)$, para calcular la probabilidad de que $X$ esté entre
  dos valores $a$ y $b$.
- $P(X \geq a) = P(X > a) + P(X = a)$, una forma de descomponer la probabilidad de que
  $X$ sea mayor o igual que $a$.
- $P(X = a) = F(a) - \lim_{h \to 0^+} F(a - h) = F(a) - P(X \leq a)$, que calcula la
  probabilidad de que $X$ tome el valor $a$.

Estas propiedades permiten calcular probabilidades acumuladas y facilitan el análisis de
distribuciones de probabilidad continuas.

???+ example "Distribución normal"

    Se desea calcular la probabilidad de que un valor se encuentre en el intervalo $[142.5, 155.7]$ en una distribución normal $N(\mu=155.7, \sigma=6.6)$.

    La probabilidad se obtiene a partir de la función de distribución acumulada (CDF):

    $$P(a < X \leq b) = P(142.5 < X \leq 155.7) = F(155.7) - F(142.5)$$

    $$P(X \leq 155.7) - P(X \leq 142.5) \approx 0.5 - 0.02275 \approx 0.4772$$

    Implementación en Python:

    ```py linenums="1"
    from statistics import NormalDist

    # Se calcula la función de distribución acumulada (CDF) en los puntos de interés
    cdf_p1 = NormalDist(155.7, 6.6).cdf(155.7)
    # cdf_p1 = 0.5, debido a la simetría de la distribución normal

    cdf_p2 = NormalDist(155.7, 6.6).cdf(142.5)
    # cdf_p2 ≈ 0.02275

    # Se obtiene la probabilidad del intervalo restando las probabilidades acumuladas
    diff = cdf_p1 - cdf_p2
    # diff ≈ 0.4772 = 47.72%
    ```

    Por lo tanto, la probabilidad de que un valor de esta distribución normal se encuentre en el intervalo $[142.5, 155.7]$ es aproximadamente del 47.72%.

#### Asimetría (_skewness_) y curtosis (_kurtosis_)

Además de la media y la varianza, existen dos medidas que caracterizan la forma de una
distribución: la **asimetría** (_skewness_) y la **curtosis** (_kurtosis_).

La **asimetría** indica hacia qué lado se inclina la distribución respecto a la media:

| Valor del _skew_ | Interpretación                                                           |
| :--------------- | :----------------------------------------------------------------------- |
| Negativo (< 0)   | Cola extendida hacia la izquierda. Se cumple que media < mediana < moda. |
| Cero             | Distribución simétrica. Media, mediana y moda coinciden.                 |
| Positivo (> 0)   | Cola extendida hacia la derecha. Se cumple que moda < mediana < media.   |

La **curtosis** mide cómo de concentrados están los datos alrededor de la media, es
decir, la altura y la estrechez de la distribución, así como el peso de las colas:

| Tipo         | Valor    | Descripción                                                                   |
| :----------- | :------- | :---------------------------------------------------------------------------- |
| Leptocúrtica | Positiva | Distribución alta y estrecha, con colas pesadas (más valores extremos).       |
| Mesocúrtica  | Cero     | Distribución normal estándar.                                                 |
| Platicúrtica | Negativa | Distribución plana y ancha, con mayor dispersión pero menos valores extremos. |

#### Distribución exponencial (continua)

La distribución exponencial se emplea para modelar el tiempo transcurrido entre eventos
en un proceso de Poisson, donde los eventos ocurren de manera independiente y con una
tasa constante. Se utiliza en el análisis de tiempos de espera, confiabilidad de
sistemas y modelado de fallos en ingeniería.

La función de densidad de probabilidad (PDF) está definida como:

$$
f(x; \lambda) = \lambda e^{-\lambda x}, \quad x \geq 0, \, \lambda > 0,
$$

donde $\lambda$ indica la frecuencia con la que ocurren los eventos.

La función de distribución acumulada (CDF) se expresa como:

$$
F(x) = 1 - e^{-\lambda x}, \quad x \geq 0.
$$

La media de la distribución exponencial equivale a la **esperanza matemática** $E[X]$.

!!! note "Esperanza matemática"

    La **esperanza matemática**, denotada como $E[X]$, es lo que comúnmente se denomina la **media** o el **valor esperado** de una variable aleatoria. Sin embargo, la interpretación de la esperanza matemática puede variar dependiendo del tipo de variable aleatoria y el contexto en el que se utilice.

    Para una variable aleatoria discreta $X$, cuya función de masa de probabilidad es $P(X = x_i)$, la esperanza matemática se calcula mediante la siguiente fórmula:

    $$
    E[X] = \sum_{i} x_i \cdot P(X = x_i)
    $$

    En este caso, el valor esperado se obtiene sumando el producto de cada valor posible de $X$ y su probabilidad correspondiente.

    Para una variable aleatoria continua $X$, cuya función de densidad de probabilidad es $f(x)$, la esperanza matemática se calcula utilizando la integral:

    $$
    E[X] = \int_{-\infty}^{\infty} x \cdot f(x) \,dx
    $$

    Aquí, el valor esperado se obtiene integrando el producto de cada valor de $X$ y su densidad de probabilidad asociada.

    En teoría de probabilidad, la esperanza matemática se considera la media "teórica" de la distribución. **En distribuciones simétricas con un único pico, como la distribución normal, la esperanza matemática coincide con el centro de la distribución. Sin embargo, en distribuciones asimétricas, la esperanza matemática puede no coincidir con la mediana o la moda**. Por ejemplo, en una distribución sesgada a la derecha, como la distribución exponencial, la esperanza matemática es mayor que la mediana, lo que indica que los valores más altos de la variable aleatoria tienen una probabilidad significativa de ocurrir.

En la distribución exponencial, la media se obtiene como:

$$
\mu = E[X] = \frac{1}{\lambda}.
$$

La varianza se expresa como:

$$
\sigma^2 = \frac{1}{\lambda^2}.
$$

#### Distribución uniforme (continua)

La distribución uniforme se caracteriza porque todos los valores dentro de un intervalo
$[a, b]$ tienen la misma probabilidad de ocurrir. Se emplea en la generación de números
aleatorios, simulaciones y situaciones en las que no hay preferencia por ningún valor
específico dentro de un rango determinado.

La función de densidad de probabilidad (PDF) para una distribución uniforme continua es:

$$
f(x) = \begin{cases} \frac{1}{b-a}, & a \leq x \leq b \\ 0, & \text{en otro caso} \end{cases}
$$

La función de distribución acumulada (CDF) está dada por:

$$
F(x) = \begin{cases} 0, & x < a \\ \frac{x-a}{b-a}, & a \leq x \leq b \\ 1, & x > b \end{cases}
$$

La media de la distribución uniforme es:

$$
\mu = E[X] = \frac{a + b}{2}.
$$

Y su varianza se expresa como:

$$
\sigma^2 = \frac{(b-a)^2}{12}.
$$

!!! tip "¿De dónde sale el 12 de la varianza de la distribución uniforme?"

    La varianza de una variable aleatoria continua $X$ se define como:

    $$
    \text{Var}(X) = E[X^2] - (E[X])^2.
    $$

    Para una distribución uniforme continua $U(a, b)$, la esperanza, la cual coincide con la media, se obtiene con la fórmula:

    $$
    E[X] = \frac{a+b}{2}.
    $$

    Por tanto, el cálculo de $E[X^2]$ se realiza como:

    $$
    E[X^2] = \int_a^b x^2 \cdot f(x) \, dx = \int_a^b x^2 \cdot \frac{1}{b-a} \, dx.
    $$

    Resolviendo la integral:

    $$
    E[X^2] = \frac{1}{b-a} \int_a^b x^2 \, dx = \frac{1}{b-a} \cdot \left[ \frac{x^3}{3} \right]_{a}^{b}.
    $$

    Evaluando de $a$ a $b$:

    $$
    E[X^2] = \frac{1}{b-a} \left[ \frac{b^3}{3} - \frac{a^3}{3} \right] = \frac{b^3 - a^3}{3(b-a)}.
    $$

    Ahora, usando la fórmula de la varianza y sustituyendo los valores obtenemos:

    $$
    \text{Var}(X) = E[X^2] - (E[X])^2 = \frac{b^3 - a^3}{3(b-a)} - \left(\frac{a+b}{2} \right)^2.
    $$

    Aplicando las identidades algebraicas siguientes:

    $$
    (a+b)^{2}=a^2+b^2+2ab,
    $$

    $$
    b^3 - a^3 = (b-a)(b^2 + ab + a^2),
    $$

    Finalmente, después de desarrollar la expresión y simplificar, se obtiene:

    $$
    \text{Var}(X) = \frac{(b-a)^2}{12}.
    $$

### Caso multivariante y reglas de la probabilidad

Las definiciones anteriores se han presentado sobre una única variable aleatoria. Su
generalización al caso de varias variables es la que sustenta los modelos
probabilísticos, donde interesa razonar sobre la relación conjunta entre parámetros y
datos.

Una función $f: \mathbb{R}^D \to \mathbb{R}$ es una función de densidad de probabilidad
si es no negativa para todo $\mathbf{x} \in \mathbb{R}^D$ y su integral sobre el dominio
completo vale 1:

$$
\int_{\mathbb{R}^D} f(\mathbf{x})\,d\mathbf{x} = 1
$$

Para las **funciones de masa de probabilidad** (_probability mass function_, PMF), que
corresponden a las variables aleatorias discretas, esa integral se sustituye por una
suma. La función de distribución acumulada se extiende de forma análoga a varias
dimensiones:

$$
F(\mathbf{x}) = P(X_1 \le x_1, \ldots, X_D \le x_D)
$$

donde $\mathbf{X}=\lbrack X_1,\ldots,X_D \rbrack$ y $\mathbf{x}=\lbrack x_1,\ldots,x_D
\rbrack$, lo que representa la probabilidad de que cada variable aleatoria $X_i$ tome un
valor menor o igual que $x_i$.

!!! note "Densidad frente a probabilidad"

    En el caso discreto la probabilidad de cada estado debe estar en el intervalo
    $\lbrack 0,1 \rbrack$. Para las variables continuas, en cambio, la normalización no
    implica que el valor de la densidad sea menor o igual que 1 para todos los valores,
    ya que lo acotado es la integral y no la función.

Una vez definidas las distribuciones que describen la incertidumbre de los datos, solo
dos reglas rigen su manipulación. Antes de enunciarlas conviene fijar la notación:
$p(x,y)$ es la distribución conjunta de las variables aleatorias $x$ e $y$, tanto $p(x)$
como $p(y)$ son las distribuciones marginales respectivas, y $p(y|x)$ es la distribución
condicional de $y$ dado $x$.

La **regla de la suma** relaciona la distribución conjunta con una distribución
marginal, por lo que también se conoce como propiedad de marginación:

$$
p(x) =
\begin{cases}
\displaystyle\sum_{y \in \mathcal{Y}} p(x,y) & \text{si } y \text{ es discreta} \\[2mm]
\displaystyle\int_{\mathcal{Y}} p(x,y)\,dy & \text{si } y \text{ es continua}
\end{cases}
$$

donde $\mathcal{Y}$ son los estados del espacio muestral de la variable aleatoria $y$.
Cuando la distribución conjunta contiene más de dos variables aleatorias, la regla puede
aplicarse a cualquier subconjunto de ellas, lo que da lugar a la distribución marginal
del resto.

!!! note

    Realizar sumas o integrales de alta dimensión resulta generalmente difícil desde el
    punto de vista computacional, en el sentido de que no se conoce ningún algoritmo de
    tiempo polinómico para calcularlas de forma exacta. Esta limitación es la que motiva
    los métodos de aproximación empleados en inferencia bayesiana.

La **regla del producto** descompone la distribución conjunta en el producto de una
condicional por una marginal:

$$
p(x,y) = p(y|x)\,p(x)
$$

Estas dos reglas son todo lo necesario para derivar el **teorema de Bayes**, fundamento
de los modelos probabilísticos, que permite invertir la relación entre parámetros y
datos para pasar de la verosimilitud a la distribución posterior sobre los parámetros.
Su aplicación concreta se desarrolla en el clasificador Naïve Bayes del capítulo de
[modelos supervisados](../02_machine_learning/section_2_supervised_models.md) y en las
redes neuronales bayesianas del capítulo de
[técnicas avanzadas](../02_machine_learning/section_6_advanced.md).

### P-valores

Los **p-valores** (_p-values_) son números comprendidos entre 0 y 1 que cuantifican la
confianza con la que se puede afirmar que una opción A es diferente de una opción B. Un
p-valor cercano a 0 indica que existe evidencia estadística suficiente para considerar
que A es distinto de B.

En la práctica, se suele utilizar un **umbral de significancia** de 0.05 para determinar
si la diferencia es estadísticamente significativa. Sin embargo, puede darse el caso de
obtener un p-valor pequeño cuando en realidad no existe diferencia, lo que se conoce
como un **falso positivo**. Un umbral de 0.05 implica que aproximadamente el 5% de los
experimentos generará un p-valor menor a 0.05 por azar. Si se requiere mayor seguridad,
se pueden emplear umbrales más bajos; por ejemplo, en medicina se utilizan umbrales como
0.0001, lo que equivale a un falso positivo cada 100.000 experimentos.

El umbral de significancia ($\alpha$) representa la probabilidad máxima aceptada de
cometer un falso positivo, y su inversa indica la frecuencia esperada de falsos
positivos. La idea de determinar si una opción A es igual o diferente a una opción B se
denomina **prueba de hipótesis**. La hipótesis de que A es igual a B se conoce como
**hipótesis nula** ($H_0$). Por tanto, el p-valor mide la probabilidad de que el
resultado observado ocurra asumiendo que la hipótesis nula es verdadera, es decir, que
no existen diferencias reales. Es importante destacar que el p-valor no mide la magnitud
de la diferencia, sino únicamente la probabilidad de observar los datos bajo la
hipótesis nula.

### Evaluación del error

Los modelos de aprendizaje automático requieren datos de entrenamiento para establecer
relaciones entre las variables y construir una función que se aproxime a la distribución
de los datos. Un aspecto fundamental en este proceso es la evaluación del desempeño del
modelo, lo cual se realiza mediante métricas estadísticas.

#### Suma de los cuadrados de los residuales (SSR)

<figure markdown="span">
  ![Suma de los cuadrados de los residuales](https://images.squarespace-cdn.com/content/v1/5acbdd3a25bf024c12f4c8b4/1600368657769-5BJU5FK86VZ6UXZGRC1M/Mean+Squared+Error.png)
  <figcaption>Ejemplo de SSR. <a href="https://images.squarespace-cdn.com/content/v1/5acbdd3a25bf024c12f4c8b4/1600368657769-5BJU5FK86VZ6UXZGRC1M/Mean+Squared+Error.png">Referencia</a></figcaption>
</figure>

La **Suma de los Cuadrados de los Residuales** (_Sum of Squared Residuals_, SSR) mide la
diferencia entre las predicciones del modelo y los valores reales. Se calcula sumando el
cuadrado de estas diferencias, lo que permite evaluar qué tan buena es la predicción del
modelo. Un valor bajo de SSR indica un mejor ajuste. Matemáticamente, la SSR se expresa
como:

$$
SSR = \sum_{i=1}^{n} (y_i - \hat{y}_i)^2,
$$

donde $y_i$ es el valor real, $\hat{y}_i$ es el valor estimado por el modelo y $n$ es el
número total de observaciones.

Sin embargo, la SSR depende del número de datos, lo que puede dificultar la comparación
entre modelos. Para abordar este problema, se emplea el **Error Cuadrático Medio
(MSE)**.

#### Error cuadrático medio (MSE)

El **Error Cuadrático Medio** (_Mean Squared Error_, MSE) se obtiene dividiendo la SSR
entre el número total de muestras. Su objetivo es promediar la magnitud del error para
normalizarlo con respecto al tamaño del conjunto de datos. Se define como:

$$
\text{MSE} = \frac{1}{n} \sum_{i=1}^{n} (y_i - \hat{y}_i)^2.
$$

A pesar de que el MSE proporciona una medida más interpretable del error, sigue
dependiendo de la escala de los datos. Para eliminar esta dependencia, se emplea el
**Coeficiente de Determinación ($R^2$)**.

#### Coeficiente de determinación

El **Coeficiente de Determinación** ($R^2$) mide la capacidad del modelo para replicar
los resultados observados y la proporción de variabilidad explicada por el modelo en
comparación con la media de los datos. Se expresa como:

$$
R^2 = 1 - \frac{SSR}{SST} = 1 - \frac{SSR(\text{respecto al modelo})}{SSR(\text{respecto a la media})},
$$

donde $SST$ es la **Suma Total de los Cuadrados**, que representa la variabilidad total
de los datos en torno a la media.

El coeficiente $R^2$ varía entre 0 y 1, donde un valor cercano a 1 indica que el modelo
explica bien la varianza de los datos, lo que sugiere un buen ajuste. En cambio, un
valor cercano a 0 sugiere que el modelo apenas mejora la predicción en comparación con
la media. Si $R^2$ es negativo, el modelo tiene un mal ajuste y predice peor que la
media. Por ejemplo, si $R^2 = 0.6$, se interpreta que la variable independiente explica
el 60% de la variación observada en la variable dependiente.

El coeficiente $R^2$ se emplea en problemas de regresión sobre datos continuos.

!!! note "Relación entre R² y correlación de Pearson"

    El coeficiente $R^2$ equivale al cuadrado del coeficiente de correlación de Pearson solo en el caso de la regresión lineal simple.

#### Coeficiente de correlación de Pearson

<figure markdown="span">
  ![Correlación para una nube de puntos](http://www.statisticshowto.com/wp-content/uploads/2012/10/pearson-2-small.png)
  <figcaption>Ejemplo de la correlación para una nube de puntos. <a href="http://www.statisticshowto.com/wp-content/uploads/2012/10/pearson-2-small.png">Referencia</a></figcaption>
</figure>

El **Coeficiente de Correlación de Pearson** mide la relación lineal entre dos variables
cuantitativas y continuas. Se define como:

$$
r = \frac{\text{cov}(X,Y)}{\sigma_X \sigma_Y},
$$

donde $\text{cov}(X,Y)$ es la **covarianza** entre las variables $X$ e $Y$, y $\sigma_X$
y $\sigma_Y$ son las desviaciones típicas de $X$ e $Y$, respectivamente.

La **covarianza** indica la relación entre dos variables. Si la covarianza es positiva,
un aumento en $X$ se asocia con un aumento en $Y$ (relación directa). Si la covarianza
es negativa, un aumento en $X$ se asocia con una disminución en $Y$ (relación inversa).
Una covarianza cercana a 0 sugiere que no existe relación lineal entre las variables.

Dado que la covarianza depende de la escala de las variables, se normaliza mediante el
coeficiente de correlación de Pearson, que toma valores entre -1 y 1, donde 1 indica una
correlación positiva perfecta, -1 una correlación negativa perfecta y 0 la ausencia de
correlación lineal. Este coeficiente permite evaluar la intensidad y dirección de la
relación lineal entre las variables sin depender de su escala.
