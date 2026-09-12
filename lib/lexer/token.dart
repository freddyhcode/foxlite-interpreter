/// class Token.
/// 
/// representa un token generado por el Lexer.
/// Cada token contiene un tipo y un valor.
library;

import 'package:foxlite_interpreter/lexer/token_type.dart';

class Token {
  final TokenType type;
  final String value;

  const Token({
    required this.type,
    required this.value
  });

  @override
  String toString() {
    return "type: $type, value: '$value'";
  }
}