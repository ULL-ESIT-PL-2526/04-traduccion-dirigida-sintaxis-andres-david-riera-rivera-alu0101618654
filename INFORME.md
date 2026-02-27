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