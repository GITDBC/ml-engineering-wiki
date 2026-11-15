---
icon: lucide/code
authors: Daniel Bazo Correa
description:
    Fundamentos del lenguaje C necesarios para la programación de sistemas, con tipos de
    datos, entrada y salida formateada, cadenas, estructuras, punteros, memoria
    dinámica, compilación y gestión de errores con errno.
title: Fundamentos de C
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Este capítulo reúne el subconjunto del lenguaje C que se necesita para programar a nivel
de sistema: tipos de datos, entrada y salida formateada, cadenas, estructuras, punteros,
memoria dinámica, compilación y la convención de errores de las llamadas al sistema. No
pretende ser un curso completo de C, sino la base de los capítulos siguientes.

## Introducción

La **programación de sistemas** consiste en escribir software que interactúa
directamente con el sistema operativo, como utilidades de línea de comandos, servidores
de red o intérpretes de órdenes. C es el lenguaje habitual para esta tarea porque ofrece
control explícito sobre la memoria y porque la interfaz del _kernel_ de Linux, descrita
en el
[capítulo de Linux](../../01_operative_systems/01_linux/section_1_fundamentals.md), se
expone a los programas como funciones C.

Tras este capítulo, el de [archivos y directorios](section_2_files.md) trata la entrada
y salida, el de [procesos](section_3_processes.md) la creación y sustitución de
programas, el de [comunicación entre procesos](section_4_ipc.md) las tuberías y el de
[señales](section_5_signals.md) los avisos asíncronos y los temporizadores. Los de
[máquinas de estados](section_6_state_machines.md), [_sockets_](section_7_sockets.md) y
[TCP/IP](../../05_infrastructure/03_networking/section_1_tcpip.md) construyen
aplicaciones de comunicaciones sobre esas piezas, y el módulo de
[concurrencia](../07_concurrency/section_1_fundamentals.md) explica cómo coordinar
varias líneas de ejecución.

## Compilación

Un programa C comienza en la función `main`, que devuelve un entero al sistema
operativo. Por convención, `0` indica éxito y cualquier otro valor indica un fallo. Las
directivas `#include` incorporan las declaraciones de la biblioteca estándar, por
ejemplo `stdio.h` para la entrada y salida y `stdlib.h` para la memoria dinámica.

El compilador de GNU, `gcc`, traduce el código fuente a un ejecutable. La orden más
habitual indica el nombre del ejecutable con `-o`, el estándar del lenguaje con `-std` y
los avisos con `-Wall` y `-Wextra`:

```bash linenums="1"
gcc -Wall -Wextra -std=c11 -o programa programa.c
```

Los avisos detectan errores frecuentes, como variables sin usar, formatos de `printf`
que no coinciden con el tipo del argumento o funciones sin declarar, por lo que conviene
tratarlos como fallos. Para ejecutar el programa se escribe su ruta, `./programa`, y los
argumentos que se añadan llegan a `main`.

!!! warning "La opción `-std` desactiva las extensiones de POSIX"

    Con `-std=c99` o `-std=c11` el compilador solo expone las funciones del estándar de
    C. Las llamadas propias de Linux y POSIX, como `kill`, `sigaction` o `setitimer`,
    pueden provocar un aviso de declaración implícita aunque se incluya la cabecera
    correcta. La solución es definir la macro `_DEFAULT_SOURCE` antes de cualquier
    `#include`, como hacen los ejemplos de esta serie que la necesitan. Esa macro
    también cambia el comportamiento de `signal()`, como se detalla en el
    [capítulo de señales](section_5_signals.md).

    ```c linenums="1"
    #define _DEFAULT_SOURCE
    #include <signal.h>
    ```

Cuando un proyecto crece, escribir la orden completa en cada compilación resulta
incómodo. La herramienta Make, descrita en el
[capítulo de Makefile](../../02_dev_tools/02_scripting/section_2_makefile.md),
automatiza el proceso. Para varios programas de un solo archivo basta una regla de
patrón que construye cada ejecutable a partir de su `.c`:

```makefile linenums="1"
CC = gcc
CFLAGS = -Wall -Wextra -std=c11 -g

%: %.c
	$(CC) $(CFLAGS) -o $@ $<
```

Con este archivo, `make programa` compila `programa.c`, y la opción `-g` incluye
información de depuración.

## Tipos de datos y salida formateada

Los tipos básicos de C son enteros (`char`, `short`, `int`, `long`, con variante
`unsigned`) y reales (`float`, `double`). Un `char` es en realidad un entero de un byte,
de modo que el carácter `'a'` y el número 97 de la tabla ASCII son el mismo valor, y
solo la forma de imprimirlo cambia. Una cadena de texto es un _array_ de `char` que
termina en el carácter nulo `'\0'`. El operador `sizeof` devuelve el tamaño en bytes de
un tipo o de una variable, y dividir el tamaño de un _array_ entre el de uno de sus
elementos da su número de elementos. La cabecera `stdbool.h` define `bool`, `true` y
`false`, que C clásico no tiene como tipo propio.

La función `printf` imprime con un formato donde cada especificador comienza por `%` y
debe coincidir con el tipo del argumento correspondiente:

| Especificador | Imprime                                                 |
| ------------- | ------------------------------------------------------- |
| `%d`          | Un entero decimal (`int`).                              |
| `%ld`         | Un entero largo decimal (`long`).                       |
| `%f`          | Un número decimal (`float` o `double`).                 |
| `%c`          | Un carácter.                                            |
| `%s`          | Una cadena de caracteres.                               |
| `%x`          | Un entero en hexadecimal (255 se imprime como `ff`).    |
| `%p`          | Una dirección de memoria.                               |
| `%zu`         | Un `size_t`, el tipo que devuelven `sizeof` y `strlen`. |

???+ example "Tipos básicos y `printf`"

    El valor de `sizeof(cadena)` incluye el terminador `'\0'`, por eso supera en uno el
    número de letras visibles.

    ```c linenums="1"
    #include <stdio.h>

    int main(void) {
        int valor_entero = 40;
        double valor_decimal = 3.1415;
        char caracter = 'a';
        char cadena[] = "Esto es una cadena";
        int numeros[] = {1, 2, 3, 4, 5, 6, 7, 8, 9};

        printf("Entero: %d\n", valor_entero);
        printf("Decimal: %f\n", valor_decimal);
        printf("Carácter: %c\tCódigo ASCII: %d\n", caracter, caracter);
        printf("Cadena: %s\n", cadena);
        printf("Hexadecimal de 255: %x\n", 255);
        printf("Bytes de la cadena: %zu\n", sizeof(cadena));
        // Número de elementos: bytes totales entre bytes de un elemento
        printf("Elementos del array: %zu\n", sizeof(numeros) / sizeof(numeros[0]));
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    Entero: 40
    Decimal: 3.141500
    Carácter: a     Código ASCII: 97
    Cadena: Esto es una cadena
    Hexadecimal de 255: ff
    Bytes de la cadena: 19
    Elementos del array: 9
    ```

## Entrada de datos

La función `scanf` lee del teclado con la misma notación de formatos, salvo que el
argumento debe ser la **dirección** de la variable donde guardar el valor. Por eso se
escribe `scanf("%d", &edad)`, con el operador `&`, pero `scanf("%s", telefono)` sin él,
porque el nombre de un _array_ ya es una dirección. Para los reales de doble precisión
`scanf` usa `%lf`, aunque `printf` acepta `%f`. La función devuelve el número de valores
leídos, y comprobarlo evita trabajar con variables sin inicializar cuando el usuario
escribe algo inesperado.

El especificador `%s` de `scanf` se detiene en el primer espacio, así que no sirve para
leer un nombre completo. Para leer una línea entera se utiliza `fgets`, que copia como
máximo el número de caracteres indicado menos uno, termina la cadena en `'\0'` y
conserva el salto de línea final si cabe. Ese salto sobra casi siempre, y se elimina con
`nombre[strcspn(nombre, "\n")] = '\0'`, que localiza su posición y la sustituye por el
terminador.

