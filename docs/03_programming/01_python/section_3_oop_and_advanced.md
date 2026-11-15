---
icon: lucide/boxes
authors: Daniel Bazo Correa
description:
    Decoradores, generadores, alcance de las variables y programación orientada a
    objetos en Python, incluidas las dataclasses.
title: POO y características avanzadas
---

Este capítulo aborda las características avanzadas de Python y la programación orientada
a objetos. Comienza por los decoradores, los generadores y las reglas de alcance de los
nombres, mecanismos que se construyen sobre las funciones. Continúa con la programación
orientada a objetos, que incluye las clases, la herencia, el polimorfismo, las
_dataclasses_ y los atributos de solo lectura. Presupone los conceptos del capítulo de
[fundamentos](section_2_fundamentals.md), en particular las funciones.

## Decoradores

Los **decoradores** en Python permiten modificar el comportamiento de una función sin
alterar su código fuente. Esto resulta útil cuando se desea añadir funcionalidades a una
función existente sin modificar su definición.

Los decoradores tienen múltiples aplicaciones. Por ejemplo, se utilizan en el desarrollo
web con _frameworks_ como Flask para añadir comportamientos a las funciones de ruta,
como requerir autenticación para acceder a ciertas páginas. También se emplean para
crear _loggers_ que registran cuándo se invocan determinadas funciones y con qué
argumentos, lo cual resulta útil para depurar y entender el flujo de ejecución de un
programa.

En Python, las funciones son objetos de primera clase. Esto significa que pueden ser
asignadas a variables, almacenadas en estructuras de datos, pasadas como argumentos a
otras funciones e incluso retornadas como valores de otras funciones.

???+ example "Decorador básico"

    ```python linenums="1"
    from collections.abc import Callable

    def nuevo_decorador(funcion_original: Callable[[], None]) -> Callable[[], None]:
        """
        Envuelve una función para mostrar mensajes antes y después de su ejecución.

        Args:
            funcion_original: Función sin argumentos que se desea decorar.

        Returns:
            La función decorada con el comportamiento añadido.
        """

        def funcion_nueva() -> None:
            """
            Ejecuta la función original añadiendo mensajes alrededor de la llamada.
            """

            print("Antes de la función original")
            funcion_original()
            print("Después de la función original")

        return funcion_nueva

    @nuevo_decorador
    def funcion_necesita_decorador() -> None:
        """
        Muestra un mensaje por pantalla.
        """

        print("Necesita un nuevo decorador")

    funcion_necesita_decorador()
    ```

    En este ejemplo, `nuevo_decorador` imprime un mensaje antes de ejecutar la función
    original y otro después. La sintaxis `@nuevo_decorador` antes de la definición de
    `funcion_necesita_decorador` es lo que aplica el decorador a la función.

## Generadores

Los **generadores** en Python son una forma eficiente de crear iteradores. A diferencia
de las funciones normales, los generadores utilizan la palabra clave `yield` en lugar de
`return`. Esto permite que produzcan valores de uno en uno, y solo cuando se necesitan,
en lugar de calcular todos los valores a la vez y almacenarlos en memoria. Son
especialmente útiles cuando se trabaja con grandes cantidades de datos que no caben en
memoria, ya que producen los elementos de forma perezosa (_lazy evaluation_), lo que
puede mejorar significativamente el rendimiento del programa.

???+ example "Generador con `yield`"

    Una función generadora devuelve un objeto generador que puede ser iterado para
    obtener los valores generados por `yield`:

    ```python linenums="1"
    from collections.abc import Generator

    def funcion_cubo_generador(n: int) -> Generator[int, None, None]:
        """
        Genera los cubos de los números comprendidos entre cero y n - 1.

        Args:
            n: Límite superior, no incluido, de la secuencia generada.

        Yields:
            El cubo de cada número de la secuencia.
        """

        for x in range(n):
            yield pow(x, 3)

    # Imprime: [0, 1, 8, 27, 64, 125, 216, 343, 512, 729]
    print(list(funcion_cubo_generador(10)))
    ```

La función `iter()` convierte un objeto iterable en un iterador, lo que permite utilizar
la función `next()` para acceder a sus elementos uno a uno:

