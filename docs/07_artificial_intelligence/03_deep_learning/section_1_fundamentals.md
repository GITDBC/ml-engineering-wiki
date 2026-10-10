---
authors: Daniel Bazo Correa
description: Introducción al aprendizaje profundo.
title: Fundamentos
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

.

## Bibliografía

- Persson, A. (s.f.). _Aladdin Persson_ \[Canal\]. YouTube.
  <https://www.youtube.com/c/AladdinPersson>
- McKinney, A. (s.f.). _Flax Tutorial_. Hugging Face Blog.
  <https://huggingface.co/blog/afmck/flax-tutorial>
- TensorFlow. (s.f.). _TensorFlow API Documentation_.
  <https://www.tensorflow.org/api_docs>
- DeepLearning.AI. (s.f.). _Deep Learning Specialization_ \[Curso\]. Coursera.
  <https://www.coursera.org/specializations/deep-learning>
- DeepLearning.AI. (s.f.). _TensorFlow Developer Professional Certificate_ \[Curso\].
  Coursera. <https://www.coursera.org/professional-certificates/tensorflow-in-practice>
- Hugging Face. (2025). _Agents Course_. <https://huggingface.co/learn/agents-course>
- Simone, G. (2024). _Alice's Adventures in a Differentiable Wonderland: A Primer on
  Designing Neural Networks (Volume I)_. Amazon.
- Howard, J. y Gugger, S. (2020). _Deep Learning for Coders with Fastai and PyTorch: AI
  Applications Without a PhD_. O'Reilly Media.
  <https://course.fast.ai/Resources/book.html>
- AI Coffee Break with Letitia. (2022). _Diffusion Models Explained_ \[Vídeo\]. YouTube.
  <https://youtu.be/BprirYymXrg>

## Introducción

Antes de abordar el estudio del **aprendizaje profundo (_Deep Learning_)**, resulta
esencial comprender el concepto de inteligencia, una noción que, aunque aparentemente
simple, presenta una complejidad notable cuando se intenta definir con precisión. En
términos generales, la inteligencia puede entenderse como la **capacidad de procesar
información y utilizarla para tomar decisiones orientadas al logro de objetivos
específicos**.

Desde una perspectiva biológica, el cerebro humano constituye el ejemplo más sofisticado
de sistema inteligente conocido. El **hipocampo**, una estructura cerebral fundamental,
desempeña funciones esenciales de memoria, navegación y planificación, construyendo
**mapas cognitivos** que representan el mundo físico en un espacio mental interno. Las
neuronas de posicionamiento (_place cells_) se activan en ubicaciones específicas del
entorno, generando patrones de actividad incluso en espacios tridimensionales. Cuando el
entorno cambia, se produce un **remapeo neuronal**: las neuronas dejan de activarse en
las mismas zonas y se reorganizan en función de las nuevas condiciones. Este remapeo no
depende únicamente de cambios físicos, sino también de factores contextuales como los
estímulos olfativos, lo que evidencia que estas representaciones son **dependientes del
contexto** y no se limitan a codificar información puramente espacial. El hipocampo
integra múltiples variables continuas para construir estas representaciones, mientras
que el **neocórtex** se encarga de procesar información más abstracta, incluyendo el
lenguaje y el conocimiento conceptual.

Dentro del neocórtex se encuentra la **columna cortical**, considerada la unidad
fundamental de procesamiento inteligente. La **hipótesis columnar** postula que, si el
_hardware_ biológico (la columna cortical replicada) es universal e idéntico en todas
sus instancias, entonces el algoritmo que gobierna su funcionamiento también debe serlo.
Esta idea se relaciona directamente con el concepto de **inteligencia artificial general
(AGI)**: un único algoritmo universal capaz de adaptarse a cualquier tipo de entrada,
donde solo varía el _input_ que recibe. Cada columna cortical opera como un sistema
independiente, pero existe un **traspaso de mensajes entre columnas** que puede
interpretarse como una interfaz de comunicación (análoga a una API en sistemas
informáticos). Incrementar el número de columnas corticales equivale a aumentar la
capacidad de cómputo del sistema. A medida que el cerebro adquiere características del
mundo, construye **marcos de referencia** que permiten localizar y relacionar conceptos,
facilitando la generación de nuevas acciones y predicciones, un proceso conocido como
**integración de caminos** (_path integration_). Las columnas corticales emplean además
un mecanismo de **votación por mayoría** para alcanzar un consenso sobre lo que se
percibe, donde la entrada de una columna puede ser tanto información sensorial directa
como información procesada por otra columna cortical.

