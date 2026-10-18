---
authors: Daniel Bazo Correa
description:
    Notación Big O para el análisis de complejidad, métodos clásicos de ordenación y
    métodos de búsqueda.
title: Algoritmos
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Este capítulo aborda la notación Big O como herramienta para analizar la eficiencia de
un algoritmo con independencia del lenguaje y del equipo donde se ejecuta, y aplica
después ese análisis a los métodos clásicos de ordenación y búsqueda. Las
implementaciones presentadas operan sobre listas de Python y complementan las
estructuras descritas en el capítulo de
[estructuras de datos](section_1_data_structures.md).

## Bibliografía

- Sciencestack. (s.f.). _Big-O Algorithm Complexity Cheat Sheet_.
  <https://www.bigocheatsheet.com/>

## Estrategia de resolución de problemas

Antes de analizar la eficiencia de un algoritmo conviene disponer de un método para
abordar el problema que resuelve. Un procedimiento sistemático reduce el riesgo de
implementar una solución que no cubra todos los casos y facilita el análisis posterior.
Consta de cuatro pasos:

1. Plantear el problema con claridad, identificando el formato de entrada y el de
   salida.
2. Establecer ejemplos concretos de entrada y salida, incluyendo todos los casos
   extremos.
3. Alcanzar una solución candidata, implementarla y probarla, corrigiendo los errores
   que surjan.
4. Analizar la complejidad del algoritmo resultante e identificar las ineficiencias.

Este último paso es el que motiva la notación que se describe a continuación.

## Notación Big O

La notación Big O se utiliza para evaluar la eficiencia de los algoritmos en términos de
complejidad temporal y espacial. La **complejidad temporal** describe cómo varía el
tiempo requerido por un algoritmo en función del número de elementos de entrada,
mientras que la **complejidad espacial** describe el uso de memoria en función del
número de variables utilizadas por el algoritmo.

El interés de esta notación reside en que describe el comportamiento **asintótico**, es
decir, la tendencia de crecimiento cuando el tamaño de la entrada aumenta. Por ese
motivo se descartan las constantes multiplicativas y los términos de menor orden, ya que
dejan de ser relevantes frente al término dominante. Un algoritmo cuyo coste es $3N +
10$ se clasifica simplemente como $O(N)$.

### Órdenes de complejidad

<figure markdown="span">
  ![Órdenes de complejidad en notación Big O](../assets/img/docs/software_engineering/bigo-complexity-orders.png)
  <figcaption>Órdenes de complejidad más habituales en notación Big O. <a href="https://medium.com/@sysglobalsolutionsblog/notaci%C3%B3n-big-o-615bd1e0a227">Referencia</a></figcaption>
</figure>

Los órdenes de complejidad más frecuentes, ordenados de menor a mayor coste, son los
siguientes:

- $O(1)$: El tiempo de ejecución es constante, independientemente del tamaño de la
  entrada. Es típico en algoritmos que acceden a un número fijo de elementos, como
  devolver el primer elemento de una lista.
- $O(\log N)$: El tiempo de ejecución crece logarítmicamente con el tamaño de la
  entrada. Es común en algoritmos que dividen el problema a la mitad en cada paso, como
  la búsqueda binaria.
- $O(N)$: El tiempo de ejecución crece linealmente con el tamaño de la entrada. Es
  típico de algoritmos que realizan una operación en cada elemento de la entrada, como
  sumar todos los elementos de una lista.
- $O(N \log N)$: Representa una combinación de comportamiento lineal y logarítmico. Es
  común en algoritmos de ordenación eficientes, como _quicksort_.
- $O(N^2)$: El tiempo de ejecución crece cuadráticamente con el tamaño de la entrada. Se
  presenta en algoritmos que realizan operaciones sobre cada par de elementos, como la
  ordenación por burbuja.
