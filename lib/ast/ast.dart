/// Un AST del inglés (Abstract Syntax Tree) es un Árbol de Sintaxis Abstracta  
/// cuyo objetivo es representar la semántica del programa a evaluar. 
library;

abstract class Ast {}

class Program extends Ast {
  List<Ast> statements = [];
}

class Identifier extends Ast {
  String value;

  Identifier(
    this.value
  );
}

class Integer extends Ast {
  int value;

  Integer(
    this.value
  );
}

class StringLiteral extends Ast {
  String value;

  StringLiteral(
    this.value
  );
}

class Boolean extends Ast {
  bool value;

  Boolean(
    this.value
  );
}

class Null extends Ast {
  dynamic value;

  Null(): value = null;
}

class Block extends Ast {
  List<Ast> statements = [];
}

class FunctionDecl extends Ast {
  Identifier name;
  List<Ast> params;
  Block? body;

  FunctionDecl(
    this.name,
    List<Ast>? params,
    this.body,
  ) : params = params ?? [];
}

class FunctionCall extends Ast {
  Identifier? name;
  List<Ast> arguments = [];

  FunctionCall();
}

class DoWhile extends Ast {
  Ast? condition;
  Block? block;
  
  DoWhile(
    this.condition,
    this.block,
  );
}

class IfStatement extends Ast {
  Ast? condition;
  Block? consequence;
  Block? alternative;

  IfStatement();
}

class BinaryOp extends Ast {
  Ast left;
  dynamic operator;
  Ast right;

  BinaryOp(
    this.left,
    this.operator,
    this.right,
  );
}

class UnaryOp extends Ast {
  dynamic operator;
  Ast right;

  UnaryOp(
    this.operator,
    this.right,
  );
}

class VariableDecl extends Ast {
  Identifier name;
  dynamic scope;

  VariableDecl(
    this.name,
    this.scope,
  );
}

class Assignment extends Ast {
  Identifier name;
  Ast? value;

  Assignment(
    this.name, 
    [this.value,]
  );
}

class ReturnStmt extends Ast {
  Ast? value;

  ReturnStmt([
    this.value,
  ]);
}

class PrintStmt extends Ast {
  List<Ast> arguments = [];

  PrintStmt();
}