```python linenums="1"
texto: str = "hola"
texto_iterador = iter(texto)

# Imprime: h
print(next(texto_iterador))
```

## Alcance de las variables

En Python, es fundamental comprender cómo se gestionan las variables en función de su
ubicación en el código. Cada nombre de variable pertenece a un ámbito o _scope_, que
determina desde qué partes del programa resulta visible:

```python linenums="1"
x: int = 25

def devolver_valor() -> int:
    """
    Devuelve un valor local que no altera la variable global del mismo nombre.

    Returns:
        El valor asignado dentro del ámbito local de la función.
    """

    x: int = 50
    return x

# Imprime: 25
print(x)

# Imprime: 50
print(devolver_valor())
```

La asignación de `x` dentro de la función `devolver_valor()` crea una variable local
independiente y no altera el valor global de `x`. Esto se debe a la regla de alcance de
Python, que sigue el orden **LEGB**:

- **L (_Local_)**: Nombres asignados dentro de una función (`def` o `lambda`) y que no
  se declaran globales en esa función.
- **E (_Enclosing function locals_)**: Nombres del ámbito local de las funciones
  envolventes (`def` o `lambda`), de la más interior a la más exterior.
- **G (_Global_)**: Nombres asignados en el nivel superior de un archivo de módulo, o
  declarados globales en un `def` dentro del archivo.
- **B (_Built-in_)**: Nombres integrados que Python predefine en el módulo `builtins`,
  como `open`, `range` o `SyntaxError`.

Este es el orden en el que Python busca las variables:

```python linenums="1"
# Variable global
nombre: str = "Esto es un string global"

def prueba() -> None:
    """
    Define una variable de encierro y llama a una función anidada.
    """

    # Variable del ámbito envolvente
    nombre: str = "Daniel"

    def hola() -> None:
        """
        Muestra el nombre visible en el ámbito más cercano.
        """

        # Variable local
        nombre: str = "Carlitos"
        print(f"Hola {nombre}")

    hola()

prueba()
```

En este ejemplo, la función `hola()` muestra primero la variable local `"Carlitos"`. Si
se comenta la asignación local, toma la variable del ámbito envolvente, `"Daniel"`. Y si
también se comenta esa asignación, toma la variable global `"Esto es un string global"`.

Cuando dentro de una función se asigna un valor a un nombre que también existe en el
ámbito global, la asignación afecta únicamente a la variable local. Para modificar la
variable global desde dentro de una función, se puede usar la palabra clave `global`:

```python linenums="1"
x: int = 50

def prueba() -> None:
    """
    Reasigna la variable global x mostrando su valor antes y después del cambio.
    """

    global x
    print(f"Valor de x antes: {x}")
    x = 200
    print(f"Valor de x después: {x}")

prueba()
print(f"Valor de x fuera: {x}")
```

Sin embargo, se recomienda evitar el uso de `global` a menos que sea absolutamente
necesario. Es más seguro devolver un objeto y luego asignarlo a la variable, evitando
así sobrescribir la variable global dentro de una función de forma inadvertida.

## Programación orientada a objetos

La **programación orientada a objetos** es un paradigma que organiza el código en torno
a **objetos** en lugar de funciones y lógica. Estos objetos combinan **datos**
(atributos) y **funciones** (métodos) que actúan sobre dichos datos. Este enfoque
permite la reutilización, la modularidad y la escalabilidad del código.

### Clases y objetos

Una **clase** es un molde o plantilla para crear objetos, que son instancias de la
clase. Los objetos poseen **atributos** (características) y **métodos**
(comportamientos):

```python linenums="1"
class NombreDeClase:
    """
    Plantilla mínima que ilustra la estructura de una clase.
    """

    def __init__(self, parametro1: str, parametro2: int) -> None:
        """
        Inicializa la instancia con los valores recibidos.

        Args:
            parametro1: Valor de tipo cadena asociado a la instancia.
            parametro2: Valor numérico asociado a la instancia.
        """

        self.parametro1 = parametro1
        self.parametro2 = parametro2

    def algun_metodo(self) -> None:
        """
        Muestra un mensaje que confirma la ejecución del método.
        """

        print("Este es un método dentro de la clase")
```

