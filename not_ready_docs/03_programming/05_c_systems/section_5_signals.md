---
icon: lucide/bell
authors: Daniel Bazo Correa
description:
    Señales POSIX en C sobre Linux, con su envío, su tratamiento con signal y sigaction,
    la interrupción de llamadas bloqueantes y los temporizadores con alarm y setitimer
    para la gestión del tiempo.
title: Señales y tiempo en C
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Este capítulo describe las señales como mecanismo de aviso asíncrono entre el _kernel_ y
los procesos, y entre procesos. Explica cómo se envían, cómo se ignoran o se atienden
con manejadores mediante `signal` y `sigaction`, qué ocurre con las llamadas bloqueantes
que una señal interrumpe y cómo se controla el tiempo con `alarm` y `setitimer`.

## Introducción

Unix puede enviar avisos a cualquier proceso en ejecución. Cuando se interrumpe con
`Ctrl + C` un programa lanzado desde la terminal, el terminal le manda un aviso. También
se avisa a todos los programas cuando la máquina va a apagarse, para que terminen con
orden la tarea que tenían entre manos, y el sistema termina por la fuerza a los procesos
que ignoran el aviso. Estos avisos son las **señales**.

El [capítulo de Linux](../../01_operative_systems/01_linux/section_1_fundamentals.md)
describe las señales más usadas desde la línea de comandos, la orden `kill` y los atajos
de teclado, por lo que aquí se estudia la interfaz en C. Se suponen los capítulos de
[fundamentos](section_1_fundamentals.md), [archivos](section_2_files.md) y
[procesos](section_3_processes.md), además de las funciones `readn` y `writen` del de
[comunicación entre procesos](section_4_ipc.md).

## Señales

El sistema de señales se diseñó para informar a los procesos de situaciones críticas que
pueden ocurrir en cualquier momento de su ejecución. La mayoría notifican errores, y
solo una pequeña parte son avisos informativos. Cada señal tiene un tratamiento por
defecto, que casi siempre es terminar el proceso, y el programa puede sustituirlo por
ignorar la señal o por ejecutar una función propia. Las señales son constantes enteras
definidas en `signal.h`.

| Señal       | Origen o uso                                                          | Acción por defecto |
| ----------- | --------------------------------------------------------------------- | ------------------ |
| `SIGINT`    | Interrupción desde el teclado (`Ctrl + C`).                           | Terminar.          |
| `SIGTERM`   | Petición de terminación ordenada, la que envía `kill` por defecto.    | Terminar.          |
| `SIGKILL`   | Terminación forzosa. No se puede ignorar ni atender.                  | Terminar.          |
| `SIGSTOP`   | Pausa el proceso. No se puede ignorar ni atender.                     | Detener.           |
| `SIGUSR1`   | Definida por el usuario, para uso de la aplicación.                   | Terminar.          |
| `SIGUSR2`   | Definida por el usuario, para uso de la aplicación.                   | Terminar.          |
| `SIGALRM`   | Vence un temporizador de tiempo real (`alarm`, `ITIMER_REAL`).        | Terminar.          |
| `SIGVTALRM` | Vence un temporizador de tiempo de CPU de usuario (`ITIMER_VIRTUAL`). | Terminar.          |
| `SIGCHLD`   | Un proceso hijo ha terminado.                                         | Ignorar.           |
| `SIGPIPE`   | Escritura en una tubería sin lectores.                                | Terminar.          |

El comando `kill -l` muestra la lista completa de señales del sistema.

## Envío de señales

La llamada `kill(pid, señal)` pide al _kernel_ que envíe una señal al proceso cuyo PID
se conoce, y devuelve `0` si tuvo éxito y `-1` si falló, por ejemplo con `ESRCH` si el
proceso no existe o con `EPERM` si el usuario no tiene permiso para señalarlo. Un
proceso puede obtener su propio PID con `getpid()` y el de su padre con `getppid()`, de
modo que puede enviarse una señal a sí mismo con `kill(getpid(), SIGINT)`, o de forma
más cómoda con `raise(SIGINT)`. Un padre y un hijo pueden avisarse entre sí del mismo
modo, y como cualquiera de los dos puede haber terminado antes del envío, la señal puede
no llegar a su destino y entonces `kill` falla.

