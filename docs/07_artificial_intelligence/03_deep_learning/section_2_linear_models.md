---
authors: Daniel Bazo Correa
description: Regresión lineal y logística en el contexto del aprendizaje profundo.
title: Regresión lineal y logística
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Los modelos de regresión lineal y logística constituyen la base conceptual del
aprendizaje profundo. También se conocen como modelos diferenciables, ya que su
estructura está compuesta por transformaciones lineales seguidas de funciones no
lineales que son derivables, lo que permite aplicar cálculo diferencial para optimizar
sus parámetros mediante métodos basados en gradientes. Este principio es el fundamento
de todas las arquitecturas de redes neuronales modernas.

El entrenamiento de una neurona, o de una red neuronal, se apoya en dos procesos
fundamentales: la **propagación hacia adelante (_forward propagation_)** y la
**propagación hacia atrás (_backpropagation_)**.

La propagación hacia adelante consiste en calcular la predicción del modelo a partir de
los datos de entrada. En este proceso, los datos ingresan por la capa de entrada y
atraviesan las distintas capas de la red, aplicando sucesivas combinaciones lineales y
no lineales hasta obtener una salida numérica. El resultado que produce el modelo antes
de aplicar una función de activación final se conoce como **_logit_**. Este valor
representa una proyección numérica de los datos de entrada en el espacio interno del
modelo, resultado de las transformaciones que la red realiza. Posteriormente, el modelo
compara esta salida con el valor real esperado y calcula una tasa de error o función de
pérdida, la cual mide qué tan precisa ha sido la representación aprendida.

Por otro lado, la propagación hacia atrás es el proceso mediante el cual el modelo
ajusta sus parámetros internos con el objetivo de minimizar el error obtenido en la
propagación hacia adelante. En este proceso, los gradientes (las derivadas parciales de
la función de pérdida respecto a cada parámetro) se propagan desde la salida hasta las
capas iniciales del modelo. Dichos gradientes indican cómo deben modificarse los pesos y
sesgos para reducir el error en las siguientes iteraciones, permitiendo así un
aprendizaje progresivo y dirigido por el descenso del gradiente.

Un modelo lineal puede expresarse matemáticamente como:

$$
\hat{y} = \mathbf{w}^\top \mathbf{x} + b,
$$

donde $\mathbf{x} \in \mathbb{R}^n$ es el vector de entrada,
$\mathbf{w} \in \mathbb{R}^n$ representa el vector de pesos del modelo,
$b \in \mathbb{R}$ es el sesgo o término independiente, y $\hat{y} \in \mathbb{R}$ es la
salida predicha por el modelo. Cuando la salida $\hat{y}$ no está restringida a un rango
específico, el modelo se utiliza en tareas de regresión, donde el objetivo es predecir
valores continuos. En este contexto, la salida puede tomar cualquier valor real,
positivo o negativo.

Sin embargo, cuando la salida está asociada a un conjunto discreto de clases
$\mathcal{C} = \{1, 2, \dots, M\}$, el modelo aborda un problema de clasificación. En
estos casos, la representación numérica (_logits_) generada por el modelo se transforma
en probabilidades mediante una función no lineal, generalmente una función sigmoide para
clasificación binaria o una función _Softmax_ para clasificación multiclase. En la
clasificación binaria ($M = 2$), el modelo aprende a distinguir entre dos posibles
categorías (por ejemplo, "positivo" y "negativo", o "clase 0" y "clase 1"). En cambio,
en los problemas multiclase, el modelo puede asignar cada entrada a una de varias
categorías posibles, como en la clasificación de imágenes por tipo de objeto o raza de
perro. Además, existen escenarios de clasificación multietiqueta, donde una misma
entrada puede pertenecer simultáneamente a varias clases. Un ejemplo típico se da en los
sistemas de visión artificial para conducción autónoma, en los cuales una sola imagen
puede contener múltiples elementos etiquetables, como peatones, vehículos y señales de
tráfico.

En los modelos diferenciables, la estructura general se puede describir como una
composición de funciones lineales y no lineales:

$$
f(\mathbf{x}) = f_{L} \circ f_{L-1} \circ \dots \circ f_1 (\mathbf{x}),
$$

donde cada capa aplica una transformación de la forma:

$$
f_{\ell}(\mathbf{x}) = \sigma_{\ell}(\mathbf{W}_{\ell}\mathbf{x} + \mathbf{b}_{\ell}).
$$

En esta formulación, $\mathbf{W}_\ell$ y $\mathbf{b}_\ell$ representan los pesos y
sesgos de la capa $\ell$, respectivamente, mientras que $\sigma_{\ell}(\cdot)$ es una
función de activación diferenciable. Esta función introduce no linealidad al modelo y
permite restringir el rango de valores de salida, lo que dota al modelo de la capacidad
de aproximar relaciones complejas y no lineales entre los datos de entrada y salida.

## Clasificación mediante regresión logística

En lugar de desarrollar manualmente una aplicación con reglas explícitas para
identificar si una imagen contiene un gato u otro tipo de animal, se puede adoptar un
enfoque basado en aprendizaje profundo. En este contexto, se construye un conjunto de
datos compuesto por múltiples ejemplos de imágenes etiquetadas, algunas con gatos y
otras sin ellos. Este conjunto permite que el modelo aprenda automáticamente a
distinguir un gato de otros animales a partir de los patrones estadísticos presentes en
los datos, sin requerir instrucciones específicas para cada caso.

El objetivo principal de este proceso es modelar la distribución de los datos de manera
que el sistema sea capaz de identificar diferencias entre las distintas clases. En un
escenario de aprendizaje supervisado, cada ejemplo del conjunto de datos se asocia con
una etiqueta que indica si pertenece o no a la clase "gato". Con ello, el modelo aprende
la relación entre las características de las imágenes y su respectiva clasificación.

