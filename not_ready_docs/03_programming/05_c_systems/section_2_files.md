---
icon: lucide/folder-open
authors: Daniel Bazo Correa
description:
    Entrada y salida de archivos en C sobre Linux, con llamadas al sistema y
    descriptores, archivos binarios, la biblioteca estándar stdio, metadatos con stat,
    directorios y una implementación de cp.
title: Archivos y directorios en C
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Este capítulo describe cómo un programa C realiza la entrada y salida (E/S) de archivos
en Linux. Presenta las llamadas al sistema `open`, `read`, `write` y `close` y el
concepto de descriptor, el almacenamiento de datos en formato binario, la biblioteca
estándar `stdio` como alternativa con _buffer_, la consulta de metadatos con `stat`, el
recorrido de directorios y, como aplicación, la implementación de `cp`.

## Introducción

Los ejemplos de este capítulo suponen los fundamentos de C del
[capítulo anterior](section_1_fundamentals.md), en particular la comprobación del valor
devuelto con `errno` y `perror`. Los conceptos del sistema operativo que no se repiten
aquí, como los permisos de lectura, escritura y ejecución, la máscara `umask` o la
jerarquía de directorios, se describen en el
[capítulo de Linux](../../01_operative_systems/01_linux/section_1_fundamentals.md).

## Llamadas al sistema

Una **llamada al sistema** es una petición que un programa del espacio de usuario dirige
al _kernel_ para obtener un servicio o un recurso, como abrir un archivo o crear un
proceso. Por razones de seguridad, los programas no pueden acceder directamente a los
dispositivos ni a la memoria del _kernel_, y toda operación sensible pasa por este
canal.

Desde C se invocan a través de funciones de la biblioteca estándar con el mismo nombre,
que preparan los argumentos y ejecutan la instrucción que transfiere el control al
_kernel_. Sus páginas de manual están en la sección 2, de modo que `man 2 open`
documenta la llamada y `man 3 printf` una función de biblioteca. Como el resultado puede
cambiar entre dos invocaciones idénticas, todas las llamadas deben comprobarse con la
convención de `-1` y `errno` presentada en el capítulo anterior.

## Todo es un archivo

En los sistemas Unix casi todo se representa como un archivo: los documentos, los
directorios, los programas, los dispositivos y los canales de comunicación. Esa
uniformidad permite comunicarse con un dispositivo igual que con un archivo, mediante
lecturas y escrituras. La primera columna de la salida de `ls -l` muestra el tipo:

| Tipo                      | Carácter en `ls -l` | Descripción                                                                   |
| ------------------------- | ------------------- | ----------------------------------------------------------------------------- |
| Regular                   | `-`                 | Datos de usuario, texto o binarios.                                           |
| Directorio                | `d`                 | Lista de nombres de otros archivos.                                           |
| Enlace simbólico          | `l`                 | Archivo ligero que contiene la ruta de otro.                                  |
| Dispositivo de bloques    | `b`                 | Dispositivo con acceso a cualquier posición, como un disco.                   |
| Dispositivo de caracteres | `c`                 | Dispositivo al que se accede carácter a carácter, como un terminal.           |
| Tubería                   | `p`                 | Canal unidireccional entre procesos.                                          |
| _Socket_                  | `s`                 | Canal bidireccional entre procesos, en la misma máquina o a través de la red. |

Un proceso no maneja los archivos por su nombre una vez abiertos, sino por un
**descriptor de archivo**, un entero pequeño no negativo que identifica el archivo
abierto dentro del proceso. Todo proceso arranca con tres descriptores ya abiertos: el
`0` es la entrada estándar (`STDIN_FILENO`), el `1` la salida estándar (`STDOUT_FILENO`)
y el `2` la salida de errores (`STDERR_FILENO`). El siguiente descriptor libre que
reciba una llamada a `open` será el 3. Los descriptores se copian en los procesos hijos,
como se verá en el [capítulo de procesos](section_3_processes.md), y de ahí viene que un
proceso padre pueda compartir un archivo o un canal con su hijo.

## E/S con descriptores

Cinco llamadas bastan para operar con archivos: `open`, `creat`, `read`, `write` y
`close`. Requieren las cabeceras `fcntl.h` para `open` y `creat`, y `unistd.h` para
`read`, `write` y `close`, además de `stdio.h` y `stdlib.h` para `perror` y `exit`.
Todas devuelven un entero, y `-1` indica fallo.