- $O(2^N)$: El tiempo de ejecución crece exponencialmente con el tamaño de la entrada.
  Es típico de algoritmos que generan todas las combinaciones posibles de elementos,
  como el problema del viajante.

La diferencia práctica entre estos órdenes se aprecia al estimar el número aproximado de
operaciones para tamaños de entrada crecientes:

|    $N$ | $O(\log N)$ | $O(N)$ |  $O(N \log N)$ |  $O(N^2)$ |
| -----: | ----------: | -----: | -------------: | --------: |
|   $10$ |         $3$ |   $10$ |           $33$ |     $100$ |
| $1000$ |        $10$ | $1000$ |         $9966$ |    $10^6$ |
| $10^6$ |        $20$ | $10^6$ | $2 \cdot 10^7$ | $10^{12}$ |

En casos donde se realizan múltiples operaciones con diferentes costes temporales, la
notación Big O representa el peor caso, ya que interesa acotar el comportamiento más
desfavorable que puede presentar el algoritmo.

Es importante señalar que la notación Big O no está limitada a la letra $N$. Cualquier
letra puede representar el tamaño de la entrada en función del contexto del problema.

### Complejidad en algoritmos multipartes

En algoritmos que involucran múltiples estructuras de datos, la complejidad puede
depender de más de un parámetro. Distinguir si los bucles se ejecutan de forma
consecutiva o anidada resulta determinante, porque en el primer caso los costes se suman
y en el segundo se multiplican.

???+ example "Bucles secuenciales"

    ```python linenums="1"
    def funcion(array_a: list[int], array_b: list[int]) -> None:
        """
        Recorre dos listas de forma consecutiva.

        Args:
            array_a: Primera lista que se recorre.
            array_b: Segunda lista que se recorre.
        """

        for i in array_a:
            ...

        for i in array_b:
            ...
    ```

    Cada bucle tiene una complejidad de $O(N)$, pero como operan sobre _arrays_
    diferentes, la complejidad total es $O(A + B)$, donde $A$ y $B$ son los tamaños de
    `array_a` y `array_b` respectivamente.

???+ example "Bucles anidados"

    ```python linenums="1"
    def funcion(array_a: list[int], array_b: list[int]) -> None:
        """
        Recorre la segunda lista completa para cada elemento de la
        primera.

        Args:
            array_a: Lista recorrida por el bucle externo.
            array_b: Lista recorrida por el bucle interno.
        """

        for i in array_a:
            for j in array_b:
                ...
    ```

    En este caso, la complejidad es $O(A \times B)$, ya que los bucles anidados operan
    sobre _arrays_ diferentes. Constituye un error asumir $O(N^2)$ sin considerar los
    tamaños de los _arrays_ involucrados, puesto que esa expresión solo es válida cuando
    ambas dimensiones coinciden.

Una vez establecido el marco de análisis, las secciones siguientes lo aplican a dos
familias de algoritmos fundamentales. Los métodos de ordenación reorganizan los
elementos de una secuencia según un criterio, mientras que los métodos de búsqueda
localizan un valor dentro de ella, y ambos problemas están relacionados, ya que disponer
de una secuencia ordenada habilita estrategias de búsqueda considerablemente más
eficientes.

## Métodos de ordenación

Los métodos que se describen a continuación son algoritmos de ordenación **in situ**, es
decir, reorganizan los elementos dentro de la propia lista sin necesitar estructuras
auxiliares proporcionales al tamaño de la entrada, por lo que su complejidad espacial es
$O(1)$. Su interés es principalmente didáctico, ya que ilustran con claridad la relación
entre el número de comparaciones y el coste asintótico.

### Ordenación por burbuja (_Bubble Sort_)

La ordenación por burbuja compara pares adyacentes de elementos en una lista e
intercambia sus posiciones si están en orden incorrecto. Tras cada pasada completa, el
mayor de los elementos no colocados asciende hasta su posición definitiva, de forma
análoga a una burbuja que sube a la superficie. El proceso se repite hasta que no se
requieren más intercambios, lo que indica que la lista está ordenada.

