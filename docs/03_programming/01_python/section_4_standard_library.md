---
icon: lucide/toolbox
authors: Daniel Bazo Correa
description:
    Módulos de la biblioteca estándar de Python, manejo de errores y excepciones,
    trabajo con archivos y directorios, y expresiones regulares.
title: Biblioteca estándar
---

Este capítulo recorre la biblioteca estándar de Python. Presenta los módulos más
frecuentes y continúa con el manejo de errores y excepciones, el trabajo con archivos y
directorios, y las expresiones regulares. Presupone los capítulos de
[fundamentos](section_2_fundamentals.md) y de
[POO y características avanzadas](section_3_oop_and_advanced.md), ya que varios tipos y
módulos se describen mediante clases y herencia.

## Bibliografía

- Python Software Foundation. (s.f.). _Python 3 Documentation_.
  <https://docs.python.org/3/>

## Módulos de la biblioteca estándar

Python dispone de una amplia colección de módulos en su biblioteca estándar que amplían
las capacidades del lenguaje sin necesidad de instalar paquetes externos. A continuación
se presentan algunos de los más utilizados.

### Módulo `collections`

El módulo `collections` proporciona tipos de datos especializados como `Counter`,
`defaultdict` y `namedtuple`, que son alternativas más eficientes a los contenedores
generales de Python (`dict`, `list`, `set` y `tuple`).

#### `Counter`

`Counter` es una subclase de diccionario para contar elementos de manera rápida.
Almacena los elementos como claves y su recuento como valores:

```python linenums="1"
from collections import Counter

lista: list[int | str] = [1, 1, 1, 2, 2, 3, "a", "adios"]
cuenta: Counter = Counter(lista)

# Devuelve los elementos ordenados de mayor a menor número de apariciones
print(cuenta.most_common())
```

#### `defaultdict`

`defaultdict` es una subclase de `dict` que, cuando se accede a una clave inexistente,
la crea con el valor que produce la factoría indicada en lugar de lanzar un `KeyError`:

```python linenums="1"
from collections import defaultdict

d: defaultdict[str, int] = defaultdict(lambda: 0)

# Imprime: 0
print(d["inexistente"])

# Imprime: defaultdict(<function <lambda> at 0x...>, {'inexistente': 0})
print(d)
```

!!! warning "El acceso inserta la clave"

    `defaultdict` no solo devuelve el valor por defecto, sino que además **añade la
    clave al diccionario**. Tras la consulta del ejemplo, `len(d)` vale 1 y la clave
    `"inexistente"` forma parte del diccionario, algo que resulta sorprendente si solo
    se pretendía comprobar un valor.

    Cuando no se desea ese efecto, la alternativa es
    `dict.get(clave, valor_por_defecto)`, que devuelve el valor indicado sin modificar
    el diccionario.

#### `namedtuple`

`namedtuple` es una subclase de tupla que permite acceder a sus elementos por nombre en
lugar de por índice:

```python linenums="1"
from collections import namedtuple

Conejo = namedtuple("Conejo", ["edad", "color", "nombre"])
misifu = Conejo(edad=2, color="Blanco", nombre="Misifu")

# Imprime: 2
print(misifu.edad)
```

### Módulo `datetime`

El módulo `datetime` permite trabajar con fechas y horas en Python. Es posible crear
objetos de fecha, realizar cálculos y extraer información como el año, el mes o el día:

```python linenums="1"
import datetime
from datetime import date

# Crear un objeto de tiempo
mi_tiempo: datetime.time = datetime.time(2, 20)

# Imprime: 20
print(mi_tiempo.minute)

# Imprime: 02:20:00
print(mi_tiempo)

# Obtener la fecha actual
hoy: date = datetime.date.today()
print(hoy)

# Extraer día, mes y año
print(f"Día: {hoy.day}, Mes: {hoy.month}, Año: {hoy.year}")

# Operaciones con fechas
fecha1: date = date(2021, 11, 3)
fecha2: date = date(2020, 11, 2)

# Imprime: 366 days, 0:00:00
print(fecha1 - fecha2)
```

### Módulo `math`

Es posible extender la funcionalidad con módulos de la biblioteca estándar, incluidos
con la propia instalación de Python, o con paquetes de terceros como NumPy o Pandas. Por
ejemplo, el módulo `math` amplía las operaciones disponibles:

| Operador o función | Descripción                                              |
| ------------------ | -------------------------------------------------------- |
| `math.floor(x)`    | Redondea $x$ hacia abajo, es decir, $\lfloor x \rfloor$. |
| `math.ceil(x)`     | Redondea $x$ hacia arriba, es decir, $\lceil x \rceil$.  |
| `math.sqrt(x)`     | Devuelve la raíz cuadrada de $x$, es decir, $\sqrt{x}$.  |
| `math.pi`          | Devuelve el valor de la constante $\pi$.                 |

Para utilizar estas funciones basta con importar el módulo:

```python linenums="1"
import math

math.floor(3.1415)
```

El módulo proporciona además las constantes y las funciones matemáticas más comunes,
entre ellas los logaritmos y las funciones trigonométricas:

```python linenums="1"
import math

# Imprime: 3.141592653589793
print(math.pi)

# Imprime: 2.718281828459045
print(math.e)

# Logaritmo en base 2 de 100. Imprime: 6.643856189774725
print(math.log(100, 2))

# Función específica de base 2, más precisa. Imprime: 6.643856189774724
print(math.log2(100))

# Funciones trigonométricas. Imprime: 1.0
print(math.sin(math.radians(90)))

# Imprime: 90.0
print(math.degrees(math.pi / 2))
```

!!! note "Precisión de `math.log` frente a `math.log2`"

    Los dos logaritmos anteriores difieren en el último dígito. `math.log(100, 2)`
    calcula el cociente de dos logaritmos naturales y arrastra el error de ambas
    operaciones, mientras que `math.log2(100)` emplea la función específica de la
    biblioteca de C y resulta más precisa. Cuando la base es 2 o 10 conviene emplear
    `math.log2` o `math.log10`.

### Precisión decimal con el módulo `decimal`

Cuando se trabaja con valores monetarios o con cálculos que exigen precisión decimal
exacta, es recomendable emplear el tipo `Decimal` del módulo `decimal` en lugar de
`float`, ya que este último introduce errores de redondeo inherentes a la representación
en punto flotante:

```python linenums="1"
from decimal import Decimal

# Imprime: 0.30000000000000004
print(0.1 + 0.2)

# Imprime: 0.3
print(Decimal("0.1") + Decimal("0.2"))
```

El valor de un `Decimal` debe construirse a partir de una cadena y no de un `float`, ya
que `Decimal(0.1)` heredaría el error de representación del literal en punto flotante.

### Módulo `random`

El módulo `random` genera números pseudoaleatorios y ofrece varias funciones para elegir
elementos aleatoriamente o barajar listas:

```python linenums="1"
import random

# La semilla se fija antes de generar valores para que la secuencia sea reproducible
random.seed(101)

# Número aleatorio entre 0 y 100, ambos incluidos
print(random.randint(0, 100))

# Lista de números del 0 al 9
lista: list[int] = list(range(10))
print(lista)

# Elegir un número aleatorio de la lista
print(random.choice(lista))

# Elegir varios números aleatorios, con posibilidad de repetición
print(random.choices(lista, k=5))

# Elegir varios números aleatorios sin repetición
print(random.sample(lista, k=4))

# Barajar la lista de forma aleatoria, modificándola en el sitio
random.shuffle(lista)
print(lista)
```

!!! warning "No apto para usos criptográficos"

    El módulo `random` genera números **pseudoaleatorios** a partir de un estado interno
    determinista, de modo que fijar la semilla reproduce siempre la misma secuencia. Esa
    propiedad es deseable para poder repetir un experimento, pero inaceptable al generar
    contraseñas, _tokens_ de sesión o claves. Para esos casos existe el módulo
    `secrets`, que se apoya en la fuente de entropía del sistema operativo.

### Módulos `time` y `timeit`

Para evaluar la eficiencia del código, es posible medir el tiempo que una función tarda
en ejecutar una acción específica. El módulo `time` de la biblioteca estándar ofrece una
forma sencilla de hacerlo:

```python linenums="1"
import time

def func_uno(n: int) -> list[str]:
    """
    Construye una lista de cadenas mediante comprensión de listas.

    Args:
        n: Número de elementos que se desean generar.

    Returns:
        La lista de cadenas generada.
    """

    return [str(num) for num in range(n)]

def func_dos(n: int) -> list[str]:
    """
    Construye una lista de cadenas mediante la función map.

    Args:
        n: Número de elementos que se desean generar.

    Returns:
        La lista de cadenas generada.
    """

    return list(map(str, range(n)))

# Paso 1: registrar el tiempo de inicio
tiempo_inicio: float = time.time()

# Paso 2: ejecutar el código que se desea cronometrar
resultado: list[str] = func_uno(1000000)

# Paso 3: calcular el tiempo total de ejecución
tiempo_transcurrido: float = time.time() - tiempo_inicio
print(tiempo_transcurrido)
```

