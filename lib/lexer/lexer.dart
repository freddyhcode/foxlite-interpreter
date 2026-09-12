/// class Lexer.
/// 
/// también conocido como tokenizer, se encarga de leer y  
/// descomponer el código fuente en pequeñas unidades llamadas tokens. 
library;

import 'package:foxlite_interpreter/lexer/keywords.dart';
import 'package:foxlite_interpreter/lexer/token.dart';
import 'package:foxlite_interpreter/lexer/token_type.dart';

class Lexer {
  final String source;
  int currentPos = 0;
  String currentChar = "";
  String? lastTokenValue;

  Lexer(this.source) {
    currentChar = source[0];
  } 

  /// Crea un token y actualiza el valor del último token generado.
  ///
  /// [tokenType] es el tipo del token a generar.
  /// [tokenValue] es el valor o lexema del token a generar.
  ///
  /// Retorna un [Token].
  Token newToken(TokenType tokenType, String tokenValue) {
    final token = Token(
      type: tokenType, 
      value: tokenValue
    );

    lastTokenValue = tokenValue;
    
    return token;
  }

  /// Mueve el puntero a la siguiente posición del código fuente.
  void advance() {
    currentPos += 1;

    if (currentPos >= source.length) {
      currentChar = "";
    } else {
      currentChar = source[currentPos];
    }
  }

  /// Mira 1 carácter hacia adelante en el código fuente.
  ///
  /// Retorna [String?].
  String? peek() {
    final int peekPosition = currentPos + 1;
    if (peekPosition >= source.length) {
      return null;
    } else {
      return source[peekPosition];
    }
  }

  /// Extrae un número entero y genera un token de tipo INT.
  /// 
  /// Retorna un [Token].
  Token isNumber() {
    String lexeme = "";
    while (currentChar != "" && _isDigit(currentChar) ) {
      lexeme += currentChar;
      advance();
    }
    return newToken(TokenType.tpInt, lexeme);
  }

  /// Obtiene una secuencia de caracteres String.
  /// 
  /// [stringDelim] permite comilla simple y doble.
  /// 
  /// Retorna un [Token].
  Token isString(String stringDelim) {
    advance(); // Avanza el primer delimitador del string
    String lexeme = "";
    while (currentChar != "" && currentChar != stringDelim) {
      lexeme += currentChar;
      advance();
    }
    advance(); // Avanza el segundo delimitador del string
    return newToken(TokenType.tpString, lexeme);
  }
  
  /// Obtiene un identificador
  /// 
  /// Retorna un [Token].
  Token identifier() {
    String lexeme = "";
    while (currentChar != "" && _isLetter(currentChar)) {
      lexeme += currentChar;
      advance();
    }
    final TokenType tokenType = Keywords.lookupIdent(lexeme);
    return newToken(tokenType, lexeme);
  }

  /// Extrae un identificador encerrado con "." ej: .t., .f., .null.
  /// 
  /// Retorna un [Token].
  Token dottedIdentifier() {
    final String dot = ".";
    String lexeme = dot;
    advance();
    while (currentChar != "" && currentChar != dot) {
      lexeme += currentChar;
      advance();
    }
    lexeme += dot;
    advance();
    TokenType tokenType = Keywords.lookupIdent(lexeme);
    return newToken(tokenType, lexeme);
  }

  /// Ignora los espacios en blanco, tabulaciones y retornos de carro.
  void ignoreBlanks() {
    while (currentChar != "" && _isSpace(currentChar)) {
      advance();
    }
  }

  /// Ignora los comentarios de "&&" 
  /// Avanza los caracteres hasta el final de la linea.
  void ignoreComments() {
    while (currentChar != "" && currentChar != "\n") {
      advance();
    }
  }