Durante este proceso, las etiquetas se representan mediante valores numéricos. Cada
clase tiene asignado un identificador único. Este identificador puede gestionarse
mediante un diccionario, en el que la clave representa el identificador numérico y el
valor corresponde al nombre de la clase. Una vez que el modelo produce sus predicciones,
se selecciona la clase con el valor más alto y se traduce nuevamente al nombre de la
clase utilizando dicho diccionario. Por ejemplo, si el modelo predice que el índice más
alto corresponde al identificador `1`, el sistema puede mapear este valor a la clase
`"gato"`.

Gracias a la disponibilidad de grandes volúmenes de datos etiquetados, los sistemas
supervisados se han convertido en los más empleados en la práctica. Cada muestra del
conjunto de datos se considera independiente e idénticamente distribuida (i.i.d.), lo
que significa que cada ejemplo es representativo y estadísticamente consistente con la
distribución global de los datos. Este supuesto garantiza que el modelo pueda aprender
patrones estables y generalizables, de modo que las representaciones internas que genera
(también conocidas como espacios embebidos o espacios de representación) resulten
estructuradas y separables, permitiendo agrupar ejemplos similares en regiones cercanas
del espacio de características que crea el modelo internamente.

Siguiendo con el ejemplo de la clasificación de gatos, cada imagen de entrada se
representa mediante un conjunto de píxeles con tres canales de color (rojo, verde y
azul). Si cada canal tiene una resolución de, por ejemplo, $64 \times 64$ píxeles, el
número total de valores por imagen es $64 \times 64 \times 3 = 12288$.

Para que esta información pueda ser procesada por un modelo de red neuronal, las tres
matrices de color se **aplanan (_flatten_)**, convirtiéndose en un único vector columna
de dimensión $12288 \times 1$. Este vector conserva la información de los píxeles, pero
la reorganiza en una estructura unidimensional apta para cálculos matriciales.

Si se dispone de $M$ ejemplos, la matriz de características $X$ tendrá dimensión
$(n, M)$, donde $n = 12288$, mientras que el vector de etiquetas $Y$ tendrá dimensión
$(1, M)$ y contendrá los valores binarios correspondientes a cada muestra.

Para resolver este problema, se emplea la regresión logística, un algoritmo de
aprendizaje supervisado diseñado específicamente para tareas de clasificación binaria.
Su funcionamiento es similar al de la regresión lineal, pero incorpora una **función de
activación sigmoide** que transforma la salida del modelo en un valor comprendido entre
0 y 1, interpretable como una probabilidad. La función sigmoide se define como:

$$
\sigma(z) = \frac{1}{1 + e^{-z}},
$$

donde:

$$
z = \mathbf{w}^\top \mathbf{x} + b.
$$

En esta formulación, $\mathbf{w}$ representa el vector de pesos, $b$ el término de
sesgo, y $\mathbf{x}$ el vector de características de la imagen. La predicción final del
modelo se expresa como:

$$
\hat{y} = \sigma(\mathbf{w}^\top \mathbf{x} + b),
$$

donde $\hat{y}$ indica la probabilidad de que la imagen pertenezca a la clase positiva
(es decir, que contenga un gato). Si el valor de $\hat{y}$ supera un determinado umbral
de decisión (por ejemplo, 0.5), la imagen se clasifica como perteneciente a la clase
"gato"; en caso contrario, se clasifica como "no gato".

## Función de pérdida y función de coste

Una vez obtenidos los datos, es necesario formalizar el proceso mediante el cual un
modelo ajusta sus predicciones a los resultados esperados. Este procedimiento se
fundamenta en la **función de pérdida**, una magnitud escalar y diferenciable que
cuantifica el error cometido por el modelo en una predicción individual. Su valor
refleja el grado de discrepancia entre la salida estimada y el valor real, constituyendo
así un indicador directo del rendimiento del modelo.

Durante el entrenamiento, el objetivo principal es **minimizar la función de pérdida**,
reduciendo la diferencia entre las predicciones generadas y los valores verdaderos. En
el caso del aprendizaje supervisado, esta minimización se realiza comparando las
etiquetas reales con las salidas del modelo. Por el contrario, en contextos no
supervisados, donde no existen etiquetas explícitas, se optimizan otras métricas, como
las distancias entre muestras o el error cuadrático medio entre reconstrucciones y los
datos originales, entre otras.

El proceso de optimización se ejecuta habitualmente mediante el **descenso del
gradiente**. Durante este proceso, los parámetros del modelo, los pesos ($w$) y el sesgo
($b$), se ajustan iterativamente con el fin de minimizar la discrepancia entre las
predicciones y las etiquetas reales.

Es importante distinguir entre función de pérdida y función de coste. La función de
pérdida mide el error correspondiente a un único ejemplo de entrenamiento, mientras que
la función de coste representa el promedio de dichas pérdidas a lo largo de todo el
conjunto de entrenamiento:

$$
J(w, b) = \frac{1}{M} \sum_{i=1}^{M} \mathcal{L}(\hat{y}^{(i)}, y^{(i)}),
$$

donde $M$ representa el número total de ejemplos. El objetivo del entrenamiento es
encontrar los parámetros óptimos de $(w, b)$ que minimicen la función de pérdida
$\mathcal{L}$, la cual mide la discrepancia entre las predicciones $\hat{y}_i$ y los
valores verdaderos $y_i$.

En la regresión logística, la función de pérdida más empleada es la **_log-loss_** o
pérdida logarítmica, definida como:

