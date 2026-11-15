---
icon: lucide/binary
authors: Daniel Bazo Correa
description:
    Fundamentos de cálculo numérico para el aprendizaje automático, desde la aritmética
    de punto flotante y la precisión mixta hasta el condicionamiento, la resolución
    estable de sistemas lineales, los mínimos cuadrados y el método de Newton.
title: Cálculo numérico
---

!!! warning

    El contenido de esta página no ha sido revisado ni corregido, por lo que puede
    estar incompleto, contener errores o presentar información desactualizada. Además,
    es posible que esté desordenado, carezca de una estructura clara o incluya notas
    copiadas directamente.

Este capítulo, que continúa el de [optimización](section_4_optimization.md), recoge las
ideas de cálculo numérico que explican por qué un entrenamiento diverge, produce `nan` o
converge con lentitud, y qué técnicas lo estabilizan. Parte de la representación de los
números en punto flotante y de los errores que introduce, mide después la sensibilidad
de un problema con el número de condición y aplica ambas ideas a la resolución de
sistemas lineales, al ajuste por mínimos cuadrados y al método de Newton. Los conceptos
principales se acompañan de un ejemplo en Python con NumPy.

## Introducción

El **análisis numérico** estudia algoritmos que obtienen aproximaciones a la solución de
problemas matemáticos mediante un número finito de operaciones aritméticas. Un ordenador
no trabaja con números reales sino con un subconjunto finito de ellos, lo que introduce
**errores de redondeo**, y no puede ejecutar procesos infinitos como un límite o una
serie, lo que introduce **errores de truncamiento** al detenerlos. A ello se suman dos
propiedades que deciden si esos errores pequeños se quedan pequeños. El
**condicionamiento** mide la sensibilidad del propio problema a cambios en los datos, y
la **estabilidad** indica si un algoritmo amplifica los errores aunque el problema esté
bien planteado. En el aprendizaje automático estas cuestiones aparecen a diario: el
entrenamiento en precisión mixta, la implementación de la función _softmax_, la
normalización de las características o la elección de la tasa de aprendizaje dependen de
ellas.

## Aritmética de punto flotante

### Números normalizados

Un **número normalizado en punto flotante** en base $\beta$ se escribe como:

$$
\pm . d_1 d_2 \ldots d_t \times \beta^{e} \qquad 0 < d_1 < \beta, \quad 0 \leq d_i <
\beta \ (i = 2, \ldots, t), \quad m \leq e \leq M
$$

La secuencia $d_1 d_2 \ldots d_t$ recibe el nombre de **mantisa** y $e$ es el
**exponente**, acotado entre un mínimo $m$ y un máximo $M$. Exigir $d_1 \neq 0$ hace que
la representación sea única. El conjunto de todos los números así construidos se denota
$\mathbb{F}(\beta, t, m, M)$, y dos constantes caracterizan su precisión. La **unidad de
redondeo** es:

$$
\mu = \frac{1}{2} \beta^{1-t}
$$

y el **épsilon de la máquina** es su doble, $\varepsilon = 2\mu = \beta^{1-t}$, que
coincide con la distancia entre $1$ y el siguiente número representable.

La función $fl(x)$ asigna a cada real $x$ el número representable más próximo. Tres
propiedades de esta función explican la mayoría de los fallos numéricos:

- **Conjunto finito**: Los números cuyo exponente supera $M$ provocan **desbordamiento**
  (_overflow_) y se convierten en `inf`. Los que quedan por debajo del menor normalizado
  sufren **subdesbordamiento** (_underflow_), pierden precisión y acaban en cero.
- **No inyectiva**: Infinitos reales distintos comparten la misma representación, de
  modo que la información perdida al redondear no se recupera.
- **Distribución desigual**: La separación entre dos números consecutivos es
  $\beta^{e-t}$. Crece con el exponente, de modo que los representables se concentran
  cerca del cero.

Al sustituir un real $x \neq 0$ por $fl(x)$, el **error absoluto** $|fl(x) - x|$ depende
de la magnitud de $x$, mientras que el **error relativo** $|fl(x) - x|/|x|$ no depende
de ella y es el que permite comparar aproximaciones de tamaños distintos. Si la máquina
redondea al más próximo, el error relativo de representación está acotado por $\mu$, de
modo que $x$ y $fl(x)$ comparten unos $-\log_{10} \mu$ dígitos decimales.

### Formatos IEEE 754 en aprendizaje automático

Los tipos de NumPy, PyTorch y del hardware actual siguen el estándar IEEE 754, un
sistema binario normalizado en el que el primer dígito de la mantisa vale siempre uno y
no se almacena. Los formatos habituales difieren en cómo reparten los bits entre
exponente, que fija el rango, y mantisa, que fija la precisión:

| Formato    | Exponente / mantisa | $\varepsilon$        | Máximo               | Uso habitual                                      |
| ---------- | ------------------- | -------------------- | -------------------- | ------------------------------------------------- |
| `float64`  | 11 / 52 bits        | $2.2 \cdot 10^{-16}$ | $1.8 \cdot 10^{308}$ | Cálculo científico y álgebra lineal de precisión. |
| `float32`  | 8 / 23 bits         | $1.2 \cdot 10^{-7}$  | $3.4 \cdot 10^{38}$  | Pesos maestros y acumuladores del entrenamiento.  |
| `float16`  | 5 / 10 bits         | $9.8 \cdot 10^{-4}$  | $6.6 \cdot 10^{4}$   | Activaciones y gradientes en precisión mixta.     |
| `bfloat16` | 8 / 7 bits          | $7.8 \cdot 10^{-3}$  | $3.4 \cdot 10^{38}$  | Entrenamiento en TPU y GPU recientes.             |

