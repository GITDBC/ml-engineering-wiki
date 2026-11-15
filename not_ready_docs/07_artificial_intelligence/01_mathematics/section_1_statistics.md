---
icon: lucide/chart-bar
authors: Daniel Bazo Correa
description:
    Estadística necesaria para el aprendizaje automático, desde la validación cruzada,
    los estadísticos descriptivos, la correlación y la regresión lineal por mínimos
    cuadrados hasta la probabilidad, las distribuciones usuales, el teorema central del
    límite, los p-valores y las métricas de error.
title: Estadística
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Este capítulo cubre los fundamentos estadísticos necesarios para el aprendizaje
automático. Parte de la selección y validación de los datos y continúa con las medidas
de posición y dispersión, la covarianza, la correlación y la regresión lineal simple y
múltiple por mínimos cuadrados. Después introduce la probabilidad condicionada y el
teorema de Bayes, las variables aleatorias con su esperanza y su varianza, las
distribuciones que utilizan los modelos y el teorema central del límite, para terminar
con los p-valores y las métricas de error.

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

    Es fundamental establecer una **semilla aleatoria** antes de cualquier proceso que
    requiera aleatorización, garantizando así la reproducibilidad de los resultados.

Por ejemplo, el siguiente código establece semillas para las bibliotecas más utilizadas
en Python para aprendizaje automático y profundo, garantizando la reproducibilidad de
los experimentos:

```python linenums="1"
import random
import numpy as np
import torch
import sklearn.utils

# Valor de la semilla
SEED = 42

# Establecer semilla en Python (random)
random.seed(SEED)

# Establecer semilla en NumPy
np.random.seed(SEED)

# Establecer semilla en PyTorch
torch.manual_seed(SEED)
# Para GPUs
torch.cuda.manual_seed(SEED)
# Para múltiples GPUs
torch.cuda.manual_seed_all(SEED)
# Para reproducibilidad en CUDA
torch.backends.cudnn.deterministic = True
torch.backends.cudnn.benchmark = False

# Establecer semilla en Scikit-learn
sklearn.utils.check_random_state(SEED)
```

La **validación cruzada** es una técnica fundamental en aprendizaje automático para
evaluar y comparar diferentes modelos. Su objetivo es estimar el rendimiento de un
modelo en datos no vistos y seleccionar el algoritmo más adecuado. El proceso consiste
en dividir el conjunto de datos en múltiples subconjuntos denominados **_folds_**,
generalmente de tamaño similar, y entrenar el modelo de manera iterativa. El caso más
común es el **_k-fold cross validation_**, donde $k$ suele ser cinco o diez, dependiendo
del tamaño del conjunto de datos y de la complejidad del modelo. El procedimiento se
desarrolla de la siguiente manera:

1. Se separa el conjunto de datos en $k$ _folds_.
2. En cada iteración, se utiliza un _fold_ como conjunto de prueba y los restantes como
   conjunto de entrenamiento.
3. El modelo se entrena con los _folds_ de entrenamiento y se evalúa con el _fold_ de
   prueba.
4. Este procedimiento se repite hasta que todos los _folds_ hayan sido utilizados como
   conjunto de prueba una vez.
5. Finalmente, se promedian las métricas de evaluación obtenidas en cada iteración, como
   precisión, error o sensibilidad.

La validación cruzada debe aplicarse sin introducir **_data leakage_** (fuga de datos),
que ocurre cuando información del conjunto de validación o de prueba, del futuro o de la
propia etiqueta se utiliza durante el entrenamiento o el preprocesado, generando una
evaluación artificialmente optimista del modelo. Por ejemplo, normalizar o imputar
valores con estadísticos calculados sobre todo el conjunto antes de dividirlo filtra
información del _fold_ de prueba. Para evitarlo, el preprocesado se ajusta en cada
iteración solo con los _folds_ de entrenamiento.

## Estadística descriptiva

La **estadística descriptiva** organiza, resume y representa un conjunto de datos
observados sin extraer conclusiones sobre datos que no se han medido. Es el primer paso
de cualquier análisis, ya que las medidas que se definen en esta sección (media,
varianza, momentos, covarianza) son las mismas que reaparecen después en los modelos
probabilísticos y de aprendizaje automático.

### Conceptos básicos

El vocabulario de partida distingue entre el conjunto completo de lo que se estudia y la
parte que realmente se observa:

- **Población**: Conjunto de elementos que son objeto de estudio.
- **Individuo**: Cada elemento de la población.
- **Muestra**: Subconjunto no vacío de individuos de la población. Su número de
  elementos es el **tamaño muestral**, $n$.
- **Carácter**: Característica de los individuos de la población, que puede ser
  cualitativa o cuantitativa.

A lo largo del capítulo, $N$ designa el tamaño de la población y $n$ el de la muestra,
igual que en la sección de distribuciones que aparece más adelante. Una muestra de un
carácter cuantitativo se escribe $x_1, \ldots, x_n$.

### Tipos de carácter

La naturaleza del carácter determina qué operaciones tienen sentido sobre él. Un orden
permite calcular medianas y cuantiles, mientras que solo un carácter numérico admite
medias y varianzas.

| Carácter     | Subtipo                    | Ejemplos                          |
| :----------- | :------------------------- | :-------------------------------- |
| Cualitativo  | Nominal                    | País, color.                      |
| Cualitativo  | Ordinal (con orden)        | Todo, mucho, regular, poco, nada. |
| Cuantitativo | Discreto (valores sueltos) | Número de hijos.                  |
| Cuantitativo | Continuo (intervalos)      | Altura, peso.                     |

En aprendizaje automático esta clasificación se corresponde con la distinción entre
variables categóricas, que requieren una codificación previa, y variables numéricas.

### Medidas de tendencia central

Las medidas de tendencia central resumen en un único valor el centro de la distribución.

#### Media aritmética

La **media aritmética** es la suma de todos los valores dividida entre el número total
de datos:

$$
\bar{x} = \frac{1}{n} \sum_{i=1}^{n} x_i.
$$

Si los valores se repiten, cada modalidad $x_i$ aparece con una **frecuencia relativa**
$f_i = n_i / n$, donde $n_i$ es el número de veces que se observa, y la media se escribe
$\bar{x} = \sum_i x_i f_i$. La media es muy sensible a los valores extremos. Si a partir
de una variable $X$ se construye otra mediante una **transformación afín** $y_i = a
x_i + b$, la media se transforma de la misma manera:

$$
\bar{y} = a \bar{x} + b.
$$

Esta propiedad no se extiende a las transformaciones no lineales. Para $y = a x^2 + b
x + c$ no se cumple $\bar{y} = a \bar{x}^2 + b \bar{x} + c$, porque la media de los
cuadrados no es el cuadrado de la media. En general $\overline{x^2} \neq \bar{x}^2$, y
la diferencia entre ambos es la varianza que se define más adelante.

#### Media ponderada

La **media ponderada** asigna a cada valor un peso $w_i$ que refleja su importancia:

$$
\bar{x}_w = \frac{\sum_i x_i w_i}{\sum_i w_i}.
$$

???+ example "Media ponderada de dos métricas"

    Un caso habitual de media ponderada es combinar la precisión de dos clasificadores
    según el número de muestras evaluadas. Si uno obtiene 0.90 sobre 300 muestras y
    otro 0.80 sobre 100, la precisión global es:

    $$
    \bar{x}_w = \frac{0.90 \cdot 300 + 0.80 \cdot 100}{300 + 100} = 0.875.
    $$

#### Moda y mediana

La **moda** $M_o$ de un conjunto de datos es el valor que se presenta con mayor
frecuencia, y puede no ser única. La **mediana** $M_e$ divide la distribución en dos
partes iguales. Si $n$ es impar, coincide con el valor situado en la posición $(n+1)/2$
de los datos ordenados. Si $n$ es par, es la media de los valores situados en las
posiciones $n/2$ y $n/2 + 1$. A diferencia de la media, la mediana no se ve afectada por
los valores atípicos.

### Medidas de posición

