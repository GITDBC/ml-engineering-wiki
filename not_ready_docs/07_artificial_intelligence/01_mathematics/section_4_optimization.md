---
icon: lucide/mountain
authors: Daniel Bazo Correa
description:
    Fundamentos de optimización para el entrenamiento de modelos, desde la aproximación
    local de Taylor hasta la clasificación de puntos críticos con la Hessiana y los
    multiplicadores de Lagrange.
title: Optimización
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Entrenar un modelo de aprendizaje automático equivale a resolver un problema de
optimización: encontrar los parámetros que hacen mínima una función de pérdida. Este
capítulo reúne el cálculo que justifica cómo se resuelve ese problema. Parte de la
aproximación local de una función mediante su polinomio de Taylor, que explica por qué
funcionan el descenso del gradiente y el método de Newton, estudia la derivada
direccional y la dirección de máximo crecimiento de un campo escalar, clasifica los
puntos críticos mediante la Hessiana y termina con los multiplicadores de Lagrange para
la optimización con restricciones. Da por conocidos el gradiente, la regla de la cadena
y la Hessiana presentados en [cálculo vectorial](section_3_vector_calculus.md), así como
los autovalores y las matrices definidas positivas de
[fundamentos matemáticos](section_2_deep_learning_math.md).

## Introducción

Un modelo con parámetros $\boldsymbol{\theta} \in \mathbb{R}^{n}$ define una **función
de pérdida** $L: \mathbb{R}^{n} \to \mathbb{R}$, que mide el error cometido sobre los
datos de entrenamiento. El objetivo del entrenamiento es encontrar un minimizador:

$$
\boldsymbol{\theta}^{\ast} = \arg\min_{\boldsymbol{\theta} \in \mathbb{R}^{n}}
L(\boldsymbol{\theta})
$$

donde $\boldsymbol{\theta}^{\ast}$ es el vector de parámetros con menor pérdida. Salvo
en casos muy concretos, como la regresión lineal por mínimos cuadrados, este problema no
tiene una solución cerrada. Se resuelve de forma iterativa: partiendo de unos parámetros
iniciales, cada paso los modifica para reducir la pérdida utilizando solo información
local, es decir, el valor de $L$ y de sus derivadas en el punto actual.

Las herramientas de este capítulo exigen que la pérdida sea continua y derivable, al
menos dos veces cuando interviene la Hessiana. Intuitivamente, una función es
**continua** cuando pequeños cambios en la entrada producen pequeños cambios en la
salida, y es **derivable** cuando además admite una recta tangente en cada punto. Las
funciones habituales en aprendizaje profundo cumplen estas condiciones, con excepciones
puntuales como la ReLU en el origen, que en la práctica se resuelven asignando un valor
convencional a la derivada.

La formulación práctica del algoritmo, con su regla de actualización, el papel de la
tasa de aprendizaje, el descenso estocástico por lotes y optimizadores como Momentum o
Adam, se desarrolla en el capítulo de
[modelos lineales](../03_deep_learning/section_2_linear_models.md). La pérdida de
convexidad que introducen las capas ocultas se trata en
[redes neuronales](../03_deep_learning/section_3_neural_networks.md). Este capítulo
aporta la justificación matemática que esos capítulos dan por supuesta.

## Aproximación local de una función

La idea central de la optimización basada en derivadas es que una función complicada se
comporta, cerca de un punto, como un polinomio sencillo. Un optimizador no conoce la
forma global de la pérdida, pero sí puede construir ese polinomio en el punto actual y
decidir hacia dónde moverse a partir de él.

### Aproximación lineal y diferencial

La recta tangente a $f$ en un punto $a$ proporciona su **aproximación lineal**. Al
desplazarse a $a + h$, el valor de la función se estima como:

$$
f(a + h) \approx f(a) + f'(a)\, h
$$

