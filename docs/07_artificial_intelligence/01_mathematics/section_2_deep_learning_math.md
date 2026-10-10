---
authors: Daniel Bazo Correa
description:
    Fundamentos matemáticos del aprendizaje profundo, desde los tensores y el álgebra
    lineal hasta la geometría analítica y la descomposición de matrices.
title: Fundamentos matemáticos
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

El aprendizaje automático consiste en diseñar algoritmos que extraen información de
forma automática a partir de unos datos. El énfasis recae sobre esa automatización, es
decir, sobre metodologías de propósito general aplicables a un conjunto de datos
arbitrario. Tres conceptos articulan la disciplina: los datos, el modelo y el
aprendizaje. Se dice que un modelo aprende de los datos cuando su rendimiento en una
tarea mejora después de considerarlos, y el objetivo consiste en encontrar modelos que
generalicen bien a datos no vistos.

Una dificultad de esta disciplina es que sus conceptos admiten varias lecturas, y un
mismo componente de un sistema de aprendizaje automático puede abstraerse mediante
distintas construcciones matemáticas. Este capítulo recorre el aparato algebraico que
sustenta esas construcciones. Comienza por el tensor, que es la estructura de datos
sobre la que operan las bibliotecas de cálculo, continúa con los vectores y los sistemas
de ecuaciones lineales, añade la interpretación geométrica que proporcionan las normas y
los productos internos, y termina con las descomposiciones de matrices que hacen
posibles técnicas como el análisis de componentes principales.

## Bibliografía

- Deisenroth, M. P., Faisal, A. A., y Ong, C. S. (2020). _Mathematics for Machine
  Learning_. Cambridge University Press. <https://mml-book.github.io/>
- Strang, G. (2016). _Introduction to Linear Algebra_. Wellesley-Cambridge Press.
- 3Blue1Brown. _Essence of Linear Algebra_.
  <https://www.3blue1brown.com/topics/linear-algebra>

## Tensores como estructura fundamental

En el ámbito del aprendizaje profundo, los **tensores** constituyen la estructura de
datos esencial sobre la cual se construye y ejecuta la totalidad del proceso de cómputo.
Un tensor puede definirse formalmente como una colección ordenada de elementos numéricos
organizados en un espacio de $N$ dimensiones, que permite representar, almacenar y
manipular información de manera eficiente dentro de un modelo de red neuronal.

Su principal ventaja radica en su compatibilidad con sistemas de cómputo masivamente
paralelos, como las unidades de procesamiento gráfico (GPU) o las unidades de
procesamiento tensorial (TPU). Estas arquitecturas están diseñadas para ejecutar de
forma simultánea miles de operaciones matemáticas, lo cual resulta indispensable para el
entrenamiento y la inferencia en redes neuronales de gran escala, donde la eficiencia
computacional y el manejo óptimo de los recursos son factores determinantes.

Cada tensor se describe a partir de dos componentes fundamentales: el tipo de datos que
contiene y la precisión numérica empleada en los cálculos. Los valores almacenados
suelen ser numéricos, representados comúnmente como enteros o números en coma flotante.
En la práctica, los modelos de aprendizaje profundo suelen utilizar tensores de 32 bits
(precisión simple), aunque es frecuente aplicar técnicas de **cuantización** que reducen
la precisión a 16, 8 o incluso 4 bits, especialmente una vez completada la fase de
entrenamiento. Estas reducciones, sin embargo, dependen de las capacidades del hardware,
ya que no todas las arquitecturas soportan operaciones de baja precisión con la misma
eficiencia o estabilidad numérica.

Bibliotecas especializadas como **PyTorch**, **TensorFlow** o **Keras** facilitan estos
procesos mediante instrucciones de alto nivel. La elección del nivel de precisión
implica un compromiso entre exactitud y eficiencia. En aplicaciones donde los errores
mínimos son tolerables, como la clasificación de imágenes comunes, puede optarse por una
menor precisión para reducir el consumo energético y acelerar el entrenamiento. En
cambio, en entornos donde la seguridad y la fiabilidad son críticas, se requiere una
precisión numérica más alta que garantice la estabilidad y exactitud de los resultados.
Por tanto, existe una relación directa entre la precisión numérica, el error acumulado y
el coste computacional, de modo que optimizar este equilibrio constituye uno de los
aspectos clave del diseño de modelos eficientes. El uso de **precisión mixta**, que
combina tipos de punto flotante de 16 y 32 bits durante el entrenamiento, permite
acelerar la ejecución y reducir el consumo de memoria manteniendo la estabilidad
numérica en las operaciones críticas. El tratamiento detallado de los formatos
numéricos, de la cuantización lineal y del error que introduce se aborda en el capítulo
de [despliegue](../../06_operations/section_5_deployment.md), donde estas técnicas
resultan determinantes.

Desde el punto de vista operativo, los tensores funcionan de manera análoga a los
**_arrays_** de los lenguajes de programación tradicionales, permitiendo realizar
operaciones como indexación, segmentación o extracción de subconjuntos de datos. Estas
operaciones son esenciales, ya que posibilitan el procesamiento de partes específicas de
un conjunto de información sin necesidad de manipular el tensor completo.

La dimensionalidad es una de las características más importantes de los tensores, pues
determina la forma en que los datos se estructuran internamente. Según su número de
dimensiones, pueden clasificarse del siguiente modo:

- Un **escalar** corresponde a un tensor de dimensión cero y representa un único valor
  numérico.
- Un **vector** es un tensor unidimensional que almacena una secuencia ordenada de
  valores.
- Una **matriz** constituye un tensor bidimensional que organiza los datos en filas y
  columnas.
- Los **tensores de orden superior**, con tres o más dimensiones, permiten representar
  estructuras de datos más complejas, como secuencias temporales, imágenes, vídeos o
  volúmenes tridimensionales.

Un ejemplo ilustrativo lo constituye una imagen en color de 84 × 84 píxeles con tres
canales (rojo, verde y azul) procesada en lotes durante el entrenamiento. En este caso,
la representación corresponde a un tensor de rango 4, cuyas dimensiones reflejan: el
número de ejemplos en el lote, la altura y la anchura de la imagen, y el número de
canales de color.

En el ámbito del aprendizaje profundo, el tensor constituye la unidad de procesamiento
fundamental dentro de las bibliotecas de cálculo numérico. La mayoría de los modelos se
construyen mediante la composición de funciones elementales, tales como sumas,
multiplicaciones y transformaciones no lineales. Estas operaciones permiten representar
relaciones complejas entre los datos y, por tanto, son esenciales para el funcionamiento
de los modelos de inteligencia artificial.

Para ilustrar estos conceptos se emplea **PyTorch**, una biblioteca de código abierto
para _Deep Learning_ reconocida por su flexibilidad, su ecosistema de herramientas
complementarias y su amplia adopción tanto en el ámbito académico como en el industrial.
PyTorch permite definir, entrenar y desplegar modelos de redes neuronales de manera
eficiente, ofreciendo una interfaz altamente integrada con el lenguaje de programación
Python, lo que la hace especialmente accesible para investigadores y desarrolladores.

Aunque existen otras alternativas consolidadas, como **TensorFlow**, **JAX** y
**Keras**, PyTorch destaca por su creciente popularidad y por su estrecha vinculación
con la Linux Foundation, lo que garantiza un desarrollo sostenido y un soporte
comunitario cada vez mayor. Además, múltiples proyectos de terceros, como **Ray**,
utilizado para la creación de sistemas distribuidos de entrenamiento de modelos, también
forman parte del ecosistema de la Linux Foundation. Este entorno colaborativo impulsa la
innovación y asegura un soporte activo tanto por parte de empresas tecnológicas
reconocidas como de la comunidad de código abierto.

Una de las principales ventajas de PyTorch es su sintaxis intuitiva y expresiva, que
sigue de forma natural los principios del estilo "**pythónico**", es decir, un diseño
limpio y legible que favorece la comprensión del código.

Independientemente de la biblioteca elegida, los principios matemáticos y conceptuales
que sustentan el aprendizaje profundo son los mismos. Las diferencias radican
principalmente en la sintaxis y en las implementaciones específicas de cada entorno,
pero la base teórica y las operaciones fundamentales definidas sobre tensores permanecen
invariantes.

Los apartados siguientes establecen el aparato algebraico sobre el que se definen esas
operaciones, antes de volver a su expresión concreta en código.

## Vectores y sistemas de ecuaciones lineales

Cualquier objeto que pueda sumarse con otro objeto del mismo tipo y multiplicarse por un
escalar, devolviendo en ambos casos otro objeto del mismo tipo, se considera un
**vector**. La notación habitual emplea letra negrita, de forma que
$\mathbf{a} = \lbrack 1, 2, 3 \rbrack$ con $\mathbf{a} \in \mathbb{R}^3$ designa un
vector de tres componentes. En numerosas ocasiones los datos se tratan precisamente como
representaciones vectoriales en $\mathbb{R}^n$.

Cuando se formaliza un concepto, un enfoque frecuente consiste en construir un conjunto
de objetos y establecer reglas para manipularlos, lo que se conoce como álgebra. El
**álgebra lineal** estudia los vectores y las reglas que permiten manipularlos. Desde un
punto de vista abstracto, cualquier objeto que satisfaga las dos propiedades anteriores
es un vector, lo que abarca casos muy distintos entre sí:

- Los vectores geométricos, que pueden dibujarse en dos o tres dimensiones, sumarse
  entre sí y multiplicarse por un escalar $\lambda \in \mathbb{R}$.
- Los polinomios, que también admiten suma y producto por un escalar aunque se trate de
  objetos abstractos sin representación gráfica directa.
- Las señales de audio, que se suman y escalan como cualquier otra magnitud.
- Los elementos de $\mathbb{R}^n$, es decir, las tuplas de $n$ números reales.

Numerosos problemas se formulan como un **sistema de ecuaciones lineales**. Su forma
general relaciona $n$ incógnitas mediante $m$ ecuaciones:

$$
a_{11}x_1 + a_{12}x_2 + \ldots + a_{1n}x_n = b_1
$$

$$
a_{21}x_1 + a_{22}x_2 + \ldots + a_{2n}x_n = b_2
$$

$$
a_{m1}x_1 + a_{m2}x_2 + \ldots + a_{mn}x_n = b_m
$$

En estas expresiones $x_1, \ldots, x_n$ son las incógnitas del sistema, los $a_{ij}$ son
los coeficientes y $b_1, \ldots, b_m$ los términos independientes. Cada $n$-tupla
$(x_1, \ldots, x_n) \in \mathbb{R}^n$ que satisface todas las ecuaciones es una solución
del sistema. En general no existe una única solución, sino que el sistema puede admitir
infinitas o ninguna. Cuando no es posible resolverlo de forma exacta se recurre a la
regresión lineal para obtener una aproximación.

Un enfoque sistemático para resolver el sistema consiste en agrupar los coeficientes en
vectores y estos, a su vez, en una matriz:

$$
\begin{bmatrix}
a_{11} & \ldots & a_{1n} \\
\vdots & & \vdots \\
a_{m1} & \ldots & a_{mn}
\end{bmatrix}
\begin{bmatrix}
x_1 \\ \vdots \\ x_n
\end{bmatrix}
=
\begin{bmatrix}
b_1 \\ \vdots \\ b_m
\end{bmatrix}
$$

