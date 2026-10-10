---
authors: Daniel Bazo Correa
description: Fundamentos de las Redes Neuronales de Grafos.
title: Redes Neuronales de Grafos
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Este capítulo introduce las redes neuronales de grafos, su representación matemática,
las propiedades estructurales y los métodos de predicción sobre datos relacionales.

## Grafos y sus aplicaciones

En numerosos dominios del mundo real, como las redes sociales, la economía o los
sistemas de comunicaciones, los datos no se organizan de forma tabular, sino que adoptan
de manera natural una estructura relacional. Este tipo de datos se describe de forma más
adecuada mediante grafos, ya que permiten representar explícitamente las relaciones
entre entidades. El uso de grafos proporciona una representación más rica y expresiva,
capaz de capturar dependencias complejas entre los elementos de un sistema y de reflejar
interacciones que difícilmente pueden modelarse mediante estructuras vectoriales
tradicionales.

Desde un punto de vista conceptual, pueden distinguirse dos grandes categorías. Por un
lado, los grafos naturales, que surgen de manera intrínseca en el dominio de estudio,
como una red social, una red biológica o una red de transporte. Por otro lado, las
representaciones basadas en grafos, en las que estructuras originalmente no relacionales
se reinterpretan como grafos para facilitar su análisis computacional. En ambos casos,
el aprendizaje automático sobre grafos presenta desafíos adicionales frente a otros
tipos de datos, debido a su tamaño arbitrario, su compleja topología, la ausencia de un
orden fijo en los nodos, la posible dinámica temporal y la coexistencia de múltiples
tipos de información o modalidades.

## Arquitectura

El aprendizaje automático sobre grafos puede entenderse como un proceso en el que un
grafo se introduce como entrada a un modelo, típicamente una Red Neuronal de Grafos
(Graph Neural Network, GNN), con el objetivo de generar una predicción. Dependiendo del
problema planteado, dicha predicción puede consistir en la asignación de etiquetas a
nodos individuales, la inferencia de enlaces inexistentes, o la clasificación,
comparación o generación de grafos completos o subgrafos.

Un elemento central en este proceso es la representación de los nodos. Dado un nodo $u$,
se define una función que lo proyecta a un espacio vectorial de dimensión finita,

$$
f: u \rightarrow \mathbb{R}^d,
$$

donde el vector resultante constituye una representación densa que captura tanto
información estructural del grafo como, cuando está disponible, atributos propios del
nodo. Estas representaciones, también denominadas _embeddings_, son la base sobre la que
operan los modelos de aprendizaje y permiten aplicar técnicas de Deep Learning a datos
relacionales.

## Tipos de tareas en grafos

Las tareas de aprendizaje sobre grafos pueden organizarse según el nivel de granularidad
al que se aplica la predicción. Existen tareas a nivel de nodo, cuyo objetivo es
predecir propiedades individuales, como ocurre en la clasificación de nodos o la
estimación de su relevancia. También se consideran tareas a nivel de enlace, orientadas
a predecir relaciones faltantes, un problema habitual en la finalización de grafos de
conocimiento o en sistemas de recomendación. A un nivel intermedio se sitúan las tareas
sobre subgrafos, mientras que, finalmente, las tareas a nivel de grafo completo buscan
asignar categorías globales, comparar grafos entre sí o analizar su evolución y
generación, como sucede en simulaciones de sistemas complejos.

## Componentes y definición de un grafo

Un grafo se compone de un conjunto de nodos o vértices, denotado por $N$, y un conjunto
de enlaces o aristas, denotado por $E$. El sistema completo se representa como
$G(N, E)$. Para definir un grafo es necesario especificar ambos conjuntos, aunque en
algunos casos la representación es única y en otros pueden existir múltiples
alternativas igualmente válidas. En la práctica, la forma en que se asignan los enlaces
resulta especialmente relevante, ya que determina la estructura relacional del sistema y
condiciona los patrones que pueden ser aprendidos.