### Apertura y cierre

La llamada `open(ruta, modo)` abre un archivo existente y devuelve su descriptor. El
modo se construye con constantes de `fcntl.h` que se combinan con el operador `|`:

| Constante  | Efecto                                                                    |
| ---------- | ------------------------------------------------------------------------- |
| `O_RDONLY` | Abre solo para lectura. El archivo debe existir.                          |
| `O_WRONLY` | Abre solo para escritura. El archivo debe existir, salvo con `O_CREAT`.   |
| `O_RDWR`   | Abre para lectura y escritura.                                            |
| `O_APPEND` | Conserva el contenido y añade los datos nuevos al final.                  |
| `O_TRUNC`  | Borra el contenido existente y sobrescribe desde el principio.            |
| `O_CREAT`  | Crea el archivo si no existe. Exige un tercer argumento con los permisos. |

La llamada `creat(ruta, permisos)` crea el archivo si no existe, lo vacía si existe y lo
devuelve abierto para escribir. Equivale a
`open(ruta, O_WRONLY | O_CREAT | O_TRUNC, permisos)`. El segundo argumento son los
permisos en octal, por ejemplo `0666` para lectura y escritura de todos, donde el `0`
inicial indica la notación octal. El _kernel_ resta a esos permisos los bits de la
máscara `umask` del proceso, de modo que con la máscara habitual de `022` un archivo
creado con `0666` queda como `rw-r--r--`.

La llamada `close(fd)` libera el descriptor y los recursos asociados. Omitir el cierre
acumula descriptores abiertos, y el sistema impone un límite por proceso.

### Lectura

La llamada `read(fd, buffer, n)` intenta leer como máximo `n` bytes en el _buffer_ y
devuelve el número de bytes realmente leídos, de tipo `ssize_t`. Ese valor puede ser
menor que `n`, y no es un error. Si un archivo mide 301 bytes y el _buffer_ es de 300,
la primera lectura devuelve 300, la segunda devuelve 1 y las siguientes devuelven 0. El
valor `0` indica el final del archivo, y `-1` indica un error. Por tanto, el patrón de
lectura es un bucle que continúa mientras `read` devuelva un valor positivo, y que
comprueba después si terminó por un error.

!!! warning "Lecturas parciales y terminador"

    El número de bytes leídos es también el que debe escribirse después. Usar
    `sizeof(buffer)` en lugar del valor de retorno escribiría basura al destino cuando
    la última lectura es parcial. Además, `read` no añade un terminador `'\0'`, de
    manera que imprimir el _buffer_ con `printf("%s")` solo es correcto si se termina la
    cadena a mano.

???+ example "Volcado de un archivo por bloques"

    El _buffer_ es de solo 10 bytes para que se vea cómo se reparte la lectura. Los
    mensajes entre corchetes salen por la salida de errores.

    ```c linenums="1"
    #include <fcntl.h>
    #include <stdio.h>
    #include <stdlib.h>
    #include <unistd.h>

    #define TAM_BUFFER 10

    int main(int argc, char *argv[]) {
        if (argc < 2) {
            fprintf(stderr, "Uso: %s archivo\n", argv[0]);
            return 1;
        }

        int fd = open(argv[1], O_RDONLY);
        if (fd < 0) {
            perror("Error al abrir el archivo");
            exit(1);
        }

        char buffer[TAM_BUFFER];
        ssize_t leidos;
        // read devuelve 0 al llegar al final del archivo y -1 si falla
        while ((leidos = read(fd, buffer, sizeof(buffer))) > 0) {
            fprintf(stderr, "[read: %zd bytes]\n", leidos);
            // Se escriben solo los bytes leídos, no todo el buffer
            if (write(STDOUT_FILENO, buffer, leidos) != leidos) {
                perror("Error al escribir");
                exit(1);
            }
        }
        if (leidos < 0) {
            perror("Error al leer el archivo");
            exit(1);
        }

        close(fd);
        return 0;
    }
    ```

    Con un archivo de 24 bytes, la lectura se reparte en tres llamadas:

    ```plaintext title="Expected output"
    [read: 10 bytes]
    linea uno
    [read: 10 bytes]
    linea dos
    [read: 4 bytes]
    fin
    ```

### Escritura

