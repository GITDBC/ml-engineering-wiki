---
icon: lucide/braces
authors: Daniel Bazo Correa
description:
    Funciones, recursión, arrays, std::vector, cadenas de caracteres, estructuras,
    enumerados y números aleatorios en C++17, junto con los errores más frecuentes al
    usarlos.
title: Funciones y estructuras de datos en C++
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Este capítulo continúa los [fundamentos de C++](section_1_fundamentals.md) con las
herramientas para organizar el código y los datos: las funciones y el paso de
parámetros, la recursión, los _arrays_, `std::vector` y las matrices, las cadenas, las
estructuras y los enumerados. Cierra con los números aleatorios y una tabla de errores
frecuentes. Los archivos, las clases y los punteros con la memoria dinámica se tratan en
capítulos posteriores del módulo, enlazados al final.

## Funciones

Una **función** agrupa un bloque de código bajo un nombre para reutilizarlo y dividir un
programa grande en partes pequeñas y comprobables por separado. Se define indicando el
tipo del valor que devuelve, su nombre y la lista de parámetros con sus tipos:

```plaintext linenums="1"
tipo nombre(tipo parametro1, tipo parametro2) {
    // La sentencia return devuelve el resultado al código que llamó
    return resultado;
}
```

Si la función no devuelve ningún valor, su tipo es `void`. Una función debe declararse
antes de usarse. Para poder escribir `main` al principio, la declaración sola, llamada
**prototipo**, se coloca arriba y la definición completa se deja para más abajo. Los
parámetros y las variables declaradas dentro de la función son locales y dejan de
existir al terminar. Las variables globales, declaradas fuera de toda función, son
visibles desde cualquier punto, pero acoplan las funciones entre sí y dificultan su
comprobación, por lo que es preferible pasar los datos como parámetros.

Todos los caminos de ejecución de una función con tipo de retorno deben terminar en un
`return`. Un `bool` o un contador asignado solo en algunas ramas devuelve un valor
indeterminado en las demás.

???+ example "Una función booleana"

    El programa define `es_primo` y la usa para listar los primos hasta 30. Basta probar
    divisores hasta la raíz del número, porque si `n` tiene un divisor mayor que su
    raíz, tiene también uno menor.

    ```cpp linenums="1"
    #include <iostream>

    using namespace std;

    // Devuelve true si n es primo, y basta probar divisores hasta su raíz
    bool es_primo(int n) {
        if (n < 2) {
            return false;
        }
        for (int divisor = 2; divisor * divisor <= n; divisor++) {
            if (n % divisor == 0) {
                return false;
            }
        }
        return true;
    }

    int main() {
        for (int n = 1; n <= 30; n++) {
            if (es_primo(n)) {
                cout << n << " ";
            }
        }
        cout << endl;
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    2 3 5 7 11 13 17 19 23 29
    ```

### Paso por valor y por referencia

Por omisión los argumentos se **pasan por valor**: la función recibe una copia y las
modificaciones no afectan a la variable original. Si el parámetro se declara con `&`, se
**pasa por referencia** y se convierte en un alias de la variable original, de modo que
la función puede modificarla. Esta es la forma habitual de devolver varios resultados.

| Forma                | Copia | Modifica el original | Uso habitual                                |
| -------------------- | ----- | -------------------- | ------------------------------------------- |
| `void f(int x)`      | Sí    | No                   | Datos pequeños de solo lectura.             |
| `void f(int &x)`     | No    | Sí                   | Parámetros de salida o de entrada y salida. |
| `void f(const T &x)` | No    | No                   | Datos grandes de solo lectura.              |

Los tipos pequeños, como `int` o `double`, se pasan por valor, porque copiarlos cuesta
menos que seguir una referencia. Los grandes, como las estructuras o los contenedores de
la biblioteca estándar, se pasan por `const &`: se evita la copia y el compilador impide
que la función los modifique por error.

???+ example "Valor, referencia e intercambio"

    El programa compara una función que incrementa una copia con otra que incrementa el
    original, y usa una tercera para intercambiar dos variables.

    ```cpp linenums="1"
    #include <iostream>

    using namespace std;

    // Modifica una copia: el argumento original no cambia
    void incrementar_copia(int x) {
        x++;
    }

    // Modifica la variable original mediante la referencia
    void incrementar_referencia(int &x) {
        x++;
    }

    // Intercambia dos variables mediante un temporal
    void intercambiar(int &a, int &b) {
        int temporal = a;
        a = b;
        b = temporal;
    }

    int main() {
        int n = 10;
        incrementar_copia(n);
        cout << "Tras incrementar_copia: " << n << endl;
        incrementar_referencia(n);
        cout << "Tras incrementar_referencia: " << n << endl;

        int a = 9, b = -4;
        intercambiar(a, b);
        cout << "a = " << a << ", b = " << b << endl;
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    Tras incrementar_copia: 10
    Tras incrementar_referencia: 11
    a = -4, b = 9
    ```

???+ example "Varios resultados"

    El programa muestra dos maneras de devolver cociente y resto. La primera usa
    parámetros por referencia y un `bool` que indica si la operación fue posible. La
    segunda devuelve un `pair` que se desempaqueta con un enlace estructurado de C++17.

    ```cpp linenums="1"
    #include <iostream>
    #include <utility>

    using namespace std;

    // El valor de retorno indica el éxito y los resultados salen por referencia
    bool dividir(int a, int b, int &cociente, int &resto) {
        if (b == 0) {
            return false;
        }
        cociente = a / b;
        resto = a % b;
        return true;
    }

    // Alternativa: devolver ambos valores juntos en un pair
    pair<int, int> dividir_par(int a, int b) {
        return {a / b, a % b};
    }

    int main() {
        int cociente = 0, resto = 0;
        if (dividir(17, 5, cociente, resto)) {
            cout << "17 = 5 * " << cociente << " + " << resto << endl;
        }
        if (!dividir(17, 0, cociente, resto)) {
            cout << "División por cero" << endl;
        }

        // Enlace estructurado (C++17): desempaqueta el pair en dos variables
        auto [c, r] = dividir_par(23, 4);
        cout << "23 = 4 * " << c << " + " << r << endl;
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    17 = 5 * 3 + 2
    División por cero
    23 = 4 * 5 + 3
    ```

