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

  /// `Forgot your password?`
  String get forgotPassword {
    return Intl.message(
      'Forgot your password?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Send recovery link`
  String get sendResetLink {
    return Intl.message(
      'Send recovery link',
      name: 'sendResetLink',
      desc: '',
      args: [],
    );
  }

  /// `A password reset email has been sent`
  String get resetEmailSent {
    return Intl.message(
      'A password reset email has been sent',
      name: 'resetEmailSent',
      desc: '',
      args: [],
    );
  }

  /// `Update Password`
  String get updatePasswordTitle {
    return Intl.message(
      'Update Password',
      name: 'updatePasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get newPasswordLabel {
    return Intl.message(
      'New Password',
      name: 'newPasswordLabel',
      desc: '',
      args: [],
    );
  }

  /// `Save new password`
  String get updatePasswordButton {
    return Intl.message(
      'Save new password',
      name: 'updatePasswordButton',
      desc: '',
      args: [],
    );
  }

  /// `Password updated successfully!`
  String get passwordUpdated {
    return Intl.message(
      'Password updated successfully!',
      name: 'passwordUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email and we'll send you a link to recover access.`
  String get sendResetLinkSubTitle {
    return Intl.message(
      'Enter your email and we\'ll send you a link to recover access.',
      name: 'sendResetLinkSubTitle',
      desc: '',
      args: [],
    );
  }

  /// `This email is not registered`
  String get errorEmailNotExists {
    return Intl.message(
      'This email is not registered',
      name: 'errorEmailNotExists',
      desc: '',
      args: [],
    );
  }

  /// `Updating password for: {email}`
  String updatingPasswordFor(Object email) {
    return Intl.message(
      'Updating password for: $email',
      name: 'updatingPasswordFor',
      desc: '',
      args: [email],
    );
  }

  /// `New password must be different from current one`
  String get errorSamePassword {
    return Intl.message(
      'New password must be different from current one',
      name: 'errorSamePassword',
      desc: '',
      args: [],
    );
  }

  /// `App Theme`
  String get theme {
    return Intl.message(
      'App Theme',
      name: 'theme',
      desc: '',
      args: [],
    );
  }

  /// `System`
  String get themeSystem {
    return Intl.message(
      'System',
      name: 'themeSystem',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get themeLight {
    return Intl.message(
      'Light',
      name: 'themeLight',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get themeDark {
    return Intl.message(
      'Dark',
      name: 'themeDark',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Catalan`
  String get langCatalan {
    return Intl.message(
      'Catalan',
      name: 'langCatalan',
      desc: '',
      args: [],
    );
  }

  /// `Spanish`
  String get langSpanish {
    return Intl.message(
      'Spanish',
      name: 'langSpanish',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get langEnglish {
    return Intl.message(
      'English',
      name: 'langEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Two Factor (2FA)`
  String get twoFactorAuth {
    return Intl.message(
      'Two Factor (2FA)',
      name: 'twoFactorAuth',
      desc: '',
      args: [],
    );
  }

  /// `2FA is enabled`
  String get mfaEnabled {
    return Intl.message(
      '2FA is enabled',
      name: 'mfaEnabled',
      desc: '',
      args: [],
    );
  }

  /// `2FA is disabled`
  String get mfaDisabled {
    return Intl.message(
      '2FA is disabled',
      name: 'mfaDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Enable Two Factor`
  String get mfaEnrollTitle {
    return Intl.message(
      'Enable Two Factor',
      name: 'mfaEnrollTitle',
      desc: '',
      args: [],
    );
  }

  /// `Copy this secret code to your authentication application (Google Authenticator or similar):`
  String get mfaEnrollSubtitle {
    return Intl.message(
      'Copy this secret code to your authentication application (Google Authenticator or similar):',
      name: 'mfaEnrollSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Secret Code`
  String get mfaLabelSecret {
    return Intl.message(
      'Secret Code',
      name: 'mfaLabelSecret',
      desc: '',
      args: [],
    );
  }

  /// `Verification Code (6 digits)`
  String get mfaLabelCode {
    return Intl.message(
      'Verification Code (6 digits)',
      name: 'mfaLabelCode',
      desc: '',
      args: [],
    );
  }

  /// `Verify and Activate`
  String get mfaButtonVerify {
    return Intl.message(
      'Verify and Activate',
      name: 'mfaButtonVerify',
      desc: '',
      args: [],
    );
  }

  /// `Two factor successfully activated!`
  String get mfaSuccess {
    return Intl.message(
      'Two factor successfully activated!',
      name: 'mfaSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Delete account`
  String get deleteAccount {
    return Intl.message(
      'Delete account',
      name: 'deleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure do you want to permanently delete your account? This action cannot be undone.`
  String get deleteAccountConfirm {
    return Intl.message(
      'Are you sure do you want to permanently delete your account? This action cannot be undone.',
      name: 'deleteAccountConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to disable 2FA?`
  String get mfaDisableConfirm {
    return Intl.message(
      'Do you want to disable 2FA?',
      name: 'mfaDisableConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Security Verification`
  String get mfaChallengeTitle {
    return Intl.message(
      'Security Verification',
      name: 'mfaChallengeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter the 6-digit code from your authenticator app to continue.`
  String get mfaChallengeSubtitle {
    return Intl.message(
      'Enter the 6-digit code from your authenticator app to continue.',
      name: 'mfaChallengeSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Verify`
  String get mfaVerifyButton {
    return Intl.message(
      'Verify',
      name: 'mfaVerifyButton',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect or expired code`
  String get mfaError {
    return Intl.message(
      'Incorrect or expired code',
      name: 'mfaError',
      desc: '',
      args: [],
    );
  }

  /// `Copy secret code`
  String get copySecret {
    return Intl.message(
      'Copy secret code',
      name: 'copySecret',
      desc: '',
      args: [],
    );
  }

  /// `Secret code copied`
  String get secretCopied {
    return Intl.message(
      'Secret code copied',
      name: 'secretCopied',
      desc: '',
      args: [],
    );
  }

  /// `Account successfully deleted`
  String get deletedAccount {
    return Intl.message(
      'Account successfully deleted',
      name: 'deletedAccount',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out of the current session?`
  String get logoutConfirmMessage {
    return Intl.message(
      'Are you sure you want to log out of the current session?',
      name: 'logoutConfirmMessage',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get navSearch {
    return Intl.message(
      'Search',
      name: 'navSearch',
      desc: '',
      args: [],
    );
  }

  /// `Search users...`
  String get searchUsersHint {
    return Intl.message(
      'Search users...',
      name: 'searchUsersHint',
      desc: '',
      args: [],
    );
  }

  /// `Followers`
  String get followers {
    return Intl.message(
      'Followers',
      name: 'followers',
      desc: '',
      args: [],
    );
  }

  /// `Following`
  String get following {
    return Intl.message(
      'Following',
      name: 'following',
      desc: '',
      args: [],
    );
  }

  /// `Privacy`
  String get privacy {
    return Intl.message(
      'Privacy',
      name: 'privacy',
      desc: '',
      args: [],
    );
  }

  /// `Public profile`
  String get public {
    return Intl.message(
      'Public profile',
      name: 'public',
      desc: '',
      args: [],
    );
  }

  /// `Private profile`
  String get private {
    return Intl.message(
      'Private profile',
      name: 'private',
      desc: '',
      args: [],
    );
  }

  /// `Friends only`
  String get friends {
    return Intl.message(
      'Friends only',
      name: 'friends',
      desc: '',
      args: [],
    );
  }

  /// `No users found`
  String get noResultsFound {
    return Intl.message(
      'No users found',
      name: 'noResultsFound',
      desc: '',
      args: [],
    );
  }

  /// `Follow`
  String get follow {
    return Intl.message(
      'Follow',
      name: 'follow',
      desc: '',
      args: [],
    );
  }

  /// `Send request`
  String get sendRequest {
    return Intl.message(
      'Send request',
      name: 'sendRequest',
      desc: '',
      args: [],
    );
  }

  /// `Request sent`
  String get requestPending {
    return Intl.message(
      'Request sent',
      name: 'requestPending',
      desc: '',
      args: [],
    );
  }

  /// `This profile is private. Follow it to see its content.`
  String get privateProfileMessage {
    return Intl.message(
      'This profile is private. Follow it to see its content.',
      name: 'privateProfileMessage',
      desc: '',
      args: [],
    );
  }

  /// `You'll soon be able to see its habits here.`
  String get publicDataPlaceholder {
    return Intl.message(
      'You\'ll soon be able to see its habits here.',
      name: 'publicDataPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to unfollow this user?`
  String get unfollowConfirm {
    return Intl.message(
      'Do you want to unfollow this user?',
      name: 'unfollowConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get navNotifications {
    return Intl.message(
      'Notifications',
      name: 'navNotifications',
      desc: '',
      args: [],
    );
  }

  /// `You have no notifications`
  String get noNotifications {
    return Intl.message(
      'You have no notifications',
      name: 'noNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Wants to follow you`
  String get wantsToFollow {
    return Intl.message(
      'Wants to follow you',
      name: 'wantsToFollow',
      desc: '',
      args: [],
    );
  }

  /// `Accept`
  String get accept {
    return Intl.message(
      'Accept',
      name: 'accept',
      desc: '',
      args: [],
    );
  }

  /// `Reject`
  String get reject {
    return Intl.message(
      'Reject',
      name: 'reject',
      desc: '',
      args: [],
    );
  }

  /// `This information is private`
  String get privateInfoMessage {
    return Intl.message(
      'This information is private',
      name: 'privateInfoMessage',
      desc: '',
      args: [],
    );
  }

  /// `You`
  String get me {
    return Intl.message(
      'You',
      name: 'me',
      desc: '',
      args: [],
    );
  }

  /// `started following you`
  String get startedFollowingYou {
    return Intl.message(
      'started following you',
      name: 'startedFollowingYou',
      desc: '',
      args: [],
    );
  }

  /// `Follow requests`
  String get followRequests {
    return Intl.message(
      'Follow requests',
      name: 'followRequests',
      desc: '',
      args: [],
    );
  }

  /// `Recent activity`
  String get recentActivity {
    return Intl.message(
      'Recent activity',
      name: 'recentActivity',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get remove {
    return Intl.message(
      'Remove',
      name: 'remove',
      desc: '',
      args: [],
    );
  }

  /// `Remove follower`
  String get removeFollower {
    return Intl.message(
      'Remove follower',
      name: 'removeFollower',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove`
  String get confirmRemoveFollower {
    return Intl.message(
      'Are you sure you want to remove',
      name: 'confirmRemoveFollower',
      desc: '',
      args: [],
    );
  }

  /// `List of`
  String get listFor {
    return Intl.message(
      'List of',
      name: 'listFor',
      desc: '',
      args: [],
    );
  }

  /// `user`
  String get totalCount1 {
    return Intl.message(
      'user',
      name: 'totalCount1',
      desc: '',
      args: [],
    );
  }

  /// `users`
  String get totalCount2 {
    return Intl.message(
      'users',
      name: 'totalCount2',
      desc: '',
      args: [],
    );
  }

  /// `Data Consent`
  String get consentTitle {
    return Intl.message(
      'Data Consent',
      name: 'consentTitle',
      desc: '',
      args: [],
    );
  }

  /// `In order to create your account on Constancy, we need your permission to store your email and profile data on our secure servers. This data is used exclusively for the management of your habits and will not be shared with third parties. You can delete your account and your data at any time from the settings.`
  String get consentDescription {
    return Intl.message(
      'In order to create your account on Constancy, we need your permission to store your email and profile data on our secure servers. This data is used exclusively for the management of your habits and will not be shared with third parties. You can delete your account and your data at any time from the settings.',
      name: 'consentDescription',
      desc: '',
      args: [],
    );
  }

  /// `Deny`
  String get decline {
    return Intl.message(
      'Deny',
      name: 'decline',
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