Este concepto constituye el fundamento del campo de la **Inteligencia Artificial (IA)**,
disciplina que se dedica al desarrollo de técnicas y algoritmos capaces de reproducir
ciertos aspectos del comportamiento humano. La IA busca emular la inteligencia mediante
sistemas computacionales, permitiendo que las máquinas procesen información, se adapten
a diversos contextos y realicen predicciones para resolver problemas de manera autónoma,
minimizando la intervención humana.

Dentro de la IA se encuentra el **aprendizaje automático (_Machine Learning_)**, cuyo
propósito es permitir que las máquinas **aprendan a partir de la experiencia**, sin
necesidad de recibir instrucciones explícitas para cada tarea. En lugar de programar
manualmente cada paso del proceso, se diseñan algoritmos que **identifican patrones en
los datos**, ajustando sus parámetros internos con el objetivo de mejorar
progresivamente su rendimiento a medida que acumulan ejemplos. Este proceso de
aprendizaje se guía mediante una **función objetivo**, la cual mide el grado de
aproximación del sistema a la meta deseada.

El investigador Andrej Karpathy ha descrito este paradigma como "software 2.0", en
contraposición al enfoque tradicional de programación. En el "software 1.0", el
programador define de forma explícita las reglas y procedimientos que el sistema debe
ejecutar. En cambio, en el "software 2.0", el programador proporciona **ejemplos,
recompensas o etiquetas** que guían el proceso de optimización del algoritmo,
permitiendo que el propio sistema descubra de manera implícita las reglas necesarias
para cumplir la tarea. Este cambio de paradigma marca una transición desde la
programación manual hacia el aprendizaje basado en datos, donde el sistema adquiere la
capacidad de generalizar más allá de los ejemplos proporcionados durante el
entrenamiento.

El aprendizaje profundo representa una evolución dentro del aprendizaje automático. Su
principal característica radica en el uso de **redes neuronales artificiales** como
núcleo del proceso de aprendizaje. Estas redes, inspiradas en la estructura y el
funcionamiento del cerebro biológico humano, están compuestas por múltiples capas de
procesamiento que permiten **aprender representaciones jerárquicas de la información**.
Gracias a esta arquitectura, el aprendizaje profundo puede capturar relaciones complejas
entre variables, lo que le permite reconocer patrones altamente complejos en los datos.
Como resultado, el aprendizaje profundo ha demostrado un rendimiento excepcional en
tareas que antes se consideraban exclusivas del razonamiento humano, tales como el
reconocimiento de imágenes, el procesamiento del lenguaje natural, el análisis de audio
y la interpretación de grandes volúmenes de datos no estructurados.

Las ventajas fundamentales del aprendizaje profundo pueden resumirse en tres aspectos.
En primer lugar, la **simplicidad**: elimina la necesidad de ingeniería manual de
características, sustituyendo complejas cadenas de procesamiento por modelos entrenables
de extremo a extremo construidos con unas pocas operaciones tensoriales. En segundo
lugar, la **escalabilidad**: se beneficia enormemente de la paralelización en GPU y TPU,
y al entrenarse sobre pequeños lotes de datos, puede trabajar con conjuntos de datos de
tamaño arbitrario. En tercer lugar, la **versatilidad y reutilización**: los modelos
entrenados pueden actualizarse con datos adicionales sin reiniciar el proceso, y las
representaciones aprendidas pueden transferirse a nuevas tareas, lo que permite
construir sistemas cada vez más potentes a partir de trabajo previo.

### Escalabilidad y leyes de crecimiento

Un aspecto esencial en la evolución del aprendizaje profundo es el estudio de las
**leyes de escalado neuronal (_Neural Scaling Laws_)**, las cuales describen
comportamientos empíricamente observables en el rendimiento de los modelos a medida que
se incrementan los recursos disponibles. Estas leyes establecen que, al aumentar de
forma sistemática el tamaño de los conjuntos de datos, la capacidad computacional y el
número de parámetros de un modelo, se obtiene una mejora predecible y sostenida en la
precisión y eficiencia de las predicciones.

