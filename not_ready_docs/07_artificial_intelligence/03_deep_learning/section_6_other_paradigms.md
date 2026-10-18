---
authors: Daniel Bazo Correa
description: Otros paradigmas de aprendizaje y flujo de trabajo.
title: Otros paradigmas
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Este capítulo explora paradigmas de aprendizaje complementarios como el aprendizaje
multitarea, meta-learning, few-shot learning y autoencoders.

## Aprendizaje multitarea

El **aprendizaje multitarea (_Multi-Task Learning_)** persigue que un mismo modelo sea
capaz de resolver de manera simultánea múltiples problemas relacionados. La idea central
es que al compartir representaciones internas entre diferentes tareas, la red aprende
descriptores más generales y robustos que benefician a todas ellas. Un ejemplo
paradigmático se encuentra en la conducción autónoma, donde un único modelo puede
segmentar imágenes, clasificar señales de tráfico y predecir trayectorias
simultáneamente.

El objetivo general se formula como:

$$
\min_{\theta} \sum_{i=1}^{T} w_i \cdot L_i(\theta, D_i),
$$

donde $D_i$ es el conjunto de datos de la tarea $i$ y $w_i$ permite ajustar la
relevancia de cada tarea. Las principales estrategias incluyen el uso de _embeddings_
condicionales, sistemas _multi-head_ (un modelo único con múltiples salidas) y
condicionales multiplicativos.

## _Meta-learning_

El **_Meta-Learning_** se enfoca en dotar a los modelos de la habilidad de identificar y
aprovechar patrones subyacentes en los datos, lo que les permite adaptarse rápidamente a
nuevos problemas con un mínimo de información. Este enfoque es particularmente útil en
escenarios con datos limitados o costosos de obtener.

## _Few-shot learning_

El **_Few-Shot Learning_ (FSL)** se centra en entrenar modelos que logren un alto
rendimiento con un número muy limitado de ejemplos etiquetados por clase. Se organiza en
torno a un **_Support Set_** (conjunto de entrenamiento con pocas muestras etiquetadas)
y un **_Query Set_** (conjunto de prueba). El aprendizaje se describe según dos
parámetros: **_K-shot Learning_** (número de ejemplos por clase) y **_N-way
Classification_** (número de clases diferentes).

Existen dos tipos de modelos en este régimen: los **modelos no parametrizados** (como
_k-Nearest Neighbors_), simples y eficaces cuando se dispone de _embeddings_ de alta
calidad, y los **modelos parametrizados** (redes neuronales profundas), que generan
_embeddings_ que capturan las características relevantes en un espacio de menor
dimensionalidad.

