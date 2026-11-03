---
type: concept
title: "Batch size y optimización de gradiente"
created: 2026-08-17
updated: 2026-08-17
tags:
  - deep-learning
  - redes-neuronales
  - hiperparametros
  - optimizacion
  - regularizacion
status: seed
related:
  - "[[Machine Learning for Tabular Data]]"
  - "[[Deep Learning - Conceptos generales]]"
sources:
  - "Hilo de Reddit r/MachineLearning sobre batch size (capturas OCR 2025-01-03)"
---

# Batch size y optimización de gradiente

## Qué es el batch size

- **Batch size**: número de muestras de entrenamiento que se procesan juntas en una iteración antes de actualizar los pesos de la red.
- En el **descenso de gradiente por lotes** (batch gradient descent), cada paso de optimización se calcula sobre un subconjunto de los datos, no sobre el dataset completo.
- Tamaños extremos:
  - **Batch = dataset completo**: gradiente exacto, pero caro de computar.
  - **Batch = 1 (SGD puro)**: una actualización por cada muestra.
  - **Mini-batch** (típico 2–256): compromiso intermedio recomendado en la práctica.
- Es un **hiperparámetro**: se ajusta manualmente junto con el learning rate, la regularización, etc.

## Papel en el cálculo del gradiente

- Cada batch produce una **estimación** del gradiente real de la función de pérdida sobre todo el conjunto de datos.
- Cuanto mayor es el batch, más muestras contribuyen al promedio → mejor estimación del gradiente "verdadero".
- Con una mejor estimación, la optimización converge de forma más **estable** y dirigida hacia el mínimo.

## Trade-off: batch grande vs. batch pequeño

| Aspecto | Batch grande | Batch pequeño |
|---|---|---|
| Estimación del gradiente | Más precisa | Más ruidosa / aproximada |
| Convergencia | Más estable | Oscilante, menos directa |
| Mínimos locales | Mayor riesgo de atascarse | Escapa mejor (no los "nota") |
| Efecto regularizador | Menor | **Mayor** (regularización implícita) |
| Memoria / actualizaciones | Más memoria; buen paralelismo | Menos memoria; actualizaciones frecuentes |

### Riesgos de cada extremo

- **Batch demasiado grande**: el gradiente *promedio* puede impedir optimizar — la señal de los casos particulares se diluye y el modelo puede quedarse estancado. Además, sobrecarga de memoria.
- **Batch demasiado pequeño**: estimación muy ruidosa. En el extremo **batch = 1** la trayectoria puede saltar por todas partes y **no converger nunca**.
- Los batches pequeños son más **dinámicos**: los modelos se atascan menos y tienden a converger a mínimos con mejor generalización.

## La analogía de la "ceguera"

- Batch pequeño → estimación del gradiente más tosca → el optimizador va "más ciego".
- Esa "ceguera" evita caer en **mínimos locales**: el gradiente pobre ni siquiera los "nota".
- Batch grande → más precisión → útil cuando la función de pérdida se comporta razonablemente bien.

## Batch size como hiperparámetro

- Se tunea como cualquier otro hiperparámetro de entrenamiento (ver [[Machine Learning for Tabular Data]] para el papel análogo de `learning_rate`, `subsample` y regularización en XGBoost).
- Los **batch bajos fomentan regularización más fuerte** (regularización implícita del SGD).
- Se enmarca en los fundamentos de entrenamiento de [[Deep Learning - Conceptos generales]].

## Papers de arXiv citados en la fuente

| arXiv | Título | Relevancia |
|---|---|---|
| [1804.07612](https://arxiv.org/abs/1804.07612) | *Revisiting Small Batch Training for Deep Neural Networks* (Masters & Luschi, 2018) | Batch pequeños → mejor generalización y menor memoria; rango óptimo ≈ 2–32 |
| [2107.05074](https://arxiv.org/abs/2107.05074) | *SGD: The Role of Implicit Regularization, Batch-size and Multiple-epochs* (Kale, Sekhari & Sridharan, 2021) | Rol del batch size y de la regularización implícita en SGD |
| [1811.00659](https://arxiv.org/abs/1811.00659) | *Implicit Regularization of SGD in Natural Language Processing* (Lei et al., 2018) | SGD con batches pequeños converge a mínimos con mejor generalización |
| [2011.08843](https://arxiv.org/abs/2011.08843) | *Design Space for Graph Neural Networks* (You, Ying & Leskovec, NeurIPS 2020) | Citado como ejemplo de ajuste sistemático de hiperparámetros |

> [!note] Sobre la cuarta referencia
> El usuario del hilo cita 2011.08843 como ejemplo de búsqueda sistemática de hiperparámetros; el paper en sí estudia el *design space* de GNN, no el batch size directamente.

## Conexiones

- [[Machine Learning for Tabular Data]] — hiperparámetros de entrenamiento (learning rate, subsample, regularización L1/L2).
- [[Deep Learning - Conceptos generales]] — fundamentos de redes neuronales, funciones de coste y optimización.

## Fuente

- Hilo de Reddit r/MachineLearning sobre batch size (capturas OCR del 2025-01-03): discusión sobre estimación del gradiente por lotes, convergencia estable, mínimos locales, regularización y 4 referencias a papers de arXiv.