Mezclar `scanf` y otras lecturas tiene una trampa adicional: `scanf` deja en el _buffer_
de entrada el salto de línea que sigue al valor, y la siguiente lectura de un solo
carácter o de una línea lo encuentra de inmediato. El remedio habitual es descartar el
resto de la línea con un bucle que lea con `getchar` hasta el final de línea.

???+ example "Lectura de una línea y de un entero"

    Con la entrada `Ana Pérez` y `34`, cada una en su línea, el programa muestra los
    datos leídos. Como la entrada no es interactiva, los avisos aparecen seguidos.

    ```c linenums="1"
    #include <stdio.h>
    #include <string.h>

    #define MAX_NOMBRE 30

    int main(void) {
        char nombre[MAX_NOMBRE];
        int edad;

        printf("Nombre: ");
        // fgets lee la línea completa, incluidos los espacios
        if (fgets(nombre, sizeof(nombre), stdin) == NULL)
            return 1;
        // Elimina el salto de línea que fgets deja al final
        nombre[strcspn(nombre, "\n")] = '\0';

        printf("Edad: ");
        // %d necesita la dirección de la variable: &edad
        if (scanf("%d", &edad) != 1)
            return 1;

        // Descarta lo que quede en el buffer de entrada hasta el salto de línea
        int c;
        while ((c = getchar()) != '\n' && c != EOF)
            ;

        printf("\nNombre: %s\nEdad: %d\n", nombre, edad);
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    Nombre: Edad:
    Nombre: Ana Pérez
    Edad: 34
    ```

!!! warning "`scanf("%s")` sin ancho máximo desborda el destino"

    `scanf("%s", destino)` escribe tantos caracteres como reciba, sin mirar el tamaño
    del _array_. Cualquier entrada más larga corrompe la pila. Hay que indicar siempre
    el ancho, `%49s` para un destino de 50 bytes, o preferir `fgets`.

## _Arrays_ y cadenas

Un _array_ se declara con un tamaño fijo, preferiblemente mediante una constante
(`#define TAM 25` y `int nombre[TAM];`), o sin tamaño explícito cuando se inicializa con
una lista, como `int nombre[] = {1, 2, 3, 4};`, y entonces el compilador cuenta los
elementos. Una cadena puede inicializarse carácter a carácter, con el terminador
incluido, o con una cadena literal entre comillas dobles, que lo añade por sí sola.

El identificador de un _array_ se comporta como un puntero constante a su primer
elemento. Por ello un _array_ pasado a una función llega siempre como puntero, y
`void funcion(char array[])` equivale a `void funcion(char *array)`. Dentro de la
función se pierde la información de longitud, de modo que `sizeof` ya no sirve y el
tamaño debe pasarse como un argumento aparte o marcarse con un valor final, como el
`'\0'` de las cadenas.

La biblioteca `string.h` agrupa las funciones habituales para trabajar con cadenas, y
`stdlib.h` y `ctype.h` las conversiones y clasificaciones de caracteres:

| Función   | Descripción                                                      | Ejemplo de uso               |
| --------- | ---------------------------------------------------------------- | ---------------------------- |
| `strlen`  | Devuelve el largo de una cadena, sin contar el `'\0'`.           | `strlen("hola")` vale 4.     |
| `strcpy`  | Copia una cadena en otra.                                        | `strcpy(destino, origen)`    |
| `strcat`  | Concatena una cadena al final de otra.                           | `strcat(destino, "texto")`   |
| `strcmp`  | Compara dos cadenas y devuelve 0 si son iguales.                 | `strcmp(a, b) == 0`          |
| `strstr`  | Busca una cadena dentro de otra y devuelve un puntero.           | `strstr(frase, "mun")`       |
| `atoi`    | Convierte una cadena a entero, y `atof` y `atol` a real y largo. | `atoi("42")` vale 42.        |
| `isalpha` | Indica si un carácter es una letra, y `isdigit` si es un dígito. | `isalpha('a')` es verdadero. |
| `toupper` | Pasa un carácter a mayúscula, y `tolower` a minúscula.           | `toupper('a')` vale `'A'`.   |