La primera matriz recoge los coeficientes, el vector $\mathbf{x}$ las incógnitas y el
vector $\mathbf{b}$ los términos independientes. Esta forma compacta
$\mathbf{A}\mathbf{x} = \mathbf{b}$ es la notación con la que se describe cualquier capa
lineal de una red neuronal, donde $\mathbf{A}$ contiene los pesos, $\mathbf{x}$ la
entrada y $\mathbf{b}$ el sesgo.

## Matrices y sus propiedades

Las matrices sirven para compactar sistemas de ecuaciones lineales, pero también para
representar funciones lineales o mapeos lineales. Una matriz puede además reorganizarse
como un vector de mayor longitud, de modo que una matriz
$\mathbf{A} \in \mathbb{R}^{4 \times 2}$ equivale, tras un cambio de forma, a un vector
$\mathbf{a} \in \mathbb{R}^8$. Esta operación de reorganización es la que en las
bibliotecas de cálculo numérico se conoce como _reshape_.

La suma de dos matrices $\mathbf{A} \in \mathbb{R}^{m \times n}$ y
$\mathbf{B} \in \mathbb{R}^{m \times n}$ se define elemento a elemento:

$$
\mathbf{A} + \mathbf{B} :=
\begin{bmatrix}
a_{11} + b_{11} & \cdots & a_{1n} + b_{1n} \\
\vdots & & \vdots \\
a_{m1} + b_{m1} & \cdots & a_{mn} + b_{mn}
\end{bmatrix} \in \mathbb{R}^{m \times n}
$$

El producto, en cambio, se calcula fila por columna y exige que el número de columnas de
la primera matriz coincida con el número de filas de la segunda. Para
$\mathbf{A} \in \mathbb{R}^{2 \times 3}$ y $\mathbf{B} \in \mathbb{R}^{3 \times 2}$ el
resultado pertenece a $\mathbb{R}^{2 \times 2}$:

$$
\begin{bmatrix} 1 & 2 & 3 \\ 3 & 2 & 1 \end{bmatrix}
\begin{bmatrix} 0 & 2 \\ 1 & -1 \\ 0 & 1 \end{bmatrix}
=
\begin{bmatrix} 2 & 3 \\ 2 & 5 \end{bmatrix}
$$

Cada elemento del resultado se obtiene sumando los productos de la fila correspondiente
de la primera matriz con la columna correspondiente de la segunda. El primer elemento,
por ejemplo, resulta de $1 \cdot 0 + 2 \cdot 1 + 3 \cdot 0 = 2$.

El producto de matrices satisface varias propiedades que conviene retener. No es
conmutativo, de forma que $\mathbf{A}\mathbf{B} \neq \mathbf{B}\mathbf{A}$ en general.
Sí es asociativo, por lo que
$(\mathbf{A}\mathbf{B})\mathbf{C} = \mathbf{A}(\mathbf{B}\mathbf{C})$ para dimensiones
compatibles. Y es distributivo respecto a la suma, cumpliéndose tanto
$(\mathbf{A} + \mathbf{B})\mathbf{C} = \mathbf{A}\mathbf{C} + \mathbf{B}\mathbf{C}$ como
$\mathbf{A}(\mathbf{C} + \mathbf{D}) = \mathbf{A}\mathbf{C} + \mathbf{A}\mathbf{D}$.

La **matriz identidad** $\mathbf{I}_n \in \mathbb{R}^{n \times n}$ es una matriz
cuadrada, con igual número de filas que de columnas, que presenta unos en la diagonal
principal y ceros en el resto:

$$
\mathbf{I}_n =
\begin{bmatrix}
1 & 0 & \ldots & 0 \\
0 & 1 & \ldots & 0 \\
\vdots & \vdots & & \vdots \\
0 & 0 & \ldots & 1
\end{bmatrix}
\in \mathbb{R}^{n \times n}
$$

Actúa como elemento neutro del producto, de modo que
$\mathbf{I}_m \mathbf{A} = \mathbf{A} \mathbf{I}_n = \mathbf{A}$ para cualquier
$\mathbf{A} \in \mathbb{R}^{m \times n}$. Conviene notar que
$\mathbf{I}_m \neq \mathbf{I}_n$ cuando $m \neq n$.

### Inversa y transpuesta

Dada una matriz cuadrada $\mathbf{A} \in \mathbb{R}^{n \times n}$, si existe otra matriz
$\mathbf{B} \in \mathbb{R}^{n \times n}$ tal que
$\mathbf{A}\mathbf{B} = \mathbf{I} = \mathbf{B}\mathbf{A}$, entonces $\mathbf{B}$ es la
**inversa** de $\mathbf{A}$ y se denota $\mathbf{A}^{-1}$. No todas las matrices tienen
inversa. Cuando la tienen se denominan regulares, invertibles o no singulares, y en caso
contrario singulares o no invertibles. Si la inversa existe es única, y la matriz ha de
ser necesariamente cuadrada. Una matriz es regular si, y solo si, su determinante es
distinto de cero.

La **transpuesta** de una matriz se obtiene escribiendo las columnas en la posición de
las filas y viceversa. Para $\mathbf{A} \in \mathbb{R}^{m \times n}$, la matriz
$\mathbf{B} \in \mathbb{R}^{n \times m}$ con $a_{ij} = b_{ji}$ es la transpuesta de
$\mathbf{A}$ y se escribe $\mathbf{B} = \mathbf{A}^T$:

$$
\mathbf{A} =
\begin{bmatrix}
1 & 2 & 3 \\
4 & 5 & 6 \\
7 & 8 & 9
\end{bmatrix}
\quad\longrightarrow\quad
\mathbf{A}^T =
\begin{bmatrix}
1 & 4 & 7 \\
2 & 5 & 8 \\
3 & 6 & 9
\end{bmatrix}
$$

Ambas operaciones cumplen un conjunto de propiedades de uso frecuente:

- $\mathbf{A}\mathbf{A}^{-1} = \mathbf{I} = \mathbf{A}^{-1}\mathbf{A}$.
- La inversa de un producto invierte el orden de los factores:
  $(\mathbf{A}\mathbf{B})^{-1} = \mathbf{B}^{-1}\mathbf{A}^{-1}$. Esta propiedad no se
  cumple para la suma, donde
  $(\mathbf{A} + \mathbf{B})^{-1} \neq \mathbf{A}^{-1} + \mathbf{B}^{-1}$.
- La transposición es involutiva: $(\mathbf{A}^T)^T = \mathbf{A}$.
- La transpuesta de un producto también invierte el orden:
  $(\mathbf{A}\mathbf{B})^T = \mathbf{B}^T\mathbf{A}^T$.
- La transpuesta de una suma es la suma de transpuestas:
  $(\mathbf{A} + \mathbf{B})^T = \mathbf{A}^T + \mathbf{B}^T$.
- Inversa y transpuesta conmutan entre sí:
  $(\mathbf{A}^{-1})^T = (\mathbf{A}^T)^{-1} = \mathbf{A}^{-T}$.

Una matriz $\mathbf{A} \in \mathbb{R}^{n \times n}$ es **simétrica** si
$\mathbf{A} = \mathbf{A}^T$. Solo las matrices cuadradas pueden serlo. La suma de
matrices simétricas es siempre simétrica, mientras que el producto generalmente no lo
es. Las matrices simétricas aparecen de forma natural en inteligencia artificial como
matrices de covarianza y matrices de Gram, y su estructura es precisamente lo que hace
posibles las descomposiciones que se tratan más adelante.

## Eliminación gaussiana

Un sistema de ecuaciones lineales admite una representación compacta en forma matricial.
El sistema formado por las tres ecuaciones $2x_1 + 3x_2 + 5x_3 = 1$,
$4x_1 + 2x_2 + 7x_3 = -8$ y $9x_1 - 5x_2 - 3x_3 = 2$ se escribe como:

$$
\begin{bmatrix}
2 & 3 & 5 \\
4 & 2 & 7 \\
9 & -5 & -3
\end{bmatrix}
\begin{bmatrix}
x_1 \\ x_2 \\ x_3
\end{bmatrix}
=
\begin{bmatrix}
1 \\ -8 \\ 2
\end{bmatrix}
$$

En la forma $\mathbf{A}\mathbf{x} = \mathbf{b}$, el producto $\mathbf{A}\mathbf{x}$ es
una combinación lineal de las columnas de $\mathbf{A}$.

Las **transformaciones elementales** permiten simplificar el sistema sin alterar su
solución. Son tres: intercambiar la posición de dos ecuaciones, multiplicar una ecuación
por un escalar distinto de cero y sumar ecuaciones entre sí.

Un concepto central asociado es el de **matriz escalonada**, aquella que presenta un
pivote en cada fila no nula. El pivote es el primer valor distinto de cero empezando por
la izquierda, y mediante transformaciones elementales se busca anular los valores
situados por debajo de la diagonal principal. Este procedimiento constituye el algoritmo
de **eliminación gaussiana**, que aplica operaciones elementales hasta obtener una
matriz escalonada reducida. El número de pivotes obtenidos es el rango de la matriz,
dato que permite determinar si las columnas de un conjunto de datos son linealmente
independientes o si existen características redundantes.

El mismo algoritmo permite calcular la inversa de una matriz. Se trata de encontrar una
matriz $\mathbf{X}$ que satisfaga $\mathbf{A}\mathbf{X} = \mathbf{I}_n$, lo que se
consigue partiendo de la matriz aumentada y aplicando transformaciones elementales hasta
que el bloque izquierdo se convierta en la identidad:

$$
\lbrack \mathbf{A} \mid \mathbf{I}_n \rbrack \rightsquigarrow \ldots \rightsquigarrow
\lbrack \mathbf{I}_n \mid \mathbf{A}^{-1} \rbrack
$$

### Métodos para resolver sistemas de ecuaciones lineales

Para resolver un sistema de la forma $\mathbf{A}\mathbf{x} = \mathbf{b}$ se parte del
supuesto de que la solución existe. En algunos casos particulares la inversa de la
matriz proporciona directamente la solución mediante
$\mathbf{x} = \mathbf{A}^{-1}\mathbf{b}$, aunque esto solo es posible si $\mathbf{A}$ es
cuadrada e invertible, lo que no suele ocurrir en la práctica.

Cuando $\mathbf{A}$ tiene columnas linealmente independientes se recurre a la siguiente
transformación:

$$
\mathbf{A}\mathbf{x} = \mathbf{b} \iff \mathbf{A}^{T}\mathbf{A}\mathbf{x} =
\mathbf{A}^{T}\mathbf{b} \iff \mathbf{x} =
(\mathbf{A}^{T}\mathbf{A})^{-1}\mathbf{A}^{T}\mathbf{b}
$$

La expresión $(\mathbf{A}^{T}\mathbf{A})^{-1}\mathbf{A}^{T}$ es la **pseudoinversa de
Moore-Penrose**, que se corresponde con la solución de mínimos cuadrados. Esta fórmula
es la solución cerrada de la regresión lineal: dado un conjunto de datos $\mathbf{A}$ y
unas observaciones $\mathbf{b}$, devuelve directamente los pesos óptimos sin necesidad
de descenso del gradiente. En la práctica, el elevado coste de calcular el producto de
matrices y la inversa de $\mathbf{A}^{T}\mathbf{A}$ hace que se prefiera resolver el
problema mediante descomposiciones como la descomposición en valores singulares, o de
forma iterativa cuando el número de parámetros es grande.

