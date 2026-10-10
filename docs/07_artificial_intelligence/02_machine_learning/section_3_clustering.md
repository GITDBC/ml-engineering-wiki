---
authors: Daniel Bazo Correa
description: Algoritmos de agrupación y clustering.
title: Algoritmos de agrupación
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

La función principal de la agrupación o _clustering_ consiste en reducir la distancia
entre los puntos de un grupo y maximizar la distancia entre los distintos grupos, es
decir, que los puntos de datos que pertenezcan a un mismo grupo se encuentren lo más
cerca posible entre sí pero alejados de los puntos de datos del resto de grupos. **Este
problema se vuelve más complejo conforme aumenta la dimensionalidad del espacio**, ya
que puntos de datos que parecían alejados pueden pasar a estar más cerca en dimensiones
superiores.

Por ello, **es muy común el uso de técnicas para la reducción de la dimensionalidad en
datos de alta dimensionalidad**, ya que al añadir más características a la entrada del
algoritmo de _clustering_, los datos se vuelven dispersos y el análisis sufre de la
denominada **maldición de la dimensionalidad** (**_curse of dimensionality_**). Algunas
de las técnicas de reducción de dimensionalidad más utilizadas son el análisis de
componentes principales (**_Principal Component Analysis_**, **PCA**) y los
**_Autoencoders_**. El PCA garantiza la búsqueda de la mejor transformación lineal que
reduzca el número de dimensiones con una pérdida mínima de información (en ocasiones, la
información que se pierde se considera ruido irrelevante), mientras que los
_Autoencoders_ comprimen la información recibida a la entrada para adquirir una
representación compacta en su espacio latente.

Los algoritmos de _clustering_ se utilizan en problemas **no supervisados**, es decir,
problemas donde no se dispone de etiquetas y el objetivo es obtener agrupaciones de
datos con similitudes. A continuación, se presentan los principales tipos de algoritmos
de agrupación.

## Métodos basados en particiones

### K-Means

**K-Means** es uno de los algoritmos de _clustering_ no supervisado más utilizados. Su
principal función es dividir el conjunto de datos en $k$ grupos predefinidos, donde cada
dato pertenece a un único grupo. El algoritmo opera de la siguiente manera:

En primer lugar, se eligen de manera aleatoria $k$ puntos del conjunto de datos, que se
interpretan como los centros iniciales (centroides) de los grupos. A continuación, se
calcula la distancia de cada punto del conjunto de datos a cada centroide, generalmente
utilizando la **distancia euclídea**. Cada punto se asigna al centroide más cercano,
formando así los grupos iniciales. Posteriormente, se recalcula la posición de cada
centroide como la media de todos los puntos asignados a su grupo. Este proceso de
asignación y actualización se repite iterativamente hasta que los centroides convergen
(dejan de cambiar significativamente) o se alcanza un número máximo de iteraciones.

Formalmente, el centro del cluster $k$ se representa con la letra $\mu_k$. Para cada
punto $x_i$ del conjunto de datos, se calcula la distancia euclídea a cada centroide y
se asigna al cluster cuyo centroide sea el más cercano. La **función de coste** del
algoritmo se define como la suma promedio de las distancias euclídeas entre todas las
muestras y sus respectivos centroides:

$$
J = \frac{1}{M} \sum_{i=1}^{M} \| x_i - \mu_{c_i} \|^2,
$$

donde $M$ es el número total de muestras y $c_i$ es el índice del cluster asignado al
punto $x_i$. En cada iteración, la función de coste debería reducirse, lo que permite
comparar el valor actual con el anterior para verificar si el modelo converge.

Para evitar que el algoritmo quede atrapado en mínimos locales, es habitual ejecutar
K-Means múltiples veces con diferentes inicializaciones aleatorias y seleccionar la
ejecución con menor función de coste. El número de clusters $k$ debe ser menor que el
número total de muestras $M$ y su elección es un aspecto crítico del algoritmo.