  /// Extrae el siguiente token desde el código fuente.
  ///
  /// Retorna un [Token].
  Token nextToken() {
    while (currentChar != "") {
      // Salto de linea
      if (currentChar == "\n") {
        // Si el token anterior no es LBREAK entonces generamos el token LBREAK
        if (lastTokenValue != "" && lastTokenValue != TokenType.tpLbreak.value) {
          return newToken(TokenType.tpLbreak, TokenType.tpLbreak.value);
        }
      }

      // Ignoramos los espacios en blanco
      if (_isSpace(currentChar)) {
        ignoreBlanks();
        continue;
      }

      // Ignoramos los comentarios
      if (currentChar == "&" && peek() == "&") {
        ignoreComments();
        continue;
      }

      // Caracteres de 1 digito de longitud
      if (currentChar == "+") {
        advance();
        return newToken(TokenType.tpPlus, TokenType.tpPlus.value);
      }

      if (currentChar == "-") {
        advance();
        return newToken(TokenType.tpMinus, TokenType.tpMinus.value);
      }

      if (currentChar == "*") {
        advance();
        return newToken(TokenType.tpMul, TokenType.tpMul.value);
      }

      if (currentChar == "/") {
        advance();
        return newToken(TokenType.tpDiv, TokenType.tpDiv.value);
      }

      if (currentChar == "(") {
        advance();
        return newToken(TokenType.tpLParen, TokenType.tpLParen.value);
      }

      if (currentChar == ")") {
        advance();
        return newToken(TokenType.tpRParen, TokenType.tpRParen.value);
      }

      if (currentChar == ",") {
        advance();
        return newToken(TokenType.tpComma, TokenType.tpComma.value);
      }

      // Caracteres de 1 o mas digitos de longitud
      if (currentChar == "=") {
        advance(); // Avanza el "="
        if (currentChar == "=" ) {
          advance(); // Avanza el segundo "="
          return newToken(TokenType.tpEqual, TokenType.tpEqual.value);
        }
        return newToken(TokenType.tpAssign, TokenType.tpAssign.value);
      }

      if (currentChar == "!") {
        advance(); // Avanza el "!"
        if (currentChar == "=") {
          advance(); // Avanza el "="
          return newToken(TokenType.tpNotEqual, TokenType.tpNotEqual.value);
        }
        return newToken(TokenType.tpNot, TokenType.tpNot.value);
      }

      if (currentChar == "<") {
        advance(); // Avanza el "<"
        if (currentChar == "=") {
          advance(); // Avanza el "="
          return newToken(TokenType.tpLessEq, TokenType.tpLessEq.value);
        }
        return newToken(TokenType.tpLess, TokenType.tpLess.value);
      }

      if (currentChar == ">") {
        advance(); // Avanza el ">"
        if (currentChar == "=") {
          advance(); // Avanza el "="
          return newToken(TokenType.tpGreaterEq, TokenType.tpGreaterEq.value);
        }
        return newToken(TokenType.tpGreater, TokenType.tpGreater.value);
      }

      // Caracter de impresion
      if (currentChar == "?") {
        advance();
        return newToken(TokenType.tpPrint, TokenType.tpPrint.value);
      }
      
      // Números
      if (_isDigit(currentChar)) {
        return isNumber();
      }

      // Identificadores
      if (_isLetter(currentChar)) {
        return identifier();
      }

      // Palabra reservada encerradas en puntos
      if (currentChar == ".") {
        return dottedIdentifier();
      }

      // Secuencia de caracteres (String)
      if (currentChar == '"'|| currentChar == "'") {
        return isString(currentChar); 
      }

      throw Exception(
        "Error: caracter desconocido $currentChar"
      );
    }

    return newToken(TokenType.tpEof, "");
  }

  /// Determina si un carácter es un dígito.
  ///
  /// [ch] es el carácter a evaluar.
  ///
  /// Retorna [bool].
  bool _isDigit(String ch) {
    return RegExp(r'^[0-9]$').hasMatch(ch);
  }

  /// Determina si el carácter es alfanumérico o guion bajo.
  ///
  /// [ch] es el carácter a evaluar.
  ///
  /// Retorna [bool].
  bool _isLetter(String ch) {
    return RegExp(r'^[a-zA-Z0-9_]$').hasMatch(ch);
  }

  /// Determina si el carácter es un espacio en blanco,
  /// tabulación o retorno de carro.
  ///
  /// El Line Feed (ENTER) no lo ignoramos porque es relevante.
  ///
  /// [ch] es el carácter a evaluar.
  ///
  /// Retorna [bool].
  bool _isSpace(String ch) {
    return ch == " " || ch == "\t" || ch == "\r";
  }
}