Los **cuantiles** generalizan la mediana. El cuantil $x(p)$ es el valor por debajo del
cual queda una proporción $p$ de los datos. Los **cuartiles** dividen la distribución en
cuatro partes iguales, los **deciles** en diez y los **percentiles** en cien:

$$
Q_k = x\left(\frac{k}{4}\right),\quad D_k = x\left(\frac{k}{10}\right),\quad
P_k = x\left(\frac{k}{100}\right).
$$

Hay tres cuartiles ($k = 1, 2, 3$), nueve deciles y 99 percentiles. El segundo cuartil
es la mediana: $Q_2 = x(0.5) = M_e$.

!!! note

    Existen varias convenciones para estimar cuantiles. Bibliotecas como NumPy
    interpolan linealmente entre observaciones por defecto, por lo que sus resultados
    pueden diferir ligeramente de otros criterios, como tomar el primer dato cuya
    frecuencia relativa acumulada alcanza $p$.

### Medidas de dispersión

Las medidas de dispersión cuantifican cuán agrupados o dispersos están los datos. Son
sensibles a los errores en los datos, salvo las que se basan en posiciones.

El **rango** o recorrido $R$ es la diferencia entre el mayor y el menor valor observado.
El **rango intercuartílico**, $R_Q = Q_3 - Q_1$, y el **rango interpercentílico**, $R_P
= P_{99} - P_1$, no son sensibles a los valores atípicos, porque descartan las colas de
la distribución.

#### Error cuadrático medio respecto a un valor

El **error cuadrático medio** respecto a un parámetro $p$ promedia los cuadrados de las
desviaciones $x_i - p$, de modo que penaliza más las desviaciones grandes:

$$
ECM(p) = \frac{1}{n} \sum_{i=1}^{n} (x_i - p)^2.
$$

Se cumple $ECM(p) = ECM(\bar{x}) + (\bar{x} - p)^2$, de modo que el error cuadrático
medio es mínimo cuando $p = \bar{x}$. Ese valor mínimo es la varianza, que se define a
continuación. Esta es una de las razones por las que la media es el resumen natural
cuando se mide el error al cuadrado.

#### Varianza y desviación típica

La **varianza** es el ECM respecto a la media y la **desviación típica** es su raíz
cuadrada positiva:

$$
\sigma^2 = \frac{1}{n} \sum_{i=1}^{n} (x_i - \bar{x})^2,
$$

$$
\sigma = +\sqrt{\sigma^2}.
$$

El **coeficiente de variación de Pearson** relaciona la dispersión con el tamaño de la
media y carece de unidades, de modo que permite comparar variables con escalas
distintas. No está definido para $\bar{x} = 0$:

$$
CV = \frac{\sigma}{|\bar{x}|}.
$$

#### Media y varianza muestrales

Normalmente no es posible medir toda la población. El mejor estimador de la media
poblacional $\mu$ es la media muestral $\bar{x}$. El mejor estimador de la varianza
poblacional es la **varianza muestral** $s^2$, que corrige con el factor $n/(n-1)$ la
varianza $\sigma_M^2$ calculada sobre la muestra:

$$
s^2 = \frac{n}{n-1} \, \sigma_M^2 = \frac{1}{n-1} \sum_{i=1}^{n} (x_i - \bar{x})^2.
$$

Esta es la varianza muestral que aparece en la sección de distribuciones, con
denominador $n - 1$. La corrección compensa que $\bar{x}$ se calcula a partir de los
mismos datos y por eso subestima la dispersión respecto a la media poblacional.

### Momentos

Los **momentos** unifican las medidas anteriores en una familia de expresiones. El
**momento ordinario de orden $r$**, $m_r$, y el **momento central de orden $r$**,
$\mu_r$, son:

$$
m_r = \frac{1}{n} \sum_{i=1}^{n} x_i^r, \qquad
\mu_r = \frac{1}{n} \sum_{i=1}^{n} (x_i - \bar{x})^r.
$$

Los primeros momentos recuperan medidas conocidas: $m_1 = \bar{x}$, $m_2 = \sigma^2 +
\bar{x}^2$, $\mu_1 = 0$ y $\mu_2 = \sigma^2 = m_2 - \bar{x}^2$. Los momentos centrales
de orden 3 y 4 describen la forma de la distribución mediante los coeficientes de
**asimetría** y de **apuntamiento** de Fisher:

$$
g_1 = \frac{\mu_3}{\sigma^3}, \qquad g_2 = \frac{\mu_4}{\sigma^4} - 3.
$$

Un valor $g_1 > 0$ indica asimetría a la derecha (cola más larga hacia los valores
altos) y $g_1 < 0$, asimetría a la izquierda. El coeficiente $g_2$ compara la
distribución con la normal, para la que vale 0. Su interpretación se detalla más
adelante, en la subsección de asimetría y curtosis de las distribuciones.

???+ example "Estadísticos descriptivos con NumPy"

    El siguiente código calcula las medidas de posición y de dispersión y los
    coeficientes de Fisher de una muestra de diez observaciones.

    ```python linenums="1"
    import numpy as np

    # Muestra de diez observaciones
    x = np.array([2, 3, 3, 4, 5, 5, 5, 6, 7, 10])
    n = len(x)

    # Tendencia central y posición
    media = x.mean()
    mediana = np.median(x)
    q1, q3 = np.percentile(x, [25, 75])

    # Dispersión: varianza sobre la muestra, desviación típica y varianza muestral
    varianza = x.var()
    sigma = x.std()
    s2 = x.var(ddof=1)

    # Coeficientes de asimetría y apuntamiento de Fisher
    g1 = np.mean((x - media) ** 3) / sigma**3
    g2 = np.mean((x - media) ** 4) / sigma**4 - 3

    print(f"media={media:.2f} mediana={mediana:.2f} Q1={q1:.2f} Q3={q3:.2f}")
    print(f"varianza={varianza:.2f} sigma={sigma:.4f} s2={s2:.4f}")
    print(f"g1={g1:.4f} g2={g2:.4f}")
    ```

    ```plaintext title="Expected output"
    media=5.00 mediana=5.00 Q1=3.25 Q3=5.75
    varianza=4.80 sigma=2.1909 s2=5.3333
    g1=0.8558 g2=0.2813
    ```

    La moda es $M_o = 5$ y coincide con la media y la mediana, pero el valor 10 alarga
    la cola derecha y produce $g_1 > 0$. El argumento `ddof=1` de NumPy aplica la
    corrección $n - 1$ de la varianza muestral.

## Estadística bivariante

Hasta ahora se ha descrito un único carácter. Cuando se observan simultáneamente dos
caracteres sobre cada individuo, interesa además estudiar la relación entre ambos. La
descripción conjunta es la base de la correlación y de la regresión.

### Covarianza

Una muestra de la variable bidimensional $(X, Y)$ está formada por $n$ pares $(x_i,
y_i)$ observados en cada individuo. El punto $G = (\bar{x}, \bar{y})$ se denomina
**centro de gravedad** de la distribución. La **covarianza** mide cómo varían
conjuntamente ambas variables respecto a sus medias:

$$
\text{cov}(x, y) = \sigma_{xy}
= \frac{1}{n} \sum_{i=1}^{n} (x_i - \bar{x})(y_i - \bar{y})
= \frac{1}{n} \sum_{i=1}^{n} x_i y_i - \bar{x} \bar{y}.
$$

La covarianza de una variable consigo misma es su varianza, $\text{cov}(x, x) =
\sigma_x^2$. Con $d$ variables, las varianzas y covarianzas de todos los pares se reúnen
en la **matriz de covarianzas**, simétrica y semidefinida positiva, que es la base del
análisis de componentes principales. Ambas propiedades se definen en el capítulo de
[matemáticas del aprendizaje profundo](section_2_deep_learning_math.md).

### Dependencia estadística

El objetivo de analizar dos variables conjuntamente es establecer la relación entre
ellas. Hay tres situaciones posibles:

- **Independencia**: No hay relación entre las variables.
- **Dependencia funcional**: El valor de una variable queda determinado conociendo el
  valor de la otra.
