import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';
import '../../domain/models/user_model.dart';
import '../../domain/services/achievement_service.dart';
import '../../domain/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final AchievementService _achievementService;

  UserModel? _currentUser;
  bool isManualLogin = false;
  int _currentTabIndex = 0;
  StreamSubscription? _profileSubscription;

  AuthProvider(this._authService, this._achievementService);

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  int get currentTabIndex => _currentTabIndex;

  void setUser(UserModel user) {
    _currentUser = user;
    isManualLogin = false;
    notifyListeners();
  }

  void initProfileListener(String userId) {
    _profileSubscription?.cancel();
    _profileSubscription = _authService.listenToProfile(userId).listen((updatedUser) {
      _currentUser = updatedUser;
      notifyListeners();
    });
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

  Future<void> signOut() async {
    await _authService.signOut();
    logout();
  }

  Future<void> updateProfile({
    required String nom,
    required String cognom,
    File? imageFile,
  }) async {
    if (_currentUser == null) return;

    final updatedUser = await _authService.updateFullProfile(
      userId: _currentUser!.id,
      nom: nom,
      cognom: cognom,
      imageFile: imageFile,
      currentImageUrl: _currentUser!.imatgePerfil,
    );

    _currentUser = updatedUser;
    notifyListeners();
  }

  Future<void> updatePrivacy(String userId, TipusPrivacitat nouValor) async {
    final updatedUser = await _authService.updateUserPrivacy(userId, nouValor);
    _currentUser = updatedUser;
    notifyListeners();
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

  Future<bool> checkEmailExists(String email) => _authService.checkEmailExists(email);
  Future<void> sendPasswordResetEmail(String email) => _authService.sendPasswordResetEmail(email);
  Future<void> updatePassword(String newPassword) => _authService.updatePassword(newPassword);
  Future<void> loginMFAChallenge(String code) => _authService.loginMFAChallenge(code);
  Future<bool> isMFAEnabled() => _authService.isMFAEnabled();
  Future<dynamic> enrollMFA() => _authService.enrollMFA();
  Future<String?> getMFAFactorId() => _authService.getMFAFactorId();
  Future<void> unenrollMFA(String factorId) => _authService.unenrollMFA(factorId);

  Future<void> verifyMFA(String factorId, String code) async {
    try {
      await _authService.verifyMFA(factorId, code);

      if (_currentUser != null) {
        await _achievementService.setAbsoluteProgress(_currentUser!.id, 'activarMfa', 1);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    await _authService.deleteAccount();
    logout();
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

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }
}