!!! warning "Un mismo objeto como entrada y salida"

    Si una variable se pasa a la vez como parámetro de entrada y de salida, escribir en
    la salida modifica también la entrada, incluso cuando esta se declara `const &`,
    porque ambas son alias del mismo objeto. Sea una función `producto` con los
    parámetros `const double &a`, `const double &b`, `double c`, `double d`,
    `double &re` y `double &im`, que multiplica dos números complejos con
    `re = a * c - b * d;` seguido de `im = a * d + b * c;`. La llamada
    `producto(x, y, 3.0, 4.0, x, y)` hace que `im` use el valor de `a` ya modificado. La
    solución consiste en calcular ambos resultados en variables locales antes de
    escribir ninguno.

### Plantillas de función

Una **plantilla** (_template_) define una función para un tipo genérico `T` y deja que
el compilador genere una versión por cada tipo con el que se la llama. Evita duplicar el
mismo código para `int`, `double` o `char`.

???+ example "Funciones genéricas"

    El programa define el valor absoluto y el máximo para cualquier tipo comparable.

    ```cpp linenums="1"
    #include <iostream>

    using namespace std;

    // El compilador genera una versión para cada tipo con el que se llama
    template <typename T>
    T valor_absoluto(T x) {
        return x < 0 ? -x : x;
    }

    template <typename T>
    T maximo(T a, T b) {
        return a > b ? a : b;
    }

    int main() {
        cout << valor_absoluto(-7) << " " << valor_absoluto(-2.5) << endl;
        cout << maximo(3, 8) << " " << maximo(2.5, 1.5) << " ";
        cout << maximo('a', 'z') << endl;
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    7 2.5
    8 2.5 z
    ```

## Recursión

Una función es **recursiva** si se llama a sí misma. Todo algoritmo recursivo necesita
dos partes. El **caso base** resuelve directamente el problema más pequeño y detiene la
recursión. El **caso recursivo** reduce el problema a uno más pequeño del mismo tipo y
se acerca al caso base en cada llamada. El factorial, definido como $0! = 1$ y $n! = n
\cdot (n - 1)!$, es el ejemplo clásico.

Cada llamada reserva un marco en la pila (_stack_) con sus parámetros y variables
locales, y los marcos se liberan en orden inverso cuando las llamadas devuelven su
resultado. Para `factorial(4)`, la pila crece hasta cinco llamadas activas antes de
poder multiplicar.

| Llamada        | Espera el resultado de | Devuelve         |
| -------------- | ---------------------- | ---------------- |
| `factorial(4)` | `factorial(3)`         | $4 \cdot 6 = 24$ |
| `factorial(3)` | `factorial(2)`         | $3 \cdot 2 = 6$  |
| `factorial(2)` | `factorial(1)`         | $2 \cdot 1 = 2$  |
| `factorial(1)` | `factorial(0)`         | $1 \cdot 1 = 1$  |
| `factorial(0)` | Nada, es el caso base  | $1$              |

???+ example "Factorial y máximo común divisor"

    El programa implementa dos funciones recursivas. `mcd` aplica el algoritmo de
    Euclides, basado en que $\operatorname{mcd}(a, b) = \operatorname{mcd}(b, a \bmod
    b)$.

    ```cpp linenums="1"
    #include <iostream>

    using namespace std;

    // Caso base: 0! = 1. Caso recursivo: n! = n * (n - 1)!
    unsigned long long factorial(unsigned n) {
        if (n == 0) {
            return 1;
        }
        return n * factorial(n - 1);
    }

    // Algoritmo de Euclides: mcd(a, b) = mcd(b, a mod b)
    unsigned mcd(unsigned a, unsigned b) {
        if (b == 0) {
            return a;
        }
        return mcd(b, a % b);
    }

    int main() {
        cout << "5! = " << factorial(5) << endl;
        // 20! es el mayor factorial que cabe en un unsigned long long
        cout << "20! = " << factorial(20) << endl;
        cout << "mcd(84, 36) = " << mcd(84, 36) << endl;
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    5! = 120
    20! = 2432902008176640000
    mcd(84, 36) = 12
    ```

!!! warning "Límites de la recursión"

    Sin caso base alcanzable, la recursión consume la pila hasta que el programa termina
    de forma abrupta. Además, un `int` solo contiene el factorial de 12, y un
    `unsigned long long` el de 20. Cuando el algoritmo se expresa igual de bien con un
    bucle, como el factorial o la sucesión de Fibonacci, la versión iterativa es más
    rápida y no corre ese riesgo. La recursión resulta más natural en problemas que se
    descomponen en subproblemas, como el recorrido de estructuras jerárquicas.

## _Arrays_

Un _array_ es una colección de elementos del mismo tipo almacenados de forma contigua en
memoria y accesibles mediante un índice. La primera posición es la `0` y la última es
`n - 1`. Su tamaño se fija al compilar, por lo que debe ser una constante.

### La clase `std::array`

La biblioteca estándar ofrece `std::array<T, N>`, un _array_ que conserva su tamaño y
ofrece operaciones útiles sin coste adicional. Las más habituales son `size()`,
`fill(v)` para asignar un valor a todos los elementos, `at(i)` para acceder con
comprobación de límites y `begin()` y `end()` para usar los algoritmos de la biblioteca.
Una declaración con `= {}` inicializa todos los elementos a cero, y sin ella contienen
valores indeterminados.

Los _arrays_ heredados de C se declaran con corchetes: `int a[10];` reserva diez enteros
y `int b[] = {2, 3, 4, 5};` deduce la longitud del inicializador. No exigen que se usen
todas las posiciones, pero carecen de `size()` y de la mayoría de las operaciones. Los
ejemplos del capítulo emplean `std::array`, salvo cuando se indica.