- **Dependencia estadística**: Una variable da información sobre la otra, pero la
  modalidad de una no determina la de la otra.

Sean $f_{ij}$ la frecuencia relativa con la que se observa el par $(x_i, y_j)$ y
$f_{i\cdot} = \sum_j f_{ij}$ y $f_{\cdot j} = \sum_i f_{ij}$ las **frecuencias
marginales** de cada modalidad. Dos variables son **independientes** si y solo si la
frecuencia conjunta es el producto de las marginales para todos los pares:

$$
f_{ij} = f_{i\cdot} \, f_{\cdot j}, \qquad \forall i, j.
$$

Basta con que una sola celda no cumpla la igualdad para que las variables sean
dependientes. Si $X$ es independiente de $Y$, entonces $Y$ es independiente de $X$.

!!! warning

    La independencia implica covarianza nula, pero el recíproco es falso. Sea $X$ una
    variable que toma los valores $-1$, $0$ y $1$ con igual frecuencia e $Y = X^2$. La
    covarianza vale $\overline{xy} - \bar{x}\,\bar{y} = \overline{x^3} - 0 = 0$ y sin
    embargo $Y$ está completamente determinada por $X$. La covarianza solo detecta
    relaciones lineales.

## Regresión y correlación

La **correlación** mide el grado de dependencia lineal entre dos variables. La
**regresión** pretende encontrar un modelo aproximado de la dependencia entre ellas. Al
representar los pares de la muestra de una variable bidimensional sobre unos ejes se
obtiene una nube de puntos o **diagrama de dispersión**, y la función que mejor se
ajusta a esa nube se denomina **curva de regresión**. Si todos los puntos satisfacen la
ecuación obtenida, las variables están perfectamente relacionadas.

La forma de la nube indica el tipo de relación:

| Forma de la nube                              | Interpretación                         |
| :-------------------------------------------- | :------------------------------------- |
| Puntos que ascienden de izquierda a derecha.  | Correlación lineal positiva o directa. |
| Puntos que descienden de izquierda a derecha. | Correlación lineal negativa o inversa. |
| Puntos dispersos sin patrón.                  | Ausencia de relación lineal.           |
| Puntos que describen una curva, como una U.   | Relación no lineal.                    |

### Coeficiente de correlación de Pearson

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

La interpretación del coeficiente se resume en los siguientes casos:

- Si $r > 0$, existe correlación lineal directa.
- Si $r < 0$, existe correlación lineal inversa.
- Si $r = 0$, las variables están linealmente incorreladas, aunque pueden depender de
  otra forma, como muestra la advertencia de la sección de dependencia.
- Si $r = 1$ o $r = -1$, la correlación lineal es perfecta, directa o inversa.

### Método de mínimos cuadrados

Dados los datos $\{(x_i, y_i)\}$ de dos variables cuantitativas, el problema de la
regresión consiste en determinar una función $y = \varphi(x)$ de una familia de
funciones reales que se aproxime lo más posible a los datos. El criterio es el **método
de mínimos cuadrados**, que minimiza la suma de los cuadrados de los errores $e_i =
y_i - \varphi(x_i)$:

$$
f = \sum_i \left(y_i - \varphi(x_i)\right)^2 = \sum_i e_i^2.
$$

Esta suma coincide con la SSR que se define más adelante en la sección de evaluación del
error. Minimizarla equivale a minimizar el error cuadrático medio $\sum_i e_i^2 / n$.
Según la forma de $\varphi$, los ajustes más habituales son:

| Ajuste      | Función                      |
| :---------- | :--------------------------- |
| Lineal      | $\varphi(x) = a + bx$        |
| Parabólico  | $\varphi(x) = a + bx + cx^2$ |
| Exponencial | $\varphi(x) = a e^{bx}$      |

En cada caso hay que calcular los valores de los parámetros que minimizan la función
objetivo. El caso lineal es la base de la regresión lineal que se utiliza en los
[modelos supervisados](../02_machine_learning/section_2_supervised_models.md).

### Ajuste de la recta

En el ajuste de la **recta de $Y$ sobre $X$**, $y = a + bx$, la función a minimizar es

$$
F(a, b) = \sum_i \left(y_i - (a + b x_i)\right)^2,
$$

que mide las distancias verticales entre los puntos y la recta. Al anular las derivadas
parciales respecto a $a$ y $b$ se obtiene el sistema de **ecuaciones normales**:

$$
\sum_i y_i = n a + b \sum_i x_i,
$$

$$
\sum_i x_i y_i = a \sum_i x_i + b \sum_i x_i^2.
$$

Dividiendo entre $n$, la primera ecuación indica $\bar{y} = a + b \bar{x}$, es decir,
que el centro de gravedad $G = (\bar{x}, \bar{y})$ pertenece a la recta. Restando de la
segunda, dividida entre $n$, la primera multiplicada por $\bar{x}$ se obtiene la
pendiente en función de la covarianza:

$$
b = \frac{n \sum x_i y_i - \sum x_i \sum y_i}{n \sum x_i^2 - \left(\sum x_i\right)^2}
= \frac{\text{cov}(x, y)}{\sigma_x^2}, \qquad a = \bar{y} - b \bar{x}.
$$

Utilizando el coeficiente de correlación, la recta se escribe:

$$
y - \bar{y} = r \frac{\sigma_y}{\sigma_x} (x - \bar{x}).
$$

La pendiente tiene el signo de la covarianza. Esta recta debe utilizarse para predecir
$Y$ a partir de $X$. Para el caso contrario se ajusta la recta de $X$ sobre $Y$, que
minimiza las distancias horizontales y solo coincide con la anterior cuando $|r| = 1$.

???+ example "Recta de regresión de diez puntos"

    Con $n = 10$ pares, las sumas son $\sum x = 560$, $\sum y = 178$,
    $\sum x^2 = 37750$ y $\sum xy = 7745$. Aplicando las expresiones anteriores:

    $$
    b = \frac{10 \cdot 7745 - 560 \cdot 178}{10 \cdot 37750 - 560^2} =
    \frac{-22230}{63900} = -0.347887,
    $$

    $$
    a = \frac{178 - (-0.347887) \cdot 560}{10} = 37.28169.
    $$

    La recta de regresión es $y = 37.28169 - 0.34789 x$ y su pendiente negativa es
    coherente con el signo de la correlación. El siguiente código reproduce el cálculo,
    obtiene el coeficiente de Pearson $r = -0.88223$, que indica una correlación
    inversa y fuerte, y verifica que el coeficiente de determinación $R^2$, definido
    más adelante en esta sección, coincide con $r^2$. La recta explica el 77.83% de la
    variabilidad de $Y$.

    ```python linenums="1"
    import numpy as np

    # Datos de la muestra bidimensional
    x = np.array([100, 90, 80, 45, 50, 50, 60, 40, 25, 20])
    y = np.array([3, 5, 9, 10, 20, 21, 24, 24, 27, 35])
    n = len(x)

    # Pendiente y ordenada de y = a + b x por ecuaciones normales
    num = n * np.sum(x * y) - np.sum(x) * np.sum(y)
    den = n * np.sum(x**2) - np.sum(x) ** 2
    b = num / den
    a = (np.sum(y) - b * np.sum(x)) / n

    # Covarianza y coeficiente de correlación
    cov = np.mean(x * y) - x.mean() * y.mean()
    r = cov / (x.std() * y.std())

    # Residuos, varianza residual y coeficiente de determinación
    e = y - (a + b * x)
    v_r = np.mean(e**2) - np.mean(e) ** 2
    r2 = 1 - v_r / y.var()

    print(f"a={a:.5f} b={b:.5f}")
    print(f"cov={cov:.1f} r={r:.5f}")
    print(f"V_r={v_r:.4f} R2={r2:.4f} r^2={r**2:.4f}")
    ```

    ```plaintext title="Expected output"
    a=37.28169 b=-0.34789
    cov=-222.3 r=-0.88223
    V_r=22.0246 R2=0.7783 r^2=0.7783
    ```

### Regresión lineal múltiple

