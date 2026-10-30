import 'package:foxlite_interpreter/environment/environment.dart';
import 'package:foxlite_interpreter/evaluator/evaluator.dart';
import 'package:foxlite_interpreter/lexer/lexer.dart';
import 'package:foxlite_interpreter/lexer/token_type.dart';
import 'package:foxlite_interpreter/parser/parser.dart';
import 'package:test/test.dart';

/// Genera el AST del código fuente y lo evalúa.
dynamic evaluate(String source, [Environment? env]) {
  final parser = Parser(Lexer('\n$source'));
  final program = parser.program();

  expect(parser.errors, isEmpty);

  return Evaluator().eval(program, env ?? Environment());
}

void main() {
  group('Lexer', () {
    test('reconoce código de varias líneas', () {
      final lexer = Lexer('a = 1\nb = 2');
      final tokens = <String>[];

      while (true) {
        final token = lexer.nextToken();

        if (token.type == TokenType.tpEof) {
          break;
        }

        tokens.add('${token.type.name}:${token.value}');
      }

      expect(tokens, [
        'tpIdent:a',
        'tpAssign:=',
        'tpInt:1',
        'tpLbreak:LBREAK',
        'tpIdent:b',
        'tpAssign:=',
        'tpInt:2',
      ]);
    });

    test('no genera saltos de línea repetidos', () {
      final lexer = Lexer('a = 1\n\n\nb = 2');
      final tokens = <TokenType>[];

      while (true) {
        final token = lexer.nextToken();

        if (token.type == TokenType.tpEof) {
          break;
        }

        tokens.add(token.type);
      }

      expect(tokens.where((type) => type == TokenType.tpLbreak).length, 1);
    });

    test('con código vacío genera EOF', () {
      expect(Lexer('').nextToken().type, TokenType.tpEof);
    });
  });

  group('Parser', () {
    test('genera un ast Assignment', () {
      final parser = Parser(Lexer('\na = 1'));
      final program = parser.program();

      expect(parser.errors, isEmpty);
      expect(program.toString(), 'a = 1');
    });

    test('genera un ast FunctionDecl', () {
      final parser = Parser(Lexer('\nfunction sumar(a,b)\nreturn a + b\nendfunc'));
      final program = parser.program();

      expect(parser.errors, isEmpty);
      expect(
        program.toString(),
        'function sumar(a,b)\n\treturn a + b\nendfunc',
      );
    });

    test('genera un ast PrintStmt', () {
      final parser = Parser(Lexer('\n?1, 2, .t., .null.'));
      final program = parser.program();

      expect(parser.errors, isEmpty);
      expect(program.toString(), '?1,2,.t.,.null.');
    });
  });

  group('Evaluator', () {
    test('respeta la precedencia de operadores', () {
      expect(evaluate('1 + 2 * 3').toString(), '7');
      expect(evaluate('(1 + 2) * 3').toString(), '9');
    });

    test('evalúa operadores relacionales', () {
      expect(evaluate('11 < 15').toString(), 'True');
      expect(evaluate('.t. != .f.').toString(), 'True');
      expect(evaluate('.t. * .f.').toString(),
          'Operador no soportado para el tipo BOOLEAN: \'*\'');
    });

    test('concatena cadenas', () {
      expect(evaluate('"Hola " + "mundo..."').toString(), 'Hola mundo...');
    });

    test('evalúa la sentencia If', () {
      const source = '''
a = 10
if a > 10
?a, " es mayor a 10"
else
?a, " es menor a 10"
endif''';

      expect(evaluate(source), isNull);
    });

    test('evalúa la sentencia Do While', () {
      const source = '''
a = 3
do while a > 0
a = a - 1
enddo
a''';

      expect(evaluate(source).toString(), '0');
    });

    test('evalúa funciones y recursividad', () {
      const source = '''
function fibonacci(n)
if n <= 1
return n
else
return fibonacci(n-1) + fibonacci(n-2)
endif
endfunc
fibonacci(10)''';

      expect(evaluate(source).toString(), '55');
    });

    test('evalúa funciones integradas', () {
      expect(evaluate('len("Hola")').toString(), '4');
      expect(evaluate('alltrim(" Hola ")').toString(), 'Hola');
      expect(evaluate('type(.null.)').toString(), 'X');
      expect(evaluate('type("Hola")').toString(), 'C');
      expect(evaluate('type(1985)').toString(), 'N');
      expect(evaluate('type(.t.)').toString(), 'L');
    });

    test('evalúa cortocircuito en AND', () {
      expect(evaluate('.f. and variable_que_no_existe').toString(), 'False');
    });
  });
}
