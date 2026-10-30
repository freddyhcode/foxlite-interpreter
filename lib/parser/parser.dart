/// class Parser.
///
/// Parser: se encarga de validar la gramática y generar
/// el árbol de sintaxis abstracta (AST).
library;

import 'package:foxlite_interpreter/ast/ast.dart' as ast;
import 'package:foxlite_interpreter/lexer/lexer.dart';
import 'package:foxlite_interpreter/lexer/token.dart';
import 'package:foxlite_interpreter/lexer/token_type.dart';

class Parser {
  final Lexer lexer;

  Token curToken = const Token(type: TokenType.tpEof, value: "");
  Token peekToken = const Token(type: TokenType.tpEof, value: "");

  List<String> errors = [];

  Parser(this.lexer) {
    nextToken(); // Avanza el primer token
    nextToken(); // Avanza el segundo token
  }

  /// Avanza tanto el token actual como el siguiente token.
  void nextToken() {
    curToken = peekToken;
    peekToken = lexer.nextToken();
  }

  /// Verifica si el token dado es el mismo
  /// que el token actual para avanzarlos.
  void eat(TokenType tokenType) {
    if (curToken.type == tokenType) {
      nextToken();
    } else {
      final msg = "Se esperaba el token: '$tokenType', "
          "y se obtuvo '$curToken.type' en su lugar.";
      errors.add(msg);
    }
  }

  /// program ::= statement (LBREAK statement)* EOF
  ast.Program program() {
    final program = ast.Program();

    while (curToken.type != TokenType.tpEof) {
      final previousToken = curToken;
      final statement = this.statement();

      if (statement != null) {
        program.statements.add(statement);
      }

      // Evita un bucle infinito si la sentencia no consumió ningún token.
      if (identical(curToken, previousToken)) {
        nextToken();
      }
    }

    return program;
  }

  /// block ::= (LBREAK)? (statement)+ 'enddo'
  /// | 'endif' | 'endfunc' (LBREAK)?
  ast.Block block(TokenType endingBlockTokenType) {
    final block = ast.Block();

    if (curToken.type == TokenType.tpLbreak) {
      eat(TokenType.tpLbreak);
    }

    while (curToken.type != endingBlockTokenType &&
        curToken.type != TokenType.tpEof) {
      final previousToken = curToken;
      final statement = this.statement();

      if (statement != null) {
        block.statements.add(statement);
      }

      // Evita un bucle infinito si la sentencia no consumió ningún token.
      if (identical(curToken, previousToken)) {
        nextToken();
      }
    }

    eat(endingBlockTokenType);

    if (curToken.type == TokenType.tpLbreak) {
      eat(TokenType.tpLbreak);
    }

    return block;
  }

  /// statement ::= public_decl
  /// | local_decl
  /// | private_decl
  /// | function_decl
  /// | do_while_decl
  /// | if_decl
  /// | assignment_decl
  /// | return_decl
  /// | print_decl
  /// | expression_decl
  ast.Ast? statement() {
    if (curToken.type == TokenType.tpPublic) {
      return publicDecl();
    } else if (curToken.type == TokenType.tpLocal) {
      return localDecl();
    } else if (curToken.type == TokenType.tpPrivate) {
      return privateDecl();
    } else if (curToken.type == TokenType.tpFunction) {
      return functionDecl();
    } else if (curToken.type == TokenType.tpDo) {
      return doWhileDecl();
    } else if (curToken.type == TokenType.tpIf) {
      return ifDecl();
    } else if (curToken.type == TokenType.tpIdent &&
        peekToken.type == TokenType.tpAssign) {
      return assignmentDecl();
    } else if (curToken.type == TokenType.tpReturn) {
      return returnDecl();
    } else if (curToken.type == TokenType.tpPrint) {
      return printDecl();
    } else {
      return expressionDecl();
    }
  }

  /// public_decl ::= 'public' identifier
  ast.VariableDecl publicDecl() {
    eat(TokenType.tpPublic);
    final ident = identifier();
    return ast.VariableDecl(ident, "public");
  }

  /// local_decl ::= 'local' identifier
  ast.VariableDecl localDecl() {
    eat(TokenType.tpLocal);
    final ident = identifier();
    return ast.VariableDecl(ident, "local");
  }

  /// private_decl ::= 'private' identifier
  ast.VariableDecl privateDecl() {
    eat(TokenType.tpPrivate);
    final ident = identifier();
    return ast.VariableDecl(ident, "private");
  }