El mismo criterio se aplica cuando la respuesta depende de varias variables o de
funciones no lineales de una sola, siempre que el modelo sea **lineal en sus
parámetros**. Es el caso de la parábola $y = a + bx + cx^2$, cuyas funciones base son
$1$, $x$ y $x^2$, o del plano $z = a + bx + cy$, con dos variables explicativas. Al
anular las derivadas parciales de la suma de cuadrados se obtiene un sistema de
ecuaciones normales que, en forma matricial, se escribe como:

$$
\mathbf{A}^\top \mathbf{A} \mathbf{w} = \mathbf{A}^\top \mathbf{z},
$$

donde $\mathbf{A}$ es la matriz de diseño, cuyas columnas son las funciones base
evaluadas en los datos, $\mathbf{w}$ el vector de parámetros y $\mathbf{z}$ el vector de
valores a aproximar. Es la formulación que se desarrolla con álgebra lineal en el
capítulo de [matemáticas del aprendizaje profundo](section_2_deep_learning_math.md).

Los modelos que no son lineales en sus parámetros se pueden **linealizar** con una
transformación de las variables. Para $y = a e^{bx}$, al tomar logaritmos se tiene $\ln
y = \ln a + bx$, una recta en las variables $(x, \ln y)$. Como el error se minimiza
entonces en el espacio transformado, la calidad del ajuste se evalúa con los residuos
originales $e_i = y_i - \hat{y}_i$.

???+ example "Ajuste de una parábola y de un plano"

    Para siete puntos con $x = 0, 1, \ldots, 6$ e $y = 2.4, 2.1, 3.2, 5.6, 9.3, 14.6,
    21.9$, el ajuste de la parábola da $a = 2.5095$, $b = -1.2$ y $c = 0.7333$. Para
    ocho puntos $(x, y, z)$, el ajuste del plano da $a = 2.2045$, $b = -1.0568$ y
    $c = 1.6591$. Ambos ajustes se resuelven en NumPy con una única función.

    ```python linenums="1"
    import numpy as np


    def ajustar(columnas: list[np.ndarray], objetivo: np.ndarray) -> np.ndarray:
        """Resuelve las ecuaciones normales de un ajuste lineal en sus parámetros.

        Args:
            columnas: Funciones base evaluadas en los datos (1, x, x^2, y...).
            objetivo: Valores a aproximar.

        Returns:
            Los coeficientes que minimizan la suma de cuadrados de los errores.
        """
        A = np.column_stack(columnas)
        return np.linalg.solve(A.T @ A, A.T @ objetivo)


    def r_cuadrado(real: np.ndarray, estimado: np.ndarray) -> float:
        """Coeficiente de determinación a partir de la varianza residual."""
        e = real - estimado
        v_r = np.mean(e**2) - np.mean(e) ** 2
        return 1 - v_r / np.var(real)


    # Parábola y = a + b x + c x^2 con siete puntos
    x = np.arange(7.0)
    y = np.array([2.4, 2.1, 3.2, 5.6, 9.3, 14.6, 21.9])
    a, b, c = ajustar([np.ones(7), x, x**2], y)
    print(f"parábola: a={a:.4f} b={b:.4f} c={c:.4f}")
    print(f"R2={r_cuadrado(y, a + b * x + c * x**2):.4f}")

    # Plano z = a + b x + c y con ocho puntos
    px = np.array([0, 1, 0, -1, 0, 1, 1, 2.0])
    py = np.array([0, 1, 1, 1, 3, 2, 2, 0.0])
    z = np.array([2, 3, 4, 5, 7, 4, 5, 0.0])
    a, b, c = ajustar([np.ones(8), px, py], z)
    print(f"plano: a={a:.4f} b={b:.4f} c={c:.4f}")
    print(f"R2={r_cuadrado(z, a + b * px + c * py):.4f}")
    ```

    ```plaintext title="Expected output"
    parábola: a=2.5095 b=-1.2000 c=0.7333
    R2=0.9995
    plano: a=2.2045 b=-1.0568 c=1.6591
    R2=0.9794
    ```

### Varianza residual y coeficiente de determinación

La **varianza residual** $V_r$ es la parte de la variabilidad de $Y$ que el modelo deja
sin explicar. Se calcula con los errores $e_i = y_i - \hat{y}_i$, y su raíz cuadrada es
el **error típico**:

$$
V_r = \frac{1}{n} \sum_i (e_i - \bar{e})^2
= \frac{\sum_i e_i^2}{n} - \left(\frac{\sum_i e_i}{n}\right)^2.
$$

El **coeficiente de determinación** relaciona esa variabilidad no explicada con la
total:

$$
R^2 = 1 - \frac{V_r}{\text{Var}(y)},
$$

donde $\text{Var}(y) = \sigma_y^2$ es la varianza de los valores observados. El valor
$R^2 = 1$ corresponde a un ajuste perfecto y $R^2 = 0$ a un ajuste que no explica nada.
Cuando el modelo es lineal con término independiente, las ecuaciones normales implican
$\sum_i e_i = 0$, de modo que $\bar{e} = 0$ y la varianza residual es simplemente $V_r =
SSR/n$. En la recta se cumple además $R^2 = r^2$ y $V_r = (1 - r^2) \text{Var}(y)$. En
los ajustes no lineales, $\bar{e}$ no tiene por qué ser cero y $R^2$ se calcula
directamente con $V_r$.

## Probabilidad

La estadística descriptiva trabaja con datos ya observados. La **teoría de la
probabilidad** proporciona el marco formal para razonar sobre experimentos cuyo
resultado no se conoce de antemano. Esta sección fija ese marco, y en las siguientes se
construyen sobre él las variables aleatorias y los modelos de distribución.

### Experimentos y sucesos

Un experimento científico produce un resultado que puede ser **determinista**, cuando
las mismas circunstancias dan siempre el mismo resultado, o **aleatorio**, cuando
circunstancias idénticas pueden dar resultados distintos dentro de un conjunto
predeterminado. El **espacio muestral** $\Omega$ de un experimento aleatorio es el
conjunto de sus resultados posibles. Un **suceso aleatorio** es un subconjunto $A
\subseteq \Omega$. El **suceso seguro** es $\Omega$ y el **suceso imposible**,
$\emptyset$.

Entre sucesos se definen la **unión** $A \cup B$ (ocurre $A$ o $B$), la **intersección**
$A \cap B$ (ocurren $A$ y $B$) y el **complementario** o **contrario** $\overline{A}$,
que ocurre cuando no ocurre $A$.

???+ example "Sucesos de un dado"

    Al lanzar un dado, $\Omega = \{1, 2, 3, 4, 5, 6\}$. Sean $A = \{2, 4, 6\}$ el suceso
    «sale par» y $B = \{3, 6\}$ el suceso «sale múltiplo de 3». Entonces
    $A \cup B = \{2, 3, 4, 6\}$, $A \cap B = \{6\}$ y $\overline{A} = \{1, 3, 5\}$.

### Medida de probabilidad

Una función $P$ que asigna a cada suceso $A \subseteq \Omega$ un número $P(A) \in
\lbrack 0, 1 \rbrack$ es una **medida de probabilidad** si y solo si se cumple:

- $P(\Omega) = 1$.
- Para toda colección finita o numerable de sucesos $\{A_i\}_{i \in I}$ disjuntos dos a
  dos, $A_i \cap A_j = \emptyset$ para $i \neq j$, se tiene $P\left(\bigcup_{i}
  A_i\right) = \sum_{i} P(A_i)$.

El espacio muestral junto con su medida, $(\Omega, P)$, forma un **espacio de
probabilidad**. Si $\Omega$ es finito o infinito numerable y se conoce la probabilidad
de cada suceso elemental, queda determinada la de cualquier suceso. De los axiomas se
derivan las siguientes propiedades:

- $P(\overline{A}) = 1 - P(A)$ y $P(\emptyset) = 0$.
- Si $A \subseteq B$, entonces $P(A) \leq P(B)$.
- $P(A \cup B) = P(A) + P(B) - P(A \cap B)$.

Desde el punto de vista frecuentista, la probabilidad de un suceso $A$ es el límite de
su frecuencia relativa cuando el número de repeticiones crece:

$$
P(A) = \lim_{n \to \infty} \frac{n_A}{n},
$$

donde $n_A$ es el número de veces que ocurre $A$ en $n$ repeticiones.

Si todos los sucesos elementales son equiprobables, la **regla de Laplace** establece:

$$
P(A) = \frac{\text{número de sucesos elementales favorables}}{\text{número de sucesos
elementales posibles}}.
$$

???+ example "Probabilidad de una unión"

    Con los sucesos del dado, $P(A) = 3/6$, $P(B) = 2/6$ y $P(A \cap B) = 1/6$, por lo
    que:

    $$
    P(A \cup B) = \frac{3}{6} + \frac{2}{6} - \frac{1}{6} = \frac{4}{6} = 0.6667,
    $$

    resultado que coincide con el recuento directo de $\{2, 3, 4, 6\}$.

### Probabilidad condicionada y teorema de Bayes

Sea $A$ un suceso con $P(A) \neq 0$. La **probabilidad condicionada** de un suceso $B$
dado $A$ es:

$$
P(B \mid A) = \frac{P(A \cap B)}{P(A)}.
$$

Despejando la intersección se recupera la regla del producto $P(A \cap B) = P(B \mid A)
P(A)$ que se usa más adelante con distribuciones. Un suceso $B$ es **independiente** de
otro $A$ si y solo si $P(B \mid A) = P(B)$, o de forma equivalente, $P(A \cap B) = P(A)
P(B)$.

Un conjunto de sucesos $\{C_i\}_{i \in I}$ es un **sistema completo** si son disjuntos
dos a dos y su unión es todo el espacio muestral, $\bigcup_i C_i = \Omega$. Para un
sistema completo, el **teorema de la probabilidad total** descompone la probabilidad de
cualquier suceso $B$ según el caso en que se encuentre el sistema:

$$
P(B) = \sum_{i \in I} P(C_i) \, P(B \mid C_i).
$$

El **teorema de Bayes** invierte el condicionamiento. Si además $P(C_i) > 0$ para todo
$i$, la probabilidad de que se haya dado $C_j$ sabiendo que ha ocurrido $B$ es:

$$
P(C_j \mid B) = \frac{P(C_j) \, P(B \mid C_j)}{\sum_{i \in I} P(C_i) \, P(B \mid C_i)}.
$$

El numerador de esta expresión es la probabilidad conjunta de $C_j$ y $B$, y el
denominador es la probabilidad total de $B$. En términos de inferencia, $P(C_j)$ es la
probabilidad **a priori**, $P(B \mid C_j)$ la verosimilitud y $P(C_j \mid B)$ la
probabilidad **a posteriori**.

???+ example "Independencia y teorema de Bayes"

    Con los sucesos del dado, $P(B \mid A) = P(\{6\}) / P(A) = (1/6)/(1/2) = 1/3$, que
    es igual a $P(B)$. Por tanto, «par» y «múltiplo de 3» son independientes.

    Tres máquinas $M_1$, $M_2$ y $M_3$ producen el 50%, el 30% y el 20% de las piezas de
    una fábrica, con una proporción de piezas defectuosas del 2%, el 5% y el 10%,
    respectivamente. La probabilidad de que una pieza elegida al azar sea defectuosa
    ($D$) es, por la probabilidad total:

    $$
    P(D) = 0.5 \cdot 0.02 + 0.3 \cdot 0.05 + 0.2 \cdot 0.10 = 0.045.
    $$

    Si una pieza resulta defectuosa, la probabilidad de que proceda de cada máquina se
    obtiene con el teorema de Bayes:

    $$
    P(M_3 \mid D) = \frac{0.2 \cdot 0.10}{0.045} = 0.4444, \quad
    P(M_2 \mid D) = \frac{0.015}{0.045} = 0.3333, \quad
    P(M_1 \mid D) = \frac{0.01}{0.045} = 0.2222.
    $$

    La máquina $M_3$ produce solo el 20% de las piezas, pero origina el 44% de los
    defectos. La observación del defecto ha actualizado la creencia inicial.

## Variables aleatorias y distribuciones

Con el espacio de probabilidad definido, el siguiente paso es asociar un número a cada
resultado del experimento. Esta sección reúne la caracterización de las variables
aleatorias y las distribuciones de probabilidad más habituales, desde los histogramas
con los que se visualizan los datos hasta los modelos que los describen.

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

!!! note "Elección del número de _bins_"

    La elección del número de _bins_ es crucial, ya que debe reflejar correctamente la
    distribución de los datos. Este tipo de histogramas resulta especialmente útil en
    algoritmos como **Naïve Bayes**, donde se generan distribuciones de probabilidad en
    cada iteración, permitiendo obtener valores como medias e intervalos de confianza.

El conjunto completo de datos recopilados se denomina **población** y se representa con
la letra $N$. Un subconjunto de la población se denomina **muestra** y se representa con
la letra $n$.

La probabilidad de que un dato pertenezca a una determinada parte del histograma se
calcula dividiendo el número de muestras en esa sección entre el número total de
muestras en la población.

!!! note "Confianza y tamaño de muestra"

    La confianza en los resultados depende del tamaño de la muestra: cuanto mayor sea el
    número de muestras, mayor será la confianza en la estimación. La confianza
    representa el grado de incertidumbre asociado a una probabilidad.

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

    Supongamos que se lanza una moneda equilibrada (equiprobable, la probabilidad de
    obtener cara es la misma que la de obtener cruz) 5 veces y se quiere calcular la
    probabilidad de obtener exactamente 3 caras.

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

    Por lo tanto, la probabilidad de obtener exactamente 3 caras en 5 lanzamientos de
    una moneda equilibrada es del 31.25%.

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

    Supongamos que una central telefónica recibe en promedio 10 llamadas por hora y se
    desea calcular la probabilidad de que en una hora lleguen exactamente 7 llamadas.

    Se definen los parámetros:

    - $\lambda = 10$ (promedio de llamadas por hora).
    - $k = 7$ (número específico de llamadas que se desea calcular).

    Aplicamos la fórmula de la distribución de Poisson:

    $$
    P(X = 7) = \frac{10^7 e^{-10}}{7!} \approx 0.0902
    $$

    Por lo tanto, la probabilidad de recibir exactamente 7 llamadas en una hora es del
    9.02%.

#### Distribución normal o gaussiana (continua)

La distribución normal, también denominada distribución gaussiana, se representa
mediante una curva en forma de campana. En esta distribución, el eje $y$ indica la
**verosimilitud** (**_likelihood_**) de observar un determinado valor en el eje $x$.

!!! note "Verosimilitud vs. Probabilidad"

    Aunque son conceptos relacionados, la verosimilitud y la probabilidad tienen
    diferencias clave:

    - **Probabilidad**: Representa la posibilidad de que ocurra un evento dado un modelo
      y sus parámetros. Se expresa como $P(D|\theta)$, donde $D$ son los datos y
      $\theta$ los parámetros del modelo. Responde a la pregunta: _Dado que los
      parámetros del modelo son conocidos, ¿qué tan probable es observar ciertos datos?_
    - **Verosimilitud**: Mide qué tan bien un conjunto de parámetros explica un conjunto
      de datos observados. Se denota como $L(\theta | D)$ y representa la plausibilidad
      de los parámetros $\theta$ dados los datos $D$. Responde a la pregunta: _Dado que
      los datos han sido observados, ¿qué tan plausible es que provengan de un modelo
      con ciertos parámetros?_

    Mientras que la probabilidad se emplea para predecir eventos futuros basándose en un
    modelo conocido, la verosimilitud se usa para evaluar qué tan bien un modelo con
    ciertos parámetros explica los datos observados. Para obtener probabilidades a
    partir de la verosimilitud, se puede utilizar el Teorema de Bayes.

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
reales, entonces se cumple que $F: \mathbb{R} \to \lbrack 0,1 \rbrack$, lo que significa
que el rango de valores de la función de distribución está comprendido entre 0 y 1.

