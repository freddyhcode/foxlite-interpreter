/// class Evaluator.
///
/// Evaluador: se encarga de recorrer el AST y ejecutar
/// cada una de sus sentencias y expresiones.
library;

// TRUE, FALSE y NULL son los nombres que usa el libro.
// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:foxlite_interpreter/ast/ast.dart' as ast;
import 'package:foxlite_interpreter/builtins/fox_lite_builtins.dart';
import 'package:foxlite_interpreter/environment/environment.dart';
import 'package:foxlite_interpreter/object/fox_lite_object.dart' as obj;

final TRUE = obj.Boolean(true);
final FALSE = obj.Boolean(false);
final NULL = obj.Null();

/// Verifica si el objeto dado es de tipo obj.Error()
bool isError(dynamic valueObj) {
  return valueObj != null && valueObj.type() == obj.Type.error;
}

/// Retorna un objeto de tipo obj.Error() con la informaciÃ³n del error.
obj.Error newError(String message) {
  return obj.Error(message);
}

/// Realiza las operaciones unarias y devuelve el objeto resultante.
obj.FoxLiteObject evalUnaryExpression(
  String operator,
  obj.FoxLiteObject rightObj,
) {
  if (operator == "!") {
    if (rightObj.type() != obj.Type.boolean) {
      return newError("Tipo de dato incompatible. Se esperaba un BOOLEAN");
    } else if (rightObj == TRUE) {
      return FALSE;
    } else if (rightObj == FALSE) {
      return TRUE;
    }
  } else if (operator == "-") {
    if (rightObj.type() != obj.Type.integer) {
      return newError("Tipo de dato incompatible. Se esperaba un INTEGER");
    } else {
      return obj.Integer(-(rightObj as obj.Integer).value);
    }
  }

  return NULL;
}

/// Realiza operaciones binarias y devuelve el objeto correspondiente.
obj.FoxLiteObject? evalBinaryExpression(
  obj.FoxLiteObject leftObj,
  String operator,
  obj.FoxLiteObject rightObj,
) {
  if (leftObj.type() == obj.Type.integer &&
      rightObj.type() == obj.Type.integer) {
    if (operator == "+" ||
        operator == "-" ||
        operator == "*" ||
        operator == "/") {
      return evalNativeIntegerToIntegerObject(leftObj, operator, rightObj);
    } else if (isRelationalOperator(operator)) {
      return evalNativeIntegerToBooleanObject(leftObj, operator, rightObj);
    } else {
      return newError(
        "Operador no soportado para el tipo INTEGER: '$operator'",
      );
    }
  } else if (leftObj.type() == obj.Type.string &&
      rightObj.type() == obj.Type.string) {
    if (operator == "+" || operator == "==" || operator == "!=") {
      return evalNativeStringToObject(leftObj, operator, rightObj);
    } else {
      return newError(
        "Operador no soportado para el tipo STRING: '$operator'",
      );
    }
  } else if (leftObj.type() == obj.Type.boolean &&
      rightObj.type() == obj.Type.boolean) {
    if (isRelationalOperator(operator)) {
      return evalNativeBooleanToBooleanObject(leftObj, operator, rightObj);
    } else {
      return newError(
        "Operador no soportado para el tipo BOOLEAN: '$operator'",
      );
    }
  } else if (leftObj.type() != rightObj.type()) {
    return newError(
      "Incompatibilidad de tipos: ${leftObj.type()}, ${rightObj.type()} ",
    );
  }

  return NULL;
}

/// Determina si el operador dado es de origen relacional.
bool isRelationalOperator(String operator) {
  return operator == "<" ||
      operator == ">" ||
      operator == "<=" ||
      operator == ">=" ||
      operator == "==" ||
      operator == "!=";
}

/// EvalÃºa los operandos integer nativo a objeto integer.
/// Las operaciones realizadas son aritmÃ©ticas.
obj.FoxLiteObject evalNativeIntegerToIntegerObject(
  obj.FoxLiteObject leftObj,
  String operator,
  obj.FoxLiteObject rightObj,
) {
  final leftVal = (leftObj as obj.Integer).value;
  final rightVal = (rightObj as obj.Integer).value;

  if (operator == "+") {
    return obj.Integer(leftVal + rightVal);
  } else if (operator == "-") {
    return obj.Integer(leftVal - rightVal);
  } else if (operator == "*") {
    return obj.Integer(leftVal * rightVal);
  } else if (operator == "/") {
    if (rightVal == 0) {
      return newError("DivisiÃ³n por cero.");
    }
    return obj.Integer(leftVal / rightVal);
  }

  return NULL;
}

