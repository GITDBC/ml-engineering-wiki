---
authors: Daniel Bazo Correa
description:
    Bibliotecas del ecosistema de Python especialmente útiles para construir utilidades
    y herramientas de línea de comandos.
title: Librerías
---

Este capítulo recopila un conjunto de bibliotecas del ecosistema de Python que resultan
especialmente útiles al construir utilidades, herramientas de línea de comandos
(_Command Line Interface_, CLI) y servicios pequeños. No pretende ser un catálogo
exhaustivo, sino un punto de partida con las alternativas más habituales para cada
necesidad.

## Bibliografía

- Python Software Foundation. (s.f.). _PyPI - The Python Package Index_.
  <https://pypi.org/>
- Python Packaging Authority. (s.f.). _Python Packaging User Guide_.
  <https://packaging.python.org/>

## Bibliotecas destacadas

La siguiente tabla resume el propósito de cada biblioteca. Todas se instalan como
dependencia del proyecto, con la excepción de `argparse`, que forma parte de la
biblioteca estándar y por tanto está disponible sin instalación previa.

| Biblioteca      | Descripción                                                                                                                                                                                         | Etiquetas                                          |
| --------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| `pypdf`         | Manipula archivos PDF, y permite leer, escribir, combinar documentos y extraer su contenido.                                                                                                        | pdf, documentos, extracción, lectura, escritura    |
| `argparse`      | Construye interfaces de línea de comandos definiendo argumentos y opciones, y genera el mensaje de ayuda de forma automática.                                                                       | cli, argumentos, terminal, comandos                |
| `sqlmodel`      | Modela y consulta bases de datos SQL combinando SQLAlchemy, que aporta el mapeo objeto-relacional, y Pydantic, que aporta la validación de datos.                                                   | sql, base de datos, orm, pydantic, sqlalchemy      |
| `cookiecutter`  | Genera proyectos a partir de plantillas, lo que estandariza la estructura de directorios y archivos al iniciar un desarrollo nuevo.                                                                 | plantillas, scaffolding, estructura, proyecto      |
| `slowapi`       | Limita el número de peticiones que admite una API construida con FastAPI o Starlette, con el fin de proteger el servicio frente a un uso abusivo.                                                   | fastapi, rate-limit, api, peticiones, throttling   |
| `python-dotenv` | Carga variables de entorno desde un archivo `.env` al entorno del proceso, lo que permite mantener la configuración y las credenciales fuera del código y por tanto fuera del control de versiones. | env, variables de entorno, configuración, secretos |

!!! note

    Conviene consultar la documentación oficial de cada biblioteca y su página en
    [PyPI](https://pypi.org/) para obtener información detallada sobre la instalación,
    el uso y la compatibilidad de versiones. Con el tiempo algunas de estas bibliotecas
    pueden quedar obsoletas o ser reemplazadas por alternativas mejores, de modo que
    revisar el estado del proyecto antes de adoptarlo es una precaución razonable.

Para conocer cómo se declaran estas dependencias en el archivo `pyproject.toml` y cómo
se instalan por grupos, puede consultarse el capítulo de
[entornos virtuales](section_1_environments.md).
