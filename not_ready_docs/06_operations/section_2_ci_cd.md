---
authors: Daniel Bazo Correa
description:
    Prácticas de integración y despliegue continuos, con la definición de pipelines en
    GitHub Actions y GitLab CI/CD.
title: CI/CD
---

Este capítulo aborda las prácticas de integración y despliegue continuos, el papel que
desempeñan dentro del ciclo de desarrollo y la definición de _pipelines_ en las dos
plataformas más extendidas, GitHub Actions y GitLab CI/CD.

## Bibliografía

- GitHub. (s.f.). _GitHub Actions Documentation_. <https://docs.github.com/en/actions>
- GitLab. (s.f.). _GitLab CI/CD_. <https://docs.gitlab.com/ee/ci/>

## Introducción

La **integración continua** (_Continuous Integration_, CI) consiste en incorporar los
cambios en la rama principal con la mayor frecuencia posible, acompañando cada
incorporación de procesos automáticos de construcción y de pruebas. El **despliegue
continuo** (_Continuous Deployment_, CD) extiende esa automatización hasta la
publicación del software en producción o en entornos equivalentes. Ambas prácticas
persiguen el mismo objetivo: detectar los errores lo antes posible y reducir el coste de
cada entrega.

Una implementación madura combina _commits_ frecuentes, pruebas automatizadas y revisión
de código mediante _pull requests_. A ello se añaden técnicas como las **_feature
flags_**, que permiten activar o desactivar funcionalidades en tiempo de ejecución sin
necesidad de un nuevo despliegue, lo que separa la publicación del código de la
activación de la funcionalidad.

!!! note "Ramas y _pull requests_"

    Las estrategias de ramificación y el flujo de revisión sobre el que se apoyan estas
    prácticas se describen en el capítulo de [fundamentos de
    Git](../02_dev_tools/01_git/section_1_fundamentals.md).

### Plataformas

GitHub es una plataforma de desarrollo colaborativo que proporciona control de versiones
mediante Git junto con funcionalidades de CI/CD. Entre ellas destacan GitHub Actions,
para la automatización de flujos de trabajo, y GitHub Pages, para publicar sitios web
estáticos desde un repositorio. La principal ventaja de GitHub Actions frente a
herramientas externas como Jenkins es su integración nativa con el repositorio, sin
necesidad de mantener un servidor independiente. Su Marketplace ofrece además un amplio
catálogo de acciones desarrolladas por GitHub y por terceros.

GitLab cubre el mismo terreno con un modelo propio. Su sistema de CI/CD también es
nativo, se configura mediante un único archivo en la raíz del repositorio y se apoya en
una arquitectura cliente-servidor en la que el servidor orquesta la ejecución y los
_runners_ realizan el trabajo. Las secciones siguientes describen primero GitHub Actions
y después GitLab CI/CD, de modo que los conceptos comunes, como los _jobs_, las etapas o
la reutilización de configuración, se presentan una sola vez.

## GitHub Actions

GitHub Actions automatiza flujos de trabajo mediante archivos de configuración en
formato YAML. Cada _workflow_ se compone de una serie de pasos organizados en _jobs_,
que se ejecutan en paralelo o en secuencia según las necesidades del proyecto.

El _runner_ es el servidor que ejecuta esos _workflows_ en un entorno definido. Sobre él
se compila el código para distintos sistemas operativos, se ejecutan pruebas en
paralelo, se valida el código con herramientas como los _linters_ y los analizadores
estáticos y se despliega el resultado en producción o en entornos de _staging_.

<figure markdown="span">
  ![Relación entre eventos, jobs y steps en un workflow](../assets/img/docs/cloud/cloud-github-actions-workflow.png)
  <figcaption>Esquema de un <em>workflow</em> en GitHub Actions.</figcaption>
</figure>

Un _pipeline_ habitual encadena la fusión (_merge_) de los cambios en la rama principal,
la ejecución de las pruebas, el análisis estático del código (_linting_), la generación
de una compilación (_build_) y el despliegue en producción o en _staging_.