???+ example "Recorridos básicos"

    El programa calcula la suma, la media y la posición del máximo de un _array_ y
    recorre sus elementos con un bucle por rango.

    ```cpp linenums="1"
    #include <array>
    #include <iostream>

    using namespace std;

    int main() {
        // El tamaño forma parte del tipo y debe ser una constante
        constexpr int N = 5;
        array<int, N> datos = {3, 4, 2, 1, 5};

        int suma = 0;
        int posicion_maximo = 0;
        for (int i = 0; i < N; i++) {
            suma += datos[i];
            if (datos[i] > datos[posicion_maximo]) {
                posicion_maximo = i;
            }
        }
        double media = static_cast<double>(suma) / N;
        cout << "Suma: " << suma << " media: " << media << endl;
        cout << "Máximo " << datos[posicion_maximo] << " en la posición "
             << posicion_maximo << endl;

        // for por rango: recorre todos los elementos sin índice
        for (int valor : datos) {
            cout << valor * valor << " ";
        }
        cout << endl;

        // fill asigna el mismo valor a todos los elementos
        datos.fill(0);
        cout << datos.size() << " elementos, primero " << datos[0] << endl;
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    Suma: 15 media: 3
    Máximo 5 en la posición 4
    9 16 4 1 25
    5 elementos, primero 0
    ```

!!! warning "Acceso fuera de límites"

    El operador `[]` no comprueba que el índice sea válido. Leer o escribir fuera del
    _array_ es comportamiento indefinido: puede no fallar, corromper otras variables o
    cerrar el programa. El método `at()` lanza una excepción en ese caso. Los índices
    solo llegan hasta `n - 1`, y por tanto la condición correcta del bucle es `i < n`.

!!! warning "Arrays de longitud variable"

    La declaración `int datos[n];` con `n` leído en tiempo de ejecución, llamada _array_
    de longitud variable, no es C++ estándar. El compilador la acepta como extensión,
    pero `-pedantic` la señala. Para tamaños fijos se usa una constante `constexpr`, y
    para tamaños que solo se conocen al ejecutar, `std::vector`, que gestiona su memoria
    y crece con `push_back`.

    ```cpp linenums="1"
    #include <iostream>

    using namespace std;

    int main() {
        int n = 0;
        cin >> n;
        int datos[n];
        datos[0] = 1;
        cout << datos[0] << endl;
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    programa.cpp: In function ‘int main()’:
    programa.cpp:8:9: warning: ISO C++ forbids variable length array ‘datos’ [-Wvla]
        8 |     int datos[n];
          |         ^~~~~
    ```

### _Arrays_ de estilo C como parámetros

Un _array_ de estilo C se pasa a una función sin su longitud, de modo que esta debe
enviarse como un parámetro adicional. En las matrices hay que indicar todas las
dimensiones salvo la primera. Esta limitación, que procede de cómo C trata los _arrays_
como direcciones de memoria, es una de las razones para preferir `std::array`, que
conserva su tamaño. El capítulo de [memoria](section_5_memory.md) explica el mecanismo.

???+ example "Arrays de estilo C"

    El programa suma un vector y una matriz recibidos como parámetros y calcula la
    longitud de un _array_ con `sizeof`.

    ```cpp linenums="1"
    #include <iostream>

    using namespace std;

    // Un array de estilo C llega sin su longitud: debe pasarse aparte
    int sumar(const int datos[], int n) {
        int suma = 0;
        for (int i = 0; i < n; i++) {
            suma += datos[i];
        }
        return suma;
    }

    // En una matriz, todas las dimensiones salvo la primera deben indicarse
    int sumar_matriz(const int m[][3], int filas) {
        int suma = 0;
        for (int i = 0; i < filas; i++) {
            for (int j = 0; j < 3; j++) {
                suma += m[i][j];
            }
        }
        return suma;
    }

    int main() {
        // La longitud se deduce del inicializador
        int serie[] = {1, 2, 3, 4, 5};
        int cuadro[2][3] = {{1, 2, 3}, {4, 5, 6}};

        cout << sumar(serie, 5) << " " << sumar_matriz(cuadro, 2) << endl;
        // sizeof solo conoce la longitud en el ámbito donde se declara el array
        cout << sizeof(serie) / sizeof(serie[0]) << endl;
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    15 21
    5
    ```

### El contenedor `std::vector`

Cuando el número de elementos solo se conoce al ejecutar el programa, `std::vector<T>`,
de la biblioteca `<vector>`, gestiona su propia memoria y crece con `push_back`. Ofrece
`size()`, el acceso con `[]` y `at()`, y los mismos recorridos que `std::array`, pero se
copia con `=` y viaja a las funciones con su longitud. Por eso es la opción por omisión
para una colección de tamaño variable frente a los _arrays_ de estilo C. Una matriz de
tamaño variable es un `vector<vector<T>>`.

???+ example "Vector de tamaño variable"

    El programa construye un vector con `push_back`, calcula su media en una función que
    no recibe la longitud y crea una matriz de 2 filas y 3 columnas.

    ```cpp linenums="1"
    #include <iostream>
    #include <vector>

    using namespace std;

    // El vector llega con su longitud, que se consulta con size()
    double media(const vector<double> &datos) {
        if (datos.empty()) {
            return 0.0;
        }
        double suma = 0.0;
        for (double d : datos) {
            suma += d;
        }
        return suma / static_cast<double>(datos.size());
    }

    int main() {
        // El tamaño se decide al ejecutar y no hace falta fijar una capacidad
        const int n = 4;
        vector<double> datos;
        for (int i = 1; i <= n; i++) {
            // push_back añade al final y el vector crece solo
            datos.push_back(i * 1.5);
        }
        cout << datos.size() << " valores, media " << media(datos) << endl;

        // Matriz de 2 filas y 3 columnas con todos los elementos a cero
        vector<vector<int>> m(2, vector<int>(3, 0));
        m[1][2] = 7;
        cout << m.size() << "x" << m[0].size() << ", m[1][2] = " << m[1][2] << endl;
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    4 valores, media 3.75
    2x3, m[1][2] = 7
    ```

### Frecuencias y contadores

