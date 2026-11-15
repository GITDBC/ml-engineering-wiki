---
icon: lucide/arrow-left-right
authors: Daniel Bazo Correa
description:
    Comunicación entre procesos en C sobre Linux con tuberías anónimas y FIFOs, la
    semántica de lectura y escritura sobre canales, las funciones readn y writen, los
    protocolos con cabecera y la redirección de descriptores con dup2.
title: Comunicación entre procesos en C
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Este capítulo presenta las tuberías como mecanismo básico de comunicación entre
procesos. Describe las tuberías anónimas (`pipe`) y con nombre (FIFO), la semántica de
`read` y `write` sobre canales, las funciones auxiliares `readn` y `writen`, los
protocolos con cabecera de longitud y la redirección de la entrada y la salida estándar
con `dup2`.

## Introducción

Los procesos tienen memorias separadas, como se vio en el
[capítulo de procesos](section_3_processes.md), y las señales del
[capítulo de señales](section_5_signals.md) solo transmiten un aviso sin datos. Las
aplicaciones necesitan facilidades más ricas para intercambiar información, que el
sistema operativo ofrece en forma de llamadas al sistema de **comunicación entre
procesos** (IPC, _Inter-Process Communication_). Algunas de ellas permiten además
sincronizar los procesos.

Este capítulo se centra en el mecanismo más sencillo, las tuberías. Otros mecanismos
tienen su propio capítulo: los [_sockets_](section_7_sockets.md) comunican procesos de
máquinas distintas, y la memoria compartida y los semáforos se tratan en el capítulo de
[memoria compartida](../07_concurrency/section_2_shared_memory.md) del módulo de
concurrencia. Los ejemplos suponen la gestión de errores y los descriptores de los
capítulos de [fundamentos](section_1_fundamentals.md) y [archivos](section_2_files.md).

## Tuberías

Una **tubería** (_pipe_) es una zona de memoria del _kernel_ que se ofrece como una cola
donde se escriben y se leen bytes de forma secuencial. Es un canal de comunicación con
tres propiedades:

- Los datos salen en el mismo orden en que entraron, y el _kernel_ garantiza que no se
  alteran mientras permanecen en la tubería.
- Al leerse, los bytes desaparecen. Una lectura consume los datos.
- La capacidad es limitada. Cuando la tubería está llena, el escritor debe esperar.

Una tubería se usa en modo **símplex**, es decir, de forma unidireccional y siempre en
el mismo sentido. Si se necesita un diálogo en ambos sentidos hay que crear dos
tuberías, una por sentido. Linux ofrece dos tipos. Las **tuberías anónimas** (_pipes_)
no aparecen en el sistema de archivos, se crean en tiempo de ejecución con una llamada
al sistema y las comparten procesos emparentados, normalmente un padre y su hijo. El
_kernel_ las mantiene mientras haya algún proceso con el canal abierto, y cuando todos
terminan libera la memoria y los datos pendientes se pierden. Las **tuberías con
nombre** (_FIFO_, de _First In, First Out_) sí aparecen como archivos y permiten que se
comuniquen dos procesos cualesquiera. En un listado con `ls -l` una FIFO siempre muestra
tamaño 0, haya o no datos esperando a ser leídos, y el carácter `p` como tipo.

El operador `|` de la _shell_ usa tuberías anónimas. En `ls | sort`, la _shell_ crea una
tubería, conecta la salida estándar de `ls` a su extremo de escritura y la entrada
estándar de `sort` a su extremo de lectura. La sección sobre `dup2` explica cómo se
implementa.

## Semántica de lectura y escritura en canales

Las llamadas `read` y `write` que se usan con archivos regulares se comportan de forma
distinta en tuberías y _sockets_, porque ahí el otro extremo puede no estar listo. Hay
que conocer estas reglas para escribir código correcto.

La llamada `read` es **bloqueante** si no hay datos disponibles: el proceso sale de la
CPU hasta que otro escriba en la tubería. Al despertar, `read` devuelve los bytes que
haya en ese momento, hasta el máximo pedido, que pueden ser menos que los solicitados y
no es un error. Mientras el lector no ocupa la CPU, el escritor puede seguir añadiendo
datos, por lo que no existe una correspondencia entre las llamadas a `write` y a `read`.
Un valor `0` indica que el extremo escritor cerró la tubería.

