---
authors: Daniel Bazo Correa
description: Neurona artificial, redes neuronales y diferenciación automática.
title: Redes neuronales
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Este capítulo desarrolla la teoría y la implementación de redes neuronales, desde la
neurona artificial hasta las estrategias de optimización y el aprendizaje por
transferencia.

## Neurona artificial y redes neuronales

Para ilustrar el funcionamiento básico de los modelos de aprendizaje profundo, puede
considerarse el problema de estimar el precio de una vivienda. Si se representa
gráficamente el tamaño de la casa frente a su precio, se observa una tendencia creciente
positiva: a mayor tamaño de la vivienda, mayor precio. Una forma de capturar esta
relación es mediante la **regresión lineal**, que consiste en ajustar una línea recta
que describe la relación entre ambas variables. Esta línea se caracteriza por dos
parámetros fundamentales: su posición vertical, determinada por el término
independiente, y su pendiente, que define la tasa de cambio del precio respecto al
tamaño. Sin embargo, este enfoque presenta limitaciones importantes. Por ejemplo, al
extrapolar la línea recta hacia valores muy pequeños de tamaño, el modelo podría asignar
precios negativos a viviendas extremadamente reducidas, lo cual carece de sentido
práctico. Para resolver este problema, se incorporan funciones que restringen los
resultados a intervalos válidos de salidas, garantizando que las predicciones mantengan
coherencia con la realidad física del problema.

Este procedimiento puede comprenderse mejor mediante la analogía de una **neurona
artificial**, también conocida como perceptrón. La neurona recibe el tamaño de la
vivienda como entrada y aplica un cálculo lineal parametrizado, cuyos parámetros se han
obtenido a partir de ejemplos de entrenamiento. Posteriormente, utiliza una función de
activación que filtra valores inválidos, produciendo una estimación coherente del precio
dentro de un rango válido. De este modo, la neurona artificial transforma la entrada
mediante una combinación de operaciones lineales y no lineales, ajustándose
progresivamente a los patrones presentes en los datos.

Esta abstracción computacional tiene su origen en la estructura de la **neurona
biológica**. En el cerebro, una neurona se compone de tres partes principales: las
**dendritas**, que constituyen las entradas y reciben señales de otras neuronas; el
**soma** (cuerpo celular), donde se realiza el procesamiento; y el **axón**, que
transmite la señal de salida. Una neurona biológica se activa cuando la suma de los
impulsos recibidos a través de las dendritas alcanza un umbral determinado, generando un
potencial de acción (_spike_) que se propaga por el axón. Cuando esta señal llega a la
**sinapsis**, la conexión con la siguiente neurona, el proceso de transmisión pasa de
ser eléctrico a químico mediante la liberación de **neurotransmisores**. En la neurona
receptora, estos neurotransmisores generan una nueva señal eléctrica, completando así la
cadena de comunicación.

La sinapsis posee un **detector de coincidencias** basado en receptores NMDA, que se
activa cuando confluyen simultáneamente una señal química (llegada de neurotransmisores
de otra neurona) y una señal eléctrica (despolarización de la membrana de la neurona
receptora). Este mecanismo subyace al **principio hebbiano**: las neuronas que se
activan juntas refuerzan sus conexiones mutuas. Además, mecanismos locales, como la
activación simultánea de sinapsis cercanas, contribuyen a modular la fuerza de las
conexiones. Esta capacidad de modificar el número y la sensibilidad de los receptores
sinápticos se denomina **plasticidad sináptica**, y constituye la base biológica del
aprendizaje.

Una neurona biológica presenta dos tipos diferenciados de conexiones dendríticas. Las
**dendritas apicales** reciben conexiones de retroalimentación (_feedback_) con
información asociativa procedente de áreas corticales superiores, mientras que las
**dendritas basales** procesan conexiones de alimentación directa (_feedforward_) con
información sensorial y motora local. Las redes neuronales artificiales actuales modelan
principalmente la integración basal local junto con una plasticidad dependiente del
error de salida, pero no capturan las señales apicales ni la plasticidad dependiente del
contexto global o de los vecindarios neuronales, lo que representa una simplificación
significativa respecto al sistema biológico original.