!!! note "Notación de la CDF"

    Se usa mayúscula para $F(x)$ porque se refiere a la función matemática que mapea los
    valores de la variable aleatoria $X$ a la probabilidad acumulada, distinguiéndola de
    la función de densidad de probabilidad que se representa en minúscula, como $f(x)$.

Algunas de sus propiedades fundamentales son:

- $F(x) = P(A_x) = P(X \leq x)$, donde $A_x$ representa el evento $X \leq x$.
- $P(X \leq x) = F(x)$, lo que corresponde a la función de distribución acumulada (CDF).
- $P(X > x) = 1 - P(X \leq x) = 1 - F(x)$, es decir, la probabilidad complementaria a
  $P(X \leq x)$.
- $P(a < X \leq b) = F(b) - F(a)$, para calcular la probabilidad de que $X$ esté entre
  dos valores $a$ y $b$.
- $P(X \geq a) = P(X > a) + P(X = a)$, una forma de descomponer la probabilidad de que
  $X$ sea mayor o igual que $a$.
- $P(X = a) = F(a) - \lim_{h \to 0^+} F(a - h) = F(a) - P(X < a)$, que calcula la
  probabilidad de que $X$ tome el valor $a$. En una variable continua $F$ no presenta
  saltos y esta probabilidad es nula.

Estas propiedades permiten calcular probabilidades acumuladas y facilitan el análisis de
distribuciones de probabilidad continuas.

