---
icon: lucide/lock
authors: Daniel Bazo Correa
description:
    Mecanismos de comunicación y sincronización entre hilos que comparten memoria, desde
    la espera activa hasta los semáforos, los mutex, las variables de condición y los
    monitores, con implementaciones en C sobre POSIX.
title: Memoria compartida
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Este capítulo recorre los mecanismos con los que varios hilos que comparten memoria se
coordinan para acceder a recursos comunes sin interferir entre sí. Tras fijar qué
significa que un programa concurrente sea correcto, parte de la espera activa construida
solo con variables compartidas, como el algoritmo de Peterson, y avanza hacia primitivas
de mayor nivel: semáforos, regiones críticas, _mutex_, variables de condición y
monitores. Para cada mecanismo se presenta la idea, una implementación en C con
`pthread.h` y `semaphore.h` y las trampas habituales, como el interbloqueo, la inanición
o la inversión de prioridad. Presupone los conceptos de sección crítica, exclusión mutua
e intercalación descritos en el capítulo de [fundamentos](section_1_fundamentals.md).

## Introducción

En un programa concurrente intervienen dos tipos de entidades. Las **entidades activas**
son los hilos o procesos, que ejecutan código y hacen avanzar el programa. Las
**entidades pasivas** son los recursos que esos hilos necesitan para trabajar: una
variable, un _buffer_, un archivo o un dispositivo. Algunos recursos se pueden usar en
cualquier momento, pero otros solo admiten el acceso cuando se cumplen ciertas
condiciones de seguridad, como la exclusión mutua. Este capítulo trata de cómo imponer
esas condiciones cuando los hilos se comunican a través de memoria compartida.

Los ejemplos con función `main` son programas completos que se compilan con
`gcc -Wall -Wextra -pthread programa.c -o programa`.

### Interferencia sobre una variable compartida

Dos hilos que ejecutan `contador++` sobre la misma variable pueden perder incrementos,
porque la sentencia se compila en tres instrucciones máquina (cargar, sumar y almacenar)
y como mucho cada una de ellas es atómica, como se vio con la condición de carrera de
los [fundamentos](section_1_fundamentals.md). El código que accede al recurso compartido
es la sección crítica, y la solución consiste en garantizar que las secciones críticas
de distintos hilos no se solapen en el tiempo, es decir, que se ejecuten en exclusión
mutua. Para el resto de hilos, cada sección crítica debe parecer una operación atómica.
Garantizarlo exige sincronizar a los hilos: si uno quiere entrar mientras otro está
dentro, debe esperar a que este salga.

### Condiciones de sincronización

No todos los problemas son de exclusión mutua. En el **productor-consumidor** más
sencillo, un hilo deja un dato en una variable compartida y otro lo recoge. Sin
coordinación, el consumidor lee varias veces el mismo dato y el productor sobrescribe
datos que nadie ha leído. Aquí no hay dos escrituras concurrentes, sino un problema de
orden que se resuelve con dos **condiciones de sincronización**: el consumidor no puede
extraer un dato hasta que se haya producido uno nuevo, y el productor no puede almacenar
un dato nuevo hasta que se haya leído el anterior.

La forma más primitiva de imponerlas es la **espera activa**: una variable booleana
`hay_dato` indica si hay un dato pendiente, y cada hilo gira en un bucle vacío hasta que
la condición le permite continuar.

```c linenums="1"
long dato = 0;
// 1 si hay un dato pendiente de consumir
int hay_dato = 0;

void poner(long valor)
{
    // Espera a que se haya leído el dato anterior
    while (hay_dato) {
    }
    dato = valor;
    hay_dato = 1;
}

long leer(void)
{
    // Espera a que haya un dato nuevo
    while (!hay_dato) {
    }
    long v = dato;
    hay_dato = 0;
    return v;
}
```

Con este esquema cada dato se consume exactamente una vez, aunque los dos hilos quedan
muy acoplados, pues avanzan al mismo ritmo. La solución general interpone un _buffer_ de
varias posiciones para desacoplarlos, como se verá con los semáforos y los monitores.

!!! warning "Variables ordinarias como banderas"

    El fragmento anterior expresa la idea, pero con variables ordinarias no es correcto
    en C: el compilador puede mantener `hay_dato` en un registro y convertir el bucle en
    infinito, y el procesador puede reordenar las escrituras de `dato` y `hay_dato`. La
    sección sobre la espera activa en el hardware real explica cómo usar
    `<stdatomic.h>` para que estos algoritmos funcionen.

## Corrección de un programa concurrente

Antes de comparar soluciones conviene precisar qué significa que una sea correcta. Las
propiedades de un programa concurrente se agrupan en dos familias, y una solución válida
debe satisfacer ambas.

Las **propiedades de seguridad** (_safety_) afirman que el sistema nunca alcanza un
estado erróneo. Son ejemplos la exclusión mutua, las condiciones de sincronización del
productor-consumidor y la ausencia de **interbloqueo** (_deadlock_), el estado en el que
todos los hilos de un grupo están bloqueados esperando un evento que solo otro hilo del
grupo podría producir. Una violación de seguridad se demuestra con una traza finita que
conduce al estado prohibido.

Las **propiedades de vivacidad** (_liveness_) afirman que en algún momento ocurre algo
bueno. Para la exclusión mutua se exigen tres:

- **Progreso sin contención**: Si solo un hilo quiere entrar en su sección crítica, en
  algún momento debe poder hacerlo.
- **Ausencia de _livelock_**: Si varios hilos quieren entrar a la vez, en algún momento
  alguno de ellos debe conseguirlo. En un _livelock_ los hilos siguen ejecutando
  instrucciones, por ejemplo en un bucle de espera activa, pero ninguno avanza.
- **Ausencia de inanición** (_starvation_): Todo hilo que quiere entrar acaba entrando.
  Un hilo sufre inanición cuando los demás lo adelantan indefinidamente, aunque el
  sistema en conjunto progrese.

Las propiedades de vivacidad dependen de las hipótesis sobre el planificador. Un
planificador **justo** (_fair_) garantiza que todo hilo listo acaba siendo seleccionado
para ejecutarse. La justicia se refina según cómo se repita una petición. Un
planificador **débilmente justo** atiende toda petición que se mantiene de forma
continua. Uno **fuertemente justo** atiende toda petición que se repite infinitas veces,
aunque sea de forma intermitente. Una condición que se activa y desactiva sin cesar
puede no ser atendida nunca por un planificador solo débilmente justo.

## Espera activa