La llamada `write` tiene tres reglas:

- Una escritura puede completarse solo en parte, por ejemplo si una señal la interrumpe
  o si el canal es un _socket_, y hay que reintentar con los bytes que falten.
- Si la tubería está llena, el proceso se bloquea hasta que haya sitio.
- Si el lector ya cerró su extremo, el _kernel_ envía al escritor la señal `SIGPIPE`,
  cuya acción por defecto es terminar el proceso.

Además, si `read` o `write` devuelven `-1` con `errno` igual a `EINTR`, es que una señal
interrumpió la llamada y hay que repetirla. Las escrituras de hasta `PIPE_BUF` bytes
(4096 en Linux) en una tubería son atómicas, es decir, no se mezclan con las de otros
escritores, por lo que escribir un entero de cuatro bytes nunca queda partido.

!!! warning "`SIGPIPE` termina el proceso que escribe sin lectores"

    Ignorar `SIGPIPE` con `signal(SIGPIPE, SIG_IGN)` hace que la escritura falle con el
    error `EPIPE`, que el programa puede tratar. Es la configuración habitual en
    servidores, que no deben morir porque un cliente se desconecte.

???+ example "Escribir en una tubería sin lectores"

    Se cierra el único extremo de lectura y se ignora `SIGPIPE`. La escritura devuelve
    `-1` con `errno` igual a `EPIPE`, cuyo texto es `Broken pipe`.

    ```c linenums="1"
    #include <errno.h>
    #include <signal.h>
    #include <stdio.h>
    #include <string.h>
    #include <unistd.h>

    int main(void) {
        // Sin esto, escribir sin lectores termina el proceso con SIGPIPE
        signal(SIGPIPE, SIG_IGN);

        int tuberia[2];
        if (pipe(tuberia) < 0) {
            perror("Error en pipe");
            return 1;
        }
        // Se cierra el único extremo de lectura
        close(tuberia[0]);

        if (write(tuberia[1], "x", 1) == -1)
            printf("write falló: %s\n", strerror(errno));
        close(tuberia[1]);
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    write falló: Broken pipe
    ```

## Las funciones readn y writen

Comprobar siempre la cantidad leída o escrita y reintentar tras `EINTR` conduce a
repetir el mismo código en cada llamada. Por eso es habitual encapsularlo en dos
funciones que garantizan la transferencia completa. La función `readn` lee exactamente
`n` bytes salvo que el otro extremo cierre, y `writen` escribe exactamente `n`. Se
guardan en la cabecera `io_util.h`, que los ejemplos de este capítulo y de los
siguientes incluyen con `#include "io_util.h"`.

Los valores de retorno de `readn` permiten distinguir tres casos. Un valor igual a `n`
indica éxito, un valor menor indica que el otro extremo cerró antes de enviar todo y
`-1` indica un error.

```c linenums="1"
#ifndef IO_UTIL_H
#define IO_UTIL_H

#include <errno.h>
#include <sys/types.h>
#include <unistd.h>

// Lee exactamente n bytes salvo que se llegue al final del canal.
// Devuelve los bytes leídos (menos de n si el otro extremo cerró) o -1 si falla.
static inline ssize_t readn(int fd, void *datos, size_t n) {
    char *p = datos;
    size_t total = 0;

    while (total < n) {
        ssize_t leidos = read(fd, p + total, n - total);
        if (leidos < 0) {
            // Una señal interrumpió la llamada: se reintenta
            if (errno == EINTR)
                continue;
            return -1;
        }
        // 0 indica que el otro extremo cerró el canal
        if (leidos == 0)
            break;
        total += leidos;
    }
    return total;
}

// Escribe exactamente n bytes. Devuelve n, o -1 si falla.
static inline ssize_t writen(int fd, const void *datos, size_t n) {
    const char *p = datos;
    size_t total = 0;

    while (total < n) {
        ssize_t escritos = write(fd, p + total, n - total);
        if (escritos < 0) {
            if (errno == EINTR)
                continue;
            return -1;
        }
        total += escritos;
    }
    return total;
}

#endif
```