No obstante, el valor de una vivienda depende de múltiples factores adicionales, como el
número de dormitorios, el número de baños, la ubicación geográfica, la proximidad a
servicios públicos o el estado de conservación de la propiedad. La incorporación de
estas características incrementa la **dimensionalidad** de los datos. En este escenario,
la simple regresión lineal se vuelve insuficiente, puesto que una única línea recta solo
es capaz de relacionar linealmente dos variables. Para abordar problemas de mayor
complejidad, resulta necesario combinar múltiples perceptrones organizados en **capas**,
lo que da lugar a arquitecturas que permiten modelar no solo relaciones lineales
individuales entre pares de variables, sino también combinaciones complejas de múltiples
parámetros de entrada. Además, estas arquitecturas posibilitan que las neuronas de capas
sucesivas procesen y combinen las representaciones generadas por capas anteriores,
construyendo progresivamente abstracciones de mayor nivel que capturan patrones
sofisticados en los datos.

En las arquitecturas de aprendizaje profundo se distinguen tres tipos de capas
fundamentales. La **capa de entrada** recibe las características iniciales del problema,
es decir, los datos de entrada tras aplicar las transformaciones oportunas para obtener
valores numéricos que el modelo pueda procesar. Las **capas ocultas** (_hidden layers_)
se sitúan entre la entrada y la salida, y su función consiste en procesar y transformar
progresivamente dichas características, extrayendo representaciones intermedias cada vez
más abstractas y relevantes para la tarea en cuestión. Finalmente, la **capa de salida**
genera la predicción final del modelo. La profundidad de la red, determinada por el
número de capas ocultas, influye directamente en su capacidad para aprender relaciones
complejas y no lineales entre las variables.

Cada neurona artificial asigna un **peso** a cada característica de entrada, indicando
la importancia relativa de esa variable en el resultado final. Además, cada neurona
incluye un **sesgo** (_bias_), un valor adicional que permite ajustar la función de
salida y otorga mayor flexibilidad al modelo. Tanto los pesos como el sesgo se
inicializan de manera aleatoria al comienzo del entrenamiento y se ajustan
progresivamente mediante algoritmos de optimización. Estos constituyen los **parámetros
aprendibles** de los modelos de inteligencia artificial, cuya configuración final
determina el comportamiento y las capacidades del modelo entrenado.

El resultado de la combinación lineal de las entradas ponderadas por los pesos, sumado
al sesgo, pasa posteriormente por una **función de activación no lineal**. Este
componente es esencial, ya que otorga a la red la capacidad de capturar relaciones
complejas y no lineales entre variables, superando las limitaciones de los modelos
puramente lineales. Sin funciones de activación no lineales, una red neuronal multicapa
se comportaría simplemente como un modelo lineal, independientemente de su profundidad.
Un ejemplo clásico que ilustra esta limitación es el problema de la **puerta XOR**: a
pesar de tener solo cuatro posibles combinaciones de entrada (00, 01, 10, 11), sus
salidas (0, 1, 1, 0) no pueden separarse mediante una frontera de decisión lineal, lo
que demuestra la necesidad de combinaciones no lineales para resolver incluso problemas
aparentemente simples.

El **teorema de aproximación universal** establece que una red neuronal con suficiente
profundidad o anchura (donde la profundidad se refiere al número de capas y la anchura
al número de neuronas por capa) y funciones de activación no lineales puede aproximar
cualquier función continua con precisión arbitraria. Sin embargo, este resultado es de
naturaleza teórica y no garantiza que dicha aproximación sea prácticamente alcanzable
con los recursos y algoritmos de entrenamiento disponibles.

Las redes neuronales profundas constituyen una extensión de las redes neuronales
artificiales tradicionales. Su principal diferencia radica en la presencia de múltiples
capas ocultas, dispuestas de manera secuencial, lo que permite construir
representaciones jerárquicas de la información. Las primeras capas de la red, situadas
cerca de la entrada, suelen detectar únicamente características elementales. Por
ejemplo, en arquitecturas diseñadas para procesar imágenes, las capas iniciales tienden
a identificar líneas horizontales, verticales o diagonales. Conforme se avanza hacia
capas más profundas, las representaciones se vuelven progresivamente más sofisticadas,
ya que se construyen combinando las características detectadas en etapas anteriores. De
este modo, en niveles intermedios es posible identificar formas más estructuradas,
mientras que en las capas finales se logran representaciones de alto nivel que
corresponden a objetos completos o conceptos abstractos.