Las funciones `strcpy` y `strcat` no comprueban el tamaño del destino, por lo que el
programador debe garantizar que la cadena resultante cabe. De manera análoga, `atoi`
devuelve 0 tanto para `"0"` como para una cadena no numérica, de modo que `strtol`, que
informa dónde se detuvo la conversión, es preferible cuando la entrada procede del
exterior.

## Argumentos de la línea de comandos

La función `main` puede declararse como `int main(int argc, char *argv[])`. El parámetro
`argc` contiene el número de palabras con las que se invocó el programa y `argv` es un
_array_ de cadenas, donde `argv[0]` es el nombre del ejecutable y `argv[1]` en adelante
son los argumentos. Si se ejecuta `./miprograma param1 param2`, entonces `argc` vale 3 y
`argv` contiene `./miprograma`, `param1` y `param2`. Como el usuario puede omitir
argumentos, hay que comprobar `argc` antes de acceder a `argv[1]`.

???+ example "Argumentos y conversión con `strtol`"

    El programa muestra sus argumentos y convierte el primero a entero comprobando que
    la cadena sea numérica.

    ```c linenums="1"
    #include <stdio.h>
    #include <stdlib.h>

    int main(int argc, char *argv[]) {
        printf("argc = %d\n", argc);
        for (int i = 0; i < argc; i++)
            printf("argv[%d] = %s\n", i, argv[i]);

        if (argc > 1) {
            char *fin;
            long valor = strtol(argv[1], &fin, 10);
            // fin apunta al primer carácter no convertido: si es '\0', todo era numérico
            if (*fin == '\0')
                printf("argv[1] + 1 = %ld\n", valor + 1);
            else
                printf("argv[1] no es un número\n");
        }
        return 0;
    }
    ```

    Ejecutado como `./programa 41 hola`, imprime lo siguiente:

    ```plaintext title="Expected output"
    argc = 3
    argv[0] = ./programa
    argv[1] = 41
    argv[2] = hola
    argv[1] + 1 = 42
    ```

## Estructuras

Una **estructura** (`struct`) agrupa variables de distintos tipos bajo un solo nombre, y
puede contener _arrays_ y otras estructuras. Dos propiedades sorprenden a quien llega de
otros lenguajes. La primera es que el tamaño de una estructura no es la suma de los
tamaños de sus campos, porque el compilador inserta bytes de relleno para alinear cada
campo a su tamaño natural. La segunda es que las estructuras no se comparan con el
operador `==`, sino campo a campo.

Una estructura grande se pasa a una función por su dirección y no por valor, para no
copiarla en cada llamada. Con un puntero constante, `const struct Cuenta *`, la función
tampoco puede modificarla, y se accede a sus campos con el operador `->`.

???+ example "Estructuras, relleno y paso por puntero"

    La estructura `Cuenta` suma 63 bytes de campos, pero ocupa 72 por el relleno: dos
    bytes antes de `numero`, para alinearlo a 4, y siete al final, para que el tamaño
    sea múltiplo de 8, el alineamiento de `double`.

    ```c linenums="1"
    #include <stdbool.h>
    #include <stdio.h>

    struct Cuenta {
        char nombre[50];
        unsigned numero;
        double saldo;
        bool ocupado;
    };

    // Recibe un puntero constante: no copia la estructura y no puede modificarla
    void mostrar(const struct Cuenta *cuenta) {
        printf("%s (%u): %.2f\n", cuenta->nombre, cuenta->numero, cuenta->saldo);
    }

    int main(void) {
        struct Cuenta cuenta = {"Ana", 1001, 250.5, true};

        printf("Suma de los campos: %zu bytes\n",
               sizeof(char[50]) + sizeof(unsigned) + sizeof(double) + sizeof(bool));
        printf("sizeof(struct Cuenta): %zu bytes\n", sizeof(struct Cuenta));
        mostrar(&cuenta);
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    Suma de los campos: 63 bytes
    sizeof(struct Cuenta): 72 bytes
    Ana (1001): 250.50
    ```