Cuando se define una función dentro de una clase, se denomina método. El método especial
`__init__` es un **constructor** que se ejecuta automáticamente al crear una nueva
instancia de la clase. El primer argumento de cualquier método en una clase es `self`,
que hace referencia a la propia instancia del objeto:

```python linenums="1"
class Coche:
    """
    Representa un coche con sus características principales.
    """

    def __init__(
        self,
        marca: str,
        modelo: str,
        mejorado: bool,
        acceso_coche: list[str],
    ) -> None:
        """
        Inicializa el coche con sus datos identificativos.

        Args:
            marca: Fabricante del vehículo.
            modelo: Modelo concreto del vehículo.
            mejorado: Indica si el vehículo incorpora mejoras.
            acceso_coche: Nombres de las personas autorizadas a conducirlo.
        """

        self.marca = marca
        self.modelo = modelo
        self.mejorado = mejorado
        self.acceso_coche = acceso_coche

mi_coche = Coche("Toyota", "Corolla", True, ["Juan", "Maria"])
print(f"Mi coche es un {mi_coche.marca} {mi_coche.modelo}")
```

Cuando un método devuelve una instancia del mismo tipo que la clase, se puede utilizar
la anotación `Self` del módulo `typing`, disponible desde Python 3.11, para expresarlo
con precisión. `Self` denota el tipo real de la instancia, de modo que la anotación
sigue siendo correcta en las subclases:

```python linenums="1"
from typing import Self

class Usuario:
    """
    Ejemplo de clase cuyos métodos devuelven instancias del propio tipo.
    """

    def duplicar(self) -> Self:
        """
        Crea una instancia nueva del mismo tipo que la instancia actual.

        Returns:
            Una instancia nueva del tipo concreto sobre el que se invoca el método.
        """

        # type(self) devuelve la clase real, que puede ser una subclase de Usuario
        return type(self)()
```

!!! warning "`Self` no admite devolver la clase escrita a mano"

    Escribir `return Usuario()` en un método anotado con `-> Self` es incorrecto, aunque
    el intérprete no lo impida. Un comprobador de tipos como mypy lo señala con el error
    `Incompatible return value type (got "Usuario", expected "Self")`, porque una
    subclase heredaría el método y devolvería un objeto de la clase base en lugar de uno
    de su propio tipo.

    La construcción adecuada es `type(self)()`, que instancia la clase real. Si de
    verdad se desea devolver siempre la clase base, la anotación correcta es
    `-> "Usuario"` y no `-> Self`.

### Atributos y métodos

Algunos atributos son comunes a todas las instancias, y se denominan atributos de clase,
mientras que otros son específicos de cada objeto y se denominan atributos de instancia:

```python linenums="1"
class Perro:
    """
    Representa un perro con sus atributos de instancia y de clase.
    """

    # Atributo de clase, común para todas las instancias
    especie: str = "mamífero"

    def __init__(self, raza: str, nombre: str, edad: int) -> None:
        """
        Inicializa el perro con sus atributos de instancia.

        Args:
            raza: Raza del animal.
            nombre: Nombre del animal.
            edad: Edad del animal en años.
        """

        self.raza = raza
        self.nombre = nombre
        self.edad = edad

    def sonido(self) -> str:
        """
        Devuelve el sonido característico del animal.

        Returns:
            El sonido emitido por el perro.
        """

        return "Woof!"

    def informacion(self) -> None:
        """
        Muestra por pantalla los datos del animal.
        """

        print(
            f"Nombre: {self.nombre}, Raza: {self.raza}, "
            f"Edad: {self.edad}, Especie: {self.especie}"
        )

if __name__ == "__main__":
    mi_perro = Perro("Labrador", "Fido", 3)
    mi_perro.informacion()
```

En este ejemplo, `especie` es un atributo de clase compartido por todas las instancias
de `Perro`, mientras que `raza`, `nombre` y `edad` son atributos únicos para cada
instancia.

### Herencia y polimorfismo

La **herencia** permite crear nuevas clases a partir de clases ya existentes. La nueva
clase (subclase) hereda los atributos y métodos de la clase padre, pero también puede
tener sus propios atributos y métodos o sobrescribir los heredados:

```python linenums="1"
class Animal:
    """
    Clase base que define el comportamiento común de los animales.
    """

    def __init__(self, nombre: str) -> None:
        """
        Inicializa el animal con su nombre.

        Args:
            nombre: Nombre del animal.
        """

        self.nombre = nombre

    def quien_soy(self) -> None:
        """
        Muestra una descripción genérica del animal.
        """

        print("Soy un animal")

    def comer(self) -> None:
        """
        Muestra un mensaje indicando que el animal está comiendo.
        """

        print("Estoy comiendo")

class Perro(Animal):
    """
    Especialización de Animal que redefine su descripción.
    """

    def quien_soy(self) -> None:
        """
        Muestra una descripción específica del perro.
        """

        print(f"Soy un perro llamado {self.nombre}")

mi_perro = Perro("Fido")

# Imprime: Soy un perro llamado Fido
mi_perro.quien_soy()

# Imprime: Estoy comiendo
mi_perro.comer()
```

En este caso, `Perro` hereda de `Animal`, por lo que puede usar el método `comer`.
Además, la subclase `Perro` sobrescribe el método `quien_soy` de la clase `Animal`.

Por otro lado, el **polimorfismo** permite usar el mismo nombre de método en diferentes
clases. Aunque el método tenga el mismo nombre, cada clase puede implementarlo de manera
diferente:

```python linenums="1"
class Perro(Animal):
    """
    Representa un perro capaz de emitir su sonido característico.
    """

    def sonido(self) -> None:
        """
        Muestra el sonido emitido por el perro.
        """

        print(f"El perro {self.nombre} ladra")

class Gato(Animal):
    """
    Representa un gato capaz de emitir su sonido característico.
    """

    def sonido(self) -> None:
        """
        Muestra el sonido emitido por el gato.
        """

        print(f"El gato {self.nombre} maulla")

mi_perro = Perro("Fido")
mi_gato = Gato("Miau")

# Imprime: El perro Fido ladra
mi_perro.sonido()

# Imprime: El gato Miau maulla
mi_gato.sonido()
```

### Clases abstractas

Una **clase abstracta** es aquella que no se espera que se instancie directamente. Solo
sirve como base para otras clases que implementen sus métodos. Para definir clases
abstractas en Python se utiliza el módulo `abc` (_Abstract Base Classes_):

```python linenums="1"
from abc import ABC, abstractmethod

class Animal(ABC):
    """
    Clase abstracta que obliga a definir el sonido de cada animal.
    """

    def __init__(self, nombre: str) -> None:
        """
        Inicializa el animal con su nombre.

        Args:
            nombre: Nombre del animal.
        """

        self.nombre = nombre

    @abstractmethod
    def sonido(self) -> str:
        """
        Devuelve el sonido característico del animal.

        Returns:
            El sonido emitido por el animal.
        """

class Perro(Animal):
    """
    Implementación concreta de Animal para un perro.
    """

    def sonido(self) -> str:
        """
        Devuelve el sonido característico del perro.

        Returns:
            El mensaje con el sonido del perro.
        """

        return f"{self.nombre} hace woof!"

mi_perro = Perro("Fido")

# Imprime: Fido hace woof!
print(mi_perro.sonido())
```

Si no se implementa el método abstracto en la subclase, se genera un error al intentar
instanciarla.

### _Dataclasses_

En Python, cuando se necesita crear una clase cuya función principal es almacenar datos,
el código tiende a volverse repetitivo: es necesario escribir el método `__init__` para
asignar cada atributo, `__repr__` para obtener una representación legible del objeto y
`__eq__` para poder comparar instancias. El decorador `@dataclass`, disponible en el
módulo `dataclasses` desde Python 3.7, genera automáticamente todos estos métodos a
partir de las anotaciones de tipo de los atributos, lo que reduce significativamente el
código _boilerplate_.

Para definir una _dataclass_, basta con decorar la clase con `@dataclass` y declarar los
atributos con sus tipos:

```python linenums="1"
from dataclasses import dataclass

@dataclass
class Producto:
    """
    Representa un producto con su precio y cantidad en existencias.
    """

    nombre: str
    precio: float
    cantidad: int = 0

p1 = Producto("Teclado", 49.99, 10)
p2 = Producto("Teclado", 49.99, 10)

# Imprime: Producto(nombre='Teclado', precio=49.99, cantidad=10)
print(p1)

# Imprime: True, ya que la comparación se realiza por el valor de los atributos
print(p1 == p2)

# Imprime: 49.99
print(p1.precio)
```

En este ejemplo, Python genera automáticamente el constructor, la representación en
texto y la comparación por igualdad. El atributo `cantidad` tiene un valor
predeterminado de `0`, por lo que es opcional al crear una instancia.

El decorador `@dataclass` acepta varios parámetros que modifican el comportamiento de la
clase:

```python linenums="1"
from dataclasses import dataclass

@dataclass(frozen=True, order=True, slots=True)
class Usuario:
    """
    Representa un usuario inmutable y comparable por sus atributos.
    """

    nombre: str
    edad: int

u1 = Usuario("alice", 30)
u2 = Usuario("bob", 25)

# Imprime: True, la comparación sigue el orden de declaración de los atributos
print(u1 < u2)

# La siguiente línea lanzaría FrozenInstanceError, ya que la instancia es inmutable
# u1.nombre = "otro"
```

Cada parámetro cumple una función específica:

- `frozen=True`: Hace que las instancias sean inmutables. Cualquier intento de modificar
  un atributo después de la creación del objeto lanza un `FrozenInstanceError`. Esto
  resulta útil cuando se necesita garantizar la integridad de los datos o utilizar las
  instancias como claves de diccionarios o elementos de _sets_, ya que las hace
  _hashables_.
- `order=True`: Genera automáticamente los métodos de comparación (`__lt__`, `__le__`,
  `__gt__`, `__ge__`), permitiendo ordenar instancias. La comparación se realiza por el
  orden en que se declaran los atributos, de forma similar a como se comparan las
  tuplas.
- `slots=True` (disponible desde Python 3.10): Sustituye el diccionario interno
  `__dict__` por _slots_, lo que reduce el consumo de memoria por instancia y mejora
  ligeramente la velocidad de acceso a los atributos. Como contrapartida, no es posible
  crear atributos que no hayan sido declarados previamente en la clase.

El método `__post_init__` se ejecuta automáticamente después del `__init__` generado por
la _dataclass_. Resulta útil para realizar validaciones o transformaciones sobre los
atributos una vez asignados:

```python linenums="1"
from dataclasses import dataclass

@dataclass(frozen=True)
class Usuario:
    """
    Representa un usuario cuyo nombre se normaliza al crear la instancia.
    """

    nombre: str

    def __post_init__(self) -> None:
        """
        Normaliza el nombre eliminando espacios y pasándolo a minúsculas.
        """

        # En una dataclass frozen se usa object.__setattr__ para modificar atributos
        object.__setattr__(self, "nombre", self.nombre.strip().lower())

u = Usuario("  Alice  ")

# Imprime: alice
print(u.nombre)
```

Cuando la _dataclass_ es inmutable (`frozen=True`), no es posible reasignar atributos
directamente con `self.name = ...` dentro de `__post_init__`, ya que esto lanzaría un
error. En su lugar, se utiliza `object.__setattr__` para sortear la restricción de
inmutabilidad exclusivamente durante la fase de inicialización.

Cuando un atributo necesita un valor predeterminado mutable (como una lista o un
diccionario), no se puede asignar directamente, ya que todas las instancias compartirían
la misma referencia. Para estos casos se utiliza la función `field` con
`default_factory`:

```python linenums="1"
from dataclasses import dataclass, field

@dataclass
class Inventario:
    """
    Representa un inventario con una lista de artículos y metadatos internos.
    """

    nombre: str
    articulos: list[str] = field(default_factory=list)
    metadatos: dict[str, str] = field(default_factory=dict, repr=False)

inv = Inventario("Almacén A")
inv.articulos.append("Tornillo")

# Imprime: Inventario(nombre='Almacén A', articulos=['Tornillo'])
# El atributo metadatos no aparece porque se ha configurado con repr=False
print(inv)
```

