---
icon: lucide/brain-circuit
authors: Daniel Bazo Correa
description:
    Agentes de propósito general con DeepAgents, que equipan a un modelo con sistema de
    archivos, entornos de ejecución aislados, permisos, memoria, _skills_ y estrategias
    de gestión del contexto.
title: DeepAgents
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Este capítulo presenta **DeepAgents**, un _framework_ construido sobre LangChain y
LangGraph que proporciona a un agente todo lo que necesita para abordar tareas largas y
abiertas. Recorre el concepto de arnés, las herramientas integradas, el entorno de
ejecución y sus _backends_, los permisos sobre el sistema de archivos, la ejecución de
comandos con aislamiento, la memoria, las _skills_ y las técnicas para gestionar el
contexto. La coordinación de varios agentes y el intérprete de código se tratan en el
capítulo siguiente. Presupone los capítulos de [LangChain](section_3_langchain.md) y de
[_middleware_](section_4_middleware.md). Los ejemplos se probaron con
`deepagents==0.7.34`.

## Bibliografía

- LangChain. (s.f.). _Deep Agents documentation_. <https://docs.langchain.com/>
- Agents.md. (s.f.). _AGENTS.md_. <https://agents.md/>

## Arnés de agentes

Un **arnés** (_harness_) es el conjunto de conexiones que un modelo necesita para
trabajar como agente. Igual que un arnés de seguridad ofrece los puntos de enganche,
este aporta al modelo las _skills_, la memoria, el _system prompt_, los subagentes, el
contexto y las herramientas. Un agente útil necesita tomar acciones, conectarse a datos,
manejar contextos grandes, paralelizar tareas, aceptar la supervisión de una persona y
mejorar con el tiempo, y DeepAgents cubre cada una de esas necesidades con un mecanismo
concreto.

| Necesidad del agente      | Mecanismo en DeepAgents                                   |
| :------------------------ | :-------------------------------------------------------- |
| Tomar acciones            | Herramientas integradas y propias, y entorno de ejecución |
| Conectarse a datos        | Sistema de archivos con _backends_ intercambiables y MCP  |
| Manejar contextos grandes | Resumen, descarga de resultados al disco y _skills_       |
| Paralelizar tareas        | Subagentes y programación desde un intérprete             |
| Supervisión humana        | `interrupt_on` y permisos de tipo `interrupt`             |
| Mejorar con el tiempo     | Memoria de largo plazo en archivos                        |

`create_deep_agent` devuelve el mismo tipo de objeto que `create_agent`, de modo que
conserva `invoke`, `stream`, el _checkpointer_ y los _threads_ de conversación. El
ejemplo mínimo solo necesita un modelo.

```python linenums="1"
from deepagents import create_deep_agent
from langchain.messages import HumanMessage

from modelos import crear_modelo

agente = create_deep_agent(model=crear_modelo())

respuesta = agente.invoke({"messages": [HumanMessage("¿Cuál es la capital de España?")]})
print(respuesta["messages"][-1].content)
```

Conviene indicar siempre el modelo de forma explícita, ya que depender del modelo por
defecto está desaconsejado. El _system prompt_ se pasa en `system_prompt` y funciona
como en LangChain. Sin él, el modelo se comporta según su configuración por defecto, de
forma genérica, sin una persona definida ni un alcance y unas limitaciones concretos.

## Herramientas integradas

Sin configuración adicional, un agente de DeepAgents dispone de herramientas para el
sistema de archivos y para delegar tareas. El parámetro `tools` es **aditivo**: las
herramientas propias se suman a las integradas y no las sustituyen.

| Herramienta                            | Función                                                                   |
| :------------------------------------- | :------------------------------------------------------------------------ |
| `ls`, `glob`, `grep`                   | Listan archivos, los buscan por patrón y buscan texto en ellos.           |
| `read_file`, `write_file`, `edit_file` | Leen, crean y modifican archivos.                                         |
| `delete`                               | Elimina archivos.                                                         |
| `task`                                 | Delega un trabajo en un subagente.                                        |
| `execute`                              | Ejecuta comandos de _shell_. Solo existe con un _backend_ que lo soporte. |
| `write_todos`                          | Mantiene una lista de tareas. Solo existe con `TodoListMiddleware`.       |

