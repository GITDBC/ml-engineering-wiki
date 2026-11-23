---
icon: lucide/book-open
authors: Daniel Bazo Correa
description:
    Conceptos para integrar modelos de lenguaje en aplicaciones, desde el protocolo de
    las API y los parámetros de generación hasta la salida estructurada, el coste por
    _token_ y la caché de _prompts_.
title: Fundamentos del desarrollo con modelos de lenguaje
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Este capítulo reúne los conceptos que condicionan el diseño de cualquier aplicación que
consuma un modelo de lenguaje (_Large Language Model_, LLM) a través de una API. Se
describen la forma en que se comunica un cliente con el modelo, los parámetros que
gobiernan la generación, la validación de la salida estructurada, el coste asociado al
consumo de _tokens_ y las distintas cachés que lo reducen. Los capítulos siguientes
aplican estas ideas con LangChain y DeepAgents. Se presupone la noción de modelo
generativo del capítulo de
[IA generativa](../03_deep_learning/section_7_generative_ai.md).

## Bibliografía

- LangChain. (s.f.). _LangChain documentation_. <https://docs.langchain.com/>
- OpenAI. (s.f.). _tiktoken_. GitHub. <https://github.com/openai/tiktoken>

## Los modelos como servicio

Un modelo de lenguaje se consume habitualmente como un servicio remoto. El cliente envía
una lista de **mensajes**, cada uno con un rol (`system`, `user`, `assistant` o `tool`),
y recibe a cambio un mensaje de respuesta junto con metadatos como el número de _tokens_
consumidos. El rol `system` contiene el **_system prompt_**, las instrucciones que
definen la personalidad, el alcance y las limitaciones del modelo, y que forman parte de
cada llamada. Si no se proporciona, el modelo se comporta de forma genérica, sin una
persona definida.

Estas API son, por defecto, **_stateless_**: el servidor no conserva nada entre dos
llamadas, de modo que el cliente debe reenviar el historial completo en cada petición.
Existe la alternativa de que sea el servidor quien guarde el estado y el cliente se
limite a referenciarlo.

| Modelo de estado            | Quién conserva el historial     | Consecuencia                                                                  |
| :-------------------------- | :------------------------------ | :---------------------------------------------------------------------------- |
| _Stateless_ (cliente)       | El cliente, que lo reenvía todo | Control total y portabilidad entre proveedores, pero el coste crece por turno |
| _Server managed_ (servidor) | El servidor, que lo referencia  | Peticiones más cortas, a cambio de depender de un proveedor concreto          |

Para llegar al modelo existen varias rutas. El **SDK nativo** del proveedor es la opción
más simple y la que primero incorpora las novedades. Una **pasarela** (_gateway_) como
OpenRouter o LiteLLM expone una única interfaz para muchos modelos y añade
funcionalidades transversales como los _fallbacks_ entre proveedores o los límites de
tasa (_rate limits_). Un servicio gestionado de una nube pública, como Amazon Bedrock,
ofrece varios modelos tras la autenticación y la facturación de la propia nube, tal como
se describe en el capítulo de [AWS](../../05_infrastructure/02_cloud/section_2_aws.md).
Por último, un servidor propio, como el montado en el capítulo de
[modelos locales](section_2_local_llms.md), suele publicar una API compatible con la de
OpenAI, de modo que el mismo código cliente sirve para todas las rutas cambiando
únicamente la dirección base y el nombre del modelo.

### Credenciales

La clave de una API no debe aparecer en el código, porque terminaría en el repositorio.
En desarrollo, lo adecuado es leerla de una variable de entorno, cargada desde un
archivo `.env` excluido del control de versiones con una biblioteca como
`python-dotenv`, presentada en el capítulo de
[bibliotecas de Python](../../03_programming/01_python/section_5_libraries.md). En
producción, el valor se obtiene de un gestor de secretos como AWS Secrets Manager, que
además permite rotarlo sin tocar la aplicación.

## Diseño del _system prompt_

El _system prompt_ es la principal palanca para acotar el comportamiento del modelo, y
un _prompt_ eficaz suele cubrir los mismos elementos. Define el **rol y el alcance**, es
decir, qué es el asistente y de qué trata. Fija el **idioma y el tono** de las
respuestas. Obliga a **apoyarse en las herramientas** y a no inventar datos, de modo que
ante un fallo o una ausencia de resultados el asistente lo indique de forma explícita.
Establece cómo tratar la **incertidumbre**, con la obligación de señalar lo que no puede
garantizar. Marca los **límites**, por ejemplo la prohibición de ofrecer asesoramiento
profesional regulado, y la dependencia de la **jurisdicción** cuando las normas varían
de un país a otro. Por último, indica el **formato de salida** adecuado al destino: una
respuesta que se muestra en una terminal que no interpreta Markdown no debe contener
asteriscos, almohadillas ni tablas.

