# Syntax Directed Translation with Jison

Jison is a tool that receives as input a Syntax Directed Translation and produces as output a JavaScript parser  that executes
the semantic actions in a bottom up ortraversing of the parse tree.
 

## Compile the grammar to a parser

See file [grammar.jison](./src/grammar.jison) for the grammar specification. To compile it to a parser, run the following command in the terminal:
``` 
➜  jison git:(main) ✗ npx jison grammar.jison -o parser.js
```

## Use the parser

After compiling the grammar to a parser, you can use it in your JavaScript code. For example, you can run the following code in a Node.js environment:

```
➜  jison git:(main) ✗ node                                
Welcome to Node.js v25.6.0.
Type ".help" for more information.
> p = require("./parser.js")
{
  parser: { yy: {} },
  Parser: [Function: Parser],
  parse: [Function (anonymous)],
  main: [Function: commonjsMain]
}
> p.parse("2*3")
6
```

# Práctica 4
## Pasos seguidos

1. Instalar dependencias del proyecto `npx jison src/grammar.jison -o src/parser.js`
2. Producir el parser `npx jison src/grammar.jison -o src/parser.js`
3. Ejecutar las pruebas `npm test`

## Preguntas

### Describa la diferencia entre /* skip whitespace */ y devolver un token
Cuando el lexer devuelve un token el parser lo recibe y decide qué hacer con él. Por otra parte,
/* skip whitespace */ no devuelve nada por lo que el parser no tiene conocimiento de él y no
necesita hacer nada.

### Escriba la secuencia exacta de tokens producidos para la entrada 123**45+@
Devuelve: 
1. NUMBER (123)
2. OP (**)
3. NUMBER (45)
4. OP (+)
4. INVALID (@)

### Explique cuándo se devuelve EOF
Cuando el sistema detecta que ya no hay más flujo de entrada.

### Explique por qué existe la regla . que devuelve INVALID
Para poder tratar de manera segura los carácteres inválidos como '@'

## Modificaciones
### Saltar comentarios de una línea
Se ha añadido la siguiente regla en el jison para saltar comentarios de una línea
```
"//".*              { /* skip comment */; }
```
### Leer números flotantes
Se ha añadido lo siguiente en el jison para leer y operar con números flotantes
```
/* lexer */ 
[0-9]+\.[0-9][0-9]([eE][+-][0-9]+)? { return 'FLOAT' }

/* ... */

/* parser */
%token FLOAT
/* ... */
expression
    : expression OP term
        { $$ = operate($OP, $expression, $term); }
    | term
        { $$ = $term; }
    ;
/* ... */
```

### Pruebas
Se han añadido las siguientes pruebas:
```javascript
describe('Tests comentarios', () => {
    test('salta comentarios en medio de la expresión', () => {
      expect(parse("2 + 2 // suma")).toBe(4);
      expect(parse("3 * 3 // multiplicación\n+ 1")).toBe(10);
    });
  });

  describe('Tests números flotantes', () => {
    test('lee números flotantes', () => {
      expect(parse("2.50 + 2.50")).toBe(5);
      expect(parse("0.10e+0 * 10")).toBe(1);
      expect(parse("0.10E+0 * 10")).toBe(1);
    });
  });
```
# Práctica 5
## 1. Partiendo de la gramática y las siguientes frases 4.0-2.0*3.0, 2\*\*3\*\*2 y 7-4/2:
### 1.1 Escriba la derivación para cada una de las frases.

**4.0 - 2.0 * 3.0**

expressions => expression EOF => expression OP[*] term[3.0] => expression OP[-] term[2.0] OP[*] term[3.0] => term[4.0] OP[-] term[2.0] OP[*] term[3.0]  

**2\*\*3\*\*2**

expressions => expression EOF => expression OP[\*\*] term[2] => expression OP[\*\*] term[2] OP[\*\*] term[2] => term[2] OP[\*\*] term[2] OP[\*\*] term[2]

**7-4/2**

expressions => expression EOF => expression OP[/] term[2] => expression OP[-] term[4] OP[/] term[2] => term[7] OP[-] term[4] OP[/] term[2]

### 1.2 Escriba el árbol de análisis sintáctico (parse tree) para cada una de las frases.