```python linenums="1"
import numpy as np
from sklearn.datasets import make_blobs
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt

# Generación de datos sintéticos con distribución gaussiana isotrópica
# Una desviación típica baja indica datos más agrupados cerca de su media,
# mientras que una alta indica mayor dispersión
x, y = make_blobs(
    n_samples=200,
    n_features=2,
    centers=3,
    cluster_std=0.5,
    random_state=0
)

# Visualización inicial de los datos en 2D
plt.scatter(x[:, 0], x[:, 1], c='white', edgecolors='black')
plt.title('Datos sin agrupar')
plt.show()

# Configuración y entrenamiento del modelo K-Means
kmeans = KMeans(
    n_clusters=3,
    init='random',
    n_init=1,
    max_iter=10,
    tol=1e-04,
    random_state=2
)

y_km = kmeans.fit_predict(x)

# Visualización de los clusters resultantes
colores = ['lightgreen', 'orange', 'lightblue']
marcas = ['s', 'o', 'v']

for i in range(3):
    plt.scatter(
        x[y_km == i, 0], x[y_km == i, 1],
        s=50, c=colores[i],
        marker=marcas[i], edgecolor='black',
        label=f"Cluster {i}"
    )

# Visualización de los centroides
plt.scatter(
    kmeans.cluster_centers_[:, 0], kmeans.cluster_centers_[:, 1],
    s=250, marker='*',
    c='red', edgecolor='black',
    label='Centroides'
)

plt.legend(scatterpoints=1)
plt.title('Resultado de K-Means')
plt.show()
```

### K-Medoids

**K-Medoids** es una variante de K-Means que, en lugar de utilizar la media de los
puntos como centroide, selecciona un punto real del conjunto de datos como representante
de cada cluster (denominado **medoide**). Esta característica lo hace más robusto frente
a valores atípicos, ya que el medoide siempre es un punto existente en los datos.

```python linenums="1"
import numpy as np
import matplotlib.pyplot as plt
from sklearn_extra.cluster import KMedoids
from sklearn.metrics import silhouette_score, calinski_harabasz_score
from sklearn import preprocessing

# Configuración del modelo K-Medoids
algoritmo = KMedoids(
    n_clusters=3,
    metric='euclidean',
    method='alternate',  # Cambiar por 'pam' para mayor precisión (más lento)
    init='k-medoids++',
    max_iter=300,
    random_state=0
)

# algoritmo.fit(x)  # Ajustar con el conjunto de datos correspondiente
```

## Métodos basados en jerarquías

El **clustering jerárquico aglomerativo** (_Agglomerative Hierarchical Clustering_, AHC)
es un método que construye una jerarquía de clusters de forma ascendente. Inicialmente,
cada punto de datos se considera un cluster individual. En cada paso, los dos clusters
más cercanos se fusionan, y este proceso se repite hasta que todos los puntos pertenecen
a un único cluster o se alcanza el número deseado de agrupaciones. La distancia entre
clusters se puede medir mediante diferentes criterios de enlace (_linkage_), como el
enlace simple, completo, promedio o el método de Ward.

```python linenums="1"
import numpy as np
import matplotlib.pyplot as plt
from sklearn.cluster import AgglomerativeClustering
from sklearn.metrics import silhouette_score, calinski_harabasz_score
from sklearn import preprocessing

# Configuración del modelo de clustering jerárquico aglomerativo
algoritmo = AgglomerativeClustering(
    n_clusters=3,
    metric='euclidean',
    linkage='ward'
)

# algoritmo.fit(x)  # Ajustar con el conjunto de datos correspondiente
```

## Métodos basados en densidad

**DBSCAN** (_Density-Based Spatial Clustering of Applications with Noise_) es un
algoritmo de clustering que agrupa puntos que se encuentran en regiones de alta
densidad, separándolos de las regiones de baja densidad. A diferencia de K-Means, DBSCAN
no requiere especificar el número de clusters de antemano y es capaz de detectar
clusters de formas arbitrarias, así como identificar puntos de ruido (_outliers_) que no
pertenecen a ningún cluster.

## Métodos basados en modelos

Los **Modelos de Mezcla Gaussiana** (_Gaussian Mixture Models_, GMM) asumen que los
datos provienen de una mezcla de varias distribuciones gaussianas, cada una con sus
propios parámetros de media y covarianza. A diferencia de K-Means, que realiza
asignaciones duras (cada punto pertenece a un único cluster), los GMM proporcionan
asignaciones probabilísticas, indicando la probabilidad de que cada punto pertenezca a
cada cluster. El entrenamiento se realiza mediante el algoritmo
**Expectation-Maximization (EM)**.

## Métodos basados en grafos

El **clustering espectral** (_Spectral Clustering_) permite agrupar conjuntos de datos
mucho más complejos que no son linealmente separables, como ocurre en el caso de
K-Means. La idea fundamental de este algoritmo consiste en crear un **grafo de
afinidad** (o grafo de similitud) donde cada punto de los datos es un nodo del grafo y
las aristas (_edges_) entre nodos indican la similitud entre ellos.

Para expresar el valor de la similitud entre nodos, se puede utilizar la **función
gaussiana** (o kernel RBF). Cuando la distancia entre dos puntos es pequeña, la
similitud se aproxima a 1, indicando una gran afinidad; cuando la distancia es grande,
la similitud se aproxima a 0. El resultado es una **matriz de similitud** $W$ de
dimensión $n \times n$:

$$
W = \begin{pmatrix}
W_{1,1} & \cdots & W_{1,n} \\
\vdots & \ddots & \vdots \\
W_{n,1} & \cdots & W_{n,n}
\end{pmatrix}
$$

Una vez obtenido el grafo de similitud, el objetivo es dividir los nodos en $k$ grupos
minimizando las conexiones entre grupos y maximizando las conexiones dentro de cada
grupo.

```python linenums="1"
import numpy as np
import matplotlib.pyplot as plt
from sklearn.cluster import SpectralClustering
from sklearn.datasets import make_blobs

n_samples = 1500
random_state = 170

X, y = make_blobs(n_samples=n_samples, random_state=random_state)

# Transformación para crear datos no linealmente separables
transformation = [[0.60834549, -0.63667341], [-0.40887718, 0.85253229]]
X_aniso = np.dot(X, transformation)

# Aplicación del clustering espectral
y_pred = SpectralClustering(
    n_clusters=3,
    gamma=5,
    random_state=random_state
).fit_predict(X_aniso)

plt.figure(figsize=(6, 5))
plt.scatter(X_aniso[:, 0], X_aniso[:, 1], c=y_pred, s=10)
plt.title("Spectral Clustering")
plt.show()
```

## K-nearest neighbors (KNN)

A diferencia de los algoritmos de clustering vistos hasta este punto, **KNN**
(_K-Nearest Neighbors_) es un algoritmo **supervisado** utilizado para problemas de
clasificación y regresión. Su funcionamiento se basa en la idea de que puntos de datos
similares tienden a estar próximos en el espacio de características.

Para clasificar un nuevo punto, el algoritmo calcula la distancia de dicho punto
respecto a todos los puntos del conjunto de datos de entrenamiento, generalmente
utilizando la **distancia euclídea** o la **distancia Manhattan**. A continuación, se
seleccionan los $k$ vecinos más cercanos y se asigna al nuevo punto la clase mayoritaria
entre esos vecinos (en clasificación) o la media de sus etiquetas (en regresión).

La elección del valor de $k$ es un aspecto crítico del algoritmo. Un valor pequeño de
$k$ implica un sesgo bajo pero una alta varianza, lo que puede conducir al sobreajuste.
Un valor grande de $k$ implica un sesgo alto pero baja varianza, lo que puede provocar
subajuste. El valor óptimo de $k$ se obtiene mediante técnicas como la validación
cruzada y el análisis de curvas de aprendizaje, buscando un equilibrio entre ambos
extremos.

## Mecanismos para la elección del número de clusters

La selección del número óptimo de clusters es un paso fundamental en cualquier algoritmo
de agrupación. Existen varios métodos que permiten evaluar y comparar diferentes
configuraciones para determinar el valor más adecuado.

### Método del codo

El **método del codo** (_Elbow Method_) utiliza como medida el **WCSS** (_Within-Cluster
Sum of Squares_), que cuantifica la variabilidad de las observaciones dentro de los
clusters. El WCSS se calcula sumando las distancias al cuadrado entre cada observación y
el centroide de su respectivo cluster, y promediando los valores de todos los clusters
para obtener un WCSS global. Los valores más bajos de WCSS son preferibles, ya que
indican una agrupación más compacta.

El procedimiento consiste en ejecutar el algoritmo de clustering con diferentes valores
de $k$ y calcular el WCSS para cada uno. El valor óptimo de $k$ se identifica en el
punto donde la reducción del WCSS deja de ser significativa, formando un "codo" en la
gráfica.

```python linenums="1"
import numpy as np
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans

# Rango de valores para el número de clusters
inf = 2
sup = 10

wcss = []

for i in range(inf, sup + 1):
    algoritmo = KMeans(
        n_clusters=i,
        init='k-means++',
        max_iter=300,
        n_init=10,
        random_state=0
    )
    algoritmo.fit(x)
    wcss.append(algoritmo.inertia_)

plt.scatter(range(inf, sup + 1), wcss, c='red')
plt.plot(range(inf, sup + 1), wcss)
plt.grid(visible=True)
plt.title('Método del codo')
plt.xlabel('Número de clusters')
plt.ylabel('WCSS')
plt.show()
```

### Puntuación de la silueta

El **coeficiente de silueta** (_Silhouette Score_) se emplea para determinar el valor
óptimo del número de clusters. La puntuación se calcula promediando el coeficiente de
silueta de cada muestra, que se obtiene como la diferencia entre la distancia media al
cluster más cercano y la distancia media dentro del propio cluster, normalizada por el
valor máximo de ambas. Esto produce una puntuación entre $[-1, 1]$, donde 1 corresponde
a clusters muy densos y bien separados, 0 indica solapamiento entre clusters y -1 señala
una agrupación incorrecta.

