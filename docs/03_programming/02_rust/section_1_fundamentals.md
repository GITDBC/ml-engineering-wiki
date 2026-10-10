---
authors: Daniel Bazo Correa
description:
    Variables, tipos de datos, ownership, borrowing, slices y control de flujo en Rust,
    junto con el uso de Cargo.
title: Fundamentos
---

Este capítulo introduce Rust como lenguaje de sistemas y recorre su sistema de tipos, el
uso de Cargo como herramienta de proyecto, las estructuras de control del lenguaje y el
modelo de _ownership_ y _borrowing_ que constituye su rasgo más distintivo.

## Bibliografía

- Klabnik, S. y Nichols, C. (2023). _The Rust Programming Language_.
  <https://doc.rust-lang.org/book/>

## Introducción

<figure markdown="span">
  ![Logo de Rust](../../assets/img/docs/logos/rust-logo.png)
  <figcaption>Logo de Rust.</figcaption>
</figure>

**Rust** es un lenguaje de programación de sistemas cuyo diseño persigue tres objetivos
simultáneos: la seguridad de memoria, la ausencia de _data races_ en código concurrente
y un rendimiento comparable al de C y C++.

Otros lenguajes delegan la gestión de la memoria en un _garbage collector_, un
componente del entorno de ejecución que recupera de forma periódica la memoria de los
objetos que ya no son alcanzables desde el programa. Ese mecanismo libera al programador
de la gestión manual, pero actúa en tiempo de ejecución y en momentos que no resultan
predecibles. Rust adopta una vía distinta: un sistema de _ownership_ (propiedad) que
verifica la corrección del uso de la memoria durante la compilación. El enfoque elimina
categorías enteras de errores frecuentes, como los accesos a memoria ya liberada o los
_data races_, sin introducir penalización alguna en tiempo de ejecución.

!!! note "_Data race_ frente a condición de carrera"

    Un _data race_ es la situación en la que dos o más hilos acceden de forma
    concurrente a una misma variable compartida, al menos uno de ellos la escribe y no
    existe sincronización entre ellos. El subconjunto seguro del lenguaje, esto es, el
    código que no recurre a bloques `unsafe`, previene esta situación en tiempo de
    compilación.

    Una condición de carrera (_race condition_) es un concepto más amplio: cualquier
    error en el que el comportamiento del programa dependa del orden o de la
    temporización con que se ejecutan varios hilos, procesos o tareas concurrentes, sin
    que ese orden esté garantizado. Rust no elimina las condiciones de carrera lógicas
    ni los interbloqueos, ya que ambos dependen del diseño del programa y no de la
    seguridad de memoria.

El lenguaje resulta especialmente adecuado para el desarrollo de software de sistemas,
herramientas de línea de comandos, servicios web de alto rendimiento y cualquier
contexto en el que el control preciso sobre los recursos sea un requisito. El capítulo
de [librerías](section_2_libraries.md) recopila los _crates_ más útiles para estos
casos.

### Primer programa

Todo programa en Rust comienza su ejecución en la función `main`, que actúa como punto
de entrada obligatorio.

???+ example "Hola mundo"

    La función `main` invoca `println!` para escribir una línea en la salida estándar.

    ```rust linenums="1"
    fn main() {
        println!("Hola mundo");
    }
    ```

    El signo de exclamación de `println!` indica que se trata de una **macro** y no de
    una función convencional, lo que significa que genera código adicional en tiempo de
    compilación para extender la sintaxis del lenguaje.

## Compilación y gestión del proyecto

Antes de recorrer el lenguaje conviene conocer las herramientas con las que se compila y
se organiza un proyecto de Rust, ya que todos los ejemplos posteriores se ejecutan a
través de ellas.

### Compilación directa con `rustc`

El compilador de Rust (`rustc`) permite compilar archivos fuente de forma directa, sin
necesidad de un gestor de proyectos. Los archivos de código fuente utilizan la extensión
`.rs`. Una vez compilado, se genera un binario ejecutable con el mismo nombre que el
archivo fuente:

```bash linenums="1"
# Compilar un archivo fuente
rustc main.rs

# Ejecutar el binario generado
./main
```

El binario resultante no requiere que Rust esté instalado en la máquina que lo ejecuta,
aunque sí exige que esta comparta sistema operativo y arquitectura con la que lo
compiló. En GNU/Linux el objetivo por defecto se enlaza además de forma dinámica contra
la biblioteca estándar de C del sistema, de modo que también necesita una versión
compatible de esta.

### Cargo

**Cargo** es la herramienta oficial de Rust e integra la gestión de dependencias, la
compilación del código y la ejecución de pruebas en un único flujo de trabajo. Se
instala junto con el compilador y su versión puede consultarse con `cargo --version`.

Al crear un proyecto, Cargo genera la estructura de directorios necesaria junto con un
archivo `Cargo.toml` que describe las dependencias y la configuración. Espera encontrar
el código fuente en el directorio `src/`. Conviene trabajar siempre desde la raíz del
proyecto, ya que el analizador del lenguaje (`rust-analyzer`) localiza el `Cargo.toml`
en ese directorio y de ello dependen el autocompletado y los diagnósticos en el editor.

A continuación se recogen los comandos más relevantes de Cargo. Como en otras
herramientas, la opción `help` permite consultar los argumentos, las opciones y los
comandos que no se reflejan aquí:

```bash linenums="1"
# Verificar la versión instalada
cargo --version

# Crear un nuevo proyecto (genera Cargo.toml y src/main.rs)
cargo new nombre_proyecto

# Inicializar un proyecto en un directorio existente
cargo init

# Verificar que el código compila sin generar ejecutable (más rápido)
cargo check

# Compilar el proyecto (genera el binario en target/debug/)
cargo build

# Compilar y ejecutar en modo debug
cargo run

# Compilar y ejecutar en modo silencioso (oculta mensajes de compilación)
cargo run -q

# Compilar y ejecutar en modo release (con optimizaciones)
cargo run --release

# Ejecutar las pruebas del proyecto
cargo test

# Aplicar el formato estándar del lenguaje
cargo fmt

# Analizar el código en busca de errores y de código poco idiomático
cargo clippy
```

Los dos últimos comandos requieren los componentes `rustfmt` y `clippy`, que `rustup`
instala por defecto con la cadena de herramientas estable.

La diferencia entre ambos modos de compilación es relevante. El modo _debug_ inserta
comprobaciones adicionales, como la detección del desbordamiento aritmético, y genera
código sin optimizar para facilitar la depuración. El modo _release_ produce un binario
optimizado, destinado a producción. Además, si el código fuente no ha cambiado desde la
compilación anterior, Cargo no lo recompila, lo que acelera el ciclo de desarrollo.

!!! tip "Flujo de trabajo recomendado"

    Durante el desarrollo es preferible emplear `cargo check` para verificar con rapidez
    que el código compila, ya que no genera ejecutable, y reservar `cargo build` o
    `cargo run` para cuando se necesite ejecutar realmente el programa.

???+ example "Ejemplo de archivo `Cargo.toml`"

    El archivo declara los metadatos del paquete, los perfiles de compilación y las
    dependencias del proyecto.

    ```toml linenums="1"
    [package]
    name = "knp"
    version = "0.2.6"
    edition = "2024"
    authors = ["Daniel Bazo Correa"]
    license = "MIT"
    description = "Kindle Notes Parser (knp) is a CLI tool."
    readme = "README.md"
    homepage = "https://github.com/danibcorr/kindle-notes-parser"
    repository = "https://github.com/danibcorr/kindle-notes-parser"
    keywords = ["cli", "kindle"]
    categories = ["command-line-utilities"]

    [profile.dev]
    opt-level = 0

    [profile.release]
    opt-level = 3
    lto = true
    strip = true

    [dependencies]
    clap = { version = "4.6.1", features = ["derive", "color", "suggestions"] }
    console = "0.16.3"
    ctrlc = "3.5.2"
    dialoguer = "0.12.0"
    ```

### Perfiles de compilación

El ejemplo anterior define dos perfiles de compilación, uno para el desarrollo y otro
para las versiones finales del proyecto. Cada perfil determina cómo debe compilar Rust
el código según el modo que se solicite.

El perfil `[profile.dev]` se aplica al ejecutar `cargo build` o `cargo run`. La opción
`opt-level = 0` desactiva todas las optimizaciones del compilador. El código resultante
no es el más rápido en ejecución, pero a cambio la compilación es mucho más ágil y la
depuración resulta fiable, ya que el binario mantiene una correspondencia exacta con las
líneas del código fuente.

El perfil `[profile.release]` se aplica al ejecutar `cargo build --release` o
`cargo run --release`, y en el ejemplo combina tres opciones:

- `opt-level = 3` activa el nivel máximo de optimizaciones, con el fin de aprovechar al
  máximo el rendimiento del procesador.
- `lto = true` habilita la optimización en tiempo de enlazado (_Link-Time
  Optimization_). En lugar de optimizar cada _crate_ por separado, el compilador analiza
  el árbol de dependencias completo y aplica optimizaciones globales, como la
  eliminación de código muerto que atraviesa las fronteras entre _crates_. El resultado
  es un binario más pequeño y rápido, a costa de un tiempo de compilación mayor.
- `strip = true` elimina del ejecutable final la información de depuración y la tabla de
  símbolos, lo que reduce de forma notable su tamaño en disco.