???+ example "Envío de SIGTERM a un PID"

    El PID se convierte con `strtol`, que a diferencia de `atoi` permite detectar una
    entrada no numérica. Se prueba sobre un proceso `sleep` en segundo plano.

    ```c linenums="1"
    #define _DEFAULT_SOURCE
    #include <errno.h>
    #include <signal.h>
    #include <stdio.h>
    #include <stdlib.h>
    #include <sys/types.h>

    int main(int argc, char *argv[]) {
        if (argc < 2) {
            fprintf(stderr, "Uso: %s pid\n", argv[0]);
            return 1;
        }

        // strtol detecta entradas no numéricas, a diferencia de atoi
        char *fin;
        long valor = strtol(argv[1], &fin, 10);
        if (*fin != '\0' || valor <= 0) {
            fprintf(stderr, "PID no válido: %s\n", argv[1]);
            return 1;
        }

        pid_t pid = (pid_t)valor;
        // kill devuelve 0 si la señal se envió y -1 si hay error
        if (kill(pid, SIGTERM) == -1) {
            perror("Error en kill");
            return 1;
        }
        printf("SIGTERM enviada\n");
        return 0;
    }
    ```

    ```bash linenums="1"
    sleep 60 &
    ./enviar_sigterm $!
    wait $!
    echo "estado $?"
    ```

    ```plaintext title="Expected output"
    SIGTERM enviada
    estado 143
    ```

    El estado 143 es 128 más 15, el número de `SIGTERM`: la _shell_ informa de que el
    proceso murió por esa señal.

## Ignorar y atender señales

La llamada `signal(señal, acción)` indica al sistema operativo qué hacer cuando el
proceso reciba una señal. La acción es una de tres opciones: `SIG_IGN` para ignorarla,
`SIG_DFL` para restaurar el comportamiento por defecto o la dirección de una función
propia, el **manejador**. Las señales `SIGKILL` y `SIGSTOP` no se pueden ignorar ni
atender, porque garantizan que el administrador siempre puede detener un proceso. La
función devuelve el manejador que había antes, o `SIG_ERR` si falla.

Un manejador es una función que recibe un entero con el número de la señal y no devuelve
nada, `void manejador(int sig)`, lo que permite que una misma función atienda varias
señales distinguiéndolas por el argumento. Cuando llega la señal, el _kernel_ suspende
el proceso, ejecuta el manejador y, al terminar este, el proceso reanuda lo que hacía.

Un proceso que no tiene nada que hacer mientras espera señales no debe usar un bucle
vacío como `while (1);`, que consume el 100 % de una CPU sin necesidad. La llamada
`pause()` suspende el proceso sin consumir CPU hasta que llegue una señal, y se combina
con un bucle: `while (1) pause();`. Si el proceso ignora todas las señales que podrían
despertarlo, `pause` se queda esperando indefinidamente.

### Reglas para escribir manejadores

El manejador interrumpe al programa en un punto cualquiera, incluso en mitad de otra
función, y esto impone restricciones:

- Dentro de un manejador solo deben llamarse funciones seguras ante señales
  (_async-signal-safe_), como `write`, `_exit`, `kill`, `sigaction` o `signal`.
  Funciones como `printf` o `malloc` usan estructuras internas que pueden estar a
  medias, y llamarlas puede bloquear o corromper el programa. Por eso los ejemplos
  escriben con `write`.
- Las variables que el manejador comparte con el programa principal se declaran como
  `volatile sig_atomic_t`, un tipo entero que se lee y escribe de forma atómica y que el
  compilador no mantiene en un registro.
- Si el manejador llama a una función que puede modificar `errno`, debe guardar su valor
  al entrar y restaurarlo al salir, para no alterar la causa de un fallo anterior del
  programa principal.
- Lo habitual es hacer lo mínimo, como activar una variable o escribir un byte en una
  tubería, y dejar el trabajo para el programa principal.