Este fenómeno ha guiado gran parte de la estrategia de desarrollo en la industria
tecnológica contemporánea. Empresas líderes como Google, Meta, OpenAI y otras
organizaciones han adoptado el principio del escalado como un eje fundamental de su
investigación y desarrollo, apostando por la creación de modelos cada vez más grandes y
sofisticados. La aplicación práctica de estas leyes ha dado lugar a la construcción de
redes neuronales más profundas y con un mayor número de neuronas, lo que ha impulsado la
aparición de los denominados **modelos de gran escala**, entre los que destacan los
**modelos de lenguaje de gran tamaño (_Large Language Models, LLMs_)**. Estos modelos
han demostrado una capacidad notable para generalizar conocimientos, generar texto
coherente, responder preguntas complejas y adaptarse a una amplia variedad de tareas
cognitivas. Además, exhiben capacidades emergentes, como el razonamiento en cadena, la
resolución de problemas matemáticos o la comprensión de instrucciones complejas, que no
fueron programadas explícitamente durante su entrenamiento.

En paralelo, existe una tendencia creciente en la investigación que busca optimizar la
eficiencia computacional sin sacrificar la calidad del modelo. Esta línea de trabajo
resulta relevante en entornos donde los recursos son limitados, como los dispositivos
móviles, los sistemas embebidos o las plataformas de Internet de las Cosas (_Internet of
Things_, IoT).

Para abordar estas limitaciones, se desarrollan múltiples estrategias, entre ellas:

- **Arquitecturas especializadas:** Diseños de redes más ligeras y eficientes, adaptadas
  a las restricciones de hardware.
- **Optimización a nivel de hardware:** Uso de unidades de procesamiento específicas,
  como _Graphics Processing Units_ (GPU), _Tensor Processing Units_ (TPU) o _Neural
  Processing Unit_ (NPU), capaces de acelerar las operaciones matriciales y reducir el
  consumo de energía.
- **Compilación a lenguajes de bajo nivel:** Traducción del modelo a representaciones
  más próximas al hardware para mejorar el rendimiento.

En conjunto, estas estrategias permiten democratizar el acceso y uso del aprendizaje
profundo, posibilitando su ejecución incluso en equipos de consumo general. De este
modo, el campo avanza no solo hacia modelos más grandes y potentes, sino también hacia
sistemas más eficientes, accesibles y sostenibles desde el punto de vista energético y
económico.

### Memoria implícita y modelos fundacionales

Las redes neuronales artificiales poseen la capacidad de aproximar distribuciones de
probabilidad a partir de los datos de entrada. En esencia, su propósito es construir una
función parametrizada que permita comprender, representar y generalizar el
comportamiento de los datos observados.

En los modelos actuales, esta capacidad alcanza niveles en los que la red puede llegar a
memorizar parte de los datos de entrenamiento. Aunque las arquitecturas contemporáneas
no suelen incorporar mecanismos explícitos de memoria, como una base de datos interna o
una estructura dedicada al almacenamiento, la información queda codificada en los
propios parámetros del modelo. Este fenómeno se manifiesta en la activación selectiva de
neuronas ante determinados contextos, lo que sugiere que la red conserva rastros de
información previa y los utiliza para procesar nuevas entradas.

Aunque esta memoria no sea explícita, existen líneas de investigación que buscan
extender o complementar este comportamiento con mecanismos dedicados. En algunos casos,
se exploran estructuras que incorporan memoria persistente, como las redes recurrentes o
los _Transformers_ con mecanismos de atención. En otros, se utilizan recursos
_hardware_, como la memoria caché o el almacenamiento intermedio en disco, para
gestionar información temporal durante los procesos de entrenamiento e inferencia. Estas
aproximaciones buscan aumentar la capacidad de los modelos para manejar secuencias
largas, retener información contextual de manera más eficiente y facilitar un
aprendizaje más continuo.

