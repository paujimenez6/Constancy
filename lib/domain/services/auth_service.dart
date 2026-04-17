import 'dart:io';
import '../../domain/models/user_model.dart';
import '../../persistence/repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _authRepository;

  AuthService(this._authRepository);

  Future<String?> updateProfile({
    required String userId,
    required String nom,
    required String cognom,
    File? imageFile,
    String? currentImageUrl,
  }) async {
    return await _authRepository.updateProfile(
      userId: userId,
      nom: nom,
      cognom: cognom,
      imageFile: imageFile,
      currentImageUrl: currentImageUrl,
    );
  }

  Future<UserModel> signIn(String email, String password) async {
    return await _authRepository.signIn(email, password);
  }

  Future<bool> checkEmailExists(String email) async {
    return await _authRepository.checkEmailExists(email);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    return await _authRepository.sendPasswordResetEmail(email);
  }

  Future<void> loginMFAChallenge(String code) async {
    return await _authRepository.loginMFAChallenge(code);
  }

  Future<void> signOut() async {
    return await _authRepository.signOut();
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String nickname,
    required String nom,
    required String cognom,
  }) async {
    return await _authRepository.signUp(
      email: email,
      password: password,
      nickname: nickname,
      nom: nom,
      cognom: cognom,
    );
  }

  Future<void> updatePrivacy(String userId, TipusPrivacitat nouValor) async {
    return await _authRepository.updatePrivacy(userId, nouValor);
  }

  Future<bool> isMFAEnabled() async {
    return await _authRepository.isMFAEnabled();
  }

  Future<dynamic> enrollMFA() async {
    return await _authRepository.enrollMFA();
  }

  Future<void> verifyMFA(String factorId, String code) async {
    return await _authRepository.verifyMFA(factorId, code);
  }

  Future<String?> getMFAFactorId() async {
    return await _authRepository.getMFAFactorId();
  }

  Future<void> unenrollMFA(String factorId) async {
    return await _authRepository.unenrollMFA(factorId);
  }

  Future<void> deleteAccount() async {
    return await _authRepository.deleteAccount();
  }

  Future<void> updatePassword(String newPassword) async {
    return await _authRepository.updatePassword(newPassword);
  }
}