Con estas propiedades como vara de medir, se puede construir la exclusión mutua usando
solo lecturas y escrituras de variables compartidas. Cada hilo rodea su sección crítica
con un **preprotocolo**, que decide si puede entrar, y un **posprotocolo**, que anuncia
que ha salido. Mientras no puede entrar, el hilo gira en un bucle de espera activa
consultando las variables del protocolo. Se busca primero una solución para dos hilos,
`p0` y `p1`, cada uno de los cuales conoce su identificador `yo` y el del otro,
`otro = 1 - yo`.

```plaintext linenums="1"
while (1) {
    preprotocolo      // entrar(yo)
    sección crítica
    posprotocolo      // salir(yo)
    sección no crítica
}
```

### Intentos ingenuos

Tres protocolos aparentemente razonables fallan, y cada uno viola una propiedad
distinta.

| Intento                     | Idea                                                                 | Fallo                                                                                        |
| --------------------------- | -------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| Indicadores de intención    | Levantar la bandera propia y esperar mientras la del otro lo esté.   | _Livelock_: ambos levantan la bandera a la vez y esperan para siempre.                       |
| Comprobar antes de anunciar | Esperar a que la bandera del otro baje y después levantar la propia. | Se viola la exclusión mutua: ambos comprueban antes de que ninguno levante la bandera.       |
| Variable de turno           | Esperar mientras el turno sea del otro y cederlo al salir.           | Alternancia estricta: un hilo no puede reentrar si el otro está fuera de su sección crítica. |

El primero garantiza la exclusión mutua, pero no la vivacidad. El segundo evita el
_livelock_ a costa de perder la seguridad, que es la propiedad más grave. El tercero
garantiza la exclusión mutua y evita el _livelock_, pero viola el progreso sin
contención, porque un hilo que quiere entrar sin competencia debería poder hacerlo. Cada
fallo se demuestra con una traza concreta. Solo hace falta una que viole la propiedad.

### Algoritmo de Peterson

El **algoritmo de Peterson** combina el primer y el tercer intento. Cuando un hilo
quiere entrar, levanta su bandera y, por cortesía, cede el turno al otro. Después espera
solo mientras el otro quiera entrar y además tenga el turno. Al salir, baja su bandera.

???+ example "Exclusión mutua con el algoritmo de Peterson"

    Dos hilos incrementan un millón de veces cada uno un contador protegido por
    `entrar()` y `salir()`. Si el protocolo garantiza la exclusión mutua, el contador
    final vale dos millones.

    ```c linenums="1"
    #include <pthread.h>
    #include <stdatomic.h>
    #include <stdio.h>

    #define ITERACIONES 1000000

    // Intención de entrar de cada hilo y turno de cortesía
    static atomic_int quiere[2];
    static atomic_int turno;
    // Recurso protegido por el protocolo
    static long contador = 0;

    static void entrar(int yo)
    {
        int otro = 1 - yo;
        atomic_store(&quiere[yo], 1);
        atomic_store(&turno, otro);
        // Espera activa mientras el otro quiera entrar y tenga el turno
        while (atomic_load(&quiere[otro]) && atomic_load(&turno) == otro) {
        }
    }

    static void salir(int yo)
    {
        atomic_store(&quiere[yo], 0);
    }

    static void *hilo(void *arg)
    {
        int yo = *(int *)arg;
        for (int i = 0; i < ITERACIONES; i++) {
            entrar(yo);
            // Sección crítica
            contador++;
            salir(yo);
        }
        return NULL;
    }

    int main(void)
    {
        pthread_t th[2];
        int ids[2] = {0, 1};

        for (int i = 0; i < 2; i++) {
            pthread_create(&th[i], NULL, hilo, &ids[i]);
        }
        for (int i = 0; i < 2; i++) {
            pthread_join(th[i], NULL);
        }
        printf("contador = %ld (esperado %d)\n", contador, 2 * ITERACIONES);
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    contador = 2000000 (esperado 2000000)
    ```

El algoritmo cumple todas las propiedades exigidas:

- **Exclusión mutua**: Si los dos hilos estuvieran dentro, ambos tendrían la bandera
  levantada. Considérese el último que escribió en `turno`, por ejemplo `p0`, que dejó
  `turno = 1`. Al evaluar su guarda, `p0` vio `quiere[1] == 1` y `turno == 1`, de modo
  que no pudo salir del bucle. Contradicción.
- **Ausencia de _livelock_**: Si ambos quieren entrar, `turno` solo puede valer 0 o 1 y
  decide cuál pasa.
- **Progreso sin contención**: Si `p1` no quiere entrar, `quiere[1]` es 0 y `p0` entra
  de inmediato.
- **Ausencia de inanición**: Si `p0` sale y quiere volver a entrar, pone `turno = 1` y
  se cierra el paso a sí mismo, de modo que entra `p1`. Ningún hilo adelanta al otro más
  de una vez.

El algoritmo solo sirve para dos hilos. Para más se puede anidar en forma de torneo,
emparejando hilos de dos en dos, o recurrir al **algoritmo de la panadería** de Leslie
Lamport. Este se inspira en el dispensador de números de una tienda: cada hilo que
quiere entrar toma un número mayor que todos los repartidos y espera a que no quede
nadie con un número menor, con el identificador como desempate. Como elegir el número no
es atómico, un _array_ `pidiendo` obliga a esperar a que el otro termine de elegir antes
de compararse con él. Los hilos entran por orden de llegada y ninguno sufre inanición,
pero cada entrada recorre los $N$ hilos y los números crecen sin límite.

### Espera activa en el hardware real

Los algoritmos anteriores suponen **consistencia secuencial**: las operaciones de todos
los hilos se intercalan en un único orden global que respeta el orden de cada programa.
Los compiladores y procesadores modernos no ofrecen esa garantía sobre variables
ordinarias. El compilador puede mantener una variable en un registro o reordenar accesos
independientes, y el procesador puede adelantar una lectura a una escritura anterior a
otra dirección, que es justo el patrón de Peterson: escribir `quiere[yo]` y leer
`quiere[otro]`.

En C11 la solución es declarar las variables del protocolo con `<stdatomic.h>`.
`atomic_load` y `atomic_store` usan por defecto el orden `memory_order_seq_cst`, que
restablece la consistencia secuencial e introduce las barreras de memoria necesarias.
Además, la escritura con la que un hilo sale y la lectura con la que el otro entra
establecen una relación de orden que hace visibles los cambios realizados dentro de la
sección crítica, por lo que `contador` puede seguir siendo un `long` ordinario.

!!! warning "`volatile` no basta"

    `volatile` impide que el compilador elimine o fusione accesos, pero no genera
    barreras de memoria ni ordena las operaciones del procesador. Una versión de
    Peterson con `volatile int` en lugar de `atomic_int` pierde incrementos.