Los _workflows_ se declaran en archivos `.yml` ubicados en el directorio
`.github/workflows/` del repositorio:

```plaintext linenums="1"
.
├── .github
│   └── workflows
│       └── workflow_ejemplo.yml
└── src
```

### Elementos de un _workflow_

El campo `name` asigna un nombre descriptivo al _workflow_. Aunque es opcional, resulta
recomendable para facilitar su identificación en la interfaz de GitHub y su
reutilización desde otros _workflows_:

```yaml linenums="1"
name: Nombre del Workflow
```

Los disparadores, declarados en el campo `on`, determinan cuándo se ejecuta el
_workflow_. Los eventos habituales son `push`, `pull_request` y las ejecuciones
programadas. Junto a ellos se declaran los permisos que necesita la ejecución, ya sea de
forma global o dentro de un _job_ concreto. Cuando varios _jobs_ requieren los mismos
permisos conviene declararlos a nivel de _workflow_ en lugar de repetirlos.

El siguiente ejemplo muestra la declaración global de permisos, aplicable a todos los
_jobs_ del _workflow_.

???+ example "Permisos a nivel de _workflow_"

    ```yaml linenums="1"
    name: Nombre del Workflow

    on:
      push:
        branches: ["main"]
      workflow_call:

    permissions:
      contents: write
    ```

    El evento `workflow_call` habilita la invocación de este _workflow_ desde otro, lo
    que permite reutilizarlo como una pieza más dentro de un flujo mayor.

Cuando solo un _job_ necesita permisos elevados, la declaración se traslada a su
definición para limitar el alcance de los privilegios concedidos.

???+ example "Permisos a nivel de _job_"

    ```yaml linenums="1"
    name: Nombre del Workflow

    on:
      push:
        branches: ["main"]
      workflow_call:

    jobs:
      build-mkdocs:
        name: Build MkDocs Wiki
        runs-on: ubuntu-latest
        needs: setup-lint-test

        permissions:
          contents: write

        steps:
          - name: Checkout repository
            uses: actions/checkout@v4
    ```

    El _job_ `build-mkdocs` recibe permiso de escritura sobre el contenido del
    repositorio y, mediante `needs`, espera a que finalice el _job_ `setup-lint-test`
    antes de comenzar.

Los _jobs_ representan las unidades de trabajo del _workflow_. Cada uno agrupa una serie
de _steps_ que se ejecutan de forma secuencial. Por defecto los _jobs_ se ejecutan en
paralelo, salvo que uno declare una dependencia explícita mediante `needs`. Cada _job_
se ejecuta en una máquina virtual nueva, cuyo sistema operativo se indica con `runs-on`,
con Linux, macOS y Windows entre las opciones disponibles.

???+ example "Definición de un _job_"

    ```yaml linenums="1"
    jobs:
      nombre-del-job:
        runs-on: ubuntu-latest
    ```

    La etiqueta `ubuntu-latest` designa la última versión estable de Ubuntu disponible
    entre los _runners_ alojados por GitHub.