La existencia de esta memoria implícita plantea, además, una distinción fundamental
entre los **datos dentro de distribución (_in-distribution_)** y los **datos fuera de
distribución (_out-of-distribution_)**. Los primeros se refieren a ejemplos similares a
los utilizados durante el entrenamiento, en los cuales el modelo optimiza su función
objetivo hasta alcanzar la **convergencia**, es decir, hasta que los ajustes en los
parámetros dejan de producir mejoras significativas en el desempeño. Los segundos, en
cambio, corresponden a entradas que difieren significativamente del conjunto de
entrenamiento, lo que puede provocar fallos, respuestas erróneas o predicciones con alta
incertidumbre. Por ejemplo, un modelo entrenado exclusivamente para reconocer perros no
es capaz de identificar correctamente un gato, ya que este pertenece a una distribución
distinta de patrones visuales y características. Sin embargo, debido a que los conjuntos
de datos empleados actualmente son cada vez más amplios, diversos y heterogéneos, esta
separación entre ambos tipos de datos tiende a desdibujarse. La capacidad de los modelos
para generalizar más allá de su distribución de entrenamiento constituye un área activa
de investigación.

En este contexto, el estudio de la **capacidad de generalización** de los modelos
adquiere un papel central. Los avances recientes han explorado estrategias que permiten
mejorar la inferencia y la estimación de incertidumbre. Entre estas estrategias destacan
el uso de técnicas de cálculo en tiempo de inferencia (_test-time computation_), que
permiten al modelo dedicar más recursos computacionales a problemas complejos en el
momento de la predicción, las redes neuronales bayesianas, que incorporan distribuciones
de probabilidad sobre los parámetros en lugar de valores fijos, y técnicas como _Monte
Carlo Dropout_, que simula múltiples predicciones mediante la desactivación aleatoria de
neuronas durante la inferencia. Estas aproximaciones posibilitan la creación de
**intervalos de confianza** para las predicciones, otorgando a los modelos una mayor
robustez frente a datos desconocidos y una capacidad para expresar el grado de seguridad
de sus respuestas.

Paralelamente, existe el fenómeno del **olvido catastrófico (_catastrophic
forgetting_)**, que describe la tendencia de las redes neuronales a perder información
previamente aprendida cuando incorporan nuevo conocimiento. Este problema representa uno
de los mayores desafíos del **aprendizaje continuo (_continual learning_)**, un
paradigma en el que se busca que el modelo sea capaz de actualizarse de manera
progresiva sin olvidar su conocimiento previo. La solución a este desafío requiere el
desarrollo de mecanismos que equilibren la plasticidad (la capacidad de aprender nueva
información) con la estabilidad (la preservación del conocimiento existente).

La evolución de estas ideas conduce al desarrollo de los **modelos fundacionales
(_foundation models_)**, que se conciben como sistemas de aprendizaje generalista
capaces de adaptarse a múltiples dominios y tareas. Estos modelos no están diseñados
para una tarea específica, sino que aprenden representaciones amplias y abstractas del
mundo que pueden reutilizarse en diversos contextos. A partir de una base preentrenada
sobre grandes volúmenes de datos, es posible **ajustarlos finamente (_fine-tuning_)**
para resolver tareas concretas sin necesidad de entrenarlos desde cero.

### El aprendizaje como problema de optimización

El proceso de aprendizaje en redes neuronales debe entenderse, desde una perspectiva
formal, como un problema de optimización matemática. En este marco, un modelo se define
a partir de un conjunto de parámetros ajustables que determinan su comportamiento. Estos
parámetros representan el conocimiento adquirido durante el entrenamiento y se
actualizan progresivamente con el objetivo de **minimizar una función que mide el error
del modelo** respecto a los datos observados.

Las redes neuronales se consideran **modelos diferenciables** porque su mecanismo de
aprendizaje se basa en la capacidad de **calcular derivadas parciales** de una **función
de coste** (también denominada **función de pérdida**) con respecto a sus parámetros.
Esta función cuantifica la discrepancia entre las predicciones generadas por el modelo y
los valores reales, actuando como una medida de su rendimiento. Los parámetros
aprendibles son, por tanto, aquellas variables internas que se modifican iterativamente
para reducir dicha discrepancia y mejorar la capacidad predictiva del sistema.

El proceso de aprendizaje es **iterativo y dinámico**. Consiste en un ciclo continuo de
cálculo, actualización y evaluación que se repite hasta alcanzar un criterio de parada
determinado. Este criterio puede definirse en función del número de iteraciones, de la
estabilidad alcanzada por la función de coste o de la satisfacción de una métrica de
desempeño preestablecida. En la práctica, este procedimiento se implementa mediante
algoritmos de optimización, entre los que destaca el **descenso del gradiente**, que
ajusta los parámetros en la dirección que más reduce la pérdida. Existen además
variantes adaptativas, que mejoran la eficiencia del proceso y aceleran la convergencia
en arquitecturas complejas.

