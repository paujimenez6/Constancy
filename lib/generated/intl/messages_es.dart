// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'es';

  static String m0(error) => "Se ha producido un error: ${error}";

  static String m1(coins) => "${coins} monedas";

  static String m2(name) => "¡Bienvenido/a, ${name}!";

  static String m3(level) => "Nivel ${level}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "accountVerified": MessageLookupByLibrary.simpleMessage(
            "¡Cuenta verificada correctamente! Ahora ya puedes iniciar sesión."),
        "addHabit": MessageLookupByLibrary.simpleMessage("Añadir hábito"),
        "alreadyHaveAccount": MessageLookupByLibrary.simpleMessage(
            "¿Ya tienes cuenta? Inicia sesión"),
        "appTitle": MessageLookupByLibrary.simpleMessage("Constancy"),
        "authError": m0,
        "changePhoto": MessageLookupByLibrary.simpleMessage("Cambiar foto"),
        "changesSaved":
            MessageLookupByLibrary.simpleMessage("Perfil actualizado"),
        "confirmPasswordLabel":
            MessageLookupByLibrary.simpleMessage("Confirmar contraseña"),
        "creatingAccount":
            MessageLookupByLibrary.simpleMessage("Creando cuenta..."),
        "editProfile": MessageLookupByLibrary.simpleMessage("Editar Perfil"),
        "editProfileTitle":
            MessageLookupByLibrary.simpleMessage("Editar Perfil"),
        "emailLabel":
            MessageLookupByLibrary.simpleMessage("Correo electrónico"),
        "errorConnection": MessageLookupByLibrary.simpleMessage(
            "Error de conexión con el servidor."),
        "errorEmailExists": MessageLookupByLibrary.simpleMessage(
            "Este correo electrónico ya está registrado."),
        "errorNicknameTaken": MessageLookupByLibrary.simpleMessage(
            "Este nombre de usuario ya está en uso. Elige otro."),
        "errorUnknown": MessageLookupByLibrary.simpleMessage(
            "Se ha producido un error inesperado. Vuelve a intentarlo."),
        "fieldRequired":
            MessageLookupByLibrary.simpleMessage("Este campo es obligatorio"),
        "homeTitle": MessageLookupByLibrary.simpleMessage("Mis hábitos"),
        "invalidEmail": MessageLookupByLibrary.simpleMessage(
            "Correo electrónico no válido"),
        "lastNameLabel": MessageLookupByLibrary.simpleMessage("Apellido"),
        "loading": MessageLookupByLibrary.simpleMessage("Procesando..."),
        "loginButton": MessageLookupByLibrary.simpleMessage("Iniciar sesión"),
        "loginError": MessageLookupByLibrary.simpleMessage(
            "Correo o contraseña incorrectos"),
        "loginSubtitle": MessageLookupByLibrary.simpleMessage(
            "Mucho más que un simple habit tracker"),
        "loginTitle": MessageLookupByLibrary.simpleMessage(
            "Haz que tus hábitos hablen por ti"),
        "logout": MessageLookupByLibrary.simpleMessage("Cerrar sesión"),
        "nameLabel": MessageLookupByLibrary.simpleMessage("Nombre"),
        "navHome": MessageLookupByLibrary.simpleMessage("Inicio"),
        "navProfile": MessageLookupByLibrary.simpleMessage("Perfil"),
        "noAccount": MessageLookupByLibrary.simpleMessage(
            "¿No tienes cuenta? Regístrate"),
        "noHabits": MessageLookupByLibrary.simpleMessage(
            "Aún no tienes ningún hábito. ¿Empecamos?"),
        "passwordLabel": MessageLookupByLibrary.simpleMessage("Contraseña"),
        "passwordTooShort":
            MessageLookupByLibrary.simpleMessage("Mínimo 6 caracteres"),
        "passwordsDontMatch": MessageLookupByLibrary.simpleMessage(
            "Las contraseñas no coinciden"),
        "profileTitle": MessageLookupByLibrary.simpleMessage("Mi Perfil"),
        "registerButton": MessageLookupByLibrary.simpleMessage("Registrarse"),
        "registerTitle": MessageLookupByLibrary.simpleMessage("Crea tu cuenta"),
        "registrationPending": MessageLookupByLibrary.simpleMessage(
            "¡Revisa tu buzón de correo para confirmar la creación de la cuenta!"),
        "saveChanges": MessageLookupByLibrary.simpleMessage("Guardar cambios"),
        "savingError": MessageLookupByLibrary.simpleMessage(
            "Error guardando los datos modificados"),
        "settings": MessageLookupByLibrary.simpleMessage("Configuración"),
        "userCoins": m1,
        "usernameInfo": MessageLookupByLibrary.simpleMessage(
            "El nombre de usuario no se puede cambiar."),
        "usernameLabel": MessageLookupByLibrary.simpleMessage(
            "Nombre de usuario (nickname)"),
        "validatingData":
            MessageLookupByLibrary.simpleMessage("Validando datos..."),
        "welcomeUser": m2,
        "xpLevel": m3
      };
}