## Espacios vectoriales y subespacios

Los espacios vectoriales son los espacios estructurados donde residen los vectores. Un
**espacio vectorial** es un conjunto $V$ sobre el que están definidas dos operaciones,
la suma de vectores y el producto por un escalar, de forma que el resultado de ambas
sigue perteneciendo a $V$. El elemento neutro de la suma es el vector cero
$\mathbf{0} = \lbrack 0 \; 0 \; \ldots \; 0 \rbrack^{T}$.

En la práctica de la inteligencia artificial el espacio vectorial relevante es
$\mathbb{R}^n$, donde residen los _embeddings_, las activaciones de cada capa y los
vectores de características. Que estas operaciones estén bien definidas es precisamente
lo que permite sumar representaciones, escalarlas y combinarlas linealmente.

Un **subespacio vectorial** es un conjunto contenido en el espacio vectorial original
que conserva la estructura al operar con sus elementos. Siendo $V = (V, +, \cdot)$ un
espacio vectorial y $U \subseteq V$ con $U \neq \emptyset$, entonces $U = (U, +, \cdot)$
es un subespacio de $V$ si $U$ es a su vez un espacio vectorial con la suma y el
producto por escalar restringidos a $U \times U$ y a $\mathbb{R} \times U$.

Los subespacios cumplen dos propiedades características. La primera es que $U$ no puede
ser el conjunto vacío y, en particular, contiene siempre el vector cero. La segunda es
el cierre respecto a ambas operaciones, de forma que $\lambda \mathbf{x} \in U$ para
cualquier escalar $\lambda \in \mathbb{R}$ y $\mathbf{x} + \mathbf{y} \in U$ para
cualquier par de vectores del subespacio.

Esta idea es la base de técnicas como el análisis de componentes principales: los datos
de alta dimensión se proyectan sobre un subespacio de dimensión mucho menor que retiene
la mayor parte de la información.

## Independencia lineal

Considerando un espacio vectorial $V$ y un número finito de vectores
$\mathbf{x}_1, \ldots, \mathbf{x}_k \in V$, cada vector $\mathbf{v} \in V$ de la forma:

$$
\mathbf{v} = \lambda_1 \mathbf{x}_1 + \ldots + \lambda_k \mathbf{x}_k = \sum_{i=1}^{k}
\lambda_i \mathbf{x}_i \in V
$$

con $\lambda_1, \ldots, \lambda_k \in \mathbb{R}$ es una **combinación lineal** de los
vectores $\mathbf{x}_1, \ldots, \mathbf{x}_k$. El vector cero puede escribirse siempre
como combinación lineal de cualquier conjunto de $k$ vectores. Este concepto es uno de
los más importantes del álgebra lineal.

Varios criterios permiten determinar si un conjunto de vectores es linealmente
independiente:

- Si uno de los vectores es el vector cero, el conjunto es linealmente dependiente. Lo
  mismo ocurre si dos de los vectores son iguales.
- Los vectores son linealmente dependientes si, y solo si, uno de ellos es combinación
  lineal del resto. Un caso particular se da cuando un vector es múltiplo de otro.
- La eliminación gaussiana permite comprobar la dependencia lineal mediante la obtención
  de una matriz escalonada.
- Las columnas de una matriz son linealmente independientes si, y solo si, todas ellas
  son columnas pivote.

### Conjuntos generadores y bases

Considerando un espacio vectorial $V = (V, +, \cdot)$ y un conjunto de vectores
$A = \{\mathbf{x}_1, \ldots, \mathbf{x}_k\} \subseteq V$, si cada vector
$\mathbf{v} \in V$ puede expresarse como combinación lineal de los elementos de $A$,
entonces $A$ es un **conjunto generador** de $V$. El conjunto de todas las combinaciones
lineales de los vectores de $A$ se denomina _span_ de $A$.

Una **base** es un sistema generador cuyos vectores son linealmente independientes. Una
de las bases más empleadas es la base canónica, que en $\mathbb{R}^n$ toma la forma:

$$
B = \{(1, 0, \ldots, 0), (0, 1, \ldots, 0), \ldots, (0, \ldots, 1)\}
$$

La **dimensión** de un espacio vectorial $V$ es el número de vectores de cualquiera de
sus bases. Si $U \subseteq V$ es un subespacio de $V$, entonces $\dim(U) \leq \dim(V)$,
y la igualdad $\dim(U) = \dim(V)$ se alcanza únicamente cuando $U = V$.

## Rango

El **rango** de una matriz es el número de filas linealmente independientes. Las
matrices equivalentes por filas comparten el mismo rango, y en el caso de las matrices
escalonadas reducidas el rango coincide con el número de filas no nulas. Esta magnitud
presenta propiedades de interés directo en el análisis de datos:

- El rango es invariante frente a la transposición:
  $\mathrm{rk}(\mathbf{A}) = \mathrm{rk}(\mathbf{A}^{T})$.
- Una matriz cuadrada $\mathbf{A} \in \mathbb{R}^{n \times n}$ es regular, es decir
  invertible, si y solo si $\mathrm{rk}(\mathbf{A}) = n$.
- Dado un vector $\mathbf{b}$ con el mismo número de filas que $\mathbf{A}$, el sistema
  $\mathbf{A}\mathbf{x} = \mathbf{b}$ tiene solución si y solo si
  $\mathrm{rk}(\mathbf{A}) = \mathrm{rk}(\mathbf{A} \mid \mathbf{b})$, donde
  $\mathbf{A} \mid \mathbf{b}$ denota la matriz aumentada.
- El subespacio formado por las soluciones de $\mathbf{A}\mathbf{x} = \mathbf{0}$ tiene
  dimensión $n - \mathrm{rk}(\mathbf{A})$. Este subespacio recibe el nombre de núcleo o
  _kernel_.

## Mapeos lineales

Partiendo de dos espacios vectoriales $V_1$ y $V_2$ definidos sobre el mismo cuerpo de
escalares, una función $T: V_1 \rightarrow V_2$ es una **transformación lineal**,
también llamada mapeo lineal, si respeta la suma y el producto por escalar. La condición
sobre la suma se expresa como:

$$
T(\mathbf{u} + \mathbf{v}) = T(\mathbf{u}) + T(\mathbf{v})
$$

Conviene observar que la suma del miembro izquierdo tiene lugar en $V_1$ mientras que la
del miembro derecho ocurre en $V_2$, de modo que son operaciones distintas definidas en
espacios distintos. La condición sobre el producto por escalar es análoga:

$$
T(\alpha \mathbf{v}) = \alpha T(\mathbf{v})
$$

En este caso el escalar $\alpha$ es el mismo en ambos miembros.

Un ejemplo ilustrativo toma $V_1 = \mathbb{R}_3\lbrack x \rbrack$, el espacio de los
polinomios de grado menor o igual que tres sobre $\mathbb{R}$, y
$V_2 = \mathbb{R}_2\lbrack x \rbrack$. La función $T$ definida como $T(p(x)) = p'(x)$,
es decir la derivada, cumple ambas condiciones:

$$
T(p(x) + q(x)) = (p(x) + q(x))' = p'(x) + q'(x) = T(p(x)) + T(q(x))
$$

$$
T(\alpha p(x)) = (\alpha p(x))' = \alpha p'(x) = \alpha T(p(x))
$$

Como las dos propiedades se satisfacen, $T$ es una transformación lineal. El grado de la
derivada de un polinomio es menor que el del polinomio original, lo que justifica que la
imagen pertenezca a $\mathbb{R}_2\lbrack x \rbrack$.

!!! note

    La derivada de una función es la razón de cambio instantánea del valor de dicha
    función, y su interpretación geométrica corresponde con la pendiente de la recta
    tangente a la función en un punto.

Toda transformación lineal $T: V_1 \rightarrow V_2$ satisface además
$T(\mathbf{0}) = \mathbf{0}$ y $T(-\mathbf{v}) = -T(\mathbf{v})$.

Las transformaciones lineales se representan mediante matrices, ya que al trabajar con
matrices se está operando en realidad con transformaciones lineales o con colecciones de
vectores. El término transformación es en esencia otra forma de decir función: toma unas
entradas y produce una salida para cada una de ellas. Aplicado al álgebra lineal, toma
un vector y devuelve otro vector.

Gráficamente, una transformación es lineal si cumple dos condiciones. La primera es que
las líneas rectas no se curvan, de forma que las rectas paralelas permanecen paralelas y
equidistantes tras la transformación. La segunda es que el origen se mantiene fijo en su
posición.

Para describir numéricamente estas transformaciones conviene partir de un ejemplo.
Considerando el vector
$\mathbf{v} = \lbrack -1, 2 \rbrack = -1\mathbf{i} + 2\mathbf{j}$, la propiedad de que
las líneas permanecen paralelas y equidistantes implica que el vector transformado es la
misma combinación lineal de los vectores base transformados:

$$
T(\mathbf{v}) = -1 \cdot T(\mathbf{i}) + 2 \cdot T(\mathbf{j})
$$

Si la transformación lleva $\mathbf{i}$ a $\begin{bmatrix}1\\-2\end{bmatrix}$ y
$\mathbf{j}$ a $\begin{bmatrix}3\\0\end{bmatrix}$, el resultado es:

$$
T(\mathbf{v}) = -1 \begin{bmatrix}1\\-2\end{bmatrix} + 2
\begin{bmatrix}3\\0\end{bmatrix} = \begin{bmatrix}-1\\2\end{bmatrix} +
\begin{bmatrix}6\\0\end{bmatrix} = \begin{bmatrix}5\\2\end{bmatrix}
$$

La conclusión es que una transformación lineal bidimensional queda completamente
descrita por cuatro números, las coordenadas donde caen $\mathbf{i}$ y $\mathbf{j}$, que
se agrupan en una matriz cuya primera columna es el destino de $\mathbf{i}$ y cuya
segunda columna es el destino de $\mathbf{j}$:

$$
\begin{bmatrix}1 & 3\\-2 & 0\end{bmatrix}
$$

Generalizando a un vector arbitrario, la transformación se expresa como:

$$
\begin{bmatrix}a & b\\c & d\end{bmatrix}\begin{bmatrix}x\\y\end{bmatrix} =
x\begin{bmatrix}a\\c\end{bmatrix} + y\begin{bmatrix}b\\d\end{bmatrix} =
\begin{bmatrix}ax+by\\cx+dy\end{bmatrix}
$$

El razonamiento se extiende a dimensiones superiores sin cambios conceptuales. Con
vectores de entrada y salida tridimensionales intervienen tres vectores base,
$\hat{\mathbf{i}}$, $\hat{\mathbf{j}}$ y $\hat{\mathbf{k}}$, correspondientes a las
direcciones $x$, $y$ y $z$:

$$
\begin{bmatrix}a & b & c\\d & e & f\\g & h & i\end{bmatrix}
\begin{bmatrix}x\\y\\z\end{bmatrix} = x\begin{bmatrix}a\\d\\g\end{bmatrix} +
y\begin{bmatrix}b\\e\\h\end{bmatrix} + z\begin{bmatrix}c\\f\\i\end{bmatrix}
$$