Una herramienta fundamental que posibilita este proceso es la **diferenciación
automática**, la cual permite calcular de manera eficiente las derivadas necesarias para
actualizar los parámetros del modelo. Gracias a esta técnica, es posible entrenar redes
profundas sin requerir una derivación manual de las expresiones analíticas. La
diferenciación automática constituye, por tanto, uno de los pilares que han hecho viable
la expansión moderna del aprendizaje profundo.

No obstante, el carácter diferenciable del modelo impone ciertas restricciones sobre los
tipos de datos que pueden procesarse directamente. Las derivadas solo son aplicables a
funciones continuas, por lo que representaciones discretas (como caracteres, palabras o
números enteros) no pueden utilizarse tal cual en los cálculos diferenciales. Para
hacerlos compatibles, los datos deben transformarse en representaciones numéricas
continuas, generalmente en forma de **vectores o tensores**, que permitan aplicar las
operaciones matemáticas requeridas durante el entrenamiento.

Este proceso de conversión se denomina **_embedding_**, y su función no se limita
únicamente a permitir el procesamiento diferencial, sino también a **capturar las
relaciones semánticas, estructurales y contextuales entre los elementos de los datos**.
Por ejemplo, en el caso del lenguaje natural, los _embeddings_ permiten representar
palabras o frases de modo que aquellas con significados similares se encuentren próximas
en el **espacio vectorial**, que constituye el espacio matemático multidimensional
creado por el propio modelo. Este espacio permite al sistema establecer y mapear las
relaciones semánticas entre los datos de manera cuantitativa, facilitando operaciones
como la comparación de similitudes, la búsqueda de analogías o la agrupación de
conceptos relacionados. De este modo, los _embeddings_ transforman información simbólica
en representaciones geométricas que preservan y codifican el significado subyacente de
los datos originales.

A medida que el modelo optimiza su función de coste, desarrolla internamente una forma
de **entender y codificar la información** que refleja la estructura subyacente de los
datos. Cuanto mejor sea la capacidad del modelo para comprimir la información sin perder
significado, más eficaz será su desempeño. La compresión eficiente implica que el modelo
ha aprendido a distinguir entre la información relevante y la irrelevante, capturando
solo aquellos patrones que resultan esenciales para la tarea. Este principio de
compresión es, en última instancia, una manifestación del aprendizaje mismo: la
habilidad de mapear, abstraer y recuperar información compleja sin necesidad de
conservar todos los detalles explícitos.

### Arquitecturas y tipos de datos

El aprendizaje profundo se adapta a diferentes problemas mediante el uso de
arquitecturas especializadas, diseñadas para extraer información relevante según la
naturaleza y estructura del tipo de datos analizados. Cada arquitectura incorpora
componentes y operaciones específicas que explotan las características intrínsecas de
los datos, permitiendo al modelo capturar patrones de manera más eficiente y efectiva.
Entre las principales arquitecturas destacan:

- **Redes neuronales densas o totalmente conectadas (_Fully Connected Networks_, FCN)**:
  Constituyen la arquitectura más básica y general, en la que cada neurona de una capa
  está conectada con todas las neuronas de la capa siguiente. Estas redes pueden
  procesar, por lo general, cualquier tipo de datos, siempre que estos se presenten en
  forma vectorial unidimensional, es decir, aplanados (_flattened_). Aunque versátiles,
  presentan limitaciones al trabajar con datos de alta dimensionalidad o con estructuras
  espaciales o temporales complejas, debido al elevado número de parámetros que
  requieren y a su incapacidad para explotar eficientemente dichas estructuras.

- **Redes convolucionales (_Convolutional Neural Networks_, CNN)**: Diseñadas
  específicamente para el procesamiento de datos que poseen estructura espacial o
  espacio-temporal, como imágenes y vídeos. Las CNN utilizan operaciones de convolución
  que aplican filtros deslizantes sobre los datos de entrada, detectando patrones
  locales como bordes, texturas o formas geométricas en las primeras capas, y
  progresivamente características más abstractas y complejas en capas más profundas.
  Esta arquitectura explota la localidad espacial y la invariancia traslacional,
  reduciendo significativamente el número de parámetros en comparación con redes densas
  equivalentes, y facilitando la generalización del modelo a diferentes posiciones
  dentro de la imagen.

