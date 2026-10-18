---
authors: Daniel Bazo Correa
description: Redes neuronales convolucionales y procesamiento de imágenes.
title: Redes convolucionales
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Este capítulo presenta las redes neuronales convolucionales, su inspiración biológica,
los componentes fundamentales de la convolución y las arquitecturas más relevantes.

## Procesamiento visual humano y su analogía con las redes convolucionales

El procesamiento visual humano es un proceso jerárquico que transforma la información
lumínica captada por los ojos en representaciones visuales complejas y significativas.
La luz ingresa al ojo a través de la córnea y atraviesa el cristalino, que actúa como
una lente convexa proyectando la imagen invertida sobre la retina. En la retina, los
fotorreceptores (conos y bastones) convierten la energía lumínica en señales eléctricas,
iniciando la codificación neuronal de la información visual.

Estas señales se transmiten por el nervio óptico hasta el quiasma óptico, donde ocurre
un cruce parcial de la información visual que permite la percepción binocular y
contribuye a la percepción de profundidad. Posteriormente, las señales continúan hasta
el núcleo geniculado lateral (LGN) del tálamo, que funciona como estación de relevo y
organiza la información entrante. Desde el LGN, las señales se transmiten hacia la
corteza visual primaria (V1), localizada en el lóbulo occipital, que se organiza de
manera retinotópica.

En la corteza visual primaria se distinguen tres tipos principales de células: células
simples, que responden a bordes con orientación específica; células complejas, que
detectan bordes o movimientos en rangos más amplios; y células hipercomplejas, que
reaccionan ante combinaciones más sofisticadas, como esquinas o terminaciones de líneas.
El procesamiento continúa en áreas corticales posteriores (V2, V4, IT), donde se
analizan características más complejas, incluyendo texturas, formas tridimensionales,
rostros y objetos completos.

Las redes neuronales convolucionales, también conocidas como **_Convolutional Neural
Networks_ (CNNs)**, son modelos computacionales diseñados para procesar datos visuales
de manera eficiente, inspirados directamente en esta arquitectura del sistema visual
humano:

| Sistema Visual Humano                      | Redes Convolucionales (CNNs)                                     |
| ------------------------------------------ | ---------------------------------------------------------------- |
| Retina                                     | Imagen de entrada                                                |
| Nervio óptico / Quiasma óptico             | Preprocesamiento y alineación de la información visual           |
| LGN (núcleo geniculado lateral)            | División en canales o filtros por tipo de característica         |
| Corteza visual (V1, V2, V4, IT)            | Capas convolucionales jerárquicas                                |
| Células simples, complejas, hipercomplejas | Filtros convolucionales de bajo, medio y alto nivel              |
| Campos receptivos                          | Regiones locales (_receptive fields_) de los filtros (_kernels_) |
| Percepción jerárquica                      | Aprendizaje progresivo de características visuales               |

## Campo receptivo y jerarquía de procesamiento

El **campo receptivo** se define como la región del campo visual (o de la entrada) que
influye directamente en la actividad de una neurona específica. En las etapas iniciales
del procesamiento, los campos receptivos son pequeños y especializados en detectar
patrones simples. A medida que se avanza jerárquicamente, los campos receptivos se
expanden y se vuelven más complejos, integrando información de múltiples regiones para
formar representaciones más abstractas y globales.

En las redes convolucionales, el campo receptivo se puede simular definiendo ceros en
las matrices de pesos para aquellas regiones de píxeles que se encuentran fuera de la
zona de interés. Cada píxel tiene una relación con sus vecinos que puede representarse
como un grafo completamente conectado, donde la importancia de cada conexión depende de
la distancia entre los píxeles. Al colocar un cero en la matriz de pesos, se elimina la
influencia de un píxel vecino sobre el píxel evaluado. El campo receptivo crece
linealmente con el número de capas convolucionales, lo que motiva la noción de
**localidad**: aunque una sola capa está limitada por el tamaño del _kernel_, una pila
suficientemente grande de capas convolucionales resulta en un campo receptivo global.

## Conceptos fundamentales de la convolución