### Cuándo usar read y cuándo readn

La función `writen` se usa siempre. En lectura, `readn` es la opción cuando se espera un
número de bytes conocido de antemano, como los bytes de un `int`, de un `float` o de una
estructura, o `N` caracteres que se van a guardar en un _array_. En cambio, `read` es la
opción cuando llega una cadena de longitud variable, como una frase en una conversación
o una línea de texto, donde recibir menos bytes de los pedidos no supone ningún
problema.

Si se usara `readn` para una cadena de longitud desconocida, por ejemplo con
`readn(fd, usuario, 49)` sobre un _buffer_ de 50, la llamada esperaría de forma
obligatoria los 49 bytes y bloquearía el proceso si el escritor envió menos. Con `read`,
por el contrario, hay que recordar que lee todo lo que haya en ese momento. Un `write`
del emisor no corresponde a un `read` del receptor, y si el escritor envía dos mensajes
seguidos, el lector puede recibirlos juntos en una sola lectura.

### Protocolo con cabecera de longitud

Para enviar datos de tamaño variable con fiabilidad, se envía primero una **cabecera**
de tamaño fijo y conocido que indica cuántos bytes tiene el mensaje que sigue,
normalmente un entero. El receptor lee la cabecera con `readn` y después exactamente esa
cantidad de bytes. El ejemplo envía un usuario y una clave, que no tienen un largo fijo,
por una tubería de un padre a su hijo. La llamada `pipe` que la crea se detalla en la
sección siguiente.

???+ example "Envío de campos de longitud variable con cabecera"

    La función `recibir_campo` valida la longitud recibida antes de usarla como tamaño
    de lectura, porque un valor negativo o demasiado grande desbordaría el destino. El
    terminador `'\0'` lo añade el receptor, ya que no viaja por el canal.

    ```c linenums="1"
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <sys/wait.h>
    #include "io_util.h"

    #define MAX_CAMPO 50

    // Envía un campo precedido de su longitud (cabecera de tamaño fijo)
    int enviar_campo(int fd, const char *campo) {
        int cabecera = (int)strlen(campo);
        if (writen(fd, &cabecera, sizeof(int)) < 0 || writen(fd, campo, cabecera) < 0)
            return -1;
        return 0;
    }

    // Recibe un campo: primero la cabecera y luego exactamente esos bytes
    int recibir_campo(int fd, char destino[MAX_CAMPO]) {
        int cabecera;
        if (readn(fd, &cabecera, sizeof(int)) != sizeof(int))
            return -1;
        // La longitud llega por el canal: se valida antes de usarla
        if (cabecera < 0 || cabecera >= MAX_CAMPO)
            return -1;
        if (readn(fd, destino, cabecera) != cabecera)
            return -1;
        destino[cabecera] = '\0';
        return 0;
    }

    int main(void) {
        int tuberia[2];
        // La tubería se crea antes de fork para que el hijo herede ambos extremos
        if (pipe(tuberia) < 0) {
            perror("Error en pipe");
            exit(1);
        }

        pid_t pid = fork();
        if (pid < 0) {
            perror("Error en fork");
            exit(1);
        }

        if (pid == 0) {
            // Hijo lector: cierra el extremo de escritura que no usa
            close(tuberia[1]);
            char usuario[MAX_CAMPO], clave[MAX_CAMPO];
            if (recibir_campo(tuberia[0], usuario) < 0 ||
                recibir_campo(tuberia[0], clave) < 0) {
                fprintf(stderr, "Mensaje incompleto\n");
                exit(1);
            }
            printf("El usuario es: %s\nLa clave es: %s\n", usuario, clave);
            close(tuberia[0]);
            exit(0);
        }

        // Padre escritor: cierra el extremo de lectura que no usa
        close(tuberia[0]);
        if (enviar_campo(tuberia[1], "ana lopez") < 0 ||
            enviar_campo(tuberia[1], "123456") < 0) {
            perror("Error al escribir en la tubería");
            exit(1);
        }
        close(tuberia[1]);
        wait(NULL);
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    El usuario es: ana lopez
    La clave es: 123456
    ```

