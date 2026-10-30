/// Sistema de objetos: es la representación interna de los
/// tipos de datos que ofrece FoxLite.
library;

enum Type {
  integer("INTEGER"),
  string("STRING"),
  boolean("BOOLEAN"),
  nullType("NULL"),
  function("FUNCTION"),
  returnType("RETURN"),
  error("ERROR"),
  builtin("BUILTIN");

  final String value;

  const Type(this.value);

  @override
  String toString() {
    return "Type.$value";
  }
}

/// Object será la clase base de todos los objetos.
///
/// En Dart `Object` ya existe en dart:core, por eso la clase
/// base se llama FoxLiteObject.
abstract class FoxLiteObject {
  Type type();

  @override
  String toString();
}

class Integer extends FoxLiteObject {
  num value;

  Integer(
    this.value
  );

  @override
  String toString() {
    return value.toString();
  }

  @override
  Type type() {
    return Type.integer;
  }
}

class Boolean extends FoxLiteObject {
  bool value;

  Boolean(
    this.value
  );

  @override
  String toString() {
    return value ? "True" : "False";
  }

  @override
  Type type() {
    return Type.boolean;
  }

  @override
  bool operator ==(Object other) {
    return other is Boolean && other.value == value;
  }

  @override
  int get hashCode {
    return value.hashCode;
  }
}

class Null extends FoxLiteObject {
  dynamic value;

  Null(): value = null;

  @override
  String toString() {
    return "Null";
  }

  @override
  Type type() {
    return Type.nullType;
  }
}

class StringLiteral extends FoxLiteObject {
  String value;

  StringLiteral(
    this.value
  );

  @override
  String toString() {
    return value;
  }

  @override
  Type type() {
    return Type.string;
  }
}

class Return extends FoxLiteObject {
  FoxLiteObject value;

  Return(
    this.value
  );

  @override
  String toString() {
    return value.toString();
  }

  @override
  Type type() {
    return Type.returnType;
  }
}

/// En Dart `Function` es un identificador reservado, por eso
/// la clase se llama FunctionObject.
class FunctionObject extends FoxLiteObject {
  String name;
  List<dynamic> params;
  dynamic body;
  dynamic env;

  FunctionObject({
    required this.name,
    required this.params,
    required this.body,
    required this.env,
  });

  @override
  String toString() {
    return "function";
  }

  @override
  Type type() {
    return Type.function;
  }
}

class Error extends FoxLiteObject {
  String message;

  Error(
    this.message
  );

  @override
  String toString() {
    return message;
  }

  @override
  Type type() {
    return Type.error;
  }
}

class Builtin extends FoxLiteObject {
  FoxLiteObject? Function(List<FoxLiteObject> args) function;

  Builtin(
    this.function
  );

  @override
  String toString() {
    return "builtin function";
  }

  @override
  Type type() {
    return Type.builtin;
  }
}