La visión computacional constituye uno de los campos más dinámicos de la inteligencia
artificial, con aplicaciones que abarcan desde la conducción autónoma hasta el
reconocimiento facial, la clasificación automática de imágenes y la segmentación de
objetos. Las redes convolucionales pueden trabajar con datos secuenciales de cualquier
tipo, aprovechando dos características fundamentales: la **capacidad de localización** y
el **compartimiento de parámetros**. Estas propiedades confieren a la operación de
convolución cierta invariancia a la traslación de la ventana (el propio _kernel_ o
filtro), aunque en la práctica esta propiedad se rompe cuando se combinan con otras
operaciones como mecanismos de _pooling_.

El principio subyacente que permite la transferencia de conocimiento entre dominios es
la existencia de una estructura espacio-temporal en los datos. En el caso de las
imágenes, esta estructura se refleja en la disposición relativa de los píxeles. Si se
logra transformar otros tipos de datos en representaciones visuales que conserven dicha
organización, es posible aplicar arquitecturas convolucionales de manera eficaz. Un
ejemplo de este enfoque se observa en la conversión de series temporales en imágenes
mediante técnicas como los _Gramian Angular Fields_, o en la transformación de señales
de audio en espectrogramas de tipo _Mel_.

El principal desafío al trabajar con imágenes radica en la elevada cantidad de
información que contienen. Una imagen en color de 64 × 64 píxeles con tres canales de
color requiere **12288 entradas** para la red neuronal. Introducir directamente esta
cantidad de datos en una arquitectura densa obligaría a disponer de capas iniciales con
decenas de miles de neuronas, lo que genera un coste computacional muy alto y un elevado
riesgo de sobreajuste.

La solución a este problema se encuentra en la operación de **convolución**. Este
procedimiento aplica filtros, también denominados _kernels_, que recorren la imagen en
busca de patrones característicos como bordes, esquinas o texturas. El resultado de cada
aplicación es un **mapa de características** (_activation map_), que cuantifica la
presencia del patrón detectado en diferentes regiones de la imagen. Desde el punto de
vista del procesamiento de señales, esta operación corresponde a un filtrado mediante
filtros de respuesta finita al impulso (FIR), implementado a través de una convolución
discreta. A diferencia de los filtros clásicos diseñados manualmente (como Sobel o
Scharr), los filtros de las redes convolucionales se inicializan aleatoriamente y se
entrenan mediante descenso del gradiente, lo que permite al modelo descubrir patrones
mucho más complejos y adaptados a la tarea específica.

Una propiedad fundamental de este mecanismo es la **invariancia al desplazamiento**, que
permite reconocer un mismo patrón independientemente de su ubicación. Esta invariancia
se origina gracias al compartimiento de pesos entre los diferentes filtros: lo que se
aprende en una parte de la imagen se traslada a otra parte. No obstante, esta propiedad
se manifiesta de manera estricta únicamente cuando la convolución se realiza con un
tamaño de paso igual a uno, y puede perderse parcialmente al introducir variaciones como
_stride_, _padding_ o capas densas posteriores.

A medida que la información avanza a través de las capas convolucionales, el tamaño
espacial de las representaciones disminuye mientras que el número de canales se
incrementa. Este proceso permite capturar progresivamente patrones de mayor nivel de
abstracción. En las imágenes, la influencia de un píxel sobre sus vecinos suele
reducirse con el incremento de la distancia, lo que implica que a mayor distancia entre
píxeles, menor correlación existe entre ellos. Esta propiedad de **localidad** es
fundamental en mecanismos modernos como la atención, que evalúan la importancia de los
píxeles vecinos para obtener un mejor entendimiento de la semántica de la imagen.

Las capas convolucionales no dependen del tamaño de la imagen de entrada, sino del
tamaño del filtro y del número de canales utilizados. Sin embargo, en la práctica
resulta complicado procesar tensores de tamaños variables en un mismo lote, y además
pueden surgir problemas como el olvido catastrófico, ya que entrenar con distribuciones
de datos de tamaños muy diferentes altera las relaciones entre píxeles vecinos y las
componentes de alta frecuencia.

## Componentes de una capa convolucional