$$
\mathcal{L}(\hat{y}, y) = - \big( y \cdot \log(\hat{y}) + (1 - y) \cdot \log(1 - \hat{y}) \big).
$$

A partir de esta definición, la función de coste correspondiente se expresa como el
promedio de todas las pérdidas individuales:

$$
J(w, b) = -\frac{1}{M} \sum_{i=1}^{M} \Big[ y^{(i)} \log(\hat{y}^{(i)}) + (1 - y^{(i)}) \log(1 - \hat{y}^{(i)}) \Big],
$$

donde $\hat{y}^{(i)} = \sigma(w^T x^{(i)} + b)$ es la probabilidad estimada por el
modelo para el ejemplo $i$, $x^{(i)}$ representa el vector de características del
ejemplo, $y^{(i)}$ es la etiqueta real y $\sigma(z)$ es la **función sigmoide**. Esta
formulación penaliza de forma más efectiva los errores en problemas de clasificación
binaria que el error cuadrático medio (_Mean Square Error_, MSE), ya que la _log-loss_
proporciona gradientes más estables y evita ciertos problemas de convergencia asociados
a funciones no logarítmicas.

Sin embargo, el MSE sigue siendo ampliamente utilizado en tareas de regresión, donde se
define como:

$$
\text{MSE} = \frac{1}{M} \sum_{i=1}^{M} (\hat{y}^{(i)} - y^{(i)})^2.
$$

En problemas de regresión, la elección de la función de pérdida depende de la naturaleza
de los datos y de la sensibilidad deseada frente a valores atípicos. La MSE penaliza con
mayor intensidad los errores grandes, por lo que resulta sensible a la presencia de
valores extremos. En contraposición, la pérdida absoluta media (_Mean Absolute Error_,
MAE) ofrece una alternativa más robusta frente a valores atípicos, aunque su derivada no
está definida en los puntos donde $y_i = \hat{y}_i$:

$$
\mathcal{L}_{\text{MAE}} = \frac{1}{N} \sum_{i=1}^{N} |y_i - \hat{y}_i|.
$$

Para equilibrar las ventajas de ambas métricas, se utiliza con frecuencia la pérdida de
Huber, que introduce un parámetro de transición $\delta > 0$ y combina los
comportamientos del MSE y del MAE en una sola formulación:

$$
\mathcal{L}_{\text{Huber}} =
\begin{cases}
\frac{1}{2}(y_i - \hat{y}_i)^2, & \text{si } |y_i - \hat{y}_i| \leq \delta \\
\delta \cdot (|y_i - \hat{y}_i| - \frac{1}{2}\delta), & \text{en otro caso.}
\end{cases}
$$

La pérdida de Huber es diferenciable en casi todos los puntos, salvo en el límite
$|y_i - \hat{y}_i| = \delta$, aunque esta discontinuidad no genera inestabilidad
numérica debido a la precisión finita de los cálculos. Por este motivo, se aplica
habitualmente en contextos donde se busca un equilibrio entre la robustez frente a
valores atípicos y la estabilidad del proceso de optimización.

Finalmente, cabe destacar que un modelo que obtiene un coste bajo en el conjunto de
entrenamiento no garantiza un buen rendimiento general. Este fenómeno, conocido como
sobreajuste (_overfitting_), se presenta cuando el modelo alcanza una elevada precisión
en los datos de entrenamiento, pero su desempeño se degrada significativamente al
evaluarse en datos nuevos. En tales casos, el modelo no aprende patrones generalizables,
sino que memoriza los ejemplos específicos del conjunto de entrenamiento. El sobreajuste
puede deberse a un número insuficiente de muestras, a arquitecturas excesivamente
complejas o a problemas en la representación de los datos, como etiquetado incorrecto,
desequilibrio de clases o sesgos en el conjunto de entrenamiento. Asimismo, las
diferencias entre las distribuciones de los datos de entrenamiento y los de producción
pueden comprometer la capacidad de generalización del modelo. Los modelos entrenados con
datos que contienen valores de características poco frecuentes son especialmente
susceptibles al sobreajuste, ya que tienden a memorizar estas particularidades en lugar
de aprender patrones generalizables.

## Descenso del gradiente

El descenso del gradiente constituye uno de los algoritmos fundamentales para el
entrenamiento de modelos en aprendizaje automático. Su propósito es encontrar los
valores de los parámetros que minimizan una determinada función de coste, garantizando
que las predicciones del modelo se ajusten lo mejor posible a los datos observados.

En el caso de la regresión logística, la función de coste $J(w, b)$ se define a partir
de la función de pérdida logarítmica:

$$
J(w, b) = -\frac{1}{M} \sum_{i=1}^{M} \Big[ y^{(i)} \log(\hat{y}^{(i)}) + (1 - y^{(i)}) \log(1 - \hat{y}^{(i)}) \Big].
$$

Para reducir el valor de $J(w, b)$, se calculan las derivadas parciales con respecto a
los parámetros del modelo. Estas derivadas determinan la dirección del gradiente, es
decir, el sentido en el que la función de coste crece más rápidamente. Dado que el
objetivo es minimizarla, el algoritmo ajusta los parámetros en la dirección opuesta al
gradiente:

$$
\frac{\partial J}{\partial w} = dw = \frac{1}{M} \sum_{i=1}^{M} (\hat{y}^{(i)} - y^{(i)}) x^{(i)}, \quad
\frac{\partial J}{\partial b} = db = \frac{1}{M} \sum_{i=1}^{M} (\hat{y}^{(i)} - y^{(i)}).
$$

Estos términos indican cómo deben modificarse $w$ y $b$ en cada iteración para disminuir
el error. El procedimiento completo del descenso del gradiente se desarrolla de forma
iterativa y puede resumirse en las siguientes fases:

1. **Inicialización de los parámetros**: Se asignan valores iniciales, generalmente
   pequeños, ya sean ceros o valores aleatorios.
2. **Propagación hacia adelante**: Se calculan las predicciones $\hat{y}$ a partir de
   los datos de entrada $X$ y se evalúa la función de pérdida $\mathcal{L}(\hat{y}, y)$
   y la función de coste $J(w, b)$.
3. **Propagación hacia atrás**: Se obtienen las derivadas parciales $dw$ y $db$, que
   indican la dirección del ajuste de los parámetros.
4. **Actualización de parámetros**: Se actualizan los valores de $w$ y $b$ según la
   regla:

$$
w := w - \alpha \cdot dw, \quad b := b - \alpha \cdot db,
$$

donde $\alpha$ es la tasa de aprendizaje o ratio de aprendizaje, un hiperparámetro que
controla el tamaño del paso dado en cada iteración. Si $\alpha$ es demasiado grande, el
algoritmo puede divergir; si es demasiado pequeño, la convergencia será muy lenta. El
proceso se repite hasta alcanzar un mínimo adecuado de $J(w, b)$, lo que se traduce en
predicciones más precisas.

En la práctica, el descenso del gradiente se implementa de forma vectorizada,
aprovechando operaciones matriciales sobre todos los ejemplos del conjunto de
entrenamiento en paralelo. Esta formulación no solo simplifica la implementación, sino
que también permite aprovechar la capacidad de cómputo de las GPU.

Para ilustrar el funcionamiento del algoritmo, considérese la función bidimensional:

$$
f(x) = \sin(x_1)\cos(x_2) + \sin(0.5x_1)\cos(0.5x_2), \quad x \in [0, 10].
$$

El objetivo consiste en aplicar el descenso del gradiente sobre esta función, calculando
explícitamente las derivadas parciales respecto a $x_1$ y $x_2$:

```py linenums="1"
import numpy as np
import matplotlib.pyplot as plt

# Definición de la función
def function(input: np.ndarray) -> np.ndarray:
    assert input.shape[-1] == 2, "La entrada debe contener 2 elementos"
    return np.sin(input[:, 0]) * np.cos(input[:, 1]) + np.sin(0.5 * input[:, 0]) * np.cos(0.5 * input[:, 1])

# Cálculo del gradiente (derivadas parciales)
def gradiente(input: np.ndarray) -> np.ndarray:
    assert input.shape[-1] == 2, "La entrada debe contener 2 elementos"

    df_x1 = np.cos(input[:, 0]) * np.cos(input[:, 1]) + 0.5 * np.cos(0.5 * input[:, 0]) * np.cos(0.5 * input[:, 1])
    df_x2 = -np.sin(input[:, 0]) * np.sin(input[:, 1]) - 0.5 * np.sin(0.5 * input[:, 0]) * np.sin(0.5 * input[:, 1])

    return np.stack([df_x1, df_x2], axis=1)

# Algoritmo de descenso del gradiente
def descenso_gradiente(num_puntos: int = 10, num_iteraciones: int = 30, learning_rate: float = 1e-3):
    dim = 2

    # Inicialización en el dominio [0,10]
    X = np.random.rand(num_puntos, dim) * 10
    trayectorias = [X.copy()]

    for _ in range(num_iteraciones):
        X = X - learning_rate * gradiente(input=X)
        trayectorias.append(X.copy())

    return np.array(trayectorias)

# Ejecución del descenso del gradiente
trayectoria = descenso_gradiente(num_puntos=5, num_iteraciones=30)

# Visualización de las trayectorias
for i in range(trayectoria.shape[1]):
    plt.plot(trayectoria[:, i, 0], trayectoria[:, i, 1], marker="o")

plt.xlabel("x1")
plt.ylabel("x2")
plt.title("Trayectorias del descenso del gradiente")
plt.show()
```

Al ejecutar este código, se observa que los puntos iniciales evolucionan siguiendo
trayectorias determinadas por el gradiente de la función. En cada iteración, las
posiciones se actualizan desplazándose en la dirección opuesta a la pendiente local, lo
que permite avanzar hacia valores más bajos de la función objetivo.

En el contexto de redes neuronales, el cálculo de derivadas necesarias para aplicar el
descenso del gradiente se realiza mediante sistemas de **diferenciación automática**. En
PyTorch, este proceso se gestiona mediante el módulo **`autograd`**, que permite
calcular derivadas de manera automática sobre operaciones tensoriales y constituye la
base del algoritmo de _backpropagation_. Cada tensor en PyTorch puede llevar asociada la
propiedad `requires_grad=True`, que indica si debe participar en el cálculo de
gradientes. PyTorch construye un grafo computacional dinámico que registra las
operaciones realizadas sobre los tensores, y al invocar el método `backward()`, aplica
la regla de la cadena para calcular las derivadas necesarias. Este mecanismo se conoce
también como el modo inverso de diferenciación automática:

```py linenums="1"
import torch

x = torch.tensor([2.0, 3.0], requires_grad=True)
y = x**2 + 2*x + 1
z = y.sum()
z.backward()

# Derivadas parciales de z respecto a x
print(x.grad)
```

Además, PyTorch permite desactivar el cálculo de gradientes cuando no es necesario, como
durante la fase de inferencia, utilizando el contexto `with torch.no_grad():` o el modo
`with torch.inference_mode():`, que resulta aún más eficiente. Esto reduce
significativamente el consumo de memoria y mejora el rendimiento computacional.