### Semántica de signal y sigaction

Históricamente existen dos formas de reaccionar a una señal. En el modo **BSD**, el
manejador sigue registrado hasta que el programa lo cambie. En el modo **System V**, el
registro es de un solo uso: al recibir la señal, el sistema restaura la acción por
defecto antes de ejecutar el manejador, y un segundo aviso termina el proceso si el
manejador no se ha vuelto a registrar. En Linux, la función `signal` de la biblioteca
estándar se comporta de una forma u otra según las macros con las que se compile. El
programa siguiente registra el manejador una sola vez y se envía dos señales.

???+ example "Dos señales con un solo registro"

    El resultado depende de las opciones de compilación, no del código.

    ```c linenums="1"
    #include <signal.h>
    #include <unistd.h>

    void manejador(int sig) {
        (void)sig;
        ssize_t r = write(STDOUT_FILENO, "recibida\n", 9);
        (void)r;
    }

    int main(void) {
        // El manejador se registra una sola vez, fuera de manejador()
        signal(SIGUSR1, manejador);
        raise(SIGUSR1);
        raise(SIGUSR1);
        ssize_t r = write(STDOUT_FILENO, "fin\n", 4);
        (void)r;
        return 0;
    }
    ```

    Con `gcc -std=gnu11` (modo BSD) el manejador sigue activo y se atienden las dos:

    ```plaintext title="Expected output"
    recibida
    recibida
    fin
    ```

    Con `gcc -std=c11` (modo System V) la segunda señal encuentra la acción por defecto
    y termina el proceso, de modo que solo aparece una línea y la _shell_ informa de
    `User defined signal 1`:

    ```plaintext title="Expected output"
    recibida
    ```

Para obtener un comportamiento independiente de la compilación hay dos soluciones. La
primera, antigua, consiste en volver a registrar el manejador dentro de sí mismo, con
`signal(sig, manejador)` como primera instrucción. Deja una pequeña ventana en la que
una señal puede llegar con la acción por defecto, por lo que no es la solución
definitiva. La segunda es usar `sigaction`, que tiene una semántica única y definida por
POSIX.

La llamada `sigaction(señal, &nueva, &anterior)` instala la acción descrita en `nueva`
y, si `anterior` no es `NULL`, guarda en ella la acción previa. La estructura
`struct sigaction` tiene tres campos principales:

| Campo        | Contenido                                                                                                                  |
| ------------ | -------------------------------------------------------------------------------------------------------------------------- |
| `sa_handler` | El manejador, o `SIG_IGN` o `SIG_DFL`.                                                                                     |
| `sa_mask`    | Señales que se bloquean mientras se ejecuta el manejador, vaciada con `sigemptyset`.                                       |
| `sa_flags`   | Opciones. `SA_RESTART` reinicia las llamadas interrumpidas y `SA_NOCLDSTOP` evita avisos de `SIGCHLD` por hijos detenidos. |

Durante la ejecución del manejador, el sistema bloquea la propia señal que lo activó, de
modo que no se atiende a sí misma de forma recursiva. Las señales estándar no se
encolan: si llegan varias iguales mientras está bloqueada, solo se entrega una. Esto es
lo que obliga al patrón de recoger todos los hijos en bucle visto en el capítulo de
procesos.

El uso más extendido de las señales en servicios y programas de larga duración es el
**cierre ordenado**. `SIGTERM` es la señal con la que el sistema pide terminar antes de
un apagado, y `SIGINT` la de `Ctrl + C`. Un programa que las atiende no debe terminar
dentro del manejador, sino activar un indicador, y es el bucle principal quien lo
consulta, termina la tarea en curso, libera sus recursos y sale con código `0`.

