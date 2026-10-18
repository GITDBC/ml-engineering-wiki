---
authors: Daniel Bazo Correa
description: Modelos de aprendizaje supervisado.
title: Modelos supervisados
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Una vez comprendido el concepto de modelo de aprendizaje automático, donde se utilizan
datos para modelar su distribución, analizar relaciones y extraer conocimiento, es
posible aplicar estos modelos para realizar tareas como clasificación de nuevos datos,
predicción de valores y otras aplicaciones. A continuación, se presentan algunos de los
métodos más utilizados.

!!! tip "Enfoque práctico para la selección de modelos"

    A pesar del auge de los modelos de lenguaje basados en arquitecturas de **aprendizaje profundo (_Deep Learning_)**, su aplicación sigue siendo limitada en ciertos contextos debido a la gran cantidad de datos y capacidad de cómputo que requieren, así como a la necesidad de explicabilidad en sectores específicos. Por ello, los métodos tradicionales siguen desempeñando un papel fundamental, especialmente en el análisis de datos **tabulares**, los cuales representan la mayoría de los datos empresariales.

    Es recomendable iniciar con modelos más sencillos para comprender los resultados y evaluar su utilidad en función de los objetivos del análisis. A partir de esta base, y considerando factores como el tiempo y los recursos disponibles, se puede optar por soluciones más complejas que ofrezcan un mayor retorno de inversión (ROI).

## Naïve Bayes

El clasificador **Naïve Bayes** es un modelo probabilístico basado en el **Teorema de
Bayes** que asume independencia condicional entre las características dadas la clase. A
pesar de que esta suposición de independencia rara vez se cumple en la práctica, el
modelo ofrece un rendimiento sorprendentemente bueno en muchas aplicaciones,
especialmente en clasificación de texto y filtrado de spam.

El Teorema de Bayes permite calcular la probabilidad posterior de una clase $C_k$ dado
un vector de características $\mathbf{x}$:

$$
P(C_k | \mathbf{x}) = \frac{P(\mathbf{x} | C_k) \cdot P(C_k)}{P(\mathbf{x})}.
$$

Bajo la suposición de independencia condicional, la verosimilitud se descompone como el
producto de las probabilidades individuales de cada característica:

$$
P(\mathbf{x} | C_k) = \prod_{i=1}^{n} P(x_i | C_k).
$$

El clasificador asigna a cada nueva observación la clase con mayor probabilidad
posterior. Existen diferentes variantes del modelo según la distribución asumida para
las características: **Gaussiano** (para datos continuos con distribución normal),
**Multinomial** (para conteos de frecuencias, como en clasificación de texto) y
**Bernoulli** (para características binarias).

## Árboles de decisión

Los **árboles de decisión** son modelos que realizan predicciones mediante una serie de
reglas de decisión organizadas en una estructura jerárquica en forma de árbol. Cada nodo
interno del árbol representa una condición sobre una característica del conjunto de
datos, cada rama corresponde al resultado de esa condición y cada nodo hoja contiene la
predicción final (una clase en clasificación o un valor numérico en regresión).

El proceso de construcción del árbol consiste en seleccionar, en cada nodo, la
característica y el umbral que mejor separan los datos según un criterio de impureza,
como el **índice de Gini** o la **entropía** en clasificación, o la reducción de la
varianza en regresión. Este proceso se repite recursivamente hasta que se cumple algún
criterio de parada, como alcanzar una profundidad máxima o un número mínimo de muestras
por nodo.

Los árboles de decisión son fácilmente interpretables y eficientes en el ajuste a los
datos de entrenamiento. Sin embargo, presentan una alta varianza que los hace propensos
al sobreajuste, especialmente cuando se permite que el árbol crezca sin restricciones.

### Medición de la pureza mediante la entropía

El criterio de impureza determina qué división resulta preferible en cada nodo. La
**entropía** mide esa impureza en función de $p_1$, la proporción de ejemplos de la
clase positiva presentes en el nodo. Dado que $p_0 = 1 - p_1$, la expresión se reduce a
una única variable:

$$
H(p_1) = -p_1 \log_2(p_1) - (1 - p_1) \log_2(1 - p_1)
$$

La función parte de cero cuando $p_1 = 0$, alcanza su valor máximo de 1 cuando $p_1 =
0{,}5$, y vuelve a cero cuando $p_1 = 1$. La lectura es inmediata: un nodo con muestras
de una sola clase tiene entropía nula, mientras que un nodo con las clases perfectamente
repartidas presenta la máxima incertidumbre posible. Puesto que $\log(0)$ no está
definido, se adopta por convención $0 \cdot \log(0) = 0$.

Para un nodo que contiene las etiquetas `1 1 1 1 1 0`, donde 1 representa una clase y 0
la otra, las proporciones son $p_1 = 5/6 \approx 0{,}83$ y $p_0 = 1/6$, lo que arroja
una entropía aproximada de $0{,}6$.

### Ganancia de información

La **ganancia de información** cuantifica la reducción de incertidumbre que produce una
división. Se calcula restando a la entropía del nodo padre la media ponderada de las
entropías de los nodos hijos, donde los pesos $w$ son las fracciones de muestras que
caen en cada rama:

$$
H\left(p_1^{\text{raíz}}\right) - \left(w^{\text{izq}}
H\left(p_1^{\text{izq}}\right) + w^{\text{der}} H\left(p_1^{\text{der}}\right)\right)
$$

Esta magnitud permite comparar divisiones candidatas y seleccionar la que más mejora la
pureza. Sirve además como criterio para elegir el umbral en el caso de características
continuas. Cuando las características son categóricas se recurre a la codificación
**_one-hot encoding_** para poder aplicar el mismo procedimiento.

???+ example "Comparación de divisiones candidatas"

    Se parte de un nodo raíz con diez muestras repartidas a partes iguales entre dos
    clases, de forma que $p_1 = 0{,}5$ y por tanto $H(p_1) = 1$, el valor de
    incertidumbre máxima. Se evalúan tres características candidatas para la primera
    división.

    La primera división reparte las muestras en dos grupos de cinco, con
    $p_1 = 4/5 = 0{,}8$ en una rama y $p_1 = 1/5 = 0{,}2$ en la otra. Ambas entropías
    valen $0{,}72$, lo que da una ganancia de información de
    $1 - (0{,}5 \cdot 0{,}72 + 0{,}5 \cdot 0{,}72) = 0{,}28$.

    La segunda división genera grupos de siete y tres muestras, con
    $p_1 = 4/7 \approx 0{,}57$ y $p_1 = 1/3 \approx 0{,}33$. Las entropías
    correspondientes son $0{,}99$ y $0{,}92$, con una ganancia de apenas
    $1 - (0{,}7 \cdot 0{,}99 + 0{,}3 \cdot 0{,}92) = 0{,}03$.

    La tercera división produce grupos de cuatro y seis muestras, con
    $p_1 = 3/4 = 0{,}75$ y $p_1 = 1/3 \approx 0{,}33$. Las entropías son $0{,}81$ y
    $0{,}92$, lo que da una ganancia de
    $1 - (0{,}4 \cdot 0{,}81 + 0{,}6 \cdot 0{,}92) = 0{,}12$.

    La primera característica es la preferible, puesto que logra la mayor reducción de
    incertidumbre.

### Criterios de parada

Las divisiones se detienen cuando un nodo contiene muestras de una sola clase, puesto
que ya es completamente puro, o cuando la pureza no mejora con ninguna de las divisiones
disponibles. A estos criterios se añaden en la práctica las restricciones de profundidad
máxima y número mínimo de muestras por nodo mencionadas anteriormente.

Conviene tener presentes los puntos fuertes y las limitaciones de estos modelos. Los
árboles de decisión funcionan bien sobre datos tabulares, es decir, datos estructurados,
y resultan rápidos de entrenar y de evaluar. Cuando son de tamaño reducido mantienen un
grado razonable de interpretabilidad. En cambio, no son adecuados para datos no
estructurados como imágenes o audio, donde las arquitecturas de aprendizaje profundo
resultan claramente superiores.

### Random Forest