La llamada `write(fd, datos, n)` escribe en el archivo `n` bytes a partir de la
dirección `datos` y devuelve los bytes escritos. Para añadir contenido a un archivo
existente se abre con `O_WRONLY | O_APPEND`, y para sobrescribirlo con
`O_WRONLY | O_TRUNC`. Un resultado menor que `n` indica una escritura parcial, que en
archivos regulares apenas ocurre salvo con el disco lleno, pero que puede darse en
tuberías y _sockets_, donde el
[capítulo de comunicación entre procesos](section_4_ipc.md) presenta una solución.

Cada descriptor mantiene una posición actual dentro del archivo que avanza con cada
lectura y escritura, y por eso dos llamadas consecutivas a `write` dejan los datos uno
tras otro. La llamada `lseek(fd, desplazamiento, origen)` modifica esa posición, con
`SEEK_SET`, `SEEK_CUR` o `SEEK_END` como origen. Por ejemplo, `lseek(fd, 0, SEEK_END)`
coloca el cursor al final y devuelve el tamaño del archivo.

### Entrada y salida estándar

Los descriptores 0 y 1 se usan igual que cualquier otro. Un programa que lee de
`STDIN_FILENO` y escribe en `STDOUT_FILENO` con `read` y `write` funciona igual con un
terminal, con un archivo redirigido o con una tubería, y esa es la base de los filtros
de la línea de comandos. Las mismas precauciones de la lectura se aplican: se escribe
exactamente el número de bytes leídos y no se supone que `read` termine la cadena.

## Archivos binarios

Un archivo binario guarda el contenido en memoria de las variables, las estructuras y
los _arrays_, con cada byte almacenado de forma consecutiva. El tamaño en disco coincide
con el que ocupa en memoria: un `int` escrito de este modo ocupa `sizeof(int)`,
normalmente 4 bytes, sin importar su valor. A diferencia de un archivo de texto, no hay
que convertir números a cadenas al escribir ni analizarlos al leer, aunque el resultado
no se puede abrir con un editor.

El orden y el tamaño de las lecturas deben coincidir exactamente con los de las
escrituras, porque el archivo no contiene ninguna descripción de su estructura. El
ejemplo guarda un entero, un _array_ de cuatro enteros y una estructura, y después los
recupera del mismo archivo.

???+ example "Escritura y lectura de variables en binario"

    Antes de asignar los campos se pone a cero toda la estructura con `memset`, para que
    los bytes de relleno no filtren contenido de la pila al archivo. Cada `read` se
    compara con el tamaño esperado, porque un resultado menor significa que el archivo
    está truncado o que no tiene el formato previsto.

    ```c linenums="1"
    #include <fcntl.h>
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <unistd.h>

    struct Estructura {
        int a;
        float b;
        char c;
    };

    int main(int argc, char *argv[]) {
        if (argc < 2) {
            fprintf(stderr, "Uso: %s archivo\n", argv[0]);
            return 1;
        }

        int x = 7;
        int enteros[4] = {0, 1, 2, 3};
        struct Estructura est;
        // Pone a cero también los bytes de relleno antes de asignar los campos
        memset(&est, 0, sizeof(est));
        est.a = 1;
        est.b = 2.0f;
        est.c = '3';

        // creat crea el archivo, o lo vacía si existe, y lo abre para escribir
        int fd = creat(argv[1], 0666);
        if (fd < 0) {
            perror("Error al crear el archivo");
            exit(1);
        }
        // Se escribe la imagen en memoria de cada variable, con su tamaño exacto
        if (write(fd, &x, sizeof(x)) != sizeof(x) ||
            write(fd, enteros, sizeof(enteros)) != sizeof(enteros) ||
            write(fd, &est, sizeof(est)) != sizeof(est)) {
            perror("Error al escribir los datos");
            exit(1);
        }
        close(fd);
        printf("sizeof(struct Estructura) = %zu\n", sizeof(est));

        int x2, enteros2[4];
        struct Estructura est2;
        fd = open(argv[1], O_RDONLY);
        if (fd < 0) {
            perror("Error al abrir el archivo");
            exit(1);
        }
        // Las lecturas siguen el mismo orden y los mismos tamaños que las escrituras
        if (read(fd, &x2, sizeof(x2)) != sizeof(x2) ||
            read(fd, enteros2, sizeof(enteros2)) != sizeof(enteros2) ||
            read(fd, &est2, sizeof(est2)) != sizeof(est2)) {
            perror("Error al leer los datos");
            exit(1);
        }
        close(fd);

        printf("x = %d\n", x2);
        printf("enteros = { %d, %d, %d, %d }\n", enteros2[0], enteros2[1], enteros2[2],
               enteros2[3]);
        printf("est.a = %d, est.b = %f, est.c = %c\n", est2.a, est2.b, est2.c);
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    sizeof(struct Estructura) = 12
    x = 7
    enteros = { 0, 1, 2, 3 }
    est.a = 1, est.b = 2.000000, est.c = 3
    ```

    El tamaño de la estructura es 12 y no 9, porque el compilador completa la estructura
    hasta un múltiplo de 4, el alineamiento de `int` y `float`. El archivo final mide
    4 + 16 + 12 = 32 bytes. La orden `od` permite comprobarlo, y se aprecia que los
    enteros se almacenan con el byte menos significativo primero (_little endian_):

    ```bash linenums="1"
    od -A d -t x1 datos.bin
    ```

    ```plaintext title="Expected output"
    0000000 07 00 00 00 00 00 00 00 01 00 00 00 02 00 00 00
    0000016 03 00 00 00 01 00 00 00 00 00 00 40 33 00 00 00
    0000032
    ```