/// EvalÃºa los operandos integer nativo a objeto boolean.
/// Las operaciones realizadas son relacionales.
obj.FoxLiteObject evalNativeIntegerToBooleanObject(
  obj.FoxLiteObject leftObj,
  String operator,
  obj.FoxLiteObject rightObj,
) {
  final leftVal = (leftObj as obj.Integer).value;
  final rightVal = (rightObj as obj.Integer).value;

  if (operator == "<") {
    return leftVal < rightVal ? TRUE : FALSE;
  } else if (operator == "<=") {
    return leftVal <= rightVal ? TRUE : FALSE;
  } else if (operator == ">") {
    return leftVal > rightVal ? TRUE : FALSE;
  } else if (operator == ">=") {
    return leftVal >= rightVal ? TRUE : FALSE;
  } else if (operator == "==") {
    return leftVal == rightVal ? TRUE : FALSE;
  } else if (operator == "!=") {
    return leftVal != rightVal ? TRUE : FALSE;
  }

  return FALSE;
}

/// EvalÃºa los operandos string nativo a objeto string.
/// Las operaciones realizadas son aritmÃ©ticas.
obj.FoxLiteObject evalNativeStringToObject(
  obj.FoxLiteObject leftObj,
  String operator,
  obj.FoxLiteObject rightObj,
) {
  final leftVal = (leftObj as obj.StringLiteral).value;
  final rightVal = (rightObj as obj.StringLiteral).value;

  if (operator == "+") {
    return obj.StringLiteral(leftVal + rightVal);
  } else if (operator == "==") {
    return obj.Boolean(leftVal == rightVal);
  } else if (operator == "!=") {
    return obj.Boolean(leftVal != rightVal);
  }

  return NULL;
}

/// EvalÃºa los operandos boolean nativo a objeto boolean.
/// Las operaciones realizadas son relacionales.
/// Como los operandos son de tipo Boolean, primero se tienen que
/// convertir a su equivalente numÃ©rico. (.f. => 0, .t. => 1)
obj.FoxLiteObject evalNativeBooleanToBooleanObject(
  obj.FoxLiteObject leftObj,
  String operator,
  obj.FoxLiteObject rightObj,
) {
  final leftVal = (leftObj as obj.Boolean).value;
  final rightVal = (rightObj as obj.Boolean).value;

  final leftInteger = obj.Integer(leftVal ? 1 : 0);
  final rightInteger = obj.Integer(rightVal ? 1 : 0);

  return evalNativeIntegerToBooleanObject(leftInteger, operator, rightInteger);
}

/// EvalÃºa el valor de un identificador.
obj.FoxLiteObject evalIdentifier(ast.Identifier astNode, Environment env) {
  final valObj = env.get(astNode.value);

  if (valObj == null) {
    return newError("Variable '${astNode.value}' no definida.");
  }

  return valObj as obj.FoxLiteObject;
}

/// Crea un nuevo environment para la funciÃ³n dada.
Environment extendFunctionEnv(
  obj.FunctionObject funcObj,
  List<obj.FoxLiteObject> arguments,
) {
  final extendedEnv = Environment(parent: funcObj.env as Environment?);

  // Registramos los sÃ­mbolos de la funciÃ³n
  for (var paramIdx = 0; paramIdx < funcObj.params.length; paramIdx++) {
    final param = funcObj.params[paramIdx] as ast.Identifier;

    extendedEnv.set(
      param.value,
      arguments[paramIdx],
      scope: "default",
      currentScope: true,
    );
  }

  return extendedEnv;
}