!!! note "Qué es un _crate_"

    Un _crate_ es la unidad de compilación de Rust. Puede tratarse de una dependencia
    externa descargada desde [crates.io](https://crates.io/) o de un módulo propio del
    proyecto. El compilador procesa cada _crate_ como un todo, y esa granularidad es la
    que la optimización en tiempo de enlazado permite superar.

### Documentación

Rust incluye una copia local de la documentación oficial que puede consultarse sin
conexión a internet mediante `rustup doc`, que la abre en el navegador. Si no está
instalada, se añade con el siguiente comando:

```bash linenums="1"
rustup component add rust-docs
rustup doc
```

## Variables y constantes

En Rust las variables se declaran con la palabra clave `let` y son **inmutables por
defecto**. Esta decisión de diseño favorece la escritura de código más seguro y
predecible, ya que obliga a ser explícito cuando se desea permitir la modificación de un
valor. Para declarar una variable mutable se añade la palabra clave `mut` tras `let`.

Las **constantes**, por su parte, se declaran con `const` y requieren siempre una
anotación de tipo explícita. A diferencia de las variables inmutables, las constantes se
evalúan en tiempo de compilación y no pueden declararse como mutables bajo ninguna
circunstancia.

???+ example "Variables mutables y constantes"

    El siguiente programa modifica una variable mutable y declara una constante con su
    tipo explícito.

    ```rust linenums="1"
    fn main() {
        // Variable mutable: permite modificar su valor
        let mut contador: i32 = 4;
        contador += 1;
        println!("{}", contador);

        // Constante: inmutable, tipo obligatorio, evaluada en compilación
        const CONSTANTE: u8 = 6;
        println!("{}", CONSTANTE);
    }
    ```

### _Shadowing_

El _shadowing_ consiste en redeclarar una variable con el mismo nombre mediante una
nueva sentencia `let`. A diferencia de la mutabilidad, el _shadowing_ crea una variable
completamente nueva que puede incluso tener un tipo distinto al de la original. La
variable anterior deja de ser accesible en el _scope_ actual, aunque conserva su valor
en los _scopes_ superiores si la redeclaración ocurre dentro de un bloque anidado.

!!! note "_Shadowing_ frente a mutabilidad"

    La mutabilidad (`mut`) modifica el valor de una variable conservando su tipo,
    mientras que el _shadowing_ crea una variable nueva que puede cambiar de tipo. Por
    ello el _shadowing_ no requiere que la variable sea mutable.

???+ example "_Shadowing_ en distintos _scopes_"

    El valor redeclarado dentro del bloque no altera el valor original del _scope_
    superior, y una redeclaración posterior permite cambiar de tipo.

    ```rust linenums="1"
    fn main() {
        let n = 5;

        {
            // Shadowing dentro de un scope diferente
            let mut n = 6;
            println!("Valor de n dentro: {}", n); // 6

            n += 1;
            println!("Valor de n dentro: {}", n); // 7
        }

        // El valor original permanece inalterado fuera del bloque
        println!("Valor de n fuera: {}", n); // 5

        // Shadowing con cambio de tipo
        let numero: i32 = 4;
        println!("{}", numero);

        let numero: &str = "Hola";
        println!("{}", numero);
    }
    ```

## Tipos de datos

### Números enteros

Rust proporciona tipos enteros con y sin signo en diversos tamaños: `i8` y `u8`, `i16` y
`u16`, `i32` y `u32`, `i64` y `u64`, `i128` y `u128`, además de `isize` y `usize`. Estos
dos últimos tienen un tamaño que depende de la arquitectura del sistema donde se ejecuta
el programa. Ocupan 64 bits en sistemas de 64 bits y 32 bits en sistemas de 32 bits.

!!! note

    El tipo `usize` se utiliza habitualmente para indexar colecciones, ya que representa
    un valor sin signo del tamaño de un puntero.

!!! warning "Desbordamiento aritmético"

    El comportamiento ante un desbordamiento aritmético (_overflow_) depende del modo de
    compilación. En modo _debug_ el compilador inserta comprobaciones que provocan un
    `panic!` en tiempo de ejecución, lo que detiene el programa e informa del problema.
    En modo _release_ esas comprobaciones desaparecen y se aplica _wrapping_: el valor
    desborda de forma silenciosa y vuelve al inicio del rango, con resultados que pueden
    ser inesperados. El mismo principio se aplica al _underflow_, cuando un valor
    desciende por debajo del mínimo representable para su tipo.

    Existe un caso distinto. Cuando la operación puede evaluarse durante la compilación,
    como en `let x: u8 = 255 + 1;`, `rustc` la rechaza directamente y no llega a generar
    el binario. Para controlar el comportamiento de forma explícita conviene emplear los
    métodos `checked_add`, `saturating_add` o `wrapping_add`, y sus equivalentes para el
    resto de operaciones.

Para mejorar la legibilidad de literales numéricos extensos, Rust admite guiones bajos
como separadores visuales, tanto en enteros como en decimales. Estos separadores no
afectan al valor y el compilador los ignora, si bien no pueden aparecer al principio del
literal ni justo después del punto decimal.

???+ example "Rangos de valores y separadores visuales"

    Las constantes asociadas `MAX` y `MIN` exponen los límites de cada tipo. La salida
    corresponde a una arquitectura de 64 bits.

    ```rust linenums="1"
    fn main() {
        println!("Valor máximo usize: {}", usize::MAX);
        println!("Valor mínimo usize: {}", usize::MIN);

        println!("Valor máximo isize: {}", isize::MAX);
        println!("Valor mínimo isize: {}", isize::MIN);

        // Separadores visuales para legibilidad
        let variable_millon: i32 = 1_000_000;
        println!("Valor: {}", variable_millon);

        // También aplicable a decimales
        let pi: f32 = 3.141_592_7;
        println!("Pi: {}", pi);
    }
    ```

### Punto flotante

Los tipos de punto flotante `f32` y `f64` siguen el estándar IEEE 754 para la
representación de números reales en formato binario. Debido a las limitaciones
inherentes de esta representación, determinados valores decimales no pueden expresarse
de forma exacta, lo que introduce pequeños errores de precisión. Este comportamiento no
es exclusivo de Rust, sino que afecta a cualquier lenguaje que utilice aritmética de
punto flotante.

!!! warning "Comparación de valores de punto flotante"

    La comparación directa entre valores de punto flotante mediante el operador `==`
    resulta poco fiable. La práctica recomendada consiste en calcular la diferencia
    absoluta entre ambos valores y verificar que sea inferior a un umbral de tolerancia,
    habitualmente representado por la constante `f64::EPSILON`.

???+ example "Comparación segura de flotantes"

    La suma `0.1 + 0.2` no produce exactamente `0.3`, por lo que la comparación por
    tolerancia devuelve el resultado esperado mientras que la comparación directa no.

    ```rust linenums="1"
    fn main() {
        let a: f64 = 0.1;
        let b: f64 = 0.2;
        let c: f64 = a + b;
        const VALOR_ESPERADO: f64 = 0.3;

        // El resultado no es exactamente 0.3 (produce 0.30000000000000004)
        println!("¿c == 0.3?: {}", c == VALOR_ESPERADO); // false

        // Comparación correcta mediante tolerancia
        println!("¿c ≈ 0.3?: {}", (c - VALOR_ESPERADO).abs() < f64::EPSILON);
    }
    ```

### Booleanos y caracteres

El tipo `bool` representa valores lógicos y admite únicamente dos estados, `true` o
`false`. Se utiliza de forma habitual en expresiones condicionales y bucles.

El tipo `char` representa un único carácter Unicode y ocupa 4 bytes en memoria, lo que
permite almacenar cualquier carácter del estándar, incluidos los _emojis_ y los
caracteres de escrituras no latinas.

???+ example "Valores booleanos y caracteres"

    Un valor `bool` y un `char` se declaran e imprimen igual que cualquier otro tipo
    básico.

    ```rust linenums="1"
    fn main() {
        let conectado: bool = false;
        println!("Conectado: {}", conectado);

        let letra: char = 'z';
        println!("Letra: {}", letra);
    }
    ```

### Cadenas de texto

Rust distingue dos representaciones para el texto. El tipo `String` es una cadena que el
programa posee, que reside en el montículo y que puede crecer o modificarse. El tipo
`&str`, en cambio, es una referencia de solo lectura a una secuencia de caracteres que
pertenece a otro sitio, y es el tipo que tiene cualquier literal escrito entre comillas
dobles.

La conversión entre ambos es habitual. `String::from("Hola")` o `"Hola".to_string()`
construyen una `String` a partir de un literal, mientras que `&mi_cadena` obtiene un
`&str` que apunta al contenido de una `String` existente. Como norma práctica, un
parámetro de función se declara `&str` para aceptar ambas formas, y se reserva `String`
para cuando la función deba conservar el valor.

???+ example "Cadenas propias y prestadas"

    El literal es un `&str`, la cadena construida con `String::from` es propia y admite
    modificaciones, y la función acepta indistintamente ambas gracias a la conversión
    automática.

    ```rust linenums="1"
    fn longitud(texto: &str) -> usize {
        return texto.chars().count();
    }

    fn main() {
        // Literal: referencia de solo lectura a datos del propio ejecutable
        let saludo: &str = "Hola";

        // Cadena propia, alojada en el montículo y modificable
        let mut nombre: String = String::from("Dani");
        nombre.push_str(" Bazo");

        println!("{} {}", saludo, nombre);

        // Ambas formas se aceptan donde se espera un &str
        println!("{} {}", longitud(saludo), longitud(&nombre));
    }
    ```

### Conversión de tipos

Rust no realiza conversiones de tipo de forma implícita. Para efectuar un _casting_
explícito entre tipos numéricos se utiliza la palabra clave `as`, que admite cambiar el
tamaño de un entero, convertir enteros a flotantes o transformar un carácter en su punto
de código Unicode.

!!! warning "`as` no comprueba el resultado"

    El operador `as` no verifica que el valor de origen quepa en el tipo de destino. Si
    no cabe, la conversión trunca, satura o reinterpreta el signo sin emitir ningún
    aviso. Así, `300i32 as u8` produce `44`, `-1i32 as u32` produce `4294967295` y
    `3.9e10f64 as i32` satura en `2147483647`.

    Cuando la conversión debe fallar de forma detectable, la alternativa es el _trait_
    `TryFrom` a través del método `try_into()`, que devuelve un `Result`, el tipo que
    representa el resultado de una operación que puede fallar, y permite tratar el caso
    en el que el valor no es representable.

Para convertir cadenas de texto a tipos numéricos se utiliza el método `.parse()`, que
devuelve un `Result` y requiere gestión de errores, habitualmente mediante `.expect()` o
_pattern matching_.

!!! tip "Limpieza previa a la conversión"

    Es recomendable aplicar `.trim()` antes de `.parse()` para eliminar los espacios en
    blanco o los saltos de línea que puedan interferir con la conversión.

???+ example "_Casting_ con `as` y conversión de cadenas"

    El programa convierte una cadena a `i32`, opera con una constante y transforma un
    carácter en su punto de código Unicode.

    ```rust linenums="1"
    const MULTIPLICADOR: u32 = 2;

    fn main() {
        let entrada_usuario = "100";
        let convertido: i32 = entrada_usuario
            .parse()
            .expect("Error al convertir de str a número");

        println!("Resultado: {}", convertido * MULTIPLICADOR as i32);

        let caracter: char = 'A';
        let codigo_unicode: u32 = caracter as u32;
        println!("Punto de código de 'A': {}", codigo_unicode);
    }
    ```

## Tipos compuestos

### Tuplas

Las tuplas permiten agrupar un número fijo de valores que pueden ser de tipos
diferentes. El acceso a los elementos individuales se realiza mediante notación de punto
seguida del índice posicional, que comienza en cero, o bien mediante _destructuring_,
que asigna cada componente a una variable independiente en una sola sentencia.

Existe un caso especial denominado _unit_ (`()`), que es una tupla vacía. En Rust la
_unit_ representa la ausencia de valor y constituye el tipo de retorno implícito de las
funciones que no devuelven nada de forma explícita.

???+ example "Acceso y _destructuring_ de tuplas"

    Se accede a los elementos por índice y por _destructuring_, se emplea una tupla como
    parámetro de función y se muestra una tupla con tipos mixtos mediante el formato de
    _debug_ `{:?}`.

    ```rust linenums="1"
    fn calcular_distancia(coord_1: (f32, f32), coord_2: (f32, f32)) -> f32 {
        // Distancia euclídea: se elevan al cuadrado las diferencias, no las coordenadas
        return ((coord_2.0 - coord_1.0).powi(2) + (coord_2.1 - coord_1.1).powi(2)).sqrt();
    }

    fn main() {
        let tupla: (i32, i32) = (1, 2);
        println!("x: {}, y: {}", tupla.0, tupla.1);

        // Destructuring
        let (a, b) = tupla;
        println!("x: {}, y: {}", a, b);

        // La tupla permite agrupar los parámetros de una función
        println!("Distancia: {}", calcular_distancia((1.0, 1.0), (4.0, 5.0))); // 5

        // Tuplas con tipos mixtos
        let tupla: (&str, u8, i32) = ("Hola", 1, 6);
        println!("Valores: {:?}", tupla);

        // Unit: tupla vacía
        let _vacia: () = ();
    }
    ```

### _Arrays_

Los _arrays_ en Rust tienen un tamaño fijo que debe conocerse en tiempo de compilación,
porque la longitud forma parte del propio tipo, que se escribe `[T; N]`. Todos los
elementos deben ser del mismo tipo. Un _array_ almacena sus elementos de forma contigua
y en el mismo lugar donde reside el propio _array_, de modo que una variable local
guarda todos sus elementos junto al resto de los datos de la función.

También es posible inicializar un _array_ con un valor repetido mediante la sintaxis
`[valor; cantidad]`, que resulta útil cuando se necesita una colección de tamaño fijo
con todos sus elementos idénticos.

???+ example "Declaración e indexado de _arrays_"

    El ejemplo accede al primer y al último elemento y crea un _array_ inicializado con
    un valor repetido.

    ```rust linenums="1"
    fn main() {
        let lista: [i32; 3] = [1, 2, 3];
        println!("Contenido: {:?}", lista);

        let nombres: [&str; 4] = ["hola", "adiós", "hello", "bye"];
        println!("Primer elemento: {}", nombres[0]);
        println!("Último elemento: {}", nombres[nombres.len() - 1]);

        // Inicialización con valor repetido
        let repetido = ["Dani"; 5];
        println!("Repetido: {:?}", repetido);
    }
    ```

### Vectores

Los vectores (`Vec<T>`) constituyen la alternativa dinámica a los _arrays_. Su tamaño
puede crecer o decrecer en tiempo de ejecución, ya que almacenan sus datos en el _heap_.
Se crean habitualmente mediante la macro `vec![]`, que permite inicializarlos con
valores predefinidos, y admiten añadir elementos con el método `.push()`.

???+ example "Creación y ampliación de un vector"

    Un vector inicializado con `vec![]` crece de forma dinámica al añadir un elemento
    con `.push()`.

    ```rust linenums="1"
    fn main() {
        let mut vector: Vec<&str> = vec!["Dani", "Jorge", "Fran"];
        vector.push("Paco");
        println!("Vector: {:?}", vector);
    }
    ```

## Funciones

Las funciones se definen con la palabra clave `fn` seguida del nombre, los parámetros
entre paréntesis y, de forma opcional, el tipo de retorno indicado con `->`. Cada
parámetro requiere una anotación de tipo explícita. El valor de retorno puede
especificarse mediante la palabra clave `return` o, de forma idiomática en Rust,
omitiendo el punto y coma en la última expresión del cuerpo.

La macro `dbg!` resulta especialmente útil durante el desarrollo, ya que imprime el
archivo, la línea y el valor de una expresión en la salida de error estándar, lo que
facilita la depuración sin necesidad de configurar un depurador completo.

!!! warning "_Ownership_ en `dbg!`"

    La macro `dbg!` toma el _ownership_ del valor que recibe, por lo que la variable no
    podrá utilizarse después de la llamada. Para evitar este comportamiento se debe
    pasar una referencia, esto es, `dbg!(&variable)`.

???+ example "Definición de funciones y depuración con `dbg!`"

    Se muestran las dos formas de devolver un valor, con y sin `return`, y el uso de
    `dbg!` sobre una referencia. La salida de `dbg!` se dirige a la salida de error
    estándar e incluye el archivo y la línea de la llamada.

    ```rust linenums="1"
    fn imprimir_nombre(nombre: &str) {
        println!("Hola {}!", nombre);
    }

    fn sumar_valores(valor_1: i32, valor_2: i32) -> isize {
        return (valor_1 + valor_2) as isize;
    }

    fn sumar_valores_sin_return(valor_1: i32, valor_2: i32) -> isize {
        (valor_1 + valor_2) as isize
    }

    fn main() {
        imprimir_nombre("Dani");

        let resultado = sumar_valores(1, 2);
        dbg!(&resultado);

        let resultado_alternativo = sumar_valores_sin_return(3, 4);
        dbg!(&resultado_alternativo);
    }
    ```

### Sentencias y expresiones

Las **sentencias** realizan una acción pero no producen un valor utilizable, como ocurre
con un `let`, mientras que las **expresiones** se evalúan y producen un resultado que
puede asignarse a una variable o emplearse en otro contexto.

En Rust un bloque delimitado por llaves `{}` es siempre una expresión. Su valor es el de
la última expresión que contenga, siempre que esta no termine en punto y coma. Si el
bloque termina en una sentencia, su valor es la _unit_ (`()`). Esta característica
permite construir asignaciones complejas de forma concisa y legible.

???+ example "Bloques como expresiones"

    La macro `dbg!` devuelve el valor evaluado, y un bloque cuya última línea no termina
    en punto y coma produce un valor asignable.

    ```rust linenums="1"
    fn main() {
        // dbg! es una expresión que devuelve el valor evaluado
        let resultado: i32 = dbg!(20 + 30);
        println!("Resultado: {}", resultado); // 50

        // Bloque como expresión (sin punto y coma en la última línea)
        let suma = {
            let x = 1;
            let y = 2;
            x + y
        };
        println!("Suma: {}", suma); // 3
    }
    ```

## Control de flujo

### Condicionales

La estructura `if`/`else` en Rust funciona de manera similar a la de otros lenguajes,
con la particularidad de que puede utilizarse como expresión para asignar valores
directamente. Las condiciones no requieren paréntesis, aunque las llaves que delimitan
cada bloque son obligatorias.

???+ example "`if`/`else` como sentencia y como expresión"

    El programa lee una línea de la entrada estándar y utiliza `if` tanto para decidir
    un mensaje como para asignar el valor de una variable.

    ```rust linenums="1"
    use std::io;

    const LONGITUD_MINIMA: u8 = 10;

    fn main() {
        let mut entrada: String = String::new();
        println!("Introduce un valor: ");
        io::stdin().read_line(&mut entrada).expect("Error de lectura");

        let longitud = entrada.trim().len();

        if longitud >= LONGITUD_MINIMA as usize {
            println!("Longitud suficiente");
        } else {
            println!("Demasiado corto");
        }

        // Uso de if como expresión para asignar un valor
        let paridad: &str = if longitud % 2 == 0 { "par" } else { "impar" };
        println!("La longitud es {}", paridad);
    }
    ```

### Coincidencia de patrones

La expresión `match` compara un valor contra una serie de patrones y ejecuta el brazo
del primero que coincida. El compilador exige que los brazos cubran todos los casos
posibles, lo que evita olvidos al tratar tipos con un número cerrado de variantes. Esta
comprobación de exhaustividad es la razón por la que `match` resulta más seguro que una
cadena de condicionales.

El método `.cmp()` de los tipos numéricos ilustra bien el mecanismo. Devuelve un valor
del tipo `Ordering`, cuyas tres variantes son `Ordering::Less`, `Ordering::Equal` y
`Ordering::Greater`, de modo que un `match` sobre su resultado debe tratar las tres.

???+ example "Comparación con `match`"

    El `match` cubre las tres variantes de `Ordering`. Si se omitiera una, el programa
    no compilaría.

    ```rust linenums="1"
    use std::cmp::Ordering;

    fn main() {
        let objetivo = 7;
        let intento = 4;

        match intento.cmp(&objetivo) {
            Ordering::Less => println!("El intento es menor"),
            Ordering::Equal => println!("El intento coincide"),
            Ordering::Greater => println!("El intento es mayor"),
        }

        // El guion bajo actúa como brazo por defecto para el resto de los casos
        let codigo = 404;

        match codigo {
            200 => println!("Correcto"),
            404 => println!("No encontrado"),
            _ => println!("Otro código"),
        }
    }
    ```

### Bucles

Rust proporciona tres construcciones para la iteración. El bucle `loop` crea una
repetición infinita que solo se interrumpe mediante `break`. El bucle `while` evalúa una
condición antes de cada iteración y continúa mientras esta sea verdadera. El bucle `for`
itera sobre los elementos de un iterador y constituye la forma más idiomática y segura
de recorrer colecciones.

Cuando se trabaja con bucles anidados, Rust permite asignar etiquetas (_labels_) a cada
bucle mediante la sintaxis `'nombre_etiqueta:`. Estas etiquetas posibilitan el uso de
`break` y `continue` dirigidos a un bucle concreto, lo que resulta útil para salir de
varios niveles de anidamiento de forma controlada.

???+ example "Los tres tipos de bucle y las etiquetas"

    El bucle `while` imprime una cuenta atrás y el bucle `for` recorre un vector con
    `enumerate`. Los bucles `loop`, incluidos los anidados con etiquetas, no producen
    salida en este ejemplo.

    ```rust linenums="1"
    fn main() {
        // loop: bucle infinito con break explícito
        let mut contador: u8 = 0;
        loop {
            if contador >= 10 {
                break;
            }
            contador += 1;
        }

        // while: evalúa la condición antes de cada iteración
        let mut n = 3;
        while n > 0 {
            println!("{}", n);
            n -= 1;
        }

        // for con enumerate para obtener índice y valor
        let vector: Vec<i32> = vec![1, 2, 3, 4, 5];
        for (indice, elemento) in vector.iter().enumerate() {
            println!("Índice: {}, Elemento: {}", indice, elemento);
        }

        // Etiquetas en bucles anidados
        let mut contador_principal: u8 = 0;

        'loop_principal: loop {
            contador_principal += 1;
            let mut contador_interno: u8 = 0;

            'loop_interno: loop {
                contador_interno += 1;

                if contador_interno == 10 {
                    break 'loop_interno;
                }
                if contador_principal == 10 {
                    break 'loop_principal;
                }
            }
        }
    }
    ```

El siguiente ejemplo integra buena parte de lo visto hasta aquí. Requiere añadir el
_crate_ `rand` a la sección `[dependencies]` del `Cargo.toml` con la versión `0.9`, ya
que la generación de números aleatorios no forma parte de la biblioteca estándar de
Rust.

???+ example "Juego de adivinar"

    El programa combina entrada y salida estándar, constantes, bucles, _pattern
    matching_ con `match` y el uso de una dependencia externa.

    ```rust linenums="1"
    use rand::random_range;
    use std::cmp::Ordering;
    use std::io;

    const VALOR_MINIMO: i32 = 0;
    const VALOR_MAXIMO: i32 = 10;
    const NUM_INTENTOS: u8 = 3;

    fn solicitar_valor() -> i32 {
        println!("Introduce un valor: ");
        let mut entrada = String::new();
        io::stdin().read_line(&mut entrada).expect("Error de lectura");
        return entrada.trim().parse().expect("No es un valor válido");
    }

    fn main() {
        let secreto: i32 = random_range(VALOR_MINIMO..VALOR_MAXIMO);
        let mut intentos: u8 = 0;

        loop {
            let intento: i32 = solicitar_valor();

            match intento.cmp(&secreto) {
                Ordering::Equal => {
                    println!("¡Has adivinado!");
                    break;
                }
                Ordering::Less => println!("Introduce un valor mayor."),
                Ordering::Greater => println!("Introduce un valor menor."),
            }

            intentos += 1;
            if intentos == NUM_INTENTOS {
                println!("Sin intentos. El valor era: {}", secreto);
                break;
            }
        }
    }
    ```

## _Ownership_

El sistema de _ownership_ constituye el mecanismo central mediante el cual Rust gestiona
la memoria sin recurrir a un _garbage collector_. Se rige por tres reglas que el
compilador verifica de forma estática.

En primer lugar, cada valor tiene una variable que actúa como su **propietario**
(_owner_). En segundo lugar, ese propietario es único en cada momento, de modo que
asignar el valor a otra variable transfiere la propiedad. Por último, cuando el
propietario sale del ámbito (_scope_) en el que fue declarado, el valor se libera de
forma automática mediante la operación _drop_.

La diferencia esencial con un _garbage collector_ es que aquí el momento de la
liberación queda determinado en tiempo de compilación por la estructura del código, y no
lo decide un componente del entorno de ejecución. El resultado es una liberación de
recursos completamente predecible y sin coste en tiempo de ejecución.

### _Stack_ y _heap_

Para comprender el _ownership_ es necesario distinguir entre las dos regiones de memoria
que utiliza un programa.

El **_stack_** (pila) almacena los datos cuyo tamaño se conoce en tiempo de compilación,
como los enteros, los flotantes, los booleanos, las referencias y los _arrays_, cuya
longitud forma parte de su tipo. Las operaciones sobre el _stack_ son extremadamente
rápidas porque consisten en apilar y desapilar valores de tamaño fijo siguiendo una
estructura LIFO (_Last In, First Out_). En el _stack_ no existe diferencia entre una
copia superficial (_shallow copy_) y una copia profunda (_deep copy_), ya que ambas
producen el mismo resultado al tratarse de valores de tamaño fijo.

El **_heap_** (montículo) almacena los datos cuyo tamaño puede variar en tiempo de
ejecución, como `String` o `Vec`. Al crear un valor en el _heap_, el sistema reserva un
bloque de memoria y devuelve un puntero que se almacena en el _stack_ junto con la
longitud actual y la capacidad reservada. El acceso al _heap_ es más lento porque
requiere seguir punteros para localizar los datos. Copiar un tipo alojado en el _heap_
exige una copia profunda mediante `.clone()`, lo que puede resultar costoso.

!!! note "Dónde vive realmente el texto de un `&str`"

    En `let palabra: &str = "Bob"`, lo que reside en el _stack_ es la propia referencia,
    formada por un puntero y una longitud. Los bytes del literal `"Bob"` están
    incrustados en una sección de solo lectura del ejecutable y tienen duración
    `'static`, de modo que existen durante toda la vida del programa.

    En cambio, `let palabra: String = String::from("Bob")` almacena el puntero, la
    longitud y la capacidad en el _stack_, mientras que el contenido de la cadena reside
    en el _heap_. Lo mismo ocurre con un _array_ dentro de un `Box`, un puntero que
    traslada al _heap_ un valor que de otro modo se alojaría en el _stack_.

### _Move_ y _clone_

Cuando se asigna a otra variable un valor que contiene datos en el _heap_, Rust no copia
el contenido. En su lugar transfiere la propiedad (_move_) a la nueva variable e
invalida la original, lo que impide su uso posterior. Este comportamiento previene la
liberación doble de memoria (_double free_), un error frecuente en lenguajes como C que
se produciría si dos variables apuntasen al mismo bloque y ambas intentasen liberarlo al
salir de su _scope_.

Un _trait_ es un conjunto de capacidades que un tipo declara implementar, y el
compilador lo utiliza para decidir qué operaciones admite ese tipo. El comportamiento
alternativo, copiar los bits en lugar de mover el valor, se aplica únicamente a los
tipos que implementan el _trait_ `Copy`. Lo implementan los enteros, los flotantes,
`bool`, `char` y las tuplas y _arrays_ cuyos elementos también lo implementan. No basta
con que un tipo resida en el _stack_: una estructura propia se mueve igualmente salvo
que se declare con `#[derive(Copy, Clone)]`. Cuando se necesita una copia profunda de un
valor alojado en el _heap_ se utiliza el método `.clone()`, que duplica tanto los
metadatos como el contenido al que apuntan.

???+ example "_Move_ de un valor en el _heap_ y copia con `.clone()`"

    Los tipos que implementan `Copy` se copian de forma automática, mientras que un
    valor en el _heap_ se mueve, invalidando la variable original, salvo que se duplique
    con `.clone()`.

    ```rust linenums="1"
    fn main() {
        // Tipos que implementan Copy: se copian automáticamente
        let a = 1;
        let b = a;
        println!("a: {}, b: {}", a, b); // Ambos válidos

        // Tipos alojados en el heap: se produce un move
        let palabra: String = String::from("Hola");
        let otra = palabra; // Move: `palabra` queda invalidada
        println!("otra: {}", otra);
        // println!("{}", palabra); // Error de compilación: valor movido

        // Clone: copia profunda del contenido en el heap
        let texto: String = String::from("Prueba");
        let copia: String = texto.clone();
        println!("texto: {}, copia: {}", texto, copia); // Ambos válidos
    }
    ```

### _Ownership_ en funciones

Una función puede devolver el _ownership_ de un valor, de modo que la variable receptora
en el ámbito que la invoca se convierte en la nueva propietaria. Cada variable que
recibe el resultado de una función adquiere su propio _ownership_ independiente.

???+ example "Devolución de _ownership_ desde una función"

    Cada llamada a `crear_saludo` transfiere la propiedad de una `String` distinta a la
    variable que la recibe.

    ```rust linenums="1"
    fn crear_saludo() -> String {
        String::from("Hola")
    }

    fn main() {
        let saludo_1 = crear_saludo();
        let saludo_2 = crear_saludo();
        println!("{}, {}", saludo_1, saludo_2);
    }
    ```

## Referencias y _borrowing_

Las **referencias** permiten acceder al valor de una variable sin adquirir su
_ownership_. Este mecanismo se denomina _borrowing_ (préstamo) y constituye la forma
idiomática de pasar datos a una función sin transferir la propiedad. Rust distingue dos
tipos de referencias. Por un lado, `&T` representa una referencia inmutable que permite
únicamente la lectura del valor y de la cual pueden mantenerse varias instancias activas
de forma simultánea. Por otro lado, `&mut T` representa una referencia mutable que
permite tanto la lectura como la escritura, con la restricción de que solo puede existir
una activa a la vez sobre un mismo valor.

El compilador garantiza en tiempo de compilación que nunca coexistan referencias
mutables e inmutables sobre el mismo dato. Las referencias son inmutables por defecto,
al igual que las variables.

???+ example "Referencias inmutables y mutables"

    La función `normalizar_texto` toma una referencia inmutable y `agregar_texto` una
    referencia mutable. Al finalizar se mantienen varias referencias inmutables de forma
    simultánea.

    ```rust linenums="1"
    fn normalizar_texto(texto: &str) -> String {
        return texto.to_lowercase();
    }

    fn agregar_texto(texto: &mut String) {
        texto.push_str("!");
    }

    fn main() {
        let texto: String = String::from("Hola");

        // Referencia inmutable: no adquiere ownership
        println!("Normalizado: {}", normalizar_texto(&texto));
        println!("Original: {}", texto); // Sigue disponible

        // Referencia mutable: permite modificar el valor
        let mut saludo: String = String::from("Bob");
        agregar_texto(&mut saludo);
        println!("Modificado: {}", saludo); // "Bob!"

        // Múltiples referencias inmutables simultáneas: permitido
        let ref_1 = &saludo;
        let ref_2 = &saludo;
        println!("{}, {}", ref_1, ref_2);
    }
    ```

!!! warning "Alcance de un préstamo"

    El alcance de un préstamo termina en su último uso, no al final del bloque en el que
    se declaró. Por ello, partiendo de `let mut s = String::from("a");`, la secuencia
    `let r = &mut s;`, `r.push('b');` y `s.push('c');` compila sin problema. El préstamo
    mutable ha dejado de estar activo tras la llamada a `r.push`, momento en el que la
    variable original vuelve a ser utilizable.

    Estas restricciones existen porque el _aliasing_ mutable permitiría invalidar datos
    que están en uso. Un ejemplo típico es realojar un `Vec` al añadirle elementos
    mientras se conserva un puntero a su contenido anterior, que queda apuntando a
    memoria liberada. En presencia de varios hilos, el mismo _aliasing_ daría lugar
    además a _data races_.

### _Dangling references_

Rust impide devolver referencias a datos locales de una función, ya que al finalizar su
ejecución se realiza un _drop_ de sus variables y la referencia apuntaría a memoria
liberada. Esta situación se conoce como _dangling reference_. La solución consiste en
devolver el valor directamente, transfiriendo el _ownership_, en lugar de una
referencia.

???+ example "Evitar una _dangling reference_"

    La versión comentada no compila porque devolvería una referencia a un valor que se
    libera al terminar la función. La versión correcta devuelve el valor y transfiere su
    _ownership_.

    ```rust linenums="1"
    // Error de compilación: dangling reference
    // fn crear_texto() -> &String {
    //     let s = String::from("hola");
    //     &s // `s` se libera al salir de la función
    // }

    // Correcto: se devuelve el ownership
    fn crear_texto() -> String {
        let s = String::from("hola");
        s
    }

    fn main() {
        let texto = crear_texto();
        println!("{}", texto);
    }
    ```

## _Slices_

Los _slices_ son referencias a una subsecuencia contigua de elementos dentro de una
colección, sin adquirir el _ownership_ de los datos subyacentes. Se representan con el
tipo `&[T]` y se construyen especificando un rango sobre la colección original mediante
la sintaxis `&coleccion[inicio..fin]`, donde `inicio` es inclusivo y `fin` es exclusivo.
Si se omite el índice inicial se toma desde el primer elemento, y si se omite el final
se incluyen todos los elementos hasta el último.

Los _slices_ resultan especialmente útiles para trabajar con porciones de _arrays_ o de
vectores sin necesidad de copiar los datos, lo que los convierte en una herramienta
eficiente para el procesamiento de secuencias.

???+ example "Obtener un _slice_ de un _array_"

    La función `slice_lista` devuelve una porción del _array_ original delimitada por un
    rango, sin copiar los datos.

    ```rust linenums="1"
    fn slice_lista(lista: &[i32], inicio: usize, fin: usize) -> &[i32] {
        return &lista[inicio..fin];
    }

    fn main() {
        let lista: [i32; 5] = [1, 2, 3, 4, 5];
        let slice = slice_lista(&lista, 1, 3);
        println!("{:?}", slice); // [2, 3]
    }
    ```

Con estos fundamentos cubiertos, el capítulo de [librerías](section_2_libraries.md)
recopila los _crates_ más habituales para construir herramientas de línea de comandos en
Rust.