!!! warning "Un archivo binario no es portable entre máquinas"

    El formato guardado depende del orden de bytes (_endianness_), del tamaño de `int` y
    `long` y del relleno de las estructuras, que varían según la arquitectura y el
    compilador. Un archivo escrito así solo es fiable si lo lee un programa compilado en
    las mismas condiciones. Para intercambiar datos entre sistemas distintos conviene
    escribir los campos uno a uno con tipos de ancho fijo, o usar un formato de texto.

### Registros de longitud variable

Cuando los datos incluyen cadenas de largo desconocido, la estrategia habitual consiste
en escribir antes de cada una un entero con su longitud, de forma que el lector sepa
cuántos bytes debe leer. El formato del ejemplo es un entero con el número de palabras
y, por cada palabra, un entero con su longitud seguido de sus bytes sin terminador.

El lector valida la longitud antes de usarla, porque procede de un archivo externo y una
longitud corrupta podría desbordar el _buffer_. El mismo patrón de cabecera y datos
reaparece en el [capítulo de comunicación entre procesos](section_4_ipc.md), donde se
envían campos de longitud variable por una tubería.

???+ example "Palabras con prefijo de longitud"

    El programa guarda en el archivo las palabras recibidas como argumentos y después
    las lee de vuelta.

    ```c linenums="1"
    #include <fcntl.h>
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <unistd.h>

    #define MAX_PALABRA 255

    // Escribe exactamente n bytes o termina el programa con un mensaje de error
    void escribir_o_salir(int fd, const void *datos, size_t n) {
        if (write(fd, datos, n) != (ssize_t)n) {
            perror("Error al escribir");
            exit(1);
        }
    }

    // Lee exactamente n bytes o termina el programa con un mensaje de error
    void leer_o_salir(int fd, void *destino, size_t n) {
        if (read(fd, destino, n) != (ssize_t)n) {
            fprintf(stderr, "Archivo truncado o con formato no válido\n");
            exit(1);
        }
    }

    int main(int argc, char *argv[]) {
        if (argc < 3) {
            fprintf(stderr, "Uso: %s archivo palabra...\n", argv[0]);
            return 1;
        }

        int fd = creat(argv[1], 0666);
        if (fd < 0) {
            perror(argv[1]);
            return 1;
        }
        int cantidad = argc - 2;
        // Formato: número de palabras y, por cada una, longitud y bytes
        escribir_o_salir(fd, &cantidad, sizeof(int));
        for (int i = 0; i < cantidad; i++) {
            int largo = (int)strlen(argv[2 + i]);
            escribir_o_salir(fd, &largo, sizeof(int));
            escribir_o_salir(fd, argv[2 + i], largo);
        }
        close(fd);

        fd = open(argv[1], O_RDONLY);
        if (fd < 0) {
            perror(argv[1]);
            return 1;
        }
        leer_o_salir(fd, &cantidad, sizeof(int));
        for (int i = 0; i < cantidad; i++) {
            int largo;
            char palabra[MAX_PALABRA + 1];

            leer_o_salir(fd, &largo, sizeof(int));
            // La longitud viene del archivo: se valida antes de usarla
            if (largo < 0 || largo > MAX_PALABRA) {
                fprintf(stderr, "Longitud no válida: %d\n", largo);
                exit(1);
            }
            leer_o_salir(fd, palabra, largo);
            palabra[largo] = '\0';
            printf("%s (%d bytes)\n", palabra, largo);
        }
        close(fd);
        return 0;
    }
    ```

    Ejecutado como `./programa palabras.bin gato perro canario`, imprime lo siguiente:

    ```plaintext title="Expected output"
    gato (4 bytes)
    perro (5 bytes)
    canario (7 bytes)
    ```