El uso de convoluciones en redes neuronales introduce una serie de elementos esenciales.
El **relleno (_padding_)** consiste en añadir bordes artificiales alrededor de la imagen
para evitar la pérdida de información en los márgenes y mantener las dimensiones
originales de la entrada. El **desplazamiento (_stride_)** define el número de píxeles
que el filtro avanza en cada paso al recorrer la imagen; un valor mayor reduce las
dimensiones de la salida y disminuye el número de cálculos necesarios. Cuando el tamaño
del _stride_ coincide con el del filtro, el proceso es equivalente a dividir la imagen
en fragmentos independientes (_patches_), concepto que ha dado lugar a arquitecturas
avanzadas basadas en _Transformers_, como **ViT** (_Vision Transformer_), donde cada
submatriz de la imagen se convierte en un _token_ que el modelo procesa.

En el caso de imágenes en color, los filtros se extienden a tres dimensiones para
recorrer simultáneamente los canales rojo, verde y azul. El número de parámetros de una
capa convolucional depende únicamente del tamaño y la cantidad de filtros, y no de las
dimensiones de la imagen de entrada. Por ejemplo, una capa con 10 filtros de 3 × 3 × 3
requiere solo 280 parámetros, cifra muy reducida frente a los millones de conexiones que
implicaría una arquitectura densa equivalente.

Las convoluciones resultan efectivas por dos motivos principales: permiten una
**reducción drástica del número de parámetros** y implementan la **compartición de
parámetros**, ya que un patrón aprendido en una región de la imagen puede aplicarse en
cualquier otra.

Tras la convolución, suele aplicarse una etapa de **agrupamiento (_pooling_)**,
destinada a reducir las dimensiones intermedias y aportar robustez frente a pequeñas
variaciones espaciales. La técnica más extendida es el **_max pooling_**, que selecciona
el valor máximo dentro de cada región, priorizando la detección de la presencia de una
característica por encima de su ubicación exacta. Otra variante frecuente es el
**_average pooling_**, que sustituye cada región por el valor promedio de sus elementos.
Los mecanismos de _pooling_ global destruyen la información espacial, por lo que se
implementan técnicas parciales como el _max pooling_ con ventanas de 2 × 2, que permite
reducir la resolución espacial a la mitad manteniendo el número de canales intacto.

En la gran mayoría de arquitecturas modernas basadas en convolución, ya no se utilizan
capas densas finales con aplanamiento de tensores. En su lugar, se emplea **_Global
Average Pooling_**, que consiste en calcular el promedio global de los valores de cada
mapa de características, obteniendo un único valor por canal. Este mecanismo es
invariante a los desplazamientos, preserva la información espacial, y reduce
significativamente la cantidad de parámetros en comparación con el aplanamiento seguido
de capas densas. Sin embargo, la agregación uniforme del _Global Average Pooling_ puede
generar una geometría pobre en las representaciones embebidas del modelo.

La arquitectura típica de una red convolucional se divide en dos partes: el
**_backbone_** (esqueleto del modelo), que utiliza capas convolucionales para extraer
características de los datos de entrada, y la **cabeza** (_head_), que emplea las capas
finales para realizar la tarea específica (clasificación, regresión, etc.).

## Tipos de operaciones convolucionales

Existen variantes especializadas de la convolución que permiten optimizar el
procesamiento:

- **Convolución 1×1 (_pointwise convolution_)**: Actualiza la representación de cada
  píxel mediante una combinación ponderada de sus canales, sin considerar los píxeles
  vecinos. Resulta útil para modificar la dimensión de canales.
- **Convolución en profundidad (_depthwise convolution_)**: Combina píxeles en un
  vecindario pequeño, pero procesando cada canal de manera independiente. Puede
  generalizarse considerando grupos de canales (_groupwise convolution_).
- **Convolución separable en profundidad (_depthwise separable convolution_)**: Alterna
  convoluciones 1×1 (para mezclar canales) y convoluciones en profundidad (para mezclar
  píxeles). Es común en CNNs diseñadas para dispositivos de bajo consumo, como
  MobileNet.

## Evolución de las arquitecturas