## Entorno de ejecución y _backends_

Un agente trabaja dentro de un **entorno**. El sistema de archivos está siempre presente
y sirve para leer y escribir. Una _shell_ para ejecutar comandos y un intérprete para
ejecutar código dentro del bucle del agente son opcionales. Lo que hace configurable ese
entorno es el **_backend_**, la capa a la que las herramientas de archivos delegan cada
operación.

| _Backend_           | Dónde se guardan los archivos                                         |
| :------------------ | :-------------------------------------------------------------------- |
| `StateBackend`      | En el estado del _thread_ actual, por defecto y no persistente.       |
| `FilesystemBackend` | En un directorio del disco local.                                     |
| `StoreBackend`      | En un almacén de LangGraph, persistente y compartido entre _threads_. |
| `CompositeBackend`  | En varios _backends_, según el prefijo de la ruta.                    |
| _Backend_ propio    | En un servicio como S3 o GitHub, implementando el protocolo.          |

Con un único _backend_, todas las rutas van al mismo destino. Con un `CompositeBackend`,
un _backend_ por defecto atiende las rutas generales y cada prefijo registrado se
redirige a otro.

```mermaid
flowchart LR
    subgraph Único["Backend único"]
        A1["Agente"] --> S1["StateBackend"] --> T1["Estado del thread"]
    end
    subgraph Compuesto["Backend compuesto"]
        A2["Agente"] --> C["CompositeBackend"]
        C -->|"Rutas generales"| T2["Estado del thread"]
        C -->|"/assets/"| D["Disco local"]
    end
```

La diferencia es práctica. Con el _backend_ por defecto, si un agente escribe un
documento en el _thread_ A y después se abre el _thread_ B para leerlo, el archivo no se
encuentra, porque vive en el estado del _thread_ A y ese estado no es persistente. Para
conservar archivos entre conversaciones se enruta una ruta concreta hacia un _backend_
persistente. El parámetro `virtual_mode=True` de `FilesystemBackend` expone el
directorio indicado como la raíz `/` del agente e impide salir de él.

### Permisos

Las reglas `FilesystemPermission` restringen qué operaciones puede hacer el agente sobre
qué rutas. Cada regla indica las operaciones, los patrones de ruta y un modo que puede
ser `allow` (por defecto), `deny` o `interrupt`, que pausa la llamada hasta que una
persona la apruebe. Las reglas se evalúan **en orden y la primera coincidencia gana**,
de modo que las reglas más específicas deben preceder a las más generales. En el
ejemplo, el agente puede escribir en `/assets/` y en ninguna otra ruta, y lo hace con la
ayuda de un _backend_ compuesto que guarda esa carpeta en el disco.

```python linenums="1"
from pathlib import Path

from deepagents import FilesystemPermission, create_deep_agent
from deepagents.backends import CompositeBackend, FilesystemBackend, StateBackend
from langchain.messages import HumanMessage
from langgraph.checkpoint.memory import InMemorySaver

from modelos import crear_modelo

DIRECTORIO_ASSETS = Path("assets")
DIRECTORIO_ASSETS.mkdir(exist_ok=True)

agente = create_deep_agent(
    model=crear_modelo(),
    checkpointer=InMemorySaver(),
    backend=CompositeBackend(
        default=StateBackend(),
        routes={
            "/assets/": FilesystemBackend(
                root_dir=str(DIRECTORIO_ASSETS), virtual_mode=True
            )
        },
    ),
    permissions=[
        FilesystemPermission(operations=["write"], paths=["/assets/**"], mode="allow"),
        FilesystemPermission(operations=["write"], paths=["/**"], mode="deny"),
    ],
)

peticion = (
    "Escribe un archivo en Markdown que describa el interés compuesto en la carpeta "
    "de assets, con el nombre 'interes_compuesto.md'."
)
respuesta = agente.invoke(
    {"messages": [HumanMessage(peticion)]},
    config={"configurable": {"thread_id": "1"}},
)
print(respuesta["messages"][-1].content)
```

