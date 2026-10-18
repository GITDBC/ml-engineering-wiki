---
authors: Daniel Bazo Correa
description: Fundamentos y arquitecturas de agentes basados en LLMs.
title: Agentes
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Este capítulo introduce el concepto de agente como sistema de inteligencia artificial
capaz de razonar, planificar e interactuar con su entorno de forma autónoma.

## Introducción

Un agente es un modelo de inteligencia artificial capaz de **razonar**, **planificar** e
**interactuar con el entorno**. Se denomina agente porque utiliza herramientas que le
ofrece el entorno, comunicándose mediante protocolos como _Agent-to-Agent_ (A2A) o
_Model Context Protocol_ (MCP). Las herramientas permiten ampliar las capacidades del
modelo sin necesidad de realizar _fine-tuning_, por lo que el diseño de la interfaz de
las herramientas tiene un gran impacto en la calidad del agente. Una acción puede
requerir el uso de múltiples herramientas.

### Tipos de agentes

| Tipo                         | Descripción                                                                                                    |
| :--------------------------- | :------------------------------------------------------------------------------------------------------------- |
| **_JSON Agent_**             | Especifica las acciones en formato JSON.                                                                       |
| **_Code Agent_**             | Escribe código que se interpreta externamente.                                                                 |
| **_Function Calling Agent_** | Subcategoría de _JSON Agent_ en la que se realiza _fine-tuning_ para generar un nuevo mensaje por cada acción. |

### Tipos de acciones

| Tipo                           | Descripción                                                            |
| :----------------------------- | :--------------------------------------------------------------------- |
| **_Information Gathering_**    | Búsquedas web, consultas a bases de datos, obtención de documentación. |
| **_Tool Usage_**               | Llamadas a APIs, ejecución de código.                                  |
| **Interacción con el entorno** | Manipulación de interfaces o del entorno.                              |
| **Comunicación**               | Colaboración entre agentes y usuarios.                                 |