**Random Forest** es una técnica de ensamblado basada en árboles de decisión que mejora
la capacidad de generalización de estos últimos. Aunque los árboles de decisión clásicos
son fácilmente interpretables y eficientes en el ajuste a los datos de entrenamiento,
presentan una alta varianza que los hace poco robustos frente a nuevas muestras. Random
Forest soluciona esta limitación mediante un enfoque basado en el aprendizaje conjunto
de múltiples árboles de decisión.

El proceso de construcción de un modelo Random Forest se compone de tres etapas
fundamentales. En primer lugar, se generan múltiples subconjuntos de entrenamiento
mediante **muestreo aleatorio con reemplazo** a partir del conjunto de datos original,
un procedimiento conocido como _bootstrap sampling_. Como consecuencia, algunas
observaciones pueden repetirse dentro de un subconjunto, mientras que otras no son
seleccionadas. En segundo lugar, cada subconjunto generado se utiliza para entrenar un
árbol de decisión independiente. A diferencia del procedimiento habitual, en cada
división del árbol se selecciona aleatoriamente un subconjunto de características en
lugar de utilizar todas, lo que introduce diversidad entre los árboles y reduce la
correlación entre ellos. En tercer lugar, las predicciones de todos los árboles se
combinan mediante un proceso denominado **_bagging_** (_bootstrap aggregating_), que
consiste en promediar las predicciones (para regresión) o realizar una votación
mayoritaria (para clasificación).

Durante el entrenamiento, algunas muestras no se utilizan en la construcción de un árbol
determinado. Estas observaciones, conocidas como _out-of-bag samples_, se emplean para
evaluar el rendimiento del modelo de manera interna, sin necesidad de un conjunto de
validación adicional. Al calcular el porcentaje de muestras _out-of-bag_ clasificadas
incorrectamente por el conjunto de árboles, se obtiene el llamado _out-of-bag error_,
que actúa como una estimación fiable del error de generalización.

El número de características consideradas en cada división puede ajustarse como
hiperparámetro del modelo. Este control permite optimizar el equilibrio entre sesgo y
varianza, mejorando la precisión y robustez del Random Forest frente a los árboles de
decisión individuales. Partiendo de $n$ características disponibles, en cada división se
toma un subconjunto aleatorio de $k < n$ de ellas, y una elección habitual por defecto
es $k = \sqrt{n}$.

## Máquina de vectores de soporte

La **Máquina de Vectores de Soporte** (_Support Vector Machine_, SVM) es un algoritmo de
aprendizaje supervisado utilizado tanto para clasificación como para regresión. Su
principio fundamental consiste en encontrar el **hiperplano** que mejor separa las
clases en el espacio de características, maximizando el **margen**, es decir, la
distancia entre el hiperplano y los puntos de datos más cercanos de cada clase,
denominados **vectores de soporte**.

Un hiperplano es un subespacio de dimensión inmediatamente inferior a la del espacio que
lo contiene, de modo que en una dimensión es un punto, en dos dimensiones una recta y en
tres dimensiones una superficie que divide el espacio en dos partes. Esta construcción
geométrica se desarrolla con mayor detalle en el capítulo de
[fundamentos matemáticos](../01_mathematics/section_2_deep_learning_math.md).

La formulación parte de tres hiperplanos paralelos. El hiperplano central $H_0$
constituye la frontera de decisión y satisface:

$$
\mathbf{w} \cdot \mathbf{x} + b = 0
$$

donde $\mathbf{w}$ es el vector de pesos, perpendicular a los tres hiperplanos,
$\mathbf{x}$ el vector de características y $b$ el término de sesgo. El producto
$\mathbf{w} \cdot \mathbf{x}$ es el producto interno, es decir, la suma de los productos
de las componentes correspondientes. Una muestra se clasifica como positiva cuando
$\mathbf{w} \cdot \mathbf{x} + b \geq 0$.

Los dos hiperplanos restantes delimitan el margen y se sitúan a ambos lados del central,
definidos por un valor de corte $K$:

$$
\mathbf{w} \cdot \mathbf{x} + b = K \qquad \mathbf{w} \cdot \mathbf{x} + b = -K
$$

