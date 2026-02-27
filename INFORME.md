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