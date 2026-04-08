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

  static String m1(email) => "Actualizando la contraseña de: ${email}";

  static String m2(coins) => "${coins} monedas";

  static String m3(name) => "¡Bienvenido/a, ${name}!";

  static String m4(level) => "Nivel ${level}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "accountVerified": MessageLookupByLibrary.simpleMessage(
            "¡Cuenta verificada correctamente! Ahora ya puedes iniciar sesión."),
        "addHabit": MessageLookupByLibrary.simpleMessage("Añadir hábito"),
        "alreadyHaveAccount": MessageLookupByLibrary.simpleMessage(
            "¿Ya tienes cuenta? Inicia sesión"),
        "appTitle": MessageLookupByLibrary.simpleMessage("Constancy"),
        "authError": m0,
        "cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "changePhoto": MessageLookupByLibrary.simpleMessage("Cambiar foto"),
        "changesSaved":
            MessageLookupByLibrary.simpleMessage("Perfil actualizado"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirmar"),
        "confirmPasswordLabel":
            MessageLookupByLibrary.simpleMessage("Confirmar contraseña"),
        "copySecret":
            MessageLookupByLibrary.simpleMessage("Copiar código secreto"),
        "creatingAccount":
            MessageLookupByLibrary.simpleMessage("Creando cuenta..."),
        "deleteAccount":
            MessageLookupByLibrary.simpleMessage("Eliminar cuenta"),
        "deleteAccountConfirm": MessageLookupByLibrary.simpleMessage(
            "¿Estás seguro de que quieres eliminar tu cuenta para siempre? Esta acción no se puede deshacer."),
        "deletedAccount": MessageLookupByLibrary.simpleMessage(
            "Cuenta eliminada correctamente"),
        "editProfile": MessageLookupByLibrary.simpleMessage("Editar Perfil"),
        "editProfileTitle":
            MessageLookupByLibrary.simpleMessage("Editar Perfil"),
        "emailLabel":
            MessageLookupByLibrary.simpleMessage("Correo electrónico"),
        "errorConnection": MessageLookupByLibrary.simpleMessage(
            "Error de conexión con el servidor."),
        "errorEmailExists": MessageLookupByLibrary.simpleMessage(
            "Este correo electrónico ya está registrado."),
        "errorEmailNotExists": MessageLookupByLibrary.simpleMessage(
            "Este correo no está registrado"),
        "errorNicknameTaken": MessageLookupByLibrary.simpleMessage(
            "Este nombre de usuario ya está en uso. Elige otro."),
        "errorSamePassword": MessageLookupByLibrary.simpleMessage(
            "La nueva contraseña debe ser diferente a la actual"),
        "errorUnknown": MessageLookupByLibrary.simpleMessage(
            "Se ha producido un error inesperado. Vuelve a intentarlo."),
        "fieldRequired":
            MessageLookupByLibrary.simpleMessage("Este campo es obligatorio"),
        "forgotPassword": MessageLookupByLibrary.simpleMessage(
            "¿Has olvidado la contraseña?"),
        "homeTitle": MessageLookupByLibrary.simpleMessage("Mis hábitos"),
        "invalidEmail": MessageLookupByLibrary.simpleMessage(
            "Correo electrónico no válido"),
        "langCatalan": MessageLookupByLibrary.simpleMessage("Catalán"),
        "langEnglish": MessageLookupByLibrary.simpleMessage("Inglés"),
        "langSpanish": MessageLookupByLibrary.simpleMessage("Español"),
        "language": MessageLookupByLibrary.simpleMessage("Idioma"),
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
        "logoutConfirmMessage": MessageLookupByLibrary.simpleMessage(
            "¿Estás seguro de que quieres cerrar la sesión actual?"),
        "mfaButtonVerify":
            MessageLookupByLibrary.simpleMessage("Verificar y Activar"),
        "mfaChallengeSubtitle": MessageLookupByLibrary.simpleMessage(
            "Introduce el código de 6 dígitos de tu app de autenticación para continuar."),
        "mfaChallengeTitle":
            MessageLookupByLibrary.simpleMessage("Verificación de Seguridad"),
        "mfaDisableConfirm": MessageLookupByLibrary.simpleMessage(
            "¿Quieres desactivar el doble factor de seguridad?"),
        "mfaDisabled":
            MessageLookupByLibrary.simpleMessage("El 2FA está desactivado"),
        "mfaEnabled":
            MessageLookupByLibrary.simpleMessage("El 2FA está activado"),
        "mfaEnrollSubtitle": MessageLookupByLibrary.simpleMessage(
            "Copia este código secreto en tu aplicación de autenticación (Google Authenticator o similares):"),
        "mfaEnrollTitle":
            MessageLookupByLibrary.simpleMessage("Activar Doble Factor"),
        "mfaError": MessageLookupByLibrary.simpleMessage(
            "Código incorrecto o caducado"),
        "mfaLabelCode": MessageLookupByLibrary.simpleMessage(
            "Código de verificación (6 dígitos)"),
        "mfaLabelSecret":
            MessageLookupByLibrary.simpleMessage("Código Secreto"),
        "mfaSuccess": MessageLookupByLibrary.simpleMessage(
            "¡Doble factor activado correctamente!"),
        "mfaVerifyButton": MessageLookupByLibrary.simpleMessage("Verificar"),
        "nameLabel": MessageLookupByLibrary.simpleMessage("Nombre"),
        "navHome": MessageLookupByLibrary.simpleMessage("Inicio"),
        "navProfile": MessageLookupByLibrary.simpleMessage("Perfil"),
        "newPasswordLabel":
            MessageLookupByLibrary.simpleMessage("Nueva contraseña"),
        "noAccount": MessageLookupByLibrary.simpleMessage(
            "¿No tienes cuenta? Regístrate"),
        "noHabits": MessageLookupByLibrary.simpleMessage(
            "Aún no tienes ningún hábito. ¿Empecamos?"),
        "passwordLabel": MessageLookupByLibrary.simpleMessage("Contraseña"),
        "passwordTooShort":
            MessageLookupByLibrary.simpleMessage("Mínimo 6 caracteres"),
        "passwordUpdated": MessageLookupByLibrary.simpleMessage(
            "¡Contraseña actualizada correctamente!"),
        "passwordsDontMatch": MessageLookupByLibrary.simpleMessage(
            "Las contraseñas no coinciden"),
        "profileTitle": MessageLookupByLibrary.simpleMessage("Mi Perfil"),
        "registerButton": MessageLookupByLibrary.simpleMessage("Registrarse"),
        "registerTitle": MessageLookupByLibrary.simpleMessage("Crea tu cuenta"),
        "registrationPending": MessageLookupByLibrary.simpleMessage(
            "¡Revisa tu buzón de correo para confirmar la creación de la cuenta!"),
        "resetEmailSent": MessageLookupByLibrary.simpleMessage(
            "Se ha enviado un correo para restablecer la contraseña"),
        "saveChanges": MessageLookupByLibrary.simpleMessage("Guardar cambios"),
        "savingError": MessageLookupByLibrary.simpleMessage(
            "Error guardando los datos modificados"),
        "secretCopied":
            MessageLookupByLibrary.simpleMessage("Código secreto copiado"),
        "sendResetLink": MessageLookupByLibrary.simpleMessage(
            "Enviar enlace de recuperación"),
        "sendResetLinkSubTitle": MessageLookupByLibrary.simpleMessage(
            "Introduce tu correo y te enviaremos un enlace para recuperar el acceso."),
        "settings": MessageLookupByLibrary.simpleMessage("Configuración"),
        "theme": MessageLookupByLibrary.simpleMessage("Tema de la aplicación"),
        "themeDark": MessageLookupByLibrary.simpleMessage("Oscuro"),
        "themeLight": MessageLookupByLibrary.simpleMessage("Claro"),
        "themeSystem": MessageLookupByLibrary.simpleMessage("Sistema"),
        "twoFactorAuth":
            MessageLookupByLibrary.simpleMessage("Doble Factor (2FA)"),
        "updatePasswordButton":
            MessageLookupByLibrary.simpleMessage("Guardar nueva contraseña"),
        "updatePasswordTitle":
            MessageLookupByLibrary.simpleMessage("Actualizar contraseña"),
        "updatingPasswordFor": m1,
        "userCoins": m2,
        "usernameInfo": MessageLookupByLibrary.simpleMessage(
            "El nombre de usuario no se puede cambiar."),
        "usernameLabel": MessageLookupByLibrary.simpleMessage(
            "Nombre de usuario (nickname)"),
        "validatingData":
            MessageLookupByLibrary.simpleMessage("Validando datos..."),
        "welcomeUser": m3,
        "xpLevel": m4
      };
}