## Tuberías anónimas

La llamada `pipe(fd)` recibe un _array_ de dos enteros y, si tiene éxito, los rellena
con dos descriptores. En `fd[0]` está el extremo de lectura y en `fd[1]` el de
escritura, y devuelve `-1` si falla. Hay que crearla **antes de `fork`** para que el
hijo herede ambos descriptores y los dos procesos puedan usar el canal, como en el
ejemplo anterior.

!!! warning "Cada proceso debe cerrar el extremo que no usa"

    Tras el `fork`, un escritor cierra `fd[0]` y un lector cierra `fd[1]`. Es una norma
    de corrección, no de orden: el _kernel_ solo informa del fin de datos a un lector
    con `read` igual a `0` cuando **todos** los extremos de escritura están cerrados,
    incluidas las copias heredadas. Si el lector conserva abierto el extremo de
    escritura, o si el padre no cierra su copia de un extremo que usa el hijo, el lector
    no llega a ver el final y se queda bloqueado.

Para un diálogo en los dos sentidos hace falta una segunda tubería, con la misma
disciplina de cierre: una por sentido, con el extremo de escritura de cada una en el
proceso que envía. Cuando uno de los dos procesos cierra su extremo de escritura, el
otro recibe el final de datos y puede terminar.

## FIFOs

Una FIFO es una tubería que tiene un nombre en el sistema de archivos, por lo que dos
procesos sin parentesco pueden comunicarse abriéndola por su ruta. Se crea desde la
_shell_ con `mkfifo ruta`, o desde C con la función `mkfifo(ruta, permisos)`, y se usa
con `open`, `read`, `write` y `close` como cualquier archivo. La llamada `open` sobre
una FIFO **sincroniza** a los dos extremos: quien abre para leer se bloquea hasta que
aparece un escritor, y quien abre para escribir se bloquea hasta que aparece un lector.
Cuando el escritor cierra, el lector recibe `read` igual a 0 y termina.

???+ example "Comunicación a través de una FIFO"

    El lector se lanza en segundo plano y queda bloqueado en `open` hasta que el
    escritor abre la FIFO. `cat` abre la FIFO, lee por bloques y vuelca el contenido
    hasta el final.

    ```bash linenums="1"
    mkfifo mi_fifo
    # Lector: se bloquea hasta que alguien escriba
    cat mi_fifo &
    # Escritor: el operador > abre la FIFO para escribir
    echo "mensaje por la FIFO" > mi_fifo
    wait
    rm mi_fifo
    ```

    ```plaintext title="Expected output"
    mensaje por la FIFO
    ```

Un programa en C que abra la FIFO con `open` una sola vez y la mantenga abierta se
comporta igual que `cat` y `echo`, y usa `readn` y `writen` de la misma forma que con
una tubería anónima. Abrir y cerrar la FIFO en cada mensaje también funciona, porque
cada cierre del escritor produce un final de datos para el lector, pero cada mensaje
cuesta entonces una apertura.

## Redirección con dup2

Cada proceso tiene una tabla de descriptores en la que cada entrada apunta a un archivo
abierto. La llamada `dup2(origen, destino)` hace que el descriptor `destino` apunte al
mismo archivo que `origen`, y si `destino` estaba abierto lo cierra antes. Las funciones
de la biblioteca estándar y los programas que usan los descriptores 0, 1 y 2 no saben
adónde van realmente, de modo que redirigir esos tres es la forma de conectar programas
ya escritos sin modificarlos.

Esto es lo que hace una _shell_ al interpretar `programa > archivo` o `a | b`. Crea un
hijo con `fork`, y este ajusta sus descriptores con `dup2` y ejecuta después el programa
con `exec`, que conserva los descriptores abiertos. El siguiente ejemplo redirige la
salida de `echo` a un archivo.