El número de comparaciones en el peor caso se obtiene sumando las de cada pasada, lo que
da la suma de una serie aritmética:

$$
\frac{N(N-1)}{2}
$$

Ese término cuadrático es el que domina el comportamiento asintótico. Cuando la lista se
encuentra ya ordenada y la implementación detecta la ausencia de intercambios, basta una
única pasada, de modo que el mejor caso es lineal, $O(N)$.

- **Complejidad temporal**: $O(N^2)$ en el peor caso y $O(N)$ en el mejor.
- **Complejidad espacial**: $O(1)$.

???+ tip "Implementación"

    ```python linenums="1"
    def ordenacion_burbuja(lista: list[int]) -> list[int]:
        """
        Ordena una lista de enteros mediante comparaciones de pares
        adyacentes.

        Args:
            lista: Lista de enteros que se ordena in situ.

        Returns:
            La misma lista recibida, con sus elementos en orden
                creciente.
        """

        n: int = len(lista)

        for i in range(n):
            for j in range(n - 1):
                if lista[j] > lista[j + 1]:
                    lista[j], lista[j + 1] = lista[j + 1], lista[j]

        return lista
    ```

    ```python linenums="1"
    print(f"Resultado: {ordenacion_burbuja([5, 1, 4, 2, 8])}")
    ```

    ```title="Salida esperada"
    Resultado: [1, 2, 4, 5, 8]
    ```

### Ordenación por selección (_Selection Sort_)

La ordenación por selección divide conceptualmente la lista en una parte ordenada,
situada al principio, y otra pendiente de ordenar. En cada iteración busca el elemento
más pequeño de la parte no ordenada y lo intercambia con la primera posición de esa
parte, ampliando así el segmento ordenado. El proceso se repite hasta que la lista está
completamente ordenada.

Frente a la ordenación por burbuja, este método realiza el mismo número de
comparaciones, pero un número mucho menor de intercambios, ya que efectúa como máximo
uno por iteración.

- **Complejidad temporal**: $O(N^2)$ en el peor caso.
- **Complejidad espacial**: $O(1)$.

???+ tip "Implementación"

    ```python linenums="1"
    def ordenacion_seleccion(lista: list[int]) -> list[int]:
        """
        Ordena una lista de enteros seleccionando el mínimo en cada
        iteración.

        Args:
            lista: Lista de enteros que se ordena in situ.

        Returns:
            La misma lista recibida, con sus elementos en orden
                creciente.
        """

        n: int = len(lista)

        for i in range(n):
            idx_min: int = i

            for j in range(i + 1, n):
                if lista[j] < lista[idx_min]:
                    idx_min = j

            lista[i], lista[idx_min] = lista[idx_min], lista[i]

        return lista
    ```

    ```python linenums="1"
    print(f"Resultado: {ordenacion_seleccion([5, 1, 4, 2, 8])}")
    ```

    ```title="Salida esperada"
    Resultado: [1, 2, 4, 5, 8]
    ```

### Ordenación por inserción (_Insertion Sort_)

La ordenación por inserción también distingue una parte ordenada y otra desordenada,
pero en lugar de buscar el mínimo, toma el siguiente elemento pendiente y lo desplaza
hacia la izquierda hasta situarlo en la posición que le corresponde dentro de la parte
ordenada.

Este comportamiento explica su ventaja frente a los métodos anteriores cuando la entrada
está casi ordenada, ya que en el mejor caso, con la lista previamente ordenada, cada
elemento requiere una única comparación y el coste desciende a $O(N)$. Por esta razón se
emplea como caso base en implementaciones de algoritmos más avanzados cuando los
subproblemas resultan suficientemente pequeños.

- **Complejidad temporal**: $O(N^2)$ en el peor caso, $O(N)$ en el mejor caso.
- **Complejidad espacial**: $O(1)$.