La distancia de la proyección de un punto sobre la dirección del vector de pesos se
obtiene normalizando el producto interno por la norma del vector:

$$
\frac{\mathbf{w} \cdot \mathbf{x}}{\|\mathbf{w}\|}
$$

El problema de optimización consiste precisamente en maximizar la anchura de ese margen,
lo que de forma equivalente se plantea como la minimización de $\frac{1}{2}\mathbf{w}
\cdot \mathbf{w}$ sujeta a las restricciones de clasificación correcta.

En problemas donde los datos no son linealmente separables, las SVM emplean el
denominado **truco del kernel** (_kernel trick_), que consiste en proyectar los datos a
un espacio de mayor dimensionalidad donde sí resultan separables linealmente. Entre los
kernels más utilizados se encuentran el lineal, el polinómico y el de función de base
radial (RBF). El caso prototípico de datos no separables linealmente en dos dimensiones
es el de una clase agrupada en el centro y rodeada por la otra, configuración que
ninguna recta puede separar pero que sí admite separación mediante una frontera circular
en el espacio transformado.

La formulación matemática de la SVM busca minimizar una función objetivo que equilibra
la maximización del margen con la penalización de las clasificaciones erróneas,
controlada por un hiperparámetro de regularización $C$. Un valor alto de $C$ prioriza la
clasificación correcta de todos los puntos (riesgo de sobreajuste), mientras que un
valor bajo permite mayor tolerancia a errores (mayor generalización).

## XGBoost

**XGBoost** (_Extreme Gradient Boosting_) es un algoritmo de aprendizaje automático
basado en el ensamblado de árboles de decisión mediante la técnica de **_gradient
boosting_**. A diferencia de Random Forest, donde los árboles se entrenan de forma
independiente, en XGBoost cada nuevo árbol se construye para corregir los errores
cometidos por los árboles anteriores, lo que permite mejorar progresivamente el
rendimiento del modelo.

El algoritmo utiliza por defecto el **Error Cuadrático Medio (MSE)** como función de
pérdida para problemas de regresión. El proceso de entrenamiento se basa en la
optimización de una función objetivo que combina la función de pérdida con un término de
regularización para controlar la complejidad del modelo y prevenir el sobreajuste.

Para determinar las divisiones óptimas en cada nodo del árbol, XGBoost calcula una
métrica denominada **similaridad** (_similarity score_), que se define como:

$$
\text{Similarity} = \frac{G^2}{H + \lambda},
$$

donde $G$ es la suma de los gradientes (primeras derivadas de la función de pérdida),
$H$ es la suma de las hessianas (segundas derivadas de la función de pérdida) y
$\lambda$ es el parámetro de regularización. La **ganancia** (_gain_) de una división se
calcula como la diferencia entre la suma de las similaridades de los nodos hijos y la
similaridad del nodo padre:

$$
\text{Gain} = \text{Similarity}_{\text{izq}} + \text{Similarity}_{\text{der}} - \text{Similarity}_{\text{padre}}.
$$

Se selecciona la división con mayor ganancia en cada paso. Para determinar los puntos de
corte candidatos, XGBoost puede utilizar un enfoque basado en **cuantiles**
(_quantile-based split finding_), que permite obtener rangos de valores representativos
(por ejemplo, los percentiles 0.1, 0.5 y 0.9) para evaluar las divisiones de forma
eficiente sin necesidad de probar todos los valores posibles.

XGBoost también soporta la **regresión por cuantiles** (_quantile regression_), que en
lugar de predecir un único valor, estima diferentes percentiles de la distribución
condicional de la variable objetivo. La función de pérdida para la regresión por
cuantiles se define como:

$$
L_q(y, \hat{y}) = \begin{cases} q \cdot (y - \hat{y}) & \text{si } y > \hat{y} \\ (1 - q) \cdot (\hat{y} - y) & \text{si } y < \hat{y} \end{cases},
$$

donde $q$ es el cuantil deseado. Esta función de pérdida permite obtener intervalos de
predicción y estimar la incertidumbre asociada a las predicciones del modelo.