### Composición de funciones y no linealidad

Un concepto fundamental en el diseño de redes neuronales es la **composición de
funciones**, que consiste en descomponer operaciones complejas en secuencias de
transformaciones más simples y manejables. El funcionamiento de una red neuronal puede
expresarse como múltiples operaciones parametrizadas encadenadas una tras otra:

$$
f(x) = (f_2 \circ f_1)(x) = f_2(f_1(x)),
$$

donde cada función $f_\ell$ corresponde a una capa del modelo con sus propios
parámetros. Esta composición puede extenderse a un número arbitrario de funciones,
siempre que cada una conserve el tipo de datos de la capa anterior. Los parámetros de
cada función se ajustan durante el entrenamiento de manera interdependiente, ya que la
salida de una capa constituye la entrada de la siguiente.

Sin embargo, si todas las funciones de la composición son lineales, la cadena completa
colapsa en una única transformación lineal, independientemente del número de capas. Por
ejemplo, si se tienen dos funciones lineales sucesivas $f_1(x) = W_1 x + b_1$ y
$f_2(h) = W_2 h + b_2$, la composición resulta en
$f_2(f_1(x)) = W_2 W_1 x + W_2 b_1 + b_2$, que sigue siendo una función lineal. Por
ello, la introducción de **funciones de activación no lineales** entre capas resulta
imprescindible para romper este colapso y dotar a la red de la capacidad de modelar
relaciones complejas.

### De neuronas a redes neuronales

Una **neurona artificial** se puede representar de manera similar a una regresión
logística: recibe entradas, las combina linealmente mediante pesos y sesgo, y aplica una
función de activación para producir una salida. Una **red neuronal** se construye al
**apilar múltiples neuronas organizadas en capas**, interconectadas entre sí, de manera
que la información procesada por una neurona puede transmitirse a otras neuronas de la
misma capa o de capas posteriores.

Añadir capas ocultas hace que el problema de optimización de las redes neuronales se
convierta en **no convexo**, lo que significa que la función de coste puede presentar
múltiples mínimos locales. A mayor número de capas y parámetros, es decir, a mayor
número de grados de libertad de la red, más no convexa es la función que debe
optimizarse. En consecuencia, pequeños cambios en la inicialización de los parámetros
pueden alterar significativamente el resultado final del entrenamiento.

### Parámetros e hiperparámetros

En el entrenamiento de redes neuronales profundas resulta esencial distinguir entre
parámetros e hiperparámetros. Los **parámetros** incluyen los pesos y sesgos de la red,
los cuales se aprenden automáticamente mediante algoritmos de optimización. Los
**hiperparámetros**, en cambio, se definen antes del entrenamiento y controlan aspectos
estructurales y dinámicos del modelo. Entre ellos destacan la **tasa de aprendizaje**,
el número de iteraciones o épocas, la cantidad de capas ocultas, el número de neuronas
por capa y la elección de funciones de activación. La búsqueda de hiperparámetros
constituye un proceso iterativo en el que se combinan prueba y error con estrategias más
sistemáticas, con el fin de encontrar la configuración que produzca el mejor desempeño.

### Funciones de activación

Las **funciones de activación** introducen no linealidad en la red neuronal, permitiendo
que el modelo aprenda relaciones complejas entre los datos. La elección de la función de
activación es fundamental y depende del tipo de capa y del problema a resolver. Las
salidas de la función parametrizada de la neurona o red neuronal se conocen como los
_logits_, y es posible distinguir entre las salidas **pre-activación** (antes de aplicar
la función de activación) y **post-activación** (después de aplicarla).

En las **capas ocultas**, se emplean funciones de activación como:

- **ReLU (_Rectified Linear Unit_)**: Es ampliamente utilizada en redes profundas, ya
  que acelera el entrenamiento y evita problemas de gradientes muy pequeños. No
  obstante, puede provocar **neuronas muertas**, que siempre devuelven cero. Para
  mitigar este efecto se utilizan variantes como _Leaky ReLU_, que mantiene un pequeño
  gradiente para valores negativos:

$$
f(x) = \max(0, x).
$$

- **Sigmoide**: Transforma los valores en el rango $[0,1]$. Se utiliza en redes
  recurrentes, aunque presenta el problema de **gradientes que desaparecen** en los
  extremos:

$$
\sigma(x) = \frac{1}{1 + e^{-x}}.
$$

- **Tangente hiperbólica (tanh)**: Normaliza las salidas en el rango $[-1, 1]$. Suele
  preferirse frente a la sigmoide en capas ocultas porque sus activaciones tienen media
  cercana a cero, lo que facilita el entrenamiento. Tanto la sigmoide como la tangente
  hiperbólica tienden a saturarse en valores extremos, provocando gradientes muy
  pequeños que ralentizan el proceso de aprendizaje:

$$
\tanh(x) = \frac{e^x - e^{-x}}{e^x + e^{-x}}.
$$

En las **capas de salida**, la función de activación se selecciona según el rango de
valores esperado:

- **Clasificación binaria:** Sigmoide.
- **Clasificación multiclase (mutuamente excluyentes):** _Softmax_.
- **Clasificación multietiqueta:** Sigmoide, ya que una muestra puede pertenecer
  simultáneamente a varias clases.
- **Regresión:** Activación lineal, permitiendo que la salida adopte cualquier valor
  real.

### Implementación de una red neuronal

El siguiente ejemplo implementa una red neuronal de dos capas para un conjunto de datos
sintético. Este código ilustra de manera práctica cómo construir, entrenar y evaluar una
red neuronal simple utilizando **ReLU** en la capa oculta y **sigmoide** en la capa de
salida para un problema de clasificación binaria:

```py linenums="1"
import numpy as np
import matplotlib.pyplot as plt

# Crear dataset sintético
np.random.seed(0)
m = 200  # número de ejemplos
X = np.random.randn(2, m)  # 2 características
Y = (X[0, :] * X[1, :] > 0).astype(int).reshape(1, m)

# Funciones auxiliares
def sigmoid(z):
    return 1 / (1 + np.exp(-z))

def relu(z):
    return np.maximum(0, z)

def relu_derivative(z):
    return (z > 0).astype(float)

def compute_loss(Y, A):
    m = Y.shape[1]
    return -(1/m) * np.sum(Y*np.log(A+1e-8) + (1-Y)*np.log(1-A+1e-8))

# Inicializar parámetros
def initialize_parameters(n_x, n_h, n_y):
    np.random.seed(1)
    W1 = np.random.randn(n_h, n_x) * 0.01
    b1 = np.zeros((n_h, 1))
    W2 = np.random.randn(n_y, n_h) * 0.01
    b2 = np.zeros((n_y, 1))
    return {"W1": W1, "b1": b1, "W2": W2, "b2": b2}

# Forward propagation
def forward_propagation(X, params):
    W1, b1, W2, b2 = params["W1"], params["b1"], params["W2"], params["b2"]
    Z1 = np.dot(W1, X) + b1
    A1 = relu(Z1)
    Z2 = np.dot(W2, A1) + b2
    A2 = sigmoid(Z2)
    cache = {"Z1": Z1, "A1": A1, "Z2": Z2, "A2": A2}
    return A2, cache

# Backpropagation
def backward_propagation(X, Y, params, cache):
    m = X.shape[1]
    W2 = params["W2"]
    A1, A2, Z1 = cache["A1"], cache["A2"], cache["Z1"]

    dZ2 = A2 - Y
    dW2 = (1/m) * np.dot(dZ2, A1.T)
    db2 = (1/m) * np.sum(dZ2, axis=1, keepdims=True)

    dA1 = np.dot(W2.T, dZ2)
    dZ1 = dA1 * relu_derivative(Z1)
    dW1 = (1/m) * np.dot(dZ1, X.T)
    db1 = (1/m) * np.sum(dZ1, axis=1, keepdims=True)

    return {"dW1": dW1, "db1": db1, "dW2": dW2, "db2": db2}

# Actualizar parámetros
def update_parameters(params, grads, lr):
    params["W1"] -= lr * grads["dW1"]
    params["b1"] -= lr * grads["db1"]
    params["W2"] -= lr * grads["dW2"]
    params["b2"] -= lr * grads["db2"]
    return params

# Entrenamiento
def model(X, Y, n_h=3, num_iterations=10000, lr=0.1, print_loss=True):
    n_x, n_y = X.shape[0], Y.shape[0]
    params = initialize_parameters(n_x, n_h, n_y)

    for i in range(num_iterations):
        A2, cache = forward_propagation(X, params)
        loss = compute_loss(Y, A2)
        grads = backward_propagation(X, Y, params, cache)
        params = update_parameters(params, grads, lr)

        if print_loss and i % 1000 == 0:
            print(f"Iteración {i}, pérdida: {loss:.4f}")

    return params

# Predicciones
def predict(X, params):
    A2, _ = forward_propagation(X, params)
    return (A2 > 0.5).astype(int)

# Ejecutar el modelo
params = model(X, Y, n_h=3, num_iterations=10000, lr=0.1)
Y_pred = predict(X, params)
acc = np.mean(Y_pred == Y) * 100
print(f"Precisión final: {acc:.2f}%")
```