- **Redes recurrentes (_Recurrent Neural Networks_, RNN)** y sus variantes modernas,
  como las LSTM (_Long Short-Term Memory_) y GRU (_Gated Recurrent Units_): Empleadas en
  el tratamiento de secuencias, donde el orden temporal de los datos es primordial.
  Estas arquitecturas son especialmente adecuadas para procesar texto, series
  temporales, señales de audio o cualquier tipo de datos secuenciales. Las RNN
  incorporan conexiones recurrentes que permiten a la red mantener un estado interno o
  memoria que captura información de elementos anteriores de la secuencia, posibilitando
  la modelización de dependencias temporales.

- **Modelos basados en _Transformers_**: Representan una evolución significativa en el
  procesamiento de secuencias, basándose en mecanismos de atención que permiten al
  modelo ponderar la importancia de diferentes elementos de la entrada de manera
  dinámica y contextual. Los _Transformers_ han demostrado ser altamente efectivos para
  tareas de procesamiento de lenguaje natural y han sido adoptados también en otros
  dominios como la visión por computador.

- **Modelos multimodales**: Capaces de integrar y procesar información proveniente de
  distintas fuentes o modalidades, como texto, imágenes, audio y vídeo. Estos modelos se
  basan en la idea de representar todos los datos de entrada, independientemente de su
  formato original, como **representaciones embebidas** (_embeddings_) en un espacio
  vectorial común. Este espacio, creado y aprendido por el modelo durante el
  entrenamiento, permite establecer relaciones semánticas entre elementos de diferentes
  modalidades, facilitando que conceptos similares (expresados en formatos distintos) se
  encuentren próximos en dicho espacio. Este proceso de conversión se conoce actualmente
  como **tokenización**, y consiste en la creación de **_tokens_**, representaciones
  vectoriales aprendibles y entendibles por el modelo que encapsulan unidades
  significativas de información. Un único modelo final puede entonces procesar estos
  _tokens_ de manera unificada, independientemente de su origen modal, permitiendo
  tareas complejas como la generación de descripciones textuales a partir de imágenes,
  la búsqueda multimodal o la traducción entre diferentes tipos de contenido.

En este contexto, resulta necesario distinguir entre diferentes tipos de datos según su
estructura y formato. Los **datos estructurados** se organizan en tablas de filas y
columnas, donde cada fila representa una observación o ejemplo, y cada columna
corresponde a una característica o variable con un significado bien definido. Este
formato es característico de las bases de datos relacionales tradicionales y de las
hojas de cálculo. Para este tipo de datos, suelen bastar algoritmos de aprendizaje
automático clásicos, como árboles de decisión o regresión logística, que pueden alcanzar
rendimientos competitivos sin requerir la complejidad arquitectónica del aprendizaje
profundo. No obstante, las redes neuronales también pueden aplicarse a datos
estructurados, especialmente cuando existen interacciones complejas entre variables o
cuando se combinan con datos no estructurados en modelos híbridos.

Los **datos no estructurados**, por el contrario, carecen de una organización tabular
predefinida y presentan formatos heterogéneos y complejos. Ejemplos incluyen imágenes,
grabaciones de voz, documentos en lenguaje natural, vídeos o señales biomédicas. Estos
datos requieren arquitecturas avanzadas de aprendizaje profundo para su procesamiento
efectivo, pues contienen patrones intrincados, relaciones jerárquicas y dependencias
contextuales que no pueden ser fácilmente capturadas por algoritmos tradicionales. El
aprendizaje profundo se muestra especialmente eficaz en estos casos, permitiendo extraer
automáticamente representaciones significativas y patrones complejos a partir de grandes
volúmenes de información, sin necesidad de ingeniería manual de características.

En cuanto a la representación tensorial de los datos, cada tipo de dato se mapea a un
rango específico de tensor. Los datos vectoriales se representan como tensores de rango
2 con forma $(muestras, características)$. Las series temporales o datos secuenciales
adoptan tensores de rango 3 con forma $(muestras, pasos\_temporales, características)$.
Las imágenes se codifican como tensores de rango 4 con forma
$(muestras, alto, ancho, canales)$. Finalmente, los vídeos se representan como tensores
de rango 5 con forma $(muestras, fotogramas, alto, ancho, canales)$.