Cuando los valores posibles forman un rango pequeño, un _array_ de contadores indexado
por el propio valor resuelve el recuento de frecuencias en una sola pasada. Para los
dígitos, el índice es `c - '0'`, y para las letras minúsculas, `c - 'a'` con 26
contadores.

???+ example "Frecuencia de dígitos"

    Con la entrada `1233450921 7`, el programa lee carácter a carácter con `cin.get`,
    hasta el salto de línea, ignora los que no son dígitos y cuenta las apariciones de
    cada uno.

    ```cpp linenums="1"
    #include <array>
    #include <cctype>
    #include <iostream>

    using namespace std;

    int main() {
        // Un contador por dígito, inicializado a cero
        array<int, 10> frecuencia = {};

        cout << "Dígitos: ";
        // get lee un carácter cada vez, incluidos los espacios y el salto de línea
        char c = static_cast<char>(cin.get());
        while (c != '\n' && cin) {
            if (isdigit(static_cast<unsigned char>(c))) {
                // El valor del dígito es el índice del contador
                frecuencia[c - '0']++;
            }
            c = static_cast<char>(cin.get());
        }

        for (int d = 0; d < 10; d++) {
            cout << d << ":" << frecuencia[d] << " ";
        }
        cout << endl;
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    Dígitos: 0:1 1:2 2:2 3:2 4:1 5:1 6:0 7:1 8:0 9:1
    ```

### Ordenación

Ordenar un _array_ consiste en reorganizar sus elementos según un criterio. Los
algoritmos elementales (burbuja, selección e inserción) tienen un coste cuadrático,
$O(n^{2})$, y se explican junto con la notación Big O en el capítulo de
[algoritmos](../../04_software_engineering/section_2_algorithms.md), con ejemplos en
Python. El programa siguiente implementa la inserción en C++: toma cada elemento y
desplaza a la derecha los mayores para abrirle hueco.

???+ example "Ordenación por inserción"

    ```cpp linenums="1"
    #include <iostream>
    #include <vector>

    using namespace std;

    // Inserción: desplaza los mayores a la derecha para abrir hueco al elemento i
    void insercion(vector<int> &a) {
        for (size_t i = 1; i < a.size(); i++) {
            int actual = a[i];
            size_t pos = i;
            while (pos > 0 && a[pos - 1] > actual) {
                a[pos] = a[pos - 1];
                pos--;
            }
            a[pos] = actual;
        }
    }

    int main() {
        vector<int> a = {5, 2, 9, 1, 7, 2};
        insercion(a);
        for (int x : a) {
            cout << x << " ";
        }
        cout << endl;
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    1 2 2 5 7 9
    ```

En programas reales se utiliza `std::sort`, de la biblioteca `<algorithm>`, con coste
$O(n \log n)$. Un tercer argumento opcional define el criterio, como se muestra en la
sección de estructuras.

### Búsqueda

La **búsqueda secuencial** recorre el _array_ desde el principio hasta encontrar el dato
o agotar los elementos. Funciona con cualquier orden y cuesta $O(n)$. La función
`buscar` de la sección de estructuras es un ejemplo. La **búsqueda binaria** exige un
_array_ ordenado y compara el dato con el elemento central, lo que descarta la mitad de
las posiciones en cada paso con un coste $O(\log n)$. Ambas se detallan en el capítulo
de [algoritmos](../../04_software_engineering/section_2_algorithms.md).

???+ example "Búsqueda binaria"

    El programa mantiene el intervalo $\lbrack \text{inf}, \text{sup})$ y calcula la
    mitad sin riesgo de desbordamiento. Devuelve la posición del dato o `-1` si no está.

    ```cpp linenums="1"
    #include <iostream>
    #include <vector>

    using namespace std;

    // Búsqueda binaria: exige orden y reduce a la mitad el intervalo [inf, sup)
    int buscar_binaria(const vector<int> &a, int dato) {
        int inf = 0;
        int sup = static_cast<int>(a.size());
        while (inf < sup) {
            // Evita el desbordamiento de inf + sup en listas muy grandes
            int mitad = inf + (sup - inf) / 2;
            if (a[mitad] == dato) {
                return mitad;
            }
            if (a[mitad] < dato) {
                inf = mitad + 1;
            } else {
                sup = mitad;
            }
        }
        return -1;
    }

    int main() {
        const vector<int> ordenada = {2, 5, 8, 12, 16, 23, 38};
        cout << "Dato 23: " << buscar_binaria(ordenada, 23) << endl;
        cout << "Dato 7: " << buscar_binaria(ordenada, 7) << endl;
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    Dato 23: 5
    Dato 7: -1
    ```

La biblioteca estándar incluye `find` para la búsqueda secuencial, y `binary_search` y
`lower_bound` para la binaria.

### Matrices

Una **matriz** es un _array_ de _arrays_ y se declara como `array<array<T, C>, F>`. El
elemento `m[i][j]` es el de la fila `i` y la columna `j`. Un alias con `using` evita
repetir el tipo compuesto. Recorrer una matriz exige dos bucles anidados, y el orden de
anidamiento decide si se recorre por filas o por columnas. En las sumas de filas, el
acumulador se reinicia en cada vuelta del bucle externo. En las diagonales de una matriz
cuadrada de lado `N`, la principal cumple `i == j` y la secundaria `i + j == N - 1`. Si
las dimensiones se conocen solo al ejecutar, se usa `vector<vector<T>>` en lugar de
`array`.