Los vectores base forman un conjunto linealmente independiente. En el espacio
bidimensional, por ejemplo, no existe ninguna combinación de $\hat{\mathbf{i}}$ que
permita obtener $\hat{\mathbf{j}}$, ni al contrario.

## Cambios de base

Una matriz de cambio de base transforma las coordenadas de un vector de un sistema de
referencia a otro. Al situar dos ejes sobre un plano arbitrario de $\mathbb{R}^2$ se
establece un sistema de referencia determinado por los vectores $\hat{\mathbf{i}}$ y
$\hat{\mathbf{j}}$, que constituyen la base canónica y generan todo el plano.

Un vector $\mathbf{u} = \begin{pmatrix}4\\3\end{pmatrix}$ expresado en la base canónica
se denota $\lbrack \mathbf{u} \rbrack_C$. Sin embargo, la base canónica no es la única
posible. Tomando otros dos vectores $\mathbf{v}$ y $\mathbf{w}$ que también formen base
de $\mathbb{R}^2$, se obtiene una base alternativa $B = \{\mathbf{v}, \mathbf{w}\}$. Si
$\mathbf{v} = 0{,}64\hat{\mathbf{i}} + 0{,}77\hat{\mathbf{j}}$ y
$\mathbf{w} = -0{,}5\hat{\mathbf{i}} + 0{,}87\hat{\mathbf{j}}$, un vector cuyas
coordenadas en la base $B$ son $(4, 3)$ se expresa en la base canónica mediante el
siguiente producto:

$$
\begin{pmatrix}0{,}64 & -0{,}5\\0{,}77 & 0{,}87\end{pmatrix}
\begin{pmatrix}4\\3\end{pmatrix} = \begin{pmatrix}1{,}06\\5{,}69\end{pmatrix}
$$

La primera matriz es la matriz de cambio de base $\mathbf{P}_{BC}$, el vector $(4, 3)$
corresponde a $\lbrack \mathbf{u} \rbrack_B$ y el resultado a
$\lbrack \mathbf{u} \rbrack_C$. La matriz $\mathbf{P}_{BC}$ se construye colocando en
columnas los vectores de la base de partida expresados en la base de destino. Para
recorrer el camino inverso basta con aplicar su inversa, ya que de
$\mathbf{P}_{BC} \lbrack \mathbf{u} \rbrack_B = \lbrack \mathbf{u} \rbrack_C$ se deduce
que $\lbrack \mathbf{u} \rbrack_B = \mathbf{P}_{BC}^{-1} \lbrack \mathbf{u} \rbrack_C$.

Este cambio de representación es exactamente lo que realiza el análisis de componentes
principales: elegir una base nueva, alineada con las direcciones de máxima varianza de
los datos, y reescribir cada muestra en esas coordenadas. Se trata de las mismas
muestras descritas con otros ejes.

## Imagen y núcleo

La imagen y el núcleo de una transformación lineal son subespacios vectoriales con
propiedades de especial relevancia. Sea $f: V \rightarrow W$ una transformación lineal.
El **núcleo** de $f$ se define como el conjunto de vectores de $V$ cuya imagen es el
vector cero:

$$
\mathrm{Ker}(f) = \{\mathbf{x} \in V \mid f(\mathbf{x}) = \mathbf{0}\} = f^{-1}(\mathbf{0})
$$

La **imagen** de $f$ es el conjunto de vectores de $W$ que son imagen de algún vector de
$V$:

$$
\mathrm{Im}(f) = \{f(\mathbf{v}) \in W \mid \mathbf{v} \in V\}
$$

El núcleo es un subespacio vectorial de $V$ y la imagen un subespacio vectorial de $W$,
de modo que para ambos puede calcularse la dimensión y obtenerse una base. El núcleo
nunca es el conjunto vacío, ya que contiene como mínimo el vector cero.

Considerando una matriz $\mathbf{A} \in \mathbb{R}^{m \times n}$ y la transformación
lineal asociada $T: \mathbb{R}^n \rightarrow \mathbb{R}^m$ definida por
$\mathbf{x} \mapsto \mathbf{A}\mathbf{x}$, se cumplen las siguientes relaciones:

- El rango coincide con la dimensión de la imagen:
  $\mathrm{rk}(\mathbf{A}) = \dim(\mathrm{Im}(T))$.
- El núcleo es la solución general del sistema homogéneo
  $\mathbf{A}\mathbf{x} = \mathbf{0}$ y recoge todas las combinaciones lineales de
  elementos de $\mathbb{R}^n$ que producen el vector cero de $\mathbb{R}^m$.
- El núcleo es un subespacio de $\mathbb{R}^n$, donde $n$ es el número de columnas de la
  matriz.
- El núcleo describe la relación entre las columnas, por lo que permite determinar cómo
  expresar una columna como combinación lineal de las demás.

La relación entre las dimensiones de la imagen y del núcleo queda recogida en la
siguiente igualdad:

$$
\dim(V) = \dim(\mathrm{Ker}) + \dim(\mathrm{Im})
$$

La lectura práctica de esta relación es directa. Un núcleo no trivial significa que
existen columnas que son combinación lineal de otras, es decir, características
redundantes en el conjunto de datos o neuronas que no aportan capacidad expresiva. El
rango indica cuánta información efectiva contiene realmente la matriz, y es el criterio
con el que se decide cuántas componentes conservar al comprimir una representación.

## Operaciones vectoriales

Los conceptos anteriores se expresan en código sobre tensores. Los vectores constituyen
tensores unidimensionales, habitualmente representados como $x \sim (d)$, donde $d$
indica la dimensión del tensor. Resulta fundamental distinguir entre vectores columna y
vectores fila, denotados respectivamente por $\mathbf{x}$ y $\mathbf{x}^\top$ mediante
la transpuesta introducida anteriormente. Un vector columna puede considerarse como un
tensor bidimensional de forma $(d, 1)$, mientras que un vector fila posee forma
$(1, d)$.

Esta distinción es particularmente relevante en entornos de programación, donde las
operaciones entre tensores deben cumplir las reglas de **_broadcasting_**, las cuales
determinan cómo se alinean las dimensiones durante las operaciones aritméticas. En
PyTorch, cuando las dimensiones de los tensores son incompatibles, puede ser necesario
utilizar funciones como `squeeze()`, `unsqueeze()` o `view()` para ajustar su
estructura. Dado que la biblioteca se actualiza con frecuencia, se recomienda consultar
la documentación oficial para obtener información actualizada sobre las funciones
disponibles.

Si se disponen dos vectores del mismo tamaño, $\mathbf{x}$ y $\mathbf{y}$, es posible
combinarlos linealmente mediante coeficientes escalares $a$ y $b$, generando un nuevo
vector $\mathbf{z}$, tal que:

$$
\mathbf{z} = a \mathbf{x} + b \mathbf{y}.
$$

Desde una perspectiva geométrica, en un espacio euclidiano bidimensional, la suma de
vectores puede interpretarse como la **diagonal del paralelogramo** definido por ambos
vectores.

### Norma

Al pensar en vectores geométricos como segmentos rígidos que comienzan en el origen, la
longitud de un vector se corresponde intuitivamente con la distancia desde el origen
hasta su extremo. Esta noción se formaliza mediante el concepto de **norma**, definida
como la magnitud o longitud de un vector. Toda norma satisface tres propiedades:

- Definida positiva: $\|\mathbf{x}\| \geq 0$ y
  $\|\mathbf{x}\| = 0 \Leftrightarrow \mathbf{x} = \mathbf{0}$, es decir, la distancia
  no puede ser negativa.
- Absolutamente homogénea: $\|\lambda \mathbf{x}\| = |\lambda| \|\mathbf{x}\|$, de modo
  que la distancia crece o decrece con el producto por un escalar tomado en valor
  absoluto.
- Desigualdad triangular:
  $\|\mathbf{x}+\mathbf{y}\| \leq \|\mathbf{x}\| + \|\mathbf{y}\|$. La igualdad se
  alcanza únicamente cuando los vectores son colineales y del mismo sentido.

Existen diferentes tipos de normas, agrupadas bajo la familia de las normas de Hölder:

$$
\|\mathbf{x}\|_p = \sqrt[p]{\sum_{i=1}^{n} |x_i|^p}
$$

De esta familia derivan los casos de uso más frecuente. La **norma $L_1$**, también
llamada norma Manhattan o norma de la suma de módulos, corresponde a $p = 1$ y se
calcula como $\|\mathbf{x}\|_1 = \sum_{i=1}^{n} |x_i|$. La **norma euclídea** o norma
$L_2$ corresponde a $p = 2$ y representa la distancia del vector al origen del sistema
de coordenadas:

$$
\|\mathbf{x}\|_2 = \sqrt{\sum_{i=1}^{n} |x_i|^2}
$$

La **norma del máximo**, caso límite cuando $p$ tiende a infinito, selecciona la
componente de mayor magnitud:

$$
\|\mathbf{x}\|_\infty = \max_{i=1,\dots,n} |x_i|
$$

Las dos primeras normas son las que aparecen en la regularización de modelos. Penalizar
los pesos con la norma $L_1$ tiende a anular coeficientes por completo, lo que produce
modelos dispersos y actúa como selección de características. Penalizar con la norma
$L_2$ reduce los pesos de forma proporcional sin llevarlos a cero, limitando el
sobreajuste. La norma $L_2$ es además la que se emplea para normalizar _embeddings_
antes de comparar direcciones, y la norma del máximo aparece al acotar perturbaciones en
ejemplos adversarios.

### Producto interno y similitud del coseno

El **producto interno**, escrito $\langle \mathbf{x},\mathbf{y} \rangle$, generaliza el
**producto escalar** o **producto punto** y es la operación con la que se miden ángulos
y longitudes. El caso habitual en inteligencia artificial es el producto punto estándar:

$$
\langle \mathbf{x},\mathbf{y} \rangle = \mathbf{x}^T \mathbf{y} = \sum_{i=1}^{n} x_i y_i
$$

De forma más general, dada una matriz $\mathbf{A} \in \mathbb{R}^{n \times n}$ simétrica
y definida positiva, la expresión
$\langle \mathbf{x},\mathbf{y} \rangle = \mathbf{x}^T \mathbf{A} \mathbf{y}$ también
define un producto interno. Esta forma cuadrática aparece en la **distancia de
Mahalanobis**, donde $\mathbf{A}$ es la inversa de la matriz de covarianza y permite
medir distancias teniendo en cuenta la escala y la correlación entre características, en
lugar de tratar todas las dimensiones por igual. Una propiedad que conviene retener es
que si $\mathbf{A}$ es definida positiva, entonces
$\mathbf{x}^T \mathbf{A} \mathbf{x} > 0$ para todo $\mathbf{x} \neq \mathbf{0}$, lo que
garantiza que ciertas descomposiciones, como la de Cholesky, resulten aplicables.

El resultado del producto interno es un escalar con una interpretación geométrica
directa, ya que permite determinar el **ángulo entre dos vectores** y, en consecuencia,
su **similitud direccional**. Partiendo de un vector situado sobre el eje de abscisas y
otro que forma un ángulo $\theta$ con dicho eje, la proyección del segundo sobre el
primero conduce a la relación:

$$
\cos\theta = \frac{\langle \mathbf{x},\mathbf{y} \rangle}{\|\mathbf{x}\| \|\mathbf{y}\|}
= \frac{\sum_{i=1}^{n} x_i y_i}{\sqrt{\sum_{i=1}^{n}|x_i|^2}
\sqrt{\sum_{i=1}^{n}|y_i|^2}}
$$