```python linenums="1"
PROMPT_ASISTENTE_FINANCIERO: str = (
    "Eres un asistente especializado en finanzas. Explicas conceptos, analizas "
    "situaciones económicas y respondes consultas con precisión y claridad.\n\n"
    "Responde en el idioma del usuario, con un tono formal y directo, y define "
    "los términos que puedan ser nuevos, como liquidez o apalancamiento.\n\n"
    "Cuando la consulta se refiera a un valor bursátil, usa las herramientas "
    "disponibles antes de responder. No inventes cotizaciones: si una herramienta "
    "falla o no devuelve datos, indícalo.\n\n"
    "Explicita los supuestos de tus cálculos, como la tasa o el horizonte "
    "temporal. Si no puedes garantizar una cifra, recomienda confirmarla en una "
    "fuente oficial.\n\n"
    "No ofrezcas asesoramiento de inversión personalizado ni garantices "
    "rentabilidades. Si la norma depende del país, pregunta por la jurisdicción.\n\n"
    "Tu respuesta se muestra en una terminal sin Markdown: no uses asteriscos, "
    "almohadillas, tablas ni listas con guiones. Enumera con 1. 2. 3."
)
```

Un _prompt_ largo tiene un coste en cada llamada, porque forma parte de toda la entrada,
pero su prefijo es estable y por tanto un candidato ideal para la caché de _prompts_
descrita al final del capítulo.

## Tokens y ventana de contexto

El modelo no procesa caracteres ni palabras, sino **_tokens_**, fragmentos de texto
producidos por un tokenizador. Tanto el coste como el límite de capacidad se miden en
_tokens_. La **ventana de contexto** es el número máximo de _tokens_ que caben en una
llamada, sumando la entrada y la salida, y todo lo que se envía al modelo ocupa espacio
en ella: el _system prompt_, el historial, los documentos y las definiciones de las
herramientas.

La biblioteca `tiktoken` cuenta los _tokens_ de un texto con los tokenizadores de
OpenAI. Para otros modelos el resultado es solo una estimación, pero resulta suficiente
para presupuestar el consumo y comparar alternativas de _prompt_.

```python linenums="1"
import tiktoken

# Tokenizador usado por varias familias de modelos de OpenAI
codificador = tiktoken.get_encoding("cl100k_base")

texto: str = "La caché de prompts reduce la latencia y el coste."
print(len(codificador.encode(texto)))
```

```plaintext title="Expected output"
14
```

## Parámetros de generación

Un modelo de lenguaje produce, en cada paso, una puntuación (_logit_) $z_i$ por cada
_token_ $i$ del vocabulario, que se convierte en probabilidad mediante la función
_softmax_ con **temperatura** $T$:

$$
p_i = \frac{\exp(z_i / T)}{\sum_j \exp(z_j / T)}
$$

Una temperatura baja concentra la probabilidad en los _tokens_ más probables y produce
respuestas deterministas. Una temperatura alta aplana la distribución y favorece
respuestas creativas pero menos predecibles. El resto de parámetros acotan la
generación. El **número máximo de _tokens_** limita la longitud de la respuesta, el
_timeout_ fija cuánto se espera al modelo antes de cancelar la petición y los
**reintentos** (_max retries_) repiten las peticiones que fallan.

Otros dos parámetros, _top-k_ y _top-p_, recortan el vocabulario antes de muestrear. El
primero conserva los $k$ _tokens_ más probables. El segundo conserva el menor conjunto
$S$ de _tokens_ cuya probabilidad acumulada alcanza el umbral $p$. En ambos casos las
probabilidades restantes se **renormalizan** para que la distribución vuelva a sumar 1:

$$
\tilde{p}_i = \frac{p_i}{\sum_{j \in S} p_j} \quad \text{si } i \in S, \qquad
\tilde{p}_i = 0 \quad \text{en otro caso}
$$

La siguiente función implementa los tres mecanismos sobre un vocabulario de cuatro
_tokens_ para comprobar su efecto.