Si se invirtiera el orden de las dos reglas, la denegación general se evaluaría primero
y ninguna escritura sería posible, tal como se comprobó al ejecutar ambas variantes. Los
permisos se aplican a las herramientas de archivos integradas, no a lo que un comando de
_shell_ pueda hacer sobre el disco, de modo que no sustituyen al aislamiento descrito en
la sección siguiente. Los subagentes heredan las reglas del agente principal salvo que
definan las suyas.

## Comandos de _shell_ y aislamiento

Para que un agente compile o ejecute programas necesita la herramienta `execute`, que
aparece cuando el _backend_ implementa la capacidad de ejecutar comandos. El
`LocalShellBackend` es el más sencillo, ya que ejecuta los comandos directamente en la
máquina que corre el agente.

```python linenums="1"
from pathlib import Path

from deepagents import create_deep_agent
from deepagents.backends.local_shell import LocalShellBackend
from langchain.messages import HumanMessage

from modelos import crear_modelo

DIRECTORIO_TRABAJO = Path("assets")
DIRECTORIO_TRABAJO.mkdir(exist_ok=True)

agente = create_deep_agent(
    model=crear_modelo(),
    backend=LocalShellBackend(root_dir=DIRECTORIO_TRABAJO, virtual_mode=True),
    system_prompt="Eres un programador de C. El compilador gcc está instalado.",
)

peticion = "Crea un programa 'Hola mundo' en C, compílalo y ejecútalo."
respuesta = agente.invoke({"messages": [HumanMessage(peticion)]})
print(respuesta["messages"][-1].content)
```

!!! danger

    Con `LocalShellBackend` los comandos se ejecutan con los permisos del _host_ y
    pueden acceder a cualquier ruta, aunque las herramientas de archivos estén
    confinadas por `virtual_mode`. Un modelo equivocado o manipulado podría borrar datos
    o filtrar secretos, por lo que este _backend_ no es viable en producción.

La alternativa es un **_sandbox_**, un entorno aislado que puede ser un contenedor, una
máquina virtual o un servicio remoto. Existen dos disposiciones. En la primera, el
propio agente se ejecuta dentro del _sandbox_, y por tanto la llamada a la API del
modelo sale desde allí. En la segunda, el agente permanece fuera y el _sandbox_ se usa
como una herramienta, de modo que solo el comando se ejecuta aislado.

```mermaid
flowchart TD
    F["Herramientas de archivos"] --> B["Backend"]
    B --> L["LocalShellBackend<br />Ejecuta en el host"]
    B --> S["Backend de sandbox<br />Ejecuta aislado"]
    L --> E["Herramienta execute"]
    S --> E
```

Cuando el agente trabaja dentro de un _sandbox_, este no debe llamar directamente a las
API con las credenciales. Un **_proxy_ de autenticación** en el _host_ recibe la
petición, inyecta los secretos y la reenvía, con lo que las claves nunca residen dentro
del entorno aislado. Además, los recursos del _sandbox_ deben liberarse siempre al
terminar de usarlo, porque un contenedor olvidado sigue consumiendo cómputo.

## Memoria

DeepAgents distingue dos tipos de memoria. La de **corto plazo** es el histórico de
mensajes de un único _thread_, que gestiona automáticamente el _checkpointer_, no
persiste por sí misma y no se comparte entre _threads_, tal como se describió en el
capítulo de LangChain. La de **largo plazo** es lo que el agente aprende y debe llevar
de una conversación a otra, como las preferencias del usuario o las convenciones del
proyecto. Es persistente y se guarda en el sistema de archivos.

En DeepAgents la memoria de largo plazo es **texto plano en el sistema de archivos del
agente**, escrito normalmente en Markdown en un archivo `AGENTS.md`, siguiendo la
convención del mismo nombre. El parámetro `memory` recibe las rutas de esos archivos y
activa un _middleware_ que los carga siempre en el _prompt_. Las rutas son relativas a
las del _backend_, de modo que se combina con un `CompositeBackend` en el que las rutas
normales van al _backend_ por defecto y una ruta concreta, como `/memory/`, se almacena
de forma persistente.