  /// function_decl ::= 'function' identifier '(' (params)? ')' block 'endfunc'
  ast.FunctionDecl functionDecl() {
    eat(TokenType.tpFunction);
    final func = ast.FunctionDecl(identifier(), null, null);

    if (curToken.type == TokenType.tpLParen) {
      eat(TokenType.tpLParen);

      if (curToken.type != TokenType.tpRParen) {
        func.params = parseParameters();
      }

      eat(TokenType.tpRParen);
    }

    func.body = block(TokenType.tpEndFunc);

    return func;
  }

  /// parse_parameters ::= identifier ( ',' identifier )*
  List<ast.Ast> parseParameters() {
    final identifiers = [identifier()];

    while (curToken.type == TokenType.tpComma) {
      eat(TokenType.tpComma);
      identifiers.add(identifier());
    }

    return identifiers;
  }

  /// Genera un ast de tipo Identifier()
  ast.Identifier identifier() {
    final name = curToken.value;
    eat(TokenType.tpIdent);

    return ast.Identifier(name);
  }

  /// do_while_decl ::= 'do while' expression_decl block 'enddo'
  ast.DoWhile doWhileDecl() {
    eat(TokenType.tpDo);
    eat(TokenType.tpWhile);

    return ast.DoWhile(
      expressionDecl(),
      block(TokenType.tpEndDo),
    );
  }

  /// if_decl ::= 'if' expression_decl block ( 'else' block )? 'endif'
  ast.IfStatement ifDecl() {
    eat(TokenType.tpIf);

    final ifStmt = ast.IfStatement();
    ifStmt.condition = expressionDecl();
    ifStmt.consequence = ast.Block();

    while (curToken.type != TokenType.tpElse &&
        curToken.type != TokenType.tpEndIf &&
        curToken.type != TokenType.tpEof) {
      final previousToken = curToken;
      final statement = this.statement();

      if (statement != null) {
        ifStmt.consequence!.statements.add(statement);
      }

      // Evita un bucle infinito si la sentencia no consumió ningún token.
      if (identical(curToken, previousToken)) {
        nextToken();
      }
    }

    if (curToken.type == TokenType.tpElse) {
      eat(TokenType.tpElse);
      ifStmt.alternative = block(TokenType.tpEndIf);
    } else {
      eat(TokenType.tpEndIf);
    }

    return ifStmt;
  }

  /// assignment_decl ::= identifier '=' expression_decl
  ast.Assignment assignmentDecl() {
    final ident = identifier();
    eat(TokenType.tpAssign);
    final value = expressionDecl();

    return ast.Assignment(ident, value);
  }

  /// return_decl ::= 'return' (expression_decl)?
  ast.ReturnStmt returnDecl() {
    final returnStmt = ast.ReturnStmt();
    eat(TokenType.tpReturn);

    if (curToken.type != TokenType.tpLbreak) {
      returnStmt.value = expressionDecl();
    } else {
      returnStmt.value = ast.Boolean(true);
    }

    return returnStmt;
  }

  /// print_decl ::= '?' expression_decl ( ',' expression_decl)*
  ast.PrintStmt printDecl() {
    final printStmt = ast.PrintStmt();
    eat(TokenType.tpPrint);

    printStmt.arguments.add(expressionDecl()!);

    while (curToken.type == TokenType.tpComma) {
      eat(TokenType.tpComma);
      printStmt.arguments.add(expressionDecl()!);
    }

    return printStmt;
  }

  /// expression_decl ::= logic_or (LBREAK)?
  ast.Ast? expressionDecl() {
    final exp = logicOr();

    if (curToken.type == TokenType.tpLbreak) {
      eat(TokenType.tpLbreak);
    }

    return exp;
  }

  /// logic_or ::= logic_and ( 'or' logic_and )*
  ast.Ast? logicOr() {
    var orExp = logicAnd();

    while (curToken.type == TokenType.tpOr) {
      final tok = curToken;
      eat(TokenType.tpOr);

      orExp = ast.BinaryOp(orExp!, tok.value, logicAnd()!);
    }

    return orExp;
  }

  /// logic_and ::= equality ( 'and' equality )*
  ast.Ast? logicAnd() {
    var andExp = equality();

    while (curToken.type == TokenType.tpAnd) {
      final tok = curToken;
      eat(TokenType.tpAnd);

      andExp = ast.BinaryOp(andExp!, tok.value, equality()!);
    }

    return andExp;
  }

