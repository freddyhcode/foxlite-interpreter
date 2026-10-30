/// Un AST del inglés (Abstract Syntax Tree) es un Árbol de Sintaxis Abstracta  
/// cuyo objetivo es representar la semántica del programa a evaluar. 
library;

// El libro concatena strings paso a paso para mostrar el AST,
// por eso mantenemos ese mismo estilo.
// ignore_for_file: prefer_interpolation_to_compose_strings

abstract class Ast {}

class Program extends Ast {
  List<Ast> statements = [];

  @override
  String toString() {
    var output = "";
    for (final statement in statements) {
      output += statement.toString();
    }
    return output;
  }
}

class Identifier extends Ast {
  String value;

  Identifier(
    this.value
  );

  @override
  String toString() {
    return value;
  }
}

class Integer extends Ast {
  int value;

  Integer(
    this.value
  );

  @override
  String toString() {
    return value.toString();
  }
}

class StringLiteral extends Ast {
  String value;

  StringLiteral(
    this.value
  );

  @override
  String toString() {
    return value;
  }
}

class Boolean extends Ast {
  bool value;

  Boolean(
    this.value
  );

  @override
  String toString() {
    return value ? ".t." : ".f.";
  }
}

class Null extends Ast {
  dynamic value;

  Null(): value = null;

  @override
  String toString() {
    return ".null.";
  }
}

class Block extends Ast {
  List<Ast> statements = [];

  @override
  String toString() {
    var output = "";
    for (final statement in statements) {
      output += statement.toString();
    }
    return output;
  }
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

  @override
  String toString() {
    var output = "function";
    output += " " + name.toString();
    output += "(";

    final paramsList = <String>[];
    for (final param in params) {
      paramsList.add(param.toString());
    }

    output += paramsList.join(",");
    output += ")";
    output += "\n";
    output += "\t" + body.toString();
    output += "\n";
    output += "endfunc";

    return output;
  }
}

class FunctionCall extends Ast {
  Identifier? name;
  List<Ast> arguments = [];

  FunctionCall();

  @override
  String toString() {
    var output = name.toString();
    output += "(";

    final args = <String>[];
    for (final arg in arguments) {
      args.add(arg.toString());
    }

    output += args.join(",");
    output += ")";

    return output;
  }
}

class DoWhile extends Ast {
  Ast? condition;
  Block? block;
  
  DoWhile(
    this.condition,
    this.block,
  );

  @override
  String toString() {
    var output = "do while ";
    output += condition.toString();
    output += "\n";
    output += "\t" + block.toString();
    output += "\n";
    output += "enddo";

    return output;
  }
}

class IfStatement extends Ast {
  Ast? condition;
  Block? consequence;
  Block? alternative;

  IfStatement();

  @override
  String toString() {
    var output = "if ";
    output += condition.toString();
    output += "\n";
    output += "\t" + consequence.toString();

    if (alternative != null && alternative!.statements.isNotEmpty) {
      output += "\n";
      output += "else";
      output += "\n";
      output += "\t" + alternative.toString();
    }

    output += "\n";
    output += "endif";

    return output;
  }
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

  @override
  String toString() {
    var output = left.toString();
    output += " ";
    output += operator.toString();
    output += " ";
    output += right.toString();

    return output;
  }
}

class UnaryOp extends Ast {
  dynamic operator;
  Ast right;

  UnaryOp(
    this.operator,
    this.right,
  );

  @override
  String toString() {
    var output = operator.toString();
    output += right.toString();

    return output;
  }
}

class VariableDecl extends Ast {
  Identifier name;
  dynamic scope;

  VariableDecl(
    this.name,
    this.scope,
  );

  @override
  String toString() {
    var output = scope.toString();
    output += " " + name.toString();

    return output;
  }
}

class Assignment extends Ast {
  Identifier name;
  Ast? value;

  Assignment(
    this.name, 
    [this.value,]
  );

  @override
  String toString() {
    var output = name.toString();
    output += " = ";
    output += value.toString();

    return output;
  }
}

class ReturnStmt extends Ast {
  Ast? value;

  ReturnStmt([
    this.value,
  ]);

  @override
  String toString() {
    var output = "return ";
    output += value.toString();

    return output;
  }
}

class PrintStmt extends Ast {
  List<Ast> arguments = [];

  PrintStmt();

  @override
  String toString() {
    var output = "?";

    final args = <String>[];
    for (final arg in arguments) {
      args.add(arg.toString());
    }

    output += args.join(",");

    return output;
  }
}