???+ example "Redirección de la salida estándar a un archivo"

    Tras `dup2`, el descriptor 1 apunta a `salida.txt` y se cierra el descriptor
    original, que ya no hace falta. `echo` escribe en el descriptor 1 sin saber que es
    un archivo. El padre espera al hijo y se convierte en `cat` para mostrar el
    resultado.

    ```c linenums="1"
    #include <fcntl.h>
    #include <stdio.h>
    #include <stdlib.h>
    #include <sys/wait.h>
    #include <unistd.h>

    int main(void) {
        pid_t pid = fork();
        if (pid < 0) {
            perror("Error en fork");
            exit(1);
        }

        if (pid == 0) {
            int fd = open("salida.txt", O_WRONLY | O_CREAT | O_TRUNC, 0644);
            if (fd < 0) {
                perror("Error al abrir salida.txt");
                exit(1);
            }
            // El descriptor 1 pasa a apuntar a salida.txt, como con `> salida.txt`
            if (dup2(fd, STDOUT_FILENO) < 0) {
                perror("Error en dup2");
                exit(1);
            }
            close(fd);
            // exec conserva los descriptores: echo escribe en el archivo sin saberlo
            execlp("echo", "echo", "texto redirigido", (char *)NULL);
            perror("Error en exec");
            exit(1);
        }

        waitpid(pid, NULL, 0);
        printf("El archivo contiene:\n");
        fflush(stdout);
        execlp("cat", "cat", "salida.txt", (char *)NULL);
        perror("Error en exec");
        return 1;
    }
    ```

    ```plaintext title="Expected output"
    El archivo contiene:
    texto redirigido
    ```

Una tubería se conecta de la misma forma. El ejemplo siguiente implementa el equivalente
de `printf 'c\nb\na\n' | sort`. Un hijo productor redirige su salida estándar al extremo
de escritura de la tubería y ejecuta `printf`. Un hijo consumidor redirige su entrada
estándar al extremo de lectura y ejecuta `sort`.

???+ example "Equivalente de una canalización de la _shell_"

    Cada hijo cierra los dos descriptores de la tubería después de `dup2`, y el padre
    también. Si algún extremo de escritura quedara abierto, `sort` no recibiría nunca el
    final de la entrada y el programa no terminaría.

    ```c linenums="1"
    #include <stdio.h>
    #include <stdlib.h>
    #include <sys/wait.h>
    #include <unistd.h>

    int main(void) {
        int tuberia[2];
        if (pipe(tuberia) < 0) {
            perror("Error en pipe");
            exit(1);
        }

        pid_t productor = fork();
        if (productor < 0) {
            perror("Error en fork");
            exit(1);
        }
        if (productor == 0) {
            // La salida estándar pasa a ser el extremo de escritura de la tubería
            dup2(tuberia[1], STDOUT_FILENO);
            // Los descriptores originales ya no hacen falta en el hijo
            close(tuberia[0]);
            close(tuberia[1]);
            execlp("printf", "printf", "c\\nb\\na\\n", (char *)NULL);
            perror("Error en exec");
            exit(1);
        }

        pid_t consumidor = fork();
        if (consumidor < 0) {
            perror("Error en fork");
            exit(1);
        }
        if (consumidor == 0) {
            // La entrada estándar pasa a ser el extremo de lectura
            dup2(tuberia[0], STDIN_FILENO);
            close(tuberia[0]);
            close(tuberia[1]);
            execlp("sort", "sort", (char *)NULL);
            perror("Error en exec");
            exit(1);
        }

        // Si el padre conservara tuberia[1], sort nunca vería el fin de archivo
        close(tuberia[0]);
        close(tuberia[1]);
        waitpid(productor, NULL, 0);
        waitpid(consumidor, NULL, 0);
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    a
    b
    c
    ```

Las tuberías sirven para comunicar procesos de una misma máquina. El
[siguiente capítulo](section_5_signals.md) describe el aviso asíncrono entre procesos y
los temporizadores. Cuando los procesos se encuentran en máquinas distintas, el canal
pasa a ser un _socket_, y las funciones `readn` y `writen` y los protocolos con cabecera
de este capítulo se reutilizan tal cual en el
[capítulo de _sockets_](section_7_sockets.md).