Para mediciones más precisas, se puede utilizar el módulo `timeit`, que permite realizar
múltiples repeticiones y obtener resultados estadísticamente más fiables:

```python linenums="1"
import timeit

# El parámetro setup contiene el código de preparación, que no se cronometra
setup: str = """
def func_uno(n):
    return [str(num) for num in range(n)]
"""

# El parámetro stmt contiene la sentencia cuyo tiempo se desea medir
stmt: str = "func_uno(100)"
print(timeit.timeit(stmt, setup, number=100000))

setup2: str = """
def func_dos(n):
    return list(map(str, range(n)))
"""

stmt2: str = "func_dos(100)"
print(timeit.timeit(stmt2, setup2, number=100000))
```

### Funciones mágicas de Jupyter

Los _notebooks_ de Jupyter ofrecen además las **funciones mágicas**, órdenes propias del
entorno que no forman parte del lenguaje ni de su biblioteca estándar. Existen dos
variantes. Las de línea se escriben con un único signo de porcentaje y afectan solo a la
expresión que las sigue, mientras que las de celda se escriben con dos signos y afectan
a la celda completa:

```python linenums="1"
# Función mágica de línea: cronometra únicamente esta expresión
%timeit func_uno(100)
```

```python linenums="1"
# Función mágica de celda: cronometra todo el contenido de la celda
%%timeit
func_uno(100)
func_dos(100)
```

## Manejo de errores y excepciones

### Validación de datos

Cuando se crean funciones que reciben valores de entrada del usuario, es importante
verificar dichas entradas para asegurarse de que son correctas. Este proceso se conoce
como validación de datos.

La función `input()` en Python puede resultar problemática porque espera la interacción
del usuario. Si se ejecuta accidentalmente dos veces, el programa puede quedarse
esperando una respuesta que no llega. En Jupyter, en ese caso, sería necesario reiniciar
el _kernel_, teniendo en cuenta que todas las variables anteriores se borrarán y habrá
que ejecutarlas de nuevo.

Una forma cómoda de validar datos es utilizar bucles `while` para pedir al usuario que
introduzca un valor repetidamente cuando este no es válido:

```python linenums="1"
def limite(eleccion: str) -> bool:
    """
    Comprueba si el valor introducido está dentro del rango permitido.

    Args:
        eleccion: Cadena que representa el número introducido por el usuario.

    Returns:
        True si el número está entre 1 y 10, False en caso contrario.
    """

    return 1 <= int(eleccion) <= 10

def eleccion_usuario() -> int:
    """
    Solicita al usuario un número entre 1 y 10 hasta obtener un valor válido.

    Returns:
        El número validado introducido por el usuario.
    """

    eleccion: str = input("Número de 1 a 10: ")

    while not eleccion.isdigit() or not limite(eleccion):
        eleccion = input("Número de 1 a 10: ")

        if not eleccion.isdigit():
            print("El valor introducido no es un número")

        if eleccion.isdigit() and not limite(eleccion):
            print("El número introducido supera el límite")

    return int(eleccion)

eleccion_usuario()
```

Para limpiar la consola cuando el usuario introduce valores incorrectos en un _notebook_
de Jupyter, se puede importar y usar la función `clear_output()` del módulo
`IPython.display`:

```python linenums="1"
from IPython.display import clear_output
```

Esta función borra la salida de la celda actual, lo que resulta útil para limpiar los
mensajes de error acumulados al validar la entrada. Solo tiene efecto dentro de un
_notebook_ de Jupyter.

### Excepciones (`try`, `except` y `finally`)

El manejo de errores es una estrategia que permite planificar y gestionar posibles
errores que puedan surgir en el código. Por ejemplo, si un usuario intenta escribir en
un archivo que se ha abierto en modo de solo lectura y no existe ninguna declaración de
error en el código, el programa entero se detendrá. Para evitar esto, se utiliza el
manejo de excepciones, que permite continuar con el programa, notificar el error y
seguir con la ejecución.

Las palabras clave del manejo de errores en Python son las siguientes:

- `try`: Bloque de código que se intenta ejecutar (puede producir un error).
- `except`: Bloque de código que se ejecuta en caso de que haya un error en el bloque
  `try`.
