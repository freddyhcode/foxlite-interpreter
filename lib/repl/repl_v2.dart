/// class ReplV2.
///
/// REPL para el Parser: en lugar de mostrar los tokens,
/// muestra el árbol de sintaxis abstracta (AST) generado.
library;

// El libro concatena strings paso a paso, por eso mantenemos ese estilo.
// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:io';
import 'package:foxlite_interpreter/lexer/lexer.dart';
import 'package:foxlite_interpreter/parser/parser.dart';

const _foxLite = r"""
 /\ /\ ¡FoxLite!
//\_//\ ____
\_ _/ / /
/ * * \ /^^^]
\_\O/_/ [ ]
/ \_ [ /
\ \_ / /
[ [ / \/ _/
_[ [ \ /_/
""";

const _errorFace = r"""
|\__/|
/ \
/_.@ @,_ \
\@/
""";

class ReplV2 {
  void run() {
    printHeader();

    String sourceCode = "";

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

        // Usamos el ";" para unir declaraciones de más de 1 línea.
        if (userInput[userInput.length - 1] == ";") {
          sourceCode += "\n" + userInput.substring(0, userInput.length - 1);
          continue;
        } else {
          sourceCode += "\n" + userInput;
        }

        if (userInput == "quit") {
          break;
        }

        final lexer = Lexer(sourceCode);
        final parser = Parser(lexer);
        final program = parser.program();

        if (parser.errors.isNotEmpty) {
          printParserErrors(parser.errors);
          break;
        }

        print(program); // Imprimir el ast program.
        sourceCode = "";
      } catch (e) {
        print(e);
      }
    }
  }

  void printParserErrors(List<String> errors) {
    print(_errorFace);
    print("¡Ay caramba! parece que tenemos un problema.");
    print("Errores del Parser:");

    for (final error in errors) {
      print(error);
    }
  }

  void printHeader() {
    print(_foxLite);
    print("¡Hola Mundo! Este es lenguaje de programación FoxLite ");
    print("¡Adelante! Ingresa algunos comandos... \n");
  }
}
