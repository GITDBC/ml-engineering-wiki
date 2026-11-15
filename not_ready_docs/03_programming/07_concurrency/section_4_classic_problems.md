---
icon: lucide/puzzle
authors: Daniel Bazo Correa
description:
    Método para plantear problemas de sincronización y su aplicación a los problemas
    clásicos, con el productor-consumidor con varios hilos, los lectores-escritores
    justos, la cena de filósofos, un _pipeline_ de procesos con paso de mensajes y la
    sincronización mediante señales POSIX.
title: Problemas clásicos de sincronización
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Este capítulo aplica los mecanismos de los capítulos anteriores a los problemas de
sincronización que más se repiten en el software real. Parte de un método para plantear
cualquier problema y recorre el productor-consumidor, los lectores-escritores y la cena
de filósofos, para terminar con un _pipeline_ de mensajes y un ejemplo de sincronización
con señales. Las versiones básicas de estos problemas ya están resueltas en
[memoria compartida](section_2_shared_memory.md) y en
[paso de mensajes y eventos](section_3_message_passing_events.md), de modo que aquí solo
se amplía lo que falta: variantes con varios hilos, justicia y razonamiento sobre
invariantes. La base teórica está en [fundamentos](section_1_fundamentals.md).

## Cómo plantear un problema de sincronización

Resolver un problema de sincronización por prueba y error es especialmente engañoso,
porque un programa incorrecto puede funcionar miles de veces. Conviene seguir siempre la
misma secuencia. Un **invariante** es la fórmula sobre el estado compartido que debe
cumplirse siempre, y una **condición de espera** es el predicado que habilita una acción
bloqueante.

- **Entidades**: Se identifican las activas (hilos o procesos) y las pasivas (recursos y
  _buffers_). De las pasivas interesa solo lo que cambia con el tiempo.
- **Estado compartido**: Se elige el estado mínimo que permite decidir quién avanza.
  Casi siempre son contadores (cuántos hay dentro, cuántos esperan, cuántos huecos
  quedan) y banderas, y casi nunca listas de hilos.
- **Invariante**: Se escribe como fórmula la propiedad que nunca debe violarse, por
  ejemplo $0 \leq \text{cuenta} \leq N$. Es la propiedad de seguridad del problema.
- **Condiciones de espera**: Cada acción bloqueable recibe un predicado sobre el estado
  que debe ser cierto para ejecutarla. Todo cambio de estado que pueda hacerlo cierto
  debe avisar a quien espera.
- **Mecanismo**: Se elige la herramienta que expresa el predicado de la forma más
  directa.
- **Vivacidad**: Se comprueba que no hay inanición y, si el problema lo exige, qué orden
  de atención garantiza la propia solución (su justicia, que no depende de la del
  planificador). La ausencia de interbloqueo también se comprueba, pero es una propiedad
  de seguridad.

La tabla resume la elección del mecanismo. Un mismo problema admite varias soluciones, y
la que usa la primitiva más cercana al predicado suele ser la más corta y la más fácil
de razonar.

| Naturaleza de la condición                       | Mecanismo natural                  | Ejemplo en el capítulo                          |
| ------------------------------------------------ | ---------------------------------- | ----------------------------------------------- |
| Exclusión sobre un dato                          | _Mutex_ o semáforo binario         | Oráculo de exclusión mutua                      |
| Contar unidades de un recurso                    | Semáforo general                   | Huecos del _buffer_                             |
| Evento puntual de un hilo hacia otro             | Semáforo inicializado a 0          | Órdenes del productor-consumidor con señales    |
| Predicado sobre varias variables de estado       | Monitor con variables de condición | Lectores-escritores justo, filósofos con rondas |
| Varios recursos a la vez                         | Orden global de adquisición        | Filósofos con orden de tenedores                |
| Intercambio de datos sin memoria compartida      | Colas de mensajes                  | _Pipeline_ de ordenación                        |
| Notificación asíncrona desde otro proceso o hilo | Señales POSIX en tiempo real       | Productor-consumidor con señales                |

Un patrón se reutiliza en casi todos los problemas: el **predicado de entrada**. Una
función `puede(c)` evalúa, con el _mutex_ tomado, si un hilo de clase `c` puede entrar.
Se invoca dentro de un `while`, de modo que un hilo que despierta sin poder avanzar
vuelve a dormirse. Las políticas de justicia o de prioridad se añaden como conjunciones
en ese predicado, sin tocar el resto del código.

### Comprobar el invariante dentro del programa

Que un programa termine no demuestra que la solución sea correcta. Siempre que es
posible, el ejemplo incluye un **oráculo**, un contador atómico independiente del
mecanismo probado que mide si el invariante se viola. Una variable `dentro` cuenta
cuántos hilos hay en la región protegida, otra cuenta las violaciones y una pausa breve
dentro de la región hace probable el solapamiento cuando falta protección.