La espera activa tiene además un coste evidente: el hilo que espera consume ciclos de
CPU sin hacer trabajo útil y, en un único núcleo, puede retrasar al mismo hilo que debe
liberar la sección crítica. Por eso en la práctica se reserva para esperas muy cortas en
sistemas multiprocesador y se apoya en instrucciones atómicas de lectura y modificación,
como _test-and-set_ o _compare-and-swap_, en lugar de algoritmos basados solo en
lecturas y escrituras.

### _Spinlocks_

Un **_spinlock_** es una variante del _mutex_ con espera activa que proporciona el
sistema. El hilo que intenta tomarlo mientras está ocupado permanece activo, comprobando
en un bucle si se ha liberado. POSIX ofrece `pthread_spinlock_t`, construido sobre
instrucciones atómicas del procesador, con las funciones `pthread_spin_init`,
`pthread_spin_lock`, `pthread_spin_trylock`, `pthread_spin_unlock` y
`pthread_spin_destroy`, análogas a las del _mutex_ que se describe más adelante. Solo
compensa cuando se mantiene tomado durante muy poco tiempo y hay varios núcleos. Si la
sección crítica es larga, o puede bloquearse por entrada y salida, conviene un mecanismo
que suspenda al hilo en lugar de hacerlo girar.

## Semáforos

Ese mecanismo de suspensión es el semáforo, propuesto por Edsger Dijkstra. Un
**semáforo** almacena un número natural que representa los permisos todavía disponibles
para acceder a un recurso. Se llama **semáforo general** si puede tomar valores mayores
que uno y **semáforo binario** si solo toma los valores 0 y 1.

### Definición

Sobre un semáforo `s` se definen dos operaciones, que por definición se ejecutan de
forma atómica:

- **`wait(s)`**: Decrementa `s` en cuanto el resultado sea no negativo. Si `s` vale 0,
  el hilo se suspende hasta que el valor sea positivo y pueda realizar el decremento. En
  la notación original de Dijkstra es la operación `P`.
- **`post(s)`**: Incrementa `s` y, si hay hilos suspendidos en `wait`, despierta a uno
  de ellos. Es la operación `V`, también llamada `signal`.

La diferencia con la espera activa es que el hilo bloqueado en `wait` no consume CPU. El
sistema operativo lo retira de la cola de listos y lo devuelve a ella cuando otro `post`
le concede el permiso. Una consecuencia directa de la definición es que, si un semáforo
se inicializa a 0 y cinco hilos ejecutan, en cualquier orden, dos `post` y tres `wait`,
exactamente uno de los hilos que hacen `wait` queda bloqueado para siempre.

### Semáforos POSIX

La cabecera `semaphore.h` ofrece semáforos de tipo `sem_t`. Los semáforos sin nombre se
declaran como variables y se inicializan con `sem_init()` antes de crear los hilos que
los usan.

| Función                        | Descripción                                                                                                              |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------ |
| `sem_init(&s, pshared, valor)` | Inicializa el semáforo con `valor`. `pshared` es 0 si es local al proceso y distinto de 0 si se comparte entre procesos. |
| `sem_destroy(&s)`              | Libera los recursos del semáforo. Destruir un semáforo con hilos esperando es un error.                                  |
| `sem_wait(&s)`                 | Decrementa el semáforo o bloquea al hilo hasta que pueda hacerlo.                                                        |
| `sem_trywait(&s)`              | Decrementa si es posible y, si el valor es 0, devuelve -1 con `errno` igual a `EAGAIN` en lugar de bloquear.             |
| `sem_post(&s)`                 | Incrementa el semáforo y despierta a un hilo en espera si lo hay.                                                        |
| `sem_getvalue(&s, &valor)`     | Escribe en `valor` el valor actual del semáforo.                                                                         |

Todas devuelven 0 si tienen éxito y -1 si fallan, con la causa en `errno`. El valor que
devuelve `sem_getvalue()` puede haber cambiado antes de que el hilo lo use, de modo que
solo sirve para depurar y nunca para tomar decisiones de sincronización. Para
sincronizar procesos independientes existen los semáforos con nombre, que se abren con
`sem_open("/nombre", ...)`, se cierran con `sem_close()` y se eliminan del sistema con
`sem_unlink()`, y que usan las mismas `sem_wait()` y `sem_post()`.

### Exclusión mutua con semáforos

Un semáforo binario inicializado a 1 resuelve la exclusión mutua para cualquier número
de hilos. El preprotocolo es `sem_wait()`, que cierra el semáforo e impide entrar a los
demás, y el posprotocolo es `sem_post()`, que lo abre de nuevo.

???+ example "Contador protegido por un semáforo binario"

    Tres hilos incrementan un millón de veces cada uno el mismo contador.

    ```c linenums="1"
    #include <pthread.h>
    #include <semaphore.h>
    #include <stdio.h>

    #define HILOS 3
    #define ITERACIONES 1000000

    static sem_t mutex;
    static long contador = 0;

    static void *acceso(void *arg)
    {
        (void)arg;
        for (int i = 0; i < ITERACIONES; i++) {
            sem_wait(&mutex);
            // Sección crítica
            contador++;
            sem_post(&mutex);
        }
        return NULL;
    }

    int main(void)
    {
        pthread_t th[HILOS];

        // Semáforo binario: un único permiso
        sem_init(&mutex, 0, 1);
        for (int i = 0; i < HILOS; i++) {
            pthread_create(&th[i], NULL, acceso, NULL);
        }
        for (int i = 0; i < HILOS; i++) {
            pthread_join(th[i], NULL);
        }
        sem_destroy(&mutex);
        printf("contador = %ld\n", contador);
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    contador = 3000000
    ```

Si el semáforo se inicializa con un valor $M > 1$, la misma estructura garantiza que
haya como mucho $M$ hilos a la vez en la sección crítica. Este uso, a veces llamado
**multiplex**, modela recursos con varias unidades idénticas, como un aparcamiento con
$M$ plazas o un conjunto de conexiones a una base de datos.

### Señalización

Además de la exclusión mutua, los semáforos expresan condiciones de orden entre hilos.
En el **aviso** (_signaling_), un semáforo inicializado a 0 representa un evento. El
hilo que debe esperarlo hace `wait` y el que lo produce hace `post`. Si el `post` ocurre
antes, el permiso queda guardado y el `wait` posterior no se bloquea, de modo que el
aviso no se pierde.