El incremento en la profundidad de las redes neuronales ha permitido avances
significativos en la visión computacional. Sin embargo, a partir de cierto punto, el
rendimiento no mejora sino que se degrada, debido a fenómenos como la desaparición o
explosión de gradientes.

La solución a este desafío surgió con las **redes residuales (ResNet)**, que incorporan
**conexiones de atajo (_skip connections_)** que transmiten directamente las
activaciones de una capa hacia otra más profunda. Cada bloque residual no aprende una
transformación completa, sino la diferencia (_residuo_) entre la entrada y la salida
esperada. Las redes residuales pueden verse como la suma de múltiples caminos donde la
entrada permanece sin alterar a la par que recibe transformaciones o combinaciones de
múltiples transformaciones. El número de caminos crece exponencialmente con el número de
bloques residuales, y estos caminos pueden interpretarse como pequeños modelos que
comparten información entre sí mediante _weight-sharing_. Desde una perspectiva
neurocientífica, este mecanismo recuerda a la organización de la **columna cortical**,
que se estructura en seis niveles jerárquicos: desde las capas superiores de reconexión
con pocas neuronas, pasando por las capas intermedias de procesamiento y las capas que
reciben información sensorial directa, hasta las capas inferiores que almacenan
información espacial y de posición. El salto de información desde las capas inferiores
(nivel 6) hacia las capas superiores (niveles 2 y 3) constituye una analogía biológica
directa de las _skip connections_ empleadas en las redes residuales.

Otra innovación relevante fue la **arquitectura Inception** (GoogLeNet), que aplica en
paralelo filtros de distintos tamaños (1×1, 3×3 y 5×5) junto con una operación de
_pooling_, y concatena los resultados. Para controlar el coste computacional, se
introdujeron convoluciones de 1×1 como cuellos de botella.

Con la expansión de los dispositivos móviles surgieron las **MobileNet**, basadas en
**convoluciones separables en profundidad**. La segunda generación, **MobileNetV2**,
incorporó conexiones residuales junto con capas de expansión mediante filtros 1×1.

## Sistemas de detección de objetos

En muchas aplicaciones de la visión computacional no basta con clasificar una imagen en
su conjunto, sino que es imprescindible identificar **qué objetos aparecen en la escena
y en qué lugar se encuentran**. Este desafío se aborda mediante la **detección de
objetos**, que combina simultáneamente la clasificación y la localización de los
elementos presentes a través de recuadros delimitadores (_bounding boxes_).

Una estrategia habitual consiste en dividir la imagen en una **malla de celdas**, donde
cada celda predice la presencia de objetos cuyo centro se encuentra en su interior. Uno
de los algoritmos más influyentes es **YOLO (_You Only Look Once_)**, que aplica la red
convolucional a toda la imagen de manera simultánea, permitiendo detecciones en tiempo
real.

El desempeño de los modelos de detección se evalúa mediante métricas como la
**Intersección sobre Unión (IoU)**, la **Supresión de No Máximos (NMS)** y las **Cajas
de Anclaje (_anchor boxes_)**. Además de la detección convencional, existen variantes
como la detección de puntos de referencia y los métodos basados en regiones.

## Segmentación semántica y convoluciones transpuestas

La **segmentación semántica** asigna una **clase específica a cada píxel** de la imagen.
Para reconstruir la resolución espacial original a partir de representaciones
comprimidas, se emplea la **convolución transpuesta**, que expande las dimensiones
espaciales.

Un hito en este ámbito lo constituye la **arquitectura U-Net**, que se estructura en una
etapa de compresión (_encoder_) y una etapa de expansión (_decoder_), conectadas
mediante **conexiones de omisión (_skip connections_)** que transfieren información
directamente desde las capas de compresión a las de expansión, conservando detalles
finos de bordes y contornos.

## _One-shot learning_

Los modelos de visión por computador suelen requerir grandes volúmenes de datos para
alcanzar un entrenamiento eficaz. Sin embargo, en numerosos escenarios prácticos solo se
dispone de un número muy reducido de ejemplos por clase. Este desafío se aborda mediante
técnicas como el **_One-Shot Learning_** y el **_Few-Shot Learning_**, que buscan dotar
a los sistemas de la capacidad de generalizar a partir de datos escasos.