???+ example "Oráculo de exclusión mutua"

    El programa ejecuta la misma sección crítica con y sin _mutex_. Con el _mutex_ el
    contador de violaciones debe ser cero, y sin él el solapamiento debe detectarse.

    ```c linenums="1"
    #include <pthread.h>
    #include <stdatomic.h>
    #include <stdio.h>
    #include <unistd.h>

    #define HILOS 4
    #define ITERACIONES 200

    static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
    // Oráculo: cuántos hilos hay dentro de la región y cuántas veces hubo más de una
    static atomic_int dentro, violaciones;

    static void region(void)
    {
        if (atomic_fetch_add(&dentro, 1) != 0) {
            atomic_fetch_add(&violaciones, 1);
        }
        // La pausa hace que un solapamiento sea casi seguro si falta protección
        usleep(20);
        atomic_fetch_sub(&dentro, 1);
    }

    static void *protegida(void *arg)
    {
        (void)arg;
        for (int i = 0; i < ITERACIONES; i++) {
            pthread_mutex_lock(&mutex);
            region();
            pthread_mutex_unlock(&mutex);
        }
        return NULL;
    }

    static void *desprotegida(void *arg)
    {
        (void)arg;
        for (int i = 0; i < ITERACIONES; i++) {
            region();
        }
        return NULL;
    }

    // Lanza los hilos con el cuerpo indicado y devuelve las violaciones medidas
    static int probar(void *(*cuerpo)(void *))
    {
        pthread_t th[HILOS];

        atomic_store(&violaciones, 0);
        for (int i = 0; i < HILOS; i++) {
            pthread_create(&th[i], NULL, cuerpo, NULL);
        }
        for (int i = 0; i < HILOS; i++) {
            pthread_join(th[i], NULL);
        }
        return atomic_load(&violaciones);
    }

    int main(void)
    {
        printf("con mutex, violaciones: %d\n", probar(protegida));
        printf("sin mutex, se detectó el solapamiento: %s\n",
               probar(desprotegida) > 0 ? "sí" : "no");
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    con mutex, violaciones: 0
    sin mutex, se detectó el solapamiento: sí
    ```

La segunda línea depende de que el planificador solape los hilos. Con la pausa de 20
microsegundos se cumplió en todas las ejecuciones realizadas. Una prueba así no
demuestra la corrección, pero convierte la ausencia de fallos en una medida. Además
permite una comprobación por mutación: si al quitar una operación de sincronización el
oráculo no detecta ningún error, la prueba no es sensible a lo que pretende evitar.

Todos los programas del capítulo se compilan con
`gcc -Wall -Wextra -pthread programa.c -o programa` y los hilos terminan tras un número
fijo de iteraciones, para que el programa acabe y pueda medirse. Las salidas mostradas
son resultados deterministas o invariantes comprobados.

## Productor-consumidor

El **productor-consumidor** coordina hilos que depositan elementos en un _buffer_
circular de $N$ posiciones con otros que los retiran. El estado compartido es el
_array_, los índices de entrada y salida y el número de elementos presentes. Las
propiedades son las siguientes.

- **Invariante**: $0 \leq \text{cuenta} \leq N$.
- **Integridad**: Cada elemento producido se consume exactamente una vez.
- **Orden**: Los elementos se extraen en el orden en que se insertaron.
- **Condiciones de espera**: Un productor espera con el _buffer_ lleno y un consumidor
  con el _buffer_ vacío.

El caso con un productor y un consumidor está resuelto con semáforos en
[memoria compartida](section_2_shared_memory.md), donde también aparece un monitor con
varios hilos de cada clase, y con una cola de mensajes POSIX en
[paso de mensajes y eventos](section_3_message_passing_events.md). La variante que exige
revisar qué estado es realmente compartido es la de varios hilos de cada clase con
semáforos.

### Varios productores y consumidores

Con un solo productor y un solo consumidor, los índices de entrada y de salida pueden
ser variables locales de cada hilo. Con varios productores, dos de ellos pueden usar el
mismo índice y sobrescribirse, de modo que los índices pasan a ser estado compartido y
los protege el semáforo `mutex`. Los semáforos de contar siguen expresando las
condiciones de espera.