???+ example "Aviso entre dos hilos"

    El hilo trabajador calcula un resultado y avisa. `main` se bloquea hasta que el
    resultado está disponible.

    ```c linenums="1"
    #include <pthread.h>
    #include <semaphore.h>
    #include <stdio.h>

    // A 0: representa el evento «el resultado está listo»
    static sem_t listo;
    static long resultado;

    static void *calcular(void *arg)
    {
        (void)arg;
        long suma = 0;
        for (long i = 1; i <= 1000; i++) {
            suma += i;
        }
        resultado = suma;
        // Avisa de que resultado ya es válido
        sem_post(&listo);
        return NULL;
    }

    int main(void)
    {
        pthread_t th;

        sem_init(&listo, 0, 0);
        pthread_create(&th, NULL, calcular, NULL);
        // Bloqueo pasivo hasta que el hilo publique el resultado
        sem_wait(&listo);
        printf("resultado = %ld\n", resultado);
        pthread_join(th, NULL);
        sem_destroy(&listo);
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    resultado = 500500
    ```

Encadenar avisos impone una relación de precedencia, y dos avisos cruzados forman una
**cita** (_rendezvous_), en la que dos hilos deben llegar a un punto antes de que
cualquiera continúe. Cada hilo hace `post` en su propio semáforo y después `wait` en el
del otro. El orden importa: si ambos hicieran primero `wait`, los dos se bloquearían y
habría interbloqueo. La generalización a $N$ hilos es la **barrera**, que POSIX ofrece
directamente con `pthread_barrier_t`. `pthread_barrier_init()` fija el número de hilos
que deben llegar y `pthread_barrier_wait()` bloquea hasta que llegan todos.

### Productor-consumidor con semáforos

El productor-consumidor con un _buffer_ circular de `TAM` posiciones combina los dos
usos de los semáforos. Las propiedades que debe cumplir se traducen una a una en
semáforos:

- **El productor no almacena si el _buffer_ está lleno**: `hay_espacio`, inicializado a
  `TAM`, vale 0 cuando el _buffer_ está lleno. El productor hace `wait` antes de
  almacenar y el consumidor hace `post` después de extraer.
- **El consumidor no extrae si el _buffer_ está vacío**: `hay_datos`, inicializado a 0,
  vale 0 cuando no hay datos. El consumidor hace `wait` antes de extraer y el productor
  hace `post` después de almacenar.
- **El _buffer_ se usa en exclusión mutua**: `mutex`, inicializado a 1, protege el
  acceso al _buffer_. Con un único productor y un único consumidor los otros dos
  semáforos ya impiden que ambos toquen la misma posición, y el `mutex` solo es
  imprescindible con varios de cada clase, como se ve en
  [problemas clásicos](section_4_classic_problems.md).

???+ example "_Buffer_ acotado con tres semáforos"

    Un productor genera los enteros de 0 a 999 y un consumidor los suma. La suma
    obtenida confirma que no se pierde ni se repite ningún dato.

    ```c linenums="1"
    #include <pthread.h>
    #include <semaphore.h>
    #include <stdio.h>

    #define TAM 8
    #define DATOS 1000

    static int buffer[TAM];
    // Huecos libres, elementos disponibles y acceso exclusivo al buffer
    static sem_t hay_espacio, hay_datos, mutex;

    static void *productor(void *arg)
    {
        (void)arg;
        int entrada = 0;
        for (int dato = 0; dato < DATOS; dato++) {
            sem_wait(&hay_espacio);
            sem_wait(&mutex);
            buffer[entrada] = dato;
            entrada = (entrada + 1) % TAM;
            sem_post(&mutex);
            sem_post(&hay_datos);
        }
        return NULL;
    }

    static void *consumidor(void *arg)
    {
        long *suma = arg;
        int salida = 0;
        for (int k = 0; k < DATOS; k++) {
            sem_wait(&hay_datos);
            sem_wait(&mutex);
            *suma += buffer[salida];
            salida = (salida + 1) % TAM;
            sem_post(&mutex);
            sem_post(&hay_espacio);
        }
        return NULL;
    }

    int main(void)
    {
        pthread_t p, c;
        long suma = 0;

        sem_init(&hay_espacio, 0, TAM);
        sem_init(&hay_datos, 0, 0);
        sem_init(&mutex, 0, 1);
        pthread_create(&p, NULL, productor, NULL);
        pthread_create(&c, NULL, consumidor, &suma);
        pthread_join(p, NULL);
        pthread_join(c, NULL);
        printf("suma consumida = %ld\n", suma);
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    suma consumida = 499500
    ```

!!! danger "El orden de los `wait` importa"

    Intercambiar los dos `wait` del preprotocolo produce interbloqueo. Si el consumidor
    toma primero `mutex` y después espera en `hay_datos` con el _buffer_ vacío, se
    bloquea con el `mutex` tomado. El productor no puede entonces entrar a almacenar el
    dato que despertaría al consumidor, y ambos quedan bloqueados para siempre. Regla
    general: nunca bloquearse en un semáforo de condición mientras se retiene el de
    exclusión mutua.

Las variantes con varios productores y consumidores, y los demás problemas clásicos, se
desarrollan en el capítulo de [problemas clásicos](section_4_classic_problems.md).

### Interbloqueo y filósofos

El problema de los **filósofos** modela el interbloqueo por espera circular. Cinco
filósofos alternan entre pensar y comer alrededor de una mesa redonda. Entre cada par de
platos hay un tenedor, y cada filósofo necesita los dos tenedores adyacentes para comer.
Cada tenedor se representa de forma natural con un semáforo binario. Si cada filósofo
toma primero su tenedor izquierdo y después el derecho, puede ocurrir que los cinco
tomen el izquierdo a la vez. Entonces cada uno espera el tenedor que retiene su vecino y
el sistema queda bloqueado.

```mermaid
flowchart LR
    F0["Filósofo 0"] -->|espera el tenedor 1| F1["Filósofo 1"]
    F1 -->|espera el tenedor 2| F2["Filósofo 2"]
    F2 -->|espera el tenedor 3| F3["Filósofo 3"]
    F3 -->|espera el tenedor 4| F4["Filósofo 4"]
    F4 -->|espera el tenedor 0| F0
```

Un interbloqueo requiere que se den a la vez cuatro condiciones, conocidas como
condiciones de Coffman: exclusión mutua sobre los recursos, retención de un recurso
mientras se espera otro, imposibilidad de arrebatar un recurso a quien lo tiene y una
cadena circular de esperas. Basta con romper una de ellas. Por la disposición de la
mesa, como mucho dos filósofos pueden comer a la vez, de modo que limitar a cuatro los
filósofos que compiten por los tenedores rompe la espera circular sin restar
concurrencia. Un semáforo general `sillas` inicializado a $N - 1$ implementa ese límite.

