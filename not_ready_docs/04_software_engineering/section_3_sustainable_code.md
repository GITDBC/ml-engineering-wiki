---
authors: Daniel Bazo Correa
description:
    Principios de diseño, código limpio, modularidad, gestión de la complejidad,
    arquitectura y prácticas de desarrollo sostenible en software.
title: Diseño y código sostenible
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Este capítulo recoge los principios que permiten escribir código sostenible, entendido
como aquel que puede leerse, modificarse y ampliarse con un esfuerzo razonable a lo
largo del tiempo. El recorrido parte de las convenciones básicas de limpieza y
organización, continúa con el análisis de la complejidad como problema central del
diseño de _software_ y con las técnicas de modularidad, documentación y gestión de
errores que la contienen, y concluye con las decisiones de mayor alcance relativas a la
arquitectura, el versionado y las metodologías de desarrollo guiadas por pruebas.

## Bibliografía

- Ousterhout, J. (2021). _A Philosophy of Software Design_ (2.ª ed.). Yaknyam Press.
- Van Rossum, G. et al. (2001). _PEP 8. Style Guide for Python Code_.
  <https://pep8.org/>
- Tan, D. (2024). _Effective Machine Learning Teams_. O'Reilly Media.
  <https://www.oreilly.com/library/view/effective-machine-learning/9781098144623/>

## Principios de código limpio

El desarrollo de un proyecto debe realizarse bajo una estructura de código clara y
sostenible, utilizando herramientas y metodologías que garanticen su organización y
limpieza. Estas prácticas resultan fundamentales durante el desarrollo, la puesta en
producción y la evolución del proyecto, con independencia del lenguaje de programación
utilizado.

El código limpio se rige por principios universales que favorecen la legibilidad, el
mantenimiento y la escalabilidad, entre los que destacan los siguientes:

- **Separación de responsabilidades**: Cada parte del código debe tener una tarea
  específica. Una función, una única tarea.
- **Minimizar dependencias entre módulos**: Conviene diseñar los módulos como si fueran
  microservicios, con interfaces claras y acoplamiento mínimo.
- **Nomenclatura descriptiva**: Los nombres de variables y funciones deben ser fáciles
  de interpretar, buscar y entender.
- **Evitar comentarios innecesarios**: Si el código necesita un comentario para
  explicarse, es preferible extraer una función o una variable con un nombre
  descriptivo. Esto no implica eliminar los comentarios por completo. Lo que debe
  evitarse es comentar lo que el código hace literalmente, cuando lo valioso es
  documentar qué representa y qué se pretende conseguir con él.
- **Principio de responsabilidad única**: No conviene agrupar toda la lógica en clases
  cuando la programación funcional resulta suficiente.
- **Validación cerca de los datos**: La validación debe situarse siempre lo más cerca
  posible de la fuente de datos.

Estos principios se materializan en dos decisiones concretas que conviene tomar al
inicio de cualquier proyecto, la organización de los directorios y la adopción de una
convención de estilo común.

### Estructura del proyecto

Un proyecto debe estar organizado en dos partes principales:

1. **Directorio de la aplicación**: Contiene la lógica del código, la configuración de
   los modelos, los registros (_logs_) y demás componentes funcionales.
2. **Ajustes y configuraciones**: Incluye configuraciones y dependencias del proyecto,
   como archivos de gestión de dependencias, _Dockerfiles_, archivos de configuración
   `.yml` y similares.

Esta separación promueve un código modular, organizado y fácil de mantener, además de
delimitar con claridad qué elementos pertenecen al dominio del problema y cuáles
corresponden al entorno de ejecución.

### Convenciones de estilo

Cada lenguaje de programación dispone de guías de estilo que definen convenciones para
escribir código legible y consistente. Se recomienda adoptar la guía oficial del
lenguaje utilizado y emplear herramientas de formateo automático para garantizar su
cumplimiento, de modo que las decisiones de estilo dejen de consumir atención durante la
revisión del código.