???+ example "_Buffer_ acotado con tres productores y dos consumidores"

    Cada productor genera 2000 valores únicos y un _array_ de contadores comprueba al
    final que cada uno de los 6000 valores se consumió una vez. El orden de los `wait`
    es siempre primero el semáforo de contar y después el `mutex`.

    ```c linenums="1"
    #include <pthread.h>
    #include <semaphore.h>
    #include <stdatomic.h>
    #include <stdio.h>

    #define TAM 8
    #define PRODUCTORES 3
    #define CONSUMIDORES 2
    #define POR_PRODUCTOR 2000
    #define TOTAL (PRODUCTORES * POR_PRODUCTOR)

    // Huecos libres, elementos disponibles y exclusión sobre el estado
    static sem_t hay_espacio, hay_datos, mutex;
    // Los índices son compartidos: con varios productores no pueden ser locales
    static int buffer[TAM], entra = 0, sale = 0;
    static int ocupados = 0, max_ocupados = 0;
    static atomic_int vistos[TOTAL];

    static void poner(int dato)
    {
        sem_wait(&hay_espacio);
        sem_wait(&mutex);
        buffer[entra] = dato;
        entra = (entra + 1) % TAM;
        ocupados++;
        if (ocupados > max_ocupados) {
            max_ocupados = ocupados;
        }
        sem_post(&mutex);
        sem_post(&hay_datos);
    }

    static int sacar(void)
    {
        sem_wait(&hay_datos);
        sem_wait(&mutex);
        int dato = buffer[sale];
        sale = (sale + 1) % TAM;
        ocupados--;
        sem_post(&mutex);
        sem_post(&hay_espacio);
        return dato;
    }

    static void *productor(void *arg)
    {
        int id = *(int *)arg;

        for (int i = 0; i < POR_PRODUCTOR; i++) {
            poner(id * POR_PRODUCTOR + i);
        }
        return NULL;
    }

    static void *consumidor(void *arg)
    {
        (void)arg;
        for (int i = 0; i < TOTAL / CONSUMIDORES; i++) {
            atomic_fetch_add(&vistos[sacar()], 1);
        }
        return NULL;
    }

    int main(void)
    {
        pthread_t p[PRODUCTORES], c[CONSUMIDORES];
        int ids[PRODUCTORES], mal = 0;

        sem_init(&hay_espacio, 0, TAM);
        sem_init(&hay_datos, 0, 0);
        sem_init(&mutex, 0, 1);
        for (int i = 0; i < PRODUCTORES; i++) {
            ids[i] = i;
            pthread_create(&p[i], NULL, productor, &ids[i]);
        }
        for (int i = 0; i < CONSUMIDORES; i++) {
            pthread_create(&c[i], NULL, consumidor, NULL);
        }
        for (int i = 0; i < PRODUCTORES; i++) {
            pthread_join(p[i], NULL);
        }
        for (int i = 0; i < CONSUMIDORES; i++) {
            pthread_join(c[i], NULL);
        }
        for (int v = 0; v < TOTAL; v++) {
            mal += atomic_load(&vistos[v]) != 1;
        }
        printf("valores consumidos una sola vez: %d de %d\n", TOTAL - mal, TOTAL);
        printf("ocupación máxima dentro de 0..%d: %s\n", TAM,
               max_ocupados <= TAM ? "sí" : "no");
        printf("elementos que quedan: %d\n", ocupados);
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    valores consumidos una sola vez: 6000 de 6000
    ocupación máxima dentro de 0..8: sí
    elementos que quedan: 0
    ```

!!! warning "Índices locales y orden de los `wait`"

    El error típico es dejar `entra` y `sale` como variables locales, correctas con un
    solo productor. El síntoma es la pérdida o duplicación de elementos, que el
    contador de integridad detecta, y no un fallo inmediato. El otro error clásico es
    tomar el `mutex` antes que el semáforo de contar, lo que produce interbloqueo
    cuando el _buffer_ está lleno o vacío, porque quien espera retiene el `mutex` que
    necesita el otro lado.

## Lectores-escritores

Los **lectores-escritores** comparten una estructura de datos. Los escritores la
modifican y necesitan exclusión total, mientras que los lectores solo la consultan y
cualquier número de ellos puede estar dentro a la vez. Es el patrón de una caché, una
tabla de configuración o un índice en memoria que se lee mucho y se actualiza poco. El
invariante, con $n_e$ escritores y $n_l$ lectores dentro, es

$$
n_e \leq 1 \quad \land \quad (n_e > 0 \Rightarrow n_l = 0)
$$

La seguridad es sencilla de obtener. La dificultad está en la vivacidad, porque la
política de entrada decide quién puede sufrir inanición. En
[memoria compartida](section_2_shared_memory.md) se resuelve con un monitor que da
prioridad a los lectores, con lo que un flujo continuo de lectores deja a los escritores
esperando indefinidamente. Dar prioridad a los escritores traslada la inanición a los
lectores.

### Una versión justa con turnos

La solución simétrica es atender en orden de llegada. Cada hilo recibe un número al
llegar y solo puede entrar cuando le toca y se cumple la condición de su clase. El
predicado de entrada es una conjunción, y la justicia es un término más de ella.

- **Lector**: Entra si es su turno y no hay un escritor dentro.
- **Escritor**: Entra si es su turno y no hay nadie dentro.