Para mejorar la eficiencia, en lugar de calcular los gradientes utilizando el conjunto
completo de datos, se emplea el **descenso de gradiente estocástico (SGD)**, que utiliza
pequeños subconjuntos (_mini-batches_). Esta aproximación introduce aleatoriedad,
disminuye el coste computacional y ayuda a escapar de regiones problemáticas, como los
puntos de silla, donde los gradientes se anulan sin representar un mínimo real. Calcular
los gradientes sobre un subconjunto reducido del conjunto de datos puede interpretarse
como una aproximación de Monte Carlo de la función de coste global, lo que resulta
suficientemente representativo para actualizar los parámetros de la red de manera
efectiva.

El descenso de gradiente básico puede resultar ineficiente en ciertos escenarios, por lo
que se han desarrollado variantes que mejoran su rendimiento. Una de ellas es el
**algoritmo Momentum**, que introduce un efecto de inercia acumulando información de
gradientes previos para suavizar las actualizaciones:

$$
v_t = \beta v_{t-1} + (1-\beta) \, \nabla_\theta \mathcal{L}(\theta_t),
$$

$$
\theta_{t+1} = \theta_t - \eta \, v_t,
$$

donde $v_t$ representa la "velocidad" acumulada y $\beta \in [0,1)$ es el coeficiente de
decaimiento, generalmente fijado en 0.9. Este mecanismo reduce las oscilaciones en
direcciones de alta curvatura y acelera la convergencia en valles estrechos.

Otro método es **RMSprop**, que adapta la tasa de aprendizaje a cada parámetro mediante
el escalado de los gradientes por una media móvil de sus valores al cuadrado:

$$
s_t = \rho s_{t-1} + (1-\rho) \left(\nabla_\theta \mathcal{L}(\theta_t)\right)^2,
$$

$$
\theta_{t+1} = \theta_t - \frac{\eta}{\sqrt{s_t + \epsilon}} \, \nabla_\theta \mathcal{L}(\theta_t),
$$

donde $\rho \approx 0.9$ y $\epsilon \approx 10^{-8}$ para evitar divisiones por cero.
Este ajuste permite que los parámetros con gradientes grandes reciban pasos más
pequeños, mientras que aquellos con gradientes pequeños se actualizan más rápidamente,
mejorando la estabilidad del entrenamiento.

El optimizador **Adam** combina las ventajas de Momentum y RMSprop, acumulando tanto la
media de los gradientes como la media de sus cuadrados. Su formulación se realiza en
cuatro etapas:

1. **Media de gradientes (primer momento):**

$$
m_t = \beta_1 m_{t-1} + (1-\beta_1) \, \nabla_\theta \mathcal{L}(\theta_t).
$$

2. **Media de cuadrados de gradientes (segundo momento):**

$$
v_t = \beta_2 v_{t-1} + (1-\beta_2) \, \left(\nabla_\theta \mathcal{L}(\theta_t)\right)^2.
$$

3. **Corrección del sesgo inicial:**

$$
\hat{m}_t = \frac{m_t}{1-\beta_1^t}, \quad \hat{v}_t = \frac{v_t}{1-\beta_2^t}.
$$

4. **Actualización final de los parámetros:**

$$
\theta_{t+1} = \theta_t - \frac{\eta}{\sqrt{\hat{v}_t} + \epsilon} \, \hat{m}_t.
$$

Los valores recomendados son $\beta_1 = 0.9$, $\beta_2 = 0.999$ y $\epsilon = 10^{-8}$.
Este optimizador se utiliza ampliamente debido a su rapidez, estabilidad y robustez
frente a configuraciones no óptimas de hiperparámetros.

A modo de ilustración, se presenta una implementación de los principales optimizadores
aplicada a la función de prueba $f(\theta) = \theta^2$, cuyo mínimo global se encuentra
en $\theta=0$:

```py linenums="1"
import numpy as np

# Función de pérdida y gradiente
loss = lambda theta: theta**2
grad = lambda theta: 2*theta

# Valor inicial
theta_init = 5.0

# Descenso de gradiente estocástico (SGD)
def sgd(theta, grad, eta=0.1, steps=20):
    for t in range(steps):
        theta -= eta * grad(theta)
    return theta

# Momentum
def momentum(theta, grad, eta=0.1, beta=0.9, steps=20):
    v = 0
    for t in range(steps):
        v = beta * v + (1 - beta) * grad(theta)
        theta -= eta * v
    return theta

# RMSprop
def rmsprop(theta, grad, eta=0.1, rho=0.9, eps=1e-8, steps=20):
    s = 0
    for t in range(steps):
        g = grad(theta)
        s = rho * s + (1 - rho) * g**2
        theta -= eta / (np.sqrt(s) + eps) * g
    return theta

# Adam
def adam(theta, grad, eta=0.1, beta1=0.9, beta2=0.999, eps=1e-8, steps=20):
    m, v = 0, 0
    for t in range(1, steps+1):
        g = grad(theta)
        m = beta1 * m + (1 - beta1) * g
        v = beta2 * v + (1 - beta2) * g**2
        m_hat = m / (1 - beta1**t)
        v_hat = v / (1 - beta2**t)
        theta -= eta / (np.sqrt(v_hat) + eps) * m_hat
    return theta

print("SGD:", sgd(theta_init, grad))
print("Momentum:", momentum(theta_init, grad))
print("RMSprop:", rmsprop(theta_init, grad))
print("Adam:", adam(theta_init, grad))
```

## Métodos de regularización

En el contexto de la regresión lineal, es posible obtener una solución analítica para
los pesos del modelo mediante la **pseudoinversa de Moore–Penrose**, que proporciona una
estimación cerrada de los parámetros cuando la matriz de diseño no es cuadrada o no
tiene inversa directa. Esta solución se expresa como:

$$
\mathbf{w} = (\mathbf{X}^\top \mathbf{X})^{-1} \mathbf{X}^\top \mathbf{y},
$$

donde $\mathbf{X} \in \mathbb{R}^{N \times n}$ representa la matriz de datos de entrada
y $\mathbf{y} \in \mathbb{R}^N$ los valores objetivo. Sin embargo, este enfoque puede
resultar numéricamente inestable cuando la matriz $(\mathbf{X}^\top \mathbf{X})$ es casi
singular, es decir, cuando algunos de sus valores propios son muy pequeños o cercanos a
cero. En tales casos, pequeñas variaciones en los datos pueden producir grandes cambios
en los parámetros estimados, lo que conduce a un modelo **sobreajustado** y con escasa
capacidad de generalización.

Para mitigar este problema y mejorar la estabilidad del modelo, se introduce un
**término de regularización** en la función de coste. La regularización actúa como un
mecanismo de control que penaliza los pesos excesivamente grandes, favoreciendo
soluciones más estables y reduciendo la varianza del modelo. De este modo, se logra un
equilibrio entre el ajuste a los datos de entrenamiento y la capacidad de generalización
ante nuevos ejemplos. Los métodos más comunes son la **regularización L2 (_Ridge
Regression_)** y la **regularización L1 (_Lasso Regression_)**.

La regularización L2 agrega al término de error un componente proporcional al cuadrado
de la magnitud de los pesos. Este término penaliza los parámetros de gran magnitud,
promoviendo valores pequeños y distribuidos de manera más uniforme. Su función de
pérdida se define como:

$$
\mathcal{L}_{\text{Ridge}} = \frac{1}{N} \sum_{i=1}^{N} (y_i - \hat{y}_i)^2 + \lambda |\mathbf{w}|_2^2,
$$

donde $\lambda$ es un hiperparámetro que controla la intensidad de la penalización.
Cuanto mayor sea su valor, más fuerte será la restricción sobre los pesos. La
regularización L2 produce modelos más suaves y estables, ya que evita oscilaciones
excesivas en los parámetros y contribuye a que el proceso de entrenamiento sea más
controlado. En la práctica, esto se traduce en cambios menos abruptos en la salida ante
pequeñas desviaciones en la entrada, comportamiento que también se conoce como
**decaimiento de los pesos (_weight decay_)**.

Por otro lado, la regularización L1 incorpora un término basado en la suma de los
valores absolutos de los pesos:

$$
\mathcal{L}_{\text{Lasso}} = \frac{1}{N} \sum_{i=1}^{N} (y_i - \hat{y}_i)^2 + \lambda |\mathbf{w}|_1.
$$

A diferencia de la regularización L2, el término L1 tiende a forzar algunos coeficientes
a ser exactamente cero, lo que induce esparsidad en el modelo. En la práctica, esto
significa que ciertos parámetros se eliminan completamente, dando lugar a modelos más
simples y con menos variables efectivamente activas. Este comportamiento convierte a la
regularización L1 en una herramienta útil para selección de características, ya que
identifica de manera implícita las variables más relevantes para la predicción. Sin
embargo, la regularización L1 es menos común en aprendizaje profundo porque no
interactúa bien con la no convexidad de los problemas de optimización y con el uso del
descenso del gradiente.

La regularización y la normalización son técnicas fundamentales para mejorar la
capacidad de generalización de los modelos de aprendizaje profundo y reducir el riesgo
de sobreajuste. Ambas estrategias buscan limitar la dependencia excesiva del modelo
respecto a los datos de entrenamiento, promoviendo representaciones más robustas y
estables que permitan un rendimiento consistente en datos no vistos. Entre las técnicas
de regularización más utilizadas destacan:

- **Dropout**: Desactiva aleatoriamente un subconjunto de neuronas durante el
  entrenamiento, impidiendo que las unidades desarrollen dependencias excesivas entre
  sí. Esto obliga a la red a generar representaciones redundantes y más robustas.
  Durante la inferencia, todas las neuronas se utilizan, pero la salida se convierte en
  una variable aleatoria dependiente de las máscaras de desactivación aplicadas. Para
  obtener una salida determinista, se puede aproximar el valor esperado mediante
  muestreo de Monte Carlo (realizando múltiples pasadas hacia adelante con diferentes
  máscaras y promediando los resultados), lo que además proporciona una medida de
  incertidumbre sobre la predicción. No obstante, dado que realizar múltiples pasadas
  resulta costoso, la práctica más habitual consiste en reemplazar las variables
  aleatorias capa por capa mediante un ajuste proporcional de los pesos, lo que
  constituye una aproximación razonable y eficiente.

- **Aumentación de datos (_data augmentation_)**: Crea ejemplos adicionales a partir de
  transformaciones aplicadas a los datos originales, como rotaciones, traslaciones,
  cambios de escala o variaciones de iluminación. Esta técnica incrementa la diversidad
  del conjunto de entrenamiento y hace que el modelo sea menos sensible a variaciones
  irrelevantes.

- **Detención temprana (_early stopping_)**: Supervisa el rendimiento del modelo sobre
  el conjunto de validación y detiene el entrenamiento cuando el error deja de mejorar,
  evitando que la red se ajuste demasiado a las particularidades del conjunto de
  entrenamiento.

- **Normalización de entradas**: Escala y centra las características de los datos para
  garantizar magnitudes comparables, acelerando la convergencia, mejorando la
  estabilidad numérica y evitando que ciertos parámetros dominen el aprendizaje. Una
  práctica habitual consiste en restar la media y dividir por la desviación estándar de
  cada característica, de modo que los datos queden centrados en cero con varianza
  unitaria.