???+ example "Cierre ordenado con SIGTERM"

    El manejador solo activa un indicador. La llamada `sleep` se interrumpe al llegar la
    señal, y el bucle termina al comprobarlo. Se prueba enviando `SIGTERM` a los dos
    segundos y medio.

    ```c linenums="1"
    #define _DEFAULT_SOURCE
    #include <signal.h>
    #include <stdio.h>
    #include <unistd.h>

    static volatile sig_atomic_t terminar = 0;

    void manejador(int sig) {
        (void)sig;
        // Solo se activa un indicador: el trabajo lo hace el programa principal
        terminar = 1;
    }

    int main(void) {
        struct sigaction accion = {0};
        accion.sa_handler = manejador;
        sigemptyset(&accion.sa_mask);
        sigaction(SIGTERM, &accion, NULL);
        sigaction(SIGINT, &accion, NULL);

        int tarea = 0;
        while (!terminar) {
            printf("Tarea %d\n", ++tarea);
            fflush(stdout);
            // sleep se interrumpe cuando llega una señal
            sleep(1);
        }
        printf("Señal recibida: se liberan los recursos y se sale\n");
        return 0;
    }
    ```

    ```bash linenums="1"
    ./cierre_ordenado &
    sleep 2.5
    kill -TERM $!
    wait $!
    echo "estado $?"
    ```

    ```plaintext title="Expected output"
    Tarea 1
    Tarea 2
    Tarea 3
    Señal recibida: se liberan los recursos y se sale
    estado 0
    ```

### Espera de señales y condiciones de carrera

El patrón de comprobar una variable y llamar a `pause()` tiene una carrera: si la señal
llega entre la comprobación y la llamada a `pause`, se pierde el aviso y el proceso
queda dormido aunque el evento ya ocurrió. En el programa de los hijos del capítulo de
procesos se mitigó acotando la espera con `sleep(1)`. La solución correcta consiste en
bloquear la señal con `sigprocmask`, comprobar la variable y suspenderse con
`sigsuspend`, que desbloquea y duerme en una sola operación atómica, o en convertir las
señales en eventos de una tubería, como se describe en las
[máquinas de estados](section_6_state_machines.md).

## Señales y llamadas bloqueantes

Una señal no solo interrumpe el código ordinario, sino que también interrumpe las
llamadas bloqueantes. Cuando un proceso espera un recurso con `read`, `write`, `open`
sobre una FIFO o `sleep`, y le llega una señal cuyo manejador se ejecuta, la llamada
termina antes de tiempo: devuelve `-1` con `errno` igual a `EINTR` (`sleep` devuelve los
segundos que faltaban) o un resultado parcial. Por eso cada llamada bloqueante debe
estar preparada para reintentarse, de la forma que aplican `readn` y `writen`.

Si se registra el manejador con la opción `SA_RESTART`, el sistema reinicia
automáticamente muchas de estas llamadas y el programa no ve el `EINTR`. Cuando el
objetivo es que la señal despierte el programa, como al implementar un tiempo de espera
máximo sobre una lectura, se registra sin esa opción.

???+ example "Lectura interrumpida por una alarma"

    El manejador no hace nada, y lo que interesa es su efecto sobre `read`. La alarma
    vence al cabo de un segundo, con la entrada aún vacía.

    ```c linenums="1"
    #define _DEFAULT_SOURCE
    #include <errno.h>
    #include <signal.h>
    #include <stdio.h>
    #include <unistd.h>

    void manejador(int sig) {
        (void)sig;
    }

    int main(void) {
        struct sigaction accion = {0};
        accion.sa_handler = manejador;
        sigemptyset(&accion.sa_mask);
        // Sin SA_RESTART, las llamadas bloqueantes devuelven -1 con errno = EINTR
        accion.sa_flags = 0;
        sigaction(SIGALRM, &accion, NULL);
        alarm(1);

        char buffer[50];
        ssize_t leidos;
        do {
            leidos = read(STDIN_FILENO, buffer, sizeof(buffer));
            if (leidos == -1 && errno == EINTR)
                printf("read interrumpida por una señal, se reintenta\n");
        } while (leidos == -1 && errno == EINTR);

        if (leidos == -1) {
            perror("Error en read");
            return 1;
        }
        printf("Lectura terminada con %zd bytes\n", leidos);
        return 0;
    }
    ```

    En la ejecución con una entrada que tarda tres segundos en cerrarse, `read` se
    interrumpe una vez y, al reintentarla, devuelve 0 al terminar la entrada:

    ```bash linenums="1"
    sleep 3 | ./lectura_eintr
    ```

    ```plaintext title="Expected output"
    read interrumpida por una señal, se reintenta
    Lectura terminada con 0 bytes
    ```