```python linenums="1"
import numpy as np


def distribucion_final(
    logits: np.ndarray,
    temperatura: float = 1.0,
    top_k: int | None = None,
    top_p: float | None = None,
) -> np.ndarray:
    """Calcula la distribución de probabilidad tras aplicar el muestreo.

    Args:
        logits: Puntuaciones sin normalizar de cada token del vocabulario.
        temperatura: Divisor de los logits antes del softmax.
        top_k: Número máximo de tokens que se conservan.
        top_p: Probabilidad acumulada mínima que debe cubrir el conjunto.

    Returns:
        Probabilidades de cada token, que suman 1.
    """
    exponentes = np.exp((logits - logits.max()) / temperatura)
    probabilidades = exponentes / exponentes.sum()

    orden = np.argsort(probabilidades)[::-1]
    conservar = np.ones_like(probabilidades, dtype=bool)

    if top_k is not None:
        conservar[orden[top_k:]] = False

    if top_p is not None:
        acumulada = np.cumsum(probabilidades[orden])
        # Se conserva el menor conjunto cuya masa alcanza top_p
        corte = int(np.searchsorted(acumulada, top_p)) + 1
        conservar[orden[corte:]] = False

    filtradas = np.where(conservar, probabilidades, 0.0)
    return filtradas / filtradas.sum()


logits = np.array([3.0, 2.0, 1.0, 0.0])

print(np.round(distribucion_final(logits), 3))
print(np.round(distribucion_final(logits, temperatura=0.5), 3))
print(np.round(distribucion_final(logits, top_k=2), 3))
print(np.round(distribucion_final(logits, top_p=0.8), 3))
```

```plaintext title="Expected output"
[0.644 0.237 0.087 0.032]
[0.865 0.117 0.016 0.002]
[0.731 0.269 0.    0.   ]
[0.731 0.269 0.    0.   ]
```

Bajar la temperatura a 0.5 concentra el 86 % de la probabilidad en el primer _token_.
Con _top-k_ igual a 2 solo sobreviven los dos primeros y sus probabilidades se reescalan
a 0.731 y 0.269. El _top-p_ de 0.8 produce el mismo resultado porque los dos primeros
_tokens_ ya acumulan un 88 % de la masa. Las API de los proveedores aplican siempre esta
renormalización, por lo que la salida sigue siendo una distribución válida.

## Salida estructurada

Muchas aplicaciones necesitan que el modelo devuelva datos y no prosa, por ejemplo un
objeto JSON que otro componente procesa. Algunos proveedores, como Google AI Studio,
permiten indicar un **esquema** de salida para que la respuesta lo respete, ya sea
mediante un modo JSON, una herramienta cuyo argumento es el esquema o una opción de
formato de respuesta. Esa garantía depende del modelo y de la API, de modo que la salida
siempre debe **verificarse** antes de usarla.

El enfoque más robusto es tratar el esquema como un **contrato**. La entrada se compone
de los datos y del esquema que describe la forma de la respuesta esperada, y la salida
es un documento JSON que debe validarse contra ese esquema. Si la validación falla, la
aplicación puede reintentar la llamada o devolver un error controlado. Pydantic, citada
en el capítulo de bibliotecas de Python, cubre ambos lados: genera el esquema JSON a
partir de una clase y valida el texto recibido.

```python linenums="1"
from pydantic import BaseModel, Field, ValidationError


class InfoCapital(BaseModel):
    """Datos de la capital de un país."""

    nombre: str = Field(description="Nombre de la capital")
    pais: str = Field(description="País al que pertenece")


# Esquema que se enviaría al modelo como contrato de salida
print(sorted(InfoCapital.model_json_schema()["properties"]))

respuesta_valida: str = '{"nombre": "París", "pais": "Francia"}'
print(InfoCapital.model_validate_json(respuesta_valida))

respuesta_invalida: str = '{"nombre": "París"}'
try:
    InfoCapital.model_validate_json(respuesta_invalida)
except ValidationError as error:
    print(error.errors()[0]["type"], error.errors()[0]["loc"])
```

```plaintext title="Expected output"
['nombre', 'pais']
nombre='París' pais='Francia'
missing ('pais',)
```

## Coste y _FinOps_

La facturación de un modelo alojado por un proveedor depende del número de _tokens_ de
entrada y de salida, y se cobra **toda** la entrada de cada llamada: el _system prompt_,
el historial, los documentos y los esquemas de las herramientas. Por eso el coste de una
conversación crece con cada turno en un cliente _stateless_. A este coste se suman el
presupuesto de contexto, la calidad exigida y la latencia, que depende a su vez del
número de _tokens_ a procesar, del modelo elegido y de la carga del servicio.