Despejando el ángulo mediante el arco coseno se obtiene su valor explícito:

$$
\theta = \arccos \frac{\langle \mathbf{x},\mathbf{y} \rangle}{\|\mathbf{x}\|
\|\mathbf{y}\|}
$$

Dado que el coseno está acotado entre $-1$ y $1$, el ángulo resultante nunca excede ese
rango. La lectura de los casos extremos es inmediata:

- Si $\cos(\theta) = 1$, los vectores apuntan en la misma dirección.
- Si $\cos(\theta) = 0$, los vectores son ortogonales, es decir, forman un ángulo de 90
  grados entre sí.
- Si $\cos(\theta) = -1$, los vectores son opuestos, con un ángulo de 180 grados entre
  ambos.

Esta medida se conoce como **similitud del coseno** y desempeña un papel fundamental en
tareas de **agrupamiento (_clustering_)**, búsqueda semántica y **representaciones
latentes**. Tiene aplicación directa en los **_word embeddings_**, representaciones
vectoriales del lenguaje en las que cada palabra se codifica como un punto dentro de un
espacio semántico de alta dimensionalidad. Modelos como GPT-2 y GPT-3 utilizan
representaciones de entre 768 y más de 12000 dimensiones, lo que permite capturar
relaciones semánticas y sintácticas a través de simples operaciones vectoriales.

### Ortogonalidad

El caso en que el producto interno de dos vectores es cero merece atención propia. Si
$\langle \mathbf{x},\mathbf{y} \rangle = 0$, entonces $\cos\theta = 0$ y por tanto
$\theta = 90°$. Cualquier vector que forme un ángulo recto con otro se denomina **vector
ortogonal**, lo que se escribe $\mathbf{x} \perp \mathbf{y}$.

Dos vectores ortogonales son perpendiculares entre sí, lo que significa que cada uno
varía de forma independiente del otro. Considerados en conjunto pueden influir en la
solución final, pero tomados por separado no guardan relación. En aprendizaje automático
esta propiedad resulta muy útil, ya que permite identificar qué características son
independientes de las demás y, por tanto, decidir qué columnas conviene mantener y
cuáles pueden descartarse al reducir la dimensionalidad de un conjunto de datos.

Si además ambos vectores son unitarios, de forma que
$\|\mathbf{x}\| = 1 = \|\mathbf{y}\|$, entonces se denominan **ortonormales**. Una
implicación de la definición es que el vector cero resulta ortogonal a cualquier vector
del espacio vectorial.

A continuación, se presenta un ejemplo de implementación de la similitud del coseno
utilizando Python con la biblioteca **NumPy**:

```py linenums="1"
import numpy as np

def normalizar_matriz(matriz: np.ndarray) -> np.ndarray:
    return matriz / np.expand_dims(np.sqrt(np.sum(np.power(matriz, 2), axis=1)), axis=-1)

def cosine_similarity(matriz: np.ndarray) -> np.ndarray:
    return matriz @ matriz.T

X = np.array([
    [1, 2, 3],
    [4, 5, 6],
    [1, 0, 0],
    [0, 1, 0]
], dtype=float)

X_normalized = normalizar_matriz(X)
similarity_matrix = cosine_similarity(X_normalized)
print(similarity_matrix)
```

El siguiente código muestra el mismo procedimiento utilizando **PyTorch**:

```py linenums="1"
import torch
import torch.nn.functional as F

X = torch.tensor([
    [1., 2., 3.],
    [4., 5., 6.],
    [1., 0., 0.],
    [0., 1., 0.]
])

# Normalización
X_norm = F.normalize(X, p=2, dim=1)

# Cálculo de la matriz de similitud
similarity = X_norm @ X_norm.T
print(similarity)
```

El resultado obtenido en ambos casos es una matriz de tamaño $N \times N$ que contiene
los valores de similitud entre cada par de vectores. En la diagonal principal aparecen
valores iguales a 1, ya que cada vector presenta similitud máxima consigo mismo.

## Operaciones matriciales

Una matriz es un arreglo bidimensional que organiza los datos en filas y columnas, por
lo que puede entenderse como una **colección ordenada de vectores**. Matemáticamente,
una matriz $X \in \mathbb{R}^{A \times B}$ está compuesta por $A$ filas y $B$ columnas,
donde cada elemento $x_{ij}$ representa el valor ubicado en la fila $i$ y la columna
$j$.

Si se dispone de una matriz $X \in \mathbb{R}^{A \times B}$ y otra
$Y \in \mathbb{R}^{B \times C}$, su **producto matricial** se define como:

$$
Z = X Y,
$$

donde $Z \in \mathbb{R}^{A \times C}$. Esta operación es válida únicamente cuando el
número de columnas de $X$ coincide con el número de filas de $Y$. En términos
algebraicos, cada elemento de la matriz resultante se calcula como:

$$
Z_{ij} = \sum_{k=1}^{B} X_{ik} \cdot Y_{kj}.
$$

El producto matricial es una de las operaciones más utilizadas en el aprendizaje
profundo, ya que permite procesar simultáneamente grandes volúmenes de información. En
el contexto de una capa neuronal, los datos de entrada suelen representarse mediante una
matriz donde cada fila corresponde a una muestra y cada columna a una característica. Al
multiplicar esta matriz por otra que contiene los pesos del modelo, se obtiene una
transformación lineal de las entradas, a la cual se suma posteriormente un vector de
sesgo.

Además del producto matricial convencional, existen otras operaciones de gran relevancia
en el cálculo numérico y el aprendizaje profundo. Una de ellas es el **producto de
Hadamard**, también conocido como multiplicación elemento a elemento. A diferencia del
producto matricial, esta operación se realiza exclusivamente entre matrices del mismo
tamaño y se define como:

$$
Z_{ij} = X_{ij} \cdot Y_{ij}.
$$

El producto de Hadamard se emplea en múltiples contextos, entre los cuales destaca su
uso en **mecanismos de enmascaramiento** (_masking_) durante el entrenamiento de
modelos. Esta técnica permite ignorar valores específicos de un tensor para impedir que
influyan en el cálculo de los gradientes o en la propagación de errores. Dicha propiedad
es esencial en arquitecturas modernas como **_Transformers_**, donde se aplica para
restringir la atención a determinadas posiciones o para manejar secuencias de longitud
variable sin afectar el aprendizaje global del modelo.

## Operaciones con tensores

La biblioteca PyTorch proporciona un conjunto amplio, eficiente y flexible de
herramientas para la creación, manipulación y transformación de tensores, que
constituyen la estructura de datos fundamental en el aprendizaje profundo. Los tensores
generalizan los conceptos de escalares, vectores y matrices hacia dimensiones
superiores, lo que permite representar datos complejos de manera multidimensional y
realizar operaciones matemáticas de forma vectorizada y optimizada.

A continuación, se presentan ejemplos prácticos y comentados que ilustran las
operaciones más comunes con tensores en PyTorch. Estas operaciones son esenciales para
comprender el funcionamiento interno del código empleado en la creación de modelos de
aprendizaje profundo. En la práctica, muchas arquitecturas modernas o modificaciones de
arquitecturas existentes surgen a partir de pequeñas variaciones en la manipulación de
tensores, ya sea mediante la selección de elementos específicos (_slicing_), la
optimización de cálculos o el uso de estrategias que reduzcan el coste computacional.

Para crear tensores, es posible hacerlo a partir de listas, mediante inicialización
aleatoria o con valores fijos:

```py linenums="1"
import torch

# Tensores básicos
escalar = torch.tensor(7)
vector = torch.tensor([1, 2, 3])
matriz = torch.tensor([[1, 2, 3], [4, 5, 6]])

# Tensores aleatorios y de valores fijos
tensor_aleatorio = torch.rand((2, 3))
ceros = torch.zeros((2, 3))
unos = torch.ones((2, 3))
rango = torch.arange(0, 10, 2)

print("Escalar:", escalar)
print("Vector:", vector)
print("Matriz:\n", matriz)
print("Tensor aleatorio:\n", tensor_aleatorio)
print("Tensor de ceros:\n", ceros)
print("Tensor de unos:\n", unos)
print("Rango:", rango)
```

Cada tensor contiene información sobre su **tipo de dato**, sus **dimensiones** y el
**dispositivo de almacenamiento** (CPU o GPU). El tipo de dato (`dtype`) determina la
precisión numérica del tensor; a mayor precisión, mayor será el rango de valores
posibles, pero también el consumo de memoria. El dispositivo (`device`) es relevante
porque un tensor ubicado en la GPU no puede ser manipulado directamente desde la CPU,
por lo que es necesario transferirlo o copiarlo según sea necesario:

```py linenums="1"
tensor = torch.rand((2, 3, 4))
print("Tipo de dato:", tensor.dtype)
print("Forma:", tensor.shape)
print("Dispositivo:", tensor.device)
print("Número de elementos:", tensor.numel())
```

Las operaciones de agregación permiten resumir la información contenida en un tensor.
Algunas de las más comunes son la suma, la media o la obtención del valor máximo o
mínimo. El parámetro `dim` indica el eje sobre el cual se aplica la operación, donde
`dim=0` actúa sobre las filas (por columnas), mientras que `dim=1` actúa sobre las
columnas (por filas):

```py linenums="1"
tensor = torch.tensor([[1., 2., 3.], [4., 5., 6.]])

print("Suma total:", tensor.sum())
print("Promedio:", tensor.mean())
print("Máximo por columna:", tensor.max(dim=0))
print("Promedio por fila:", tensor.mean(dim=1))
```

Otras funciones, como `view()`, `reshape()`, `unsqueeze()` y `squeeze()`, permiten
modificar la forma del tensor sin alterar sus datos subyacentes. Estas operaciones son
fundamentales para adaptar las dimensiones de los tensores según las necesidades de las
redes neuronales:

```py linenums="1"
x = torch.arange(1, 7)
print("Tensor original:", x)

# Cambiar forma
x_reshaped = x.view(2, 3)
print("Tensor 2x3:\n", x_reshaped)

# Añadir dimensión
x_unsqueezed = x.unsqueeze(0)
print("Tensor con nueva dimensión:", x_unsqueezed.shape)

# Eliminar dimensión
x_squeezed = x_unsqueezed.squeeze()
print("Tensor tras eliminar dimensión:", x_squeezed.shape)
```

Las funciones `permute()` y `transpose()` permiten reordenar las dimensiones de un
tensor, lo cual es especialmente útil en el procesamiento de imágenes o secuencias, por
ejemplo, al desplazar canales de color o mapas de características:

```py linenums="1"
tensor = torch.rand((2, 3, 4))
print("Forma original:", tensor.shape)

# Transposición (intercambio de dos dimensiones)
tensor_T = tensor.transpose(1, 2)
print("Forma tras transpose:", tensor_T.shape)

# Permutación general de ejes
tensor_P = tensor.permute(2, 0, 1)
print("Forma tras permute:", tensor_P.shape)
```

También es posible combinar tensores mediante funciones como `torch.cat()` y
`torch.stack()`. La primera une tensores existentes a lo largo de un eje específico,
mientras que la segunda crea una nueva dimensión para apilarlos:

```py linenums="1"
a = torch.tensor([[1, 2], [3, 4]])
b = torch.tensor([[5, 6], [7, 8]])

# Concatenación (mismo número de filas)
cat_0 = torch.cat((a, b), dim=0)
cat_1 = torch.cat((a, b), dim=1)

# Apilamiento (nueva dimensión)
stacked = torch.stack((a, b), dim=0)

print("Concatenación por filas:\n", cat_0)
print("Concatenación por columnas:\n", cat_1)
print("Apilamiento (nueva dimensión):\n", stacked)
```

PyTorch implementa una gran cantidad de **operaciones vectorizadas**, que permiten
realizar cálculos sin recurrir a bucles explícitos. Este enfoque no solo mejora la
legibilidad del código, sino que también aprovecha las optimizaciones internas del
framework y del hardware subyacente, como las implementaciones en CUDA para GPU:

```py linenums="1"
x = torch.tensor([1., 2., 3.])
y = torch.tensor([4., 5., 6.])

print("Suma:", x + y)
print("Producto elemento a elemento:", x * y)
print("Exponencial:", torch.exp(x))
print("Raíz cuadrada:", torch.sqrt(y))
print("Seno:", torch.sin(x))
```

Estas operaciones resultan especialmente útiles para inspeccionar distribuciones de
datos o normalizar tensores antes del entrenamiento, tareas que contribuyen a
estabilizar el aprendizaje de los modelos:

```py linenums="1"
tensor = torch.randn((3, 4))  # Distribución normal
print("Tensor aleatorio:\n", tensor)
print("Media:", tensor.mean())
print("Desviación estándar:", tensor.std())
print("Valor mínimo:", tensor.min())
print("Índice del máximo:", tensor.argmax())
```

Finalmente, PyTorch permite una **conversión directa entre tensores y arreglos de
NumPy**, lo que facilita su integración con bibliotecas de análisis y visualización.
Esta interoperabilidad permite combinar el poder de cálculo de PyTorch con la
versatilidad de ecosistemas como NumPy, Matplotlib o Pandas:

```py linenums="1"
import numpy as np

# Tensor a NumPy
tensor = torch.tensor([[1, 2], [3, 4]])
array = tensor.numpy()
print("Tensor a NumPy:\n", array)

# NumPy a Tensor
nuevo_tensor = torch.from_numpy(array)
print("NumPy a Tensor:\n", nuevo_tensor)
```

En conjunto, estas operaciones proporcionan una visión integral de las capacidades de
PyTorch en la manipulación de tensores, mostrando su versatilidad, eficiencia y
facilidad de integración con otros entornos de análisis.

Los apartados siguientes retoman la perspectiva teórica para tratar la geometría que
induce el producto interno y las descomposiciones de matrices que de ella se derivan.

## Geometría analítica y ortogonalidad

Las nociones de norma y producto interno introducidas anteriormente permiten construir
bases con propiedades geométricas convenientes y proyectar vectores sobre subespacios.
Estas operaciones son la base de la ortogonalización y de la separación lineal de
conjuntos de datos.

### Matrices y bases ortonormales

Una matriz $\mathbf{A} \in \mathbb{R}^{n \times n}$ es **ortogonal** si sus columnas son
ortonormales, condición que se expresa como:

$$
\mathbf{A}\mathbf{A}^T = \mathbf{I} = \mathbf{A}^T \mathbf{A}
$$

De esta igualdad se deduce una propiedad de gran utilidad computacional:
$\mathbf{A}^{-1} = \mathbf{A}^T$, de modo que invertir una matriz ortogonal se reduce a
transponerla.

En el caso de las bases, dado un espacio vectorial $V$ de dimensión $n$ y una base
$\{\mathbf{b}_1,\dots,\mathbf{b}_n\}$ de $V$, la base es ortonormal cuando se cumplen
dos condiciones para todo $i,j = 1,\dots,n$. La primera es que
$\langle \mathbf{b}_i, \mathbf{b}_j \rangle = 0$ cuando $i \neq j$, es decir, los
vectores son ortogonales entre sí. La segunda es que
$\langle \mathbf{b}_i, \mathbf{b}_i \rangle = 1$, lo que implica que cada vector de la
base tiene norma unitaria. Si solo se satisface la primera condición la base es
simplemente ortogonal. La eliminación gaussiana permite encontrar bases de un espacio
vectorial, y el procedimiento para construir bases ortonormales se denomina proceso de
Gram-Schmidt.

### Proyecciones ortogonales

Una **proyección ortogonal** es la descomposición de un vector en la suma de dos
vectores ortogonales. Dada una recta $L = \{c\mathbf{v} \mid c \in \mathbb{R}\}$ formada
por todos los múltiplos escalares del vector $\mathbf{v}$, proyectar un vector
$\mathbf{y}$ sobre $L$ equivale a escribir $\mathbf{y}$ como un múltiplo escalar de
$\mathbf{v}$ más un componente ortogonal a dicha recta. La proyección se calcula
mediante:

$$
\widehat{\mathbf{y}} = \mathrm{proy}_L \mathbf{y} = \frac{\mathbf{y} \cdot
\mathbf{v}}{\mathbf{v} \cdot \mathbf{v}} \mathbf{v}
$$

Tomando $\mathbf{y} = \begin{pmatrix} 7 \\ 6 \end{pmatrix}$ y
$\mathbf{v} = \begin{pmatrix} 2 \\ 1 \end{pmatrix}$, el cálculo resulta:

$$
\widehat{\mathbf{y}} = \frac{7 \cdot 2 + 6 \cdot 1}{2 \cdot 2 + 1 \cdot 1}
\begin{pmatrix} 2 \\ 1 \end{pmatrix} = \frac{20}{5} \begin{pmatrix} 2 \\ 1
\end{pmatrix} = \begin{pmatrix} 8 \\ 4 \end{pmatrix}
$$

La componente de $\mathbf{y}$ ortogonal a $\mathbf{v}$ se obtiene por diferencia:

$$
\mathbf{y} - \widehat{\mathbf{y}} = \begin{pmatrix} 7 \\ 6 \end{pmatrix} -
\begin{pmatrix} 8 \\ 4 \end{pmatrix} = \begin{pmatrix} -1 \\ 2 \end{pmatrix}
$$

### Ortogonalización por Gram-Schmidt

El método de **Gram-Schmidt** resulta de utilidad cuando se dispone de una base
cualquiera de un subespacio vectorial y se desea transformarla en una base ortogonal u
ortonormal, teniendo en cuenta que normalizar consiste simplemente en dividir cada
vector entre su norma.

Partiendo de una base $B = \{\mathbf{v}_1, \mathbf{v}_2, \ldots, \mathbf{v}_n\}$ de
vectores linealmente independientes, el método conduce a una nueva base
$B' = \{\mathbf{w}_1, \mathbf{w}_2, \ldots, \mathbf{w}_n\}$ en la que todas las parejas
de vectores son perpendiculares entre sí. Cada vector se obtiene restando al vector
original sus proyecciones sobre los vectores ya calculados:

$$
\mathbf{w}_n = \mathbf{v}_n - \sum_{i=1}^{n-1} \frac{\mathbf{v}_n \cdot
\mathbf{w}_i}{\lVert \mathbf{w}_i \rVert^2} \mathbf{w}_i
$$

El resultado es una base ortogonal. Para obtener además una base ortonormal se divide
cada vector entre su norma:

$$
\left\{ \frac{\mathbf{w}_1}{\lVert \mathbf{w}_1 \rVert}, \frac{\mathbf{w}_2}{\lVert
\mathbf{w}_2 \rVert}, \ldots, \frac{\mathbf{w}_n}{\lVert \mathbf{w}_n \rVert} \right\}
$$

???+ example "Ortogonalización de una base por Gram-Schmidt"

    Se parte del subespacio vectorial definido por la ecuación
    $H \equiv x + y - z - t = 0$. Despejando $x = -y + z + t$ y tomando $y$, $z$ y $t$
    como parámetros libres, se obtiene la base
    $B = \{(-1,1,0,0), (1,0,1,0), (1,0,0,1)\}$, de modo que
    $\mathbf{v}_1 = (-1,1,0,0)$, $\mathbf{v}_2 = (1,0,1,0)$ y
    $\mathbf{v}_3 = (1,0,0,1)$.

    El primer vector se toma directamente: $\mathbf{w}_1 = (-1, 1, 0, 0)$, con
    $\lVert \mathbf{w}_1 \rVert = \sqrt{2}$.

    Para el segundo, con
    $\mathbf{v}_2 \cdot \mathbf{w}_1 = -1$:

    $$
    \mathbf{w}_2 = \mathbf{v}_2 - \frac{\mathbf{v}_2 \cdot \mathbf{w}_1}{\lVert
    \mathbf{w}_1 \rVert^2} \mathbf{w}_1 = (1,0,1,0) + \frac{1}{2}(-1,1,0,0) =
    \left( \frac{1}{2}, \frac{1}{2}, 1, 0 \right)
    $$

    Para el tercero, con $\mathbf{v}_3 \cdot \mathbf{w}_1 = -1$,
    $\mathbf{v}_3 \cdot \mathbf{w}_2 = \frac{1}{2}$ y
    $\lVert \mathbf{w}_2 \rVert^2 = \frac{3}{2}$:

    $$
    \mathbf{w}_3 = (1,0,0,1) + \frac{1}{2}(-1,1,0,0) - \frac{1/2}{3/2}
    \left(\frac{1}{2}, \frac{1}{2}, 1, 0\right) = \left(\frac{1}{3}, \frac{1}{3},
    -\frac{1}{3}, 1\right)
    $$

    La base ortogonal resultante es
    $\{(-1,1,0,0), (\tfrac{1}{2},\tfrac{1}{2},1,0),
    (\tfrac{1}{3},\tfrac{1}{3},-\tfrac{1}{3},1)\}$. Para comprobar la ortogonalidad
    basta multiplicar los vectores por parejas y verificar que el resultado es cero. Con
    las normas $\lVert \mathbf{w}_1 \rVert = \sqrt{2}$,
    $\lVert \mathbf{w}_2 \rVert = \frac{\sqrt{6}}{2}$ y
    $\lVert \mathbf{w}_3 \rVert = \frac{2\sqrt{3}}{3}$, la base ortonormal queda:

    $$
    \left\{ \left(-\frac{1}{\sqrt{2}}, \frac{1}{\sqrt{2}}, 0, 0\right),
    \left(\frac{\sqrt{6}}{6}, \frac{\sqrt{6}}{6}, \frac{\sqrt{6}}{3}, 0\right),
    \left(\frac{\sqrt{3}}{6}, \frac{\sqrt{3}}{6}, -\frac{\sqrt{3}}{6},
    \frac{\sqrt{3}}{2}\right) \right\}
    $$

Este procedimiento es el que subyace a la descomposición QR y, en el contexto de la
inteligencia artificial, se emplea para construir bases ortonormales con las que
inicializar pesos de forma estable o para eliminar la correlación entre las direcciones
de una representación.

### El hiperplano como límite de decisión

Un hiperplano es un subespacio de dimensión inmediatamente inferior a la del espacio que
lo contiene, de forma que en dos dimensiones es una recta y en tres dimensiones un
plano. Si los puntos de un espacio representan un conjunto de datos, un hiperplano
permite separarlos en regiones, lo que resulta aplicable a problemas de clasificación.
La pregunta relevante es dónde debe situarse exactamente ese hiperplano para que
constituya un buen límite de decisión.

