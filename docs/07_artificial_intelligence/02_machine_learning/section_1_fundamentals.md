---
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
  ![Subajuste, ajuste adecuado y sobreajuste](https://miro.medium.com/max/1125/1*_7OPgojau8hkiPUiHoGK_w.png)
  <figcaption>Ejemplo de subajuste, ajuste adecuado y sobreajuste. <a href="https://miro.medium.com/max/1125/1*_7OPgojau8hkiPUiHoGK_w.png">Referencia</a></figcaption>
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