???+ example "Filósofos sin interbloqueo con un semáforo de sillas"

    Cada filósofo come 10 000 veces. Sin las dos líneas que usan `sillas`, el programa
    se queda bloqueado en la práctica y hay que interrumpirlo. Aun así, que una
    ejecución termine no demuestra por sí solo que la solución sea correcta.

    ```c linenums="1"
    #include <pthread.h>
    #include <semaphore.h>
    #include <stdio.h>

    #define N 5
    #define COMIDAS 10000

    // Un semáforo binario por tenedor y uno general para las sillas
    static sem_t tenedor[N];
    static sem_t sillas;
    static int comidas[N];

    static void *filosofo(void *arg)
    {
        int id = *(int *)arg;
        for (int k = 0; k < COMIDAS; k++) {
            // Como mucho N - 1 filósofos compiten por los tenedores
            sem_wait(&sillas);
            sem_wait(&tenedor[id]);
            sem_wait(&tenedor[(id + 1) % N]);
            comidas[id]++;
            sem_post(&tenedor[(id + 1) % N]);
            sem_post(&tenedor[id]);
            sem_post(&sillas);
        }
        return NULL;
    }

    int main(void)
    {
        pthread_t th[N];
        int ids[N];
        int total = 0;

        sem_init(&sillas, 0, N - 1);
        for (int i = 0; i < N; i++) {
            sem_init(&tenedor[i], 0, 1);
        }
        for (int i = 0; i < N; i++) {
            ids[i] = i;
            pthread_create(&th[i], NULL, filosofo, &ids[i]);
        }
        for (int i = 0; i < N; i++) {
            pthread_join(th[i], NULL);
            total += comidas[i];
        }
        printf("comidas totales = %d\n", total);
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    comidas totales = 50000
    ```

Otra forma clásica de romper la espera circular es imponer un orden global en la
adquisición de recursos, por ejemplo que un filósofo tome siempre primero el tenedor de
menor índice. Esa regla de ordenar los _mutex_ es la técnica general para evitar
interbloqueos cuando un hilo necesita varios recursos.

### Limitaciones de los semáforos

Los semáforos son primitivas de muy bajo nivel. Son eficientes, pero resultan poco
adecuados para problemas de sincronización complejos como los lectores-escritores, que
con preferencia para los escritores exigen cinco semáforos y varios contadores:

- **Sobrecarga de significado**: El mismo tipo de objeto sirve para la exclusión mutua y
  para las condiciones de sincronización, lo que dificulta entender la interacción entre
  los hilos y modificar el código.
- **Fragilidad**: Olvidar un `wait` en un preprotocolo viola la exclusión mutua, y
  olvidar un `post` en un posprotocolo produce bloqueos. Ninguno de los dos errores lo
  detecta el compilador.
- **Dispersión**: El protocolo de acceso a un recurso queda repartido por el código de
  todos los hilos que lo usan, de modo que cualquiera de ellos puede romper una
  propiedad básica.

Las regiones críticas y los monitores responden a estas críticas trasladando la
responsabilidad de la exclusión mutua del programador al lenguaje.

## Regiones críticas

Una sección crítica es una secuencia de instrucciones que debería ejecutarse en
exclusión mutua, y es el programador quien debe asegurarlo con un _mutex_. Una **región
crítica** es una secuencia de instrucciones que, por definición, se ejecuta en exclusión
mutua: el lenguaje inserta de forma transparente los _mutex_ necesarios. En pseudocódigo
se escribe con un constructor especial que asocia el bloque a un identificador:

```plaintext linenums="1"
region (v) {
    S;
}
```

Un hilo que quiere ejecutar `S` debe adquirir la zona de exclusión asociada a `v`. Si
otro hilo la tiene, se bloquea en una cola asociada a ese mecanismo. Al terminar, el
hilo libera la zona y permite entrar al primero de la cola. Solo las regiones
etiquetadas con el mismo identificador se excluyen entre sí, de modo que `region (v1)` y
`region (v2)` pueden ejecutarse a la vez. Si dos variables no guardan relación, lo
adecuado es protegerlas con identificadores distintos: usar uno solo sería correcto,
pero reduciría la concurrencia sin necesidad.

### _Mutex_ POSIX

C no tiene regiones críticas como constructor del lenguaje. POSIX ofrece el equivalente
mediante el _mutex_, de tipo `pthread_mutex_t`, y la región crítica se obtiene
encerrando el bloque entre `lock` y `unlock`.

| Función                         | Descripción                                                                                  |
| ------------------------------- | -------------------------------------------------------------------------------------------- |
| `pthread_mutex_init(&m, &attr)` | Inicializa el _mutex_ desbloqueado. Con `attr` igual a `NULL` usa los atributos por defecto. |
| `PTHREAD_MUTEX_INITIALIZER`     | Inicializa estáticamente un _mutex_ con atributos por defecto.                               |
| `pthread_mutex_lock(&m)`        | Adquiere el _mutex_ o bloquea al hilo hasta que quede libre.                                 |
| `pthread_mutex_trylock(&m)`     | Intenta adquirirlo sin bloquear y devuelve `EBUSY` si está tomado.                           |
| `pthread_mutex_unlock(&m)`      | Libera el _mutex_, que debe estar tomado por el propio hilo.                                 |
| `pthread_mutex_destroy(&m)`     | Destruye el _mutex_, que debe estar desbloqueado.                                            |

A diferencia de un semáforo binario, un _mutex_ tiene propietario: solo el hilo que lo
adquirió puede liberarlo. Con el tipo por defecto, liberar un _mutex_ ajeno o ya libre
es comportamiento indefinido. El tipo `PTHREAD_MUTEX_ERRORCHECK`, que se fija con
`pthread_mutexattr_settype()`, hace que esas llamadas devuelvan un error. Los atributos
se gestionan con `pthread_mutexattr_init()` y `pthread_mutexattr_destroy()`, e incluyen
el protocolo frente a la inversión de prioridad y si el _mutex_ se comparte entre
procesos.