El principio fundamental consiste en aprender un **espacio de representación** en el que
las imágenes similares se ubiquen próximas entre sí, mientras que las correspondientes a
clases distintas aparezcan más alejadas. Una de las arquitecturas más representativas
son las **redes siamesas**, que procesan en paralelo dos imágenes mediante una misma red
convolucional que comparte parámetros. Otra estrategia ampliamente utilizada es la
basada en la **pérdida triple (_triplet loss_)**, que organiza el entrenamiento a partir
de tríos de imágenes: _anchor_, positiva y negativa.

## Aprendizaje contrastivo y autosupervisado

El **aprendizaje autosupervisado** permite entrenar modelos robustos sin la necesidad de
disponer de grandes volúmenes de datos etiquetados, generando automáticamente señales de
supervisión a partir de los propios datos. Dentro de este paradigma, una de las
estrategias más influyentes emplea la **pérdida contrastiva**, cuyo propósito es
aprender un espacio de representación en el que las imágenes similares se ubiquen
próximas entre sí.

En escenarios sin etiquetas, los **pares positivos** se generan mediante
transformaciones aplicadas a una misma imagen (rotaciones, cambios de escala, recortes
aleatorios, modificaciones de color), mientras que las **imágenes distintas** se
consideran pares negativos.

El proceso de entrenamiento contrastivo incluye varias etapas esenciales: obtención de
un conjunto de datos no etiquetados, generación de _embeddings_ mediante un modelo
preentrenado, optimización mediante _fine-tuning_ utilizando medidas de distancia entre
_embeddings_, e iteración con ajuste manual de las muestras más problemáticas.

Entre las funciones de pérdida más utilizadas destacan:

La **Triplet Loss** se fundamenta en tres elementos (ancla, par positivo y par
negativo):

$$
L = \min_{\theta}\left(\max\left(0, \text{dist}(X, X^+) - \text{dist}(X, X^-) + \text{margen}\right)\right).
$$

La **Contrastive Loss** se aplica a pares de datos:

$$
L = (1 - y) \frac{1}{2} \left( \text{dist}(X_1, X_2) \right)^2 + y \frac{1}{2} \left( \max(0, m - \text{dist}(X_1, X_2)) \right)^2.
$$

La **InfoNCE Loss**, utilizada en arquitecturas como **SimCLR**, maximiza la similitud
entre un dato ancla y su par positivo mientras minimiza la similitud con los pares
negativos:

$$
L = -\frac{1}{N} \sum_{i=1}^N \log \frac{\exp(\text{sim}(z_i, z_i^+)/\tau)}{\sum_{j=1}^K \exp(\text{sim}(z_i, z_j^-)/\tau)}.
$$

Entre las limitaciones del aprendizaje contrastivo se encuentran la dependencia de
transformaciones adecuadas de aumentación de datos y la necesidad de un gran número de
épocas y lotes suficientemente grandes para obtener pares negativos efectivos. Además,
en sistemas con múltiples atributos finos, puede producirse un fenómeno de
**_entanglement_** donde las características finas no son fácilmente separables, lo que
provoca un colapso de las representaciones embebidas: muestras que deberían estar
diferenciadas acaban con representaciones muy similares en el espacio latente. Este
colapso también puede ocurrir con los filtros que aprenden las redes convolucionales,
donde un número excesivo de filtros puede llevar a que muchos de ellos aprendan
características redundantes.

Modelos como **DINOv1** y **DINOv2** de Meta han demostrado la eficacia del aprendizaje
autosupervisado en visión computacional, utilizando representaciones de imágenes con
recortes parciales para el estudiante y visiones completas para el maestro, lo que
permite obtener representaciones globales de alta calidad. Estos sistemas también se
emplean para refinar conjuntos de datos, eliminando duplicados y filtrando imágenes no
apropiadas mediante búsqueda de similitud entre representaciones embebidas.

## Convolución en otros tipos de datos