El parámetro `repr=False` en `field` permite excluir un atributo de la representación en
texto del objeto, lo cual resulta útil para atributos internos o de gran tamaño que no
aportan claridad al inspeccionar la instancia.

Las _dataclasses_ admiten herencia de forma natural. La subclase hereda los atributos de
la clase padre y puede añadir los suyos propios. También es posible combinar
_dataclasses_ con clases abstractas del módulo `abc` para definir interfaces que las
subclases deben implementar:

```python linenums="1"
from dataclasses import dataclass
from abc import ABC, abstractmethod

@dataclass
class Vehiculo(ABC):
    """
    Clase base abstracta para los vehículos del catálogo.
    """

    marca: str
    modelo: str

    @abstractmethod
    def tipo(self) -> str:
        """
        Devuelve la categoría comercial del vehículo.

        Returns:
            El nombre de la categoría a la que pertenece el vehículo.
        """

@dataclass
class Coche(Vehiculo):
    """
    Vehículo de tipo turismo con un número configurable de puertas.
    """

    num_puertas: int = 4

    def tipo(self) -> str:
        """
        Devuelve la categoría comercial del coche.

        Returns:
            La cadena que identifica al vehículo como turismo.
        """

        return "Turismo"

c = Coche("Toyota", "Corolla")

# Imprime: Coche(marca='Toyota', modelo='Corolla', num_puertas=4)
print(c)

# Imprime: Turismo
print(c.tipo())
```

### Atributos de solo lectura

El parámetro `frozen=True` de una _dataclass_ protege la instancia completa, pero en
muchos diseños solo interesa proteger algunos atributos concretos, como un identificador
asignado en la creación del objeto, mientras el resto del estado sigue evolucionando.
Python ofrece hoy tres mecanismos para expresar esa intención, cada uno con un alcance
distinto.

La anotación `Final` del módulo `typing` declara que un atributo no debe reasignarse
después de su primera asignación. La comprobación la realizan los verificadores de tipos
de forma estática, ya que en tiempo de ejecución no existe ninguna restricción efectiva.
La propiedad definida con `@property` y sin método asociado a `@nombre.setter` sí impide
la reasignación en tiempo de ejecución, a costa de introducir un atributo interno
adicional y el método que lo expone. El parámetro `frozen=True`, por último, congela
todos los atributos de la _dataclass_ a la vez.

```python linenums="1"
from typing import Final

class Sensor:
    """
    Representa un sensor cuyo identificador no cambia tras la creación.
    """

    def __init__(self, identificador: str, lectura: float) -> None:
        """
        Inicializa el sensor con su identificador y su primera lectura.

        Args:
            identificador: Código que identifica al sensor de forma única.
            lectura: Valor medido en el momento de la creación.
        """

        self.identificador: Final[str] = identificador
        self._lectura: float = lectura

    @property
    def lectura(self) -> float:
        """
        Expone la última lectura registrada.

        Returns:
            El valor de la última lectura registrada por el sensor.
        """

        return self._lectura

s = Sensor("s-01", 21.5)

# Imprime: 21.5
print(s.lectura)

# La siguiente línea lanzaría AttributeError, ya que la propiedad no tiene setter
# s.lectura = 22.0
```

Ninguno de los tres mecanismos permite declarar un atributo que la propia clase pueda
modificar y que el código externo solo pueda consultar sin recurrir a una propiedad. La
[PEP 767](https://peps.python.org/pep-0767/) propone cubrir ese hueco con la anotación
`ReadOnly`, aplicable a los atributos de cualquier clase y también a los declarados en
un protocolo, donde sirve para exigir que la implementación exponga el atributo sin
autorizar su modificación. La propuesta se plantea como alternativa más granular a
`Final` y a las _dataclasses_ inmutables, aunque continúa en discusión y todavía no está
disponible en la biblioteca estándar.

Con estos mecanismos y las clases ya descritos, el capítulo de
[biblioteca estándar](section_4_standard_library.md) recorre los módulos más frecuentes,
el manejo de errores y excepciones, el trabajo con archivos y las expresiones regulares.