Los grafos pueden clasificarse según la naturaleza de sus enlaces. En los grafos no
dirigidos, los enlaces no tienen orientación y existe simetría entre los nodos
conectados. En los grafos dirigidos, en cambio, cada enlace tiene una dirección
definida, lo que introduce una asimetría en las relaciones y permite modelar flujos,
jerarquías o dependencias causales.

## Propiedades de los nodos

En grafos no dirigidos, el grado de un nodo $i$, denotado como $K_i$, corresponde al
número de enlaces adyacentes a dicho nodo. El grado medio del grafo se obtiene como

$$
\langle K \rangle = \frac{1}{N} \sum_{i=1}^{N} K_i = \frac{2E}{N},
$$

donde cada enlace contribuye dos veces al cómputo total del grado. Esta magnitud ofrece
una primera aproximación a la densidad de conexiones del grafo.

En grafos dirigidos, el concepto de grado se descompone en grado de entrada
(_in-degree_), que cuenta los enlaces que llegan al nodo, y grado de salida
(_out-degree_), que cuenta los enlaces que parten de él. El grado total resulta de la
suma de ambos, y su valor promedio se relaciona directamente con el número de enlaces
existentes en el grafo.

Un caso particular lo constituyen los grafos bipartitos, en los que los nodos pueden
dividirse en dos conjuntos disjuntos de tal forma que cada enlace conecta un nodo de un
conjunto con uno del otro, sin enlaces internos dentro de un mismo conjunto. Este tipo
de grafos es frecuente en problemas de recomendación y análisis de relaciones
usuario–objeto.

## Representación matricial de los grafos

Una de las representaciones más habituales de un grafo es la matriz de adyacencia
$A \in \mathbb{R}^{N \times N}$, definida como

$$
A_{ij} = 1 \quad \text{si existe un enlace entre los nodos } i \text{ y } j,
$$

y $A_{ij} = 0$ en caso contrario. En grafos no dirigidos, la matriz es simétrica,
mientras que en grafos dirigidos generalmente no lo es, reflejando la direccionalidad de
las relaciones.

Las matrices de adyacencia suelen ser muy dispersas, ya que la mayoría de las posibles
conexiones no existen. Por esta razón, en grafos grandes resulta más eficiente emplear
representaciones basadas en listas de adyacencia, que almacenan únicamente los enlaces
presentes y reducen el coste computacional.

Además, los grafos pueden incorporar atributos en nodos o enlaces, como pesos, rangos o
tipos. En grafos ponderados, la matriz de adyacencia se generaliza a una matriz de pesos
$W$, donde cada entrada refleja la intensidad o relevancia de la relación. También
pueden existir bucles propios o _self-loops_, representados en la diagonal principal,
así como multigrafos, en los que múltiples enlaces entre dos nodos codifican distintas
propiedades.

## Conectividad y componentes

La conectividad describe la posibilidad de desplazarse entre nodos siguiendo los enlaces
del grafo. Un grafo completamente conectado permite alcanzar cualquier nodo desde
cualquier otro, mientras que la presencia de nodos aislados da lugar a subgrafos
independientes o componentes conexas. En grafos dirigidos, la conectividad puede ser más
sutil, ya que la dirección de los enlaces puede impedir alcanzar ciertos nodos, dando
lugar a componentes fuertemente conectadas, en las que existe un camino dirigido entre
cualquier par de nodos del componente.

## Características estructurales y medidas de centralidad

En el aprendizaje sobre grafos se distinguen las características estructurales, que
describen la posición de un nodo dentro del grafo, y las características atributivas,
que reflejan propiedades propias del nodo o del enlace. Entre las características
estructurales más relevantes se encuentran el grado y diversas medidas de centralidad,
que cuantifican diferentes nociones de importancia de un nodo.