**FinOps** es la disciplina que gestiona el coste de la infraestructura en la nube, y su
herramienta central es la **economía unitaria**: medir cuánto cuesta cada unidad de
valor, como una petición, un usuario o una tarea resuelta, en lugar de mirar solo la
factura total. Con una tarifa por millón de _tokens_, el coste de una petición es

$$
C = \frac{n_{\text{ent}} \, p_{\text{ent}} + n_{\text{cache}} \, p_{\text{cache}} + n_{\text{sal}} \, p_{\text{sal}}}{10^{6}}
$$

donde $n$ son los _tokens_ de entrada no cacheados, de entrada cacheados y de salida, y
$p$ sus precios por millón. La función siguiente lo calcula con una tarifa ficticia.

```python linenums="1"
from dataclasses import dataclass


@dataclass(frozen=True)
class Tarifa:
    """Precio en dólares por millón de tokens de un modelo."""

    entrada: float
    salida: float
    entrada_cacheada: float


def coste_peticion(
    tarifa: Tarifa,
    tokens_entrada: int,
    tokens_salida: int,
    tokens_cacheados: int = 0,
) -> float:
    """Calcula el coste en dólares de una petición.

    Args:
        tarifa: Precios por millón de tokens.
        tokens_entrada: Tokens de entrada totales, incluidos los cacheados.
        tokens_salida: Tokens generados por el modelo.
        tokens_cacheados: Parte de la entrada servida desde la caché.

    Returns:
        Coste total de la petición.
    """
    nuevos = tokens_entrada - tokens_cacheados
    total = (
        nuevos * tarifa.entrada
        + tokens_cacheados * tarifa.entrada_cacheada
        + tokens_salida * tarifa.salida
    )
    return total / 1_000_000


tarifa = Tarifa(entrada=3.0, salida=15.0, entrada_cacheada=0.30)

print(f"{coste_peticion(tarifa, 20_000, 500):.4f}")
print(f"{coste_peticion(tarifa, 20_000, 500, tokens_cacheados=18_000):.4f}")
```

```plaintext title="Expected output"
0.0675
0.0189
```

Reutilizar el mismo prefijo en la entrada reduce el coste de la petición de ejemplo a
casi una cuarta parte. Las palancas de ahorro más habituales son la caché de _prompts_,
el enrutado de las tareas sencillas a modelos más baratos, el procesamiento por lotes
(_batch_) de las peticiones que no son urgentes y el aprovechamiento de las franjas
horarias con tarifas reducidas. Con infraestructura propia no existe factura por
_token_, pero el coste se traslada a la capacidad de cómputo y a la latencia, por lo que
medir el consumo con `tiktoken` sigue siendo útil para estimar y optimizar.

## Cachés en aplicaciones con modelos

Con el nombre de caché se designan tres mecanismos distintos que conviene no mezclar.

| Caché               | Dónde reside                        | Qué guarda                                          |
| :------------------ | :---------------------------------- | :-------------------------------------------------- |
| _Prompt caching_    | Servidor del proveedor              | El prefijo ya procesado de un _prompt_              |
| Caché de respuestas | Cliente o infraestructura propia    | La salida completa para una entrada idéntica        |
| _KV cache_          | Motor de inferencia, local o remoto | Claves y valores de atención de los _tokens_ vistos |

El **_prompt caching_** del proveedor reduce la latencia, el cómputo y, por tanto, el
coste cuando varias llamadas comparten un prefijo largo, como el _system prompt_, las
herramientas o las _skills_. Su disponibilidad y su formato dependen del modelo y de la
API, y bibliotecas como DeepAgents incluyen _middleware_ específico para cachear los
modelos de Anthropic. La caché de respuestas, en cambio, se implementa en la propia
aplicación y evita la llamada al modelo cuando la entrada se repite. La _KV cache_ es un
detalle de la inferencia que interesa a quien opera el servidor del modelo, no a quien
lo consume.

Para aprovechar el _prompt caching_ conviene situar al principio de la entrada lo que no
cambia entre llamadas y al final lo variable, ya que la coincidencia se evalúa sobre el
prefijo.

El [siguiente capítulo](section_2_local_llms.md) describe cómo montar un servidor propio
de modelos de lenguaje, la ruta alternativa a los proveedores externos.