El formato `bfloat16` conserva el exponente de `float32` y sacrifica mantisa, de modo
que tiene el mismo rango pero solo dos o tres dígitos decimales. El formato `float16`
tiene algo más de precisión pero un rango muy corto, con un máximo de $65504$. La
función `np.finfo` devuelve estos parámetros, y su atributo `eps` es exactamente el
$\varepsilon = \beta^{1-t}$ definido antes.

### Precisión mixta

El **entrenamiento en precisión mixta** ejecuta las multiplicaciones de matrices en
`float16` o `bfloat16`, que duplican el rendimiento y reducen a la mitad la memoria de
las activaciones, y mantiene en `float32` las operaciones sensibles al redondeo. Dos
fenómenos justifican este reparto:

- **Actualizaciones absorbidas**: Si una actualización $\eta g$ es menor que $\mu |w|$,
  la suma $w + \eta g$ redondea de nuevo a $w$ y el peso no cambia. En `float16`, con
  $\mu \approx 4.9 \cdot 10^{-4}$, un peso de valor uno ignora cualquier actualización
  inferior a ese umbral. Por eso se guarda una copia maestra de los pesos en `float32`.
- **Gradientes anulados**: Muchos gradientes quedan por debajo de $6.1 \cdot 10^{-5}$,
  el menor normalizado de `float16`, donde pierden precisión, y por debajo de unos $3
  \cdot 10^{-8}$ se anulan. El **escalado de la pérdida** (_loss scaling_) multiplica la
  pérdida por una constante, típicamente una potencia de dos, antes de la
  retropropagación y divide los gradientes por ella antes de actualizar los pesos en
  `float32`.

El formato `bfloat16` apenas necesita escalado, porque su rango coincide con el de
`float32`, pero su mantisa corta agrava el primer problema. En la práctica, las
bibliotecas de aprendizaje profundo automatizan ambos mecanismos, como en `torch.amp`.

???+ example "Actualizaciones absorbidas y escalado de la pérdida"

    El código suma mil veces una actualización de $10^{-4}$ a un peso de valor uno en
    `float16` y en `float32`, y después representa un gradiente de $10^{-8}$ en
    `float16` con y sin escalado.

    ```python linenums="1"
    import numpy as np

    # Un peso cercano a uno y una actualización pequeña del orden de lr * gradiente
    peso, actualizacion = 1.0, 1e-4
    for tipo in (np.float16, np.float32):
        w = tipo(peso)
        for _ in range(1000):
            w = tipo(w + tipo(actualizacion))
        print(f"{np.dtype(tipo).name}: peso tras 1000 pasos = {float(w):.6f}")

    # Un gradiente pequeño se anula en float16 salvo que se escale la pérdida
    gradiente = 1e-8
    escala = 2.0**16
    print("float16 sin escalar:", np.float16(gradiente))
    escalado = np.float16(gradiente * escala)
    print("float16 escalado y recuperado en float32:", np.float32(escalado) / escala)
    ```

    ```plaintext title="Expected output"
    float16: peso tras 1000 pasos = 1.000000
    float32: peso tras 1000 pasos = 1.100017
    float16 sin escalar: 0.0
    float16 escalado y recuperado en float32: 9.997166e-09
    ```

    En `float16` el peso no se mueve en mil pasos, mientras que en `float32` avanza
    casi el $0.1$ esperado. El gradiente sin escalar se pierde por completo y, escalado
    por $2^{16}$, se recupera con un error relativo del orden de $3 \cdot 10^{-4}$.

### Operaciones y cancelación catastrófica

Una operación computacional $\circledast$ representa los operandos, opera con ellos y
vuelve a representar el resultado:

$$
x \circledast y = fl\left(fl(x) \ast fl(y)\right) \qquad \ast \in \{+, -, \times, /\}
$$

Si los operandos son exactamente representables, el estándar IEEE 754 garantiza que el
error relativo de cada operación aislada no supera $\mu$. Los problemas aparecen al
encadenar operaciones, porque los errores se propagan y se pueden amplificar. El caso
más peligroso es la **cancelación catastrófica**: al restar dos números casi iguales,
los dígitos iniciales se anulan y el resultado conserva solo los dígitos finales, que
son precisamente los afectados por el redondeo. El error absoluto se mantiene, pero el
relativo crece tanto como se reduce el resultado.

Un ejemplo frecuente es el cálculo de la varianza con la fórmula $E\lbrack x^2 \rbrack -
E\lbrack x \rbrack^2$, que resta dos cantidades enormes cuando la media es grande
respecto a la desviación típica. Las implementaciones de _Batch Normalization_ evitan
esta fórmula y centran los datos antes de elevar al cuadrado, o aplican el algoritmo
incremental de Welford.

???+ example "Varianza con una y con dos pasadas"

    El código calcula en `float32` la varianza de cien mil valores con media $10^4$ y
    varianza uno, y la compara con la referencia en `float64`.

    ```python linenums="1"
    import numpy as np

    rng = np.random.default_rng(0)
    # Activaciones con media grande y varianza pequeña, en float32
    x = (1e4 + rng.standard_normal(100_000)).astype(np.float32)

    # Fórmula de una pasada: E[x^2] - E[x]^2
    una_pasada = np.mean(x * x) - np.mean(x) ** 2
    # Fórmula de dos pasadas: centrar primero y después elevar al cuadrado
    dos_pasadas = np.mean((x - np.mean(x)) ** 2)
    referencia = np.var(x.astype(np.float64))
    print(f"una pasada:  {una_pasada:.4f}")
    print(f"dos pasadas: {dos_pasadas:.4f}")
    print(f"referencia:  {referencia:.4f}")
    ```

    ```plaintext title="Expected output"
    una pasada:  -8.0000
    dos pasadas: 1.0003
    referencia:  1.0003
    ```

    Los dos términos de la resta valen alrededor de $10^8$, donde la separación entre
    `float32` consecutivos es $8$, y la fórmula de una pasada devuelve una varianza
    negativa. Centrar primero elimina la cancelación.

