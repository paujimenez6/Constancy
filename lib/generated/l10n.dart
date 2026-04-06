// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Constancy`
  String get appTitle {
    return Intl.message(
      'Constancy',
      name: 'appTitle',
      desc: '',
      args: [],
    );
  }

  /// `Let your habits speak for you`
  String get loginTitle {
    return Intl.message(
      'Let your habits speak for you',
      name: 'loginTitle',
      desc: '',
      args: [],
    );
  }

  /// `Way more than a simple habit tracker`
  String get loginSubtitle {
    return Intl.message(
      'Way more than a simple habit tracker',
      name: 'loginSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Email address`
  String get emailLabel {
    return Intl.message(
      'Email address',
      name: 'emailLabel',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get passwordLabel {
    return Intl.message(
      'Password',
      name: 'passwordLabel',
      desc: '',
      args: [],
    );
  }

  /// `Log in`
  String get loginButton {
    return Intl.message(
      'Log in',
      name: 'loginButton',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account? Sign up`
  String get noAccount {
    return Intl.message(
      'Don\'t have an account? Sign up',
      name: 'noAccount',
      desc: '',
      args: [],
    );
  }

  /// `Processing...`
  String get loading {
    return Intl.message(
      'Processing...',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `Create your account`
  String get registerTitle {
    return Intl.message(
      'Create your account',
      name: 'registerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get nameLabel {
    return Intl.message(
      'Name',
      name: 'nameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Last name`
  String get lastNameLabel {
    return Intl.message(
      'Last name',
      name: 'lastNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Username (nickname)`
  String get usernameLabel {
    return Intl.message(
      'Username (nickname)',
      name: 'usernameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Confirm password`
  String get confirmPasswordLabel {
    return Intl.message(
      'Confirm password',
      name: 'confirmPasswordLabel',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get registerButton {
    return Intl.message(
      'Sign Up',
      name: 'registerButton',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account? Log in`
  String get alreadyHaveAccount {
    return Intl.message(
      'Already have an account? Log in',
      name: 'alreadyHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email address`
  String get invalidEmail {
    return Intl.message(
      'Invalid email address',
      name: 'invalidEmail',
      desc: '',
      args: [],
    );
  }

  /// `This field is required`
  String get fieldRequired {
    return Intl.message(
      'This field is required',
      name: 'fieldRequired',
      desc: '',
      args: [],
    );
  }

  /// `Validating data...`
  String get validatingData {
    return Intl.message(
      'Validating data...',
      name: 'validatingData',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get passwordsDontMatch {
    return Intl.message(
      'Passwords do not match',
      name: 'passwordsDontMatch',
      desc: '',
      args: [],
    );
  }

  /// `Creating account...`
  String get creatingAccount {
    return Intl.message(
      'Creating account...',
      name: 'creatingAccount',
      desc: '',
      args: [],
    );
  }

  /// `Minimum 6 characters`
  String get passwordTooShort {
    return Intl.message(
      'Minimum 6 characters',
      name: 'passwordTooShort',
      desc: '',
      args: [],
    );
  }

  /// `Check your email to confirm account creation!`
  String get registrationPending {
    return Intl.message(
      'Check your email to confirm account creation!',
      name: 'registrationPending',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect email or password`
  String get loginError {
    return Intl.message(
      'Incorrect email or password',
      name: 'loginError',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred: {error}`
  String authError(Object error) {
    return Intl.message(
      'An error occurred: $error',
      name: 'authError',
      desc: '',
      args: [error],
    );
  }

  /// `¡Welcome, {name}!`
  String welcomeUser(Object name) {
    return Intl.message(
      '¡Welcome, $name!',
      name: 'welcomeUser',
      desc: '',
      args: [name],
    );
  }

  /// `My Habits`
  String get homeTitle {
    return Intl.message(
      'My Habits',
      name: 'homeTitle',
      desc: '',
      args: [],
    );
  }

  /// `You don't have any habits yet. Shall we get started?`
  String get noHabits {
    return Intl.message(
      'You don\'t have any habits yet. Shall we get started?',
      name: 'noHabits',
      desc: '',
      args: [],
    );
  }

  /// `Add habit`
  String get addHabit {
    return Intl.message(
      'Add habit',
      name: 'addHabit',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get logout {
    return Intl.message(
      'Log out',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `This username is already in use. Please choose another one.`
  String get errorNicknameTaken {
    return Intl.message(
      'This username is already in use. Please choose another one.',
      name: 'errorNicknameTaken',
      desc: '',
      args: [],
    );
  }

  /// `This email address already exists.`
  String get errorEmailExists {
    return Intl.message(
      'This email address already exists.',
      name: 'errorEmailExists',
      desc: '',
      args: [],
    );
  }

  /// `An unexpected error occurred. Please try again.`
  String get errorUnknown {
    return Intl.message(
      'An unexpected error occurred. Please try again.',
      name: 'errorUnknown',
      desc: '',
      args: [],
    );
  }

  /// `Error connecting to the server.`
  String get errorConnection {
    return Intl.message(
      'Error connecting to the server.',
      name: 'errorConnection',
      desc: '',
      args: [],
    );
  }

  /// `Account successfully verified! You can now log in.`
  String get accountVerified {
    return Intl.message(
      'Account successfully verified! You can now log in.',
      name: 'accountVerified',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get navHome {
    return Intl.message(
      'Home',
      name: 'navHome',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get navProfile {
    return Intl.message(
      'Profile',
      name: 'navProfile',
      desc: '',
      args: [],
    );
  }

  /// `My Profile`
  String get profileTitle {
    return Intl.message(
      'My Profile',
      name: 'profileTitle',
      desc: '',
      args: [],
    );
  }

  /// `Edit Profile`
  String get editProfile {
    return Intl.message(
      'Edit Profile',
      name: 'editProfile',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Level {level}`
  String xpLevel(Object level) {
    return Intl.message(
      'Level $level',
      name: 'xpLevel',
      desc: '',
      args: [level],
    );
  }

  /// `{coins} coins`
  String userCoins(Object coins) {
    return Intl.message(
      '$coins coins',
      name: 'userCoins',
      desc: '',
      args: [coins],
    );
  }

  /// `Change photo`
  String get changePhoto {
    return Intl.message(
      'Change photo',
      name: 'changePhoto',
      desc: '',
      args: [],
    );
  }

  /// `Error saving modified data`
  String get savingError {
    return Intl.message(
      'Error saving modified data',
      name: 'savingError',
      desc: '',
      args: [],
    );
  }

  /// `Edit Profile`
  String get editProfileTitle {
    return Intl.message(
      'Edit Profile',
      name: 'editProfileTitle',
      desc: '',
      args: [],
    );
  }

  /// `Save Changes`
  String get saveChanges {
    return Intl.message(
      'Save Changes',
      name: 'saveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Profile Updated`
  String get changesSaved {
    return Intl.message(
      'Profile Updated',
      name: 'changesSaved',
      desc: '',
      args: [],
    );
  }

  /// `Username cannot be changed.`
  String get usernameInfo {
    return Intl.message(
      'Username cannot be changed.',
      name: 'usernameInfo',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ca'),
      Locale.fromSubtags(languageCode: 'es'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
