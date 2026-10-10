---
authors: Daniel Bazo Correa
description: Fundamentos de la IA Generativa.
title: IA Generativa
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Los modelos auto regresivos son la forma más simple del modelo generativos, los modelos
auto regresivos al final basadas en los modelos grandes de lenguaje, lo que hacen es
generar nuevos, tocáis a partir de de toques anteriores y son el fundamento o la base de
las arquitecturas multimodales. Los modelos generativos son o están en marcado
naturalmente en el contexto de las probabilidades. Al final si imaginamos que tenemos un
espacio de todas las secuencias posibles lo que tenemos es la probabilidad de X, siendo
X perteneciente al conjunto del espacio de todas las posibilidades de secuencias
entonces X es una secuencia que pertenece a ese espacio completo. Entonces al final
estos modelos generativos su tarea principal es modelar nuevos datos a partir de la
distribución de la probabilidad de X donde al final lo que tenemos es que la
probabilidad de X es igual al producto de las probabilidades de todas las secuencias
sucesivas anteriores es decir, que si yo tengo una secuencia y y + 1 e y + 2 la
secuencia predecir de Imas tres depende de la probabilidad de la secuencia y y + 1 + 2.
A este tipo de modelos se les llama a generativos, porque al final permiten generar
nuevos puntos, es decir, nuevas muestras a partir de esta distribución de probabilidades
si lo que estamos haciendo es predecir una etiqueta dado un dato de entrada son modelos
discriminatívoos. Isam peleamos siempre el toquen que tienen mayor probabilidad. Como
habíamos comentado anteriormente, al utilizar la función softmax podemos introducir un
parámetro de temperatura, que controla cómo de estricta o uniforme es la distribución de
probabilidades entre las distintas secuencias posibles. Cuando la temperatura es alta,
la distribución de probabilidad se vuelve más uniforme, de modo que el modelo es más
aleatorio y explora más. En cambio, cuando la temperatura es baja, la distribución se
concentra en las opciones más probables, haciendo que el modelo sea más determinista y
menos “creativo”.

## Modelos de lenguaje de gran escala (LLMs)

Los modelos de lenguaje forman parte del campo del aprendizaje profundo. Aunque los
modelos de lenguaje ya existían antes de la era de los LLMs, estos empleaban
arquitecturas diferentes, como las redes neuronales recurrentes (RNN) y las redes con
memoria a largo y corto plazo (LSTM, por sus siglas en inglés). Estas arquitecturas
presentaban limitaciones importantes, especialmente en lo que respecta a la
paralelización, debido a su naturaleza secuencial. En estas estructuras, la salida en un
instante de tiempo $$t$$ depende de la entrada y salida en $$t-1$$, lo que dificulta el
procesamiento paralelo de las secuencias.

Además, dichas arquitecturas no escalaban de manera eficiente. Aunque el aumento de
neuronas podía mejorar el rendimiento, la capacidad de cómputo de la época limitaba su
aplicabilidad. A esto se sumaba la falta de herramientas adecuadas para la recopilación,
limpieza y estandarización de los datos necesarios para el entrenamiento de modelos de
lenguaje efectivos.

La introducción de la arquitectura Transformer supuso una solución a muchas de estas
limitaciones. Los Transformers permiten la paralelización efectiva de las tareas,
mejorando la escalabilidad y el rendimiento general. La mayoría de los avances recientes
en modelos como GPT se basan en variantes del Transformer, incrementando el número de
capas, neuronas, cabezas de atención y empleando mecanismos avanzados de atención (como
la auto-atención y la atención cruzada), así como técnicas adicionales como la
incorporación de componentes frecuenciales.

Estos avances han sido fundamentales en el desarrollo de la inteligencia artificial
generativa, que es capaz de producir texto, imágenes, vídeos y otros tipos de contenido.
Para tareas relacionadas con imágenes y vídeos, se exploran también otras arquitecturas
como los mecanismos de difusión, que a veces se combinan con Transformers. Además, se
han desarrollado modelos fundacionales, capaces de tokenizar distintos tipos de
contenido (imágenes, sonido, texto, etc.) y representarlos en forma de tensores,
permitiendo establecer relaciones entre diferentes modalidades de datos, como el sonido
de un perro y su imagen.

El entrenamiento de los modelos de lenguaje a gran escala suele dividirse en dos fases
principales:

Preentrenamiento. Durante esta etapa, el modelo es entrenado utilizando grandes corpus
de datos no etiquetados. Estos conjuntos de datos pueden estar compuestos por textos de
Wikipedia, libros, artículos y otros contenidos disponibles en la web. Antes del
entrenamiento, se realiza un proceso de limpieza y estandarización del texto (por
ejemplo, eliminación de acentos o símbolos innecesarios).

El objetivo del preentrenamiento es que el modelo aprenda a predecir el siguiente token,
que puede corresponder a una palabra o un fragmento de ella, dependiendo del sistema de
tokenización. Este enfoque se conoce como aprendizaje autosupervisado (_self-supervised
learning_), ya que no requiere anotaciones humanas.

Esta fase permite que el modelo adquiera una comprensión general del lenguaje,
incluyendo su sintaxis, semántica y contexto. No obstante, su entrenamiento requiere una
enorme cantidad de recursos computacionales y datos. Por ejemplo, se estima que el
preentrenamiento de GPT-3 costó aproximadamente 4600 millones de dólares en créditos de
computación, procesando miles de millones de tokens.

Tras el preentrenamiento, el modelo puede ser ajustado mediante conjuntos de datos más
pequeños pero etiquetados, con el fin de especializarlo en tareas concretas. Este
proceso recibe el nombre de _fine-tuning_ y permite adaptar modelos fundacionales a
dominios específicos.

Existen dos formas comunes de ajuste fino:

- **Instruction Fine-Tuning**: Consiste en presentar al modelo pares de preguntas y
  respuestas. Un ejemplo típico es proporcionar un problema matemático y su resolución
  paso a paso. Esta técnica es especialmente útil en modelos orientados al razonamiento,
  ya que permite emular capacidades cognitivas complejas.

- **Classification Fine-Tuning**: En este caso, se le presenta al modelo un texto
  acompañado de una etiqueta, con el objetivo de realizar tareas de clasificación.
  Ejemplos comunes incluyen la clasificación de correos electrónicos como spam o no
  spam, o la detección de problemas en redes de telecomunicaciones.

Gracias al _fine-tuning_, los modelos pueden realizar tareas de _zero-shot_ o _few-shot
learning_, es decir, resolver problemas sin haber sido entrenados específicamente en
ellos, o con muy pocos ejemplos.

Cuando un modelo de lenguaje exhibe capacidades no previstas durante su entrenamiento
explícito, se habla de _comportamientos emergentes_ (_emergent behaviors_). Estos surgen
debido a la combinación de datos masivos y arquitecturas profundas, lo que permite que
el modelo establezca relaciones complejas entre conceptos de manera autosupervisada.
Estos comportamientos son indicativos del potencial de generalización de los LLMs.

El objetivo principal de los modelos de inteligencia artificial y aprendizaje profundo
consiste en transformar los datos de entrada en representaciones más ricas y
diferenciadas. Esta transformación permite separar y agrupar la información en
diferentes clústeres, utilizando funciones lineales y no lineales. A medida que las
arquitecturas se profundizan, la representación de la entrada se vuelve más
representativa y detallada, capturando relaciones semánticas complejas.

En el caso del lenguaje, los datos de entrada suelen ser palabras, que se transforman en
identificadores asociados a vectores numéricos conocidos como **embeddings**. Estos
embeddings permiten representar palabras de manera continua en un espacio vectorial,
capturando similitudes semánticas. Sin embargo, los enfoques tradicionales presentan
limitaciones: palabras nuevas o no presentes en el vocabulario original no pueden ser
representadas directamente, y errores ortográficos o variantes culturales pueden generar
inconsistencias.

Para solucionar estas limitaciones surge la **tokenización**, que consiste en dividir
las entradas en unidades menores denominadas **tokens**. La tokenización puede ser
realizada mediante diferentes técnicas, como la codificación por pares de bytes (Byte
Pair Encoding, BPE), que permite una división inteligente de los datos para extraer
información semántica y contextual. Posteriormente, estos tokens se representan como
tensores, los cuales constituyen la entrada para las capas de procesamiento del modelo.

Cada token se procesa de manera paralela mediante **redes neuronales completamente
conectadas (Feed-Forward Networks, FFN)**. La paralelización se logra mediante la
compartición de pesos, una ventaja distintiva de los **transformers** frente a
arquitecturas previas como las **RNN** o **LSTM**, que procesan secuencias de manera
secuencial y carecen de esta eficiencia computacional.

