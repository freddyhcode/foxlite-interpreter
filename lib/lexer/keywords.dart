/// Clase Keywords.
///
/// contiene las palabras reservadas del lenguaje
/// y permite determinar si un identificador corresponde
/// a una palabra reservada.
library;

import 'package:foxlite_interpreter/lexer/token_type.dart';

class Keywords {
  
  /// Diccionario de palabras reservadas 
  static final Map<String, TokenType> keywords = {
    "function": TokenType.tpFunction,
    "endfunc": TokenType.tpEndFunc,
    "do": TokenType.tpDo,
    "while": TokenType.tpWhile,
    "enddo": TokenType.tpEndDo,
    "if": TokenType.tpIf,
    "else": TokenType.tpElse,
    "endif": TokenType.tpEndIf,
    "return": TokenType.tpReturn,
    "public": TokenType.tpPublic,
    "local": TokenType.tpLocal,
    "private": TokenType.tpPrivate,
    ".t.": TokenType.tpTrue,
    ".f.": TokenType.tpFalse,
    ".null.": TokenType.tpNull,
    "and": TokenType.tpAnd,
    "or": TokenType.tpOr,
  };

  /// Comprueba si el string es una palabra reservada
  /// o un identificador.
  ///
  /// [ident] es el string a evaluar.
  ///
  /// Retorna un [TokenType].
  static TokenType lookupIdent(String ident) {
    final TokenType? tokenType = keywords[ident];

    if (tokenType != null) {
      return tokenType;
    }

    return TokenType.tpIdent;
  }
}