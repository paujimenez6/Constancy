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

  static String m1(email) => "Actualitzant la contrasenya de: ${email}";

  static String m2(coins) => "${coins} monedes";

  static String m3(name) => "Benvingut/da, ${name}!";

  static String m4(level) => "Nivell ${level}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "accept": MessageLookupByLibrary.simpleMessage("Acceptar"),
        "accountVerified": MessageLookupByLibrary.simpleMessage(
            "Compte verificat correctament! Ara ja pots iniciar sessió."),
        "addHabit": MessageLookupByLibrary.simpleMessage("Afegir hàbit"),
        "alreadyHaveAccount": MessageLookupByLibrary.simpleMessage(
            "Ja tens compte? Inicia sessió"),
        "appTitle": MessageLookupByLibrary.simpleMessage("Constancy"),
        "authError": m0,
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel·lar"),
        "changePhoto": MessageLookupByLibrary.simpleMessage("Canviar foto"),
        "changesSaved":
            MessageLookupByLibrary.simpleMessage("Perfil actualitzat"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirmar"),
        "confirmPasswordLabel":
            MessageLookupByLibrary.simpleMessage("Confirmar contrasenya"),
        "copySecret":
            MessageLookupByLibrary.simpleMessage("Copiar codi secret"),
        "creatingAccount":
            MessageLookupByLibrary.simpleMessage("Creant compte..."),
        "deleteAccount":
            MessageLookupByLibrary.simpleMessage("Eliminar compte"),
        "deleteAccountConfirm": MessageLookupByLibrary.simpleMessage(
            "Estàs segur que vols eliminar el teu compte per sempre? Aquesta acció no es pot desfer."),
        "deletedAccount": MessageLookupByLibrary.simpleMessage(
            "Compte eliminat correctament"),
        "editProfile": MessageLookupByLibrary.simpleMessage("Editar Perfil"),
        "editProfileTitle":
            MessageLookupByLibrary.simpleMessage("Editar Perfil"),
        "emailLabel": MessageLookupByLibrary.simpleMessage("Correu electrònic"),
        "errorConnection": MessageLookupByLibrary.simpleMessage(
            "Error de connexió amb el servidor."),
        "errorEmailExists": MessageLookupByLibrary.simpleMessage(
            "Aquest correu electrònic ja està registrat."),
        "errorEmailNotExists": MessageLookupByLibrary.simpleMessage(
            "Aquest correu no està registrat"),
        "errorNicknameTaken": MessageLookupByLibrary.simpleMessage(
            "Aquest nom d\'usuari ja està en ús. Tria\'n un altre."),
        "errorSamePassword": MessageLookupByLibrary.simpleMessage(
            "La nova contrasenya ha de ser diferent a l\'actual"),
        "errorUnknown": MessageLookupByLibrary.simpleMessage(
            "S\'ha produït un error inesperat. Torna-ho a provar."),
        "fieldRequired":
            MessageLookupByLibrary.simpleMessage("Aquest camp és obligatori"),
        "follow": MessageLookupByLibrary.simpleMessage("Seguir"),
        "followers": MessageLookupByLibrary.simpleMessage("Seguidors"),
        "following": MessageLookupByLibrary.simpleMessage("Seguint"),
        "forgotPassword":
            MessageLookupByLibrary.simpleMessage("Heu oblidat la contrasenya?"),
        "friends": MessageLookupByLibrary.simpleMessage("Només amics"),
        "homeTitle": MessageLookupByLibrary.simpleMessage("Els meus hàbits"),
        "invalidEmail":
            MessageLookupByLibrary.simpleMessage("Correu electrònic no vàlid"),
        "langCatalan": MessageLookupByLibrary.simpleMessage("Català"),
        "langEnglish": MessageLookupByLibrary.simpleMessage("Anglès"),
        "langSpanish": MessageLookupByLibrary.simpleMessage("Espanyol"),
        "language": MessageLookupByLibrary.simpleMessage("Idioma"),
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
        "logoutConfirmMessage": MessageLookupByLibrary.simpleMessage(
            "Estàs segur que vols tancar la sessió actual?"),
        "me": MessageLookupByLibrary.simpleMessage("Tu"),
        "mfaButtonVerify":
            MessageLookupByLibrary.simpleMessage("Verificar i Activar"),
        "mfaChallengeSubtitle": MessageLookupByLibrary.simpleMessage(
            "Introdueix el codi de 6 dígits de la teva app d\'autenticació per continuar."),
        "mfaChallengeTitle":
            MessageLookupByLibrary.simpleMessage("Verificació de Seguretat"),
        "mfaDisableConfirm": MessageLookupByLibrary.simpleMessage(
            "Vols desactivar el doble factor de seguretat?"),
        "mfaDisabled":
            MessageLookupByLibrary.simpleMessage("El 2FA està desactivat"),
        "mfaEnabled":
            MessageLookupByLibrary.simpleMessage("El 2FA està activat"),
        "mfaEnrollSubtitle": MessageLookupByLibrary.simpleMessage(
            "Copia aquest codi secret a la teva aplicació d\'autenticació (Google Authenticator o similars):"),
        "mfaEnrollTitle":
            MessageLookupByLibrary.simpleMessage("Activar Doble Factor"),
        "mfaError":
            MessageLookupByLibrary.simpleMessage("Codi incorrecte o caducat"),
        "mfaLabelCode": MessageLookupByLibrary.simpleMessage(
            "Codi de verificació (6 dígits)"),
        "mfaLabelSecret": MessageLookupByLibrary.simpleMessage("Codi Secret"),
        "mfaSuccess": MessageLookupByLibrary.simpleMessage(
            "Doble factor activat correctament!"),
        "mfaVerifyButton": MessageLookupByLibrary.simpleMessage("Verificar"),
        "nameLabel": MessageLookupByLibrary.simpleMessage("Nom"),
        "navHome": MessageLookupByLibrary.simpleMessage("Inici"),
        "navNotifications":
            MessageLookupByLibrary.simpleMessage("Notificacions"),
        "navProfile": MessageLookupByLibrary.simpleMessage("Perfil"),
        "navSearch": MessageLookupByLibrary.simpleMessage("Cerca"),
        "newPasswordLabel":
            MessageLookupByLibrary.simpleMessage("Nova contrasenya"),
        "noAccount":
            MessageLookupByLibrary.simpleMessage("No tens compte? Registra\'t"),
        "noHabits": MessageLookupByLibrary.simpleMessage(
            "Encara no tens cap hàbit. Comencem?"),
        "noNotifications":
            MessageLookupByLibrary.simpleMessage("No tens cap notificació"),
        "noResultsFound":
            MessageLookupByLibrary.simpleMessage("No s\'han trobat usuaris"),
        "passwordLabel": MessageLookupByLibrary.simpleMessage("Contrasenya"),
        "passwordTooShort":
            MessageLookupByLibrary.simpleMessage("Mínim 6 caràcters"),
        "passwordUpdated": MessageLookupByLibrary.simpleMessage(
            "Contrasenya actualitzada correctament!"),
        "passwordsDontMatch": MessageLookupByLibrary.simpleMessage(
            "Les contrasenyes no coincideixen"),
        "privacy": MessageLookupByLibrary.simpleMessage("Privacitat"),
        "private": MessageLookupByLibrary.simpleMessage("Perfil privat"),
        "privateInfoMessage": MessageLookupByLibrary.simpleMessage(
            "Aquesta informació és privada"),
        "privateProfileMessage": MessageLookupByLibrary.simpleMessage(
            "Aquest perfil és privat. Segueix-lo per veure el seu contingut."),
        "profileTitle": MessageLookupByLibrary.simpleMessage("El meu Perfil"),
        "public": MessageLookupByLibrary.simpleMessage("Perfil públic"),
        "publicDataPlaceholder": MessageLookupByLibrary.simpleMessage(
            "Aviat podràs veure els seus hàbits aquí."),
        "registerButton": MessageLookupByLibrary.simpleMessage("Registrar-se"),
        "registerTitle":
            MessageLookupByLibrary.simpleMessage("Crea el teu compte"),
        "registrationPending": MessageLookupByLibrary.simpleMessage(
            "Revisa la teva bústia de correu per confirmar la creació del compte!"),
        "reject": MessageLookupByLibrary.simpleMessage("Rebutjar"),
        "requestPending":
            MessageLookupByLibrary.simpleMessage("Sol·licitud enviada"),
        "resetEmailSent": MessageLookupByLibrary.simpleMessage(
            "S\'ha enviat un correu per restablir la contrasenya"),
        "saveChanges": MessageLookupByLibrary.simpleMessage("Desar canvis"),
        "savingError": MessageLookupByLibrary.simpleMessage(
            "Error guardant les dades modificades"),
        "searchUsersHint":
            MessageLookupByLibrary.simpleMessage("Cerca usuaris..."),
        "secretCopied":
            MessageLookupByLibrary.simpleMessage("Codi secret copiat"),
        "sendRequest":
            MessageLookupByLibrary.simpleMessage("Enviar sol·licitud"),
        "sendResetLink": MessageLookupByLibrary.simpleMessage(
            "Enviar enllaç de recuperació"),
        "sendResetLinkSubTitle": MessageLookupByLibrary.simpleMessage(
            "Introdueix el teu correu i t\'enviarem un enllaç per recuperar l\'accés."),
        "settings": MessageLookupByLibrary.simpleMessage("Configuració"),
        "theme": MessageLookupByLibrary.simpleMessage("Tema de l\'aplicació"),
        "themeDark": MessageLookupByLibrary.simpleMessage("Fosc"),
        "themeLight": MessageLookupByLibrary.simpleMessage("Clar"),
        "themeSystem": MessageLookupByLibrary.simpleMessage("Sistema"),
        "twoFactorAuth":
            MessageLookupByLibrary.simpleMessage("Doble Factor (2FA)"),
        "unfollowConfirm": MessageLookupByLibrary.simpleMessage(
            "Vols deixar de seguir a aquest usuari?"),
        "updatePasswordButton":
            MessageLookupByLibrary.simpleMessage("Desar nova contrasenya"),
        "updatePasswordTitle":
            MessageLookupByLibrary.simpleMessage("Actualitzar contrasenya"),
        "updatingPasswordFor": m1,
        "userCoins": m2,
        "usernameInfo": MessageLookupByLibrary.simpleMessage(
            "El nom d\'usuari no es pot canviar."),
        "usernameLabel":
            MessageLookupByLibrary.simpleMessage("Nom d\'usuari (nickname)"),
        "validatingData":
            MessageLookupByLibrary.simpleMessage("Validant dades..."),
        "wantsToFollow": MessageLookupByLibrary.simpleMessage("Vol seguir-te"),
        "welcomeUser": m3,
        "xpLevel": m4
      };
}