| Elemento              | Convención                   | Ejemplo             |
| :-------------------- | :--------------------------- | :------------------ |
| Paquetes y módulos    | Minúsculas con guiones bajos | `mi_modulo`         |
| Clases                | _CamelCase_ (o _PascalCase_) | `MiClase`           |
| Funciones y variables | Minúsculas con guiones bajos | `mi_funcion`        |
| Constantes            | Mayúsculas con guiones bajos | `MI_CONSTANTE`      |
| Elementos no públicos | Prefijo con guion bajo       | `_variable_interna` |

???+ example "En Python"

    En Python, la guía de estilo oficial es [PEP 8](https://pep8.org/). Herramientas como
    [Ruff](https://docs.astral.sh/ruff/) permiten aplicar estas convenciones
    automáticamente. El siguiente fragmento ilustra el orden recomendado de las
    importaciones, que separa la biblioteca estándar de las dependencias externas y del
    código propio, junto con la aplicación de las convenciones de nomenclatura:

    ```python linenums="1"
    from typing import Final

    from external_lib import some_function
    from local_module import local_function

    MI_CONSTANTE: Final[int] = 42


    class MiClase:
        """
        Ejemplo de clase con un atributo no público.
        """

        def __init__(self) -> None:
            """
            Inicializa el estado interno de la instancia.
            """
            self._variable_interna: int = 10

        def metodo_publico(self) -> int:
            """
            Expone el valor del atributo interno.

            Returns:
                El valor almacenado en el atributo no público.
            """

            return self._variable_interna


    def suma(a: int, b: int) -> int:
        """
        Suma dos números enteros.

        Args:
            a: Primer operando.
            b: Segundo operando.

        Returns:
            El resultado de sumar ambos operandos.
        """

        return a + b
    ```

## Complejidad

Las convenciones anteriores mejoran la legibilidad local del código, pero no resuelven
el problema de fondo que aparece cuando un sistema crece. El problema más fundamental en
la ciencia de la computación es la **descomposición de problemas**. A medida que un
programa evoluciona y adquiere más funcionalidades, se vuelve complejo, con dependencias
sutiles entre sus componentes. Con el tiempo, la complejidad se acumula y resulta cada
vez más difícil para los programadores mantener en mente todos los factores relevantes
al modificar el sistema. Esto ralentiza el desarrollo, conduce a errores y da lugar a lo
que se conoce como **deuda técnica**.

???+ warning "Mentalidad táctica frente a mentalidad estratégica"

    Muchas organizaciones fomentan una mentalidad táctica, centrada en hacer que las
    funcionalidades estén operativas lo más rápido posible. Sin embargo, las complejidades
    se acumulan con rapidez cuando todo el equipo programa de forma táctica. El código
    funcional no es suficiente, ya que el objetivo principal debe ser producir un buen
    diseño que además funcione. Se recomienda invertir entre el 10 % y el 20 % del tiempo
    total de desarrollo en mejoras de diseño. Este esfuerzo puede incorporarse dentro de
    los _sprints_ cuando se emplean metodologías ágiles, o bien reservarse como un tiempo
    explícito dedicado a dicha tarea.

### Síntomas de la complejidad

Antes de poder controlar la complejidad conviene reconocerla. Esta se manifiesta de tres
formas generales:

1. **Amplificación de cambios**: Un cambio aparentemente simple requiere modificaciones
   en muchos lugares diferentes del código.
2. **Carga cognitiva**: Se refiere a cuánto necesita saber un desarrollador para
   completar una tarea. Surge de APIs con muchos métodos, variables globales,
   inconsistencias y dependencias entre módulos.
3. **Incógnitas desconocidas**: No resulta obvio qué piezas de código deben modificarse
   para completar una tarea, ni qué información necesita el desarrollador. Este es el
   peor de los tres síntomas, porque no puede detectarse mediante la lectura del código.

### Causas de la complejidad

Estos síntomas responden a dos causas fundamentales:

- **Dependencias**: Cada vez que se crea una nueva clase, se generan dependencias
  alrededor de su API.
- **Oscuridad**: Ocurre cuando información importante no resulta evidente. La
  inconsistencia es un contribuyente destacado a la oscuridad.

La necesidad de documentación extensa suele ser una señal de que el diseño no es del
todo correcto. La mejor forma de reducir la oscuridad consiste en simplificar el diseño
del sistema en lugar de compensarlo con explicaciones añadidas.

## Diseño modular

Una de las técnicas más importantes para gestionar la complejidad del _software_
consiste en diseñar sistemas de modo que los desarrolladores solo necesiten enfrentarse
a una pequeña fracción de la complejidad total en cada momento. En el diseño modular, un
sistema se descompone en una colección de módulos relativamente independientes que
pueden adoptar muchas formas, como clases, subsistemas o servicios.

### Interfaces

La interfaz de un módulo contiene dos tipos de información:

- **Formal**: Especificada explícitamente en el código, como las firmas de los métodos,
  los tipos de los parámetros, los valores de retorno y las excepciones.
- **Informal**: Restricciones de uso, orden de llamadas y precondiciones. Si un
  desarrollador necesita conocer una pieza de información para usar un módulo, esa
  información forma parte de su interfaz.

Reconocer que la parte informal también constituye interfaz resulta clave, ya que
determina cuánto conocimiento debe transferirse entre módulos y, por tanto, el grado
real de acoplamiento del sistema.

### Módulos profundos

Los mejores módulos son aquellos que proporcionan funcionalidad potente mediante
interfaces simples. La cuestión más importante al diseñar clases y módulos consiste en
hacerlos **profundos**, es decir, dotarlos de interfaces simples para los casos de uso
comunes y de funcionalidad significativa detrás de ellas.

???+ example "Módulo profundo frente a módulo superficial en Python"

    Un módulo **superficial** expone demasiados detalles internos y obliga a quien lo
    utiliza a orquestar la secuencia completa de operaciones:

    ```python linenums="1"
    class GestorArchivos:
        """
        Interfaz superficial que expone la mecánica interna de acceso
        al archivo.
        """

        def abrir_archivo(self, ruta: str) -> int: ...

        def leer_bytes(self, descriptor: int, n: int) -> bytes: ...

        def cerrar_archivo(self, descriptor: int) -> None: ...

        def verificar_permisos(self, ruta: str) -> bool: ...

        def obtener_tamano(self, ruta: str) -> int: ...
    ```

    Un módulo **profundo** oculta esa complejidad tras una interfaz reducida:

    ```python linenums="1"
    class GestorArchivos:
        """
        Interfaz profunda que resuelve el caso de uso común en una sola
        llamada.
        """

        def leer(self, ruta: str) -> str:
            """
            Lee el contenido completo de un archivo.

            Args:
                ruta: Ruta del archivo que se desea leer.

            Returns:
                El contenido del archivo como texto.
            """
            ...
    ```

    Conviene tener en consideración que una única función no debe abarcarlo todo. Cuando
    existen funcionalidades generalizables a varias operaciones, como la apertura y el
    cierre del archivo compartidos entre la lectura y la escritura, resulta preferible
    repartir la responsabilidad en métodos reutilizables que se mantengan ocultos tras la
    interfaz pública.

### Ocultación de información

Cada módulo debe encapsular piezas de conocimiento que representan decisiones de diseño.
La **ocultación de información** reduce la complejidad de dos formas, ya que simplifica
la interfaz del módulo y facilita la evolución del sistema al limitar el impacto de los
cambios.

???+ example "Ocultación de información en Python"

    El usuario de la clase no necesita saber cómo se almacenan los datos internamente:

    ```python linenums="1"
    class Carrito:
        """
        Carrito de compra que acumula productos y calcula su importe
        total.
        """

        def __init__(self) -> None:
            """
            Inicializa un carrito sin productos.
            """

            self._items: dict[str, float] = {}

        def agregar(self, producto: str, precio: float) -> None:
            """
            Añade un producto al carrito.

            Args:
                producto: Nombre identificativo del producto.
                precio: Importe asociado al producto.
            """

            self._items[producto] = precio

        def total(self) -> float:
            """
            Calcula el importe total del carrito.

            Returns:
                La suma de los precios de todos los productos.
            """

            return sum(self._items.values())
    ```

    Si en el futuro se sustituye el diccionario por una base de datos, la interfaz pública
    formada por `agregar` y `total` permanece intacta.

### Fugas de información

Lo opuesto a la ocultación de información es la **fuga de información**, que ocurre
cuando una decisión de diseño se refleja en múltiples módulos y crea dependencias entre
ellos.

???+ example "Fuga de información en Python"

    Si el formato de serialización se filtra a varios módulos, un cambio de JSON a YAML
    obliga a modificarlos todos:

    ```python linenums="1"
    import json


    # Fuga: ambos módulos conocen el formato JSON
    class Exportador:
        """
        Convierte datos a texto conociendo el formato concreto.
        """

        def exportar(self, datos: dict) -> str:
            """
            Serializa un diccionario.

            Args:
                datos: Estructura que se desea serializar.

            Returns:
                Representación textual de los datos.
            """

            return json.dumps(datos)


    class Importador:
        """
        Reconstruye datos a partir de texto conociendo el formato
        concreto.
        """

        def importar(self, texto: str) -> dict:
            """
            Deserializa una cadena de texto.

            Args:
                texto: Representación textual de los datos.

            Returns:
                Estructura reconstruida a partir del texto.
            """

            return json.loads(texto)
    ```

    La solución consiste en encapsular la decisión de formato en un único módulo:

    ```python linenums="1"
    import json


    # Correcto: un solo módulo conoce el formato
    class Serializador:
        """
        Concentra la decisión sobre el formato de serialización.
        """

        def serializar(self, datos: dict) -> str:
            """
            Convierte una estructura de datos en texto.

            Args:
                datos: Estructura que se desea serializar.

            Returns:
                Representación textual de los datos.
            """

            return json.dumps(datos)

        def deserializar(self, texto: str) -> dict:
            """
            Reconstruye una estructura de datos a partir de texto.

            Args:
                texto: Representación textual de los datos.

            Returns:
                Estructura reconstruida a partir del texto.
            """

            return json.loads(texto)
    ```

???+ warning "Descomposición temporal"

    Un error común es la descomposición temporal, donde la estructura del sistema
    corresponde al orden temporal de las operaciones. Al diseñar módulos hay que centrarse
    en el conocimiento necesario para cada tarea, no en el orden en que ocurren las tareas.

### Generalidad frente a especialización

La sobreespecialización puede ser la mayor causa de complejidad en _software_. El código
más general resulta más simple, limpio y fácil de entender. El código especializado debe
separarse limpiamente del código de propósito general, y los casos especiales deben
eliminarse siempre que sea posible.

### Cuándo dividir o unir código

La decisión de dividir o unir módulos debe basarse en la complejidad resultante. La
longitud por sí sola rara vez es una buena razón para dividir un método. Cada método
debe hacer una cosa y hacerla completamente. Además, resulta más importante que un
módulo tenga una interfaz simple que una implementación simple, porque la interfaz la
soportan todos los consumidores del módulo, mientras que la implementación solo afecta a
quien lo mantiene.

## Gestión de excepciones

El manejo de excepciones puede representar una fracción significativa de todo el código
de un sistema y constituye una fuente importante de complejidad, ya que multiplica los
caminos de ejecución posibles. La lección clave consiste en **reducir el número de
lugares donde deben manejarse las excepciones**.

Las técnicas principales para reducir esta complejidad son las siguientes:

1. **Definir los errores fuera de existencia**: Diseñar las APIs de modo que las
   condiciones de error simplemente no puedan ocurrir.
2. **Enmascaramiento de excepciones**: Manejar la excepción en un nivel bajo sin
   propagarla hacia arriba.
3. **Agregación de excepciones**: Manejar muchas excepciones con un único fragmento de
   código.
4. **Terminar la aplicación**: Para ciertos errores que no vale la pena intentar
   manejar, dejar simplemente que la aplicación falle.

De estas cuatro técnicas, la primera es la más efectiva, porque elimina la condición de
error en lugar de trasladar su tratamiento a otro punto del sistema.

???+ example "Definir errores fuera de existencia en Python"

    En lugar de lanzar una excepción cuando la clave no existe:

    ```python linenums="1"
    # Diseño que genera excepciones innecesarias
    class Configuracion:
        """
        Configuración que obliga a capturar errores en cada consulta.
        """

        def __init__(self, datos: dict[str, str]) -> None:
            """
            Almacena los pares de configuración.

            Args:
                datos: Pares clave y valor de la configuración.
            """

            self._datos: dict[str, str] = datos

        def obtener(self, clave: str) -> str:
            """
            Devuelve el valor asociado a una clave.

            Args:
                clave: Clave de configuración solicitada.

            Returns:
                El valor asociado a la clave.

            Raises:
                KeyError: Si la clave no está definida.
            """

            if clave not in self._datos:
                raise KeyError(f"Clave '{clave}' no encontrada")

            return self._datos[clave]
    ```

    La API puede diseñarse de forma que el error no llegue a existir:

    ```python linenums="1"
    # Diseño que elimina la condición de error
    class Configuracion:
        """
        Configuración que devuelve un valor por defecto para claves
        ausentes.
        """

        def __init__(self, datos: dict[str, str]) -> None:
            """
            Almacena los pares de configuración.

            Args:
                datos: Pares clave y valor de la configuración.
            """

            self._datos: dict[str, str] = datos

        def obtener(self, clave: str, por_defecto: str = "") -> str:
            """
            Devuelve el valor asociado a una clave o un valor
            alternativo.

            Args:
                clave: Clave de configuración solicitada.
                por_defecto: Valor devuelto cuando la clave no está
                    definida.

            Returns:
                El valor asociado a la clave, o el valor por defecto.
            """

            return self._datos.get(clave, por_defecto)
    ```

    ```python linenums="1"
    configuracion = Configuracion({"entorno": "produccion"})

    print(f"Entorno: {configuracion.obtener('entorno')}")
    print(f"Región: {configuracion.obtener('region', 'eu-west-1')}")
    ```

    ```title="Salida esperada"
    Entorno: produccion
    Región: eu-west-1
    ```

???+ warning "Antipatrón"

    Los programadores agravan el problema definiendo excepciones innecesarias. Las
    excepciones lanzadas por una clase forman parte de su interfaz, de modo que las clases
    con muchas excepciones presentan interfaces complejas y resultan más superficiales. A
    esto se añade que los módulos y funciones de los tipos de datos utilizados, tanto
    propios como de terceros, ya suelen contemplar internamente las excepciones
    pertinentes, por lo que replicar ese tratamiento aporta complejidad sin aportar
    garantías.

## Documentación y nombres

Reducir la complejidad estructural no elimina la necesidad de comunicar la intención del
código. Los comentarios y los nombres constituyen los dos mecanismos principales para
ello.

### Comentarios

Los comentarios deben describir aquello que no resulta obvio a partir del código. El
acto de escribir comentarios permite además evaluar las decisiones de diseño de forma
temprana, ya que si resulta difícil escribir un comentario simple y completo para un
método o una variable, existe un indicio de que el diseño presenta un problema.

Entre las buenas prácticas aplicables destacan escribir el comentario de interfaz de
cada método antes de su cuerpo, posicionar los comentarios cerca del código que
describen, no redocumentar en un módulo las decisiones de diseño de otro y referenciar
la información ya documentada en una fuente externa en lugar de repetirla.

### Nombres

Los buenos nombres presentan dos propiedades:

- **Precisión**: Si alguien observa el nombre de forma aislada, sin ver su declaración
  ni su documentación, debería poder deducir a qué se refiere.
- **Consistencia**: Para cada uso común conviene elegir un nombre y emplearlo en todas
  partes, sin utilizar nunca ese mismo nombre para otro propósito.

???+ example "Buenos y malos nombres en Python"

    La primera versión obliga a leer el cuerpo completo para entender qué hace la función,
    mientras que la segunda transmite su propósito desde la firma:

    ```python linenums="1"
    # Nombres vagos que no transmiten intención
    def proc(d: list[dict]) -> list[dict]:
        r = []

        for x in d:
            if x["a"] > 0:
                r.append(x)

        return r
    ```

    ```python linenums="1"
    # Nombres descriptivos que documentan el código
    def filtrar_transacciones_positivas(
        transacciones: list[dict[str, float]],
    ) -> list[dict[str, float]]:
        """
        Selecciona las transacciones cuyo importe es positivo.

        Args:
            transacciones: Colección de transacciones con la clave
                "monto".

        Returns:
            Las transacciones cuyo importe es mayor que cero.
        """

        positivas: list[dict[str, float]] = []

        for transaccion in transacciones:
            if transaccion["monto"] > 0:
                positivas.append(transaccion)

        return positivas
    ```

    ```python linenums="1"
    movimientos: list[dict[str, float]] = [{"monto": 120.0}, {"monto": -35.5}]

    print(f"Positivas: {filtrar_transacciones_positivas(movimientos)}")
    ```

    ```title="Salida esperada"
    Positivas: [{'monto': 120.0}]
    ```

## Consistencia y claridad

La consistencia es una herramienta poderosa para reducir la complejidad. Si un sistema
es consistente, las cosas similares se hacen de formas similares y las cosas diferentes
se hacen de formas diferentes, lo que permite reutilizar el conocimiento adquirido en
una parte del sistema al leer cualquier otra.

Para mantener la consistencia conviene documentar las convenciones más importantes,
escribir herramientas que verifiquen automáticamente sus violaciones y resistir la
tentación de mejorar convenciones ya establecidas. El _software_ debe diseñarse para
facilitar la lectura, no la escritura.

## Arquitectura de _software_

Las decisiones examinadas hasta ahora afectan a módulos concretos y admiten
rectificación con un coste moderado. La arquitectura de _software_ se distingue del
diseño precisamente en que aborda decisiones estructurales difíciles de revertir,
mientras que el diseño se centra en aspectos más fácilmente modificables. El verdadero
trabajo de un arquitecto reside en su capacidad para evaluar objetivamente los
_trade-offs_ a ambos lados de una decisión consecuente y resolverla de la mejor manera
posible.

### _Clean Architecture_

_Clean Architecture_ propone una separación clara entre la **lógica de negocio**,
aquello que no está limitado por la tecnología, y la **lógica de la aplicación**, que
depende de la tecnología utilizada.

La arquitectura se organiza en capas concéntricas con dependencias que apuntan siempre
hacia el interior, de modo que las capas internas permanecen ajenas a las decisiones
tecnológicas de las externas:

| Capa (de interior a exterior) | Responsabilidad                                                               |
| :---------------------------- | :---------------------------------------------------------------------------- |
| **Dominio**                   | Entidades y reglas de negocio puras. No conoce las capas exteriores.          |
| **Casos de uso (Aplicación)** | Orquesta la lógica de negocio. El dominio no sabe de los casos de uso.        |
| **Adaptadores**               | Convierte datos entre el formato de los casos de uso y el del mundo exterior. |
| **Externo (Infraestructura)** | _Frameworks_, bases de datos, UI, navegador, APIs externas.                   |

Esta disposición se traduce de forma directa en la organización de los directorios del
proyecto y en el uso de abstracciones que invierten el sentido de las dependencias.

???+ example "Estructura de carpetas siguiendo _Clean Architecture_"

    ```plaintext linenums="1"
    mi_proyecto/
    ├── dominio/
    │   ├── entidades.py        # Modelos puros del negocio
    │   └── repositorios.py     # Interfaces abstractas (protocolos)
    ├── aplicacion/
    │   └── casos_de_uso.py     # Orquestación de la lógica de negocio
    ├── adaptadores/
    │   ├── api.py              # Controladores HTTP
    │   └── persistencia.py     # Implementación concreta del repositorio
    └── main.py                 # Punto de entrada y configuración
    ```

    El dominio define la interfaz que necesita mediante un protocolo, sin conocer la
    implementación concreta que la satisface:

    ```python linenums="1"
    # dominio/repositorios.py
    from typing import Protocol

    from dominio.entidades import Usuario


    class RepositorioUsuarios(Protocol):
        """
        Contrato de persistencia requerido por el dominio.
        """

        def obtener_por_id(self, id_usuario: int) -> Usuario | None: ...

        def guardar(self, usuario: Usuario) -> None: ...
    ```

    El caso de uso recibe una implementación de ese contrato, por lo que puede sustituirse
    sin modificar la lógica de negocio:

    ```python linenums="1"
    # aplicacion/casos_de_uso.py
    from dominio.entidades import Usuario
    from dominio.repositorios import RepositorioUsuarios


    class RegistrarUsuario:
        """
        Caso de uso que crea y persiste un usuario.
        """

        def __init__(self, repositorio: RepositorioUsuarios) -> None:
            """
            Recibe la dependencia de persistencia.

            Args:
                repositorio: Implementación concreta del contrato de
                    persistencia.
            """

            self._repositorio: RepositorioUsuarios = repositorio

        def ejecutar(self, nombre: str, email: str) -> Usuario:
            """
            Registra un nuevo usuario en el sistema.

            Args:
                nombre: Nombre del usuario.
                email: Dirección de correo electrónico del usuario.

            Returns:
                La entidad de usuario creada.
            """

            usuario = Usuario(nombre=nombre, email=email)
            self._repositorio.guardar(usuario)

            return usuario
    ```

### Registros de decisiones arquitectónicas (ADRs)

Dado que las decisiones arquitectónicas resultan costosas de revertir, conviene
conservar el razonamiento que las motivó. Una de las formas más efectivas de
documentarlas son los _Architectural Decision Records_ (ADRs). Un ADR consiste en un
archivo de texto breve que describe una decisión arquitectónica específica, su contexto
y sus consecuencias, lo que permite que futuros integrantes del equipo comprendan por
qué el sistema es como es.

## Señales de alerta

La presencia de cualquiera de los síntomas recogidos en la tabla siguiente sugiere un
problema con el diseño y justifica revisar la descomposición elegida:

| Señal de alerta           | Descripción                                                                              |
| ------------------------- | ---------------------------------------------------------------------------------------- |
| Fuga de información       | Una decisión de diseño se refleja en múltiples módulos                                   |
| Método de paso            | Un método no hace casi nada excepto pasar sus argumentos a otro método con firma similar |
| Repetición                | Un fragmento de código no trivial se repite una y otra vez                               |
| Métodos acoplados         | Dos métodos tienen tantas dependencias que es difícil entender uno sin entender el otro  |
| Nombre vago               | El nombre de una variable o método es tan impreciso que no transmite información útil    |
| Dificultad para nombrar   | Es difícil encontrar un nombre preciso e intuitivo para una entidad                      |
| Dificultad para describir | La documentación de una variable o método debe ser extensa para ser completa             |
| Código no obvio           | El comportamiento o significado de un fragmento de código no puede entenderse fácilmente |

## Versionado semántico

Un diseño sostenible debe comunicar también cómo evoluciona hacia el exterior. El
versionado semántico (_Semantic Versioning_ o SemVer) es un sistema estandarizado para
controlar las versiones del _software_, representado mediante el formato `X.Y.Z`:

| Componente    | Significado   | Se incrementa cuando...                                    |
| :------------ | :------------ | :--------------------------------------------------------- |
| **X** (Major) | Versión mayor | Un cambio rompe la compatibilidad con versiones anteriores |
| **Y** (Minor) | Versión menor | Se añade funcionalidad compatible con lo existente         |
| **Z** (Patch) | Parche        | Se corrigen errores sin alterar la compatibilidad          |

Un proyecto comienza en la versión `0.1.0` durante su desarrollo inicial. A partir de la
versión `1.0.0` se considera estable y las reglas de incremento se aplican de forma
estricta, lo que permite a los consumidores anticipar el impacto de cada actualización.

## Desarrollo guiado por pruebas (TDD)

Las pruebas automatizadas constituyen el mecanismo que permite modificar un sistema con
confianza y, por tanto, sostener el diseño a lo largo del tiempo. El _Test-Driven
Development_ (TDD) propone escribir las pruebas antes del código de producción, de modo
que la especificación del comportamiento preceda a la implementación. El ciclo
fundamental se resume en la secuencia _Red-Green-Refactor_:

1. **Red**: Escribir una prueba que falla, ya que la funcionalidad aún no existe.
2. **Green**: Implementar el código mínimo necesario para que la prueba pase.
3. **Refactor**: Mejorar la calidad interna del código sin alterar su comportamiento.

???+ example "En Python con pytest"

    Las pruebas se escriben en primer lugar y describen el comportamiento esperado de una
    función que todavía no está implementada:

    ```python linenums="1"
    # test_suma.py
    from mi_modulo import suma


    def test_suma_positivos() -> None:
        """
        Comprueba la suma de dos operandos positivos.
        """

        assert suma(2, 3) == 5


    def test_suma_negativos() -> None:
        """
        Comprueba la suma de dos operandos negativos.
        """

        assert suma(-1, -1) == -2
    ```

    A continuación se implementa el código mínimo que satisface esas pruebas:

    ```python linenums="1"
    # mi_modulo.py
    def suma(a: int, b: int) -> int:
        """
        Suma dos números enteros.

        Args:
            a: Primer operando.
            b: Segundo operando.

        Returns:
            El resultado de sumar ambos operandos.
        """

        return a + b
    ```

    ```title="Salida esperada"
    ===== 2 passed in 0.01s =====
    ```

## Desarrollo guiado por comportamiento (BDD)

El _Behavior-Driven Development_ (BDD) extiende TDD centrándose en el comportamiento del
sistema desde la perspectiva del usuario final. En lugar de pruebas unitarias aisladas,
BDD describe escenarios de alto nivel en un lenguaje cercano al dominio del problema, lo
que facilita que participen en su definición perfiles no técnicos.

???+ example "Escenario BDD"

    ```gherkin linenums="1"
    Feature: Suma de números
      Scenario: Sumar dos números positivos
        Given el número 2
        And el número 3
        When se realiza la suma
        Then el resultado es 5
    ```

## Rendimiento

La búsqueda de eficiencia suele entrar en aparente conflicto con la simplicidad, pero
las intuiciones de los programadores sobre el rendimiento no resultan fiables. Antes de
introducir cambios conviene medir el comportamiento existente del sistema para
identificar dónde tendrá mayor impacto la optimización. La mejor forma de mejorar el
rendimiento consiste en aplicar cambios fundamentales, como introducir una _cache_ o
adoptar un enfoque algorítmico diferente, tal como ilustra la diferencia de coste entre
los métodos de búsqueda descritos en el capítulo de algoritmos. El código limpio y
simple tiende a ser suficientemente rápido.