???+ example "Sumas, diagonales y traspuesta"

    El programa recorre una matriz de 3 por 3 por filas y por columnas, suma ambas
    diagonales y construye su traspuesta.

    ```cpp linenums="1"
    #include <array>
    #include <iomanip>
    #include <iostream>

    using namespace std;

    constexpr int N = 3;
    using Matriz = array<array<int, N>, N>;

    void mostrar(const Matriz &m) {
        for (int i = 0; i < N; i++) {
            for (int j = 0; j < N; j++) {
                cout << setw(3) << m[i][j];
            }
            cout << endl;
        }
    }

    int main() {
        // Cada llave interior es una fila
        const Matriz m = {{{1, 2, 3}, {4, 5, 6}, {7, 8, 9}}};
        mostrar(m);

        // La suma de cada fila reinicia el acumulador en cada vuelta externa
        for (int i = 0; i < N; i++) {
            int suma = 0;
            for (int j = 0; j < N; j++) {
                suma += m[i][j];
            }
            cout << "Fila " << i << ": " << suma << endl;
        }

        // En las columnas se intercambian los bucles
        for (int j = 0; j < N; j++) {
            int suma = 0;
            for (int i = 0; i < N; i++) {
                suma += m[i][j];
            }
            cout << "Columna " << j << ": " << suma << endl;
        }

        // Diagonal principal: i == j. Secundaria: i + j == N - 1
        int principal = 0, secundaria = 0;
        for (int i = 0; i < N; i++) {
            principal += m[i][i];
            secundaria += m[i][N - 1 - i];
        }
        cout << "Diagonales: " << principal << " y " << secundaria << endl;

        // Traspuesta: filas y columnas intercambiadas
        Matriz t = {};
        for (int i = 0; i < N; i++) {
            for (int j = 0; j < N; j++) {
                t[j][i] = m[i][j];
            }
        }
        mostrar(t);
        return 0;
    }
    ```

    ```plaintext title="Expected output"
      1  2  3
      4  5  6
      7  8  9
    Fila 0: 6
    Fila 1: 15
    Fila 2: 24
    Columna 0: 12
    Columna 1: 15
    Columna 2: 18
    Diagonales: 15 y 15
      1  4  7
      2  5  8
      3  6  9
    ```

Cuando el resultado de cada celda depende de sus vecinas, como en un filtro o una
convolución, hay que cuidar los bordes. Un _array_ de desplazamientos recorre las cuatro
direcciones y la guarda `fi >= 0 && fi < N && fj >= 0 && fj < N` ignora los vecinos que
caen fuera de la matriz.

Cuando casi todos los elementos son cero, guardar la matriz completa desperdicia
memoria. Una **matriz dispersa** (_sparse_) almacena solo los elementos no nulos como
una lista de términos con su fila, su columna y su valor, agrupados en una estructura
como se explica más adelante, de modo que la memoria crece con el número de elementos no
nulos y no con el tamaño de la matriz. Es la idea de los formatos dispersos de las
bibliotecas numéricas y de aprendizaje automático. Si los términos se generan
recorriendo la matriz por filas, quedan ordenados por su posición, y la suma de dos
matrices dispersas se reduce a una **mezcla** de dos listas ordenadas: dos índices
avanzan a la vez, se copia el término de posición menor y, si coinciden, se suman los
valores.

```cpp linenums="1"
// Cada elemento no nulo se guarda con sus coordenadas
struct Termino {
    int fila;
    int columna;
    int valor;
};

// La matriz dispersa es la lista de sus términos no nulos
vector<Termino> dispersa;
```

## Cadenas de caracteres

Una cadena es una secuencia de caracteres. En C++ conviven dos representaciones: los
_arrays_ de `char` heredados de C y la clase `std::string`.

### Cadenas de estilo C

Una cadena de estilo C es un _array_ de `char` terminado por el carácter nulo `'\0'`. Un
literal como `"Daniel"` ocupa siete posiciones: seis letras y el terminador. La
biblioteca `<cstring>` ofrece las operaciones.

| Función                   | Operación                                                            |
| ------------------------- | -------------------------------------------------------------------- |
| `strlen(s)`               | Número de caracteres antes de `'\0'`.                                |
| `strcpy(destino, origen)` | Copia el contenido, terminador incluido.                             |
| `strcat(destino, origen)` | Añade `origen` al final de `destino`.                                |
| `strcmp(a, b)`            | Negativo, cero o positivo según el orden alfabético de `a` y `b`.    |
| `atoi(s)`, `atof(s)`      | Convierte el texto a entero o a real, con la biblioteca `<cstdlib>`. |

???+ example "Funciones de cstring"

    El programa concatena, copia y compara cadenas. La función `strcat` exige que el
    destino tenga espacio suficiente.

    ```cpp linenums="1"
    #include <cstring>
    #include <iostream>

    using namespace std;

    int main() {
        // El compilador añade '\0' al final del literal
        char nombre[30] = "Daniel";
        char apellido[] = " Bazo";
        char manual[] = {'H', 'o', 'l', 'a', '\0'};

        // sizeof cuenta el espacio reservado y strlen los caracteres hasta '\0'
        cout << sizeof(manual) << " " << strlen(manual) << endl;
        cout << sizeof(nombre) << " " << strlen(nombre) << endl;

        // strcat concatena: nombre debe tener espacio de sobra para el resultado
        strcat(nombre, apellido);
        cout << nombre << endl;

        // strcpy copia el contenido completo, terminador incluido
        char copia[30];
        strcpy(copia, nombre);
        // Una cadena es un array: se puede modificar carácter a carácter
        copia[0] = 'B';
        cout << copia << " / " << nombre << endl;

        // strcmp devuelve un negativo, cero o positivo según el orden alfabético
        char primera[] = "becerro";
        char segunda[] = "zorro";
        if (strcmp(primera, segunda) < 0) {
            cout << primera << " va antes que " << segunda << endl;
        }
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    5 4
    30 6
    Daniel Bazo
    Baniel Bazo / Daniel Bazo
    becerro va antes que zorro
    ```

!!! danger "Desbordamiento de _buffer_"

    Las funciones de `<cstring>` no comprueban los tamaños. Copiar o concatenar más
    caracteres de los que caben escribe fuera del _array_, un fallo que ha sido origen
    de numerosas vulnerabilidades. Con `cin >> cadena` ocurre lo mismo si la palabra
    supera el tamaño reservado. En código nuevo se prefiere `std::string`.

### La clase `string`

El tipo `std::string`, de la biblioteca `<string>`, gestiona su propia memoria, crece
según haga falta y se comporta como un valor: se copia con `=`, se concatena con `+` y
se compara con `==` y `<` en orden lexicográfico. Acepta el acceso `s[i]`, la longitud
con `length()` y `size()`, la búsqueda con `find` y la extracción con
`substr(inicio, cantidad)`. La conversión entre texto y números usa `stoi`, `stod` y
`to_string`. La clasificación y el cambio de mayúsculas de un carácter proceden de
`<cctype>`.

