```text
program ::= statement (LBREAK statement)* EOF
block ::= (LBREAK)? (statement)+ 'enddo'
| 'endif' | 'endfunc' (LBREAK)?
statement ::= public_decl | local_decl | private_decl
| function_decl | do_while_decl | if_decl
| assignment_decl | return_decl
| print_decl | expression_decl
public_decl ::= 'public' identifier
local_decl ::= 'local' identifier
private_decl ::= 'private' identifier
function_decl ::= 'function' '(' ( params )? ')' block 'endfunc'
do_while_decl ::= 'do while' expression_decl block 'enddo'
if_decl ::= 'if' expression_decl block ('else' block)? 'endif'
assignment_decl ::= identifier '=' expression_decl
return_decl ::= 'return' expression_decl
print_decl ::= '?' expression_decl ( ',' expression_decl)*
expression_decl ::= logic_or (LBREAK)?
logic_or ::= logic_and ('or' logic_and )*
logic_and ::= equality ('and' equality )*
equality ::= comparison ( ('==' | '!=') comparison )*
comparison ::= term ( ( '<' | '>' | '<=' | '>=' ) term )*
term ::= factor ( ( '+' | '-' ) factor )*
factor ::= unary ( ( '*' | '/' ) unary )*
unary ::= ( '!' | '-') unary | function_call
function_call ::= primary ( '(' arguments? ')' )?
primary ::= '.t.' | '.f.' | '.null.'
| NUMBER | STRING | IDENTIFIER
| '(' expression_decl ')'
```
