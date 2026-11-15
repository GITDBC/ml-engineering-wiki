---
icon: lucide/book-open
authors: Daniel Bazo Correa
description: Fundamentos del Machine Learning.
title: Fundamentos
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Este capítulo introduce los conceptos fundamentales del aprendizaje automático, sus
técnicas principales y los tipos de datos con los que trabaja.

## Bibliografía

- Stanford University. (s.f.). _CS229: Machine Learning_ \[Lista de reproducción\].
  YouTube. <https://youtube.com/playlist?list=PLoROMvodv4rNjRoawgt72BBNwL2V7doGI>

## Introducción

### Definición

<figure markdown="span">
  ![Conjuntos que engloba la inteligencia artificial](https://www.techspot.com/articles-info/2048/images/2020-07-07-image.jpg)
  <figcaption>Ilustración sobre los conjuntos que engloba la inteligencia artificial. <a href="https://www.techspot.com/articles-info/2048/images/2020-07-07-image.jpg">Referencia</a></figcaption>
</figure>

El **aprendizaje automático** es una rama de la inteligencia artificial que se centra en
el desarrollo y uso de algoritmos, también denominados **modelos**, capaces de
identificar y comprender patrones en los datos de entrada con el objetivo de optimizar
una métrica establecida.

A diferencia de los enfoques tradicionales de programación, donde las reglas se definen
explícitamente, en el aprendizaje automático los algoritmos ajustan sus parámetros
automáticamente para mejorar su desempeño en función de los datos.

<figure markdown="span">
  ![Los cinco paradigmas del aprendizaje automático](../../assets/img/docs/machine_learning/ml-fundamentals-learning-paradigms.svg)
  <figcaption>Los cinco paradigmas del aprendizaje automático según su señal de entrenamiento: datos etiquetados (supervisado), datos sin etiquetar (no supervisado), unas pocas etiquetas (semisupervisado), etiquetas derivadas de los propios datos (autosupervisado) y recompensas (aprendizaje por refuerzo).</figcaption>
</figure>

### Técnicas

<figure markdown="span">
  ![Clasificación frente a regresión](https://www.sharpsightlabs.com/wp-content/uploads/2021/04/regression-vs-classification_simple-comparison-image_v3.png)
  <figcaption>Clasificación vs Regresión. <a href="https://www.sharpsightlabs.com/wp-content/uploads/2021/04/regression-vs-classification_simple-comparison-image_v3.png">Referencia</a></figcaption>
</figure>

Entre las técnicas más utilizadas se encuentran la **clasificación** y la **regresión**.
La clasificación permite asignar etiquetas o categorías a los datos en función de sus
características comunes. Un ejemplo de clasificación es la identificación del tipo de
planta a partir de atributos como el ancho y la altura de sus hojas. Por otro lado, la
regresión se emplea para realizar predicciones numéricas, como la estimación del precio
de una vivienda en función de sus características.

La elección de la técnica adecuada depende de la naturaleza del problema. Un enfoque
común consiste en evaluar múltiples algoritmos viables y compararlos para determinar
cuál ofrece el mejor rendimiento. Esta comparación se basa en métricas de desempeño
obtenidas a partir de los datos.

**El proceso de entrenamiento de los modelos requiere dividir el conjunto de datos en
distintas partes**: una para el **entrenamiento** del modelo, otra para la
**evaluación** de su desempeño y, en algunos casos, una tercera partición para
**validar** su capacidad de generalización antes de su implementación en entornos
reales. Durante este proceso, el algoritmo analiza las relaciones entre las
características de los datos, identifica patrones y genera predicciones que se comparan
con los valores reales. La diferencia entre las predicciones y las observaciones se mide
mediante una métrica de error, lo que permite ajustar el modelo en cada iteración o
**época**, es decir, cada vez que el algoritmo analiza completamente el conjunto de
datos.

<figure markdown="span">
  ![Subajuste, ajuste adecuado y sobreajuste](../../assets/img/docs/machine_learning/ml-fundamentals-overfitting.svg)
  <figcaption>Ejemplo de subajuste (grado 1), ajuste adecuado (grado 4) y sobreajuste (grado 15) al ajustar polinomios a 30 muestras con ruido de una función coseno. El error de prueba solo es bajo en el ajuste adecuado.</figcaption>
</figure>

Un modelo puede presentar **sobreajuste** (**_overfitting_**) cuando se ajusta demasiado
a los datos de entrenamiento, logrando un alto rendimiento en estos pero fallando en
datos nuevos. En el extremo opuesto, el **subajuste** (**_underfitting_**) ocurre cuando
el modelo es demasiado simple para capturar la estructura subyacente de los datos. Este
equilibrio se conoce como el **compromiso entre sesgo y varianza** (**_bias-variance
tradeoff_**), y su gestión es esencial para obtener modelos que generalicen
correctamente.

El **sesgo** (_bias_) se refiere a la incapacidad de un algoritmo de aprendizaje
automático para capturar la relación real existente en los datos. Un sesgo alto implica
que el modelo realiza suposiciones demasiado simplificadas y no se ajusta adecuadamente
ni siquiera a los datos de entrenamiento. La **varianza** (_variance_), por su parte,
mide la diferencia de ajuste entre el conjunto de entrenamiento y otros conjuntos, como
el de validación o el de pruebas. Una varianza alta indica que el modelo es muy sensible
a las particularidades del conjunto de entrenamiento y no generaliza bien a datos
nuevos. Lo ideal es alcanzar un bajo sesgo, para modelar con mayor exactitud la
distribución de los datos, y una baja varianza, para que el resultado de las
predicciones sea consistente para diferentes conjuntos de datos.

### Tipos de datos

#### Variables dependientes e independientes

En un conjunto de datos, cada atributo que varía entre muestras se denomina
**variable**. Si una variable depende de otra, se considera **dependiente**; en caso
contrario, se clasifica como **independiente**. Las variables independientes, también
llamadas **características** (**_features_**), son las utilizadas en el entrenamiento
del modelo para predecir la variable dependiente.

#### Datos continuos y discretos

<figure markdown="span">
  ![Datos discretos frente a datos continuos](https://agencyanalytics.com/_next/image?url=https%3A%2F%2Fimages.ctfassets.net%2Fdfcvkz6j859j%2F6k4gJrY1mvlPUxf7WZhqdp%2F9f2e800789b81fa6fe751fabf50e9069%2FDiscrete-vs-Continuous-Data-Supporting-Graphics-1.png&w=3840&q=75)
  <figcaption>Datos discretos vs datos continuos. <a href="https://agencyanalytics.com/_next/image?url=https%3A%2F%2Fimages.ctfassets.net%2Fdfcvkz6j859j%2F6k4gJrY1mvlPUxf7WZhqdp%2F9f2e800789b81fa6fe751fabf50e9069%2FDiscrete-vs-Continuous-Data-Supporting-Graphics-1.png&w=3840&q=75">Referencia</a></figcaption>
</figure>

Los datos pueden clasificarse en **continuos** o **discretos**. Los valores continuos
pueden tomar cualquier número dentro de un rango, como la altura de una persona, ya que
pueden existir valores intermedios con una precisión arbitraria. En contraste, los
valores discretos solo pueden asumir ciertos valores específicos, como la cantidad de
páginas de un libro, donde no existen valores intermedios entre un número entero y otro.

#### Datos categóricos

Los datos **categóricos** toman valores de un conjunto finito de categorías sin un orden
numérico entre ellas, como el tipo de planta o el color de un objeto. Como los modelos
operan con números, cada categoría se codifica antes de entrenar. Asignar un entero a
cada categoría introduciría un orden y una distancia que no existen, por lo que se
recurre a la codificación **_one-hot_** (**_one-hot encoding_**): cada muestra se
representa con un vector de $k$ componentes, todas a cero salvo la de su clase, que vale
uno. Con NumPy, la fila $i$ de la matriz identidad de tamaño $k$ es el vector _one-hot_
de la clase $i$, y la operación inversa se obtiene con `argmax` sobre cada fila.

???+ example "Codificación _one-hot_ y su inversa"

    El ejemplo codifica seis etiquetas con tres categorías y recupera los índices
    originales.

    ```python linenums="1"
    import numpy as np


    def codificar_one_hot(y: np.ndarray, k: int) -> np.ndarray:
        """Codifica un vector de índices de clase en una matriz one-hot.

        Args:
            y: Vector de enteros en el rango [0, k) con una etiqueta por muestra.
            k: Número de categorías distintas.

        Returns:
            Matriz de forma (n, k) con un 1 en la columna de la clase de cada muestra.
        """
        # Cada fila de la identidad es el vector one-hot de una clase
        return np.eye(k)[y]


    def decodificar_one_hot(y_one_hot: np.ndarray) -> np.ndarray:
        """Recupera los índices de clase a partir de una matriz one-hot.

        Args:
            y_one_hot: Matriz de forma (n, k) con codificación one-hot.

        Returns:
            Vector de n enteros con el índice de la clase de cada muestra.
        """
        # La posición del valor máximo de cada fila es el índice de la clase
        return np.argmax(y_one_hot, axis=1)


    # Etiquetas de seis muestras con tres categorías: 0, 1 y 2
    y = np.array([0, 2, 1, 2, 0, 1])
    y_one_hot = codificar_one_hot(y, k=3)
    print(y_one_hot)
    print(decodificar_one_hot(y_one_hot))
    ```

    ```plaintext title="Expected output"
    [[1. 0. 0.]
     [0. 0. 1.]
     [0. 1. 0.]
     [0. 0. 1.]
     [1. 0. 0.]
     [0. 1. 0.]]
    [0 2 1 2 0 1]
    ```

No todos los modelos necesitan esta codificación en las etiquetas. En PyTorch,
`nn.CrossEntropyLoss` recibe los índices de clase directamente, por lo que no requiere
_one-hot_ en la variable dependiente.

## Cierre

Con los conceptos básicos y los tipos de datos ya presentados, el
[siguiente capítulo](section_2_supervised_models.md) describe modelos de aprendizaje
supervisado concretos: Naïve Bayes, árboles de decisión, máquinas de vectores de soporte
y XGBoost.