donde $f'(a)$ es la pendiente en $a$ y $h$ el desplazamiento. El error cometido, $E(h) =
f(a + h) - (f(a) + f'(a)h)$, tiende a cero más deprisa que $h$, de modo que la
aproximación es tanto mejor cuanto más pequeño es el paso.

La **diferencial** formaliza esta idea. Para un incremento $dx$ de la variable, la
variación lineal de la función es $dy = f'(a)\, dx$. Con $f(x) = 2x^{3} - 5x^{2}$ se
tiene $f'(x) = 6x^{2} - 10x$ y, en $x = 1$, $f'(1) = -4$, así que $dy = -4\,dx$. Un
pequeño incremento de $x$ produce, aproximadamente, una disminución cuatro veces mayor
en $y$. Esta lectura es la que hace un optimizador: el signo de la derivada indica hacia
dónde baja la función y su magnitud, cuánto baja por unidad de desplazamiento.

En varias variables la pendiente se sustituye por el gradiente. Para la pérdida $L$ en
los parámetros $\boldsymbol{\theta}$ y un desplazamiento $\Delta\boldsymbol{\theta}$:

$$
L(\boldsymbol{\theta} + \Delta\boldsymbol{\theta}) \approx L(\boldsymbol{\theta}) +
\nabla L(\boldsymbol{\theta})^{\top} \Delta\boldsymbol{\theta}
$$

donde $\nabla L(\boldsymbol{\theta})$ se escribe aquí como vector columna, de modo que
el producto $\nabla L(\boldsymbol{\theta})^{\top} \Delta\boldsymbol{\theta}$ es el
producto escalar entre el gradiente y el desplazamiento. Esta expresión es el punto de
partida del descenso del gradiente.

### Polinomio de Taylor de segundo orden

La aproximación lineal ignora la curvatura. El **polinomio de Taylor** de segundo orden
de $f$ centrado en $a$ la incorpora a través de la derivada segunda:

$$
f(a + h) \approx f(a) + f'(a)\, h + \frac{f''(a)}{2}\, h^{2}
$$

El polinomio coincide con $f$ en $a$ en valor, pendiente y curvatura. El **resto de
Lagrange** cuantifica el error que se comete:

$$
f(a + h) - \left( f(a) + f'(a)\, h + \frac{f''(a)}{2}\, h^{2} \right) =
\frac{f'''(c)}{3!}\, h^{3}
$$

donde $c$ es un punto desconocido entre $a$ y $a + h$. Aunque $c$ no se conoce, acotando
$\lvert f''' \rvert$ en ese intervalo se obtiene una cota del error, que decrece como
$h^{3}$ frente al $h^{2}$ de la aproximación lineal.

???+ example "Aproximación de $\sqrt{101}$ con uno y dos términos"

    Se toma $f(x) = \sqrt{x}$ en el punto conocido $a = 100$ con $h = 1$. Las derivadas
    son $f'(x) = 1/(2\sqrt{x})$ y $f''(x) = -1/(4x^{3/2})$, que en $a = 100$ valen
    $1/20$ y $-1/4000$. La aproximación lineal da $10 + 1/20 = 10.05$, y el término
    cuadrático resta $1/8000$:

    $$
    \sqrt{101} \approx 10 + \frac{1}{20} - \frac{1}{8000} = 10.049875
    $$

    El código compara ambas aproximaciones con el valor exacto:

    ```python linenums="1"
    import math


    def aproximaciones(a: float, h: float) -> tuple[float, float]:
        """Aproxima la raíz cuadrada en a + h con Taylor de orden uno y dos.

        Args:
            a: Punto conocido en el que se centra el desarrollo.
            h: Desplazamiento respecto al punto conocido.

        Returns:
            Las aproximaciones lineal y cuadrática de la raíz de a + h.
        """
        f0 = math.sqrt(a)
        f1 = 1 / (2 * math.sqrt(a))
        f2 = -1 / (4 * a**1.5)
        lineal = f0 + f1 * h
        cuadratica = lineal + f2 / 2 * h**2
        return lineal, cuadratica


    exacto = math.sqrt(101)
    lineal, cuadratica = aproximaciones(100.0, 1.0)
    print(f"Exacto     = {exacto:.8f}")
    print(f"Orden uno  = {lineal:.8f}  error {abs(exacto - lineal):.1e}")
    print(f"Orden dos  = {cuadratica:.8f}  error {abs(exacto - cuadratica):.1e}")
    ```

    ```plaintext title="Expected output"
    Exacto     = 10.04987562
    Orden uno  = 10.05000000  error 1.2e-04
    Orden dos  = 10.04987500  error 6.2e-07
    ```

    Añadir la curvatura reduce el error en unas doscientas veces con el mismo paso.

En varias variables la derivada segunda se sustituye por la **Hessiana**
$\mathbf{H}(\boldsymbol{\theta}) = \nabla^{2} L(\boldsymbol{\theta})$, la matriz de
derivadas parciales segundas. El desarrollo de segundo orden de la pérdida es:

$$
L(\boldsymbol{\theta} + \Delta\boldsymbol{\theta}) \approx L(\boldsymbol{\theta}) +
\nabla L(\boldsymbol{\theta})^{\top} \Delta\boldsymbol{\theta} +
\frac{1}{2}\, \Delta\boldsymbol{\theta}^{\top}
\mathbf{H}(\boldsymbol{\theta})\, \Delta\boldsymbol{\theta}
$$

El término cuadrático $\Delta\boldsymbol{\theta}^{\top} \mathbf{H}\,
\Delta\boldsymbol{\theta}$ mide la curvatura de la pérdida en la dirección del paso.
Cuando las derivadas segundas son continuas, el **teorema de Schwarz** garantiza que el
orden de derivación no importa, $\partial^{2} L / \partial \theta_i \partial \theta_j =
\partial^{2} L / \partial \theta_j \partial \theta_i$, por lo que la Hessiana es
simétrica y sus autovalores son reales.

### Por qué funciona el descenso del gradiente

El **descenso del gradiente** actualiza los parámetros con la regla
$\boldsymbol{\theta}_{t+1} = \boldsymbol{\theta}_t - \eta\, \nabla
L(\boldsymbol{\theta}_t)$, donde $\eta > 0$ es la tasa de aprendizaje. Sustituyendo el
paso $\Delta\boldsymbol{\theta} = -\eta\, \mathbf{g}$, con $\mathbf{g} = \nabla
L(\boldsymbol{\theta}_t)$, en la aproximación lineal:

$$
L(\boldsymbol{\theta}_t - \eta\, \mathbf{g}) \approx
L(\boldsymbol{\theta}_t) - \eta\, \Vert \mathbf{g}
\Vert^{2}
$$

El término $-\eta \Vert \mathbf{g} \Vert^{2}$ es negativo siempre que el gradiente no se
anule, de modo que a primer orden la pérdida disminuye. Sin embargo, la aproximación
lineal no dice nada sobre el tamaño del paso. El desarrollo de segundo orden sí lo hace:

$$
L(\boldsymbol{\theta}_t - \eta\, \mathbf{g}) \approx
L(\boldsymbol{\theta}_t) - \eta\, \Vert \mathbf{g}
\Vert^{2} + \frac{\eta^{2}}{2}\, \mathbf{g}^{\top} \mathbf{H}\, \mathbf{g}
$$

El último término crece con $\eta^{2}$ y, si la curvatura en la dirección del gradiente
es positiva, acaba compensando la disminución lineal. La pérdida baja solo mientras
$\eta < 2 \Vert \mathbf{g} \Vert^{2} / (\mathbf{g}^{\top} \mathbf{H}\, \mathbf{g})$.
Como $\mathbf{g}^{\top} \mathbf{H}\, \mathbf{g} \leq \lambda_{\max} \Vert \mathbf{g}
\Vert^{2}$, siendo $\lambda_{\max}$ el mayor autovalor de la Hessiana, una tasa de
aprendizaje $\eta < 2 / \lambda_{\max}$ garantiza el descenso en cualquier dirección.
Esta es la explicación de por qué un paso demasiado grande hace divergir el
entrenamiento: la dirección más curvada de la pérdida limita la tasa de aprendizaje de
todas las demás.

### Método de Newton

Si en lugar de quedarse con la aproximación lineal se minimiza directamente la
aproximación cuadrática, se obtiene el **método de Newton**. Derivando el desarrollo de
segundo orden respecto a $\Delta\boldsymbol{\theta}$ e igualando a cero:

$$
\nabla L(\boldsymbol{\theta}) + \mathbf{H}(\boldsymbol{\theta})\, \Delta\boldsymbol{\theta} = \mathbf{0}
\quad\Rightarrow\quad
\Delta\boldsymbol{\theta} = -\mathbf{H}(\boldsymbol{\theta})^{-1}
\nabla L(\boldsymbol{\theta})
$$

El paso de Newton corrige el gradiente con la inversa de la Hessiana: avanza mucho en
las direcciones de poca curvatura y poco en las de mucha curvatura, y no necesita tasa
de aprendizaje. Sobre una pérdida cuadrática alcanza el óptimo en un solo paso. Equivale
a aplicar el método de Newton-Raphson para la búsqueda de raíces, descrito en
[cálculo numérico](section_5_numerical_computing.md), a la ecuación $\nabla
L(\boldsymbol{\theta}) = \mathbf{0}$.

Su coste explica por qué no se usa directamente en aprendizaje profundo. Con $n$
parámetros, la Hessiana tiene $n^{2}$ entradas y resolver el sistema cuesta del orden de
$n^{3}$ operaciones, inviable con millones de parámetros. Además, si la Hessiana no es
definida positiva, el paso de Newton puede dirigirse hacia un máximo o un punto de
silla. Los métodos cuasi-Newton como L-BFGS aproximan la inversa de la Hessiana a partir
de los gradientes sucesivos. Optimizadores como Adam, que reescalan cada parámetro con
la media de sus gradientes al cuadrado, se interpretan a menudo como una aproximación
diagonal y económica de esa misma información de curvatura, aunque no calculan derivadas
segundas.

???+ example "Descenso del gradiente frente a Newton en una pérdida cuadrática"

    Se minimiza $L(\boldsymbol{\theta}) = \frac{1}{2} \boldsymbol{\theta}^{\top}
    \mathbf{A}\, \boldsymbol{\theta} - \mathbf{b}^{\top} \boldsymbol{\theta}$, cuya
    Hessiana es la matriz constante $\mathbf{A}$, con curvaturas $1$ y $10$ en cada eje.
    La cota teórica es $\eta < 2/10 = 0.2$:

    ```python linenums="1"
    import numpy as np

    # Pérdida cuadrática con curvaturas muy distintas en cada eje
    A = np.array([[1.0, 0.0], [0.0, 10.0]])
    b = np.array([1.0, 1.0])
    theta_opt = np.linalg.solve(A, b)


    def gradiente(theta: np.ndarray) -> np.ndarray:
        """Calcula el gradiente de la pérdida cuadrática.

        Args:
            theta: Vector de parámetros.

        Returns:
            El gradiente A θ - b evaluado en theta.
        """
        return A @ theta - b


    def descenso(theta: np.ndarray, eta: float, tol: float = 1e-6) -> str:
        """Aplica descenso del gradiente hasta alcanzar el óptimo.

        Args:
            theta: Punto inicial.
            eta: Tasa de aprendizaje.
            tol: Distancia al óptimo con la que se detiene.

        Returns:
            El número de iteraciones realizadas o el aviso de divergencia.
        """
        for paso in range(1, 10_000):
            theta = theta - eta * gradiente(theta)
            if not np.all(np.isfinite(theta)) or np.linalg.norm(theta) > 1e6:
                return "diverge"
            if np.linalg.norm(theta - theta_opt) < tol:
                return f"{paso} iteraciones"
        return "sin converger"


    theta0 = np.array([5.0, 5.0])
    autovalores = np.linalg.eigvalsh(A)
    limite = 2 / autovalores.max()
    print(f"Autovalores de H: {autovalores}, límite 2/λmax = {limite:.2f}")
    for eta in (0.05, 0.18, 0.21):
        print(f"Descenso con η = {eta}: {descenso(theta0, eta)}")

    # Newton: un único paso θ - H⁻¹∇L alcanza el óptimo de una cuadrática
    theta_newton = theta0 - np.linalg.solve(A, gradiente(theta0))
    print(f"Newton, un paso: {theta_newton}, óptimo {theta_opt}")
    ```

    ```plaintext title="Expected output"
    Autovalores de H: [ 1. 10.], límite 2/λmax = 0.20
    Descenso con η = 0.05: 297 iteraciones
    Descenso con η = 0.18: 77 iteraciones
    Descenso con η = 0.21: diverge
    Newton, un paso: [1.  0.1], óptimo [1.  0.1]
    ```

    Con $\eta = 0.21$, por encima de la cota, el descenso diverge. Por debajo converge,
    pero el eje de curvatura $1$ avanza despacio porque la tasa de aprendizaje queda
    limitada por el eje de curvatura $10$. Newton, que reescala cada dirección por su
    curvatura, llega al óptimo en un paso.

## Campos escalares

Un **campo escalar** es una función $f: \mathbb{R}^{n} \to \mathbb{R}$ que asigna un
número a cada punto del espacio. La función de pérdida de un modelo respecto a sus
parámetros es el campo escalar por excelencia del aprendizaje automático, y su gráfica
se denomina a menudo **paisaje de pérdida**.

### Derivada direccional y máximo crecimiento

La razón de cambio de $f$ en una dirección arbitraria se mide con la **derivada
direccional**, que es el producto escalar del gradiente por un vector unitario
$\mathbf{u}$:

$$
D_{\mathbf{u}} f = \nabla f^{\top} \mathbf{u}, \qquad \mathbf{u} =
\frac{\mathbf{v}}{\Vert \mathbf{v} \Vert}
$$

donde $\mathbf{v}$ es cualquier vector no nulo en la dirección de interés. El resultado
es un número que indica cuánto crece la función por unidad de desplazamiento en esa
dirección. Escribiendo el producto escalar en términos del ángulo $\alpha$ entre $\nabla
f$ y $\mathbf{u}$:

$$
D_{\mathbf{u}} f = \Vert \nabla f \Vert \, \Vert \mathbf{u} \Vert \cos\alpha = \Vert
\nabla f \Vert \cos\alpha
$$

Esta expresión contiene tres resultados que el entrenamiento aprovecha directamente:

- **Máximo crecimiento**: El valor es máximo cuando $\alpha = 0$, es decir, cuando
  $\mathbf{u}$ apunta en la dirección del gradiente, y la tasa de crecimiento es
  entonces $\Vert \nabla f \Vert$.
- **Máximo decrecimiento**: El valor es mínimo cuando $\alpha = \pi$, en la dirección
  $-\nabla f$. Por eso el descenso del gradiente se mueve en sentido opuesto al
  gradiente: entre todas las direcciones de paso unitario, es la que más reduce la
  pérdida a primer orden.
- **Cambio nulo**: El valor se anula cuando $\mathbf{u}$ es perpendicular al gradiente.
  Son las direcciones tangentes a la **curva de nivel**, el conjunto de puntos donde $f$
  toma un valor constante. El gradiente es, por tanto, perpendicular a las curvas de
  nivel.

???+ example "Direcciones en las que se anula la derivada direccional"

    Para $f(x,y) = \frac{x^{2} - y^{2}}{x^{2} + y^{2}}$ en $P_0 = (1, 1)$, las derivadas
    parciales son:

    $$
    \frac{\partial f}{\partial x} = \frac{4xy^{2}}{(x^{2} + y^{2})^{2}} \qquad
    \frac{\partial f}{\partial y} = \frac{-4x^{2}y}{(x^{2} + y^{2})^{2}}
    $$

    En el punto, $\nabla f(1,1) = (1, -1)$. La dirección de máximo crecimiento es
    $(1, -1)/\sqrt{2}$, con tasa $\Vert \nabla f \Vert = \sqrt{2}$. Los vectores
    perpendiculares a $(1, -1)$ son los múltiplos de $(1, 1)$, que al normalizar dan las
    dos direcciones en las que la función no cambia a primer orden:

    $$
    \mathbf{u}_1 = \left(\frac{1}{\sqrt{2}}, \frac{1}{\sqrt{2}}\right) \qquad
    \mathbf{u}_2 = \left(-\frac{1}{\sqrt{2}}, -\frac{1}{\sqrt{2}}\right)
    $$

    Ambas coinciden con la recta $y = x$, sobre la que $f$ vale $0$ en todos sus puntos,
    es decir, con la curva de nivel que pasa por $P_0$.

### Puntos críticos y clasificación con la Hessiana

Un **punto crítico** de $f$ es aquel en el que se anula el gradiente, $\nabla
f(\mathbf{x}^{\ast}) = \mathbf{0}$. Es la condición necesaria de extremo cuando la
función es derivable, y es también la condición en la que el descenso del gradiente se
detiene, ya que el paso $-\eta \nabla f$ se hace nulo. Que el entrenamiento se detenga
no garantiza, sin embargo, que se haya llegado a un mínimo.

En un punto crítico el término lineal del desarrollo de Taylor desaparece, y el
comportamiento local queda determinado por el término cuadrático:

$$
f(\mathbf{x}^{\ast} + \Delta\mathbf{x}) \approx f(\mathbf{x}^{\ast}) + \frac{1}{2}\,
\Delta\mathbf{x}^{\top} \mathbf{H}(\mathbf{x}^{\ast})\, \Delta\mathbf{x}
$$

El signo de esa forma cuadrática en todas las direcciones decide el tipo de punto. Como
la Hessiana es simétrica, ese signo se lee en sus autovalores, que son las curvaturas a
lo largo de sus autovectores. La clasificación de formas cuadráticas, con el criterio de
los menores principales, se desarrolla en
[fundamentos matemáticos](section_2_deep_learning_math.md).

| Hessiana en el punto crítico | Autovalores                        | Tipo de punto          |
| ---------------------------- | ---------------------------------- | ---------------------- |
| Definida positiva            | Todos positivos.                   | Mínimo local.          |
| Definida negativa            | Todos negativos.                   | Máximo local.          |
| Indefinida                   | Positivos y negativos.             | Punto de silla.        |
| Semidefinida, no definida    | Algún cero y el resto de un signo. | El criterio no decide. |

En el caso semidefinido hay direcciones de curvatura nula, y el tipo de punto depende de
los términos de orden superior. Las funciones $x^{4} + y^{2}$ y $x^{3} + y^{2}$ tienen
la misma Hessiana en el origen, con autovalores $0$ y $2$, pero la primera tiene allí un
mínimo y la segunda no, porque $x^{3}$ toma valores negativos para $x < 0$.

En dos variables, el producto de los autovalores es el determinante de la Hessiana, lo
que da un criterio que evita calcularlos:

$$
\det \mathbf{H} = \frac{\partial^{2} f}{\partial x^{2}} \frac{\partial^{2}
f}{\partial y^{2}} - \left( \frac{\partial^{2} f}{\partial x \partial y} \right)^{2}
$$

Si $\det \mathbf{H} < 0$, los autovalores tienen signos opuestos y el punto es de silla.
Si $\det \mathbf{H} > 0$, tienen el mismo signo, que coincide con el de $\partial^{2} f
/ \partial x^{2}$: mínimo si es positivo, máximo si es negativo. Si $\det \mathbf{H} =
0$, el criterio no decide.

???+ example "Clasificación de los puntos críticos de un campo escalar"

    La función $f(x,y) = x^{3} - 3x + y^{3} - 3y$ tiene gradiente $(3x^{2} - 3,\,
    3y^{2} - 3)$, que se anula en los cuatro puntos $(\pm 1, \pm 1)$. Su Hessiana es la
    matriz diagonal de entradas $6x$ y $6y$. El código calcula los puntos críticos y los
    clasifica con los autovalores:

    ```python linenums="1"
    import sympy as sp

    x, y = sp.symbols("x y", real=True)
    f = x**3 - 3 * x + y**3 - 3 * y


    def clasificar(autovalores: list[sp.Expr]) -> str:
        """Clasifica un punto crítico a partir de los autovalores de la Hessiana.

        Args:
            autovalores: Autovalores de la Hessiana evaluada en el punto.

        Returns:
            El tipo de punto crítico o la indicación de que el criterio no decide.
        """
        if all(v > 0 for v in autovalores):
            return "mínimo local"
        if all(v < 0 for v in autovalores):
            return "máximo local"
        if any(v > 0 for v in autovalores) and any(v < 0 for v in autovalores):
            return "punto de silla"
        return "no decide"


    gradiente = [sp.diff(f, v) for v in (x, y)]
    hessiana = sp.hessian(f, (x, y))
    for punto in sp.solve(gradiente, (x, y), dict=True):
        h = hessiana.subs(punto)
        autovalores = sorted(h.eigenvals(multiple=True))
        coordenadas = f"({str(punto[x]):>2}, {str(punto[y]):>2})"
        print(f"{coordenadas}  autovalores {autovalores}  {clasificar(autovalores)}")
    ```

    ```plaintext title="Expected output"
    (-1, -1)  autovalores [-6, -6]  máximo local
    (-1,  1)  autovalores [-6, 6]  punto de silla
    ( 1, -1)  autovalores [-6, 6]  punto de silla
    ( 1,  1)  autovalores [6, 6]  mínimo local
    ```

    Un descenso del gradiente que partiese exactamente de uno de los puntos de silla no
    se movería, aunque el punto no sea un mínimo.

### Convexidad y paisaje de pérdida

Una función cuya Hessiana es semidefinida positiva en todo su dominio es **convexa**. En
ella cualquier punto crítico es un mínimo global, y el descenso del gradiente con una
tasa de aprendizaje adecuada converge hacia un mínimo global, si existe, desde cualquier
inicialización. La regresión lineal con pérdida cuadrática y la regresión logística son
problemas convexos.

Las redes neuronales con capas ocultas no lo son. Su paisaje de pérdida presenta
múltiples mínimos locales y, sobre todo, abundantes puntos de silla. En un espacio de
millones de dimensiones cabe esperar que, en un punto crítico, la Hessiana tenga
autovalores de ambos signos antes que todos del mismo. Además, muchas direcciones son
casi planas, con autovalores próximos a cero. El ruido del descenso estocástico, tratado
en [modelos lineales](../03_deep_learning/section_2_linear_models.md), ayuda a abandonar
estas regiones.

## Optimización con restricciones

En ocasiones los parámetros no pueden tomar cualquier valor. Ocurre cuando los pesos
deben tener norma acotada, cuando un vector debe representar una distribución de
probabilidad y sumar uno, o en la formulación de las máquinas de vectores soporte, donde
se maximiza el margen sujeto a clasificar correctamente los datos. En estos casos el
mínimo buscado no tiene por qué anular el gradiente de la función, porque puede estar en
la frontera de la región permitida.

### Multiplicadores de Lagrange

Cuando se busca el extremo de $f(\mathbf{x})$ sujeto a una restricción de igualdad
$g(\mathbf{x}) = 0$, el **método de los multiplicadores de Lagrange** construye la
función auxiliar, o **lagrangiana**:

$$
\mathcal{L}(\mathbf{x}, \lambda) = f(\mathbf{x}) + \lambda\, g(\mathbf{x})
$$

donde $\lambda \in \mathbb{R}$ es el **multiplicador de Lagrange**. Los candidatos a
extremo son los puntos críticos de $\mathcal{L}$, que se obtienen igualando a cero sus
derivadas parciales respecto a $\mathbf{x}$ y respecto a $\lambda$:

$$
\nabla f(\mathbf{x}) + \lambda\, \nabla g(\mathbf{x}) = \mathbf{0} \qquad
g(\mathbf{x}) = 0
$$

La segunda ecuación recupera la restricción. La primera tiene una lectura geométrica
directa a partir de la derivada direccional. Sobre la curva $g = 0$ solo se permite
avanzar en direcciones tangentes a ella, que son perpendiculares a $\nabla g$. En un
extremo restringido, $f$ no puede cambiar a primer orden en ninguna de esas direcciones,
de modo que $\nabla f$ también ha de ser perpendicular a la curva. Ambos gradientes
resultan entonces paralelos, y $\lambda$ es la constante de proporcionalidad.

???+ example "Máximo de un paraboloide sobre una recta"

    Se busca el extremo de $f(x,y) = 36 - x^{2} - y^{2}$ con la restricción $x + y = 4$,
    es decir, $g(x,y) = x + y - 4$. La lagrangiana es:

    $$
    \mathcal{L} = 36 - x^{2} - y^{2} + \lambda(x + y - 4)
    $$

    Igualando a cero las derivadas parciales:

    $$
    \frac{\partial \mathcal{L}}{\partial x} = -2x + \lambda = 0 \qquad
    \frac{\partial \mathcal{L}}{\partial y} = -2y + \lambda = 0 \qquad
    \frac{\partial \mathcal{L}}{\partial \lambda} = x + y - 4 = 0
    $$

    Las dos primeras dan $x = y = \lambda/2$. Sustituyendo en la tercera, $\lambda = 4$,
    y el único punto crítico es $(2, 2)$, con $f(2,2) = 28$. En él, $\nabla f = (-4,
    -4)$ y $\nabla g = (1, 1)$ son paralelos, con $\nabla f = -4\, \nabla g$.

    Para clasificarlo se restringe $f$ a la recta sustituyendo $y = 4 - x$, lo que da
    $h(x) = 36 - x^{2} - (4 - x)^{2}$. Su derivada segunda es $h''(x) = -4 < 0$, así que
    $(2, 2)$ es un máximo. El código resuelve el mismo sistema de forma simbólica:

    ```python linenums="1"
    import sympy as sp

    x, y, lam = sp.symbols("x y lambda", real=True)
    f = 36 - x**2 - y**2
    g = x + y - 4

    # Lagrangiana y sistema de ecuaciones con todas sus derivadas parciales nulas
    lagrangiana = f + lam * g
    ecuaciones = [sp.diff(lagrangiana, v) for v in (x, y, lam)]
    soluciones = sp.solve(ecuaciones, (x, y, lam), dict=True)
    for s in soluciones:
        print(f"Punto ({s[x]}, {s[y]}), λ = {s[lam]}, f = {f.subs(s)}")

    # Curvatura a lo largo de la restricción, sustituyendo y = 4 - x
    h = f.subs(y, 4 - x)
    print(f"h''(x) = {sp.diff(h, x, 2)}")
    ```

    ```plaintext title="Expected output"
    Punto (2, 2), λ = 4, f = 28
    h''(x) = -4
    ```

!!! warning

    En problemas con restricciones no basta con mirar el signo de las derivadas segundas
    de $f$ o de $\mathcal{L}$ por separado. Lo correcto es estudiar la curvatura a lo
    largo de la restricción, ya sea sustituyéndola como en el ejemplo o mediante la
    Hessiana orlada de $\mathcal{L}$, que añade a la Hessiana las derivadas de $g$.

Al minimizar $f$, la misma formulación se extiende a restricciones de desigualdad,
$g(\mathbf{x}) \leq 0$, mediante las **condiciones de Karush-Kuhn-Tucker**, que exigen
además $\lambda \geq 0$ y que $\lambda\, g(\mathbf{x}) = 0$ en el óptimo: o la
restricción está activa, o su multiplicador es nulo. Es la base del problema dual de las
máquinas de vectores soporte, cuyos vectores soporte son precisamente los datos con
multiplicador no nulo. También explica la relación entre restringir la norma de los
pesos y penalizarla. En un problema convexo, minimizar la pérdida con la restricción
$\Vert \mathbf{w} \Vert^{2} \leq c$ equivale a minimizar $L(\mathbf{w}) + \lambda \Vert
\mathbf{w} \Vert^{2}$ para algún $\lambda \geq 0$, que es la regularización L2 empleada
en el entrenamiento.

El siguiente capítulo, [cálculo numérico](section_5_numerical_computing.md), aborda cómo
se llevan estas ideas al ordenador, donde la aritmética de precisión finita y el
condicionamiento de los problemas determinan si un algoritmo de optimización funciona en
la práctica.
