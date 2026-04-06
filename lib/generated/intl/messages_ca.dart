// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ca locale. All the
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
  String get localeName => 'ca';

  static String m0(error) => "S\'ha produït un error: ${error}";

  static String m1(coins) => "${coins} monedes";

  static String m2(name) => "Benvingut/da, ${name}!";

  static String m3(level) => "Nivell ${level}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "accountVerified": MessageLookupByLibrary.simpleMessage(
            "Compte verificat correctament! Ara ja pots iniciar sessió."),
        "addHabit": MessageLookupByLibrary.simpleMessage("Afegir hàbit"),
        "alreadyHaveAccount": MessageLookupByLibrary.simpleMessage(
            "Ja tens compte? Inicia sessió"),
        "appTitle": MessageLookupByLibrary.simpleMessage("Constancy"),
        "authError": m0,
        "changePhoto": MessageLookupByLibrary.simpleMessage("Canviar foto"),
        "changesSaved":
            MessageLookupByLibrary.simpleMessage("Perfil actualitzat"),
        "confirmPasswordLabel":
            MessageLookupByLibrary.simpleMessage("Confirmar contrasenya"),
        "creatingAccount":
            MessageLookupByLibrary.simpleMessage("Creant compte..."),
        "editProfile": MessageLookupByLibrary.simpleMessage("Editar Perfil"),
        "editProfileTitle":
            MessageLookupByLibrary.simpleMessage("Editar Perfil"),
        "emailLabel": MessageLookupByLibrary.simpleMessage("Correu electrònic"),
        "errorConnection": MessageLookupByLibrary.simpleMessage(
            "Error de connexió amb el servidor."),
        "errorEmailExists": MessageLookupByLibrary.simpleMessage(
            "Aquest correu electrònic ja està registrat."),
        "errorNicknameTaken": MessageLookupByLibrary.simpleMessage(
            "Aquest nom d\'usuari ja està en ús. Tria\'n un altre."),
        "errorUnknown": MessageLookupByLibrary.simpleMessage(
            "S\'ha produït un error inesperat. Torna-ho a provar."),
        "fieldRequired":
            MessageLookupByLibrary.simpleMessage("Aquest camp és obligatori"),
        "homeTitle": MessageLookupByLibrary.simpleMessage("Els meus hàbits"),
        "invalidEmail":
            MessageLookupByLibrary.simpleMessage("Correu electrònic no vàlid"),
        "lastNameLabel": MessageLookupByLibrary.simpleMessage("Cognom"),
        "loading": MessageLookupByLibrary.simpleMessage("Processant..."),
        "loginButton": MessageLookupByLibrary.simpleMessage("Iniciar sessió"),
        "loginError": MessageLookupByLibrary.simpleMessage(
            "Correu o contrasenya incorrectes"),
        "loginSubtitle": MessageLookupByLibrary.simpleMessage(
            "Molt més que un simple habit tracker"),
        "loginTitle": MessageLookupByLibrary.simpleMessage(
            "Fes que els teus hàbits parlin per tu"),
        "logout": MessageLookupByLibrary.simpleMessage("Tancar sessió"),
        "nameLabel": MessageLookupByLibrary.simpleMessage("Nom"),
        "navHome": MessageLookupByLibrary.simpleMessage("Inici"),
        "navProfile": MessageLookupByLibrary.simpleMessage("Perfil"),
        "noAccount":
            MessageLookupByLibrary.simpleMessage("No tens compte? Registra\'t"),
        "noHabits": MessageLookupByLibrary.simpleMessage(
            "Encara no tens cap hàbit. Comencem?"),
        "passwordLabel": MessageLookupByLibrary.simpleMessage("Contrasenya"),
        "passwordTooShort":
            MessageLookupByLibrary.simpleMessage("Mínim 6 caràcters"),
        "passwordsDontMatch": MessageLookupByLibrary.simpleMessage(
            "Les contrasenyes no coincideixen"),
        "profileTitle": MessageLookupByLibrary.simpleMessage("El meu Perfil"),
        "registerButton": MessageLookupByLibrary.simpleMessage("Registrar-se"),
        "registerTitle":
            MessageLookupByLibrary.simpleMessage("Crea el teu compte"),
        "registrationPending": MessageLookupByLibrary.simpleMessage(
            "Revisa la teva bústia de correu per confirmar la creació del compte!"),
        "saveChanges": MessageLookupByLibrary.simpleMessage("Desar canvis"),
        "savingError": MessageLookupByLibrary.simpleMessage(
            "Error guardant les dades modificades"),
        "settings": MessageLookupByLibrary.simpleMessage("Configuració"),
        "userCoins": m1,
        "usernameInfo": MessageLookupByLibrary.simpleMessage(
            "El nom d\'usuari no es pot canviar."),
        "usernameLabel":
            MessageLookupByLibrary.simpleMessage("Nom d\'usuari (nickname)"),
        "validatingData":
            MessageLookupByLibrary.simpleMessage("Validant dades..."),
        "welcomeUser": m2,
        "xpLevel": m3
      };
}