**4.0 - 2.0 * 3.0**

E - T - 3.0
 
 \ OP - *
 
 \ E - T - 2.0
    
    \ OP - -(menos)
    
    \ E - T - 4.0

**2\*\*3\*\*2**

E - T - 2
 
 \ OP - \*\*
 
 \ E - T - 3
    
    \ OP - **
    
    \ E - T - 2

**7-4/2**

E - T - 2
 
 \ OP - /
 
 \ E - T - 4
    
    \ OP - -(menos)
    
    \ E - T - 7

### 1.3 ¿En qué orden se evaluan las acciones semánticas para cada una de las frases?

El orden se evalua de izquierda a derecha independientemente de las operaciones a realizar, esto se debe
a la SDD.

### 1.4 Añada un fichero prec.test.js al directorio __test__ con las siguientes pruebas y compruebe que con la implementación actual fallan.

He añadido el fichero con el contenido indicado y he comprobado que fallan los tests.

## 2. Modifique la gramática del fichero grammar.jison de manera que se respete la precedencia y la asociatividad de los operadores matemáticos.

Actualicé el lexer con las nuevas expresiones regulares.

```
%lex
%%
\s+                   { /* skip whitespace */; }
"//".*              { /* skip comment */; }
[0-9]+\.[0-9]([0-9])?([eE][+-][0-9]+)? { return 'NUMBER' }
[0-9]+                { return 'NUMBER';       }
"**"                  { return 'OPOW';         }
[-+]                  { return 'OPAD';         }
[*/]                  { return 'OPMU';         }
<<EOF>>               { return 'EOF';          }
.                     { return 'INVALID';      }
/lex
```
Y actualicé las reglas para respetar la precedencia y la asociatividad de los operadores matemáticos:
```
%start expressions
%token NUMBER
%%

expressions
    : expression EOF
        { return $expression; }
    ;

expression
    : expression OPAD term
        { $$ = operate($OPAD, $expression, $term); }
    | term
        { $$ = $term; } 
    ;

term
    //: NUMBER
      //  { $$ = Number(yytext); }
    : term OPMU R
        { $$ = operate($OPMU, $term, $R); }
    | R
        { $$ = $R; }
    ;

R
    : F OPOW R
        { $$ = operate($OPOW, $F, $R); }
    | F
        { $$ = $F; }
    ;


F
    : NUMBER
        { $$ = Number(yytext); }
    ;
%%
```

## 3. Añada los test correspondientes para comprobar que se respeta la precedencia y asociatividad con flotantes.

Añadí una prueba con varios test para comprobar que se respeta la precedencia y asociatividad con flotantes.

```javascript
test('should handle various realistic calculations of floats with correct precedence', () => {
    expect(parse("1.0 + 2.0 * 3.0")).toBe(7.0);
    expect(parse("1.0 - 2.0 * 3.0")).toBe(-5.0);
    expect(parse("6.0 / 1.5 + 4.5")).toBe(8.5);
    expect(parse("2.0 ** 2.0 + 1.5")).toBe(5.5); 
    expect(parse("2.0 ** 3.0 ** 2.0")).toBe(512.0); // 2.0 ** (3.0 ** 2.0) = 2.0 ** 9.0 = 512.0
  });
```
La gramática pasó el test con éxito.

## 4. Modifique el programa Jison para que se reconozcan expresiones entre paréntesis.

Añadí en el lexer las siguientes expresiones regulares
```
[(]                   { return '('; }
[)]                   { return ')'; }
```
Y en el parser añadí la siguiente regla
```
F
    : NUMBER
        { $$ = Number(yytext); }
    | '(' expression ')'
        { $$ = $expression; }
    ;
%%
```

## 5. Añada los test correspondientes para las expresiones entre paréntesis.
Añadí una prueba con varios test para comprobar que se le da prioridad a los paréntesis
```javascript
test('Parenthesis', () => {
    expect(parse("(1 + 2) * 3")).toBe(9);
    expect(parse("6 / (2 + 4)")).toBe(1); // 6 / (2 + 4) = 6 / (6) = 6 / 6 = 1
  });
```
La gramática pasó el test con éxito.