class Evaluator {
  /// EvalÃºa el ast que estÃ¡ siendo evaluado y devuelve su objeto resultante.
  obj.FoxLiteObject? eval(ast.Ast? astNode, Environment env) {
    // Evaluar el programa principal
    if (astNode is ast.Program) {
      return evalProgram(astNode, env);
    }

    // Evaluar bloques de sentencias
    else if (astNode is ast.Block) {
      return evalBlock(astNode, env);
    }

    // Evaluar Integer
    else if (astNode is ast.Integer) {
      return obj.Integer(astNode.value);
    }

    // Evaluar Boolean
    else if (astNode is ast.Boolean) {
      return astNode.value ? TRUE : FALSE;
    }

    // Evaluar expresiones unarias
    else if (astNode is ast.UnaryOp) {
      final operator = astNode.operator as String;
      final rightObj = eval(astNode.right, env);

      if (isError(rightObj)) {
        return rightObj;
      }

      return evalUnaryExpression(operator, rightObj!);
    }

    // Evaluar expresiones binarias
    else if (astNode is ast.BinaryOp) {
      final operator = astNode.operator as String;

      if (operator == "or" || operator == "and") {
        // Invocamos directamente sin evaluar los operandos.
        return evalLogicalExpression(astNode, env);
      }

      final leftObj = eval(astNode.left, env);

      if (isError(leftObj)) {
        return leftObj;
      }

      final rightObj = eval(astNode.right, env);

      if (isError(rightObj)) {
        return rightObj;
      }

      return evalBinaryExpression(leftObj!, operator, rightObj!);
    }

    // Evaluar String
    else if (astNode is ast.StringLiteral) {
      return obj.StringLiteral(astNode.value);
    }

    // Sentencia Return
    else if (astNode is ast.ReturnStmt) {
      final returnObj = eval(astNode.value, env);

      if (isError(returnObj)) {
        return returnObj;
      }

      return obj.Return(returnObj!);
    }

    // Sentencia Print
    else if (astNode is ast.PrintStmt) {
      for (final argument in astNode.arguments) {
        final resultObj = eval(argument, env);

        if (isError(resultObj)) {
          return resultObj;
        }

        stdout.write("$resultObj ");
      }

      print(""); // Empty line
    }

    // Do While
    else if (astNode is ast.DoWhile) {
      while (true) {
        final conditionObj = eval(astNode.condition, env);

        if (isError(conditionObj)) {
          return conditionObj;
        }

        if (conditionObj == FALSE) {
          break;
        }

        final resultObj = eval(astNode.block, env);

        if (resultObj != null) {
          if (resultObj.type() == obj.Type.returnType) {
            // Se retorna la expresiÃ³n del return.
            return (resultObj as obj.Return).value;
          } else if (resultObj.type() == obj.Type.error) {
            // Se retorna el objeto obj.Error().
            return resultObj;
          }
        }
      }
    }

    // Sentencia If
    else if (astNode is ast.IfStatement) {
      return evalIfStatement(astNode, env);
    }

    // Evaluar Null
    else if (astNode is ast.Null) {
      return NULL;
    }

    // Evaluar declaraciones de Variables
    else if (astNode is ast.VariableDecl) {
      // Las variables por defecto se declaran en .F.
      return env.set(astNode.name.value, FALSE, scope: astNode.scope as String);
    }

    // Evaluar asignaciones de Variables
    else if (astNode is ast.Assignment) {
      // Resolvemos su valor antes de guardarlo en la Tabla de SÃ­mbolos.
      final valObj = eval(astNode.value, env);

      if (isError(valObj)) {
        return valObj;
      }

      return env.set(astNode.name.value, valObj);
    }

    // Evaluar identificadores
    else if (astNode is ast.Identifier) {
      return evalIdentifier(astNode, env);
    }

    // DeclaraciÃ³n de FunciÃ³n
    else if (astNode is ast.FunctionDecl) {
      // Creamos el objeto Function
      final function = obj.FunctionObject(
        name: astNode.name.value,
        params: astNode.params,
        body: astNode.body,
        env: env,
      );

      env.set(function.name, function);

      return function;
    }

    // Llamada a FunciÃ³n
    else if (astNode is ast.FunctionCall) {
      var function = env.get(astNode.name!.value);

      if (function == null) {
        // Intentamos buscar la funciÃ³n como builtin
        function = builtins[astNode.name!.value];

        if (function == null) {
          return newError("FunciÃ³n no definida: '${astNode.name!.value}'.");
        }
      }

      final arguments = evalArguments(astNode.arguments, env);

      if (arguments.length == 1 && isError(arguments[0])) {
        return arguments[0];
      }

      return executeFunction(function, arguments);
    }

    return null;
  }