Para determinarlo se parte de un vector de pesos $\mathbf{w} = (w_1, w_2, \ldots, w_n)$,
cuyos valores son fijos una vez entrenado el modelo, y un vector de datos $\mathbf{v}$.
La condición que se busca expresar es $\mathbf{w} \cdot \mathbf{v} > a$ para un cierto
umbral $a$. Desarrollando el producto interno en términos del ángulo:

$$
\mathbf{w} \cdot \mathbf{v} > a \Rightarrow \lVert \mathbf{w} \rVert \lVert \mathbf{v}
\rVert \cos\theta > a \Rightarrow \lVert \mathbf{v} \rVert \cos\theta >
\frac{a}{\lVert \mathbf{w} \rVert}
$$

La interpretación geométrica es directa. El término
$\lVert \mathbf{v} \rVert \cos\theta$ es la longitud de la proyección del vector de
datos sobre la dirección del vector de pesos, mientras que
$\frac{a}{\lVert \mathbf{w} \rVert}$ marca un punto fijo sobre esa misma dirección. Si
la proyección supera ese punto, se satisface la condición
$\mathbf{w} \cdot \mathbf{v} > a$ y la muestra queda a un lado del hiperplano. Este
desarrollo es el fundamento geométrico de las máquinas de vectores de soporte, tratadas
en el capítulo de modelos supervisados.

## Descomposición de matrices

Los datos se representan a menudo de forma matricial, donde las filas pueden
corresponder a distintos individuos y las columnas describir características como el
peso, la altura o el nivel de ingresos. Los métodos que se tratan a continuación
permiten describir una matriz mediante unos pocos números que caracterizan sus
propiedades generales.

### Determinante y traza

El **determinante** es un objeto matemático central en el análisis y la resolución de
sistemas de ecuaciones lineales. Está definido únicamente para matrices cuadradas
$\mathbf{A} \in \mathbb{R}^{n \times n}$ y se representa como $\det(\mathbf{A})$ o
$|\mathbf{A}|$. Se trata de una función que transforma la matriz en un número real. El
teorema fundamental asociado establece que una matriz cuadrada es invertible si, y solo
si, su determinante es distinto de cero.

Para una matriz de orden dos el cálculo es inmediato:

$$
\det(\mathbf{A}) = \begin{vmatrix} a_{11} & a_{12} \\ a_{21} & a_{22} \end{vmatrix}
= a_{11} a_{22} - a_{12} a_{21}
$$

Para dimensiones mayores el cálculo se realiza mediante el desarrollo de Laplace o, en
la práctica, a través de descomposiciones matriciales. Lo relevante en inteligencia
artificial no es el procedimiento manual sino su interpretación: un determinante nulo
indica columnas linealmente dependientes, y por tanto información redundante y una
matriz que no se puede invertir. El valor absoluto del determinante mide además cuánto
escala el volumen una transformación, idea que reaparece en los modelos generativos de
flujo normalizado, donde el determinante del Jacobiano corrige la densidad de
probabilidad al cambiar de variable.

La **traza** de una matriz cuadrada $\mathbf{A} \in \mathbb{R}^{n \times n}$ se define
como la suma de los elementos de su diagonal principal:

$$
\mathrm{tr}(\mathbf{A}) = \sum_{i=1}^{n} a_{ii}
$$

La traza es lineal, de forma que
$\mathrm{tr}(\mathbf{A}+\mathbf{B}) = \mathrm{tr}(\mathbf{A}) + \mathrm{tr}(\mathbf{B})$
y $\mathrm{tr}(\alpha \mathbf{A}) = \alpha \, \mathrm{tr}(\mathbf{A})$ para
$\alpha \in \mathbb{R}$. La traza de la matriz identidad de orden $n$ es igual a $n$.
Además es invariante frente al orden del producto, cumpliéndose
$\mathrm{tr}(\mathbf{A}\mathbf{B}) = \mathrm{tr}(\mathbf{B}\mathbf{A})$ cuando las
dimensiones lo permiten.

Para $\lambda \in \mathbb{R}$ y una matriz cuadrada
$\mathbf{A} \in \mathbb{R}^{n \times n}$, la expresión:

$$
p_{\mathbf{A}}(\lambda) = \det(\mathbf{A} - \lambda \mathbf{I})
$$

es el **polinomio característico**, cuyas raíces son los autovalores de la matriz.

### Autovalores y autovectores

El análisis de autovalores y autovectores permite interpretar el efecto de una
transformación lineal. Los autovalores indican cómo de particular resulta un conjunto de
vectores, los autovectores, cuando se les aplica la transformación.

Siendo $\mathbf{A} \in \mathbb{R}^{n \times n}$ una matriz cuadrada, el escalar
$\lambda \in \mathbb{R}$ es un **autovalor** de $\mathbf{A}$ y el vector
$\mathbf{x} \in \mathbb{R}^n \setminus \{\mathbf{0}\}$ su **autovector** asociado si se
cumple:

$$
\mathbf{A}\mathbf{x} = \lambda \mathbf{x}
$$

Por convención los autovalores se ordenan de forma descendente. La condición anterior
admite tres formulaciones equivalentes: que $\lambda$ sea autovalor de $\mathbf{A}$, que
$\mathrm{rk}(\mathbf{A} - \lambda \mathbf{I}_n) < n$, o que
$\det(\mathbf{A} - \lambda \mathbf{I}_n) = 0$.

Dos vectores que apuntan en la misma dirección se denominan codirigidos, y son
colineales cuando apuntan en la misma dirección o en la contraria. Si $\mathbf{x}$ es un
autovector de $\mathbf{A}$ asociado al autovalor $\lambda$, entonces para cualquier
$c \in \mathbb{R} \setminus \{0\}$ el vector $c\mathbf{x}$ también es autovector con el
mismo autovalor, ya que:

$$
\mathbf{A}(c\mathbf{x}) = c\mathbf{A}\mathbf{x} = c\lambda \mathbf{x} = \lambda
(c\mathbf{x})
$$

Todos los vectores colineales a $\mathbf{x}$ son por tanto autovectores de $\mathbf{A}$.
La **multiplicidad algebraica** de un autovalor $\lambda$ es el número de veces que
aparece como raíz del polinomio característico.

Para una matriz $\mathbf{A} \in \mathbb{R}^{n \times n}$, el conjunto de autovectores
asociados a un autovalor $\lambda$ genera un subespacio de $\mathbb{R}^n$ denominado
**espacio propio** de $\mathbf{A}$ respecto de $\lambda$ y denotado $E_\lambda$. El
conjunto de todos los autovalores de $\mathbf{A}$ se denomina espectro. El espacio
propio $E_\lambda$ coincide con el espacio de soluciones del sistema homogéneo
$(\mathbf{A} - \lambda \mathbf{I})\mathbf{x} = \mathbf{0}$.

Varias propiedades resultan de interés práctico. Una matriz $\mathbf{A}$ y su
transpuesta $\mathbf{A}^T$ comparten los mismos autovalores, aunque no necesariamente
los mismos autovectores. El espacio propio $E_\lambda$ es el núcleo de
$\mathbf{A} - \lambda \mathbf{I}$, puesto que:

$$
\mathbf{A}\mathbf{x} = \lambda \mathbf{x} \iff (\mathbf{A} - \lambda
\mathbf{I})\mathbf{x} = \mathbf{0} \iff \mathbf{x} \in \mathrm{Ker}(\mathbf{A} - \lambda
\mathbf{I})
$$

Finalmente, una matriz simétrica y definida positiva siempre tiene autovalores reales.

???+ example "Diagonalización de una matriz simétrica"

    Este desarrollo paso a paso es el cálculo que subyace al análisis de componentes
    principales. Aplicado a una matriz de covarianza, los autovectores son las
    componentes principales y los autovalores indican cuánta varianza explica cada una.

    Se parte de la matriz
    $\mathbf{A} = \begin{pmatrix} 3 & 1 & 1 \\ 1 & 3 & 1 \\ 1 & 1 & 3 \end{pmatrix}$ y
    se calcula su polinomio característico:

    $$
    \begin{vmatrix} 3-\lambda & 1 & 1 \\ 1 & 3-\lambda & 1 \\ 1 & 1 & 3-\lambda
    \end{vmatrix} = -\lambda^3 + 9\lambda^2 - 24\lambda + 20
    $$

    Las raíces del polinomio son $\lambda_1 = 5$, con multiplicidad algebraica 1, y
    $\lambda_2 = 2$, con multiplicidad algebraica 2.

    Para $\lambda = 2$ se resuelve
    $(\mathbf{A} - 2\mathbf{I})\mathbf{x} = \mathbf{0}$. La matriz
    $\mathbf{A} - 2\mathbf{I}$ se reduce por filas a una matriz de rango 1, lo que deja
    dos parámetros libres. De la ecuación $x + y + z = 0$ se obtienen los generadores
    $(-1,1,0)$ y $(-1,0,1)$, de modo que la multiplicidad geométrica es 2 y coincide con
    la algebraica.

    Para $\lambda = 5$ se resuelve
    $(\mathbf{A} - 5\mathbf{I})\mathbf{x} = \mathbf{0}$. La reducción por filas conduce
    a una matriz de rango 2, con un único parámetro libre. Las ecuaciones resultantes
    $x = z$ e $y = z$ dan el generador $(1,1,1)$, por lo que la multiplicidad geométrica
    es 1 y también coincide con la algebraica.

    Con los autovalores en la diagonal y los autovectores en columnas se construyen la
    matriz diagonal $\mathbf{D}$ y la matriz de paso $\mathbf{P}$:

    $$
    \mathbf{D} = \begin{pmatrix}2&0&0\\0&2&0\\0&0&5\end{pmatrix} \qquad
    \mathbf{P} = \begin{pmatrix}-1&-1&1\\1&0&1\\0&1&1\end{pmatrix}
    $$

    La comprobación verifica que
    $\mathbf{A} = \mathbf{P}\mathbf{D}\mathbf{P}^{-1}$:

    $$
    \begin{pmatrix}3&1&1\\1&3&1\\1&1&3\end{pmatrix}=
    \begin{pmatrix}-1&-1&1\\1&0&1\\0&1&1\end{pmatrix}
    \begin{pmatrix}2&0&0\\0&2&0\\0&0&5\end{pmatrix}
    \begin{pmatrix}-1/3&2/3&-1/3\\-1/3&-1/3&2/3\\1/3&1/3&1/3\end{pmatrix}
    $$

    Puesto que la igualdad se cumple, la matriz $\mathbf{A}$ es diagonalizable.

### Relación con el determinante, la traza y el algoritmo PageRank

Dada una matriz $\mathbf{A} \in \mathbb{R}^{n \times n}$, siempre es posible obtener una
matriz simétrica y semidefinida positiva $\mathbf{S} \in \mathbb{R}^{n \times n}$
definiendo $\mathbf{S} = \mathbf{A}^T \mathbf{A}$.

El ejemplo anterior ilustra dos relaciones fundamentales entre los autovalores y las
magnitudes definidas previamente. El determinante de una matriz es el producto de sus
autovalores:

$$
\det(\mathbf{A}) = \prod_{i=1}^{n} \lambda_i
$$

