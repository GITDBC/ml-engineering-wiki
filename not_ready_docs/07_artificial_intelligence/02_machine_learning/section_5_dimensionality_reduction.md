---
authors: Daniel Bazo Correa
description: Técnicas de reducción de dimensionalidad.
title: Reducción de dimensionalidad
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Este capítulo describe las técnicas principales para reducir la dimensionalidad de los
datos, permitiendo su visualización y mejorando la eficiencia de los modelos.

## PCA

El **Análisis de Componentes Principales** (_Principal Component Analysis_, PCA) es una
técnica de reducción de dimensionalidad que transforma un conjunto de variables
posiblemente correlacionadas en un nuevo conjunto de variables no correlacionadas
denominadas **componentes principales**. Estas componentes se ordenan de manera que la
primera captura la mayor varianza posible de los datos, la segunda captura la mayor
varianza restante (siendo ortogonal a la primera), y así sucesivamente. De este modo, es
posible reducir la dimensionalidad del conjunto de datos conservando la mayor cantidad
de información posible, descartando las componentes que aportan menor varianza
(consideradas ruido).

## t-SNE

**t-SNE** (_t-distributed Stochastic Neighbor Embedding_) es una técnica de reducción de
dimensionalidad no lineal especialmente diseñada para la visualización de datos de alta
dimensionalidad en espacios de dos o tres dimensiones. A diferencia de PCA, que busca
preservar la varianza global, t-SNE se centra en preservar las relaciones de vecindad
local entre los puntos de datos. El algoritmo modela las similitudes entre puntos en el
espacio original mediante distribuciones de probabilidad y busca una representación en
baja dimensionalidad que preserve dichas similitudes, utilizando una distribución t de
Student para evitar el problema de la aglomeración de puntos.

## UMAP

**UMAP** (_Uniform Manifold Approximation and Projection_) es una técnica de reducción
de dimensionalidad basada en la teoría de variedades (_manifold learning_) y la
topología algebraica. Al igual que t-SNE, UMAP es eficaz para la visualización de datos
de alta dimensionalidad, pero ofrece varias ventajas: mayor velocidad de ejecución,
mejor preservación de la estructura global de los datos y la capacidad de realizar
transformaciones sobre nuevos datos sin necesidad de reentrenar el modelo. UMAP
construye una representación topológica de los datos en alta dimensionalidad y optimiza
una representación en baja dimensionalidad que preserve la estructura topológica
original.