### División del conjunto de datos

En el entrenamiento de modelos de aprendizaje automático, la gestión adecuada de los
datos constituye un paso fundamental para garantizar un proceso de optimización
eficiente y una evaluación rigurosa del rendimiento.

Como se mencionó anteriormente, el descenso de gradiente estocástico permite aplicar el
algoritmo de optimización sobre subconjuntos de datos en lugar de sobre la totalidad del
conjunto de entrenamiento. Al evaluar el gradiente en un lote reducido, se obtiene
información temprana sobre el progreso de la optimización sin necesidad de procesar
todas las muestras, lo que facilita un aprendizaje más rápido y actualizaciones de los
parámetros con mayor frecuencia.

El uso de lotes resulta especialmente ventajoso en entornos con GPU, ya que estas
permiten almacenar los datos en memoria gráfica y ejecutar cálculos de manera altamente
paralelizada. El tamaño de los lotes depende principalmente de la capacidad de memoria
disponible, siendo comunes valores como 32, 64, 128 o superiores. En general, se tiende
a utilizar lotes tan grandes como lo permita la memoria, aunque el tamaño seleccionado
puede afectar las métricas de evaluación del modelo. Por ejemplo, en arquitecturas
basadas en _autoencoders_, se observa un mejor desempeño con lotes pequeños, ya que esto
limita la tendencia de la red a memorizar patrones específicos. En contraste, en tareas
supervisadas de clasificación de imágenes o en metodologías contrastivas, los lotes más
grandes suelen ser beneficiosos, ya que permiten calcular un mayor número de métricas de
distancia entre pares de muestras y construir matrices de similitud más robustas.

En contextos de aprendizaje autosupervisado, el modo en que se agrupan las muestras en
lotes afecta directamente tanto a las funciones de coste como al proceso de
optimización, ya que muchas de estas funciones se basan en medidas de distancia entre
elementos de un mismo lote. Incluso en modelos de lenguaje de gran escala se ha
observado que la forma de dividir los datos en lotes repercute en la salida final del
modelo, generando variabilidad que se explica no solo por errores numéricos, sino
también por la composición de los mini-lotes y las distribuciones de las muestras que
los componen.

El procedimiento habitual consiste en aplicar una permutación aleatoria (_shuffle_) al
conjunto de entrenamiento y dividirlo en lotes consecutivos de tamaño fijo. Una vez
procesados todos los lotes, se vuelve a permutar el conjunto y se repite el proceso.
Esta división puede distribuirse entre múltiples nodos o GPU, lo que se conoce como
**paralelización de datos**: cada GPU procesa de manera independiente un lote, calcula
los gradientes correspondientes, y posteriormente todos los gradientes se agregan de
forma síncrona para actualizar los parámetros globales de la red. Cuando el lote
completo no cabe en una sola GPU, se puede recurrir a la **acumulación de gradientes**,
que consiste en iterar sobre subconjuntos más pequeños acumulando los gradientes antes
de realizar la actualización, aunque este enfoque es menos eficiente al no aprovechar
plenamente la paralelización del hardware.

