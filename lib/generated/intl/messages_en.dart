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

  static String m1(email) => "Updating password for: ${email}";

  static String m2(coins) => "${coins} coins";

  static String m3(name) => "¡Welcome, ${name}!";

  static String m4(level) => "Level ${level}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "accept": MessageLookupByLibrary.simpleMessage("Accept"),
        "accountVerified": MessageLookupByLibrary.simpleMessage(
            "Account successfully verified! You can now log in."),
        "addHabit": MessageLookupByLibrary.simpleMessage("Add habit"),
        "alreadyHaveAccount": MessageLookupByLibrary.simpleMessage(
            "Already have an account? Log in"),
        "appTitle": MessageLookupByLibrary.simpleMessage("Constancy"),
        "authError": m0,
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "changePhoto": MessageLookupByLibrary.simpleMessage("Change photo"),
        "changesSaved": MessageLookupByLibrary.simpleMessage("Profile Updated"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "confirmPasswordLabel":
            MessageLookupByLibrary.simpleMessage("Confirm password"),
        "confirmRemoveFollower": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to remove"),
        "copySecret": MessageLookupByLibrary.simpleMessage("Copy secret code"),
        "creatingAccount":
            MessageLookupByLibrary.simpleMessage("Creating account..."),
        "deleteAccount": MessageLookupByLibrary.simpleMessage("Delete account"),
        "deleteAccountConfirm": MessageLookupByLibrary.simpleMessage(
            "Are you sure do you want to permanently delete your account? This action cannot be undone."),
        "deletedAccount": MessageLookupByLibrary.simpleMessage(
            "Account successfully deleted"),
        "editProfile": MessageLookupByLibrary.simpleMessage("Edit Profile"),
        "editProfileTitle":
            MessageLookupByLibrary.simpleMessage("Edit Profile"),
        "emailLabel": MessageLookupByLibrary.simpleMessage("Email address"),
        "errorConnection": MessageLookupByLibrary.simpleMessage(
            "Error connecting to the server."),
        "errorEmailExists": MessageLookupByLibrary.simpleMessage(
            "This email address already exists."),
        "errorEmailNotExists": MessageLookupByLibrary.simpleMessage(
            "This email is not registered"),
        "errorNicknameTaken": MessageLookupByLibrary.simpleMessage(
            "This username is already in use. Please choose another one."),
        "errorSamePassword": MessageLookupByLibrary.simpleMessage(
            "New password must be different from current one"),
        "errorUnknown": MessageLookupByLibrary.simpleMessage(
            "An unexpected error occurred. Please try again."),
        "fieldRequired":
            MessageLookupByLibrary.simpleMessage("This field is required"),
        "follow": MessageLookupByLibrary.simpleMessage("Follow"),
        "followRequests":
            MessageLookupByLibrary.simpleMessage("Follow requests"),
        "followers": MessageLookupByLibrary.simpleMessage("Followers"),
        "following": MessageLookupByLibrary.simpleMessage("Following"),
        "forgotPassword":
            MessageLookupByLibrary.simpleMessage("Forgot your password?"),
        "friends": MessageLookupByLibrary.simpleMessage("Friends only"),
        "homeTitle": MessageLookupByLibrary.simpleMessage("My Habits"),
        "invalidEmail":
            MessageLookupByLibrary.simpleMessage("Invalid email address"),
        "langCatalan": MessageLookupByLibrary.simpleMessage("Catalan"),
        "langEnglish": MessageLookupByLibrary.simpleMessage("English"),
        "langSpanish": MessageLookupByLibrary.simpleMessage("Spanish"),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "lastNameLabel": MessageLookupByLibrary.simpleMessage("Last name"),
        "listFor": MessageLookupByLibrary.simpleMessage("List of"),
        "loading": MessageLookupByLibrary.simpleMessage("Processing..."),
        "loginButton": MessageLookupByLibrary.simpleMessage("Log in"),
        "loginError":
            MessageLookupByLibrary.simpleMessage("Incorrect email or password"),
        "loginSubtitle": MessageLookupByLibrary.simpleMessage(
            "Way more than a simple habit tracker"),
        "loginTitle": MessageLookupByLibrary.simpleMessage(
            "Let your habits speak for you"),
        "logout": MessageLookupByLibrary.simpleMessage("Log out"),
        "logoutConfirmMessage": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to log out of the current session?"),
        "me": MessageLookupByLibrary.simpleMessage("You"),
        "mfaButtonVerify":
            MessageLookupByLibrary.simpleMessage("Verify and Activate"),
        "mfaChallengeSubtitle": MessageLookupByLibrary.simpleMessage(
            "Enter the 6-digit code from your authenticator app to continue."),
        "mfaChallengeTitle":
            MessageLookupByLibrary.simpleMessage("Security Verification"),
        "mfaDisableConfirm":
            MessageLookupByLibrary.simpleMessage("Do you want to disable 2FA?"),
        "mfaDisabled": MessageLookupByLibrary.simpleMessage("2FA is disabled"),
        "mfaEnabled": MessageLookupByLibrary.simpleMessage("2FA is enabled"),
        "mfaEnrollSubtitle": MessageLookupByLibrary.simpleMessage(
            "Copy this secret code to your authentication application (Google Authenticator or similar):"),
        "mfaEnrollTitle":
            MessageLookupByLibrary.simpleMessage("Enable Two Factor"),
        "mfaError":
            MessageLookupByLibrary.simpleMessage("Incorrect or expired code"),
        "mfaLabelCode": MessageLookupByLibrary.simpleMessage(
            "Verification Code (6 digits)"),
        "mfaLabelSecret": MessageLookupByLibrary.simpleMessage("Secret Code"),
        "mfaSuccess": MessageLookupByLibrary.simpleMessage(
            "Two factor successfully activated!"),
        "mfaVerifyButton": MessageLookupByLibrary.simpleMessage("Verify"),
        "nameLabel": MessageLookupByLibrary.simpleMessage("Name"),
        "navHome": MessageLookupByLibrary.simpleMessage("Home"),
        "navNotifications":
            MessageLookupByLibrary.simpleMessage("Notifications"),
        "navProfile": MessageLookupByLibrary.simpleMessage("Profile"),
        "navSearch": MessageLookupByLibrary.simpleMessage("Search"),
        "newPasswordLabel":
            MessageLookupByLibrary.simpleMessage("New Password"),
        "noAccount": MessageLookupByLibrary.simpleMessage(
            "Don\'t have an account? Sign up"),
        "noHabits": MessageLookupByLibrary.simpleMessage(
            "You don\'t have any habits yet. Shall we get started?"),
        "noNotifications":
            MessageLookupByLibrary.simpleMessage("You have no notifications"),
        "noResultsFound":
            MessageLookupByLibrary.simpleMessage("No users found"),
        "passwordLabel": MessageLookupByLibrary.simpleMessage("Password"),
        "passwordTooShort":
            MessageLookupByLibrary.simpleMessage("Minimum 6 characters"),
        "passwordUpdated": MessageLookupByLibrary.simpleMessage(
            "Password updated successfully!"),
        "passwordsDontMatch":
            MessageLookupByLibrary.simpleMessage("Passwords do not match"),
        "privacy": MessageLookupByLibrary.simpleMessage("Privacy"),
        "private": MessageLookupByLibrary.simpleMessage("Private profile"),
        "privateInfoMessage":
            MessageLookupByLibrary.simpleMessage("This information is private"),
        "privateProfileMessage": MessageLookupByLibrary.simpleMessage(
            "This profile is private. Follow it to see its content."),
        "profileTitle": MessageLookupByLibrary.simpleMessage("My Profile"),
        "public": MessageLookupByLibrary.simpleMessage("Public profile"),
        "publicDataPlaceholder": MessageLookupByLibrary.simpleMessage(
            "You\'ll soon be able to see its habits here."),
        "recentActivity":
            MessageLookupByLibrary.simpleMessage("Recent activity"),
        "registerButton": MessageLookupByLibrary.simpleMessage("Sign Up"),
        "registerTitle":
            MessageLookupByLibrary.simpleMessage("Create your account"),
        "registrationPending": MessageLookupByLibrary.simpleMessage(
            "Check your email to confirm account creation!"),
        "reject": MessageLookupByLibrary.simpleMessage("Reject"),
        "remove": MessageLookupByLibrary.simpleMessage("Remove"),
        "removeFollower":
            MessageLookupByLibrary.simpleMessage("Remove follower"),
        "requestPending": MessageLookupByLibrary.simpleMessage("Request sent"),
        "resetEmailSent": MessageLookupByLibrary.simpleMessage(
            "A password reset email has been sent"),
        "saveChanges": MessageLookupByLibrary.simpleMessage("Save Changes"),
        "savingError":
            MessageLookupByLibrary.simpleMessage("Error saving modified data"),
        "searchUsersHint":
            MessageLookupByLibrary.simpleMessage("Search users..."),
        "secretCopied":
            MessageLookupByLibrary.simpleMessage("Secret code copied"),
        "sendRequest": MessageLookupByLibrary.simpleMessage("Send request"),
        "sendResetLink":
            MessageLookupByLibrary.simpleMessage("Send recovery link"),
        "sendResetLinkSubTitle": MessageLookupByLibrary.simpleMessage(
            "Enter your email and we\'ll send you a link to recover access."),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "startedFollowingYou":
            MessageLookupByLibrary.simpleMessage("started following you"),
        "theme": MessageLookupByLibrary.simpleMessage("App Theme"),
        "themeDark": MessageLookupByLibrary.simpleMessage("Dark"),
        "themeLight": MessageLookupByLibrary.simpleMessage("Light"),
        "themeSystem": MessageLookupByLibrary.simpleMessage("System"),
        "totalCount1": MessageLookupByLibrary.simpleMessage("user"),
        "totalCount2": MessageLookupByLibrary.simpleMessage("users"),
        "twoFactorAuth":
            MessageLookupByLibrary.simpleMessage("Two Factor (2FA)"),
        "unfollowConfirm": MessageLookupByLibrary.simpleMessage(
            "Do you want to unfollow this user?"),
        "updatePasswordButton":
            MessageLookupByLibrary.simpleMessage("Save new password"),
        "updatePasswordTitle":
            MessageLookupByLibrary.simpleMessage("Update Password"),
        "updatingPasswordFor": m1,
        "userCoins": m2,
        "usernameInfo":
            MessageLookupByLibrary.simpleMessage("Username cannot be changed."),
        "usernameLabel":
            MessageLookupByLibrary.simpleMessage("Username (nickname)"),
        "validatingData":
            MessageLookupByLibrary.simpleMessage("Validating data..."),
        "wantsToFollow":
            MessageLookupByLibrary.simpleMessage("Wants to follow you"),
        "welcomeUser": m3,
        "xpLevel": m4
      };
}