!!! note "_Runners_ disponibles"

    El catálogo completo de _runners_ alojados por GitHub, con sus sistemas operativos y
    sus recursos asignados, se detalla en la
    [documentación oficial](https://docs.github.com/en/actions/using-github-hosted-runners/using-github-hosted-runners/about-github-hosted-runners).

Dentro de los _steps_ es posible integrar acciones predefinidas, disponibles en el
[repositorio oficial de acciones](https://github.com/actions) y en el
[GitHub Marketplace](https://github.com/marketplace), lo que evita reimplementar tareas
habituales como la instalación de un intérprete o la gestión de la caché.

### Ejemplos de configuración

El _workflow_ más sencillo reacciona a los cambios sobre una rama y prepara el entorno
para las tareas posteriores.

???+ example "_Workflow_ básico"

    ```yaml linenums="1"
    name: Workflow básico

    on:
      push:
        branches: ["main"]
      pull_request:
        branches: ["main"]

    permissions:
      contents: read

    jobs:
      build:
        runs-on: ubuntu-latest

        steps:
          - name: Checkout repository
            uses: actions/checkout@v4
    ```

    La ejecución se dispara ante un `push` o un `pull_request` sobre la rama `main`, y el
    único _step_ descarga el código del repositorio en el _runner_.

!!! tip "Acción `checkout`"

    Conviene situar la acción `checkout` al inicio del _workflow_, ya que el _runner_
    parte de una máquina limpia y el resto de tareas necesitan disponer del código más
    reciente antes de ejecutarse.

Sobre esa base se añade la preparación del lenguaje y de las dependencias. El ejemplo
siguiente configura Python, gestiona las dependencias con Poetry y valida el código con
Flake8.

???+ example "Validación de código Python con Flake8"

    ```yaml linenums="1"
    name: Verificación con Flake8

    on:
      push:
        branches: ["main"]
      pull_request:
        branches: ["main"]

    permissions:
      contents: read

    jobs:
      build:
        runs-on: ubuntu-latest

        steps:
          - name: Checkout repository
            uses: actions/checkout@v4

          - name: Instalar Python
            uses: actions/setup-python@v5
            with:
              python-version: "3.10"

          - name: Instalar Poetry
            uses: snok/install-poetry@v1

          - name: Instalar dependencias con Poetry
            run: poetry install

          - name: Verificar código con Flake8
            run: poetry run flake8 src/
    ```

    Cada _step_ se apoya en el anterior: primero se descarga el código, después se
    instalan el intérprete y el gestor de dependencias y, por último, se ejecuta el
    análisis estático sobre el directorio `src/`.

La instalación de dependencias es una de las tareas más costosas de un _pipeline_. El
almacenamiento en caché del entorno virtual evita repetirla cuando las dependencias no
han cambiado.

???+ example "Caché de dependencias"

    ```yaml linenums="1"
    name: Workflow con caché

    on:
      push:
        branches: ["main"]
      pull_request:
        branches: ["main"]

    permissions:
      contents: read

    jobs:
      build:
        runs-on: ubuntu-latest

        steps:
          - name: Checkout repository
            uses: actions/checkout@v4

          - name: Instalar Python
            uses: actions/setup-python@v5
            with:
              python-version: "3.10"

          - name: Instalar Poetry
            uses: snok/install-poetry@v1
            with:
              virtualenvs-in-project: true

          - name: Cargar caché de dependencias
            uses: actions/cache@v4
            id: cached-poetry-dependencies
            with:
              path: .venv
              key: venv-${{ runner.os }}-${{ hashFiles('**/poetry.lock') }}

          - name: Instalar dependencias con Poetry
            if: steps.cached-poetry-dependencies.outputs.cache-hit != 'true'
            run: poetry install
    ```

    La opción `virtualenvs-in-project` sitúa el entorno virtual en el directorio `.venv`
    del proyecto, que es la ruta que se almacena en la caché. La condición `if` del
    último _step_ omite la instalación cuando la caché se ha recuperado correctamente.

!!! note "Invalidación de la caché"

    La clave `venv-${{ runner.os }}-${{ hashFiles('**/poetry.lock') }}` incorpora el
    sistema operativo del _runner_ y un _hash_ del archivo `poetry.lock`, de modo que la
    caché solo se renueva cuando cambian las dependencias declaradas. Esta técnica reduce
    de forma notable el tiempo de ejecución, aunque conviene revisar periódicamente su
    comportamiento para evitar que un _pipeline_ trabaje con dependencias obsoletas.

### Modularización de _workflows_

Cuando varios _workflows_ repiten la misma secuencia de preparación, esa lógica puede
extraerse a una acción personalizada. El resultado mejora la reutilización y reduce el
mantenimiento, ya que un cambio en la preparación del entorno se aplica en un único
lugar. La estructura del proyecto refleja esta separación:

```plaintext linenums="1"
.
├── .github
│   ├── actions
│   │   └── build-application
│   │       └── action.yml
│   └── workflows
│       └── lint.yml
└── src
```

Cada acción personalizada reside en su propio directorio y se declara en un archivo que
debe llamarse `action.yml`. El tipo `composite` indica que la acción agrupa una
secuencia de _steps_ reutilizables:

```yaml linenums="1"
name: Build Application

runs:
    using: composite

    steps:
        - name: Checkout repository
          uses: actions/checkout@v4

        - name: Set up Python
          uses: actions/setup-python@v5
          with:
              python-version: "3.10.7"

        - name: Instalar Poetry
          uses: snok/install-poetry@v1
          with:
              virtualenvs-in-project: true

        - name: Cargar caché de dependencias
          uses: actions/cache@v4
          id: cached-poetry-dependencies
          with:
              path: .venv
              key: venv-${{ runner.os }}-${{ hashFiles('**/poetry.lock') }}

        - name: Instalar dependencias con Poetry
          if: steps.cached-poetry-dependencies.outputs.cache-hit != 'true'
          run: poetry install
```

Los _workflows_ invocan después esta acción con
`uses: ./.github/actions/build-application` en lugar de repetir sus _steps_. Este
enfoque divide la complejidad del _pipeline_, facilita la incorporación de nuevas
funcionalidades sin modificar los _workflows_ principales y mantiene una única
definición de cada tarea compartida.

### Matrices de estrategia

Las matrices de estrategia ejecutan un mismo _job_ en múltiples combinaciones de
entornos, lo que resulta especialmente útil para validar el software en distintos
sistemas operativos, versiones o configuraciones. El bloque `matrix` declara las
dimensiones de la combinación y el bloque `exclude` descarta los casos que no interesan:

```yaml linenums="1"
name: Workflow

on:
    push:
        branches: ["main"]
    pull_request:
        branches: ["main"]

jobs:
    build:
        runs-on: ${{ matrix.os }}
        strategy:
            matrix:
                os: [macos-latest, windows-latest]
                version: [12, 14, 16]
                environment: [staging, production]
                exclude:
                    - os: macos-latest
                      version: 12
                      environment: production
                    - os: windows-latest
                      version: 16
```

GitHub genera de forma automática todas las combinaciones posibles de los valores
declarados en `matrix`. Las que se ejecutan tras aplicar las exclusiones son las
siguientes:

| Sistema operativo | Versión | Entorno      |
| ----------------- | ------- | ------------ |
| `macos-latest`    | 12      | `staging`    |
| `macos-latest`    | 14      | `staging`    |
| `macos-latest`    | 14      | `production` |
| `macos-latest`    | 16      | `staging`    |
| `macos-latest`    | 16      | `production` |
| `windows-latest`  | 12      | `staging`    |
| `windows-latest`  | 12      | `production` |
| `windows-latest`  | 14      | `staging`    |
| `windows-latest`  | 14      | `production` |

El bloque `exclude` descarta las combinaciones recogidas a continuación. La segunda
entrada omite la versión y el entorno, por lo que elimina todas las combinaciones que
utilizan esa versión en Windows:

| Sistema operativo | Versión | Entorno      |
| ----------------- | ------- | ------------ |
| `macos-latest`    | 12      | `production` |
| `windows-latest`  | 16      | Cualquiera   |

El uso de matrices aporta eficiencia, ya que las combinaciones se ejecutan en paralelo,
y flexibilidad, al permitir descartar los casos innecesarios. Además, escala sin
esfuerzo: añadir una versión nueva a la lista basta para ampliar la cobertura sin
escribir un _workflow_ adicional.

## GitLab CI/CD

GitLab ofrece capacidades de integración y entrega continua de forma nativa. Su sistema
de CI/CD se configura mediante un archivo `.gitlab-ci.yml` situado en la raíz del
repositorio y se apoya en una arquitectura cliente-servidor. El GitLab Server actúa como
orquestador, mientras que los GitLab Runners ejecutan los _jobs_ y devuelven los
resultados al servidor.

### Estructura básica de un _pipeline_

Un _pipeline_ se compone de _stages_, o etapas, y de _jobs_, o tareas. Los _stages_
definen el orden de ejecución y los _jobs_ de un mismo _stage_ se ejecutan en paralelo
por defecto. La configuración comienza con la definición del flujo de trabajo, las
etapas y las variables globales.

El bloque `workflow.rules` controla cuándo se crea un _pipeline_ y evita ejecuciones
duplicadas. La directiva `image` establece la imagen de contenedor base que utilizan
todos los _jobs_.

???+ example "Configuración global de un _pipeline_"

    ```yaml linenums="1"
    workflow:
      rules:
        - if: $CI_PIPELINE_SOURCE == "merge_request_event"
        - if: $CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS
          when: never
        - if: $CI_COMMIT_BRANCH == "develop"

    stages:
      - lint
      - test
      - deploy

    variables:
      PATH_SRC: src
      PATH_TESTS: tests
      GIT_STRATEGY: fetch
      GIT_DEPTH: 1

    image: ghcr.io/astral-sh/uv:python3.11-bookworm
    ```

    Las reglas ejecutan el _pipeline_ en los eventos de _merge request_ y en los _pushes_
    a la rama `develop`, y descartan la ejecución sobre una rama que ya tiene una _merge
    request_ abierta. Las variables globales centralizan las rutas del proyecto y limitan
    la profundidad del clonado para acelerar la preparación de cada _job_.

!!! note "Imagen por defecto"

    Cuando no se especifica ninguna imagen, GitLab recurre a una por defecto, por lo que
    conviene declararla de forma explícita para garantizar la reproducibilidad del
    entorno. Las imágenes se obtienen de Docker Hub o de otros registros de contenedores
    y, como se indica en el capítulo de
    [contenedores](section_1_containers.md), resulta preferible fijar una versión
    concreta en lugar de recurrir a etiquetas como `latest`. La directiva `image`
    declarada a nivel global se aplica a todos los _jobs_, y para que uno concreto
    utilice otra imagen basta con redefinirla en su interior.

!!! warning "Asignación implícita de _stage_"

    Un _job_ que no declara ningún _stage_ se asigna automáticamente al _stage_ `test`.
    Además, los archivos creados o modificados durante la ejecución de un _job_ no se
    confirman en el repositorio, por lo que cualquier resultado que deba conservarse
    tiene que declararse como artefacto.

### _Jobs_ y configuración

Cada _job_ define una unidad de trabajo dentro del _pipeline_. Se compone de un bloque
`before_script` para la preparación del entorno, un bloque `script` con los comandos
principales y, de forma opcional, un bloque `after_script` para las tareas de limpieza.
La directiva `needs` establece dependencias explícitas entre _jobs_ y el bloque
`artifacts` permite compartir archivos entre ellos o conservarlos una vez finalizado el
_pipeline_.

???+ example "_Jobs_ con dependencias y artefactos"

    ```yaml linenums="1"
    quality_check:
      stage: lint
      before_script:
        - uv sync --only-group pipeline
      script:
        - uv run ruff format --check ${PATH_SRC}
        - uv run ruff check ${PATH_SRC}
        - uv run mypy ${PATH_SRC}

    unit_tests:
      stage: test
      needs:
        - quality_check
      before_script:
        - |
          if [ ! -d "${PATH_TESTS}" ]; then
            echo "${PATH_TESTS} no disponible. Omitiendo job..."
            exit 0
          fi
        - uv sync --all-extras
      script:
        - uv run pytest ${PATH_TESTS} --maxfail=1 --durations=0
          --cov=${PATH_SRC} --cov-report=xml:coverage.xml
      artifacts:
        paths:
          - coverage.xml
        expire_in: 1 hour
    ```

    El _job_ `unit_tests` solo se ejecuta tras la finalización correcta de
    `quality_check`, gracias a la directiva `needs`. Su bloque `before_script` comprueba
    que el directorio de pruebas exista antes de instalar las dependencias, y el bloque
    `artifacts` conserva el informe de cobertura durante una hora mediante `expire_in`.

Además de las variables declaradas en el archivo `.gitlab-ci.yml`, GitLab permite
definir variables de CI/CD desde los ajustes del repositorio, en la sección
`Settings > CI/CD > Variables`. Esta vía resulta indicada para almacenar valores
sensibles como _tokens_ de acceso, credenciales o direcciones de correo que no deben
figurar en el código fuente. Estas variables quedan disponibles de forma automática en
todos los _pipelines_ del repositorio y se referencian igual que las variables globales
del archivo YAML.

### Opciones de control de _jobs_

GitLab dispone de varias directivas para ajustar el comportamiento de un _job_. La
directiva `when: manual` exige una activación manual desde la interfaz, lo que resulta
adecuado para los despliegues a producción que requieren aprobación. La directiva
`retry` fija el número de reintentos ante un fallo, con un máximo de dos intentos
adicionales. Por último, `allow_failure: true` permite que un _job_ falle sin bloquear
el resto del _pipeline_, opción razonable en tareas no críticas como los análisis
opcionales.

### _Anchors_ y plantillas YAML

Para evitar la repetición de configuración, GitLab aprovecha las _anchors_ de YAML, que
definen bloques reutilizables. Un _job_ cuyo nombre comienza por un punto se considera
una plantilla oculta y no se ejecuta en el _pipeline_. El operador `&` crea el _anchor_
y la expresión `<<: *anchor` inserta en el _job_ todas las propiedades de la plantilla.
Las propiedades declaradas en el propio _job_ sobrescriben las heredadas.

???+ example "Plantilla completa con _anchor_"

    ```yaml linenums="1"
    .job_template: &anchor
      image: alpine
      before_script:
        - echo "Preparando entorno"

    job_1:
      <<: *anchor
      script:
        - echo "Ejecutando job_1"
    ```

    La plantilla oculta `.job_template` declara la imagen y el _script_ de preparación,
    mientras que `job_1` hereda toda esa configuración y aporta únicamente su bloque
    `script`.

El mecanismo también se aplica a fragmentos parciales de configuración, no solo a _jobs_
completos.

???+ example "_Anchor_ parcial"

    ```yaml linenums="1"
    .dependencies: &dependencies
      - echo "Instalando dependencias"

    job_1:
      image: alpine
      before_script: *dependencies
      script:
        - echo "Ejecutando job_1"
    ```

    En este caso el _anchor_ contiene una lista de comandos que se reutiliza como bloque
    `before_script` de cualquier _job_ que la necesite.

### _Extends_ frente a _anchors_

Junto a las _anchors_, GitLab proporciona la directiva `extends`, cuyo comportamiento
difiere en un aspecto importante. Mientras que las _anchors_ sobrescriben las
propiedades de forma completa, `extends` realiza una fusión profunda de los atributos y
combina las propiedades del _job_ con las de la plantilla. La diferencia resulta
relevante al trabajar con estructuras anidadas, ya que `extends` preserva las
propiedades que no se redefinen en los niveles internos.

???+ example "Herencia mediante _extends_"

    ```yaml linenums="1"
    nuevo_job:
      extends: .template
      stage: production
    ```

    El _job_ `nuevo_job` hereda todas las propiedades de la plantilla `.template` y
    redefine únicamente el _stage_ en el que se ejecuta.

### Modularización de la configuración

A medida que un proyecto crece resulta recomendable dividir el archivo `.gitlab-ci.yml`
en varios archivos para mejorar la organización y el mantenimiento. La directiva
`include` importa configuraciones desde distintas fuentes. Los archivos locales se
referencian desde la raíz del repositorio, mientras que los remotos deben ser accesibles
públicamente, salvo que pertenezcan a la misma instancia o grupo de GitLab, caso en el
que pueden ser privados.

???+ example "Inclusión de archivos locales y remotos"

    ```yaml linenums="1"
    include:
      - local: "ci/build.yml"
      - remote: "https://gitlab.com/grupo/proyecto/-/raw/main/ci/shared.yml"
    ```

    La clave `local` importa un archivo del propio repositorio y la clave `remote` toma la
    configuración de una dirección externa, lo que permite compartir definiciones entre
    varios proyectos.

### Catálogo de componentes CI/CD

GitLab dispone de un catálogo de componentes CI/CD reutilizables, equivalente al
Marketplace de GitHub Actions. Estos componentes se incorporan al _pipeline_ mediante la
directiva `include` con la clave `component` y pueden aceptar parámetros de entrada. Los
parámetros admitidos dependen de cada componente y se documentan en su repositorio
correspondiente.

???+ example "Uso de un componente del catálogo"

    ```yaml linenums="1"
    include:
      - component: gitlab.com/grupo/componente@version
        inputs:
          stage: build
    ```

    La referencia incluye la versión del componente, lo que fija su comportamiento, y el
    bloque `inputs` establece el _stage_ en el que se integran los _jobs_ que aporta.

### Selección de _runners_ y _tags_

Los _runners_ de GitLab se seleccionan mediante _tags_, que dirigen la ejecución de un
_job_ hacia un _runner_ con características determinadas, como un sistema operativo
concreto, un tipo de CPU o la disponibilidad de GPU. Los _tags_ disponibles dependen de
la configuración de la instancia de GitLab, ya sea _self-hosted_ o gestionada por
GitLab.

### Gestión de artefactos y caché

La directiva `dependencies: []` evita que un _job_ descargue los artefactos de los
_jobs_ anteriores, lo que reduce su tiempo de ejecución cuando esos artefactos no
resultan necesarios.

Para la caché de dependencias existen dos estrategias principales. La primera consiste
en dirigir los _jobs_ a un mismo _runner_ mediante _tags_, de modo que la caché persista
localmente. La segunda emplea un sistema de caché distribuido al que pueden acceder
varios _runners_. Conviene recordar que, con el Docker _executor_, cada _job_ se ejecuta
en un contenedor efímero que se destruye al finalizar, por lo que la caché debe
almacenarse fuera del contenedor.

!!! note "Docker-in-Docker"

    El Docker _executor_ admite además el modo Docker-in-Docker (DinD) mediante imágenes
    específicas como `docker:dind`, que habilita la ejecución de comandos de Docker dentro
    de los propios _jobs_. Esta capacidad resulta útil para construir, etiquetar y
    publicar imágenes de contenedores directamente desde el _pipeline_.

!!! note "Submódulos y permisos"

    En el caso de los submódulos de Git es necesario activar los permisos del _job token_
    para que un repositorio pueda acceder a otro durante el clonado, especialmente cuando
    ambos no pertenecen al mismo grupo.

### _Stages_ especiales

GitLab reserva dos _stages_ especiales. El _stage_ `.pre` se ejecuta antes que cualquier
otro y el _stage_ `.post` después de todos. Para que el _pipeline_ se cree correctamente
debe existir al menos un _job_ en un _stage_ regular, además de los declarados en `.pre`
o en `.post`.

Algunas imágenes de contenedor, como la de AWS CLI, definen un _entrypoint_
personalizado que interfiere con la ejecución de los comandos del _job_. El _stage_
`.pre` es el lugar natural para preparar el entorno en estos casos.

???+ example "Preparación del entorno en el _stage_ `.pre`"

    ```yaml linenums="1"
    preparar_entorno:
      stage: .pre
      image:
        name: amazon/aws-cli
        entrypoint: [""]
      script:
        - aws --version
    ```

    La sobrescritura del _entrypoint_ con un valor vacío devuelve el control al bloque
    `script`, de modo que los comandos se ejecutan tal como se declaran.

Los _pipelines_ descritos automatizan la validación y la publicación de los artefactos
de un proyecto, aunque su ejecución se limita al entorno efímero que proporciona el
_runner_. La gestión de esos artefactos una vez desplegados, repartidos entre varias
máquinas y con requisitos de escalado y resiliencia, se aborda en el capítulo de
[orquestación](section_3_orchestrators.md).