```py linenums="1"
from torch.utils.data import DataLoader
dataloader = DataLoader(dataset, shuffle=True, batch_size=32)
for xb, yb in dataloader:
    pass  # Procesamiento del lote
```

De manera clásica, durante el desarrollo de modelos de aprendizaje automático los
conjuntos de datos se dividen en tres subconjuntos principales:

1. **Conjunto de entrenamiento**: Se emplea para ajustar los parámetros internos del
   modelo mediante el proceso de optimización.
2. **Conjunto de validación**: Formado por ejemplos no utilizados en el entrenamiento
   directo. Su función es evaluar la capacidad de generalización del modelo y guiar la
   selección de hiperparámetros, reduciendo el riesgo de sobreajuste.
3. **Conjunto de prueba**: Reservado para la evaluación final y objetiva del modelo una
   vez completado el entrenamiento y optimizados los hiperparámetros.

La proporción destinada a cada subconjunto depende de la cantidad de datos disponibles.
Con bases de datos pequeñas, se suele aplicar una partición del 70 % para entrenamiento
y 30 % para prueba. En bases de datos más extensas, resulta común asignar un 60 % al
entrenamiento, 20 % a la validación y 20 % a la prueba. Es esencial que los subconjuntos
de validación y prueba sigan la misma distribución que los datos de entrenamiento, ya
que una discrepancia significativa puede generar degradaciones en las métricas de
evaluación. Cuando los datos son escasos, la **validación cruzada K-fold** constituye
una alternativa robusta: el conjunto de datos se divide en $K$ particiones, se entrenan
$K$ modelos idénticos utilizando $K-1$ particiones para entrenamiento y la restante para
validación, y la métrica final se obtiene como el promedio de las $K$ evaluaciones.

En entornos de producción, las distribuciones de los datos suelen variar con el tiempo,
fenómeno conocido como **cambio de concepto (_concept drift_)**. Para detectar y
cuantificar estas desviaciones se utilizan métricas como la divergencia de
Kullback-Leibler, la divergencia de Jensen-Shannon u otras medidas de distancia entre
distribuciones. Asimismo, técnicas como el análisis de entropía, los _autoencoders_ o el
Análisis de Componentes Principales (PCA) permiten medir errores de reconstrucción y
establecer umbrales para identificar muestras fuera de distribución. La detección de
datos fuera de distribución constituye una línea de investigación activa, con
aplicaciones en el aprendizaje activo, el _meta-learning_ y la mitigación del olvido
catastrófico.

Es importante tener en cuenta ciertas consideraciones al dividir los datos. Si se
trabaja con datos temporales (predicción del futuro a partir del pasado), no se deben
mezclar aleatoriamente antes de la división, ya que esto crearía una fuga temporal donde
el modelo se entrenaría con datos del futuro. En estos casos, los datos de prueba deben
ser siempre posteriores a los de entrenamiento. Además, si existen datos duplicados o
redundantes, es necesario asegurarse de que no aparezcan simultáneamente en los
conjuntos de entrenamiento y validación, ya que esto equivaldría a evaluar el modelo con
parte de sus propios datos de entrenamiento.

### Sesgo y varianza

El análisis de sesgo y varianza constituye una herramienta fundamental para comprender
las fuentes de error en los modelos de aprendizaje automático. El **sesgo** se define
como la diferencia sistemática entre las predicciones del modelo y los valores reales.
Un sesgo alto indica la presencia de subajuste, lo que significa que el modelo no logra
capturar de manera adecuada la complejidad de la relación existente en los datos. Por
otro lado, la **varianza** mide la sensibilidad del modelo frente a pequeñas variaciones
en los datos de entrenamiento. Una varianza alta refleja la existencia de sobreajuste.