| Función                    | Resultado                                   |
| -------------------------- | ------------------------------------------- |
| `isalpha(c)`, `isdigit(c)` | Si `c` es una letra o un dígito.            |
| `isalnum(c)`, `isspace(c)` | Si `c` es una letra o dígito, o un espacio. |
| `isupper(c)`, `islower(c)` | Si `c` es mayúscula o minúscula.            |
| `toupper(c)`, `tolower(c)` | El carácter en mayúscula o en minúscula.    |

???+ example "Operaciones con `string`"

    El programa busca, extrae, convierte y transforma una cadena.

    ```cpp linenums="1"
    #include <algorithm>
    #include <cctype>
    #include <iostream>
    #include <string>

    using namespace std;

    int main() {
        string nombre = "Daniel Bazo Correa";

        cout << nombre.length() << " caracteres, inicial " << nombre[0] << endl;
        // find devuelve la posición o string::npos si no hay coincidencia
        size_t pos = nombre.find("Bazo");
        if (pos != string::npos) {
            // substr(inicio, cantidad) extrae un fragmento
            cout << "Bazo empieza en " << pos << ": ";
            cout << nombre.substr(pos, 4) << endl;
        }

        // length cuenta bytes: la tilde de "Málaga" ocupa dos en UTF-8
        string ciudad = "Málaga";
        cout << ciudad.length() << endl;

        // + concatena y == y < comparan en orden lexicográfico
        string saludo = "Hola, " + nombre.substr(0, 6) + "!";
        cout << saludo << endl;
        cout << (string("becerro") < string("zorro")) << endl;

        // toupper actúa sobre un carácter y el bucle por rango lo aplica a todos
        string mayusculas = nombre;
        for (char &c : mayusculas) {
            c = static_cast<char>(toupper(static_cast<unsigned char>(c)));
        }
        cout << mayusculas << endl;

        // reverse invierte el rango indicado
        string invertida = nombre;
        reverse(invertida.begin(), invertida.end());
        cout << invertida << endl;

        // Conversión entre texto y números
        int entero = stoi("1234") + 1;
        double real = stod("2.5") * 2;
        cout << entero << " " << real << " " << to_string(entero * 2) << endl;
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    18 caracteres, inicial D
    Bazo empieza en 7: Bazo
    7
    Hola, Daniel!
    1
    DANIEL BAZO CORREA
    aerroC ozaB leinaD
    1235 5 2470
    ```

!!! note "Caracteres con tilde y UTF-8"

    En un archivo codificado en UTF-8, las letras con tilde y la `ñ` ocupan dos bytes.
    Como `length()` cuenta bytes, `"Málaga"` tiene longitud 7. Las funciones de
    `<cctype>` solo clasifican correctamente los caracteres ASCII, y su argumento debe
    convertirse a `unsigned char` para no invocar un comportamiento indefinido con los
    bytes superiores a 127.

### Recorrido y normalización de texto

Un palíndromo es un texto que se lee igual en ambos sentidos. Para comprobarlo en una
frase se filtran los caracteres que no son letras ni dígitos, se pasa todo a minúscula y
se compara con la versión invertida, obtenida con `std::reverse`. La inversión también
se puede hacer sin biblioteca, con dos índices que parten de los extremos, intercambian
sus caracteres y se acercan hasta cruzarse.

???+ example "Palíndromos de frase"

    El programa normaliza tres frases y las compara con su inversa.

    ```cpp linenums="1"
    #include <algorithm>
    #include <cctype>
    #include <iostream>
    #include <string>

    using namespace std;

    // Conserva solo letras y dígitos, en minúscula
    string normalizar(const string &frase) {
        string resultado;
        for (char c : frase) {
            unsigned char uc = static_cast<unsigned char>(c);
            if (isalnum(uc)) {
                resultado += static_cast<char>(tolower(uc));
            }
        }
        return resultado;
    }

    // Un texto es palíndromo si coincide con su inversión
    bool es_palindromo(const string &frase) {
        string limpia = normalizar(frase);
        string invertida = limpia;
        reverse(invertida.begin(), invertida.end());
        return limpia == invertida;
    }

    int main() {
        const string frases[] = {"Anita lava la tina",
                                 "Dabale arroz a la zorra el abad", "Hola mundo"};
        for (const string &frase : frases) {
            cout << frase << ": " << (es_palindromo(frase) ? "sí" : "no") << endl;
        }
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    Anita lava la tina: sí
    Dabale arroz a la zorra el abad: sí
    Hola mundo: no
    ```

!!! tip "Longitudes sin signo"

    El método `size()` devuelve un `size_t`, un entero sin signo. En una cadena vacía,
    `s.size() - 1` no vale `-1` sino un número enorme. Reescribir la condición
    `i < s.size() - 1` como `i + 1 < s.size()` evita ese problema.

## Estructuras

Una **estructura** (`struct`) agrupa bajo un solo nombre datos de tipos distintos, que
reciben el nombre de **campos** o miembros. Define un tipo nuevo, y cada variable de ese
tipo contiene su propia copia de todos los campos, a los que se accede con el operador
punto. Una estructura puede contener otras, y se inicializa con llaves siguiendo el
orden de sus campos. La asignación copia todos los campos. Para evitar esa copia en las
funciones, las estructuras se pasan por referencia, y por `const &` si son de solo
lectura.