## E/S estándar con stdio

La biblioteca estándar de C ofrece, sobre las llamadas al sistema, un nivel superior con
_buffer_ en el que el archivo se representa con un puntero `FILE *` en lugar de un
descriptor. Los datos se acumulan en un _buffer_ de la biblioteca y se transfieren al
_kernel_ en bloques, lo que reduce el número de llamadas al sistema cuando se escribe o
se lee en piezas pequeñas.

| Función             | Descripción                                                    | Ejemplo de uso                    |
| ------------------- | -------------------------------------------------------------- | --------------------------------- |
| `fopen`, `fclose`   | Abre un archivo con un modo (`"r"`, `"w"`, `"a"`) y lo cierra. | `FILE *f = fopen("a.txt", "r");`  |
| `fgetc`, `fputc`    | Lee o escribe un carácter.                                     | `int c = fgetc(f);`               |
| `fgets`, `fputs`    | Lee una línea de un tamaño máximo o escribe una cadena.        | `fgets(linea, sizeof(linea), f);` |
| `getline`           | Lee una línea completa y reserva el _buffer_ necesario.        | `getline(&linea, &capacidad, f);` |
| `fprintf`, `fscanf` | Escribe o lee con formato, como `printf` y `scanf`.            | `fprintf(f, "%d\n", x);`          |

Con `fprintf` también pueden guardarse variables como texto, por ejemplo escribir
`x = 7` en una línea. El archivo resultante se lee con cualquier editor, pero recuperar
los valores obliga a analizar cada línea, que es más largo y frágil que leer la imagen
binaria de la sección anterior.

Se elige `stdio` para texto y para programas donde la comodidad pesa más que el control
fino, y los descriptores cuando se necesita ese control, como en tuberías, _sockets_ o
dispositivos, donde el _buffer_ de la biblioteca resulta un estorbo. Mezclar ambos sobre
el mismo archivo exige llamar a `fflush` antes de cambiar de interfaz, porque lo que
está en el _buffer_ de `stdio` todavía no ha llegado al descriptor. Por la misma razón,
la salida de `printf` redirigida a un archivo o una tubería se retiene hasta que el
_buffer_ se llena, a diferencia de lo que ocurre en un terminal, que la vacía en cada
salto de línea.

!!! warning "Trampas de `fgetc` y `fprintf`"

    El valor que devuelve `fgetc` debe guardarse en un `int` y no en un `char`. Con
    `char`, el valor `EOF` (`-1`) se confunde con el byte `0xFF` y el bucle de lectura
    termina antes de tiempo o no termina. Además, al copiar líneas con
    `fprintf(destino, linea)` el texto leído se interpreta como cadena de formato, y
    cualquier `%` del archivo origen provoca comportamiento indefinido. La forma
    correcta es `fputs(linea, destino)` o `fprintf(destino, "%s", linea)`.

## Metadatos con stat

La llamada `stat(ruta, &info)` rellena una `struct stat` con las propiedades del archivo
y devuelve 0, o `-1` si falla. La estructura, definida en `sys/stat.h`, incluye entre
otros campos `st_mode`, que codifica el tipo y los permisos, y `st_size`, el tamaño en
bytes. El tipo se consulta con las macros `S_ISREG` (regular), `S_ISDIR` (directorio),
`S_ISCHR` (dispositivo de caracteres), `S_ISFIFO` (tubería) y `S_ISSOCK` (_socket_), y
los permisos se extraen con una máscara, `st_mode & 0777`. La llamada `lstat` informa
del propio enlace simbólico en lugar del archivo al que apunta.

