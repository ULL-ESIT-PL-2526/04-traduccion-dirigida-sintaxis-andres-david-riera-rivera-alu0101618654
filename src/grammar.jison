/* Lexer */
%lex
%%
\s+                   { /* skip whitespace */; }
"//".*              { /* skip comment */; }
[(]                   { return '('; }
[)]                   { return ')'; }  
[0-9]+\.[0-9]([0-9])?([eE][+-][0-9]+)? { return 'NUMBER' }
[0-9]+                { return 'NUMBER';       }
"**"                  { return 'OPOW';         }
[-+]                  { return 'OPAD';         }
[*/]                  { return 'OPMU';         }
<<EOF>>               { return 'EOF';          }
.                     { return 'INVALID';      }
/lex

/* Parser */
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
    | '(' expression ')'
        { $$ = $expression; }
    ;
%%

function operate(op, left, right) {
    switch (op) {
        case '+': return left + right;
        case '-': return left - right;
        case '*': return left * right;
        case '/': return left / right;
        case '**': return Math.pow(left, right);
    }
}