- `else`: Bloque que se ejecuta solo si el bloque `try` termina sin lanzar ninguna
  excepción.
- `finally`: Bloque final de código que se ejecuta independientemente de si hubo un
  error o no.
- `raise`: Vuelve a lanzar la excepción capturada, de modo que se propague hacia el
  código que invocó a la función.

```python linenums="1"
try:
    with open("mi_archivo.txt", "w") as f:
        f.write("Línea de prueba")
except TypeError:
    print("Hubo un problema con el tipo de dato")
except OSError:
    print("Hubo un error de entrada y salida")
except Exception:
    print("Hubo un fallo en otro tipo de excepciones")
finally:
    print("De todos modos, la ejecución continúa")
```

En este otro ejemplo, se pide constantemente un dato al usuario hasta que introduzca un
valor adecuado:

```python linenums="1"
def introducir_entero() -> None:
    """
    Solicita un número entero al usuario hasta que la conversión sea correcta.
    """

    while True:
        try:
            valor: int = int(input("Introduce un número entero: "))
        except ValueError:
            print("El valor introducido no es un número")
        else:
            print(f"El valor {valor} es un valor correcto")
            break

introducir_entero()
```

A partir de Python 3.11, es posible añadir notas adicionales a las excepciones
capturadas mediante el método `add_note`, lo que facilita la depuración al proporcionar
contexto extra sobre el error:

```python linenums="1"
try:
    ...
except Exception as e:
    e.add_note("Contexto adicional sobre el error")
    raise
```

### Depuración

El depurador o _debugger_ se emplea para identificar y corregir errores en el código. En
lugar de utilizar `print()` para inspeccionar el estado del programa, se puede usar el
depurador interactivo de Python, `pdb`:

```python linenums="1"
x: list[int] = [1, 2, 3]
z: int = 2
y: int = 1



# La función breakpoint(), disponible desde Python 3.7, detiene la ejecución e
# inicia el depurador. La forma clásica equivalente es pdb.set_trace()
breakpoint()

# La siguiente línea provoca un TypeError, ya que no es posible sumar int y list
resultado: int = y + x
```

## Trabajo con archivos y directorios

### Lectura y escritura

Es posible abrir un archivo usando la función `open()`:

```python linenums="1"
archivo = open("mi_archivo.txt")
```

El segundo argumento de `open()` indica el modo de apertura, que determina si el archivo
se abre para leer, para escribir o para ambas cosas:

| Modo | Descripción                                                                                                                  |
| ---- | ---------------------------------------------------------------------------------------------------------------------------- |
| `r`  | Solo lectura.                                                                                                                |
| `w`  | Solo escritura, reescribe los archivos existentes o crea uno nuevo.                                                          |
| `a`  | Para añadir información al final del archivo.                                                                                |
| `r+` | Lectura y escritura.                                                                                                         |
| `w+` | Escritura y lectura, reescribe los archivos existentes o crea uno nuevo.                                                     |
| `wb` | Escritura en binario. El sufijo `b` se combina con cualquier modo y hace que se trabaje con `bytes` en lugar de con cadenas. |

Para leer un archivo se pueden utilizar los siguientes métodos:

| Método        | Descripción                                                            |
| ------------- | ---------------------------------------------------------------------- |
| `readable()`  | Devuelve un booleano para saber si se puede leer o no el archivo.      |
| `read()`      | Devuelve todo el contenido restante del archivo como una única cadena. |
| `readline()`  | Devuelve la siguiente línea a partir de la posición actual del cursor. |
| `readlines()` | Devuelve todas las líneas restantes del archivo en una lista.          |

Todos estos métodos operan a partir de la posición del cursor, que avanza con cada
lectura. Así, `readline()` devuelve la primera línea la primera vez que se invoca, la
segunda en la siguiente llamada y una cadena vacía cuando se alcanza el final del
archivo.

```python linenums="1"
nombre_arch: str = input("Nombre del archivo: ")

archivo = open(nombre_arch, "r")

if archivo.readable():
    lista: list[str] = archivo.readlines()

    for empleado in lista:
        print(empleado)

# Es recomendable cerrar el archivo después de trabajar con él
archivo.close()
```

Si se lee un archivo completo con `read()`, una segunda lectura no devuelve nada, porque
el cursor ha quedado al final del contenido. Para volver al principio se emplea
`archivo.seek(0)`.

Otra forma de abrir un archivo y operar con él es mediante el gestor de contexto `with`,
que cierra automáticamente el archivo al finalizar el bloque:

```python linenums="1"
with open("mi_archivo.txt", mode="r") as archivo_abierto:
    contenido: str = archivo_abierto.read()

print(contenido)
```

Un ejemplo de cómo añadir información al final de un archivo:

```python linenums="1"
nombre_arch: str = input("Nombre del archivo: ")
nuevo_empleado: str = input("Nombre del nuevo empleado: ")
funcion_empleado: str = input(f"Puesto del empleado {nuevo_empleado}: ")

with open(nombre_arch, "a") as archivo:
    archivo.write(f"\n{nuevo_empleado} - {funcion_empleado}")
```

### Rutas de archivos con `pathlib`

El módulo `pathlib` proporciona una interfaz orientada a objetos para trabajar con rutas
del sistema de archivos. Su uso resulta más limpio que la manipulación de cadenas de
texto y es multiplataforma, lo que garantiza la compatibilidad entre sistemas
operativos:

```python linenums="1"
from pathlib import Path

# El operador / compone rutas con el separador propio del sistema
ruta: Path = Path("datos") / "archivo.csv"

# Imprime: datos/archivo.csv
print(ruta)

# Componentes de la ruta: nombre completo, nombre sin extensión, extensión y directorio
print(ruta.name, ruta.stem, ruta.suffix, ruta.parent)

# Comprobaciones sobre el sistema de archivos
print(ruta.exists(), ruta.is_file())

# Creación del directorio padre, sin error si ya existe
ruta.parent.mkdir(parents=True, exist_ok=True)
```

Frente a la manipulación de cadenas, `pathlib` evita construir separadores a mano y
concentra en un único objeto tanto la descomposición de la ruta como las operaciones
sobre el sistema de archivos.

### Gestión de directorios

En Python se utilizan varios módulos para la apertura, lectura y manipulación de
archivos y directorios en el sistema operativo. Los módulos principales son `shutil` y
`os`, que permiten realizar operaciones como navegar por los directorios, mover y
eliminar archivos, entre otras. En el siguiente ejemplo se emplea además el paquete
externo `send2trash`, que envía los archivos a la papelera del sistema en lugar de
borrarlos de forma definitiva y que debe instalarse previamente en el entorno virtual:

```python linenums="1"
import os
import shutil

import send2trash

# Creación de un archivo de prueba
with open("Prueba.txt", "w+") as f:
    f.write("Esto es una prueba de escritura en un archivo")

# Obtención del directorio de trabajo actual
print(os.getcwd())

# Listado de los elementos en el directorio de trabajo
print(os.listdir())

# Listado de los elementos en un directorio específico
print(os.listdir("/home/usuario/"))

# Movimiento de archivos entre directorios
shutil.move("Prueba.txt", "/home/usuario/")

# Eliminación segura de archivos, enviándolos a la papelera del sistema
send2trash.send2trash("/home/usuario/Prueba.txt")
```

Python también permite recorrer un directorio completo, con todos sus subdirectorios y
archivos:

```python linenums="1"
import os

directorio: str = "/home/usuario/Escritorio"

for actual, subdirectorios, archivos in os.walk(directorio):
    print(f"Directorio actual: {actual}")
    print("Subdirectorios:")

    for subdirectorio in subdirectorios:
        print(f"\t{subdirectorio}")

    print("Archivos:")

    for archivo in archivos:
        print(f"\t{archivo}")
```

### Manipulación de archivos CSV y JSON

Los archivos CSV (_Comma Separated Values_) son un formato utilizado por Excel y otros
programas de bases de datos. Son útiles para la manipulación de datos, aunque solo
contienen el contenido en crudo, sin imágenes, macros ni formato visual.

En Python se trabaja con el módulo `csv` incluido en la biblioteca estándar. Otras
bibliotecas a considerar para la manipulación de datos son Pandas, Openpyxl o la
interfaz de programación de aplicaciones (_Application Programming Interface_, API) de
Google Sheets para Python.

```python linenums="1"
import csv

# Apertura del archivo y lectura de su contenido como lista de filas
with open("example.csv", encoding="utf-8") as datos:
    lineas_datos: list[list[str]] = list(csv.reader(datos))

correos: list[str] = []

# La primera fila contiene los encabezados, por lo que se omite
for linea in lineas_datos[1:]:
    if linea[3] not in correos:
        correos.append(linea[3])

for numero, correo in enumerate(correos):
    print(f"{numero} : {correo}")
```