???+ example "Tipo, tamaño y permisos de un archivo"

    El tamaño tiene el tipo `off_t`, que en sistemas de 64 bits es un entero largo, por
    lo que se convierte a `long long` antes de imprimirlo con `%lld`. Usar `%d` produce
    comportamiento indefinido.

    ```c linenums="1"
    #define _DEFAULT_SOURCE
    #include <stdio.h>
    #include <sys/stat.h>
    #include <sys/types.h>

    // Devuelve una descripción del tipo de archivo según st_mode
    const char *tipo_de_archivo(mode_t modo) {
        if (S_ISREG(modo))
            return "archivo regular";
        if (S_ISDIR(modo))
            return "directorio";
        if (S_ISCHR(modo))
            return "dispositivo de caracteres";
        if (S_ISFIFO(modo))
            return "tubería (FIFO)";
        if (S_ISSOCK(modo))
            return "socket";
        return "otro";
    }

    int main(int argc, char *argv[]) {
        if (argc < 2) {
            fprintf(stderr, "Uso: %s ruta\n", argv[0]);
            return 1;
        }

        struct stat info;
        // stat rellena la estructura y devuelve 0, o -1 si hay error
        if (stat(argv[1], &info) == -1) {
            perror("Error en stat");
            return 1;
        }

        printf("Tipo: %s\n", tipo_de_archivo(info.st_mode));
        // off_t puede ser de 64 bits: se convierte a long long para imprimirlo
        printf("Tamaño: %lld bytes\n", (long long)info.st_size);
        printf("Permisos: %o\n", info.st_mode & 0777);
        return 0;
    }
    ```

    Aplicado a un archivo de cinco bytes creado con la máscara habitual, imprime:

    ```plaintext title="Expected output"
    Tipo: archivo regular
    Tamaño: 5 bytes
    Permisos: 644
    ```

    Sobre un directorio, el tamaño que informa `stat` es el de la lista de nombres que
    guarda el propio directorio, que suele ser 4096 bytes, y no la suma de los archivos
    que contiene.

## Directorios

La jerarquía estándar de directorios de Linux (`/bin`, `/etc`, `/home`, `/tmp` y el
resto) se describe en el capítulo de Linux. Desde C, un directorio se crea con
`mkdir(ruta, permisos)`, por ejemplo con `0777`, que la máscara `umask` recorta igual
que en los archivos, y se recorre con tres funciones de `dirent.h`:

- `opendir(ruta)` abre el directorio y devuelve un puntero `DIR *`, o `NULL` si falla.
- `readdir(dir)` devuelve en cada llamada un puntero a una `struct dirent` con la
  siguiente entrada, y `NULL` cuando no quedan más.
- `closedir(dir)` cierra el directorio y devuelve `-1` si falla.

Del registro `struct dirent` interesa el campo `d_name`, con el nombre de la entrada. El
orden en que `readdir` entrega las entradas no está definido, y siempre incluye las
entradas especiales `.` y `..`. Para obtener más información sobre una entrada hay que
llamar a `stat`, y esa llamada necesita la **ruta completa**: si se le pasa solo
`d_name`, el nombre se interpreta respecto al directorio de trabajo del proceso, de modo
que se consultaría un archivo distinto o fallaría. Por ello el ejemplo construye la ruta
con `snprintf`, que además no desborda el destino. Este recorrido es la base de
utilidades como `ls`, que añade el formato de los permisos y el tamaño.