Y la traza es la suma de sus autovalores:

$$
\mathrm{tr}(\mathbf{A}) = \sum_{i=1}^{n} \lambda_i
$$

Un ejemplo destacado de aplicación de estos conceptos es el algoritmo **PageRank**,
empleado por Google para determinar la relevancia de una página en los resultados de
búsqueda a partir del autovector correspondiente al autovalor máximo de una matriz. La
idea de partida es que la importancia de una página web puede aproximarse por la
importancia de las páginas que enlazan con ella. El algoritmo calcula el peso $x_i > 0$
de una página $a_i$ contando el número de páginas que apuntan a ella, ponderadas por la
importancia de esas mismas páginas. El comportamiento de navegación de un usuario se
modela mediante una matriz de transición $\mathbf{A}$ que recoge la probabilidad de
terminar en una página distinta. Esta matriz tiene la propiedad de que, para cualquier
vector de importancia inicial $\mathbf{x}$, la secuencia
$\mathbf{x}, \mathbf{A}\mathbf{x}, \mathbf{A}^2\mathbf{x}, \ldots$ converge a un vector
$\mathbf{x}^*$. Ese vector es el PageRank y satisface
$\mathbf{A}\mathbf{x}^* = \mathbf{x}^*$, de modo que es un autovector asociado al
autovalor 1. Tras normalizarlo para que $\|\mathbf{x}^*\| = 1$, sus entradas se
interpretan como probabilidades.

### Descomposición de Cholesky

Para que una matriz $\mathbf{A}$ sea factorizable mediante **Cholesky** ha de ser
simétrica, es decir cuadrada e igual a su transpuesta, y definida positiva, lo que exige
que el determinante de cada submatriz principal sea positivo. La descomposición expresa
la matriz como el producto de una matriz triangular inferior por su transpuesta:

$$
\mathbf{A} = \mathbf{M}\mathbf{M}^T =
\begin{pmatrix}m_{11}&0&0\\m_{21}&m_{22}&0\\m_{31}&m_{32}&m_{33}\end{pmatrix}
\begin{pmatrix}m_{11}&m_{21}&m_{31}\\0&m_{22}&m_{32}\\0&0&m_{33}\end{pmatrix}
$$

Como las matrices de covarianza cumplen ambas condiciones, esta descomposición es la
herramienta estándar para generar muestras de una distribución normal multivariante: se
parte de ruido gaussiano independiente y se multiplica por $\mathbf{M}$ para imponer la
covarianza deseada. Es el mecanismo que se emplea en procesos gaussianos y en el truco
de reparametrización de los _autoencoders_ variacionales. Resulta además más rápida y
numéricamente más estable que calcular una inversa, por lo que se utiliza al evaluar
verosimilitudes gaussianas.

Un resultado estrechamente relacionado establece que una matriz simétrica
$\mathbf{S} \in \mathbb{R}^{n \times n}$ siempre puede diagonalizarse con una matriz de
paso $\mathbf{P}$ ortogonal, de modo que
$\mathbf{D} = \mathbf{P}^T \mathbf{S} \mathbf{P}$. Esta propiedad es la que garantiza
que el análisis de componentes principales siempre pueda calcularse sobre una matriz de
covarianza.

### Descomposición en valores singulares

La **descomposición en valores singulares** (_Singular Value Decomposition_, SVD) se
emplea para reducir la dimensión de los datos, identificando las características clave
necesarias para analizarlos, comprenderlos y describirlos. Puede entenderse como la
generalización basada en datos de la transformación de Fourier, una de las
transformaciones más útiles para aproximar funciones mediante expansiones en senos y
cosenos.

También sirve para resolver sistemas de ecuaciones $\mathbf{A}\mathbf{x} = \mathbf{b}$
cuando la matriz $\mathbf{A}$ no es cuadrada, lo que resulta particularmente relevante
en los modelos de regresión lineal. Con datos de salud de un gran número de pacientes y
el objetivo de modelar cómo los distintos factores de riesgo se relacionan con una
enfermedad, el modelo de mejor ajuste se construye mediante una regresión lineal de
mínimos cuadrados apoyada en la SVD.

La descomposición de una matriz $\mathbf{A} \in \mathbb{R}^{m \times n}$ toma la forma:

$$
\mathbf{A} = \mathbf{U} \mathbf{\Sigma} \mathbf{V}^T
$$

donde $\mathbf{U} \in \mathbb{R}^{m \times m}$ y
$\mathbf{V} \in \mathbb{R}^{n \times n}$ son matrices ortogonales y
$\mathbf{\Sigma} \in \mathbb{R}^{m \times n}$ es una matriz diagonal cuyas entradas, los
valores singulares, no son negativas. Para obtener estas matrices se parte de las dos
relaciones siguientes:

$$
\mathbf{A}^T \mathbf{A} = \mathbf{V} \mathbf{\Sigma}^T \mathbf{\Sigma} \mathbf{V}^T
$$

$$
\mathbf{A}\mathbf{V} = \mathbf{U}\mathbf{\Sigma}
$$

???+ example "Cálculo de la SVD de una matriz de orden dos"

    Se parte de la matriz
    $\mathbf{C} = \begin{pmatrix}5&5\\-1&7\end{pmatrix}$ y se calcula el producto
    $\mathbf{C}^T \mathbf{C}$:

    $$
    \mathbf{C}^T \mathbf{C} = \begin{pmatrix}5&-1\\5&7\end{pmatrix}
    \begin{pmatrix}5&5\\-1&7\end{pmatrix} = \begin{pmatrix}26&18\\18&74\end{pmatrix}
    $$

    El polinomio característico
    $\det(\mathbf{C}^T\mathbf{C}-\lambda \mathbf{I}) = \lambda^2-100\lambda+1600$
    proporciona los autovalores $\lambda_1 = 80$ y $\lambda_2 = 20$.

    Para $\lambda_2 = 20$, la matriz
    $\mathbf{C}^T\mathbf{C}-20\mathbf{I} = \begin{pmatrix}6&18\\18&54\end{pmatrix}$ se
    reduce por filas a $\begin{pmatrix}1&3\\0&0\end{pmatrix}$, con rango 1. De
    $x + 3y = 0$ se obtiene el generador $(-3, 1)$, cuya norma es $\sqrt{10}$, lo que da
    el autovector normalizado $(-3/\sqrt{10},\ 1/\sqrt{10})$.

    Para $\lambda_1 = 80$, un desarrollo análogo sobre
    $\mathbf{C}^T\mathbf{C}-80\mathbf{I} = \begin{pmatrix}-54&18\\18&-6\end{pmatrix}$
    conduce al autovector normalizado $(1/\sqrt{10},\ 3/\sqrt{10})$.

    Con estos autovectores en columnas se construye $\mathbf{V}$, y con las raíces
    cuadradas de los autovalores la matriz $\mathbf{\Sigma}$:

    $$
    \mathbf{V} = \begin{pmatrix}-3/\sqrt{10}&1/\sqrt{10}\\1/\sqrt{10}&3/\sqrt{10}
    \end{pmatrix} \qquad \mathbf{\Sigma} = \begin{pmatrix}2\sqrt{5}&0\\0&4\sqrt{5}
    \end{pmatrix}
    $$

    La matriz $\mathbf{U}$ se despeja de
    $\mathbf{C}\mathbf{V} = \mathbf{U}\mathbf{\Sigma}$, de donde
    $\mathbf{U} = \mathbf{C}\mathbf{V}\mathbf{\Sigma}^{-1}$:

    $$
    \begin{pmatrix}-\sqrt{10}&2\sqrt{10}\\\sqrt{10}&2\sqrt{10}\end{pmatrix}
    \begin{pmatrix}1/(2\sqrt{5})&0\\0&1/(4\sqrt{5})\end{pmatrix} =
    \begin{pmatrix}-1/\sqrt{2}&1/\sqrt{2}\\1/\sqrt{2}&1/\sqrt{2}\end{pmatrix} =
    \mathbf{U}
    $$

    El producto $\mathbf{U}\mathbf{\Sigma}\mathbf{V}^T$ reproduce la matriz original, lo
    que confirma la validez de la descomposición.

### Aproximación de rango bajo y teorema de Eckart-Young-Mirsky

En lugar de calcular la SVD completa, la descomposición puede expresarse como una suma
de matrices de rango uno, lo que reduce el coste computacional. La matriz de rango uno
$\mathbf{A}_i \in \mathbb{R}^{m \times n}$ se construye como:

$$
\mathbf{A}_i = \mathbf{u}_i \mathbf{v}_i^T
$$

donde $\mathbf{u}_i$ y $\mathbf{v}_i$ son las columnas $i$-ésimas de $\mathbf{U}$ y
$\mathbf{V}$ respectivamente. Una matriz $\mathbf{A} \in \mathbb{R}^{m \times n}$ de
rango $r$ se escribe entonces como la suma ponderada de estas matrices:

$$
\mathbf{A} = \sum_{i=1}^{r}\sigma_i \mathbf{u}_i \mathbf{v}_i^T = \sum_{i=1}^{r}\sigma_i
\mathbf{A}_i
$$

La aproximación que conserva únicamente los $k$ primeros términos se denota
$\widehat{\mathbf{A}}(k)$. Para medir la calidad de estas aproximaciones se emplea la
**norma espectral**, definida para
$\mathbf{x} \in \mathbb{R}^n \setminus \{\mathbf{0}\}$ como:

$$
\|\mathbf{A}\|_2 = \max \frac{\|\mathbf{A}\mathbf{x}\|_2}{\|\mathbf{x}\|_2}
$$

La norma espectral de $\mathbf{A}$ coincide con su mayor valor singular $\sigma_1$.

El **teorema de Eckart-Young-Mirsky** establece el resultado central sobre estas
aproximaciones. Considerando una matriz $\mathbf{A} \in \mathbb{R}^{m \times n}$ de
rango $r$ y cualquier matriz $\mathbf{B} \in \mathbb{R}^{m \times n}$ de rango
$k \le r$, la aproximación truncada $\widehat{\mathbf{A}}(k)$ es la mejor posible:

$$
\widehat{\mathbf{A}}(k) = \operatorname{arg\,min}_{\mathrm{rk}(\mathbf{B})=k}
\|\mathbf{A}-\mathbf{B}\|_2
$$

Y el error cometido es exactamente el siguiente valor singular descartado:

$$
\|\mathbf{A}-\widehat{\mathbf{A}}(k)\|_2 = \sigma_{k+1}
$$

El operador $\operatorname{arg\,min}$ devuelve los puntos del dominio de una función
donde esta alcanza su valor mínimo.

Este resultado es la justificación teórica de la compresión por rango bajo. Establece
que quedarse con los $k$ valores singulares mayores no es una heurística razonable sino
la mejor aproximación posible de rango $k$, y cuantifica exactamente el error cometido.
De aquí derivan la compresión de imágenes, la reducción de dimensionalidad mediante
análisis de componentes principales truncado y las técnicas de adaptación de modelos de
gran tamaño como LoRA, donde una actualización de pesos se representa con dos matrices
estrechas en lugar de una matriz completa.

El siguiente capítulo aborda el cálculo vectorial, que completa el aparato matemático
necesario para comprender cómo se entrenan los modelos a partir de estas estructuras.
Puede consultarse en [cálculo vectorial](section_3_vector_calculus.md).