```python linenums="1"
import numpy as np
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score
from yellowbrick.cluster import SilhouetteVisualizer

inf = 2
sup = 10

punt_silu = []

for i in range(inf, sup + 1):
    algoritmo = KMeans(
        n_clusters=i,
        init='k-means++',
        max_iter=300,
        n_init=10,
        random_state=0
    )
    visualizer = SilhouetteVisualizer(algoritmo, colors='yellowbrick')
    visualizer.fit(x)
    visualizer.show()
    punt_silu.append(silhouette_score(x, algoritmo.labels_))

sil = np.argmax(punt_silu) + 2

plt.grid(visible=True)
plt.plot(range(inf, sup + 1), punt_silu)
plt.scatter(sil, punt_silu[sil - 2], c='red', s=300)
plt.axvline(x=sil, linestyle='--', c='green', label='Punto óptimo')
plt.legend(shadow=True)
plt.title('Método de Puntuación de Silueta')
plt.xlabel('Número de clusters')
plt.ylabel('Puntuación Silueta')
plt.show()
```

### Índice de Caliński-Harabasz

El **índice de Caliński-Harabasz** (índice CH) evalúa la calidad de la agrupación
midiendo la relación entre la **cohesión** (qué tan similar es un objeto a su propio
grupo) y la **separación** (qué tan diferente es respecto a otros grupos). La cohesión
se estima en función de las distancias desde los puntos de datos hasta el centroide de
su cluster, y la separación se basa en la distancia de los centroides de cada cluster al
centroide global.

Un valor más alto del índice CH indica que los grupos son densos y están bien separados.
No existe un valor de corte universalmente aceptable, por lo que se buscan soluciones
que presenten un cambio abrupto en la gráfica del índice CH. Si la gráfica es suave, no
hay razón para preferir una solución sobre otra.

```python linenums="1"
import numpy as np
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans
from sklearn.metrics import calinski_harabasz_score

inf = 2
sup = 10

puntuaciones_CH = []

for i in range(inf, sup + 1):
    algoritmo = KMeans(
        n_clusters=i,
        init='k-means++',
        max_iter=300,
        n_init=10,
        random_state=0
    )
    algoritmo.fit(x)
    puntuaciones_CH.append(calinski_harabasz_score(x, algoritmo.labels_))

ch = np.argmax(puntuaciones_CH) + 2

plt.grid(visible=True)
plt.plot(range(inf, sup + 1), puntuaciones_CH)
plt.scatter(ch, puntuaciones_CH[ch - 2], c='red', s=300)
plt.axvline(x=ch, linestyle='--', c='green', label='Punto óptimo')
plt.legend(shadow=True)
plt.title('Método de Puntuación CH')
plt.xlabel('Número de clusters')
plt.ylabel('Índice CH')
plt.show()
```

### Combinación de métodos

Es recomendable combinar los métodos de búsqueda del número óptimo de clusters para
obtener un rango de valores óptimos más fiable. A continuación, se muestra un ejemplo
que integra las gráficas del método del codo, la puntuación de silueta y el índice CH en
una única visualización normalizada:

```python linenums="1"
import numpy as np
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score, calinski_harabasz_score

inf = 2
sup = 10

wcss = []
puntuaciones_CH = []
punt_silu = []

for i in range(inf, sup + 1):
    algoritmo = KMeans(
        n_clusters=i,
        init='k-means++',
        max_iter=300,
        n_init=10,
        random_state=0
    )
    algoritmo.fit(x)

    punt_silu.append(silhouette_score(x, algoritmo.labels_))
    puntuaciones_CH.append(calinski_harabasz_score(x, algoritmo.labels_))
    wcss.append(algoritmo.inertia_)

# Normalización de las puntuaciones para visualización conjunta
punt_silu = np.array(punt_silu) / np.linalg.norm(punt_silu)
puntuaciones_CH = np.array(puntuaciones_CH) / np.linalg.norm(puntuaciones_CH)
wcss = np.array(wcss) / np.linalg.norm(wcss)

plt.grid(visible=True)
plt.plot(range(inf, sup + 1), punt_silu, label='Silueta')
plt.plot(range(inf, sup + 1), puntuaciones_CH, label='CH')
plt.plot(range(inf, sup + 1), wcss, label='Codo')
plt.legend(shadow=True, loc='upper right')
plt.title('Combinación de métodos')
plt.xlabel('Número de clusters')
plt.ylabel('Puntuación normalizada')
plt.show()
```