```python linenums="1"
from pathlib import Path

from deepagents import create_deep_agent
from deepagents.backends import CompositeBackend, FilesystemBackend, StateBackend
from langchain.messages import HumanMessage

from modelos import crear_modelo

DIRECTORIO_MEMORIA = Path("memory")
DIRECTORIO_MEMORIA.mkdir(exist_ok=True)

archivo_memoria = DIRECTORIO_MEMORIA / "AGENTS.md"
if not archivo_memoria.exists():
    archivo_memoria.write_text(
        "# Guía del proyecto\n\n"
        "- Todas las funciones llevan anotaciones de tipo.\n"
        "- Se usa `pathlib.Path` para las rutas, no `os.path`.\n",
        encoding="utf-8",
    )

agente = create_deep_agent(
    model=crear_modelo(),
    system_prompt="Eres un asistente de código especializado en Python.",
    backend=CompositeBackend(
        default=StateBackend(),
        routes={
            "/memory/": FilesystemBackend(
                root_dir=DIRECTORIO_MEMORIA, virtual_mode=True
            )
        },
    ),
    memory=["/memory/AGENTS.md"],
)

peticion = "El equipo ha cambiado a ruff para el linting. Actualiza la memoria."
agente.invoke({"messages": [HumanMessage(peticion)]})
print(archivo_memoria.read_text(encoding="utf-8"))
```

El agente actualiza la memoria editando el archivo con sus herramientas, y como este
vive en el disco el cambio persiste entre ejecuciones. Para aislar la memoria por
usuario se usa un `StoreBackend` respaldado por un almacén de LangGraph, cuyo espacio de
nombres (_namespace_) se calcula a partir del contexto de la ejecución. El agente solo
ve los archivos del usuario que figura en el contexto, que se pasa en cada `invoke`.

```python linenums="1"
from dataclasses import dataclass

from deepagents import create_deep_agent
from deepagents.backends import CompositeBackend, StateBackend, StoreBackend
from langgraph.checkpoint.memory import InMemorySaver
from langgraph.store.memory import InMemoryStore

from modelos import crear_modelo


@dataclass
class Contexto:
    """Contexto de ejecución con el identificador del usuario."""

    user_id: str


agente = create_deep_agent(
    model=crear_modelo(),
    checkpointer=InMemorySaver(),
    store=InMemoryStore(),
    context_schema=Contexto,
    backend=CompositeBackend(
        default=StateBackend(),
        routes={
            "/memories/": StoreBackend(
                namespace=lambda runtime: ("memory", runtime.context.user_id)
            )
        },
    ),
    memory=["/memories/AGENTS.md"],
)

# Cada invocación aporta el usuario cuyo espacio de memoria se lee y se escribe
# agente.invoke({...}, config={...}, context=Contexto(user_id="ana"))
```

!!! warning

    Ni `InMemorySaver` ni `InMemoryStore` son persistentes, porque guardan los datos en
    estructuras de Python dentro de la memoria RAM del proceso. Sirven para desarrollo
    local y pruebas, pero en producción deben sustituirse por implementaciones
    respaldadas por una base de datos.

## _Skills_

Una **_skill_** es una carpeta con un archivo `SKILL.md` y, de forma opcional, material
de referencia, que enseña al agente a realizar una tarea concreta. La carga es
**progresiva** (_progressive disclosure_): al iniciar, el agente solo recibe el nombre y
la descripción de cada _skill_, lo justo para saber que existe y cuándo usarla, y lee el
contenido completo únicamente cuando la tarea lo requiere. De este modo se pueden tener
muchas _skills_ sin saturar el contexto.

```plaintext linenums="1"
skills/
└── estandares-python/
    ├── SKILL.md
    └── references/
        └── estandares-completos.md
```

```plaintext linenums="1" title="skills/estandares-python/SKILL.md"
---
name: estandares-python
description:
    Estándares de código Python del proyecto. Úsala al escribir o revisar código.
---

# Estándares de Python

- Anotaciones de tipo obligatorias en todas las firmas.
- Docstrings con el formato de Google.

El detalle completo está en `references/estandares-completos.md`.
```

