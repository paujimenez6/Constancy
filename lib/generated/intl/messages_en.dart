// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(error) => "An error occurred: ${error}";

  static String m1(coins) => "${coins} coins";

  static String m2(name) => "¡Welcome, ${name}!";

  static String m3(level) => "Level ${level}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "accountVerified": MessageLookupByLibrary.simpleMessage(
            "Account successfully verified! You can now log in."),
        "addHabit": MessageLookupByLibrary.simpleMessage("Add habit"),
        "alreadyHaveAccount": MessageLookupByLibrary.simpleMessage(
            "Already have an account? Log in"),
        "appTitle": MessageLookupByLibrary.simpleMessage("Constancy"),
        "authError": m0,
        "changePhoto": MessageLookupByLibrary.simpleMessage("Change photo"),
        "changesSaved": MessageLookupByLibrary.simpleMessage("Profile Updated"),
        "confirmPasswordLabel":
            MessageLookupByLibrary.simpleMessage("Confirm password"),
        "creatingAccount":
            MessageLookupByLibrary.simpleMessage("Creating account..."),
        "editProfile": MessageLookupByLibrary.simpleMessage("Edit Profile"),
        "editProfileTitle":
            MessageLookupByLibrary.simpleMessage("Edit Profile"),
        "emailLabel": MessageLookupByLibrary.simpleMessage("Email address"),
        "errorConnection": MessageLookupByLibrary.simpleMessage(
            "Error connecting to the server."),
        "errorEmailExists": MessageLookupByLibrary.simpleMessage(
            "This email address already exists."),
        "errorNicknameTaken": MessageLookupByLibrary.simpleMessage(
            "This username is already in use. Please choose another one."),
        "errorUnknown": MessageLookupByLibrary.simpleMessage(
            "An unexpected error occurred. Please try again."),
        "fieldRequired":
            MessageLookupByLibrary.simpleMessage("This field is required"),
        "homeTitle": MessageLookupByLibrary.simpleMessage("My Habits"),
        "invalidEmail":
            MessageLookupByLibrary.simpleMessage("Invalid email address"),
        "lastNameLabel": MessageLookupByLibrary.simpleMessage("Last name"),
        "loading": MessageLookupByLibrary.simpleMessage("Processing..."),
        "loginButton": MessageLookupByLibrary.simpleMessage("Log in"),
        "loginError":
            MessageLookupByLibrary.simpleMessage("Incorrect email or password"),
        "loginSubtitle": MessageLookupByLibrary.simpleMessage(
            "Way more than a simple habit tracker"),
        "loginTitle": MessageLookupByLibrary.simpleMessage(
            "Let your habits speak for you"),
        "logout": MessageLookupByLibrary.simpleMessage("Log out"),
        "nameLabel": MessageLookupByLibrary.simpleMessage("Name"),
        "navHome": MessageLookupByLibrary.simpleMessage("Home"),
        "navProfile": MessageLookupByLibrary.simpleMessage("Profile"),
        "noAccount": MessageLookupByLibrary.simpleMessage(
            "Don\'t have an account? Sign up"),
        "noHabits": MessageLookupByLibrary.simpleMessage(
            "You don\'t have any habits yet. Shall we get started?"),
        "passwordLabel": MessageLookupByLibrary.simpleMessage("Password"),
        "passwordTooShort":
            MessageLookupByLibrary.simpleMessage("Minimum 6 characters"),
        "passwordsDontMatch":
            MessageLookupByLibrary.simpleMessage("Passwords do not match"),
        "profileTitle": MessageLookupByLibrary.simpleMessage("My Profile"),
        "registerButton": MessageLookupByLibrary.simpleMessage("Sign Up"),
        "registerTitle":
            MessageLookupByLibrary.simpleMessage("Create your account"),
        "registrationPending": MessageLookupByLibrary.simpleMessage(
            "Check your email to confirm account creation!"),
        "saveChanges": MessageLookupByLibrary.simpleMessage("Save Changes"),
        "savingError":
            MessageLookupByLibrary.simpleMessage("Error saving modified data"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "userCoins": m1,
        "usernameInfo":
            MessageLookupByLibrary.simpleMessage("Username cannot be changed."),
        "usernameLabel":
            MessageLookupByLibrary.simpleMessage("Username (nickname)"),
        "validatingData":
            MessageLookupByLibrary.simpleMessage("Validating data..."),
        "welcomeUser": m2,
        "xpLevel": m3
      };
}
