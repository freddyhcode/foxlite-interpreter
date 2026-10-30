# FoxLite Interpreter

![Dart](https://img.shields.io/badge/Dart-3.12-0175C2?logo=dart&logoColor=white)
![Tests](https://img.shields.io/badge/tests-14%20passed-success)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Windows-0078D6?logo=windows)
![Libro](https://img.shields.io/badge/libro-Irwin%20Rodr%C3%ADguez-orange)

Implementación del lenguaje de programación **FoxLite** en Dart.

Este proyecto sigue el enfoque presentado en el libro *Cómo crear un Lenguaje de Programación ¡Sin morir en el intento!* de Irwin Rodríguez, pero la implementación está realizada en Dart.

> El libro construye el intérprete en Python, capítulo por capítulo. Este repositorio es un seguimiento fiel de ese mismo camino: la gramática, el AST, el sistema de objetos, el evaluador y las funciones integradas se mantienen iguales; solo cambia el lenguaje de implementación.

## ¿Qué es FoxLite?

FoxLite es un subconjunto pequeño de **Visual FoxPro**. Es un lenguaje estructurado, sensible a mayúsculas, con tipos nativos, control de flujo, funciones definidas por el usuario y funciones integradas. No tiene programación orientada a objetos.

## Uso del lenguaje

### Comentarios

```foxlite
&& Este es un comentario de una línea
saludo = "Hola Mundo" && Este es otro comentario
```

### Tipos de datos

| Tipo | Ejemplo |
|---|---|
| Integer | `1985` |
| String | `"Hola"` ó `'Hola'` |
| Boolean | `.t.` / `.f.` |
| Null | `.null.` |

### Variables

```foxlite
public nombre
local contador
private acumulado
```

Una declaración de variable se enlaza por defecto con `.f.`. También se puede asignar directamente:

```foxlite
nombre = "FoxLite"
contador = 10
```

### Operadores

```foxlite
&& Unarios
!.t.
-35

&& Aritméticos
1 + 2
10 - 5
3 * 4
10 / 2

&& Relacionales
5 < 10
5 <= 5
10 > 3
10 >= 10
5 == 5
5 != 3

&& Lógicos
.t. and .f.
.t. or .f.
```

### Salida de datos

```foxlite
? "Hola", "Mundo"
? 1985, "es mi año de nacimiento."
? .t., .f., 35, .null.
```

### Control de flujo

```foxlite
if 5 != 5
    ? "son diferentes...!?"
else
    ? "mentira, son iguales..."
endif

i = 1
do while i <= 5
    ? i
    i = i + 1
enddo
```

### Funciones

```foxlite
function sumar(a, b)
    return a + b
endfunc

? sumar(2, 3)
```

### Funciones integradas

| Función | Descripción |
|---|---|
| `len(str)` | Devuelve la longitud de una cadena |
| `type(valor)` | Devuelve `C`, `L`, `N` ó `X` según el tipo |
| `alltrim(str)` | Elimina los espacios de los extremos |
| `messagebox(msg, titulo)` | Muestra un cuadro de diálogo (solo Windows) |

## Ejemplo

```foxlite
function fibonacci(n)
    if n <= 1
        return n
    else
        return fibonacci(n-1) + fibonacci(n-2)
    endif
endfunc

i = 1
do while i <= 10
    ? fibonacci(i)
    i = i + 1
enddo
```

## REPL

```bash
dart pub get
dart run
```

Cada línea que termine en `;` continúa en la siguiente, igual que en Visual FoxPro. `quit` cierra el REPL.

```text
>> function fibonacci(n);
>> if n <= 1;
>> return n;
>> else;
>> return fibonacci(n-1) + fibonacci(n-2);
>> endif;
>> endfunc
function
>> fibonacci(10)
55
>> ? "Hola " + "mundo"
Hola mundo
>> a = 10
10
>> alltrim("  FoxLite  ")
FoxLite
```

## Compilar

```bash
dart compile exe bin/foxlite_interpreter.dart -o dist/foxlite_interpreter.exe
```

El ejecutable queda en `dist/foxlite_interpreter.exe` y no necesita Dart instalado.

## Tests

```bash
dart test
```

## Estructura

```text
bin/
    foxlite_interpreter.dart     Punto de entrada
lib/
    ast/                         Nodos del árbol de sintaxis abstracta
    builtins/                    Funciones integradas
    environment/                 Entornos y tabla de símbolos
    evaluator/                   Evaluador del AST
    lexer/                       Analizador léxico
    object/                      Sistema de objetos
    parser/                      Analizador sintáctico
    repl/                        REPL v1, v2 y v3
docs/
    grammar.md                   Gramática libre de contexto de FoxLite
test/
    foxlite_interpreter_test.dart
```

## Notas de la adaptación a Dart

El libro está escrito en Python; estas son las diferencias mínimas necesarias para portarlo a Dart sin cambiar el diseño:

- `Object`, `String` y `Function` son identificadores propios de Dart, por eso el sistema de objetos usa `FoxLiteObject`, `StringLiteral` y `FunctionObject`.
- `to_string()` se implementa como `toString()`.
- `messagebox()` usa `dart:ffi` en lugar de `ctypes`, y solo funciona en Windows.
- `Environment.set()` usa un helper interno `getEntry()` porque en el libro `get()` devuelve el valor y `set()` necesita el par `[scope, valor]`.

## Licencia

MIT