  /// EvalÃºa el programa principal.
  obj.FoxLiteObject? evalProgram(ast.Program program, Environment env) {
    obj.FoxLiteObject? resultObj;

    for (final statement in program.statements) {
      resultObj = eval(statement, env);

      if (resultObj != null) {
        if (resultObj.type() == obj.Type.returnType) {
          // Se retorna la expresiÃ³n del return.
          return (resultObj as obj.Return).value;
        } else if (resultObj.type() == obj.Type.error) {
          // Se retorna el objeto error.
          return resultObj;
        }
      }
    }

    return resultObj;
  }

  /// EvalÃºa un bloque de sentencias.
  obj.FoxLiteObject? evalBlock(ast.Block block, Environment env) {
    obj.FoxLiteObject? resultObj;

    for (final statement in block.statements) {
      resultObj = eval(statement, env);

      if (isError(resultObj)) {
        return resultObj;
      }

      if (resultObj != null &&
          (resultObj.type() == obj.Type.error ||
              resultObj.type() == obj.Type.returnType)) {
        return resultObj;
      }
    }

    return resultObj;
  }

  /// EvalÃºa la sentencia If.
  obj.FoxLiteObject? evalIfStatement(ast.IfStatement astNode, Environment env) {
    final conditionObj = eval(astNode.condition, env);

    if (isError(conditionObj)) {
      return conditionObj;
    }

    if (conditionObj == TRUE) {
      return eval(astNode.consequence, env);
    } else if (astNode.alternative != null) {
      return eval(astNode.alternative, env);
    }

    return null;
  }

  /// EvalÃºa los argumentos de una llamada a funciÃ³n.
  List<obj.FoxLiteObject> evalArguments(
    List<ast.Ast> arguments,
    Environment env,
  ) {
    final evaluatedArguments = <obj.FoxLiteObject>[];

    for (final argument in arguments) {
      final evaluatedObj = eval(argument, env);

      if (isError(evaluatedObj)) {
        return [evaluatedObj!];
      }

      evaluatedArguments.add(evaluatedObj!);
    }

    return evaluatedArguments;
  }

  /// Ejecuta la funciÃ³n dada con sus respectivos argumentos.
  obj.FoxLiteObject? executeFunction(
    dynamic func,
    List<obj.FoxLiteObject> arguments,
  ) {
    if (func is obj.FunctionObject) {
      final extendedEnv = extendFunctionEnv(func, arguments);

      // Ejecutamos el cuerpo de la funciÃ³n
      final evaluatedObj = eval(func.body, extendedEnv);

      if (evaluatedObj is obj.Return) {
        return evaluatedObj.value;
      }

      return evaluatedObj;
    } else if (func is obj.Builtin) {
      return func.function(arguments);
    } else {
      return newError("${func.type()} no es una funciÃ³n.");
    }
  }

  /// Realiza operaciones lÃ³gicas entre 2 booleanos.
  obj.FoxLiteObject evalLogicalExpression(
    ast.BinaryOp astNode,
    Environment env,
  ) {
    // Evaluamos primero el operando de la izquierda.
    final leftObj = eval(astNode.left, env);

    if (isError(leftObj)) {
      return leftObj!;
    }

    if (leftObj!.type() != obj.Type.boolean) {
      return newError(
        "Los operadores AND y OR solo soportan operandos de tipo BOOLEAN.",
      );
    }

    if (astNode.operator == "and") {
      if (leftObj == FALSE) {
        return FALSE;
      }
    } else if (astNode.operator == "or") {
      if (leftObj == TRUE) {
        return TRUE;
      }
    }

    // La operaciÃ³n depende del operando de la derecha asÃ­ que lo evaluamos.
    final rightObj = eval(astNode.right, env);

    if (isError(rightObj)) {
      return rightObj!;
    }

    if (rightObj!.type() != obj.Type.boolean) {
      return newError(
        "Los operadores AND y OR solo soportan operandos de tipo BOOLEAN.",
      );
    }

    return rightObj == TRUE ? TRUE : FALSE;
  }
}
