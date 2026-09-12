/// class ReplV1.
///
/// REPL: llamada así por las fases que realiza durante 1 ciclo:
///
/// R: Read - Leer y analizar (parse) el código fuente.
/// E: Eval - Evaluar el AST generado por el parser.
/// P: Print - Imprimir el resultado en la consola.
/// L: Loop - Repetir el ciclo.
library;

import 'dart:io';
import 'package:foxlite_interpreter/lexer/lexer.dart';

class ReplV1 {
  static const foxLite = "FoxLite";

  void run() {
    print(foxLite);
    print("");

    String sourceCode = '';
    while (true) {
      try {
        stdout.write(">> ");
        final userInput = stdin.readLineSync();

        if (userInput == null) {
          break;
        }

        if (userInput.isEmpty) {
          continue;
        }

        if (userInput == 'quit') {
          break;
        }

        sourceCode = userInput;
        final lexer = Lexer(sourceCode);
        var token = lexer.nextToken();

        while (token.value != '') {
          print(token);
          token = lexer.nextToken();
        }
      } catch (e) {
        print(e);
      }
    }
  }
}
