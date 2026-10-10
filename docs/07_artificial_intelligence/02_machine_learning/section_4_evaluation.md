---
authors: Daniel Bazo Correa
description: Evaluación de modelos de clasificación.
title: Evaluación de modelos
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Este capítulo presenta las métricas y herramientas para evaluar el rendimiento de
modelos de clasificación, incluyendo la matriz de confusión, sensibilidad, especificidad
y curvas ROC.

## Clasificación

### Matriz de confusión

La **matriz de confusión** es una herramienta clave para evaluar la capacidad de un
modelo de clasificación. Relaciona los valores predichos por el modelo con los valores
reales, organizándolos en cuatro categorías:

- **True Positives (TP)**: Instancias positivas correctamente clasificadas.
- **False Positives (FP)**: Instancias negativas clasificadas incorrectamente como
  positivas.
- **True Negatives (TN)**: Instancias negativas correctamente clasificadas.
- **False Negatives (FN)**: Instancias positivas clasificadas incorrectamente como
  negativas.

La diagonal principal de la matriz (TP y TN) refleja la tasa de aciertos del modelo;
valores más elevados indican un mejor desempeño.

### Sensibilidad y especificidad

Dos métricas derivadas de la matriz de confusión permiten evaluar la capacidad del
modelo para identificar correctamente las clases positivas y negativas.

La **sensibilidad** (_Recall_) mide la proporción de verdaderos positivos respecto al
total de instancias realmente positivas:

$$
\text{Sensibilidad} = \frac{TP}{TP + FN}.
$$

Un valor alto indica que el modelo identifica correctamente la mayoría de las instancias
positivas.

La **especificidad** mide la proporción de verdaderos negativos respecto al total de
instancias realmente negativas:

$$
\text{Especificidad} = \frac{TN}{TN + FP}.
$$

Un valor alto indica que el modelo discrimina adecuadamente las instancias negativas.
Ambas métricas se pueden expresar en porcentaje multiplicando por cien.

???+ example "Matriz de confusión 2×2"

    Supongamos un algoritmo de regresión logística que predice si un paciente tiene enfermedad cardíaca o no, con la siguiente matriz de confusión:

    |                        | Predice enfermedad | Predice no enfermedad |
    | ---------------------- | ------------------ | --------------------- |
    | **Enfermedad real**    | 145 (TP)           | 25 (FN)               |
    | **No enfermedad real** | 30 (FP)            | 100 (TN)              |

    El recall se calcula como:

    $$
    Recall = \frac{145}{145 + 25} = \frac{145}{170} = 0.8529 \; (85.29\%)
    $$

    La especificidad se calcula como:

    $$
    Specificity = \frac{100}{100 + 30} = \frac{100}{130} = 0.7692 \; (76.92\%)
    $$

    Esto indica que el 85.29% de los pacientes con enfermedad han sido clasificados correctamente y el 76.92% de los pacientes sin enfermedad han sido clasificados correctamente. Estas métricas permiten comparar directamente con otros modelos, como un árbol de decisión, y elegir el más adecuado según la prioridad del problema: si detectar pacientes sin enfermedad es más importante, se podría preferir la regresión logística; si detectar pacientes con enfermedad es prioritario, se podría optar por el árbol de decisión.

???+ example "Matriz de confusión multiclase (3×3)"

    Para matrices de confusión de mayor tamaño, la interpretación es análoga, calculando la sensibilidad y la especificidad para cada categoría. Supongamos una matriz de confusión con 3 clases A, B y C:

    | Real \ Predicho | A   | B   | C   |
    | --------------- | --- | --- | --- |
    | **A**           | 50  | 5   | 10  |
    | **B**           | 8   | 45  | 7   |
    | **C**           | 6   | 9   | 40  |

    Los valores de la diagonal principal representan las clasificaciones correctas, las filas representan la clase real y las columnas la clase predicha.

    **Recall por clase:**

    $$Recall_A = \frac{50}{50 + 5 + 10} = \frac{50}{65} = 0.7692 \; (76.92\%)$$

    $$Recall_B = \frac{45}{8 + 45 + 7} = \frac{45}{60} = 0.7500 \; (75.00\%)$$

    $$Recall_C = \frac{40}{6 + 9 + 40} = \frac{40}{55} = 0.7273 \; (72.73\%)$$

    **Especificidad por clase:**

    Para la clase A: $FP_A = 8 + 6 = 14$, $TN_A = 45 + 7 + 9 + 40 = 101$

    $$Specificity_A = \frac{101}{101 + 14} = 0.8783 \; (87.83\%)$$

    Para la clase B: $FP_B = 5 + 9 = 14$, $TN_B = 50 + 10 + 6 + 40 = 106$

    $$Specificity_B = \frac{106}{106 + 14} = 0.8833 \; (88.33\%)$$

    Para la clase C: $FP_C = 10 + 7 = 17$, $TN_C = 50 + 5 + 8 + 45 = 108$

    $$Specificity_C = \frac{108}{108 + 17} = 0.8640 \; (86.40\%)$$

    En resumen, para matrices de confusión multiclase, el recall se calcula a partir de la fila de la clase de interés (proporción de la diagonal respecto al total de la fila), mientras que la especificidad se obtiene considerando todos los valores que no pertenecen a dicha clase. Los verdaderos negativos corresponden a todas las celdas que no están ni en la fila ni en la columna de la clase de interés, y los falsos positivos son los valores de la columna de la clase de interés excluyendo la diagonal.

### ROC y AUC

La curva **ROC** (_Receiver Operating Characteristic_) es una herramienta gráfica que
permite evaluar el rendimiento de un clasificador binario representando la relación
entre la **tasa de verdaderos positivos** (_True Positive Rate_, TPR o sensibilidad) en
el eje $y$ y la **tasa de falsos positivos** (_False Positive Rate_, FPR) en el eje $x$,
ambos con rangos comprendidos entre 0 y 1.

La diagonal principal de la gráfica ROC representa el rendimiento de un clasificador
aleatorio, es decir, aquel que tiene una proporción igual de falsos positivos y
verdaderos positivos. Los modelos cuya curva se sitúa por encima de esta diagonal
presentan un rendimiento superior al azar, mientras que los que se sitúan por debajo
tienen un rendimiento inferior. La elección de un modelo sobre otro depende de la
importancia relativa de minimizar los falsos positivos o maximizar los verdaderos
positivos según el contexto del problema.

El **AUC** (_Area Under the Curve_) mide el área bajo la curva ROC y proporciona un
valor numérico único para comparar modelos. Un valor de AUC cercano a 1 indica un modelo
excelente, mientras que un valor cercano a 0.5 indica un rendimiento similar al azar. El
AUC resulta especialmente útil para comparar modelos con diferentes curvas ROC.

En conjuntos de datos no balanceados, es habitual sustituir la tasa de falsos positivos
(FPR) por la **precisión** (_precision_), que mide la proporción de resultados positivos
correctamente clasificados respecto al total de predicciones positivas. La curva
resultante, denominada **curva Precision-Recall**, ofrece una evaluación más equilibrada
del rendimiento del modelo en estos escenarios.