???+ example "Problema de los jardines con un _mutex_"

    Cuatro puertas de un jardín registran siete millones de visitas en total. Sin las
    llamadas a `pthread_mutex_lock()` y `pthread_mutex_unlock()` el total quedaría por
    debajo y sería distinto en cada ejecución.

    ```c linenums="1"
    #include <pthread.h>
    #include <stdio.h>

    #define PUERTAS 4

    static long visitantes = 0;
    static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

    static void *puerta(void *arg)
    {
        long n = *(long *)arg;
        for (long i = 0; i < n; i++) {
            // Región crítica: lectura, incremento y escritura indivisibles
            pthread_mutex_lock(&mutex);
            visitantes++;
            pthread_mutex_unlock(&mutex);
        }
        return NULL;
    }

    int main(void)
    {
        pthread_t th[PUERTAS];
        long visitas[PUERTAS] = {1000000, 2000000, 2000000, 2000000};

        for (int i = 0; i < PUERTAS; i++) {
            pthread_create(&th[i], NULL, puerta, &visitas[i]);
        }
        for (int i = 0; i < PUERTAS; i++) {
            pthread_join(th[i], NULL);
        }
        printf("visitantes = %ld\n", visitantes);
        pthread_mutex_destroy(&mutex);
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    visitantes = 7000000
    ```

### Inversión de prioridad

En sistemas con prioridades fijas, un _mutex_ puede provocar una **inversión de
prioridad**. Supóngase un hilo de baja prioridad `L` que tiene tomado un _mutex_ que
necesita otro de alta prioridad `H`. `H` se bloquea, lo cual es esperable, pero si
entonces se activa un hilo de prioridad media `M` que no usa el _mutex_, `M` expulsa a
`L`. `L` no puede avanzar para liberar el _mutex_, de modo que `H` queda esperando a
`M`, un hilo menos prioritario con el que ni siquiera comparte recursos. El caso más
conocido es el de la sonda Mars Pathfinder en 1997, cuyos reinicios periódicos se
debieron a una inversión de prioridad y se corrigieron activando la herencia de
prioridad.

POSIX define dos protocolos en los atributos del _mutex_. Con la **herencia de
prioridad** (`PTHREAD_PRIO_INHERIT`), mientras un hilo de mayor prioridad espera el
_mutex_, el propietario hereda temporalmente esa prioridad y `M` ya no puede expulsar a
`L`. Con el **techo de prioridad** (`PTHREAD_PRIO_PROTECT`), el propietario se ejecuta
con una prioridad techo fijada con `pthread_mutexattr_setprioceiling()`, que debe ser al
menos la mayor de los hilos que lo usan. La herencia se activa al crear el _mutex_:

```c linenums="1"
pthread_mutexattr_t attr;
pthread_mutex_t mutex;

pthread_mutexattr_init(&attr);
// El propietario hereda la prioridad del hilo que espera
pthread_mutexattr_setprotocol(&attr, PTHREAD_PRIO_INHERIT);
pthread_mutex_init(&mutex, &attr);
pthread_mutexattr_destroy(&attr);
```

`pthread_mutex_trylock()` ofrece otra vía para evitar el interbloqueo cuando se
necesitan varios _mutex_: si no consigue el segundo, el hilo puede liberar el primero y
reintentar más tarde, rompiendo la condición de retención y espera.

### Regiones críticas condicionales

Además de la exclusión mutua, una primitiva de sincronización debe expresar condiciones
de sincronización como las del productor-consumidor. Las **regiones críticas
condicionales** extienden las regiones críticas con una guarda booleana `B` que debe ser
cierta antes de ejecutar el cuerpo:

```plaintext linenums="1"
region (v) when (B) {
    S;
}
```

El hilo adquiere la exclusión mutua del recurso `v` o se bloquea en la cola de entrada.
Con la exclusión adquirida evalúa `B`. Si es cierta, ejecuta `S` y al terminar libera la
exclusión. Si es falsa, libera la exclusión, porque de lo contrario ningún otro hilo
podría cambiar el estado, y se bloquea en una cola asociada a `v` hasta que otro hilo
salga de una región sobre el mismo recurso. Con este constructor el _buffer_ acotado
queda casi como su especificación:

```plaintext linenums="1"
productor:   region (buf) when (elem < N) { buffer[i] = dato; i = (i+1) % N; elem++; }
consumidor:  region (buf) when (elem > 0) { dato = buffer[j]; j = (j+1) % N; elem--; }
```

Las regiones críticas condicionales también reciben críticas. Un hilo despertado no
tiene garantía de que su guarda sea ahora cierta, y debe reevaluarla y quizá volver a
bloquearse. Evaluar las guardas en nombre de los hilos que esperan no siempre es
posible, porque pueden depender de variables locales de esos hilos. Además, el código de
acceso al recurso sigue repartido por todos los hilos. Las variables de condición y los
monitores resuelven estos problemas.

## Variables de condición

POSIX implementa el patrón de las regiones críticas condicionales con las **variables de
condición** de tipo `pthread_cond_t`. Una variable de condición es una cola de hilos
suspendidos a la espera de que cambie un predicado sobre el estado compartido. Siempre
se usa junto a un _mutex_, que protege ese estado.

| Función                                   | Descripción                                                                                            |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| `pthread_cond_init(&c, &attr)`            | Inicializa la variable de condición. Con `attr` igual a `NULL` usa los atributos por defecto.          |
| `PTHREAD_COND_INITIALIZER`                | Inicializa estáticamente una variable de condición.                                                    |
| `pthread_cond_wait(&c, &m)`               | Libera `m` y suspende al hilo de forma atómica. Al despertar, vuelve a adquirir `m` antes de retornar. |
| `pthread_cond_timedwait(&c, &m, &limite)` | Igual que `wait`, pero retorna con `ETIMEDOUT` si se alcanza el instante absoluto `limite`.            |
| `pthread_cond_signal(&c)`                 | Despierta al menos a un hilo suspendido en `c`, si lo hay.                                             |
| `pthread_cond_broadcast(&c)`              | Despierta a todos los hilos suspendidos en `c`.                                                        |
| `pthread_cond_destroy(&c)`                | Destruye la variable de condición, que no debe tener hilos esperando.                                  |

### Protocolo de uso

El uso correcto sigue siempre el mismo esquema. El hilo adquiere el _mutex_ asociado y
comprueba el predicado bajo su protección. Si es falso, llama a `pthread_cond_wait()`,
que libera el _mutex_ y suspende al hilo en una sola operación atómica, de modo que
ningún aviso se pierde entre la comprobación y la suspensión. Otro hilo que modifica el
estado, con el _mutex_ tomado, llama a `signal` o `broadcast`. El hilo despertado vuelve
a adquirir el _mutex_ y **reevalúa el predicado**.

```plaintext linenums="1"
espera:                              aviso:
    lock(m);                             lock(m);
    while (!condicion)                   condicion = 1;
        cond_wait(&c, &m);               cond_signal(&c);
    // usa el estado protegido           unlock(m);
    unlock(m);
```