El planteamiento habitual consiste en aprender una **función de similitud**
$\mathrm{Sim}(\mathbf{x}, \mathbf{x}')$ que indique en qué grado dos muestras pertenecen
a la misma clase. Con dos imágenes de gato $\mathbf{x}_1$ y $\mathbf{x}_2$ y una imagen
de perro $\mathbf{x}_3$, la función ideal devolvería $\mathrm{Sim}(\mathbf{x}_1,
\mathbf{x}_2) = 1$ frente a $\mathrm{Sim}(\mathbf{x}_1, \mathbf{x}_3) = 0$. El
procedimiento se divide en dos fases: primero se aprende la función de similitud sobre
un conjunto de entrenamiento de gran tamaño, y después se aplica para la predicción
comparando la muestra de consulta con cada elemento del _Support Set_ y seleccionando
aquel que obtenga la mayor puntuación.

El rendimiento depende de forma sistemática de los dos parámetros que caracterizan el
_Support Set_. La precisión disminuye al aumentar el número de clases (_ways_), puesto
que crece la complejidad del problema y con ella la probabilidad de confusión. Por el
contrario, la precisión aumenta con el número de ejemplos por clase (_shots_), al
disponer el modelo de más evidencia sobre cada categoría.

Los conjuntos de datos de referencia para evaluar estos modelos son **Omniglot**, que
reúne caracteres manuscritos de numerosos alfabetos, y **miniImageNet**, un subconjunto
reducido de ImageNet diseñado específicamente para este régimen de aprendizaje.

## Aprendizaje autosupervisado

El principal problema del aprendizaje supervisado radica en la cantidad de datos
etiquetados que se requieren, el tiempo necesario para etiquetar de manera manual y los
sesgos que pueden introducir los anotadores. La gran mayoría de los datos disponibles
son no etiquetados, por lo que obtener abstracciones que permitan generalizaciones a
partir de datos sin etiquetar resulta fundamental. Este es el proceso natural de
aprendizaje humano: adquirir ideas y luego extrapolar el conocimiento.

El aprendizaje autosupervisado está estrechamente relacionado con el aprendizaje
multimodal. El aprendizaje requiere conocimiento previo y redundancia en las señales.
Cuando se aprenden asociaciones entre $N$ eventos, es necesario almacenar $N^2$ posibles
probabilidades; si los eventos son independientes, las probabilidades pueden calcularse
por separado y la probabilidad total es el producto de las probabilidades individuales.

Entre las técnicas de aprendizaje autosupervisado destacan: _inpainting_ (reconstrucción
de regiones ocultas), reordenación de _puzzles_ (recomponer parches desordenados de una
imagen), colorización de imágenes en escala de grises, predicción de rotaciones,
aprendizaje contrastivo, _pseudo-labelling_ (entrenar un modelo supervisado con datos
etiquetados, predecir datos no etiquetados y reentrenar con las pseudoetiquetas
generadas) y aprendizaje de puntos clave de objetos.

## Autoencoders

Los **Autoencoders** son redes neuronales diseñadas para aprender representaciones
comprimidas de los datos de forma no supervisada. Su arquitectura se compone de dos
partes fundamentales: un **encoder** $g_{\phi}(\cdot)$, parametrizado con $\phi$, que
comprime la entrada $x$ en una representación de menor dimensionalidad denominada
**espacio latente** $z$; y un **decoder** $g_{\theta}(\cdot)$, parametrizado con
$\theta$, que reconstruye la entrada original a partir de la representación latente. El
objetivo del entrenamiento es minimizar el error de reconstrucción entre la entrada
original y la salida reconstruida.

Desde una perspectiva probabilística, el encoder estima la probabilidad posterior
$q_{\phi}(z|x)$ y el decoder modela la probabilidad de generar los datos
$p_{\theta}(x|z)$.

Los autoencoders tienden al sobreajuste, por lo que se emplean diversas técnicas de
regularización para mejorar su capacidad de generalización:

- **Denoising Autoencoders**: Se agrega ruido gaussiano a la entrada o se eliminan
  partes de la imagen de forma estocástica (mediante técnicas como _Dropout_,
  _DropBlock_ o _SpatialDropout_), forzando al modelo a aprender representaciones más
  robustas.
- **Sparse Autoencoders**: Penalizan o fuerzan al modelo a mantener un número reducido
  de neuronas activadas simultáneamente. En el caso del **k-Sparse Autoencoder**, solo
  se mantienen activas las $k$ activaciones más altas, poniendo el resto a cero.
- **Contractive Autoencoders**: Penalizan la sensibilidad de la representación latente
  respecto a los datos de entrada, midiendo esta sensibilidad mediante la norma de
  Frobenius de la **matriz Jacobiana** de las activaciones del encoder con respecto a la
  entrada:

$$
J_f(x) = \sum_{i,j} \left( \frac{\partial h_j(x)}{\partial x_i} \right)^2.
$$

### Autoencoders variacionales

El autoencoder descrito hasta aquí es **determinista**: una misma entrada produce
siempre la misma representación latente, puesto que los pesos permanecen fijos durante
la inferencia. Los **autoencoders variacionales** (_Variational Autoencoders_, VAE)
modifican este planteamiento aprendiendo, en lugar de un punto del espacio latente, los
parámetros de una distribución. Concretamente, el _encoder_ produce una media $\mu$ y
una desviación típica $\sigma$ a partir de las cuales se muestrea la representación
latente. Esta formulación convierte el espacio latente en un espacio continuo y
estructurado del que es posible muestrear para generar datos nuevos.

Para que las distribuciones aprendidas no se alejen arbitrariamente de una distribución
conocida, se incorpora a la función de pérdida un término basado en la **divergencia de
Kullback-Leibler** entre la distribución posterior aproximada y una distribución normal
estándar. Para una representación latente de $k$ dimensiones toma la forma:

$$
-\frac{1}{2} \sum_{j=0}^{k-1} \left(\sigma_j + \mu_j^2 - 1 - \log \sigma_j\right)
$$

Este término actúa como regularizador y se suma al error de reconstrucción habitual.

El muestreo plantea un obstáculo para el entrenamiento. La retropropagación requiere
nodos deterministas, es decir, operaciones sin componentes aleatorios a través de las
cuales pueda propagarse el gradiente. La solución es el **truco de reparametrización**,
que extrae la aleatoriedad del camino del gradiente:

$$
\mathbf{z} \sim N(\mu, \sigma^2) \quad \longrightarrow \quad \mathbf{z} = \mu + \sigma
\odot \varepsilon
$$

$$
\varepsilon \sim N(0, 1)
$$

En esta reformulación $\mu$ y $\sigma$ son salidas deterministas de la red y
$\varepsilon$ es una muestra de ruido gaussiano independiente de los parámetros. El
gradiente fluye entonces a través de $\mu$ y $\sigma$, mientras que $\varepsilon$ actúa
como una constante en cada paso. La generación de muestras gaussianas con una covarianza
determinada se apoya en la descomposición de Cholesky, tratada en el capítulo de
[fundamentos matemáticos](../01_mathematics/section_2_deep_learning_math.md).

Una variante de interés es el **β-VAE**, que introduce un factor de ponderación sobre el
término de divergencia. Al ajustar ese factor se favorece el **desenredado del espacio
latente** (_latent space disentanglement_), de forma que dimensiones distintas de la
representación capturen factores de variación independientes, lo que produce una
codificación más eficiente e interpretable.

## Flujo de trabajo para el desarrollo de modelos

El flujo de trabajo para el desarrollo de modelos de aprendizaje profundo se estructura
en tres fases principales.

La primera fase consiste en **definir la tarea**: comprender el dominio del problema y
la lógica subyacente, recopilar un conjunto de datos representativo, comprender qué
representan los datos y elegir cómo medir el éxito. Es fundamental enmarcar
correctamente el problema, identificando el tipo de tarea (clasificación binaria,
multiclase, regresión, segmentación, etc.), las soluciones existentes y las
restricciones del entorno (cifrado, latencia, dispositivo de destino). Un buen conjunto
de datos es un activo que merece cuidado e inversión; si se dispone de tiempo adicional,
dedicarlo a recopilar más datos suele ser más efectivo que buscar mejoras incrementales
en el modelado. La infraestructura de anotación de datos determina la calidad de las
etiquetas y, por tanto, la calidad del modelo.

La segunda fase es **desarrollar un modelo**: preparar los datos para que puedan ser
procesados (normalización, limpieza, manejo de valores faltantes), seleccionar un
protocolo de evaluación, establecer un punto de referencia simple a superar, entrenar un
primer modelo con capacidad de generalización y, finalmente, regularizar y ajustar hasta
lograr el mejor rendimiento posible. La **ingeniería de características** (_feature
engineering_) consiste en aplicar transformaciones codificadas a los datos antes de que
ingresen al modelo, haciendo el problema más fácil de resolver. Aunque el aprendizaje
profundo moderno reduce la necesidad de esta ingeniería, las buenas características
siguen permitiendo resolver problemas de manera más elegante y con menos datos.

La tercera fase es **desplegar el modelo**: presentar los resultados a las partes
interesadas con expectativas realistas (evitando declaraciones abstractas como "98% de
precisión" y prefiriendo hablar de tasas de falsos negativos y falsos positivos
vinculadas a objetivos de negocio), optimizar el modelo para inferencia mediante
técnicas como la **poda de pesos** (_weight pruning_) y la **cuantización de pesos**
(_weight quantization_), y supervisar el rendimiento del modelo en producción para
detectar degradaciones y recopilar datos para futuras iteraciones.