Para escribir en un archivo CSV se emplea `csv.writer`, que permite añadir filas
individuales con `writerow` o varias a la vez con `writerows`:

```python linenums="1"
import csv

# El parámetro delimiter indica el carácter que separa una columna de otra
with open("archivo_prueba.csv", mode="w", newline="") as archivo_salida:
    csv_escribir = csv.writer(archivo_salida, delimiter=",")
    csv_escribir.writerow(["a", "b", "c"])
    csv_escribir.writerows([["1", "2", "3"], ["4", "5", "6"]])

# El modo "a" añade la información al final del archivo existente
with open("archivo_prueba.csv", mode="a", newline="") as archivo_salida:
    csv_escribir = csv.writer(archivo_salida)
    csv_escribir.writerow(["Nombre", "Apellido", "Correo"])
    csv_escribir.writerows(
        [
            ["Daniel", "BC", "correo1@example.com"],
            ["Clara", "RA", "correo2@example.com"],
        ]
    )
```

Para trabajar con archivos JSON (_JavaScript Object Notation_) se utiliza el módulo
`json` de la biblioteca estándar:

```python linenums="1"
import json

json_string: str = '{"Nombre":"Antonio", "Apellidos":"Adrian"}'
obj: dict[str, str] = json.loads(json_string)

print(f"Nombre: {obj['Nombre']} \nApellidos: {obj['Apellidos']}")
```

También es posible obtener datos en formato JSON desde una dirección web mediante el
paquete externo `requests`, que debe instalarse previamente en el entorno virtual:

```python linenums="1"
import requests

r = requests.get("https://api.example.com/data", timeout=10)
print(r.json())
```

### Compresión de archivos

El módulo `zipfile` permite crear, leer y extraer archivos comprimidos en formato ZIP
directamente desde Python:

```python linenums="1"
import zipfile

# Creación de archivos de prueba
with open("nuevo_archivo.txt", "w+") as f:
    f.write("Esto es solo un ejemplo de introducción de texto")

with open("nuevo_archivo2.txt", "w+") as f:
    f.write("Un poquito más de texto")

# Creación del archivo comprimido y adición de los archivos
with zipfile.ZipFile("comprimido_1.zip", "w") as archivo_comprimido:
    archivo_comprimido.write("nuevo_archivo.txt", compress_type=zipfile.ZIP_DEFLATED)
    archivo_comprimido.write("nuevo_archivo2.txt", compress_type=zipfile.ZIP_DEFLATED)

# Extracción del contenido del archivo comprimido
with zipfile.ZipFile("comprimido_1.zip", "r") as zip_obj:
    zip_obj.extractall("contenido_extraido")
```

## Expresiones regulares

Las **expresiones regulares** son secuencias de caracteres que definen patrones de
búsqueda dentro de cadenas de texto. En Python, el módulo `re` proporciona todas las
herramientas necesarias para trabajar con ellas de forma eficiente, permitiendo buscar,
extraer, reemplazar y validar texto según patrones específicos.

### Búsqueda de patrones

El módulo `re` ofrece tres funciones para localizar texto. `search()` encuentra la
primera coincidencia de un patrón, `findall()` devuelve todas las coincidencias como
lista y `finditer()` devuelve un iterador con objetos que contienen información
detallada sobre cada coincidencia:

```python linenums="1"
import re

texto: str = "El número del agente es 111-111-1111"
patron: str = "número"

# Localiza la primera coincidencia y devuelve un objeto con su posición
busqueda = re.search(patron, texto)

# Muestra el índice de inicio de la palabra
print(busqueda.start())

# Muestra el índice de finalización de la palabra
print(busqueda.end())

# Para encontrar todas las coincidencias se utiliza findall
texto2: str = "Mi número favorito es el número 8"
busqueda2: list[str] = re.findall("número", texto2)
print(busqueda2)

# Para conocer los índices de cada aparición se utiliza finditer
print("La palabra 'número' está en los siguientes índices:")

for palabra in re.finditer("número", texto2):
    print(f"\t{palabra.span()}")

# El método group() devuelve el texto coincidente
print("\nLa palabra 'número' está en los siguientes índices:")

for palabra in re.finditer("número", texto2):
    print(f"\t{palabra.group()} -> {palabra.span()}")
```

### Sintaxis de patrones

Los patrones en expresiones regulares utilizan secuencias especiales para representar
tipos de caracteres. Por ejemplo, `\d` representa cualquier dígito. Es importante
utilizar el prefijo `r` (_raw string_) para evitar que Python interprete las barras
invertidas como secuencias de escape:

```python linenums="1"
import re

texto: str = "Mi número de teléfono es 11 11 11 111"

# El prefijo r indica a Python que la cadena es un patrón en crudo
numero = re.search(r"\d{2} \d{2} \d{2} \d{3}", texto)
print(numero.group())

# Los paréntesis delimitan grupos, que se tratan en detalle más adelante
numero_grupos = re.compile(r"(\d{2}) (\d{2}) (\d{2}) (\d{3})")
resultado = re.search(numero_grupos, texto)

# Acceso a un grupo específico del resultado
print(resultado.group(4))
```

Las expresiones regulares también permiten buscar alternativas mediante el operador `|`
(o lógico), así como definir patrones basados en la posición o el contexto de los
caracteres:

```python linenums="1"
import re

texto: str = "Tengo una coneja que se llama Misifu"

busq1 = re.search(r"coneja|perro", texto)
print(busq1.group())

texto2: str = "Tengo un perro que se llama Tom"

busq2 = re.search(r"coneja|perro", texto2)
print(busq2.group())

texto_gatos: str = "The cat in the hat sat there"

# El punto representa cualquier carácter, de modo que el patrón localiza
# secuencias de tres caracteres terminadas en 'at'
terminadas_at: list[str] = re.findall(r".at", texto_gatos)
print(terminadas_at)

# Exclusión de caracteres específicos, en este caso los dígitos
frase_con_numeros: str = "there are 3 numbers 34 inside 5 this sentence."
print(re.findall(r"[^\d]+", frase_con_numeros))

# Eliminación de los signos de puntuación
frase_con_puntuacion: str = "This is a string! But it has punctuation. How can we remove it?"
limpia: str = " ".join(re.findall(r"[^!.? ]+", frase_con_puntuacion))
print(limpia)

# Búsqueda de palabras que comparten un prefijo común
texto_gato: str = "Hello, would you like some catfish?"
texto_siesta: str = "Hello, would you like to take a catnap?"
print(re.search(r"cat(fish|nap|claw)", texto_gato).group())
print(re.search(r"cat(fish|nap|claw)", texto_siesta).group())
```

### Clases de caracteres y cuantificadores

Las clases de caracteres permiten definir conjuntos de caracteres que se desea buscar.
Se delimitan con corchetes `[]` y admiten rangos, negaciones y combinaciones:

```python linenums="1"
import re

notas: str = "ACAAAABCBCBAA"

# Buscar todas las calificaciones B
print(re.findall("B", notas))

# Buscar calificaciones A o B
print(re.findall("[AB]", notas))

# Buscar combinaciones AB o AC
print(re.findall("[A][B-C]", notas))

# Expresión equivalente utilizando el operador de alternancia
print(re.findall("AB|AC", notas))

# Negar un conjunto para obtener todo lo que no sea A
print(re.findall("[^A]", notas))

# El símbolo ^ fuera de los corchetes ancla la búsqueda al inicio de la cadena, por
# lo que el resultado es una lista vacía al comenzar la cadena por A
print(re.findall("^[^A]", notas))
```

Los cuantificadores especifican cuántas veces debe aparecer un patrón para considerarse
una coincidencia. La sintaxis básica es `e{m,n}`, donde `e` es la expresión, `m` el
mínimo de repeticiones y `n` el máximo:

```python linenums="1"
import re

notas: str = "ACAAAABCBCBAA"

# Secuencias de entre 2 y 10 letras A consecutivas
print(re.findall("A{2,10}", notas))

# Pares de letras A consecutivas
print(re.findall("A{1,1}A{1,1}", notas))

# Con un único valor, el cuantificador exige exactamente ese número de repeticiones
print(re.findall("A{2}", notas))
```

Es importante tener en cuenta que no se deben incluir espacios dentro de las llaves del
cuantificador, ya que `"A{2, 2}"` devuelve un resultado vacío.

El metacarácter `\w` representa cualquier carácter alfanumérico o el guion bajo, es
decir, el conjunto `[a-zA-Z0-9_]`, ampliado por defecto a las letras y los dígitos de
Unicode. El asterisco `*` indica cero o más repeticiones. El siguiente ejemplo extrae
los encabezados de un artículo de Wikipedia en el que cada encabezado va seguido de
`[edit]`:

```python linenums="1"
import re

with open("datasets/ferpa.txt", "r") as archivo:
    wiki: str = archivo.read()

# Buscar palabras seguidas de [edit] indicando un límite de caracteres
print(re.findall(r"[\w]{1,100}\[edit\]", wiki))

# Expresión equivalente sin límite superior mediante el asterisco
print(re.findall(r"[\w]*\[edit\]", wiki))

# Extraer solo los títulos, descartando la etiqueta [edit]
for titulo in re.findall(r"[\w ]*\[edit\]", wiki):
    print(re.split(r"\[", titulo)[0])
```

### Grupos

Los grupos permiten hacer coincidir diferentes patrones simultáneamente y referirse a
ellos de forma independiente. Se definen con paréntesis:

```python linenums="1"
import re

# La variable wiki contiene el texto leído en el ejemplo anterior

# Agrupar el título y la etiqueta [edit] por separado
print(re.findall(r"([\w ]*)(\[edit\])", wiki))

# Iterar sobre los resultados con finditer
for item in re.finditer(r"([\w ]*)(\[edit\])", wiki):
    print(item.groups())

# Acceder a un grupo específico, teniendo en cuenta que el grupo 0 es la
# coincidencia completa
for item in re.finditer(r"([\w ]*)(\[edit\])", wiki):
    print(item.group(1))
```

Los grupos pueden etiquetarse con nombres mediante la sintaxis `(?P<nombre>...)`, lo que
permite acceder a los resultados como un diccionario:

```python linenums="1"
for item in re.finditer(r"(?P<title>[\w ]*)(?P<edit_link>\[edit\])", wiki):
    print(item.groupdict()["title"])
```

### _Look-ahead_ y _look-behind_

Estas construcciones, denominadas conjuntamente **aserciones de anchura cero**, permiten
exigir que un patrón aparezca en una posición determinada sin incluirlo en el texto
capturado. El _look-ahead_ comprueba lo que viene inmediatamente después y se escribe
`(?=...)`, mientras que el _look-behind_ comprueba lo que precede y se escribe
`(?<=...)`. Ambas admiten la forma negativa, `(?!...)` y `(?<!...)`, que exige que el
patrón **no** aparezca en esa posición.

El siguiente ejemplo captura los títulos que van seguidos de `[edit]` sin arrastrar la
etiqueta al resultado:

```python linenums="1"
import re

for item in re.finditer(r"(?P<title>[\w ]+)(?=\[edit\])", wiki):
    print(item.group("title"))
```

El _look-behind_ opera en sentido contrario. En el ejemplo siguiente se extraen los
importes que van precedidos del símbolo del euro, sin incluir el símbolo en la
coincidencia:

```python linenums="1"
import re

texto: str = "El teclado cuesta €49 y el ratón €25, con 15 unidades en stock"

# Solo se capturan los números precedidos por el símbolo del euro
print(re.findall(r"(?<=€)\d+", texto))

# Imprime: ['49', '25']

# La forma negativa captura los números que NO van precedidos por el símbolo
print(re.findall(r"(?<!€)\b\d+", texto))

# Imprime: ['15']
```

!!! note "Longitud fija en el _look-behind_"

    El módulo `re` exige que la expresión de un _look-behind_ tenga una longitud fija,
    por lo que `(?<=€|USD)` no es válido y produce un error de compilación del patrón.
    El _look-ahead_ no tiene esa restricción. Cuando se necesita una anchura variable
    hay que recurrir al paquete externo `regex`, que sí la admite.

También es posible repartir un patrón largo en varias líneas mediante la bandera
`re.VERBOSE`, que ignora los espacios en blanco no escapados y admite comentarios dentro
del propio patrón. Por esa razón, los espacios que forman parte de la búsqueda deben
escribirse como `\ `:

```python linenums="1"
patron: str = r"""
(?P<title>.*)          # Nombre de la universidad
(–\ located\ in\ )     # Indicación de localización
(?P<city>\w*)          # Ciudad
(,\ )                  # Separador
(?P<state>\w*)         # Estado
"""

with open("datasets/universidades.txt", "r") as archivo:
    universidades: str = archivo.read()

for item in re.finditer(patron, universidades, re.VERBOSE):
    print(item.groupdict())
```

Para más información sobre expresiones regulares, se puede consultar la
[documentación oficial](https://docs.python.org/3/library/re.html) y utilizar
herramientas como [regex101](https://regex101.com/) para depurar patrones.

El capítulo de [librerías](section_5_libraries.md) recopila paquetes de terceros que
amplían lo visto aquí, y el de [entornos virtuales](section_1_environments.md) describe
cómo declararlos como dependencia del proyecto.
