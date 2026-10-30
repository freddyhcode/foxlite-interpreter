/// class Environment.
///
/// Un environment o entorno es un espacio de trabajo que permite el
/// almacenamiento y recuperación de los símbolos utilizados por la
/// construcción que ha generado el entorno.
library;

import 'package:foxlite_interpreter/object/fox_lite_object.dart' as obj;

class Environment {
  final Map<String, List<dynamic>> symbolTable = {};
  final Environment? parent;

  Environment({this.parent});

  /// Obtiene el valor de un símbolo dado su nombre.
  dynamic get(String name) {
    final result = symbolTable[name];

    if (result == null && parent != null) {
      return parent!.get(name);
    }

    return result == null ? null : result[1];
  }

  /// Obtiene el par [scope, valor] de un símbolo dado su nombre.
  ///
  /// En el libro, set() consulta parent.get() y luego accede a result[0],
  /// pero get() devuelve el valor. Este helper devuelve el par completo
  /// para poder actualizar el símbolo y respetar su ámbito.
  List<dynamic>? getEntry(String name) {
    final result = symbolTable[name];

    if (result == null && parent != null) {
      return parent!.getEntry(name);
    }

    return result;
  }

  /// Registra o actualiza un símbolo en la tabla de símbolos.
  dynamic set(
    String name,
    dynamic val, {
    String scope = "default",
    bool currentScope = false,
  }) {
    // Buscamos el símbolo en el entorno actual
    final result = symbolTable[name];

    if (result != null) {
      // Verificar la redefinición no válida.
      if ((result[0] == "local" || result[0] == "private") &&
          scope == "public") {
        return obj.Error(
          "redefinición no válida de la variable '$name'.",
        );
      }

      // Actualizamos el valor del símbolo.
      result[1] = val;
      symbolTable[name] = result;
    } else {
      if (parent != null && !currentScope) {
        // Buscamos el símbolo en el entorno padre.
        final parentResult = parent!.getEntry(name);

        if (parentResult != null) {
          // Solo permitimos "public" o "private"
          if (parentResult[0] == "public" || parentResult[0] == "private") {
            // Actualizamos el valor del símbolo en el entorno padre.
            parentResult[1] = val;
            parent!.symbolTable[name] = parentResult;
          } else {
            // Registramos el símbolo.
            symbolTable[name] = [scope, val];
          }
        } else {
          // Registramos el símbolo.
          symbolTable[name] = [scope, val];
        }
      } else {
        // Registramos el símbolo.
        symbolTable[name] = [scope, val];
      }
    }

    return val;
  }
}
