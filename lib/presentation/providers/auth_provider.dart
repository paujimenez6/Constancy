import 'package:flutter/material.dart';
import 'dart:io';
import '../../domain/models/user_model.dart';
import '../../domain/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  UserModel? _currentUser;
  bool isManualLogin = false;
  int _currentTabIndex = 0;

  AuthProvider(this._authService);

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  int get currentTabIndex => _currentTabIndex;

  void setUser(UserModel user) {
    _currentUser = user;
    isManualLogin = false;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    isManualLogin = true;
    try {
      final user = await _authService.signIn(email, password);
      setUser(user);
    } catch (e) {
      isManualLogin = false;
      rethrow;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String nickname,
    required String nom,
    required String cognom,
  }) async {
    await _authService.signUp(
      email: email,
      password: password,
      nickname: nickname,
      nom: nom,
      cognom: cognom,
    );
  }

  Future<bool> checkEmailExists(String email) async {
    return await _authService.checkEmailExists(email);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  Future<void> loginMFAChallenge(String code) async {
    await _authService.loginMFAChallenge(code);
  }

  Future<void> signOut() async {
    await _authService.signOut();
    logout();
  }

  Future<void> updateProfile({
    required String nom,
    required String cognom,
    File? imageFile,
  }) async {
    if (_currentUser == null) throw Exception("No hi ha cap usuari loguejat");

    final String? finalImageUrl = await _authService.updateProfile(
      userId: _currentUser!.id,
      nom: nom,
      cognom: cognom,
      imageFile: imageFile,
      currentImageUrl: _currentUser!.imatgePerfil,
    );

    _currentUser = _currentUser!.copyWith(
      nom: nom,
      cognom: cognom,
      imatgePerfil: finalImageUrl ?? _currentUser!.imatgePerfil,
    );
    notifyListeners();
  }

  void updateProfileImage(String newUrl) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(imatgePerfil: newUrl);
      notifyListeners();
    }
  }

  void updateUserData({required String nom, required String cognom}) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(nom: nom, cognom: cognom);
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    isManualLogin = false;
    _currentTabIndex = 0;
    notifyListeners();
  }

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  Future<void> updatePrivacy(String userId, TipusPrivacitat nouValor) async {
    await _authService.updatePrivacy(userId, nouValor);

    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(configuracioPrivacitat: nouValor);
      notifyListeners();
    }
  }

  Future<bool> isMFAEnabled() async {
    return await _authService.isMFAEnabled();
  }

  Future<dynamic> enrollMFA() async {
    return await _authService.enrollMFA();
  }

  Future<void> verifyMFA(String factorId, String code) async {
    await _authService.verifyMFA(factorId, code);
  }

  Future<String?> getMFAFactorId() async {
    return await _authService.getMFAFactorId();
  }

  Future<void> unenrollMFA(String factorId) async {
    await _authService.unenrollMFA(factorId);
  }

  Future<void> deleteAccount() async {
    await _authService.deleteAccount();
    logout();
  }

  Future<void> updatePassword(String newPassword) async {
    await _authService.updatePassword(newPassword);
  }
}