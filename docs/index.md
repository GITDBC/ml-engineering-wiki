---
title: Introducción
description: Wiki personal sobre IA, ciencia de datos y programación.
hide_table_of_contents: true
slug: /
---

# Introducción

!!! warning "Contenido nuevo pendiente de revisión"

    Se ha incorporado a la wiki material procedente de apuntes manuscritos y de notas de
    cursos. Ese contenido está integrado en el estilo del resto de la documentación, pero
    **no ha sido revisado** y puede contener errores de transcripción, imprecisiones
    técnicas o afirmaciones que convenga matizar. El listado siguiente recoge lo que falta
    por revisar.

    **Archivo nuevo**

    - `07_artificial_intelligence/01_mathematics/section_3_vector_calculus.md`: Capítulo
      de cálculo vectorial, con derivadas parciales, gradientes, Jacobiano,
      retropropagación, diferenciación automática y Hessiana.

    **Secciones añadidas a archivos existentes**

    - `07_artificial_intelligence/01_mathematics/section_2_deep_learning_math.md`: Todo el
      aparato de álgebra lineal, integrado en el capítulo existente de tensores. Incluye
      vectores y sistemas de ecuaciones, matrices, eliminación gaussiana, espacios
      vectoriales, independencia lineal, rango, mapeos lineales, cambios de base, imagen y
      núcleo, bases ortonormales, Gram-Schmidt, el hiperplano como límite de decisión,
      determinante y traza, autovalores, PageRank, Cholesky, SVD y el teorema de
      Eckart-Young-Mirsky. Las secciones previas de norma, producto interno y similitud
      del coseno se han reescrito para fusionarlas con este material.
    - `07_artificial_intelligence/01_mathematics/section_1_statistics.md`: Formalización
      del espacio muestral y las variables aleatorias, caso multivariante de la función
      de densidad y de distribución, y reglas de la suma y del producto como base del
      teorema de Bayes.
    - `07_artificial_intelligence/02_machine_learning/section_2_supervised_models.md`:
      Entropía, ganancia de información y criterios de parada en árboles de decisión,
      selección aleatoria de características en Random Forest y derivación geométrica de
      las SVM.
    - `07_artificial_intelligence/03_deep_learning/section_5_sequential_models.md`:
      Tipologías de problema secuencial, formulación del estado en las RNN, intuición e
      implementación de la atención y apartado completo sobre Mixture of Experts y
      Switch Transformer.
    - `07_artificial_intelligence/03_deep_learning/section_6_other_paradigms.md`:
      _Autoencoders_ variacionales con el truco de reparametrización y β-VAE, y función
      de similitud y conjuntos de datos en _few-shot learning_.
    - `06_operations/section_1_containers.md`: Redes segmentadas con IPAM, política de
      reinicio, límites de recursos, rotación de registros, entornos de desarrollo con
      recarga automática, modo _rootless_ y rutas de datos de MySQL y PostgreSQL.
    - `06_operations/section_3_orchestrators.md`: Plano de control de Kubernetes,
      modalidades de escalado, topologías de clúster, advertencia sobre NodePort en
      producción y tabla de operaciones con `kubectl`.
    - `06_operations/section_4_experiment_management.md`: Enfoques _model-centric_ y
      _data-centric_, diseño de sistemas de ML, clústeres y Ray, preparación de datos,
      modelos de referencia, métricas con F1 y tipos de prueba.
    - `06_operations/section_5_deployment.md`: Inferencia por lotes frente a inferencia en
      línea y apartado completo sobre compresión y cuantización de modelos.
    - `05_infrastructure/02_cloud/section_1_fundamentals.md`: Datos semiestructurados,
      distinción entre datos operativos y analíticos, integración y consolidación, y
      procesamiento por lotes y en tiempo real con Spark, Airflow, Kafka y Hadoop.
    - `05_infrastructure/01_databases/section_1_sql.md`: Comodines de conjunto y rango,
      procesamiento interno de una consulta, diseño de esquemas con claves foráneas y
      bases de datos NoSQL.
    - `04_software_engineering/section_1_data_structures.md`: Listas circulares y
      apartado completo sobre tablas hash con tratamiento de colisiones.
    - `04_software_engineering/section_2_algorithms.md`: Estrategia de resolución de
      problemas, derivación formal de la complejidad de la búsqueda binaria y serie
      aritmética de la ordenación por burbuja.
    - `03_programming/03_cuda/section_2_cuda_c.md`: Ciclo APOD, flujo iterativo de
      perfilado y ejemplo de dimensionado de malla para un dominio rectangular.

¡Bienvenido/a!

Soy Dani, y este es mi espacio dedicado al desarrollo de software que me gustaría
compartir contigo. Aquí reúno un poco los fundamentos de la ingeniería de software de
manera práctica, con temáticas que me he encontrado en mis propios proyectos o en el
trabajo. Decir que encontrarás un poco de todo, desde cómo funciona Linux, a nivel alto,
hasta cómo crear una red neuronal.

Al inicio esta wiki la hice para dedicarla solo a la inteligencia artificial, pero
conforme he seguido desarrollando mi carrera profesional y adquiriendo nuevo
conocimiento he abierto un poco más el horizonte y descubierto nuevas componentes que
son incluso más relevantes.

Gracias por interesarte y ser parte de este proyecto. Espero que disfrutes del
aprendizaje y que este contenido sea un apoyo real para alcanzar tus objetivos.

Y recuerda, siempre estoy abierto a nuevos proyectos, ideas o colaboraciones, así que no
dudes en escribirme por LinkedIn 😊.

!!! note Consideraciones

    La mayoría de los ejemplos y configuraciones están basados en Linux, específicamente
    en distribuciones basadas en Debian. Algunos comandos pueden variar según tu sistema
    operativo o distribución, y mantener toda la información actualizada me resulta
    complicado por el tiempo requerido. Por ello, te animo a investigar por tu cuenta si
    surge alguna dificultad para seguir algún paso.