  /// equality ::= comparison ( ( '==' | '!=' ) comparison )*
  ast.Ast? equality() {
    var compExp = comparison();

    while (curToken.type == TokenType.tpEqual ||
        curToken.type == TokenType.tpNotEqual) {
      final tok = curToken;
      eat(tok.type); // '==' ó '!='

      compExp = ast.BinaryOp(compExp!, tok.value, comparison()!);
    }

    return compExp;
  }

  /// comparison ::= term ( ( '<' | '>' | '<=' | '>=' ) term )*
  ast.Ast? comparison() {
    var termExp = term();

    while (curToken.type == TokenType.tpLess ||
        curToken.type == TokenType.tpLessEq ||
        curToken.type == TokenType.tpGreater ||
        curToken.type == TokenType.tpGreaterEq) {
      final tok = curToken;
      eat(tok.type); // '<' ó '>' ó '<=' ó '>='

      termExp = ast.BinaryOp(termExp!, tok.value, term()!);
    }

    return termExp;
  }

  /// term ::= factor ( ( '+' | '-' ) factor )*
  ast.Ast? term() {
    var factorExp = factor();

    while (curToken.type == TokenType.tpPlus ||
        curToken.type == TokenType.tpMinus) {
      final tok = curToken;
      eat(tok.type); // '+' ó '-'

      factorExp = ast.BinaryOp(factorExp!, tok.value, factor()!);
    }

    return factorExp;
  }

  /// factor ::= unary ( ( '*' | '/' ) unary )*
  ast.Ast? factor() {
    var unaryExp = unary();

    while (curToken.type == TokenType.tpMul ||
        curToken.type == TokenType.tpDiv) {
      final tok = curToken;
      eat(tok.type); // '*' ó '/'

      unaryExp = ast.BinaryOp(unaryExp!, tok.value, unary()!);
    }

    return unaryExp;
  }

  /// unary ::= ( '!' | '-' ) unary | function_call
  ast.Ast? unary() {
    if (curToken.type == TokenType.tpNot ||
        curToken.type == TokenType.tpMinus) {
      final operator = curToken.value;
      eat(curToken.type); // '!' ó '-'

      return ast.UnaryOp(operator, unary()!);
    } else {
      return functionCall();
    }
  }

  /// function_call ::= primary ( '(' arguments? ')' )?
  ast.Ast? functionCall() {
    final primary = this.primary();

    if (curToken.type == TokenType.tpLParen) {
      final functionName = primary as ast.Identifier;
      final functionCall = ast.FunctionCall();
      functionCall.name = functionName;

      eat(TokenType.tpLParen);

      if (curToken.type != TokenType.tpRParen) {
        functionCall.arguments = parseArguments();
      }

      eat(TokenType.tpRParen);

      return functionCall;
    }

    return primary;
  }

  /// parse_arguments ::= expression_decl ( ',' expression_decl )*
  List<ast.Ast> parseArguments() {
    final args = [expressionDecl()!];

    while (curToken.type == TokenType.tpComma) {
      eat(TokenType.tpComma);
      args.add(expressionDecl()!);
    }

    return args;
  }

  /// primary ::= '.t.' | '.f.' | '.null.'
  /// | NUMBER | STRING | IDENTIFIER
  /// | '(' expression_decl ')'
  ast.Ast? primary() {
    final tok = curToken;

    if (tok.type == TokenType.tpTrue || tok.type == TokenType.tpFalse) {
      eat(tok.type); // '.t.' ó '.f.'
      return ast.Boolean(tok.type == TokenType.tpTrue);
    } else if (tok.type == TokenType.tpNull) {
      eat(TokenType.tpNull);
      return ast.Null();
    } else if (tok.type == TokenType.tpInt) {
      eat(TokenType.tpInt);
      return ast.Integer(int.parse(tok.value));
    } else if (tok.type == TokenType.tpString) {
      eat(TokenType.tpString);
      return ast.StringLiteral(tok.value);
    } else if (tok.type == TokenType.tpIdent) {
      return identifier();
    } else if (tok.type == TokenType.tpLParen) {
      eat(TokenType.tpLParen);
      final exp = expressionDecl();
      eat(TokenType.tpRParen);
      return exp;
    }

    return null;
  }
}