Tras la proyección de los tokens en vectores de mayor dimensión mediante funciones
lineales y no lineales, los modelos aplican mecanismos de **autoatención**. Este
mecanismo evalúa la relación de cada token con todos los demás de la secuencia,
generando un promedio ponderado basado en la importancia de cada token. La función de
activación **softmax** se utiliza para convertir estos pesos en probabilidades
normalizadas. En términos matemáticos, la autoatención se organiza a partir de tres
tipos de tensores diferenciados:

- **Keys (K)**: vectores que representan las entradas.
- **Queries (Q)**: vectores de consulta, que corresponden al input que evalúa la
  relación con las keys.
- **Values (V)**: vectores que contienen la información asociada a cada key.

Estos tensores pueden visualizarse como una tabla de consulta (lookup table),
inicializados de manera aleatoria y optimizados durante el entrenamiento. La utilización
de **cachés KV** permite almacenar matrices de atención, evitando el recálculo repetido
y optimizando el rendimiento.

Aunque los mecanismos de autoatención son invariantes a las permutaciones de tokens, el
orden de los elementos es fundamental en el lenguaje y en otras modalidades como la
visión computacional. Para preservar la información posicional se incorporan
**embeddings posicionales**, que pueden ser aprendibles o basados en técnicas como
**RoPE (Rotary Positional Encoding)**, permitiendo representar la posición de manera
continua y diferenciada.

Existen diferentes tipos de arquitecturas en los modelos de lenguaje, según la tarea y
el tipo de entrenamiento:

- **Modelos de lenguaje enmascarados**: Utilizan tokens de máscara en la entrada para
  predecir la palabra oculta. Se calcula la **entropía cruzada** entre la predicción y
  el valor real. Estas arquitecturas emplean únicamente el encoder del transformer.
  Ejemplos representativos incluyen **BERT** y **RoBERTa**, óptimos para tareas de
  clasificación y comprensión de texto.
- **Modelos autoregresivos**: La salida del modelo se retroalimenta como entrada para
  predecir el siguiente token, aplicando entropía cruzada. Son **causales**, ya que
  enmascaran los tokens futuros durante el entrenamiento. Ejemplos destacados son los
  modelos **GPT**, ampliamente utilizados en generación de texto.
- **Modelos encoder-decoder**: Combinan ambas estructuras, siendo ideales para tareas de
  traducción o generación condicional de secuencias. Estas arquitecturas son más
  complejas de entrenar y escalar, pero permiten una mayor versatilidad generativa.

Los modelos incorporan tokens específicos para diversas funciones:

- **\[CLS\]**: Indica la representación global de la secuencia, utilizada en tareas de
  clasificación o comparación entre secuencias.
- **\[PAD\]**: Rellena secuencias hasta la longitud máxima permitida por el modelo.
- **Máscara**: Utilizada en modelos enmascarados para predecir tokens ocultos.

El entrenamiento de modelos de lenguaje incluye varias fases:

- **Pre-training**: Entrenamiento inicial sobre grandes corpus, generalmente basado en
  predicción de tokens siguientes o enmascarados.
- **Post-training / Fine-tuning**: Ajuste fino sobre tareas específicas, alineamiento de
  instrucciones o especialización en dominios particulares. Este proceso puede incluir
  **aprendizaje por refuerzo**, optimizando el comportamiento del modelo y mejorando la
  seguridad y precisión de las respuestas.

Para aumentar la probabilidad de obtener respuestas correctas o coherentes, se utilizan
diversas estrategias de **prompting**:

- **Few-shot learning**: Se proporcionan ejemplos previos en la entrada para
  contextualizar la tarea.
- **Cadenas de razonamiento**: Descomponen problemas complejos en pasos secuenciales,
  facilitando la resolución lógica. También se suelen utilizar modelos de recompensa,
  utilizando datasets con respuestas que se complementan con otro modelo basado en el
  desarrollo completo de pasos, entonces el modelo principal se entrena para incrementar
  el grado de recompensa del modelo que genera la recompensa.
- **Retrieve and Augmented Generation (RAG)**: Combina modelos generativos con sistemas
  de recuperación de información para fundamentar las respuestas en datos externos.

Los sistemas multimodales permiten procesar diferentes tipos de datos (texto, imágenes,
audio, música) mediante una tokenización unificada. Cada tipo de dato se representa como
tokens y se proyecta en un espacio embedido común, permitiendo que elementos con
significado similar estén cercanos en dicho espacio. Estas arquitecturas favorecen la
integración de información diversa y la generación de respuestas coherentes basadas en
múltiples fuentes de entrada. Existen modelos multimodales desde cero, que procesan
todos los tipos de datos con un único modelo, o enfoques modulares que encadenan modelos
especializados.