???+ tip "Implementación"

    ```python linenums="1"
    def ordenacion_insercion(lista: list[int]) -> list[int]:
        """
        Ordena una lista insertando cada elemento en la parte ya
        ordenada.

        Args:
            lista: Lista de enteros que se ordena in situ.

        Returns:
            La misma lista recibida, con sus elementos en orden
                creciente.
        """

        for i in range(1, len(lista)):
            j: int = i

            while j > 0 and lista[j - 1] > lista[j]:
                lista[j - 1], lista[j] = lista[j], lista[j - 1]
                j -= 1

        return lista
    ```

    ```python linenums="1"
    print(f"Resultado: {ordenacion_insercion([5, 1, 4, 2, 8])}")
    ```

    ```title="Salida esperada"
    Resultado: [1, 2, 4, 5, 8]
    ```

La comparación de los tres métodos permite apreciar que un mismo orden de complejidad
asintótica admite comportamientos distintos según las características de la entrada:

| Método    | Mejor caso | Peor caso | Complejidad espacial | Comportamiento destacado                       |
| :-------- | :--------- | :-------- | :------------------- | :--------------------------------------------- |
| Burbuja   | $O(N^2)$   | $O(N^2)$  | $O(1)$               | Número elevado de intercambios                 |
| Selección | $O(N^2)$   | $O(N^2)$  | $O(1)$               | Como máximo un intercambio por iteración       |
| Inserción | $O(N)$     | $O(N^2)$  | $O(1)$               | Muy eficiente si la entrada está casi ordenada |

## Métodos de búsqueda

Los métodos de búsqueda determinan si un valor está presente en una secuencia y, en caso
afirmativo, en qué posición se encuentra. La estrategia aplicable depende de una
condición previa decisiva, que es si la secuencia está ordenada, ya que solo en ese caso
puede descartarse parte de los datos sin examinarlos.

### Búsqueda lineal (_Linear Search_)

La búsqueda lineal recorre cada elemento de la lista uno por uno hasta encontrar el
elemento buscado o hasta agotar todos los elementos. No impone ninguna condición sobre
la secuencia, lo que la convierte en la única opción viable cuando los datos no están
ordenados.

- **Complejidad temporal**: $O(N)$ en el peor caso.
- **Complejidad espacial**: $O(1)$.

???+ tip "Implementación"

    ```python linenums="1"
    def busqueda_lineal(lista: list[int], valor_buscar: int) -> int | None:
        """
        Busca un valor recorriendo la lista de forma secuencial.

        Args:
            lista: Lista de enteros donde se realiza la búsqueda.
            valor_buscar: Valor que se desea localizar.

        Returns:
            El índice de la primera aparición del valor, o None si no
                está presente.
        """

        for idx, valor in enumerate(lista):
            if valor_buscar == valor:
                return idx

        return None
    ```

    ```python linenums="1"
    print(f"Índice del 4: {busqueda_lineal([5, 1, 4, 2, 8], 4)}")
    print(f"Índice del 7: {busqueda_lineal([5, 1, 4, 2, 8], 7)}")
    ```

    ```title="Salida esperada"
    Índice del 4: 2
    Índice del 7: None
    ```

### Búsqueda binaria (_Binary Search_)

La búsqueda binaria divide repetidamente a la mitad la parte de la lista que podría
contener el elemento buscado, hasta reducir las posibles ubicaciones a una sola. En cada
iteración compara el valor buscado con el elemento central del intervalo vigente y,
según el resultado, descarta la mitad en la que el valor no puede encontrarse. Este
método requiere que la lista esté previamente ordenada.

Como el número de candidatos se reduce a la mitad en cada paso, el número de
comparaciones necesarias es proporcional a $\log_2 N$, donde $N$ representa el número de
elementos de la lista. Conviene tener presente que ordenar previamente la secuencia
tiene un coste asociado, por lo que la búsqueda binaria resulta ventajosa cuando sobre
los mismos datos se realizan muchas búsquedas.