Al entrar, cualquiera avanza el turno de inmediato. Así, los lectores consecutivos en la
cola entran juntos, mientras que un escritor detiene a los que llegaron después hasta
que sale. Ningún lado puede adelantarse al otro, por lo que no hay inanición.

???+ example "Lectores-escritores justo con un monitor de turnos"

    Cada escritor incrementa dos campos por separado y un lector que los viera distintos
    habría coincidido con un escritor. Todas las esperas usan una única variable de
    condición con `broadcast`, porque cada hilo reevalúa su propio predicado.

    ```c linenums="1"
    #include <pthread.h>
    #include <stdatomic.h>
    #include <stdio.h>

    #define LECTORES 6
    #define ESCRITORES 3
    #define VECES 2000

    static pthread_mutex_t m = PTHREAD_MUTEX_INITIALIZER;
    static pthread_cond_t cambio = PTHREAD_COND_INITIALIZER;
    // Número que se entrega al llegar y número al que le toca entrar
    static int siguiente = 0, turno = 0;
    // Lectores dentro y escritor dentro (0 o 1)
    static int nlec = 0, nesc = 0;

    static void entra_lector(void)
    {
        pthread_mutex_lock(&m);
        int mio = siguiente++;
        // Espera su turno y que no haya un escritor dentro
        while (mio != turno || nesc > 0) {
            pthread_cond_wait(&cambio, &m);
        }
        nlec++;
        // Cede el turno enseguida para que los lectores contiguos entren juntos
        turno++;
        pthread_cond_broadcast(&cambio);
        pthread_mutex_unlock(&m);
    }

    static void sale_lector(void)
    {
        pthread_mutex_lock(&m);
        nlec--;
        pthread_cond_broadcast(&cambio);
        pthread_mutex_unlock(&m);
    }

    static void entra_escritor(void)
    {
        pthread_mutex_lock(&m);
        int mio = siguiente++;
        while (mio != turno || nesc > 0 || nlec > 0) {
            pthread_cond_wait(&cambio, &m);
        }
        nesc++;
        turno++;
        pthread_mutex_unlock(&m);
    }

    static void sale_escritor(void)
    {
        pthread_mutex_lock(&m);
        nesc--;
        pthread_cond_broadcast(&cambio);
        pthread_mutex_unlock(&m);
    }

    static long campo_a = 0, campo_b = 0;
    static atomic_int inconsistencias;

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
    escrituras = 6000, lecturas inconsistentes = 0
    ```

El precio de la justicia es la concurrencia. Un lector que llega detrás de un escritor
espera aunque otros lectores estén leyendo en ese momento. En la práctica, las
bibliotecas ofrecen el bloqueo de lectura-escritura de POSIX (`pthread_rwlock_t`), que
implementa una política fija, y esta solución sirve para entender qué garantiza cada
política.

## Cena de filósofos

Cinco filósofos alternan entre pensar y comer alrededor de una mesa redonda. Entre cada
par de platos hay un tenedor y cada filósofo necesita los dos adyacentes para comer. Es
el modelo de un hilo que necesita adquirir **varios** _mutex_ a la vez. Si todos toman
primero el tenedor izquierdo, los cinco quedan esperando el que retiene su vecino, y el
sistema se bloquea por espera circular. Para que ocurra un interbloqueo deben darse a la
vez las cuatro condiciones de Coffman: exclusión mutua, retención mientras se espera,
recursos que no se pueden arrebatar y cadena circular de esperas. Basta con romper una.

La solución con un semáforo de $N - 1$ sillas, que rompe la espera circular al limitar
cuántos filósofos compiten, está en [memoria compartida](section_2_shared_memory.md).
Las dos siguientes atacan el problema desde otro ángulo.

### Orden global de adquisición

Si todos los hilos adquieren los recursos en el mismo orden global, no puede formarse un
ciclo de esperas. Basta con que cada filósofo tome siempre primero el tenedor de menor
índice. El único que cambia respecto del intento ingenuo es el último, que toma el
tenedor 0 antes que el 4. Es la técnica general para evitar interbloqueos con varios
_mutex_ en el código real.