!!! warning "El reintento debe comprobar `-1` y `EINTR`"

    La condición de reintento es `leidos == -1 && errno == EINTR`. Escribir
    `leidos < -1` la deja siempre falsa, porque `read` nunca devuelve un valor menor que
    `-1`, y el programa trata la interrupción como un fallo o continúa con datos no
    leídos.

## Temporizadores

Para controlar el tiempo en una aplicación de comunicaciones, el sistema operativo
ofrece temporizadores que se comunican a través de señales. La llamada `alarm(segundos)`
programa una cuenta atrás y, al llegar a cero, envía `SIGALRM` al proceso. Su acción por
defecto es terminar, de modo que un programa que ejecute `alarm(5)` y espere con
`pause()` termina a los cinco segundos. Una nueva llamada a `alarm` sustituye a la
anterior, y `alarm(0)` la cancela. Para un temporizador periódico hay que registrar un
manejador de `SIGALRM` y volver a armar la alarma en cada vencimiento.

Las alarmas tienen dos inconvenientes. Solo admiten segundos enteros, de modo que no
pueden expresar intervalos menores. Y en un temporizador periódico, entre el final del
`pause` y la nueva llamada a `alarm` transcurre un tiempo que se acumula y alarga poco a
poco el periodo.

### setitimer

La llamada `setitimer(cual, &valor, NULL)` resuelve ambos problemas con una resolución
de microsegundos y un intervalo de repetición automático. El tercer argumento, que
permite recuperar el temporizador anterior, suele ser `NULL`. El primer argumento
selecciona el tipo de cuenta atrás:

| Constante        | Mide                                                   | Señal       |
| ---------------- | ------------------------------------------------------ | ----------- |
| `ITIMER_REAL`    | Tiempo real transcurrido.                              | `SIGALRM`   |
| `ITIMER_VIRTUAL` | Tiempo en que el proceso ocupa la CPU en modo usuario. | `SIGVTALRM` |

El segundo argumento es una `struct itimerval` con dos campos de tipo `struct timeval`,
que a su vez contiene `tv_sec` y `tv_usec` (microsegundos, con valores entre 0 y
999999). El campo `it_value` indica cuánto falta para el primer aviso y `it_interval`
cada cuánto se repite después. Con `it_interval` a cero, el temporizador se dispara una
sola vez.

???+ example "Temporizador periódico"

    El programa dispara un aviso cada 0,2 segundos y termina tras cinco. El manejador
    escribe un punto con `write` y cuenta los avisos, y el programa principal espera con
    `pause` sin consumir CPU.

    ```c linenums="1"
    #define _DEFAULT_SOURCE
    #include <signal.h>
    #include <stdio.h>
    #include <sys/time.h>
    #include <unistd.h>

    #define MAX_AVISOS 5

    static volatile sig_atomic_t avisos = 0;

    void manejador(int sig) {
        (void)sig;
        ssize_t r = write(STDOUT_FILENO, ".", 1);
        (void)r;
        avisos++;
    }

    int main(void) {
        struct sigaction accion = {0};
        accion.sa_handler = manejador;
        sigemptyset(&accion.sa_mask);
        sigaction(SIGALRM, &accion, NULL);

        // Primer aviso a los 0,2 s y repetición cada 0,2 s
        struct itimerval temporizador;
        temporizador.it_value.tv_sec = 0;
        temporizador.it_value.tv_usec = 200000;
        temporizador.it_interval = temporizador.it_value;
        if (setitimer(ITIMER_REAL, &temporizador, NULL) == -1) {
            perror("Error en setitimer");
            return 1;
        }

        // Espera sin consumir CPU hasta que llegue cada señal
        while (avisos < MAX_AVISOS)
            pause();
        printf("\n%d avisos recibidos\n", (int)avisos);
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    .....
    5 avisos recibidos
    ```

