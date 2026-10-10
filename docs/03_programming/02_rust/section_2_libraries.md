---
authors: Daniel Bazo Correa
description:
    Crates del ecosistema de Rust especialmente útiles para construir herramientas de
    línea de comandos.
title: Librerías
---

Este capítulo recopila un conjunto de _crates_ de Rust, la unidad con la que el lenguaje
compila y distribuye código, que resultan especialmente útiles al construir herramientas
de línea de comandos (_Command Line Interface_, CLI). No pretende ser un catálogo
exhaustivo, sino un punto de partida con las alternativas más habituales para cada
necesidad.

## Bibliografía

- Rust Foundation. (s.f.). _crates.io - The Rust community's crate registry_.
  <https://crates.io/>
- Rust Project. (s.f.). _docs.rs_. <https://docs.rs/>

## _Crates_ destacados

Todos los _crates_ de la tabla se declaran como dependencia en la sección
`[dependencies]` del archivo `Cargo.toml`, tal como se describe en el capítulo de
[fundamentos](section_1_fundamentals.md).

| _Crate_     | Descripción                                                                                                                                                                 | Etiquetas                                    |
| ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------- |
| `clap`      | Analiza los argumentos de la línea de comandos a partir de macros derivadas, y genera de forma automática la ayuda, los subcomandos, las sugerencias y la salida con color. | cli, argumentos, terminal, comandos, parsing |
| `console`   | Aporta utilidades de estilización para la terminal, entre ellas colores, estilos de texto y control de la salida de forma multiplataforma.                                  | terminal, colores, estilos, salida, tui      |
| `ctrlc`     | Captura la señal de interrupción (`Ctrl + C`) para ejecutar la lógica de limpieza necesaria antes de que el programa termine.                                               | señales, interrupción, ctrl-c, limpieza      |
| `dialoguer` | Construye interacciones en terminal, como selectores, confirmaciones, entradas de texto y menús de selección múltiple.                                                      | cli, interactivo, prompts, menús, selección  |

!!! note

    Conviene consultar la documentación oficial de cada _crate_ y su página en
    [crates.io](https://crates.io/) para obtener información detallada sobre la
    instalación, el uso y la compatibilidad de versiones. Con el tiempo algunos de estos
    _crates_ pueden quedar obsoletos o ser reemplazados por alternativas mejores, de
    modo que revisar el estado del proyecto antes de adoptarlo es una precaución
    razonable.

Para conocer cómo se declaran estos _crates_ en el archivo `Cargo.toml` y cómo se
compila el proyecto, puede consultarse el capítulo de
[fundamentos](section_1_fundamentals.md).