La derivación formal de esta complejidad es inmediata. Partiendo de una longitud inicial
$N$, tras $k$ iteraciones el tramo explorado tiene longitud:

$$
\frac{N}{2^k}
$$

El proceso termina cuando ese tramo se reduce a un único elemento, de modo que igualando
a 1 y despejando se obtiene el número de iteraciones:

$$
\frac{N}{2^k} = 1 \;\Rightarrow\; N = 2^k \;\Rightarrow\; k = \log_2 N
$$

???+ example "El problema de localizar una carta"

    Un enunciado clásico que ilustra el método plantea la siguiente situación. Alicia
    dispone de un conjunto de cartas con números escritos, las ordena de mayor a menor y
    las coloca boca abajo sobre una mesa. El reto consiste en localizar la carta que
    contiene un número dado volteando el menor número posible de cartas.

    Partiendo de las cartas `[5, 8, 3, 9, 1, 4, 28]` y ordenándolas de forma decreciente
    se obtiene `[28, 9, 8, 5, 4, 3, 1]`. La estrategia consiste en voltear la carta
    central, en este caso el 5 situado en el índice 3, lo que permite descartar de
    inmediato la mitad del conjunto: si el valor buscado es mayor que 5 solo puede estar
    en la mitad izquierda, y si es menor solo en la derecha.

    Repitiendo el procedimiento sobre la mitad que queda, el número de cartas candidatas
    se reduce a la mitad en cada paso, lo que arroja la complejidad $O(\log_2 N)$ derivada
    anteriormente. La única particularidad frente a la implementación habitual es que, al
    estar la secuencia ordenada de forma decreciente, las comparaciones que determinan
    hacia qué lado continuar quedan invertidas.

- **Complejidad temporal**: $O(\log N)$ en el peor caso.
- **Complejidad espacial**: $O(1)$.

???+ tip "Implementación"

    ```python linenums="1"
    def busqueda_binaria(lista: list[int], valor_buscar: int) -> int | None:
        """
        Busca un valor en una lista ordenada dividiendo el intervalo
        por la mitad.

        Args:
            lista: Lista de enteros ordenada de forma creciente.
            valor_buscar: Valor que se desea localizar.

        Returns:
            El índice donde se encuentra el valor, o None si no está
                presente.
        """

        izquierda: int = 0
        derecha: int = len(lista) - 1

        while izquierda <= derecha:
            punto_medio: int = (izquierda + derecha) // 2

            if valor_buscar == lista[punto_medio]:
                return punto_medio
            elif valor_buscar > lista[punto_medio]:
                izquierda = punto_medio + 1
            else:
                derecha = punto_medio - 1

        return None
    ```

    ```python linenums="1"
    print(f"Índice del 4: {busqueda_binaria([1, 2, 4, 5, 8], 4)}")
    print(f"Índice del 7: {busqueda_binaria([1, 2, 4, 5, 8], 7)}")
    ```

    ```title="Salida esperada"
    Índice del 4: 2
    Índice del 7: None
    ```

???+ warning "Requisito de ordenación"

    Aplicar la búsqueda binaria sobre una lista desordenada no produce un error de
    ejecución, sino un resultado incorrecto, ya que el algoritmo descarta intervalos
    asumiendo una ordenación que no existe. Verificar esta precondición es responsabilidad
    de quien invoca la función.

La elección entre ambos métodos depende, por tanto, del estado de los datos y del número
de consultas previstas:

| Método  | Requiere ordenación | Complejidad temporal | Situación recomendada                    |
| :------ | :------------------ | :------------------- | :--------------------------------------- |
| Lineal  | No                  | $O(N)$               | Datos desordenados o búsquedas puntuales |
| Binaria | Sí                  | $O(\log N)$          | Datos ordenados con búsquedas frecuentes |