El relleno tiene una consecuencia para los capítulos siguientes: volcar una estructura a
un archivo o a una tubería con `write` copia también esos bytes, y el resultado depende
del compilador y de la arquitectura.

## Punteros

Un **puntero** es una variable que almacena una dirección de memoria. Se declara con un
asterisco, `int *p;`, se inicializa con la dirección de otra variable mediante `p = &x;`
y se accede al contenido de esa dirección con el mismo asterisco, `*p = 20;`. La
aritmética de punteros avanza en múltiplos del tamaño del tipo apuntado, de modo que
`p++` en un `int *` salta cuatro bytes, hasta el siguiente entero, y `numeros[i]`
equivale a `*(numeros + i)`. Del mismo modo, `&numeros[2]` y `numeros + 2` designan el
mismo elemento.

### Paso por valor y por referencia

En C los argumentos se pasan siempre por valor: la función recibe una copia y
modificarla no altera la variable original. Para que una función cambie la variable del
llamante se le pasa su dirección, lo que se conoce como paso por referencia. La función
recibe un puntero y escribe a través de él con `*`. El ejemplo de la sección siguiente
contrapone `doble_por_valor(x)` y `doble_por_referencia(&x)`.

### Memoria dinámica

La función `malloc` reserva en el montón el número de bytes indicado y devuelve un
puntero a la zona reservada, o `NULL` si no hay memoria. La función `free` la libera, y
ambas requieren incluir `stdlib.h`. Es habitual calcular el tamaño con `sizeof`, como en
`malloc(sizeof(int))`, y comprobar el resultado antes de usarlo. En C no hace falta
convertir el puntero devuelto al tipo de destino. Cada reserva debe liberarse
exactamente una vez, y el puntero no debe usarse después de liberarlo.

Una función que debe reservar memoria y entregársela al llamante recibe un **puntero a
puntero**, `int **`. Si recibe solo un `int *` y le asigna `malloc`, cambia su copia
local del puntero. El llamante no ve nada y la memoria queda perdida. El ejemplo reúne
las cuatro situaciones.

???+ example "Valor, referencia y puntero a puntero"

    La versión errónea de `nuevo_valor_erroneo` libera su reserva para no filtrar
    memoria, pero deja `x` con el valor original. La correcta, con `int **`, devuelve la
    reserva al llamante.

    ```c linenums="1"
    #include <stdio.h>
    #include <stdlib.h>

    // Recibe una copia: el cambio no sale de la función
    void doble_por_valor(int i) {
        i = i + i;
    }

    // Recibe la dirección: modifica la variable original
    void doble_por_referencia(int *i) {
        *i = *i + *i;
    }

    // Error típico: reasigna la copia local del puntero, no el del llamante
    void nuevo_valor_erroneo(int *i) {
        i = malloc(sizeof(int));
        if (i == NULL)
            return;
        *i = 7;
        free(i);
    }

    // Con un puntero a puntero sí puede cambiar a dónde apunta el del llamante
    int nuevo_valor(int **i) {
        *i = malloc(sizeof(int));
        if (*i == NULL)
            return -1;
        **i = 7;
        return 0;
    }

    int main(void) {
        int x = 5;

        doble_por_valor(x);
        printf("Por valor: %d\n", x);
        doble_por_referencia(&x);
        printf("Por referencia: %d\n", x);

        x = 5;
        nuevo_valor_erroneo(&x);
        printf("Reasignando la copia local: %d\n", x);

        int *y = NULL;
        if (nuevo_valor(&y) == 0) {
            printf("Con puntero a puntero: %d\n", *y);
            free(y);
        }
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    Por valor: 5
    Por referencia: 10
    Reasignando la copia local: 5
    Con puntero a puntero: 7
    ```

### Punteros a función

Una función también ocupa una dirección de memoria y puede guardarse en un puntero. La
declaración se lee de dentro hacia fuera, con el nombre del puntero entre paréntesis
para que el asterisco no se asocie al tipo de retorno:

| Declaración               | Significado                                                              |
| ------------------------- | ------------------------------------------------------------------------ |
| `int (*pf)();`            | Puntero a una función que devuelve `int`.                                |
| `int (*pf2)(int, float);` | Puntero a una función que devuelve `int` y recibe un `int` y un `float`. |
| `int (*pf3[2])(int);`     | _Array_ de dos punteros a funciones que devuelven `int` y reciben `int`. |

Se asigna con `pf = f;`, sin paréntesis tras el nombre, y se llama con `pf();` o con
`(*pf)();`. El uso más frecuente en programación de sistemas es el registro de
manejadores de señales, que se verá en el [capítulo de señales](section_5_signals.md),
pero también sirve para escoger una operación en tiempo de ejecución.

???+ example "Tabla de punteros a función"

    El programa recorre un _array_ de punteros a función y llama a cada operación.

    ```c linenums="1"
    #include <stdio.h>

    void suma(int a, int b) {
        printf("La suma es: %d\n", a + b);
    }

    void resta(int a, int b) {
        printf("La resta es: %d\n", a - b);
    }

    int main(void) {
        // Array de punteros a funciones que devuelven void y reciben dos int
        void (*operaciones[])(int, int) = {suma, resta};

        for (int i = 0; i < 2; i++) {
            // Se llama a la función a través de su puntero
            operaciones[i](5, 10);
        }
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    La suma es: 15
    La resta es: -5
    ```

## Errores en las llamadas al sistema

Las funciones que invocan al _kernel_ pueden fallar por causas ajenas al programa, como
una saturación del sistema o un archivo que no existe, y un resultado correcto en una
ocasión no garantiza otro igual más tarde. Por eso cada llamada debe comprobarse. Casi
todas devuelven un entero con una convención común: `-1` indica error, `0` indica éxito
en las que no devuelven datos, y en las que sí lo hacen, como `read` o `open`, un valor
no negativo es el resultado.

Cuando una llamada falla, el _kernel_ deja en la variable global `errno`, definida en
`errno.h`, un código que identifica la causa. La función `perror` imprime en la salida
de errores un mensaje propio seguido de la descripción textual del código actual, y
`strerror` devuelve esa descripción como cadena. El valor de `errno` solo es fiable
inmediatamente después de una llamada fallida, porque otra llamada, aunque tenga éxito,
puede sobrescribirlo.

???+ example "Comprobación de errores con `errno` y `perror`"

    El programa intenta abrir el archivo que recibe como argumento y, si falla, muestra
    el código y su descripción de dos formas. La llamada `open` y el descriptor de
    archivo `fd` que devuelve se explican en el
    [capítulo de archivos](section_2_files.md).

    ```c linenums="1"
    #include <errno.h>
    #include <fcntl.h>
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <unistd.h>

    int main(int argc, char *argv[]) {
        if (argc < 2) {
            fprintf(stderr, "Uso: %s archivo\n", argv[0]);
            return 1;
        }

        int fd = open(argv[1], O_RDONLY);
        if (fd == -1) {
            // errno conserva el código del último fallo; strerror lo traduce
            printf("errno = %d (%s)\n", errno, strerror(errno));
            // perror antepone un mensaje propio y escribe en la salida de errores
            perror("Error al abrir el archivo");
            exit(1);
        }
        close(fd);
        printf("Archivo abierto y cerrado correctamente\n");
        return 0;
    }
    ```

    Si el archivo no existe, la salida estándar y la de errores contienen lo siguiente:

    ```plaintext title="Expected output"
    errno = 2 (No such file or directory)
    Error al abrir el archivo: No such file or directory
    ```

El resto de la serie sigue este patrón. El [siguiente capítulo](section_2_files.md)
aplica la convención a cada llamada de entrada y salida sobre archivos, el de
[procesos](section_3_processes.md) la extiende a la creación de procesos y el de
[señales](section_5_signals.md) explica el código `EINTR`, que indica que una señal
interrumpió una llamada bloqueante y que obliga a reintentarla.