???+ example "Estructuras anidadas"

    El programa define un empleado con una dirección, copia el registro y modifica la
    copia mediante una función con parámetro por referencia.

    ```cpp linenums="1"
    #include <iostream>
    #include <string>

    using namespace std;

    struct Direccion {
        string calle;
        string ciudad;
    };

    // Un struct puede contener a otro como campo
    struct Empleado {
        string nombre;
        double salario;
        Direccion direccion;
    };

    // const & evita copiar el struct completo
    void mostrar(const Empleado &e) {
        cout << e.nombre << " (" << e.salario << " euros) vive en ";
        cout << e.direccion.calle << ", " << e.direccion.ciudad << endl;
    }

    // Un parámetro por referencia permite modificar el struct original
    void subir_salario(Empleado &e, double porcentaje) {
        e.salario += e.salario * porcentaje / 100.0;
    }

    int main() {
        // Inicialización por llaves, en el orden de los campos
        Empleado ana = {"Ana", 1800.0, {"Calle Mayor 3", "Málaga"}};
        // La asignación copia todos los campos
        Empleado copia = ana;
        subir_salario(copia, 10.0);

        mostrar(ana);
        mostrar(copia);
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    Ana (1800 euros) vive en Calle Mayor 3, Málaga
    Ana (1980 euros) vive en Calle Mayor 3, Málaga
    ```

Los _arrays_ de estructuras permiten almacenar colecciones de registros. Ordenarlos con
`std::sort` exige indicar el criterio, que se expresa como una función de comparación o,
más habitualmente, como una **expresión lambda**: una función anónima que se escribe en
el punto de uso con la sintaxis `[](parámetros) { return condición; }`. Devuelve `true`
cuando el primer argumento debe colocarse antes que el segundo.

???+ example "Ordenar registros por un campo"

    El programa ordena una colección de discos por precio creciente.

    ```cpp linenums="1"
    #include <algorithm>
    #include <array>
    #include <iostream>
    #include <string>

    using namespace std;

    struct Disco {
        string titulo;
        int canciones;
        double precio;
    };

    int main() {
        array<Disco, 3> coleccion = {
            {{"Aurora", 10, 12.5}, {"Brisa", 8, 9.9}, {"Cima", 12, 15.0}}};

        // La lambda indica el criterio: precio creciente
        sort(coleccion.begin(), coleccion.end(),
             [](const Disco &a, const Disco &b) { return a.precio < b.precio; });
        for (const Disco &d : coleccion) {
            cout << d.titulo << " " << d.precio << endl;
        }
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    Brisa 9.9
    Aurora 12.5
    Cima 15
    ```

### Tamaño lógico

Con frecuencia el número de datos válidos no se conoce hasta ejecutar el programa, pero
el _array_ tiene un tamaño fijo, la **capacidad**. La solución consiste en llevar junto
al _array_ un contador `n` con el **tamaño lógico**, es decir, el número de posiciones
ocupadas, de modo que los recorridos llegan hasta `n` y no hasta la capacidad. Ambos se
agrupan en un `struct` para que viajen juntos a las funciones. Un `std::vector` lleva ya
ese contador (`size()`), así que el patrón interesa sobre todo con capacidad fija. Las
operaciones habituales son insertar, buscar por clave y borrar.

- **Insertar**: Comprueba que quede espacio y que la clave no exista y, entonces,
  escribe en la posición `n` e incrementa el contador. Devuelve un `bool` que indica el
  éxito.
- **Buscar**: Recorre con `while (i < n && lista[i].clave != clave)` y comprueba después
  si `i < n`, para distinguir el hallazgo del agotamiento de los elementos.
- **Borrar**: Busca la clave y, si existe, copia el último elemento ocupado sobre su
  posición y decrementa `n`.

???+ example "Nómina de vendedores"

    El programa gestiona una lista de capacidad 3. La tercera alta falla por duplicado y
    la quinta por falta de espacio, y el borrado mueve el último vendedor al hueco.

    ```cpp linenums="1"
    #include <array>
    #include <iostream>
    #include <string>

    using namespace std;

    constexpr int MAX_VENDEDORES = 3;

    struct Vendedor {
        string dni;
        double ventas;
    };

    // Lista con tamaño lógico: solo los n primeros elementos están ocupados
    struct Nomina {
        array<Vendedor, MAX_VENDEDORES> vendedor;
        int n = 0;
    };

    // Devuelve la posición del vendedor con ese DNI (documento de identidad) o -1
    int buscar(const Nomina &p, const string &dni) {
        int i = 0;
        while (i < p.n && p.vendedor[i].dni != dni) {
            i++;
        }
        return i < p.n ? i : -1;
    }

    // Añade al final y devuelve false si no queda espacio o el DNI ya existe
    bool insertar(Nomina &p, const Vendedor &v) {
        // Con n == MAX no hay hueco: escribir en p.vendedor[n] sería un error
        if (p.n == MAX_VENDEDORES || buscar(p, v.dni) != -1) {
            return false;
        }
        p.vendedor[p.n] = v;
        p.n++;
        return true;
    }

    // Elimina copiando el último elemento sobre el hueco (no conserva el orden)
    bool borrar(Nomina &p, const string &dni) {
        int pos = buscar(p, dni);
        if (pos == -1) {
            return false;
        }
        // El último elemento ocupado está en n - 1, no en n
        p.vendedor[pos] = p.vendedor[p.n - 1];
        p.n--;
        return true;
    }

    int main() {
        Nomina p;
        cout << insertar(p, {"111A", 5200.0}) << insertar(p, {"222B", 12000.0});
        cout << insertar(p, {"111A", 1.0}) << insertar(p, {"333C", 800.0});
        cout << insertar(p, {"444D", 50.0}) << endl;

        cout << "Borrado de 111A: " << borrar(p, "111A") << endl;
        for (int i = 0; i < p.n; i++) {
            cout << p.vendedor[i].dni << " " << p.vendedor[i].ventas << endl;
        }
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    11010
    Borrado de 111A: 1
    333C 800
    222B 12000
    ```

!!! warning "Límites al insertar y al borrar"

    Dos fallos son frecuentes en estas listas. Insertar con la condición `n <= MAX`
    permite escribir una posición más allá de la capacidad. Y al borrar, el último
    elemento está en `n - 1`, no en `n`, que es el primer hueco libre. Antes de dividir
    por el número de elementos, por ejemplo al calcular una media, se comprueba también
    que no sea cero.

Para ordenar solo la parte ocupada se acota el rango con el tamaño lógico, como en
`sort(p.vendedor.begin(), p.vendedor.begin() + p.n, criterio)`.