En complemento a la regularización, las técnicas de **normalización de activaciones**
resultan esenciales para estabilizar el entrenamiento y acelerar la convergencia.
Durante la optimización, las activaciones pueden variar significativamente entre capas,
lo que genera inestabilidad y dificulta el ajuste de los parámetros. La normalización
busca mantener distribuciones equilibradas de las activaciones a lo largo de la red:

- **_Batch Normalization_**: Normaliza las activaciones de cada capa utilizando la media
  y la varianza calculadas sobre los ejemplos de un mini-lote. Esto reduce el problema
  del _internal covariate shift_, acelera el aprendizaje, permite tasas de aprendizaje
  más altas y simplifica el ajuste de hiperparámetros. Sin embargo, su efectividad
  depende del tamaño y la composición de los lotes, siendo menos adecuada en lotes
  pequeños o en datos con distribuciones muy variables.

- **_Layer Normalization_**: Normaliza las activaciones a nivel de capa, calculando
  estadísticas por muestra en lugar de por mini-lote. Es especialmente útil en
  arquitecturas secuenciales, como los _Transformers_, y en escenarios de entrenamiento
  distribuido, ya que no requiere compartir estadísticas entre lotes, facilitando la
  paralelización y la escalabilidad.

## Sistemas de clasificación multiclase y la función Softmax

En los sistemas de clasificación multiclase, el objetivo del modelo es asignar una
probabilidad a cada una de las posibles clases, de modo que la suma de todas ellas sea
igual a uno. Para lograrlo, la capa de salida del modelo suele aplicar la **función
_Softmax_** sobre los valores de activación o _logits_ generados por la red neuronal.
Estos logits se definen como:

$$
z_i = \mathbf{w}_i^\top \mathbf{x} + b_i,
$$

donde $\mathbf{x}$ representa el vector de entrada, $\mathbf{w}_i$ los pesos asociados a
la clase $i$, y $b_i$ el sesgo correspondiente. A partir de estos valores, la función
_Softmax_ transforma los logits en una distribución de probabilidad normalizada:

$$
p_i = \text{Softmax}(z_i) = \frac{e^{z_i / T}}{\sum_{j=1}^{M} e^{z_j / T}},
$$

donde $T > 0$ es el **parámetro de temperatura** que controla la "nitidez" de la
distribución. Cuando el valor de $T$ es grande, las diferencias entre los exponentes se
atenúan, y la distribución resultante se aproxima a una distribución uniforme, lo que
refleja una mayor incertidumbre del modelo. Por el contrario, cuando $T$ tiende a cero,
la probabilidad se concentra en la clase más probable, haciendo que las predicciones
sean más deterministas.

El proceso de predicción final se realiza seleccionando la clase con la probabilidad más
alta:

$$
\hat{y} = \arg\max_i \, p_i.
$$

Con el fin de evitar que el modelo sea excesivamente confiado en sus predicciones, se
utiliza una técnica denominada **suavizado de etiquetas (_label smoothing_)**. Este
procedimiento ajusta las etiquetas verdaderas, reduciendo ligeramente la probabilidad
asignada a la clase correcta y redistribuyendo parte de ella entre las demás clases,
según la expresión:

$$
y_i' = (1 - \varepsilon) y_i + \frac{\varepsilon}{M},
$$

donde $\varepsilon \in [0,1]$ determina el grado de suavizado.

Para el entrenamiento de modelos de clasificación, la **función de pérdida por entropía
cruzada** es una de las más empleadas:

$$
\mathcal{L}_{\text{CE}} = - \sum_{i=1}^{M} y_i \log(p_i).
$$

El objetivo del aprendizaje consiste en minimizar esta pérdida, lo cual equivale a
**maximizar la probabilidad asignada a la clase correcta**. Desde un punto de vista
teórico, la entropía cruzada puede descomponerse como:

$$
\mathcal{L}_{\text{CE}} = H(\mathbf{y}, \mathbf{p}) = H(\mathbf{y}) + D_{KL}(\mathbf{y} \,||\, \mathbf{p}),
$$

donde $H(\mathbf{y})$ representa la entropía de las etiquetas verdaderas y
$D_{KL}(\mathbf{y} \,||\, \mathbf{p})$ es la **divergencia de Kullback–Leibler**,
definida como:

$$
D_{KL}(\mathbf{y} \,||\, \mathbf{p}) = \sum_{i=1}^{M} y_i \log \frac{y_i}{p_i}.
$$

Minimizar la entropía cruzada implica reducir la divergencia entre la distribución
predicha y la distribución verdadera.

## Incertidumbre, calibración y pérdida focal

Aunque la función _Softmax_ transforma los _logits_ en probabilidades dentro del
intervalo $[0, 1]$ que suman 1, estas **no reflejan necesariamente la verdadera
incertidumbre del modelo**. Un valor de probabilidad elevado no garantiza que la
predicción sea fiable, ya que muchos modelos modernos tienden a ser excesivamente
confiados en sus predicciones, incluso cuando son erróneas.

La **calibración del modelo** surge para corregir este comportamiento. Su objetivo es
alinear las probabilidades predichas con las frecuencias empíricas observadas. Un modelo
se considera perfectamente calibrado cuando:

$$
P(Y = k \mid \hat{P}(Y = k) = p) = p.
$$

El flujo general del proceso de calibración se desarrolla en las siguientes etapas:
entrenamiento del modelo sobre el conjunto de entrenamiento, obtención de los _logits_ o
probabilidades sobre un conjunto de validación independiente, aplicación de un método de
calibración (como el escalado de temperatura, el _Platt scaling_ o la regresión
isotónica), optimización de los parámetros del calibrador, evaluación del grado de
calibración mediante métricas especializadas como el _Expected Calibration Error_ (ECE)
o el _Maximum Calibration Error_ (MCE), e implementación del calibrador final para
ajustar las probabilidades durante la inferencia en producción.