!!! warning "`ITIMER_VIRTUAL` no avanza mientras el proceso duerme"

    Con `ITIMER_VIRTUAL`, el temporizador solo cuenta mientras el proceso ejecuta código
    de usuario. Si el programa espera con `pause()`, el temporizador nunca vence, porque
    un proceso bloqueado no consume tiempo de CPU. Para una espera pasiva hay que usar
    `ITIMER_REAL`. Además, un valor de `tv_usec` de un millón o más no es válido y
    `setitimer` falla con `EINVAL`: los segundos van en `tv_sec`.

### Cálculo limitado por tiempo

Un uso característico es acotar un cálculo por tiempo: se arma un temporizador de una
sola vez cuyo manejador activa un indicador, y el bucle de cálculo lo consulta entre una
iteración y la siguiente. El ejemplo calcula términos de la sucesión de Fibonacci con la
función recursiva, que tarda cada vez más, hasta que vence el límite. Cuántos términos
se alcanzan depende de la velocidad del equipo, y el indicador solo se comprueba al
terminar cada término, de modo que el último puede tardar algo más que el límite.

???+ example "Fibonacci recursivo con límite de tiempo"

    El temporizador se dispara una sola vez a los 0,5 segundos, porque `it_interval`
    queda a cero.

    ```c linenums="1"
    #define _DEFAULT_SOURCE
    #include <signal.h>
    #include <stdio.h>
    #include <sys/time.h>

    static volatile sig_atomic_t fin_tiempo = 0;

    void manejador(int sig) {
        (void)sig;
        fin_tiempo = 1;
    }

    // Cada término tarda más que el anterior
    long long fib(int n) {
        return n < 2 ? n : fib(n - 1) + fib(n - 2);
    }

    int main(void) {
        struct sigaction accion = {0};
        accion.sa_handler = manejador;
        sigemptyset(&accion.sa_mask);
        sigaction(SIGALRM, &accion, NULL);

        // Un solo aviso a los 0,5 s: it_interval queda a cero
        struct itimerval limite = {0};
        limite.it_value.tv_usec = 500000;
        setitimer(ITIMER_REAL, &limite, NULL);

        // fib(92) es el último valor que cabe en un long long
        int n = 0;
        while (!fin_tiempo && n < 93) {
            fib(n);
            n++;
        }
        printf("Límite de tiempo alcanzado antes del término 93: %s\n",
               fin_tiempo ? "sí" : "no");
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    Límite de tiempo alcanzado antes del término 93: sí
    ```

## Gestión del tiempo

Las herramientas de tiempo vistas se complementan y conviene elegir según la necesidad:

| Mecanismo   | Resolución    | Comportamiento                                                                     |
| ----------- | ------------- | ---------------------------------------------------------------------------------- |
| `sleep(n)`  | Segundos      | Suspende el proceso. Una señal lo interrumpe y devuelve los segundos que faltaban. |
| `alarm(n)`  | Segundos      | Envía `SIGALRM` una vez al vencer.                                                 |
| `setitimer` | Microsegundos | Envía `SIGALRM` o `SIGVTALRM`, una vez o de forma periódica.                       |

Hay otra técnica sin señales, que consiste en guardar la hora del evento anterior y
compararla con la actual al llegar el siguiente, como hacen las máquinas de estados con
transiciones por tiempo transcurrido que se describen en el
[capítulo siguiente](section_6_state_machines.md). Esa técnica no puede avisar de que un
tiempo ha vencido si no llega ningún evento, y para eso se necesita un temporizador con
señal. En un servidor con varios clientes, los temporizadores se combinan con la espera
simultánea sobre varios descriptores que presenta el
[capítulo de _sockets_](section_7_sockets.md).

Con las señales y el tiempo, los capítulos anteriores forman el conjunto de piezas con
el que se construyen las aplicaciones de comunicaciones. El
[siguiente capítulo](section_6_state_machines.md), sobre máquinas de estados, las
organiza alrededor de un bucle de eventos, y el de [_sockets_](section_7_sockets.md) las
lleva a la red.