Las _skills_ se registran con el parámetro `skills`, que recibe la ruta de la carpeta
dentro del _backend_.

```python linenums="1"
from pathlib import Path

from deepagents import create_deep_agent
from deepagents.backends import FilesystemBackend

from modelos import crear_modelo

agente = create_deep_agent(
    model=crear_modelo(),
    backend=FilesystemBackend(root_dir=Path("."), virtual_mode=True),
    skills=["/skills"],
)
```

## Gestión del contexto

Cada agente tiene una ventana de contexto limitada, y las tareas largas la desbordan si
no se evita que entre información innecesaria. **Ingeniería de contexto** (_context
engineering_) es el conjunto de técnicas para mejorar el contexto del modelo una vez que
este ha adquirido el conocimiento, mientras que la **recuperación** (_retrieval_) se
ocupa de traer la información adecuada. DeepAgents aplica varias estrategias a la vez.

1. **Resumen**: Los mensajes antiguos se sustituyen por un resumen. El umbral por
   defecto se sitúa en torno al 85 % de la ventana del modelo, y cuando se supera se
   resumen los mensajes anteriores a los más recientes antes de la siguiente petición,
   que queda encolada mientras tanto. El historial original se guarda en
   `/conversation_history/`.
2. **Descarga de contexto**: Los resultados grandes de las herramientas se escriben en
   el sistema de archivos, en `/large_tool_results/id_de_la_llamada`, y el contexto
   recibe solo un puntero compacto. Lo mismo ocurre con un mensaje del usuario muy
   extenso, como un documento pegado, que se guarda en `/conversation_history/`. Un
   _middleware_ intercepta la entrada antes de que llegue al contexto cuando su
   contenido es muy grande.
3. **_Skills_**: Cargan la información solo cuando hace falta, según se vio en la
   sección anterior.
4. **Memoria**: Mantiene lo que debe persistir entre conversaciones, sin repetirlo en el
   historial.
5. **_Prompt caching_**: Reduce el coste de repetir el prefijo del _prompt_, aunque
   depende del modelo utilizado.

Para buscar información dentro de los archivos existen dos enfoques complementarios.
`grep` encuentra coincidencias exactas de palabras clave, lo que funciona bien con
términos concretos pero obliga a probar sinónimos si no se conoce la palabra exacta. Un
almacén vectorial (_vector store_) busca por significado, normalmente mediante
_embeddings_ y una medida como la **similitud del coseno** entre el vector $\mathbf{a}$
de la consulta y el vector $\mathbf{b}$ de cada fragmento:

$$
\cos(\theta) = \frac{\mathbf{a} \cdot \mathbf{b}}{\Vert \mathbf{a} \Vert \, \Vert \mathbf{b} \Vert}
$$

En ambos casos conviene que el agente reciba la ruta de los archivos y lea únicamente lo
que necesita, en lugar de recibir el documento completo, y que tras un `grep` conserve
el texto circundante para tener el contexto del fragmento, como el capítulo al que
pertenece. Cuando los datos cambian con frecuencia, la fuente debe ser una API o un
servidor MCP en tiempo real, como el descrito en el [capítulo de MCP](section_5_mcp.md),
porque de lo contrario el agente trabajaría con copias antiguas.

## Aprobación humana

DeepAgents reutiliza el `HumanInTheLoopMiddleware` del capítulo anterior mediante el
parámetro `interrupt_on`, y admite los mismos tipos de decisión, `approve`, `edit`,
`reject` y `respond`. Los permisos de archivos con modo `interrupt` instalan además ese
_middleware_ de forma automática.

```python linenums="1"
from deepagents import create_deep_agent
from langgraph.checkpoint.memory import InMemorySaver

from modelos import crear_modelo

agente = create_deep_agent(
    model=crear_modelo(),
    checkpointer=InMemorySaver(),
    # Pausa antes de cada edición para que una persona la revise
    interrupt_on={"edit_file": True},
)
```

El siguiente capítulo describe cómo [coordinar varios agentes](section_7_subagents.md) y
cómo programar flujos de trabajo desde un intérprete de código.