Uno de los métodos más simples y eficaces para calibrar redes neuronales es el
**escalado de temperatura** (_temperature scaling_), que consiste en ajustar un único
parámetro $T > 0$ que reescala los _logits_ antes de aplicar la función _Softmax_. El
valor de $T$ se optimiza sobre un conjunto de validación minimizando la entropía
cruzada. Cabe destacar que este ajuste no altera la clase predicha (el valor de
$\arg\max$ permanece igual), sino que modifica la confianza asociada a cada predicción.

Para problemas de clasificación binaria, el **_Platt Scaling_** ofrece una alternativa
paramétrica en la que los _logits_ se ajustan mediante una función sigmoide con
parámetros $A$ y $B$ optimizados sobre validación. La **regresión isotónica**, por su
parte, constituye un método no paramétrico que ajusta las probabilidades mediante una
función monótonamente creciente, ofreciendo mayor flexibilidad aunque requiriendo más
muestras de validación.

Las métricas de evaluación de la calibración incluyen el **ECE** (_Expected Calibration
Error_):

$$
\text{ECE} = \sum_{m=1}^M \frac{|B_m|}{N} \Big| \text{acc}(B_m) - \text{conf}(B_m) \Big|,
$$

y el **MCE** (_Maximum Calibration Error_):

$$
\text{MCE} = \max_m \Big| \text{acc}(B_m) - \text{conf}(B_m) \Big|.
$$

En escenarios con desbalance de clases o gran cantidad de ejemplos "fáciles", la función
de pérdida tradicional por entropía cruzada puede resultar insuficiente. Para mitigar
este efecto, Lin et al. (2017) propusieron la **pérdida focal (_Focal Loss_)**:

$$
\mathcal{L}_{\text{Focal}} = - (1 - p_t)^\gamma \log(p_t),
$$

donde $p_t$ es la probabilidad predicha para la clase verdadera y $\gamma \ge 0$ es un
parámetro de enfoque que aumenta el peso relativo de los ejemplos difíciles. Cuando
$\gamma = 0$, la pérdida focal se reduce a la entropía cruzada estándar.

## Implementación de la regresión logística

Para ilustrar de forma práctica los conceptos presentados anteriormente, a continuación
se muestra una implementación básica de la regresión logística utilizando Python y la
librería NumPy. Este ejemplo incluye todas las etapas fundamentales del modelo: la
inicialización de parámetros, _forward propagation_, _backward propagation_, la
actualización de los parámetros mediante descenso del gradiente y, finalmente, la
generación de predicciones y la evaluación del modelo:

```py linenums="1"
import numpy as np
import matplotlib.pyplot as plt

# Dataset de ejemplo
np.random.seed(1)
m = 200  # número de ejemplos
n = 2    # número de características

# Clase 0
X0 = np.random.randn(m//2, n) + np.array([-2, -2])
Y0 = np.zeros((m//2, 1))

# Clase 1
X1 = np.random.randn(m//2, n) + np.array([2, 2])
Y1 = np.ones((m//2, 1))

# Concatenar y transponer
X = np.vstack((X0, X1)).T
Y = np.vstack((Y0, Y1)).T

# Funciones auxiliares
def sigmoid(z):
    """Función sigmoide."""
    return 1 / (1 + np.exp(-z))

def initialize_params(n):
    """Inicializa los parámetros del modelo."""
    w = np.zeros((n, 1))
    b = 0
    return w, b

def forward_propagation(w, b, X, Y):
    """Calcula la activación y el coste."""
    m = X.shape[1]
    Z = np.dot(w.T, X) + b
    A = sigmoid(Z)
    cost = -(1/m) * np.sum(Y*np.log(A) + (1-Y)*np.log(1-A))
    return A, cost

def backward_propagation(A, X, Y):
    """Calcula los gradientes del coste respecto a los parámetros."""
    m = X.shape[1]
    dw = (1/m) * np.dot(X, (A - Y).T)
    db = (1/m) * np.sum(A - Y)
    return dw, db

def update_params(w, b, dw, db, learning_rate):
    """Actualiza los parámetros usando descenso del gradiente."""
    w -= learning_rate * dw
    b -= learning_rate * db
    return w, b

# Entrenamiento del modelo
def logistic_regression(X, Y, num_iterations=1000, learning_rate=0.1, print_cost=False):
    """Entrena el modelo de regresión logística."""
    n = X.shape[0]
    w, b = initialize_params(n)
    costs = []

    for i in range(num_iterations):
        A, cost = forward_propagation(w, b, X, Y)
        dw, db = backward_propagation(A, X, Y)
        w, b = update_params(w, b, dw, db, learning_rate)

        if i % 100 == 0:
            costs.append(cost)
            if print_cost:
                print(f"Iteración {i}: coste = {cost:.4f}")

    return w, b, costs

# Predicción
def predict(w, b, X):
    """Genera predicciones binarias a partir de los parámetros entrenados."""
    A = sigmoid(np.dot(w.T, X) + b)
    return (A > 0.5).astype(int)

# Entrenar y evaluar el modelo
w, b, costs = logistic_regression(X, Y, num_iterations=1000, learning_rate=0.1, print_cost=True)
Y_pred = predict(w, b, X)
accuracy = 100 - np.mean(np.abs(Y_pred - Y)) * 100
print(f"\nExactitud del modelo: {accuracy:.2f}%")

# Visualización de la evolución del coste
plt.plot(costs)
plt.xlabel("Iteraciones (x100)")
plt.ylabel("Coste")
plt.title("Reducción del coste durante el entrenamiento")
plt.show()
```