La reducción del sesgo suele requerir un aumento en la capacidad de representación del
modelo, mediante arquitecturas más profundas o complejas, el incremento del número de
parámetros, un mayor tiempo de entrenamiento o la adopción de algoritmos alternativos.
En contraste, para disminuir la varianza se recurre a estrategias orientadas a mejorar
la capacidad de generalización, tales como el incremento de la cantidad y diversidad de
datos de entrenamiento, la aplicación de técnicas de regularización o ajustes en la
arquitectura y en los hiperparámetros del modelo.

En la práctica, el análisis de sesgo y varianza se complementa con la noción de **techo
de referencia humano**, empleado para evaluar modelos cuyo desempeño se compara con el
nivel de expertos humanos. En este marco, el **sesgo evitable** se entiende como la
diferencia entre el error mínimo alcanzable por un ser humano y el error observado en el
modelo, mientras que la **varianza** se cuantifica como la diferencia entre el error en
el conjunto de entrenamiento y el error en el conjunto de validación.

### Desvanecimiento y explosión de gradientes

Uno de los principales desafíos en el entrenamiento de redes neuronales profundas es el
fenómeno conocido como desvanecimiento o explosión de gradientes. Ambos problemas se
presentan durante el proceso de _backpropagation_, cuando los gradientes tienden a
disminuir hasta valores cercanos a cero o, por el contrario, a crecer de manera
exponencial. Esta inestabilidad dificulta o incluso imposibilita el aprendizaje, ya que
los parámetros no se actualizan de manera adecuada. En la práctica, este comportamiento
puede provocar que la función de pérdida devenga en valores **NaN** (_Not a Number_),
interrumpiendo el proceso de optimización.

Para mitigar estos fenómenos se emplean diversas estrategias:

- **Inicialización adecuada de los pesos**: Métodos como Xavier o He ajustan la escala
  inicial de los parámetros según la cantidad de neuronas por capa, evitando que los
  gradientes crezcan o decrezcan de manera descontrolada desde el inicio del
  entrenamiento.
- **Normalización de los datos de entrada**: Escalar las características de entrada para
  que tengan media cero y varianza unitaria contribuye a estabilizar el flujo de
  gradientes.
- **Funciones de activación más estables**: El uso de activaciones como ReLU y sus
  variantes reduce la saturación observada en funciones como la sigmoide o la tangente
  hiperbólica.
- **Clipado de gradientes**: Consiste en limitar el rango de valores que pueden alcanzar
  los gradientes durante la retropropagación, evitando actualizaciones excesivas. Es
  común emplear intervalos como $[-1, 1]$, aunque también existen variantes dinámicas.
- **Diseño arquitectónico específico**: La introducción de mecanismos de memoria y
  compuertas en redes como LSTM o GRU permite manejar dependencias de largo plazo. Más
  recientemente, los _Transformers_ han reemplazado en gran medida a las RNN, reduciendo
  estas limitaciones.

### Estrategia en el proceso de optimización

El diseño de una estrategia adecuada en el desarrollo de modelos de aprendizaje
automático resulta crucial para alcanzar un rendimiento óptimo. No todas las mejoras
introducidas durante el proceso de construcción del modelo tienen el mismo impacto en su
desempeño. En muchos casos, incrementar la cantidad y diversidad de datos disponibles o
modificar de manera sustancial la arquitectura de la red genera beneficios mucho mayores
que ajustes menores sobre los hiperparámetros.

Las métricas de evaluación dependen directamente del tipo de aprendizaje empleado,
aunque comparten el objetivo común de cuantificar la calidad de las predicciones. En
aprendizaje supervisado de clasificación, destacan medidas como la **precisión**, el
**recall** o sensibilidad, y la **puntuación F1**, definida como la media armónica entre
la precisión y el recall. Más allá de las métricas de exactitud, es indispensable
considerar indicadores de **eficiencia computacional**, tales como el tiempo de
entrenamiento, la latencia en la inferencia, el consumo de memoria y la escalabilidad
del modelo.

Para implementar una estrategia de aprendizaje coherente y sostenible, se recomienda
emplear plataformas especializadas en la gestión de experimentos, como **MLflow**,
**Weights & Biases (wandb)** y soluciones similares. Estas herramientas permiten
registrar y organizar de forma sistemática todos los artefactos generados durante el
desarrollo del modelo, garantizando la **replicabilidad de los experimentos** y
facilitando la **comparación justa entre diferentes configuraciones**.