### Exponenciales estables: _log-sum-exp_ y _softmax_

La función exponencial desborda con argumentos moderados: en `float32`, $e^{z}$ es `inf`
para $z > 88.7$ y se anula para $z < -103$. La función _softmax_, descrita en el
capítulo de [modelos lineales](../03_deep_learning/section_2_linear_models.md), combina
exponenciales de los _logits_ $z_i$, que en una red sin regularizar alcanzan con
facilidad esos valores. Evaluada de forma literal, produce `inf / inf = nan`.

La solución aprovecha que la _softmax_ es invariante a una traslación de todos los
_logits_. Restando su máximo $m = \max_j z_j$:

$$
\text{softmax}(\mathbf{z})_i = \frac{e^{z_i}}{\sum_{j} e^{z_j}} = \frac{e^{z_i -
m}}{\sum_{j} e^{z_j - m}}
$$

todos los exponentes quedan en $(-\infty, 0\rbrack$, el mayor término del denominador
vale uno y ni el numerador ni el denominador pueden desbordar. El mismo argumento
proporciona el **truco de _log-sum-exp_**, que calcula el logaritmo de una suma de
exponenciales sin evaluarla directamente:

$$
\log \sum_{j} e^{z_j} = m + \log \sum_{j} e^{z_j - m}
$$

Con él, la log-probabilidad que necesita la entropía cruzada se obtiene como $\log p_i =
z_i - \log \sum_j e^{z_j}$, sin calcular primero la _softmax_ y después su logaritmo,
que daría $\log 0 = -\infty$ cuando $p_i$ subdesborda. Por ese motivo PyTorch fusiona
ambas operaciones en `log_softmax` y `cross_entropy` recibe _logits_ en lugar de
probabilidades. El mismo truco aparece en las mezclas de densidades, en la verosimilitud
de los modelos ocultos de Markov y en la atención de los _Transformers_, donde el factor
$1/\sqrt{d_K}$ descrito en
[modelos secuenciales](../03_deep_learning/section_5_sequential_models.md) limita además
la magnitud de los _logits_.

???+ example "Softmax ingenua y estable"

    El código evalúa la _softmax_ de tres _logits_ grandes con la fórmula literal y a
    partir de _log-sum-exp_, como $p_i = e^{z_i - \log \sum_j e^{z_j}}$, y obtiene la
    log-probabilidad de la primera clase.

    ```python linenums="1"
    import numpy as np


    def logsumexp(z: np.ndarray) -> float:
        """Calcula log(sum(exp(z))) sin desbordamiento.

        Args:
            z: Vector de logits.

        Returns:
            El logaritmo de la suma de exponenciales.
        """
        m = np.max(z)
        return float(m + np.log(np.sum(np.exp(z - m))))


    z = np.array([1000.0, 999.0, 990.0])
    with np.errstate(over="ignore", invalid="ignore"):
        ingenua = np.exp(z) / np.sum(np.exp(z))
    print("softmax ingenua:", ingenua)
    # Todos los exponentes son no positivos, de modo que no hay desbordamiento
    estable = np.exp(z - logsumexp(z))
    print("softmax estable:", [f"{p:.6f}" for p in estable])
    print(f"logsumexp: {logsumexp(z):.6f}")

    # Log-probabilidad de la clase 0 sin pasar por la softmax
    print(f"log p_0 = {z[0] - logsumexp(z):.6f}")
    ```

    ```plaintext title="Expected output"
    softmax ingenua: [nan nan nan]
    softmax estable: ['0.731034', '0.268932', '0.000033']
    logsumexp: 1000.313295
    log p_0 = -0.313295
    ```

Otras funciones habituales siguen la misma idea de reescribir la expresión para evitar
un desbordamiento o una cancelación. La sigmoide se evalúa como $e^{z}/(1 + e^{z})$
cuando $z < 0$ y como $1/(1 + e^{-z})$ en otro caso. La función _softplus_, $\log(1 +
e^{z})$, se calcula con `np.logaddexp(0, z)`, que evita el desbordamiento cuando $z$ es
grande y la pérdida de precisión de `np.log(1 + np.exp(z))` cuando $e^{z}$ es muy
pequeño.

## Estabilidad y condicionamiento

### Normas matriciales

Para medir cómo se propagan los errores hay que medir distancias entre datos y entre
resultados. Las normas vectoriales se describen en el capítulo de
[fundamentos matemáticos](section_2_deep_learning_math.md). Para una matriz $\mathbf{A}$
se emplea la **norma subordinada**, que mide el máximo factor de amplificación que la
matriz aplica a un vector:

$$
\Vert \mathbf{A} \Vert = \max_{\mathbf{x} \neq \mathbf{0}} \frac{\Vert \mathbf{A}
\mathbf{x} \Vert}{\Vert \mathbf{x} \Vert}
$$

Por construcción cumple $\Vert \mathbf{A}\mathbf{x} \Vert \leq \Vert \mathbf{A} \Vert
\Vert \mathbf{x} \Vert$. La subordinada a la norma euclídea es la **norma espectral**,
$\Vert \mathbf{A} \Vert_2 = \sigma_{\max}(\mathbf{A})$, el mayor valor singular, que
coincide con la raíz del **radio espectral** $\rho(\mathbf{A}^{\top}\mathbf{A})$, el
módulo de su mayor autovalor. Las normas subordinadas a $\Vert \cdot \Vert_1$ y $\Vert
\cdot \Vert_\infty$ son la mayor suma de módulos por columnas y por filas. Todas se
obtienen con `np.linalg.norm(a, orden)`, con `orden` igual a `1`, `2`, `np.inf` o
`"fro"`, esta última para la norma de Frobenius $\sqrt{\sum_{i,j} a_{ij}^2}$.

### Problemas mal condicionados y métodos inestables

Cuando un cálculo produce un resultado muy alejado del correcto, la causa puede estar en
el método o en el propio problema. Un **método inestable** proporciona en ocasiones
resultados excesivamente malos aunque el problema esté bien planteado. Un **problema mal
condicionado** es sensible por naturaleza a pequeños cambios en los datos, de modo que
ningún método puede evitar que el redondeo se traduzca en un error grande del resultado.

Un método es estable si el resultado que calcula es la solución exacta de un problema
con datos ligeramente perturbados. Otra forma de verlo es seguir un error inicial $E_0$
a lo largo de $n$ pasos. Si crece de forma lineal, $|E_n| \approx K n E_0$, el método es
estable. Si crece de forma exponencial, $|E_n| \approx K^{n} E_0$ con $K > 1$, es
inestable: con $K = 2$ y $E_0 = 10^{-16}$, bastan 50 pasos para que el error sea del
orden de $10^{-1}$. La explosión de gradientes en redes profundas o recurrentes,
descrita en [redes neuronales](../03_deep_learning/section_3_neural_networks.md), es
este mismo fenómeno: el gradiente se multiplica por una matriz jacobiana en cada capa y
crece o decrece como la potencia de su norma.

### Número de condición

Si el término independiente de $\mathbf{A}\mathbf{x} = \mathbf{b}$ contiene un error
$\delta\mathbf{b}$, la solución calculada contiene un error $\delta\mathbf{x}$. Para
$\mathbf{A}$ regular se define el **número de condición**:

$$
\kappa(\mathbf{A}) = \Vert\mathbf{A}\Vert \Vert\mathbf{A}^{-1}\Vert
$$

que acota la amplificación del error relativo:

$$
\frac{1}{\kappa(\mathbf{A})}\frac{\Vert \delta\mathbf{b}\Vert}{\Vert\mathbf{b}\Vert}
\leq \frac{\Vert \delta\mathbf{x}\Vert}{\Vert\mathbf{x}\Vert} \leq \kappa(\mathbf{A})
\frac{\Vert \delta\mathbf{b}\Vert}{\Vert\mathbf{b}\Vert}
$$

El número de condición es, por tanto, el factor máximo por el que se puede amplificar el
error relativo de los datos. Cumple tres propiedades:

- **Rango**: $1 \leq \kappa(\mathbf{A}) \leq +\infty$. El valor uno corresponde a una
  matriz perfectamente condicionada y el infinito, a una matriz singular.
- **Norma 2**: $\kappa_2(\mathbf{A}) = \sigma_{\max}/\sigma_{\min}$, el cociente entre
  el mayor y el menor valor singular. En una matriz simétrica definida positiva es el
  cociente entre su mayor y su menor autovalor.
- **Matrices ortogonales**: Si $\mathbf{Q}$ es ortogonal, $\kappa_2(\mathbf{Q}) = 1$, lo
  que explica la estabilidad de los métodos basados en la factorización QR.

Como regla práctica, con $\kappa(\mathbf{A}) \approx 10^{k}$ se pueden perder hasta $k$
dígitos correctos en la solución. En `float32`, que tiene unos siete, una matriz con
$\kappa \approx 10^{7}$ ya no proporciona ninguno fiable.

### Condicionamiento y normalización de los datos

En un problema de regresión, la matriz relevante es $\mathbf{X}^{\top}\mathbf{X}$, donde
$\mathbf{X}$ es la matriz de diseño con una fila por ejemplo y una columna por
característica. Si las columnas tienen escalas muy distintas, por ejemplo una superficie
en metros cuadrados junto a un número de plantas, los autovalores de
$\mathbf{X}^{\top}\mathbf{X}$ difieren en varios órdenes de magnitud y la matriz queda
mal condicionada. Lo mismo ocurre cuando dos características están muy correlacionadas,
porque las columnas son casi linealmente dependientes.

El condicionamiento no afecta solo a los métodos directos. El descenso del gradiente
sobre la pérdida cuadrática $\frac{1}{2N}\Vert \mathbf{y} - \mathbf{X}\mathbf{w}
\Vert_2^2$ es la iteración lineal:

$$
\mathbf{w}^{(k+1)} = \left(\mathbf{I} - \eta \mathbf{A}\right)\mathbf{w}^{(k)} + \eta
\mathbf{c} \qquad \mathbf{A} = \frac{1}{N}\mathbf{X}^{\top}\mathbf{X}, \quad \mathbf{c}
= \frac{1}{N}\mathbf{X}^{\top}\mathbf{y}
$$

Una iteración de esta forma converge si y solo si el radio espectral de la matriz de
iteración es menor que uno, $\rho(\mathbf{I} - \eta\mathbf{A}) < 1$, lo que exige $0 <
\eta < 2/\lambda_{\max}$, la misma cota obtenida en
[optimización](section_4_optimization.md). Con el mejor paso posible, el error se reduce
en cada iteración por un factor $(\kappa - 1)/(\kappa + 1)$, con $\kappa =
\lambda_{\max}/\lambda_{\min}$. Un $\kappa$ grande obliga a usar una tasa de aprendizaje
pequeña, fijada por la dirección de mayor curvatura, y a avanzar con lentitud en la de
menor curvatura. La **estandarización** de las características, que resta la media y
divide por la desviación típica de cada columna, acerca $\kappa$ a uno. Es la razón
numérica detrás de la normalización de entradas y de activaciones descrita en
[modelos lineales](../03_deep_learning/section_2_linear_models.md).

???+ example "Efecto de la estandarización en el descenso del gradiente"

    El código ajusta una regresión lineal con dos características de escalas distintas
    mediante descenso del gradiente con el paso óptimo, antes y después de
    estandarizar, y cuenta las iteraciones hasta que el gradiente se anula.

    ```python linenums="1"
    import numpy as np


    def descenso_gradiente(
        x: np.ndarray, y: np.ndarray, tol: float = 1e-8, max_iter: int = 10_000
    ) -> int:
        """Minimiza el error cuadrático medio con el paso óptimo para una cuadrática.

        Args:
            x: Matriz de diseño de tamaño n x p.
            y: Vector de valores objetivo de tamaño n.
            tol: Tolerancia sobre la norma del gradiente.
            max_iter: Número máximo de iteraciones.

        Returns:
            El número de iteraciones realizadas.
        """
        a = x.T @ x / len(y)
        autovalores = np.linalg.eigvalsh(a)
        # Paso que minimiza el radio espectral de I - eta A
        eta = 2 / (autovalores.max() + autovalores.min())
        w = np.zeros(x.shape[1])
        for k in range(1, max_iter + 1):
            g = a @ w - x.T @ y / len(y)
            if np.linalg.norm(g) < tol:
                return k
            w -= eta * g
        return max_iter


    rng = np.random.default_rng(0)
    n = 1000
    superficie = rng.uniform(50, 300, n)
    plantas = rng.integers(1, 4, n).astype(float)
    x = np.column_stack([np.ones(n), superficie, plantas])
    precio = 2.0 * superficie + 10.0 * plantas + rng.normal(0, 5, n)

    x_std = x.copy()
    x_std[:, 1:] = (x[:, 1:] - x[:, 1:].mean(axis=0)) / x[:, 1:].std(axis=0)

    for nombre, m in [("original", x), ("estandarizada", x_std)]:
        kappa = np.linalg.cond(m.T @ m)
        iteraciones = descenso_gradiente(m, precio)
        print(f"{nombre:>13}: kappa={kappa:.2e} iteraciones={iteraciones}")
    ```

    ```plaintext title="Expected output"
         original: kappa=5.23e+05 iteraciones=10000
    estandarizada: kappa=1.00e+00 iteraciones=5
    ```

    Con los datos originales el método agota las diez mil iteraciones sin converger.
    Tras estandarizar, las columnas son casi ortogonales, $\kappa$ vale prácticamente
    uno y bastan cinco iteraciones.

## Sistemas de ecuaciones lineales

### Coste y elección del método

Un sistema $\mathbf{A}\mathbf{x} = \mathbf{b}$ con $\mathbf{A} \in \mathbb{R}^{n \times
n}$ regular aparece en la regresión lineal, en los procesos gaussianos, en el paso de
Newton o en el cálculo de verosimilitudes gaussianas. La representación matricial y la
idea de la eliminación gaussiana se describen en el capítulo de
[fundamentos matemáticos](section_2_deep_learning_math.md). Desde el punto de vista
computacional interesan tres hechos:

- **Los determinantes no sirven para resolver**: La regla de Cramer cuesta del orden de
  $(n+1)!$ operaciones. Con $n = 20$ son unas $5 \cdot 10^{19}$, frente a las $2n^3/3
  \approx 5300$ de la eliminación gaussiana.
- **La inversa casi nunca hace falta**: Calcular $\mathbf{A}^{-1}$ y multiplicar por
  $\mathbf{b}$ cuesta unas tres veces más que resolver el sistema y es menos preciso. En
  NumPy se usa `np.linalg.solve(a, b)` en lugar de `np.linalg.inv(a) @ b`.
- **Factorizar una vez y reutilizar**: Los métodos directos transforman $\mathbf{A}$ en
  un producto de matrices triangulares u ortogonales con coste $O(n^3)$. Después, cada
  nuevo $\mathbf{b}$ se resuelve con sustituciones triangulares de coste $O(n^2)$.

### Eliminación gaussiana y factorización LU

La eliminación gaussiana resta a cada fila múltiplos $m_{ji} = a_{ji}/a_{ii}$ de las
anteriores hasta obtener una matriz triangular superior $\mathbf{U}$, y guarda los
multiplicadores en una triangular inferior $\mathbf{L}$ con unos en la diagonal. El
resultado es la **factorización LU**, que con intercambios de filas existe para
cualquier matriz regular en la forma $\mathbf{P}\mathbf{A} = \mathbf{L}\mathbf{U}$,
donde $\mathbf{P}$ es una matriz de permutación. El sistema se resuelve con dos
sustituciones: la progresiva de $\mathbf{L}\mathbf{y} = \mathbf{P}\mathbf{b}$, que
despeja las incógnitas de arriba abajo, y la regresiva de $\mathbf{U}\mathbf{x} =
\mathbf{y}$, que lo hace de abajo arriba. En SciPy, `scipy.linalg.lu_factor` calcula la
factorización una sola vez y `scipy.linalg.lu_solve` la reutiliza para cada nuevo
término independiente.

El **pivotaje parcial** elige en cada columna, como pivote $a_{ii}$, el elemento de
mayor módulo entre la diagonal y las filas inferiores. No es un detalle de
implementación sino lo que hace estable el método: dividir por un pivote pequeño produce
multiplicadores enormes, que hacen crecer los elementos de $\mathbf{U}$ y borran por
absorción la información del resto de la fila. El problema puede estar perfectamente
condicionado y aun así el método sin pivotaje devolver un resultado inservible.

???+ example "Eliminación gaussiana con y sin pivotaje"

    El sistema $10^{-20}x_0 + x_1 = 1$, $x_0 + x_1 = 2$ tiene solución muy próxima a
    $(1, 1)$ y número de condición pequeño. El código lo resuelve sin intercambiar
    filas y con `np.linalg.solve`, que aplica LU con pivotaje parcial.

    ```python linenums="1"
    import numpy as np


    def lu_sin_pivotaje(a: np.ndarray, b: np.ndarray) -> np.ndarray:
        """Resuelve un sistema 2 x 2 por eliminación gaussiana sin intercambiar filas.

        Args:
            a: Matriz de tamaño 2 x 2 con a[0, 0] distinto de cero.
            b: Vector de términos independientes de tamaño 2.

        Returns:
            El vector solución x.
        """
        m = a[1, 0] / a[0, 0]
        x1 = (b[1] - m * b[0]) / (a[1, 1] - m * a[0, 1])
        return np.array([(b[0] - a[0, 1] * x1) / a[0, 0], x1])


    a = np.array([[1e-20, 1.0], [1.0, 1.0]])
    b = np.array([1.0, 2.0])
    print("sin pivotaje:", lu_sin_pivotaje(a, b))
    print("con pivotaje:", np.linalg.solve(a, b))
    print(f"kappa(A) = {np.linalg.cond(a):.2f}")
    ```

    ```plaintext title="Expected output"
    sin pivotaje: [0. 1.]
    con pivotaje: [1. 1.]
    kappa(A) = 2.62
    ```

    Sin pivotaje, el multiplicador $10^{20}$ convierte $1 - 10^{20}$ en $-10^{20}$ y el
    valor de $a_{11}$ se pierde. El método es inestable aunque el problema no lo sea.

### Factorización de Cholesky

Si $\mathbf{A}$ es simétrica y definida positiva admite la **factorización de Cholesky**
$\mathbf{A} = \mathbf{M}\mathbf{M}^{\top}$, con $\mathbf{M}$ triangular inferior de
diagonal positiva. Sus propiedades y su uso en la generación de muestras gaussianas se
describen en el capítulo de [fundamentos matemáticos](section_2_deep_learning_math.md).
Desde el punto de vista numérico tiene tres ventajas sobre LU: aprovecha la simetría con
un coste de $n^3/3$ operaciones, la mitad, no necesita pivotaje para ser estable y sirve
como prueba de que la matriz es definida positiva, porque falla si en algún paso aparece
la raíz de un número no positivo.

Esa última propiedad tiene una consecuencia práctica. Las matrices de covarianza y los
núcleos de los procesos gaussianos son semidefinidos positivos en teoría, pero el
redondeo puede dar autovalores ligeramente negativos y hacer fallar la factorización. La
solución habitual suma una pequeña constante a la diagonal, $\mathbf{A} +
\epsilon\mathbf{I}$, conocida como _jitter_, que desplaza todos los autovalores en
$\epsilon$ y es un caso particular de la regularización que se describe más adelante. En
SciPy, `scipy.linalg.cho_factor` y `scipy.linalg.cho_solve` separan la factorización de
la resolución, y `np.linalg.cholesky` lanza `LinAlgError` si la matriz no es definida
positiva.

### Factorización QR

Toda matriz $\mathbf{A} \in \mathbb{R}^{m \times n}$ con $m \geq n$ y columnas
linealmente independientes se escribe como $\mathbf{A} = \mathbf{Q}\mathbf{R}$, con
$\mathbf{Q} \in \mathbb{R}^{m \times n}$ de columnas ortonormales y $\mathbf{R} \in
\mathbb{R}^{n \times n}$ triangular superior. Si $\mathbf{A}$ es cuadrada, resolver
$\mathbf{A}\mathbf{x} = \mathbf{b}$ se reduce a la sustitución regresiva de
$\mathbf{R}\mathbf{x} = \mathbf{Q}^{\top}\mathbf{b}$. Como las matrices ortogonales
conservan la norma 2 y tienen $\kappa_2 = 1$, multiplicar por $\mathbf{Q}^{\top}$ no
amplifica los errores, y por eso QR es la base de los métodos estables de mínimos
cuadrados. Su coste es aproximadamente el doble que el de LU.

El algoritmo de Gram-Schmidt, descrito en
[fundamentos matemáticos](section_2_deep_learning_math.md), pierde ortogonalidad por
cancelación cuando las columnas son casi dependientes. Por eso `np.linalg.qr` y LAPACK
emplean **reflexiones de Householder**, matrices ortogonales $\mathbf{H} = \mathbf{I} -
2\mathbf{u}\mathbf{u}^{\top}/(\mathbf{u}^{\top}\mathbf{u})$ que anulan de una vez los
elementos de una columna por debajo de la diagonal.

### Métodos iterativos

Para matrices muy grandes y dispersas, los métodos directos resultan caros en tiempo y
en memoria. Los **métodos iterativos** construyen una sucesión $\mathbf{x}^{(k+1)} =
\mathbf{B}\mathbf{x}^{(k)} + \mathbf{c}$ que converge a la solución desde cualquier
punto de partida si y solo si $\rho(\mathbf{B}) < 1$, y cuanto menor es el radio
espectral más rápida es la convergencia. El descenso del gradiente sobre una pérdida
cuadrática, analizado en la sección anterior, es exactamente una iteración de este tipo
con $\mathbf{B} = \mathbf{I} - \eta\mathbf{A}$. Para matrices simétricas definidas
positivas, el método del **gradiente conjugado** mejora esa convergencia, porque su
velocidad depende de $\sqrt{\kappa}$ en lugar de $\kappa$, y es el que se usa en
optimizadores de segundo orden que resuelven sistemas con la Hessiana sin formarla.

## Aproximación por mínimos cuadrados

### Ecuaciones normales

Dados $N$ ejemplos con matriz de diseño $\mathbf{X} \in \mathbb{R}^{N \times p}$ y
valores objetivo $\mathbf{y} \in \mathbb{R}^{N}$, el sistema $\mathbf{X}\mathbf{w} =
\mathbf{y}$ tiene más ecuaciones que incógnitas y en general no tiene solución. La
**aproximación por mínimos cuadrados** busca los pesos que minimizan la suma de los
cuadrados de los residuos:

$$
\mathbf{w}^{\ast} = \arg\min_{\mathbf{w}} \Vert \mathbf{y} - \mathbf{X}\mathbf{w}
\Vert_2^2
$$

Se prefiere la norma 2 a otras porque conduce a un sistema lineal. Anulando el gradiente
respecto a $\mathbf{w}$ se obtienen las **ecuaciones normales**:

$$
\mathbf{X}^{\top}\mathbf{X}\mathbf{w}^{\ast} = \mathbf{X}^{\top}\mathbf{y}
$$

La matriz $\mathbf{X}^{\top}\mathbf{X}$ es la **matriz de Gram** de las columnas de
$\mathbf{X}$. Si estas son linealmente independientes es simétrica y definida positiva,
de modo que la solución existe, es única y se puede calcular con Cholesky. Su expresión
cerrada es $\mathbf{w}^{\ast} = (\mathbf{X}^{\top}\mathbf{X})^{-1}\mathbf{X}^{\top}
\mathbf{y}$, donde $(\mathbf{X}^{\top}\mathbf{X})^{-1}\mathbf{X}^{\top}$ es la
pseudoinversa de Moore-Penrose de $\mathbf{X}$. El planteamiento estadístico de la
regresión se describe en el capítulo de [estadística](section_1_statistics.md) y su uso
como solución cerrada de un modelo lineal en
[modelos lineales](../03_deep_learning/section_2_linear_models.md). Las columnas de
$\mathbf{X}$ pueden ser funciones cualesquiera de los datos, como potencias $x^k$ en un
ajuste polinómico, porque el problema solo necesita ser lineal en los pesos.

### Resolución estable con QR y SVD

Formar $\mathbf{X}^{\top}\mathbf{X}$ tiene un inconveniente numérico grave: eleva al
cuadrado el número de condición, $\kappa_2(\mathbf{X}^{\top}\mathbf{X}) =
\kappa_2(\mathbf{X})^2$. Si $\kappa_2(\mathbf{X}) \approx 10^{6}$, las ecuaciones
normales pueden perder doce dígitos en lugar de seis, y en `float32` la solución deja de
tener sentido. Existen dos alternativas que trabajan directamente sobre $\mathbf{X}$:

- **Factorización QR**: Con $\mathbf{X} = \mathbf{Q}\mathbf{R}$ y como $\mathbf{Q}$
  conserva la norma 2, minimizar $\Vert \mathbf{y} - \mathbf{X}\mathbf{w}\Vert_2$
  equivale a resolver el sistema triangular $\mathbf{R}\mathbf{w} =
  \mathbf{Q}^{\top}\mathbf{y}$, cuyo número de condición es el de $\mathbf{X}$.
- **Descomposición en valores singulares**: Con $\mathbf{X} =
  \mathbf{U}\boldsymbol{\Sigma}\mathbf{V}^{\top}$, la solución es $\mathbf{w}^{\ast} =
  \mathbf{V}\boldsymbol{\Sigma}^{+}\mathbf{U}^{\top}\mathbf{y}$, donde
  $\boldsymbol{\Sigma}^{+}$ invierte los valores singulares no nulos. Es la más cara,
  pero también funciona cuando $\mathbf{X}$ no tiene rango completo: los valores
  singulares menores que un umbral relativo, el parámetro `rcond` de `np.linalg.lstsq`,
  se tratan como cero y se obtiene la solución de norma mínima.

La SVD y su relación con la aproximación de rango bajo se describen en
[fundamentos matemáticos](section_2_deep_learning_math.md). La función `np.linalg.lstsq`
usa la SVD, y las bibliotecas de regresión como scikit-learn recurren a QR o SVD, nunca
a la inversa de $\mathbf{X}^{\top}\mathbf{X}$.

???+ example "Ajuste polinómico por tres caminos"

    El código ajusta un polinomio de grado nueve con coeficientes verdaderos iguales a
    uno sobre cincuenta puntos de $\lbrack 0, 1 \rbrack$. La matriz de diseño de
    potencias, o de Vandermonde, está mal condicionada, y el código mide el error
    relativo de los coeficientes obtenidos por cada método.

    ```python linenums="1"
    import numpy as np

    # Ajuste polinómico de grado 9 con coeficientes verdaderos conocidos
    x = np.linspace(0.0, 1.0, 50)
    m = np.vander(x, 10, increasing=True)
    w_real = np.ones(10)
    y = m @ w_real

    # Ecuaciones normales: forman M^T M y elevan al cuadrado el número de condición
    w_normales = np.linalg.solve(m.T @ m, m.T @ y)
    # QR reducida: M = Q R y se resuelve R w = Q^T y
    q, r = np.linalg.qr(m)
    w_qr = np.linalg.solve(r, q.T @ y)
    # lstsq: basada en la descomposición en valores singulares
    w_svd = np.linalg.lstsq(m, y, rcond=None)[0]

    kappa_m, kappa_gram = np.linalg.cond(m), np.linalg.cond(m.T @ m)
    print(f"kappa(M) = {kappa_m:.1e}, kappa(M^T M) = {kappa_gram:.1e}")
    for nombre, w in [("normales", w_normales), ("QR", w_qr), ("SVD", w_svd)]:
        error = np.linalg.norm(w - w_real) / np.linalg.norm(w_real)
        print(f"{nombre:>8}: error relativo en w = {error:.0e}")
    ```

    ```plaintext title="Expected output"
    kappa(M) = 3.6e+06, kappa(M^T M) = 1.3e+13
    normales: error relativo en w = 2e-04
          QR: error relativo en w = 4e-11
         SVD: error relativo en w = 1e-10
    ```

    Las ecuaciones normales pierden unos doce dígitos de los dieciséis de `float64`,
    como predice $\kappa(\mathbf{M}^{\top}\mathbf{M}) \approx 10^{13}$. QR y SVD
    pierden solo unos seis, los que corresponden a $\kappa(\mathbf{M})$.

### Regularización de Tikhonov

Cuando $\mathbf{X}^{\top}\mathbf{X}$ es casi singular, por columnas correlacionadas o
por tener más características que ejemplos, la solución de mínimos cuadrados es muy
sensible al ruido de los datos. La **regularización de Tikhonov**, que en estadística y
aprendizaje automático se conoce como regresión _Ridge_, añade una penalización sobre la
norma de los pesos:

$$
\mathbf{w}^{\ast} = \arg\min_{\mathbf{w}} \Vert \mathbf{y} - \mathbf{X}\mathbf{w}
\Vert_2^2 + \lambda \Vert \mathbf{w} \Vert_2^2 \quad \Longrightarrow \quad
\left(\mathbf{X}^{\top}\mathbf{X} + \lambda\mathbf{I}\right)\mathbf{w}^{\ast} =
\mathbf{X}^{\top}\mathbf{y}
$$

donde $\lambda > 0$ controla la intensidad de la penalización. Su interpretación
estadística, como reducción de la varianza del estimador, se trata en
[modelos lineales](../03_deep_learning/section_2_linear_models.md). Su interpretación
numérica es directa: sumar $\lambda\mathbf{I}$ desplaza todos los autovalores de
$\mathbf{X}^{\top}\mathbf{X}$ en $\lambda$, de modo que la matriz es siempre definida
positiva y su número de condición pasa a ser:

$$
\kappa_2\left(\mathbf{X}^{\top}\mathbf{X} + \lambda\mathbf{I}\right) =
\frac{\sigma_{\max}^2 + \lambda}{\sigma_{\min}^2 + \lambda}
$$

donde $\sigma_{\max}$ y $\sigma_{\min}$ son los valores singulares extremos de
$\mathbf{X}$. Un $\lambda$ del orden de $\sigma_{\min}^2$ o mayor reduce $\kappa$ de
forma drástica a cambio de introducir un sesgo en la solución. El _jitter_ de la
factorización de Cholesky y el _weight decay_ de las redes neuronales son la misma idea.
En la matriz de Vandermonde del ejemplo anterior, con $\sigma_{\min}^2 \approx 7 \cdot
10^{-12}$, el número de condición de la matriz regularizada pasa de $1.3 \cdot 10^{13}$
sin regularizar a $9 \cdot 10^{5}$ con $\lambda = 10^{-4}$ y a $9 \cdot 10^{3}$ con
$\lambda = 10^{-2}$.

## Método de Newton

### Raíces de ecuaciones no lineales

Dada una función $f: \mathbb{R} \rightarrow \mathbb{R}$ derivable, se busca $x^{\ast}$
con $f(x^{\ast}) = 0$. El **método de Newton-Raphson** sustituye $f$ por su recta
tangente en la aproximación actual $x_k$ y toma como nueva aproximación el corte de esa
recta con el eje horizontal:

$$
x_{k+1} = x_k - \frac{f(x_k)}{f'(x_k)}
$$

Si $f'(x^{\ast}) \neq 0$ y $x_0$ está suficientemente cerca de la raíz, la convergencia
es **cuadrática**: el error cumple $|e_{k+1}| \approx C |e_k|^2$ con $C =
|f''(x^{\ast})| / (2|f'(x^{\ast})|)$, de modo que el número de decimales correctos se
duplica en cada iteración. El método tiene dos inconvenientes. Exige evaluar la derivada
en cada paso y falla cerca de un extremo de $f$, donde $f'(x_k) \approx 0$ y la tangente
casi horizontal envía la siguiente iteración muy lejos. El **método de la secante**
sustituye la derivada por el cociente incremental de las dos últimas iteraciones, a
costa de reducir el orden de convergencia a $(1 + \sqrt{5})/2 \approx 1.618$.

### Newton en optimización

Minimizar una función $f: \mathbb{R}^n \rightarrow \mathbb{R}$ dos veces derivable
equivale a buscar una raíz de su gradiente, como se justifica en
[optimización](section_4_optimization.md). Aplicando Newton a $\nabla f(\mathbf{x}) =
\mathbf{0}$, la derivada del gradiente es la matriz Hessiana $\nabla^2 f$, descrita en
el capítulo de [cálculo vectorial](section_3_vector_calculus.md), y la iteración
resulta:

$$
\mathbf{x}_{k+1} = \mathbf{x}_k - \left(\nabla^2 f(\mathbf{x}_k)\right)^{-1} \nabla
f(\mathbf{x}_k)
$$

Desde el punto de vista numérico, la inversa nunca se calcula. En cada paso se resuelve
el sistema $\nabla^2 f(\mathbf{x}_k)\,\mathbf{d}_k = -\nabla f(\mathbf{x}_k)$ con
`np.linalg.solve`, o con Cholesky si la Hessiana es definida positiva, lo que además
garantiza que $\mathbf{d}_k$ es una dirección de descenso. Si no lo es, se suma
$\lambda\mathbf{I}$ a la Hessiana como en la regularización de Tikhonov, idea que el
método de Levenberg-Marquardt aplica a los mínimos cuadrados no lineales. A diferencia
del descenso del gradiente, el paso de Newton corrige la curvatura y es invariante a
cambios de escala de las variables. En la función de Rosenbrock, $f(x, y) = (1 - x)^2 +
100(y - x^2)^2$, cuyo valle estrecho tiene una Hessiana con número de condición $2508$
en el mínimo $(1, 1)$, Newton llega a él desde $(-1.2, 1)$ en siete iteraciones, donde
el descenso del gradiente con paso fijo necesita decenas de miles.

Su coste, que impide usarlo directamente en aprendizaje profundo, y los métodos
cuasi-Newton que lo aproximan se tratan en el capítulo de
[optimización](section_4_optimization.md).

Las ideas de este capítulo reaparecen en la práctica del aprendizaje profundo: la
_softmax_ estable y la entropía cruzada en
[modelos lineales](../03_deep_learning/section_2_linear_models.md), y la explosión de
gradientes, la inicialización y la normalización en
[redes neuronales](../03_deep_learning/section_3_neural_networks.md).