Las convoluciones no se limitan al procesamiento de imágenes, sino que pueden aplicarse
a cualquier tipo de datos que presente una estructura espacio-temporal. En **series
temporales**, se emplean convoluciones unidimensionales que capturan patrones locales a
lo largo del eje temporal. En **audio**, la señal puede representarse mediante
espectrogramas _Mel_ obtenidos a partir de la transformada discreta de Fourier, lo que
convierte el sonido en una imagen bidimensional que evoluciona con la frecuencia y el
tiempo. En **vídeo**, la representación corresponde a un tensor de cuatro dimensiones
(alto, ancho, canales y tiempo), donde el tiempo refleja la sucesión de fotogramas.

Es importante señalar que las dimensiones espaciales (como las de una imagen) pueden
considerarse simétricas, mientras que las dimensiones temporales son asimétricas: una
señal de audio invertida en su eje temporal es, en general, inválida, y una serie
temporal invertida representa una evolución del futuro hacia el pasado.

En el ámbito del **procesamiento del lenguaje natural**, las frases o palabras se
dividen en secuencias de unidades más pequeñas denominadas **_tokens_**. Un _token_
puede representar un carácter, una palabra completa, un fragmento intermedio entre
ambos, signos de puntuación, símbolos especiales o incluso emojis, que pueden aportar
información contextual relevante (por ejemplo, para la detección de sentimientos). Esta
división depende del tipo de arquitectura y de las decisiones de diseño durante la
creación del modelo. Cada _token_ se convierte posteriormente en una representación
embebida (_embedding_) que el modelo puede procesar.

Empresas como OpenAI han publicado de forma abierta sus tokenizadores, que cuentan con
un vocabulario definido para convertir el corpus de texto en _tokens_. La conversión de
_tokens_ a _embeddings_ puede realizarse mediante modelos preentrenados o integrando el
entrenamiento de los _embeddings_ junto con el resto de la red. Técnicas como _one-hot
encoding_ resultan menos eficientes debido a la gran cantidad de ceros que generan,
produciendo vectores dispersos (_sparse_) que pueden sufrir la maldición de la
dimensionalidad al realizar operaciones vectoriales. Los _embeddings_ densos, en cambio,
permiten obtener representaciones que codifican relaciones semánticas directas entre
palabras, como sinónimos, antónimos, cambios de género o variaciones de capitalización.

Dado que las secuencias de texto suelen ser extensas, la convolución estándar puede
quedarse limitada en capturar todo el contexto. Para ampliar el campo receptivo sin
incrementar el número de parámetros, se emplean **convoluciones dilatadas** (_dilated
convolutions_): una dilatación igual a uno equivale a una convolución estándar, mientras
que una dilatación igual a dos implica que el filtro solo considera píxeles alternos,
ampliando el campo receptivo sin aumentar la complejidad del modelo. Este tipo de
convoluciones se ha utilizado en arquitecturas como **WaveNet** para la generación de
audio.

## Otras técnicas del procesamiento de imágenes

En el preprocesamiento de imágenes existen diversas técnicas que permiten mejorar la
calidad visual y la distribución de intensidades antes de alimentar un modelo. La
**ecualización de histograma** extiende el rango de colores distribuyendo los valores
entre los diferentes intervalos (_bins_) del histograma. Una variante más sofisticada es
**CLAHE** (_Contrast Limited Adaptive Histogram Equalization_), que divide la imagen en
ventanas (_patches_) y ecualiza cada una de forma independiente. Aunque esto mejora el
contraste local, puede incrementar el ruido al perder información global. El parámetro
de _clip limit_ permite limitar esta amplificación del ruido, controlando el contraste
máximo permitido en cada ventana.

Estas técnicas de procesamiento pueden combinarse con las capacidades de las redes
convolucionales para crear sistemas o _pipelines_ que permitan recopilar y curar datos
de Internet. Por ejemplo, si se dispone de una representación embebida de una categoría
de imágenes (como gatos), es posible utilizar sistemas de búsqueda por similitud entre
_embeddings_ para ampliar el conjunto de datos, eliminar duplicados o filtrar imágenes
no apropiadas, reduciendo así el coste de almacenamiento y refinando la calidad del
conjunto de datos.