???+ example "Filósofos con orden global de tenedores"

    Cada filósofo come 10 000 veces con un _mutex_ por tenedor. Con el orden ingenuo
    (izquierdo y luego derecho) y una pausa breve entre las dos tomas, el programa se
    bloqueó en las cinco ejecuciones de prueba y hubo que interrumpirlo con `timeout`.

    ```c linenums="1"
    #include <pthread.h>
    #include <stdio.h>

    #define N 5
    #define COMIDAS 10000

    static pthread_mutex_t tenedor[N] = {
        PTHREAD_MUTEX_INITIALIZER, PTHREAD_MUTEX_INITIALIZER, PTHREAD_MUTEX_INITIALIZER,
        PTHREAD_MUTEX_INITIALIZER, PTHREAD_MUTEX_INITIALIZER};
    static int comidas[N];

    static void *filosofo(void *arg)
    {
        int id = *(int *)arg;
        int izq = id, der = (id + 1) % N;
        // Orden global: siempre se toma primero el tenedor de menor índice
        int primero = izq < der ? izq : der;
        int segundo = izq < der ? der : izq;

        for (int k = 0; k < COMIDAS; k++) {
            pthread_mutex_lock(&tenedor[primero]);
            pthread_mutex_lock(&tenedor[segundo]);
            comidas[id]++;
            pthread_mutex_unlock(&tenedor[segundo]);
            pthread_mutex_unlock(&tenedor[primero]);
        }
        return NULL;
    }

    int main(void)
    {
        pthread_t th[N];
        int ids[N], total = 0;

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

### Adyacencia y justicia con monitor

Un monitor permite modelar el problema sin un objeto por tenedor. Se asocia a cada
filósofo un estado (_pensando_, _hambriento_ o _comiendo_) y se exige que ninguno de sus
vecinos esté comiendo. Con solo esta condición un filósofo puede sufrir inanición si sus
dos vecinos comen alternativamente. Se añade entonces una **ronda**: un filósofo no
vuelve a comer hasta que todos hayan comido una vez en la ronda actual. El predicado de
entrada es

$$
\text{puede}(i) = \lnot\,\text{comiendo}(i-1) \land \lnot\,\text{comiendo}(i+1) \land
\lnot\,\text{ya\_comio}(i)
$$

???+ example "Filósofos con monitor, adyacencia y rondas"

    Cinco filósofos comen 200 veces. Un oráculo externo comprueba que dos vecinos no
    comen a la vez y el monitor comprueba que nadie lleva más de una comida de ventaja.

    ```c linenums="1"
    #include <pthread.h>
    #include <stdatomic.h>
    #include <stdio.h>
    #include <unistd.h>

    #define N 5
    #define COMIDAS 200

    enum { PENSANDO, HAMBRIENTO, COMIENDO };

    static pthread_mutex_t m = PTHREAD_MUTEX_INITIALIZER;
    static pthread_cond_t puede_comer[N];
    static int estado[N], comidas[N], ya_comio[N], comidos_en_ronda;
    static atomic_int comiendo_ahora[N];
    static atomic_int vecinos_a_la_vez, desequilibrios;

    static int izq(int i)
    {
        return (i + N - 1) % N;
    }

    static int der(int i)
    {
        return (i + 1) % N;
    }

    // Come si ningún vecino come y no ha comido ya en la ronda actual
    static int puede(int i)
    {
        return estado[izq(i)] != COMIENDO && estado[der(i)] != COMIENDO && !ya_comio[i];
    }

    static void coger_tenedores(int i)
    {
        pthread_mutex_lock(&m);
        estado[i] = HAMBRIENTO;
        while (!puede(i)) {
            pthread_cond_wait(&puede_comer[i], &m);
        }
        estado[i] = COMIENDO;
        ya_comio[i] = 1;
        comidas[i]++;
        // Invariante de justicia: nadie lleva más de una comida de ventaja
        for (int j = 0; j < N; j++) {
            if (comidas[i] - comidas[j] > 1) {
                atomic_fetch_add(&desequilibrios, 1);
            }
        }
        // Al comer todos una vez se abre una ronda nueva
        if (++comidos_en_ronda == N) {
            comidos_en_ronda = 0;
            for (int j = 0; j < N; j++) {
                ya_comio[j] = 0;
                pthread_cond_broadcast(&puede_comer[j]);
            }
        }
        pthread_mutex_unlock(&m);
    }

    static void soltar_tenedores(int i)
    {
        pthread_mutex_lock(&m);
        estado[i] = PENSANDO;
        // Los vecinos pueden haber quedado habilitados
        pthread_cond_signal(&puede_comer[izq(i)]);
        pthread_cond_signal(&puede_comer[der(i)]);
        pthread_mutex_unlock(&m);
    }

    static void *filosofo(void *arg)
    {
        int i = *(int *)arg;

        for (int k = 0; k < COMIDAS; k++) {
            coger_tenedores(i);
            atomic_store(&comiendo_ahora[i], 1);
            // Dos vecinos comiendo a la vez compartirían un tenedor
            if (atomic_load(&comiendo_ahora[izq(i)]) ||
                atomic_load(&comiendo_ahora[der(i)])) {
                atomic_fetch_add(&vecinos_a_la_vez, 1);
            }
            usleep(50);
            atomic_store(&comiendo_ahora[i], 0);
            soltar_tenedores(i);
        }
        return NULL;
    }

    int main(void)
    {
        pthread_t th[N];
        int ids[N], total = 0;

        for (int i = 0; i < N; i++) {
            pthread_cond_init(&puede_comer[i], NULL);
        }
        for (int i = 0; i < N; i++) {
            ids[i] = i;
            pthread_create(&th[i], NULL, filosofo, &ids[i]);
        }
        for (int i = 0; i < N; i++) {
            pthread_join(th[i], NULL);
            total += comidas[i];
        }
        printf("comidas totales: %d de %d\n", total, N * COMIDAS);
        printf("vecinos comiendo a la vez: %d\n", atomic_load(&vecinos_a_la_vez));
        printf("rondas desequilibradas: %d\n", atomic_load(&desequilibrios));
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    comidas totales: 1000 de 1000
    vecinos comiendo a la vez: 0
    rondas desequilibradas: 0
    ```

La ronda garantiza que la diferencia de comidas entre dos filósofos nunca supera una, lo
que evita la inanición. No hay interbloqueo porque, en cada ronda, al menos un filósofo
que aún no ha comido puede hacerlo. El precio es la pérdida de paralelismo, ya que
dentro de una ronda un filósofo que ya comió espera aunque sus vecinos estén libres.

!!! warning "Inicializar todas las condiciones antes de crear los hilos"

    Con un _array_ de variables de condición es fácil inicializar cada una en el mismo
    bucle que crea los hilos. El hilo 0 puede usar entonces la condición de un vecino
    antes de que se inicialice. Todas las inicializaciones deben completarse antes de
    crear el primer hilo.

## Paso de mensajes en una red de procesos

Cuando los procesos no comparten memoria, la sincronización se reduce a enviar y
recibir, sin semáforos ni _mutex_. Un **_pipeline_** es la red más sencilla: una cadena
de etapas en la que cada una recibe de la anterior, procesa y reenvía a la siguiente.
Mientras una etapa trabaja, la siguiente recibe, por lo que las etapas solapan su
ejecución. Es el mismo esquema de los filtros encadenados con tuberías del _shell_ o de
las etapas de preprocesado de datos en un sistema de ML.

El ejemplo es una ordenación por selección distribuida. Un generador envía $N$ números a
una cadena de $N$ etapas. La etapa $i$ recibe $N - i$ números, de modo que sabe cuándo
ha terminado. Se queda con el menor y reenvía el resto, y al final guarda el $i$-ésimo
menor. Cada buzón es una cola de mensajes POSIX de capacidad uno, de las descritas en
[paso de mensajes y eventos](section_3_message_passing_events.md), por lo que un envío
se bloquea mientras la etapa siguiente no retire el mensaje anterior y el sistema avanza
al ritmo de la etapa más lenta. Por sencillez las etapas son hilos, pero solo
intercambian datos mediante las colas.

???+ example "Ordenación con un _pipeline_ de colas de mensajes"

    Cada etapa guarda su resultado en una posición propia del _array_ `ordenado` y el
    programa lo imprime al final, porque el orden de impresión desde los hilos no
    estaría garantizado.

    ```c linenums="1"
    #include <fcntl.h>
    #include <mqueue.h>
    #include <pthread.h>
    #include <stdio.h>
    #include <stdlib.h>
    #include <sys/stat.h>

    #define N 8

    // entrada[i] es el buzón de la etapa i, con capacidad para un único entero
    static mqd_t entrada[N];
    static const int datos[N] = {42, 17, 93, 8, 65, 30, 71, 2};
    static int ordenado[N];

    static void enviar(mqd_t cola, int valor)
    {
        if (mq_send(cola, (const char *)&valor, sizeof valor, 0) == -1) {
            perror("mq_send");
            exit(EXIT_FAILURE);
        }
    }

    static int recibir(mqd_t cola)
    {
        int valor;

        if (mq_receive(cola, (char *)&valor, sizeof valor, NULL) == -1) {
            perror("mq_receive");
            exit(EXIT_FAILURE);
        }
        return valor;
    }

    // La etapa i recibe N - i números, se queda con el menor y reenvía el resto
    static void *etapa(void *arg)
    {
        int id = *(int *)arg;
        int menor = recibir(entrada[id]);

        for (int k = 1; k < N - id; k++) {
            int x = recibir(entrada[id]);

            if (x < menor) {
                int t = x;
                x = menor;
                menor = t;
            }
            enviar(entrada[id + 1], x);
        }
        ordenado[id] = menor;
        return NULL;
    }

    static void *generador(void *arg)
    {
        (void)arg;
        for (int k = 0; k < N; k++) {
            enviar(entrada[0], datos[k]);
        }
        return NULL;
    }

    int main(void)
    {
        pthread_t gen, th[N];
        int ids[N];
        struct mq_attr attr = {.mq_maxmsg = 1, .mq_msgsize = sizeof(int)};
        char nombre[32];

        for (int i = 0; i < N; i++) {
            snprintf(nombre, sizeof nombre, "/pipeline%d", i);
            // Si una ejecución anterior dejó la cola, se descarta
            mq_unlink(nombre);
            entrada[i] = mq_open(nombre, O_RDWR | O_CREAT, 0600, &attr);
            if (entrada[i] == (mqd_t)-1) {
                perror(nombre);
                return EXIT_FAILURE;
            }
        }
        pthread_create(&gen, NULL, generador, NULL);
        for (int i = 0; i < N; i++) {
            ids[i] = i;
            pthread_create(&th[i], NULL, etapa, &ids[i]);
        }
        pthread_join(gen, NULL);
        for (int i = 0; i < N; i++) {
            pthread_join(th[i], NULL);
        }
        printf("valores guardados por las etapas 0 a %d:", N - 1);
        for (int i = 0; i < N; i++) {
            printf(" %d", ordenado[i]);
        }
        printf("\n");
        // El nombre de una cola persiste en el sistema, así que se elimina
        for (int i = 0; i < N; i++) {
            snprintf(nombre, sizeof nombre, "/pipeline%d", i);
            mq_close(entrada[i]);
            mq_unlink(nombre);
        }
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    valores guardados por las etapas 0 a 7: 2 8 17 30 42 65 71 93
    ```

!!! warning "Las colas con nombre persisten"

    El nombre de una cola POSIX sigue existiendo en el sistema aunque el proceso
    termine. Por eso el ejemplo hace `mq_unlink()` al empezar y al terminar. Si no, una
    ejecución interrumpida deja colas con una capacidad o un tamaño de mensaje antiguos.
    En versiones antiguas de glibc la compilación necesita además `-lrt`.

## Señales como sincronización

Las señales POSIX de tiempo real permiten que otro proceso habilite operaciones de un
programa. Un hilo se encarga de recibirlas con `sigwaitinfo()` y traduce cada señal en
una acción sobre el estado, sin manejadores asíncronos, como se describe en
[paso de mensajes y eventos](section_3_message_passing_events.md). Hay tres requisitos.
Las señales se bloquean con `pthread_sigmask()` **antes** de crear hilos o de hacer
`fork()`, para que todos hereden la máscara y solo las reciba el hilo que espera. Se
usan señales de tiempo real (`SIGRTMIN` en adelante), que se encolan, y no `SIGUSR1` o
`SIGUSR2`, que no se acumulan. Y la espera con `sigwaitinfo()` se reintenta si falla con
`EINTR`.

El ejemplo es un productor-consumidor en el que cada señal habilita exactamente una
operación. El hilo receptor convierte cada señal en un `sem_post` sobre el semáforo de
órdenes correspondiente. El productor y el consumidor esperan primero la orden y después
el semáforo del _buffer_. Como hay un solo hilo de cada clase, los índices pueden ser
locales. Un proceso hijo creado con `fork()` envía las órdenes con retardos aleatorios.

???+ example "Productor-consumidor con señales y semáforos"

    El generador envía 200 órdenes de producir y 200 de consumir en orden aleatorio. El
    _buffer_ de cuatro posiciones es FIFO (el primero en entrar es el primero en salir)
    y el programa cuenta los elementos que salen fuera de orden.

    ```c linenums="1"
    #include <errno.h>
    #include <pthread.h>
    #include <semaphore.h>
    #include <signal.h>
    #include <stdio.h>
    #include <stdlib.h>
    #include <sys/wait.h>
    #include <unistd.h>

    #define TAM 4
    #define OPERACIONES 200
    #define PRODUCIR SIGRTMIN
    #define CONSUMIR (SIGRTMIN + 1)

    static sigset_t conjunto;
    static int buffer[TAM];
    // Una señal habilita una operación y los semáforos controlan el buffer
    static sem_t orden_producir, orden_consumir, hay_espacio, hay_datos;
    static int fuera_de_orden = 0;

    // sigwaitinfo puede fallar con EINTR si lo interrumpe un manejador de otra señal,
    // sin que haya llegado ninguna de las esperadas. Se reintenta hasta recibir una
    static int esperar_senal(siginfo_t *info)
    {
        while (sigwaitinfo(&conjunto, info) == -1) {
            if (errno != EINTR) {
                perror("sigwaitinfo");
                exit(EXIT_FAILURE);
            }
        }
        return info->si_signo;
    }

    // Convierte cada señal en un permiso de operación
    static void *receptor(void *arg)
    {
        siginfo_t info;

        (void)arg;
        for (int i = 0; i < 2 * OPERACIONES; i++) {
            int senal = esperar_senal(&info);

            sem_post(senal == PRODUCIR ? &orden_producir : &orden_consumir);
        }
        return NULL;
    }

    static void *productor(void *arg)
    {
        (void)arg;
        for (int k = 0, entra = 0; k < OPERACIONES; k++) {
            sem_wait(&orden_producir);
            sem_wait(&hay_espacio);
            buffer[entra] = k;
            entra = (entra + 1) % TAM;
            sem_post(&hay_datos);
        }
        return NULL;
    }

    static void *consumidor(void *arg)
    {
        (void)arg;
        for (int k = 0, sale = 0; k < OPERACIONES; k++) {
            sem_wait(&orden_consumir);
            sem_wait(&hay_datos);
            // El buffer es FIFO: los datos deben salir en el orden en que entraron
            fuera_de_orden += buffer[sale] != k;
            sale = (sale + 1) % TAM;
            sem_post(&hay_espacio);
        }
        return NULL;
    }

    // Proceso generador: envía las órdenes con retardos aleatorios y termina
    static void generador(pid_t destino)
    {
        int producir = OPERACIONES, consumir = OPERACIONES;

        srand(getpid());
        while (producir + consumir > 0) {
            // Elige al azar entre las órdenes que faltan por enviar
            if (rand() % (producir + consumir) < producir) {
                sigqueue(destino, PRODUCIR, (union sigval){0});
                producir--;
            } else {
                sigqueue(destino, CONSUMIR, (union sigval){0});
                consumir--;
            }
            usleep(rand() % 200);
        }
        _exit(0);
    }

    int main(void)
    {
        pthread_t r, p, c;
        pid_t hijo;

        sigemptyset(&conjunto);
        sigaddset(&conjunto, PRODUCIR);
        sigaddset(&conjunto, CONSUMIR);
        // El bloqueo debe hacerse antes de crear hilos y de hacer fork
        pthread_sigmask(SIG_BLOCK, &conjunto, NULL);
        sem_init(&orden_producir, 0, 0);
        sem_init(&orden_consumir, 0, 0);
        sem_init(&hay_espacio, 0, TAM);
        sem_init(&hay_datos, 0, 0);
        hijo = fork();
        if (hijo == 0) {
            generador(getppid());
        }
        pthread_create(&r, NULL, receptor, NULL);
        pthread_create(&p, NULL, productor, NULL);
        pthread_create(&c, NULL, consumidor, NULL);
        pthread_join(r, NULL);
        pthread_join(p, NULL);
        pthread_join(c, NULL);
        waitpid(hijo, NULL, 0);
        printf("operaciones atendidas: %d producciones y %d consumos\n", OPERACIONES,
               OPERACIONES);
        printf("elementos fuera de orden: %d\n", fuera_de_orden);
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    operaciones atendidas: 200 producciones y 200 consumos
    elementos fuera de orden: 0
    ```

!!! danger "Las señales estándar se funden"

    Con `SIGUSR1` y `SIGUSR2` en lugar de señales de tiempo real y con el generador sin
    retardos, el programa se quedó esperando en las ejecuciones realizadas. Las señales
    estándar iguales que llegan mientras otra está pendiente se funden en una, y el
    receptor cuenta menos órdenes de las que se enviaron. Con las de tiempo real, el
    mismo programa terminó correctamente.

## Comparativa de problemas

La tabla resume cada problema con el mecanismo que mejor lo expresa y la trampa más
habitual.

| Problema                              | Mecanismo                                | Trampa típica                                       |
| ------------------------------------- | ---------------------------------------- | --------------------------------------------------- |
| Productor-consumidor con varios hilos | Semáforos de contar y _mutex_            | Índices locales y orden incorrecto de los `wait`.   |
| Lectores-escritores justo             | Monitor con turnos                       | Ceder el turno solo al salir y perder concurrencia. |
| Filósofos con orden global            | Un _mutex_ por tenedor y orden de índice | Un solo hilo que adquiere en otro orden.            |
| Filósofos con rondas                  | Monitor con estados y rondas             | Inicializar las condiciones al crear los hilos.     |
| _Pipeline_ de ordenación              | Colas de mensajes de capacidad uno       | Colas con nombre que persisten tras un fallo.       |
| Productor-consumidor con señales      | `sigwaitinfo()` y semáforos              | Usar `SIGUSR1`, que no se encola.                   |

## Cierre

Los problemas del capítulo se resuelven con pocas ideas que se combinan. El estado se
reduce a contadores y el invariante se escribe como una fórmula antes de escribir
código. Cada espera es un predicado evaluado dentro de un bucle con el _mutex_ tomado, o
un semáforo cuyo valor cuenta lo que se espera. La justicia no es gratuita: se añade
como un término más del predicado, y la prioridad se expresa de la misma forma. Cuando
varios recursos intervienen a la vez, un orden global de adquisición evita el
interbloqueo. Finalmente, conviene medir el invariante dentro del propio programa y
comprobar por mutación que la medida detecta el error que se quiere evitar.

Este es el último capítulo de la serie sobre concurrencia. Los fundamentos de los
mecanismos se encuentran en [fundamentos](section_1_fundamentals.md),
[memoria compartida](section_2_shared_memory.md) y
[paso de mensajes y eventos](section_3_message_passing_events.md).
