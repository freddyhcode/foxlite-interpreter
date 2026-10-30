/// Funciones integradas en FoxLite
library;

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:foxlite_interpreter/object/fox_lite_object.dart' as obj;

/// Devuelve la longitud de una cadena.
obj.FoxLiteObject? lenFunc(List<obj.FoxLiteObject> args) {
  if (args.length != 1) {
    return obj.Error(
      "número de argumentos inválidos. Se esperaba 1 y llegaron ${args.length}",
    );
  }

  if (args[0].type() == obj.Type.string) {
    return obj.Integer((args[0] as obj.StringLiteral).value.length);
  } else {
    return obj.Error(
      "el tipo ${args[0].type()} no es soportado por la función len().",
    );
  }
}

/// Devuelve el tipo de dato del argumento pasado.
obj.FoxLiteObject? typeFunc(List<obj.FoxLiteObject> args) {
  if (args.length != 1) {
    return obj.Error(
      "número de argumentos inválidos. Se esperaba 1 y llegaron ${args.length}",
    );
  }

  final objType = args[0].type();
  var typeValue = "U";

  if (objType == obj.Type.string) {
    typeValue = "C";
  } else if (objType == obj.Type.boolean) {
    typeValue = "L";
  } else if (objType == obj.Type.integer) {
    typeValue = "N";
  } else if (objType == obj.Type.nullType) {
    typeValue = "X";
  }

  return obj.StringLiteral(typeValue);
}

typedef MessageBoxWNative = Int32 Function(
  IntPtr,
  Pointer<Utf16>,
  Pointer<Utf16>,
  Uint32,
);
typedef MessageBoxWDart = int Function(
  int,
  Pointer<Utf16>,
  Pointer<Utf16>,
  int,
);

/// Muestra un cuadro de diálogo en pantalla.
obj.FoxLiteObject? messageboxFunc(List<obj.FoxLiteObject> args) {
  if (args.length != 2) {
    return obj.Error(
      "número de argumentos inválidos. Se esperaban 2 y llegaron ${args.length}",
    );
  }

  if (!Platform.isWindows) {
    return obj.Error("messagebox solo está disponible en Windows.");
  }

  final user32 = DynamicLibrary.open("user32.dll");
  final messageBox = user32.lookupFunction<MessageBoxWNative, MessageBoxWDart>(
    "MessageBoxW",
  );

  final text = args[0].toString().toNativeUtf16();
  final title = args[1].toString().toNativeUtf16();

  try {
    messageBox(0, text, title, 0);
  } finally {
    malloc.free(text);
    malloc.free(title);
  }

  return null;
}

/// Elimina los espacios en blanco a la izquierda y a la derecha de una cadena.
obj.FoxLiteObject? alltrimFunc(List<obj.FoxLiteObject> args) {
  if (args.length != 1) {
    return obj.Error(
      "número de argumentos inválidos. Se esperaba 1 y llegaron ${args.length}",
    );
  }

  if (args[0].type() != obj.Type.string) {
    return obj.Error(
      "el tipo ${args[0].type()} no es soportado por la función alltrim().",
    );
  }

  return obj.StringLiteral((args[0] as obj.StringLiteral).value.trim());
}

final builtins = {
  "len": obj.Builtin(lenFunc),
  "type": obj.Builtin(typeFunc),
  "messagebox": obj.Builtin(messageboxFunc),
  "alltrim": obj.Builtin(alltrimFunc),
};