La reevaluación con `while` es indispensable. Entre el aviso y el momento en que el hilo
despertado recupera el _mutex_, otro hilo puede haber entrado y vuelto a hacer falso el
predicado. Además, POSIX permite **despertares espurios**: `cond_wait` puede retornar
sin que nadie haya llamado a `signal`. Con un `if`, el hilo continuaría con el predicado
falso.

### `signal` frente a `broadcast`

`signal` basta cuando cualquier hilo despertado puede aprovechar el cambio y solo uno
puede hacerlo, como un consumidor que espera un único dato nuevo. `broadcast` es
necesario cuando el cambio puede habilitar a varios hilos, o cuando en la misma variable
de condición esperan hilos con predicados distintos y no se sabe cuál de ellos puede
continuar. Un `signal` mal elegido es una fuente frecuente de bloqueos: despierta a un
hilo que no puede avanzar y vuelve a dormirse, mientras otro que sí podría hacerlo sigue
suspendido. El coste de `broadcast` es despertar hilos que volverán a bloquearse, lo
cual es ineficiente pero nunca incorrecto si las esperas usan `while`.

## Monitores

Las variables de condición resuelven la espera de un predicado, pero no la dispersión
del código. El **monitor**, definido por C. A. R. Hoare y Per Brinch Hansen a mediados
de los años 70, es una estructura de un lenguaje concurrente que encapsula un recurso
junto con todos los aspectos de su sincronización. Por definición, los procedimientos
públicos del monitor se ejecutan siempre en exclusión mutua, y el monitor proporciona
variables de condición para modelar las condiciones de sincronización. El programador
está obligado a manipular los datos compartidos a través del código del monitor, de modo
que no puede olvidar liberar la exclusión ni acceder al recurso por otro camino.

C no tiene monitores, pero se emulan con disciplina: una estructura agrupa el estado, un
_mutex_ y las variables de condición, y solo un conjunto de funciones la manipula. Cada
función empieza con `pthread_mutex_lock()` y termina con `pthread_mutex_unlock()` en
todos sus caminos de salida.

### Disciplinas de señalización

Cuando un hilo dentro del monitor hace `signal` y despierta a otro, solo uno de los dos
puede continuar dentro. La forma de resolverlo define la disciplina del monitor:

| Disciplina                        | Quién continúa tras `signal`                                                                                  | Consecuencia para la espera                                                |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| Hoare (_signal and urgent wait_)  | El hilo despertado entra de inmediato y el que señaliza espera en una cola prioritaria.                       | El predicado es cierto al despertar y basta un `if`.                       |
| Brinch Hansen (_signal and exit_) | `signal` debe ser la última operación del procedimiento, y el hilo despertado entra al salir el que señaliza. | El predicado es cierto al despertar, pero limita dónde se puede señalizar. |
| Mesa (_signal and continue_)      | El hilo que señaliza continúa, y el despertado pasa a competir por el _mutex_ con los demás.                  | El predicado puede haber cambiado y hay que reevaluarlo con `while`.       |

Las variables de condición de POSIX, igual que las de Java, siguen la disciplina Mesa, y
además admiten despertares espurios. Por eso todos los ejemplos de este capítulo esperan
dentro de un `while`. Algunos lenguajes, como Java con `wait()` y `notifyAll()`, ofrecen
una única cola de espera por monitor, de modo que un hilo despertado no puede suponer
que se cumple la condición por la que se suspendió. POSIX permite en cambio asociar
varias variables de condición a un mismo _mutex_, una por cada predicado, y despertar
solo a los hilos que esperan el cambio que se acaba de producir.

### Monitor en C: _buffer_ acotado

El _buffer_ acotado es el ejemplo canónico de monitor. La estructura `buffer_t`
encapsula los datos, los índices, el _mutex_ y dos variables de condición, una por cada
condición de sincronización. `meter()` espera mientras el _buffer_ esté lleno y avisa a
los consumidores, y `sacar()` es simétrica.

???+ example "_Buffer_ acotado como monitor"

    Dos productores insertan cada uno los enteros de 1 a 5000 y dos consumidores extraen
    5000 elementos cada uno. La suma total confirma que no se pierde ni se repite ningún
    dato.

    ```c linenums="1"
    #include <pthread.h>
    #include <stdio.h>

    #define TAM 10
    #define PARES 2
    #define DATOS 5000

    // Monitor: el estado y su sincronización viajan juntos
    typedef struct {
        pthread_mutex_t mutex;
        pthread_cond_t no_lleno;
        pthread_cond_t no_vacio;
        int cuenta, primero, ultimo;
        int datos[TAM];
    } buffer_t;

    static buffer_t buf = {
        .mutex = PTHREAD_MUTEX_INITIALIZER,
        .no_lleno = PTHREAD_COND_INITIALIZER,
        .no_vacio = PTHREAD_COND_INITIALIZER,
    };

    static void meter(buffer_t *b, int item)
    {
        pthread_mutex_lock(&b->mutex);
        // while y no if: la condición se reevalúa al despertar
        while (b->cuenta == TAM) {
            pthread_cond_wait(&b->no_lleno, &b->mutex);
        }
        b->datos[b->ultimo] = item;
        b->ultimo = (b->ultimo + 1) % TAM;
        b->cuenta++;
        pthread_cond_signal(&b->no_vacio);
        pthread_mutex_unlock(&b->mutex);
    }

    static int sacar(buffer_t *b)
    {
        pthread_mutex_lock(&b->mutex);
        while (b->cuenta == 0) {
            pthread_cond_wait(&b->no_vacio, &b->mutex);
        }
        int item = b->datos[b->primero];
        b->primero = (b->primero + 1) % TAM;
        b->cuenta--;
        pthread_cond_signal(&b->no_lleno);
        pthread_mutex_unlock(&b->mutex);
        return item;
    }

    static void *productor(void *arg)
    {
        (void)arg;
        for (int i = 1; i <= DATOS; i++) {
            meter(&buf, i);
        }
        return NULL;
    }

    static void *consumidor(void *arg)
    {
        long *suma = arg;
        for (int i = 0; i < DATOS; i++) {
            *suma += sacar(&buf);
        }
        return NULL;
    }

    int main(void)
    {
        pthread_t p[PARES], c[PARES];
        long suma[PARES] = {0};
        long total = 0;

        for (int i = 0; i < PARES; i++) {
            pthread_create(&p[i], NULL, productor, NULL);
            pthread_create(&c[i], NULL, consumidor, &suma[i]);
        }
        for (int i = 0; i < PARES; i++) {
            pthread_join(p[i], NULL);
            pthread_join(c[i], NULL);
            total += suma[i];
        }
        printf("total consumido = %ld\n", total);
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    total consumido = 25005000
    ```

