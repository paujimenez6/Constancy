import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool isManualLogin = false;

  UserModel? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  void setUser(UserModel user) {
    _currentUser = user;
    isManualLogin = false;
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
    notifyListeners();
  }
}