???+ example "Recorrido de un directorio con readdir y stat"

    La función clasifica cada entrada como directorio, archivo regular u otro tipo. Se
    preparan un directorio de pruebas y se ordena la salida, porque `readdir` no
    garantiza ningún orden.

    ```c linenums="1"
    #include <dirent.h>
    #include <stdio.h>
    #include <sys/stat.h>
    #include <sys/types.h>

    #define MAX_RUTA 4096

    int listar_directorio(const char *directorio) {
        DIR *dir = opendir(directorio);
        if (dir == NULL) {
            perror("Error al abrir el directorio");
            return -1;
        }

        struct dirent *entrada;
        // readdir devuelve una entrada por llamada y NULL al terminar
        while ((entrada = readdir(dir)) != NULL) {
            char ruta[MAX_RUTA];
            // stat necesita la ruta completa, no solo el nombre de la entrada
            snprintf(ruta, sizeof(ruta), "%s/%s", directorio, entrada->d_name);

            struct stat info;
            if (stat(ruta, &info) == -1) {
                perror(ruta);
                continue;
            }
            if (S_ISDIR(info.st_mode))
                printf("%s: directorio\n", entrada->d_name);
            else if (S_ISREG(info.st_mode))
                printf("%s: regular, %lld bytes\n", entrada->d_name,
                       (long long)info.st_size);
            else
                printf("%s: otro\n", entrada->d_name);
        }

        if (closedir(dir) == -1) {
            perror("Error al cerrar el directorio");
            return -1;
        }
        return 0;
    }

    int main(int argc, char *argv[]) {
        if (argc < 2) {
            fprintf(stderr, "Uso: %s directorio\n", argv[0]);
            return 1;
        }
        return listar_directorio(argv[1]) == 0 ? 0 : 1;
    }
    ```

    ```bash linenums="1"
    mkdir -p demo/sub
    printf 'hola\n' > demo/a.txt
    head -c 120 /dev/zero | tr '\0' 'x' > demo/b.txt
    touch demo/.oculto
    mkfifo demo/tuberia
    ./listdir demo | LC_ALL=C sort
    ```

    ```plaintext title="Expected output"
    ..: directorio
    .: directorio
    .oculto: regular, 0 bytes
    a.txt: regular, 5 bytes
    b.txt: regular, 120 bytes
    sub: directorio
    tuberia: otro
    ```

## Implementación de cp

La utilidad `cp` copia un archivo y se reduce a un bucle de lectura y escritura. Las
decisiones relevantes son abrir primero el origen, de modo que un origen inexistente no
deje un destino vacío, y escribir tantos bytes como se leyeron. Un bloque de 4096 bytes
equilibra el número de llamadas y el uso de memoria.

???+ example "Implementación de cp con llamadas al sistema"

    La función cierra los dos descriptores en todos los caminos de salida y devuelve el
    estado a `main`, que lo traduce en el código de salida del programa.

    ```c linenums="1"
    #include <fcntl.h>
    #include <stdio.h>
    #include <stdlib.h>
    #include <unistd.h>

    #define TAM_BUFFER 4096

    int copia_archivo(const char *origen, const char *destino) {
        int fd_origen = open(origen, O_RDONLY);
        if (fd_origen < 0) {
            perror(origen);
            return -1;
        }

        // Equivale a creat(destino, 0666): crear, vaciar y abrir para escribir
        int fd_destino = open(destino, O_WRONLY | O_CREAT | O_TRUNC, 0666);
        if (fd_destino < 0) {
            perror(destino);
            close(fd_origen);
            return -1;
        }

        char buffer[TAM_BUFFER];
        ssize_t leidos;
        int resultado = 0;
        while ((leidos = read(fd_origen, buffer, sizeof(buffer))) > 0) {
            // Se escriben los bytes leídos, que pueden ser menos que el buffer
            if (write(fd_destino, buffer, leidos) != leidos) {
                perror("Error al escribir en el destino");
                resultado = -1;
                break;
            }
        }
        if (leidos < 0) {
            perror("Error al leer el origen");
            resultado = -1;
        }

        close(fd_origen);
        close(fd_destino);
        return resultado;
    }

    int main(int argc, char *argv[]) {
        if (argc != 3) {
            fprintf(stderr, "Uso: %s origen destino\n", argv[0]);
            return 1;
        }
        return copia_archivo(argv[1], argv[2]) == 0 ? EXIT_SUCCESS : EXIT_FAILURE;
    }
    ```

    ```bash linenums="1"
    ./mi_cp demo/b.txt copia.txt
    cmp demo/b.txt copia.txt && echo iguales
    ./mi_cp nada x
    ```

    ```plaintext title="Expected output"
    iguales
    nada: No such file or directory
    ```

!!! danger "Delegar la copia o el listado en `system()` es inseguro"

    Es tentador implementar utilidades como `cp` o `ls` componiendo una cadena y
    pasándola a `system`, pero el argumento llega a la _shell_ sin filtrar, y un nombre
    como `; rm -rf ~` ejecutaría un segundo comando. Hay que usar las llamadas de este
    capítulo, o lanzar el programa con `execv` como se explica en el
    [capítulo de procesos](section_3_processes.md).

Con los archivos y los directorios cubiertos, el
[siguiente capítulo](section_3_processes.md) estudia cómo un programa crea otros
procesos y los sustituye por programas distintos.