### Lectores-escritores con monitor

En el problema de los **lectores-escritores**, dos tipos de hilos comparten una base de
datos. Los escritores la actualizan y deben acceder en exclusión mutua con cualquier
otro hilo, mientras que los lectores solo consultan y cualquier número de ellos puede
estar dentro a la vez. Resolverlo con semáforos exige varios contadores y semáforos
auxiliares, y con un monitor se lee directamente en las guardas. El estado son cuatro
contadores: lectores y escritores dentro, `nlec` y `nesc`, y lectores y escritores
esperando, `wlec` y `wesc`. Cada tipo de hilo espera en su propia variable de condición.

Esta versión da prioridad a los lectores. Un lector que entra despierta al siguiente
lector que espera, y así sucesivamente, lo que se denomina **despertar en cascada**. El
precio es que un flujo continuo de lectores puede dejar a los escritores esperando
indefinidamente, es decir, con inanición. Para dar prioridad a los escritores bastan dos
cambios locales: la guarda de `entra_lector()` pasa a ser `nesc > 0 || wesc > 0`, y
`sale_escritor()` despierta primero a un escritor si `wesc > 0`. La prioridad solo se
desplaza, porque ahora son los lectores los que pueden sufrir inanición.

???+ example "Lectores-escritores con prioridad para los lectores"

    Cada escritor incrementa por separado dos campos, y un lector que los viera
    distintos demostraría que ha coincidido con un escritor.

    ```c linenums="1"
    #include <pthread.h>
    #include <stdatomic.h>
    #include <stdio.h>

    #define LECTORES 6
    #define ESCRITORES 3
    #define VECES 20000

    static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
    static pthread_cond_t cond_lec = PTHREAD_COND_INITIALIZER;
    static pthread_cond_t cond_esc = PTHREAD_COND_INITIALIZER;
    // Lectores y escritores dentro, y lectores y escritores esperando
    static int nlec = 0, nesc = 0, wlec = 0, wesc = 0;

    static long campo_a = 0, campo_b = 0;
    static atomic_int inconsistencias;

    static void entra_lector(void)
    {
        pthread_mutex_lock(&mutex);
        while (nesc > 0) {
            wlec++;
            pthread_cond_wait(&cond_lec, &mutex);
            wlec--;
        }
        nlec++;
        // Despertar en cascada del siguiente lector que espera
        pthread_cond_signal(&cond_lec);
        pthread_mutex_unlock(&mutex);
    }

    static void sale_lector(void)
    {
        pthread_mutex_lock(&mutex);
        nlec--;
        if (nlec == 0) {
            pthread_cond_signal(&cond_esc);
        }
        pthread_mutex_unlock(&mutex);
    }

    static void entra_escritor(void)
    {
        pthread_mutex_lock(&mutex);
        while (nesc > 0 || nlec > 0) {
            wesc++;
            pthread_cond_wait(&cond_esc, &mutex);
            wesc--;
        }
        nesc++;
        pthread_mutex_unlock(&mutex);
    }

    static void sale_escritor(void)
    {
        pthread_mutex_lock(&mutex);
        nesc--;
        // Prioridad a los lectores que esperan
        if (wlec > 0) {
            pthread_cond_signal(&cond_lec);
        } else {
            pthread_cond_signal(&cond_esc);
        }
        pthread_mutex_unlock(&mutex);
    }

    static void *lector(void *arg)
    {
        (void)arg;
        for (int k = 0; k < VECES; k++) {
            entra_lector();
            // Un lector solo ve campos distintos si un escritor está dentro
            if (campo_a != campo_b) {
                atomic_fetch_add(&inconsistencias, 1);
            }
            sale_lector();
        }
        return NULL;
    }

    static void *escritor(void *arg)
    {
        (void)arg;
        for (int k = 0; k < VECES; k++) {
            entra_escritor();
            campo_a++;
            campo_b++;
            sale_escritor();
        }
        return NULL;
    }

    int main(void)
    {
        pthread_t l[LECTORES], e[ESCRITORES];

        for (int i = 0; i < LECTORES; i++) {
            pthread_create(&l[i], NULL, lector, NULL);
        }
        for (int i = 0; i < ESCRITORES; i++) {
            pthread_create(&e[i], NULL, escritor, NULL);
        }
        for (int i = 0; i < LECTORES; i++) {
            pthread_join(l[i], NULL);
        }
        for (int i = 0; i < ESCRITORES; i++) {
            pthread_join(e[i], NULL);
        }
        printf("escrituras = %ld, lecturas inconsistentes = %d\n", campo_a,
               atomic_load(&inconsistencias));
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    escrituras = 60000, lecturas inconsistentes = 0
    ```

El monitor retiene la exclusión solo mientras comprueba y actualiza el estado.
`pthread_cond_wait()` la libera durante cada espera. Un `sleep()` dentro de un
procedimiento del monitor, en cambio, bloquearía a todos los demás hilos durante ese
tiempo, por lo que el trabajo largo debe hacerse fuera del monitor.

## Comparativa de mecanismos

| Mecanismo                         | Bloqueo | Uso principal                                                       | Riesgo principal                                                           |
| --------------------------------- | ------- | ------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| Espera activa (Peterson, Lamport) | Activo  | Comprender el problema y construir _mutex_ sin soporte del sistema. | Consumo de CPU y dependencia del modelo de memoria.                        |
| _Spinlock_                        | Activo  | Secciones críticas muy cortas en multiprocesadores.                 | Desperdicio de CPU si el _spinlock_ se retiene mucho tiempo.               |
| Semáforo                          | Pasivo  | Exclusión mutua, recursos con varias unidades, avisos y barreras.   | Errores de orden de `wait` y `post` difíciles de detectar.                 |
| _Mutex_                           | Pasivo  | Regiones críticas con propietario.                                  | Interbloqueo por orden de adquisición e inversión de prioridad.            |
| Variable de condición             | Pasivo  | Esperar un predicado sobre el estado protegido por un _mutex_.      | Usar `if` en lugar de `while` o un `signal` donde hacía falta `broadcast`. |
| Monitor                           | Pasivo  | Encapsular un recurso con toda su sincronización.                   | Ejecutar trabajo largo dentro del monitor.                                 |

## Cierre

Todos estos mecanismos suponen que los hilos comparten un espacio de memoria. Cuando no
lo comparten, o cuando se prefiere evitar el estado compartido, la comunicación se basa
en el intercambio de mensajes y en la reacción a eventos, que se tratan en el capítulo
de [paso de mensajes y eventos](section_3_message_passing_events.md).