???+ example "Distribución normal"

    Se desea calcular la probabilidad de que un valor se encuentre en el intervalo
    $\lbrack 142.5, 155.7 \rbrack$ en una distribución normal $N(\mu=155.7,
    \sigma=6.6)$.

    La probabilidad se obtiene a partir de la función de distribución acumulada (CDF):

    $$P(a < X \leq b) = P(142.5 < X \leq 155.7) = F(155.7) - F(142.5)$$

    $$P(X \leq 155.7) - P(X \leq 142.5) \approx 0.5 - 0.02275 \approx 0.4772$$

    Implementación en Python:

    ```python linenums="1"
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

    Por lo tanto, la probabilidad de que un valor de esta distribución normal se
    encuentre en el intervalo $\lbrack 142.5, 155.7 \rbrack$ es aproximadamente del
    47.72%.

#### Asimetría (_skewness_) y curtosis (_kurtosis_)

Además de la media y la varianza, existen dos medidas que caracterizan la forma de una
distribución: la **asimetría** (_skewness_) y la **curtosis** (_kurtosis_). Los
coeficientes de Fisher que las cuantifican se definen a partir de los momentos en la
sección de estadística descriptiva, y para una variable aleatoria se calculan con los
momentos centrales de su distribución.

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

La media de la distribución exponencial equivale a la **esperanza matemática** $E\lbrack
X \rbrack$.

!!! note "Esperanza matemática"

    La **esperanza matemática**, denotada como $E\lbrack X \rbrack$, es lo que
    comúnmente se denomina la **media** o el **valor esperado** de una variable
    aleatoria. Sin embargo, la interpretación de la esperanza matemática puede variar
    dependiendo del tipo de variable aleatoria y el contexto en el que se utilice.

    Para una variable aleatoria discreta $X$, cuya función de masa de probabilidad es
    $P(X = x_i)$, la esperanza matemática se calcula mediante la siguiente fórmula:

    $$
    E\lbrack X \rbrack = \sum_{i} x_i \cdot P(X = x_i)
    $$

    En este caso, el valor esperado se obtiene sumando el producto de cada valor posible
    de $X$ y su probabilidad correspondiente.

    Para una variable aleatoria continua $X$, cuya función de densidad de probabilidad
    es $f(x)$, la esperanza matemática se calcula utilizando la integral:

    $$
    E\lbrack X \rbrack = \int_{-\infty}^{\infty} x \cdot f(x) \,dx
    $$

    Aquí, el valor esperado se obtiene integrando el producto de cada valor de $X$ y su
    densidad de probabilidad asociada.

    En teoría de probabilidad, la esperanza matemática se considera la media "teórica"
    de la distribución. **En distribuciones simétricas con un único pico, como la
    distribución normal, la esperanza matemática coincide con el centro de la
    distribución. Sin embargo, en distribuciones asimétricas, la esperanza matemática
    puede no coincidir con la mediana o la moda**. Por ejemplo, en una distribución
    sesgada a la derecha, como la distribución exponencial, la esperanza matemática es
    mayor que la mediana, lo que indica que los valores más altos de la variable
    aleatoria tienen una probabilidad significativa de ocurrir.

En la distribución exponencial, la media se obtiene como:

$$
\mu = E\lbrack X \rbrack = \frac{1}{\lambda}.
$$

La varianza se expresa como:

$$
\sigma^2 = \frac{1}{\lambda^2}.
$$

#### Distribución uniforme (continua)

La distribución uniforme se caracteriza porque todos los valores dentro de un intervalo
$\lbrack a, b \rbrack$ tienen la misma probabilidad de ocurrir. Se emplea en la
generación de números aleatorios, simulaciones y situaciones en las que no hay
preferencia por ningún valor específico dentro de un rango determinado.

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
\mu = E\lbrack X \rbrack = \frac{a + b}{2}.
$$

Y su varianza se expresa como:

$$
\sigma^2 = \frac{(b-a)^2}{12}.
$$

!!! tip "¿De dónde sale el 12 de la varianza de la distribución uniforme?"

    La varianza de una variable aleatoria continua $X$ se define como:

    $$
    \text{Var}(X) = E\lbrack X^2 \rbrack - (E\lbrack X \rbrack)^2.
    $$

    Para una distribución uniforme continua $U(a, b)$, la esperanza, la cual coincide
    con la media, se obtiene con la fórmula:

    $$
    E\lbrack X \rbrack = \frac{a+b}{2}.
    $$

    Por tanto, el cálculo de $E\lbrack X^2 \rbrack$ se realiza como:

    $$
    E\lbrack X^2 \rbrack = \int_a^b x^2 \cdot f(x) \, dx = \int_a^b x^2 \cdot
    \frac{1}{b-a} \, dx.
    $$

    Resolviendo la integral:

    $$
    E\lbrack X^2 \rbrack = \frac{1}{b-a} \int_a^b x^2 \, dx = \frac{1}{b-a} \cdot
    \left\lbrack \frac{x^3}{3} \right\rbrack_{a}^{b}.
    $$

    Evaluando de $a$ a $b$:

    $$
    E\lbrack X^2 \rbrack = \frac{1}{b-a} \left\lbrack \frac{b^3}{3} - \frac{a^3}{3}
    \right\rbrack = \frac{b^3 - a^3}{3(b-a)}.
    $$

    Ahora, usando la fórmula de la varianza y sustituyendo los valores obtenemos:

    $$
    \text{Var}(X) = E\lbrack X^2 \rbrack - (E\lbrack X \rbrack)^2 = \frac{b^3 -
    a^3}{3(b-a)} - \left(\frac{a+b}{2} \right)^2.
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

### Esperanza, varianza y momentos de una variable aleatoria

La esperanza matemática se definió para variables discretas y continuas en la sección de
la distribución exponencial. Su definición se generaliza a cualquier función real $g$ de
una variable aleatoria $X$. En el caso discreto, con soporte $S_X$:

$$
E\lbrack g(X) \rbrack = \sum_{x_i \in S_X} g(x_i) \, P(X = x_i),
$$

y en el caso continuo, con densidad $f$:

$$
E\lbrack g(X) \rbrack = \int_{-\infty}^{\infty} g(x) f(x) \, dx.
$$

Cuando el soporte discreto es infinito numerable, es necesario que la serie converja
absolutamente, es decir, $\sum_{x_i \in S_X} |g(x_i)| \, P(X = x_i) < \infty$. Para
constantes $k$, $a$ y $b$ y variables aleatorias $X$ e $Y$, la esperanza cumple las
siguientes propiedades:

- $E\lbrack k \rbrack = k$.
- $E\lbrack aX + b \rbrack = a E\lbrack X \rbrack + b$.
- $E\lbrack aX + bY \rbrack = a E\lbrack X \rbrack + b E\lbrack Y \rbrack$.
- Si $X$ e $Y$ son independientes, $E\lbrack XY \rbrack = E\lbrack X \rbrack E\lbrack Y
  \rbrack$.

La media de la variable es $\mu = E\lbrack X \rbrack$, el análogo teórico de $\bar{x}$.
El **momento de orden $r$ respecto al punto $a$** es $M_r(a) = E\lbrack (X - a)^r
\rbrack$. Como en estadística descriptiva, el **momento ordinario** de orden $r$
corresponde a $a = 0$ y el **momento central** a $a = E\lbrack X \rbrack$:

$$
m_r = E\lbrack X^r \rbrack, \qquad \mu_r = E\lbrack (X - E\lbrack X \rbrack)^r \rbrack.
$$

La varianza es el momento central de orden 2 y la desviación típica su raíz cuadrada
positiva:

$$
\text{Var}(X) = \mu_2 = E\lbrack (X - E\lbrack X \rbrack)^2 \rbrack =
E\lbrack X^2 \rbrack - E\lbrack X \rbrack^2 = m_2 - \mu^2, \qquad
\sigma_X = +\sqrt{\text{Var}(X)}.
$$

A partir de la distribución se definen los mismos parámetros que en una muestra:

- **Tendencia central**: La media $E\lbrack X \rbrack$, la moda como la abscisa donde la
  función de masa o de densidad alcanza su máximo, la mediana como el valor $x$ con
  $F(x) = 0.5$ y los cuantiles como los valores con $F(x) = c$. Los cuartiles
  corresponden a $c = 0.25$, $0.5$ y $0.75$.
- **Dispersión**: La varianza, la desviación típica y el coeficiente de variación $CV =
  \sigma_X / |\mu|$.
- **Forma**: Los coeficientes de Fisher, el sesgo $g_1 = \mu_3 / \sigma^3$ y la curtosis
  $g_2 = \mu_4 / \sigma^4 - 3$.

???+ example "Esperanza y varianza de una variable discreta"

    Sea $X$ el número de caras al lanzar dos monedas equilibradas, con $P(X = 0) =
    0.25$, $P(X = 1) = 0.5$ y $P(X = 2) = 0.25$. Entonces $E\lbrack X \rbrack = 0 \cdot
    0.25 + 1 \cdot 0.5 + 2 \cdot 0.25 = 1$ y $E\lbrack X^2 \rbrack = 0 + 0.5 + 4 \cdot
    0.25 = 1.5$, de modo que $\text{Var}(X) = 1.5 - 1^2 = 0.5$. Este valor coincide con
    la varianza $npq = 2 \cdot 0.5 \cdot 0.5$ de la distribución binomial $B(2, 0.5)$,
    que se obtiene en la sección siguiente.

### Otras distribuciones discretas

Además de la binomial y de la de Poisson, el aprendizaje automático utiliza los modelos
discretos que se construyen a partir de ensayos de Bernoulli. Son los que describen la
salida de un clasificador binario o multiclase y las variantes del clasificador Naïve
Bayes.

#### Distribución de Bernoulli y propiedades de la binomial

En un experimento con dos resultados, $A$ y $\overline{A}$, de probabilidades $P(A) = p$
y $P(\overline{A}) = 1 - p = q$, la variable $X$ que vale 1 si ocurre $A$ y 0 en caso
contrario sigue una **distribución de Bernoulli**, $X \sim Ber(p)$. Su función de
probabilidad es $P(1) = p$ y $P(0) = q$, con $p + q = 1$, y sus parámetros son:

$$
\mu = E\lbrack X \rbrack = p, \qquad \text{Var}(X) = pq, \qquad \sigma_X = \sqrt{pq}.
$$

La distribución binomial que ya se ha presentado es el número de veces que ocurre $A$ en
$n$ pruebas de Bernoulli sucesivas e independientes, $X \sim B(n, p)$. Sus parámetros
son:

$$
\mu = E\lbrack X \rbrack = np, \qquad \text{Var}(X) = npq, \qquad \sigma_X = \sqrt{npq}.
$$

La Bernoulli es el caso particular $Ber(p) = B(1, p)$.

#### Distribución multinomial

La **distribución multinomial** generaliza la binomial a $K$ sucesos excluyentes $A_1,
\ldots, A_K$ de probabilidades $p_1, \ldots, p_K$ con $p_1 + \cdots + p_K = 1$. Se
realizan $n$ pruebas independientes y $X_i$ es el número de veces que ocurre $A_i$. Para
el vector $\mathbf{X} = (X_1, \ldots, X_K)$, con $n_1 + n_2 + \cdots + n_K = n$:

$$
P(X_1 = n_1, \ldots, X_K = n_K) = \frac{n!}{n_1! \, n_2! \cdots n_K!} \,
p_1^{n_1} p_2^{n_2} \cdots p_K^{n_K}.
$$

Con una única prueba, $n = 1$, se obtiene la **distribución categórica**, que asigna la
probabilidad $p_k$ a cada una de las $K$ clases. Es la distribución que representa la
salida _softmax_ de un clasificador multiclase.

???+ example "Distribución multinomial"

    Se lanzan $n = 6$ pruebas con tres posibles resultados de probabilidades
    $p = (0.5, 0.3, 0.2)$. La probabilidad de obtener el primero tres veces, el segundo
    dos y el tercero una es:

    $$
    P(3, 2, 1) = \frac{6!}{3! \, 2! \, 1!} \cdot 0.5^3 \cdot 0.3^2 \cdot 0.2^1 =
    60 \cdot 0.125 \cdot 0.09 \cdot 0.2 = 0.135.
    $$

#### Propiedades de la distribución de Poisson

La distribución de Poisson presentada anteriormente se escribe $X \sim P(\lambda)$ y
tiene el conjunto $\mathbb{N} \cup \{0\}$ como soporte. Su media y su varianza coinciden
con el parámetro:

$$
\mu = E\lbrack X \rbrack = \lambda, \qquad \text{Var}(X) = \lambda, \qquad
\sigma_X = \sqrt{\lambda}.
$$

Esta igualdad entre media y varianza sirve como diagnóstico, ya que unos datos de
recuento con una varianza muy superior a su media no se ajustan bien a una Poisson.
Cuando el número de ensayos es grande y la probabilidad de éxito es pequeña, la binomial
se aproxima por una Poisson de parámetro $\lambda = np$.

### Distribución t de Student

Sean $Z$ una variable $N(0, 1)$ y $\chi_n^2$ la suma de los cuadrados de $n$ variables
normales estándar independientes de $Z$, que sigue una distribución **chi-cuadrado** con
$n$ **grados de libertad**. La variable:

$$
t = \frac{Z}{\sqrt{\chi_n^2 / n}}
$$

sigue una **distribución t de Student** con $n$ grados de libertad. Es simétrica y
centrada en 0 como la normal estándar, pero con colas más pesadas, de modo que asigna
más probabilidad a los valores alejados del centro. Para $n > 30$ se aproxima por una
$N(0, 1)$. Se utiliza cuando la desviación típica poblacional es desconocida y se estima
con la muestral. Con un grado de libertad, sus colas pesadas son las que aprovecha la
técnica t-SNE de
[reducción de dimensionalidad](../02_machine_learning/section_5_dimensionality_reduction.md).

### Propiedades de la distribución normal

La distribución normal $N(\mu, \sigma)$ alcanza su máximo en $x = \mu$ y tiene dos
puntos de inflexión en $x = \mu - \sigma$ y $x = \mu + \sigma$. Es simétrica respecto a
$x = \mu$, de modo que media, moda y mediana coinciden, y su varianza es $\sigma^2$.

La **tipificación** transforma una variable normal en una normal estándar. Si $X \sim
N(\mu, \sigma)$, entonces:

$$
Z = \frac{X - \mu}{\sigma} \sim N(0, 1).
$$

Esta operación permite calcular cualquier probabilidad normal con la función de
distribución de la normal estándar. Es la misma estandarización que se aplica a las
características de entrada de un modelo de aprendizaje automático.

???+ example "Tipificación y probabilidad normal"

    Si $X \sim N(170, 10)$, la probabilidad de que $X$ esté entre 160 y 185 se
    calcula tipificando los extremos, $z_1 = (160 - 170)/10 = -1$ y
    $z_2 = (185 - 170)/10 = 1.5$:

    $$
    P(160 < X \leq 185) = \Phi(1.5) - \Phi(-1) = 0.7745.
    $$

    El cálculo con la biblioteca estándar de Python, incluyendo el cuantil que deja a su
    izquierda una probabilidad de 0.975, es el siguiente.

    ```python linenums="1"
    from statistics import NormalDist

    # Probabilidad del intervalo con la CDF de N(170, 10)
    nd = NormalDist(170, 10)
    print(f"{nd.cdf(185) - nd.cdf(160):.4f}")

    # Cuantil de la normal estándar que deja 0.975 a su izquierda
    print(f"{NormalDist().inv_cdf(0.975):.2f}")
    ```

    ```plaintext title="Expected output"
    0.7745
    1.96
    ```

### Teorema central del límite

El **teorema central del límite** explica por qué la distribución normal aparece con
tanta frecuencia. Sea $\{X_n\}$ una sucesión de variables aleatorias independientes e
idénticamente distribuidas con media $\mu$ y desviación típica $\sigma$ finitas. Para la
suma $S_n = X_1 + X_2 + \cdots + X_n$ se sabe que $E\lbrack S_n \rbrack = n\mu$ y
$\text{Var}(S_n) = n\sigma^2$. Entonces, cuando $n$ crece, la suma tipificada converge
en distribución a una normal estándar:

$$
Z_n = \frac{S_n - n\mu}{\sigma \sqrt{n}} \xrightarrow{d} N(0, 1).
$$

De forma equivalente, la media muestral tiene una distribución aproximadamente normal,
$\bar{X} \sim N(\mu, \sigma/\sqrt{n})$, sea cual sea la distribución de partida. Su
desviación típica $\sigma/\sqrt{n}$ decrece con el tamaño de la muestra, lo que
justifica que la confianza aumente al disponer de más datos.

???+ example "Teorema central del límite por simulación"

    Se generan 100000 muestras de tamaño $n = 30$ de una distribución uniforme
    $U(0, 1)$, con $\mu = 0.5$ y $\sigma = \sqrt{1/12}$. El teorema predice que las
    medias se distribuyen como una $N(0.5, \sqrt{1/12}/\sqrt{30})$, cuya desviación
    típica es 0.0527, y que alrededor del 68% de ellas queda a menos de una desviación
    típica.

    ```python linenums="1"
    import numpy as np

    rng = np.random.default_rng(42)

    # 100000 muestras de tamaño 30 de una uniforme U(0, 1)
    n, repeticiones = 30, 100_000
    medias = rng.uniform(0, 1, size=(repeticiones, n)).mean(axis=1)

    # Media y desviación típica teóricas de la media muestral
    mu = 0.5
    sigma_media = np.sqrt(1 / 12) / np.sqrt(n)

    # Proporción de medias dentro de una desviación típica de mu
    dentro = np.mean(np.abs(medias - mu) < sigma_media)

    print(f"media de las medias={medias.mean():.4f}")
    print(f"desviación observada={medias.std():.4f} teórica={sigma_media:.4f}")
    print(f"proporción dentro de 1 sigma={dentro:.3f}")
    ```

    ```plaintext title="Expected output"
    media de las medias=0.4999
    desviación observada=0.0525 teórica=0.0527
    proporción dentro de 1 sigma=0.681
    ```

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

#### Variables aleatorias bidimensionales

Las reglas anteriores se concretan para dos variables aleatorias $X$ e $Y$ definidas
sobre el mismo espacio de probabilidad, que forman una **variable aleatoria
bidimensional** con función de distribución $F(x, y) = P(X \leq x, Y \leq y)$. En el
caso discreto, la función de probabilidad conjunta $p_{ij} = P(X = x_i, Y = y_j)$ se
organiza en una tabla cuyas sumas por filas y por columnas son las marginales. En el
caso continuo, la probabilidad de un rectángulo es la integral de la **función de
densidad conjunta** $f(x, y)$ sobre él:

$$
P(a \leq X \leq b, \, c \leq Y \leq d) = \int_{c}^{d} \int_{a}^{b} f(x, y) \, dx \, dy,
$$

y las densidades marginales $f_X$, $f_Y$ y condicionadas se obtienen con las reglas de
la suma y del producto. Con $\mu_X = E\lbrack X \rbrack$ y $\mu_Y = E\lbrack Y \rbrack$,
el momento central $\mu_{11} = E\lbrack (X - \mu_X)(Y - \mu_Y) \rbrack$ es la
**covarianza**:

$$
\sigma_{xy} = \text{cov}(X, Y)
= E\lbrack XY \rbrack - E\lbrack X \rbrack E\lbrack Y \rbrack.
$$

$X$ e $Y$ son **independientes** si y solo si la densidad conjunta, o la función de
probabilidad en el caso discreto, es el producto de las marginales para todo par de
valores, $f(x, y) = f_X(x) \, f_Y(y)$, y en ese caso $E\lbrack XY \rbrack = E\lbrack X
\rbrack E\lbrack Y \rbrack$ y $\text{cov}(X, Y) = 0$. Es el análogo teórico de la
condición $f_{ij} = f_{i\cdot} f_{\cdot j}$ de las frecuencias, que en una muestra
grande actúan como estimación de las probabilidades $p_{ij}$.

## P-valores

Los **p-valores** (_p-values_) son números comprendidos entre 0 y 1 que cuantifican la
confianza con la que se puede afirmar que una opción A es diferente de una opción B. Un
p-valor cercano a 0 indica que existe evidencia estadística suficiente para considerar
que A es distinto de B.

En la práctica, se suele utilizar un **umbral de significancia** de 0.05 para determinar
si la diferencia es estadísticamente significativa. Sin embargo, puede darse el caso de
obtener un p-valor pequeño cuando en realidad no existe diferencia, lo que se conoce
como un **falso positivo**. Un umbral de 0.05 implica que aproximadamente el 5% de los
experimentos generará un p-valor menor a 0.05 por azar. Si se requiere mayor seguridad,
se pueden emplear umbrales más bajos. Por ejemplo, en medicina se utilizan umbrales como
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

## Evaluación del error

Los modelos de aprendizaje automático requieren datos de entrenamiento para establecer
relaciones entre las variables y construir una función que se aproxime a la distribución
de los datos. Un aspecto fundamental en este proceso es la evaluación del desempeño del
modelo, lo cual se realiza mediante métricas estadísticas.

### Suma de los cuadrados de los residuales (SSR)

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

### Error cuadrático medio (MSE)

El **Error Cuadrático Medio** (_Mean Squared Error_, MSE) se obtiene dividiendo la SSR
entre el número total de muestras. Su objetivo es promediar la magnitud del error para
normalizarlo con respecto al tamaño del conjunto de datos. Se define como:

$$
\text{MSE} = \frac{1}{n} \sum_{i=1}^{n} (y_i - \hat{y}_i)^2.
$$

A pesar de que el MSE proporciona una medida más interpretable del error, sigue
dependiendo de la escala de los datos. Para eliminar esta dependencia, se emplea el
**Coeficiente de Determinación ($R^2$)**.

### Coeficiente de determinación

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

El coeficiente $R^2$ se emplea en problemas de regresión sobre datos continuos. En
términos de varianzas, $R^2 = 1 - V_r / \text{Var}(y)$, donde $V_r$ es la varianza
residual del modelo. Esta relación se desarrolla en la sección de regresión y
correlación.

!!! note "Relación entre R² y correlación de Pearson"

    El coeficiente $R^2$ equivale al cuadrado del coeficiente de correlación de Pearson
    solo en el caso de la regresión lineal simple.

El siguiente capítulo de la serie, dedicado a los
[fundamentos matemáticos](section_2_deep_learning_math.md), introduce los tensores y el
álgebra lineal sobre los que se construyen los modelos de aprendizaje profundo.
