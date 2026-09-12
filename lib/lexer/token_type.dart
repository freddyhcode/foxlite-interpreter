/// enum TokenType.
/// 
/// identifica cada uno de los símbolos,
/// identificadores y palabras reservadas que aparecen en el
/// código fuente y que el Lexer deberá reconocer.
library;

enum TokenType {
  tpEof('EOF'), // Fin de codigo
  tpLbreak('LBREAK'), // Nueva linea

  // Identificadores y literales
  tpIdent('IDENT'), // add, foobar, x, y, ...
  tpInt('INT'), // 123456

  // Operadores aritméticos
  tpAssign('='),
  tpPlus('+'),
  tpMinus('-'),
  tpMul('*'),
  tpDiv('/'),

  // Operadores relacionales
  tpNot('!'),
  tpLess('<'),
  tpGreater('>'),
  tpLessEq('<='),
  tpGreaterEq('>='),
  tpEqual('=='),
  tpNotEqual('!='),

  // Operadores lógicos
  tpAnd('and'),
  tpOr('or'),

  // Caracteres especiales
  tpComma(','),
  tpDot('.'),
  tpLParen('('),
  tpRParen(')'),
  tpAmper('&'),
  tpPrint('?'),
  tpString('STRING'),

  // Funciones
  tpFunction('function'),
  tpEndFunc('endfunc'),

  // Do While
  tpDo('do'),
  tpWhile('while'),
  tpEndDo('enddo'),

  // If / Endif
  tpIf('if'),
  tpElse('else'),
  tpEndIf('endif'),
  tpReturn('return'),

  // Declaración de variables
  tpPublic('public'),
  tpLocal('local'),
  tpPrivate('private'),

  // Boolean
  tpTrue('true'),
  tpFalse('false'),
  tpNull('null');

  final String value;

  const TokenType(this.value);
}