La centralidad de vector propio asigna mayor importancia a los nodos que están
conectados con otros nodos importantes. Formalmente, la centralidad $C$ satisface la
relación

$$
\lambda C = A C,
$$

donde $A$ es la matriz de adyacencia y $\lambda > 0$ es una constante de normalización.
Esta definición implica que la importancia de un nodo depende recursivamente de la
importancia de sus vecinos.

La centralidad de intermediación (_betweenness centrality_) mide la relevancia de un
nodo en función del número de caminos más cortos entre pares de nodos que pasan por él,
reflejando su papel como intermediario en la red. Por su parte, la centralidad de
cercanía (_closeness centrality_) evalúa cuán próximo se encuentra un nodo al resto,
considerando la suma de las distancias mínimas hacia los demás nodos del grafo.

Otra medida fundamental es el coeficiente de _clustering_, que cuantifica hasta qué
punto los vecinos de un nodo están conectados entre sí. Valores próximos a uno indican
una alta densidad de triángulos locales, mientras que valores cercanos a cero reflejan
una estructura más dispersa.

## Graphlets y patrones locales

Los _graphlets_ son pequeños subgrafos inducidos que permiten capturar patrones locales
de conectividad. Un caso particular es la _ego-network_, que se construye alrededor de
un nodo central, denominado _ego_, junto con sus vecinos directos o _alters_. Este tipo
de estructuras resulta especialmente útil para analizar la influencia local de un nodo
en redes sociales o para estudiar comportamientos específicos dentro de comunidades.

El estudio de graphlets no isomorfos, es decir, subgrafos con estructuras distintas,
permite identificar y comparar patrones locales característicos de un grafo. A partir de
ellos se definen propiedades como el grado, el coeficiente de _clustering_ y el vector
de grado de graphlets (_Graphlet Degree Vector_), que cuenta cuántos graphlets de cada
tipo están asociados a un nodo. Estas herramientas proporcionan una descripción
detallada de la estructura local y resultan de gran valor en el análisis y aprendizaje
automático sobre grafos.

## Predicción de enlaces y métodos basados en similitud

En la tarea de predicción de enlaces, el objetivo es inferir relaciones inexistentes a
partir de la estructura observada del grafo. Un enfoque habitual consiste en considerar
todos los pares de nodos no conectados y asignarles una puntuación que refleje la
probabilidad de que exista un enlace entre ellos. Esta puntuación se calcula a partir de
características construidas para cada pareja de nodos, aunque la simple concatenación de
características individuales puede provocar pérdida de información estructural.

Entre las métricas locales más utilizadas se encuentra el número de vecinos comunes
entre dos nodos, que captura el solapamiento de sus entornos inmediatos. Para introducir
una normalización se emplea el coeficiente de Jaccard, definido como la razón entre la
intersección y la unión de los conjuntos de vecinos. Otra métrica relevante es el índice
de Adamic–Adar, que pondera los vecinos comunes de forma inversamente proporcional a su
grado, penalizando nodos muy conectados.

A nivel global, cuando las distancias entre nodos superan los dos saltos, se utilizan
métricas que consideran el grafo completo, como el _global neighborhood overlap_, el
índice Katz o potencias de la matriz de adyacencia, que capturan la conectividad a mayor
escala.

## Métodos kernel para grafos

Los métodos basados en _kernels_ consisten en definir funciones de similitud entre
grafos en lugar de construir explícitamente características. Un _kernel_ entre dos
grafos $G$ y $G'$ mide su similitud mediante una función $K(G, G')$ que es simétrica y
semidefinida positiva, lo que garantiza la existencia de una representación implícita en
un espacio de características.

Entre los kernels más utilizados se encuentran los _graphlet kernels_, que representan
cada grafo como un vector de frecuencias de subgrafos pequeños, y el kernel de
Weisfeiler–Lehman, que se basa en un proceso iterativo de relabeling. En este último,
cada nodo recibe inicialmente una etiqueta según sus características