Una estructura que contiene una propiedad como «libre» u «ocupado» no debe codificarla
con un `bool` cuyo significado dependa de una convención. Los enumerados resuelven ese
problema y se presentan a continuación. Las funciones que operan sobre una estructura se
incorporan a ella en el capítulo de
[programación orientada a objetos](section_4_oop.md), mediante las clases.

## Enumerados

Un **enumerado** define un tipo con un conjunto finito de valores con nombre. Reemplaza
a los números mágicos y a los `bool` ambiguos, y el compilador comprueba que no se
mezclen con otros tipos. La forma moderna es `enum class`, cuyos valores se escriben
`Tipo::Valor`, no se convierten implícitamente a enteros y no chocan con otros nombres.
Cuando hace falta el número asociado, que por omisión es la posición empezando en 0, se
convierte de forma explícita con `static_cast<int>`.

???+ example "Días de la semana"

    El programa define un enumerado y lo usa con `switch` sin `default`, de modo que
    `g++` avisa si se olvida un valor. Además calcula el día siguiente con aritmética
    modular.

    ```cpp linenums="1"
    #include <iostream>
    #include <string>

    using namespace std;

    // enum class: los valores pertenecen al tipo y no se convierten solos a int
    enum class Dia { Lunes, Martes, Miercoles, Jueves, Viernes, Sabado, Domingo };

    // Sin default, g++ avisa con -Wall si se olvida algún enumerador
    string nombre(Dia d) {
        switch (d) {
        case Dia::Lunes: return "lunes";
        case Dia::Martes: return "martes";
        case Dia::Miercoles: return "miércoles";
        case Dia::Jueves: return "jueves";
        case Dia::Viernes: return "viernes";
        case Dia::Sabado: return "sábado";
        case Dia::Domingo: return "domingo";
        }
        return "desconocido";
    }

    bool es_laborable(Dia d) {
        return d != Dia::Sabado && d != Dia::Domingo;
    }

    // La conversión a número es explícita y el módulo cierra el ciclo semanal
    Dia siguiente(Dia d) {
        return static_cast<Dia>((static_cast<int>(d) + 1) % 7);
    }

    int main() {
        Dia hoy = Dia::Viernes;
        for (int k = 0; k < 4; k++) {
            cout << nombre(hoy);
            cout << (es_laborable(hoy) ? ": laborable" : ": festivo") << endl;
            hoy = siguiente(hoy);
        }
        cout << "Índice de domingo: " << static_cast<int>(Dia::Domingo) << endl;
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    viernes: laborable
    sábado: festivo
    domingo: festivo
    lunes: laborable
    Índice de domingo: 6
    ```

## Números aleatorios

La biblioteca `<random>` separa el **generador**, que produce bits pseudoaleatorios, de
la **distribución**, que los transforma en el rango deseado. Con una semilla fija, la
secuencia es reproducible, lo que facilita las pruebas. La fórmula heredada de C,
`rand() % (maximo - minimo + 1) + minimo`, produce un sesgo ligero y no se recomienda en
código nuevo, aunque sigue siendo común con `srand(time(NULL))` para sembrar según la
hora. El método de Monte Carlo estima $\pi$ lanzando puntos al azar sobre el cuadrado
unidad: la fracción que cae dentro del cuarto de círculo ($x^{2} + y^{2} \le 1$) tiende
a $\pi / 4$.

???+ example "Aproximación de pi y tiradas de un dado"

    El programa estima $\pi$ con un millón de puntos y simula cinco tiradas. Los valores
    exactos dependen de la implementación de la biblioteca estándar.

    ```cpp linenums="1"
    #include <iostream>
    #include <random>

    using namespace std;

    int main() {
        // Semilla fija: la secuencia es reproducible entre ejecuciones
        mt19937 generador(12345);
        uniform_real_distribution<double> coordenada(0.0, 1.0);
        uniform_int_distribution<int> dado(1, 6);

        // Un punto al azar del cuadrado unidad cae en el cuarto de círculo con
        // probabilidad pi / 4
        const int puntos = 1000000;
        int dentro = 0;
        for (int i = 0; i < puntos; i++) {
            double x = coordenada(generador);
            double y = coordenada(generador);
            if (x * x + y * y <= 1.0) {
                dentro++;
            }
        }
        cout << "pi aproximado: " << 4.0 * dentro / puntos << endl;

        // Cinco tiradas de un dado: enteros uniformes en [1, 6]
        for (int i = 0; i < 5; i++) {
            cout << dado(generador) << " ";
        }
        cout << endl;
        return 0;
    }
    ```

    ```plaintext title="Expected output"
    pi aproximado: 3.14216
    4 4 4 6 2
    ```

## Errores frecuentes

Las advertencias de cada sección cubren los fallos más comunes, y `-Wall -Wextra`
detecta muchos de ellos. La tabla recoge los que no se han explicado antes.

| Error                                                | Consecuencia y corrección                                   |
| ---------------------------------------------------- | ----------------------------------------------------------- |
| Raíces o medias guardadas en un `int`                | Truncamiento. Se usa `double`.                              |
| `atan(b / a)` para obtener un ángulo                 | Se pierde el cuadrante. Se usa `atan2(b, a)`.               |
| Media o cociente de una lista vacía                  | División por cero. Se comprueba el tamaño antes de dividir. |
| Funciones de `<cstring>` sobre un `std::string`      | No compila. Se usan sus métodos y operadores.               |
| Función propia con el nombre de una de la biblioteca | Colisión con `sqrt` o `pow`. Se elige otro nombre.          |

## Cierre

Los programas de este capítulo leen del teclado, escriben en pantalla y pierden sus
datos al terminar. El siguiente capítulo, dedicado a los [archivos](section_3_files.md),
extiende los mismos flujos de entrada y salida para leer y escribir datos persistentes
en disco, y aprovecha las cadenas y las estructuras presentadas aquí. Después, el
capítulo de [programación orientada a objetos](section_4_oop.md) incorpora a las
estructuras sus operaciones mediante clases, y el de [memoria](section_5_memory.md)
trata los punteros y la memoria dinámica.