### Aprendizaje por transferencia

Además de las arquitecturas tradicionales, en el campo del aprendizaje profundo se han
desarrollado enfoques que no constituyen arquitecturas en sí mismas, sino **paradigmas
de aprendizaje** que buscan aprovechar de manera más eficiente los recursos
computacionales y los datos disponibles.

El **aprendizaje por transferencia** consiste en reutilizar el conocimiento adquirido
por un modelo previamente entrenado en una tarea determinada para aplicarlo en otra
tarea relacionada. La similitud entre las tareas es un requisito fundamental: no resulta
viable transferir directamente el conocimiento de un modelo entrenado en visión por
computadora a uno diseñado para procesar texto, ya que las representaciones internas
aprendidas difieren por completo.

El grado de reutilización depende en gran medida de la disponibilidad de datos en la
nueva tarea. Cuando los datos son escasos, suele reajustarse únicamente la parte final
de la red, mientras que el resto de la arquitectura se congela, preservando así las
representaciones generales previamente aprendidas. En cambio, cuando se dispone de una
cantidad suficiente de datos, es posible aplicar un ajuste fino o **_fine-tuning_**, que
consiste en reentrenar toda la red para adaptar gradualmente los parámetros a las
particularidades del nuevo dominio.

## Diferenciación automática

La diferenciación numérica, simbólica y automática constituye un conjunto de enfoques
complementarios para obtener derivadas de funciones. Cada método se fundamenta en
principios distintos y presenta características particulares que determinan su
precisión, su coste computacional y su aplicabilidad.

La **diferenciación numérica** aproxima la derivada a partir de valores concretos de la
función, sin manipular expresiones algebraicas ni reglas simbólicas. Se basa
directamente en la definición de derivada y sustituye el límite por un incremento finito
$h$ suficientemente pequeño. La formulación más simple es la diferencia hacia adelante,
mientras que la diferencia centrada ofrece mayor precisión con un error de orden
$O(h^2)$:

$$
f'(x) \approx \frac{f(x+h) - f(x)}{h}, \quad f'(x) \approx \frac{f(x+h) - f(x-h)}{2h}.
$$

El método opera exclusivamente con números y produce resultados aproximados cuya calidad
depende de la elección de $h$. Si $h$ es demasiado grande, la aproximación se degrada;
si es demasiado pequeño, emergen errores de redondeo asociados a la aritmética de coma
flotante. Además, cada derivada requiere varias evaluaciones de la función, lo que
vuelve esta técnica poco viable para problemas con grandes cantidades de variables. Por
ello se emplea sobre todo con fines de validación o en contextos de baja
dimensionalidad.

La **diferenciación simbólica** opera directamente sobre la expresión matemática de la
función y utiliza reglas formales de derivación para obtener una fórmula exacta. Este
enfoque trabaja con símbolos en lugar de valores numéricos y permite obtener derivadas
sin aproximaciones. Sin embargo, al manipular expresiones complejas puede generar
fórmulas extremadamente grandes, fenómeno conocido como _expression swell_. Esta
explosión combinatoria limita su aplicación en programas extensos o en funciones
definidas de forma procedimental.

La **diferenciación automática** (AD) se sitúa conceptualmente entre los dos métodos
anteriores. No se basa en aproximaciones numéricas ni en transformaciones simbólicas
exhaustivas, sino en la evaluación sistemática de la estructura computacional de la
función. Aplica las reglas del cálculo diferencial durante la ejecución del programa y
propaga derivadas elementales a través de las operaciones que lo componen. El resultado
es exacto hasta los límites de la precisión de máquina, sin incurrir en errores de
aproximación ni en crecimiento explosivo de expresiones. En modo directo, el coste es
proporcional al número de variables; en modo inverso, utilizado en aprendizaje
automático para implementar _backpropagation_, el coste es comparable al de evaluar la
propia función. Esta eficiencia explica su papel central en la optimización de modelos
contemporáneos.
