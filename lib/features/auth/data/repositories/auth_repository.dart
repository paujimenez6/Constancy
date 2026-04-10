import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'dart:convert';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> signUp({
    required String email,
    required String password,
    required String nickname,
    required String nom,
    required String cognom,
  }) async {
    try {

      final existingNickname = await _supabase
          .from('profiles')
          .select('nickname')
          .eq('nickname', nickname)
          .maybeSingle();

      if (existingNickname != null) throw 'NICKNAME_TAKEN';

      await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'io.supabase.constancy://login-callback',
        data: {
          'nickname': nickname,
          'nom': nom,
          'cognom': cognom,
        },
      );

    } on AuthException catch (e) {
      if (e.code == 'user_already_exists') throw 'EMAIL_EXISTS';
      throw e.message;
    } catch (e) {
      if (e == 'NICKNAME_TAKEN') rethrow;
      debugPrint("Error: $e");
      throw 'UNKNOWN';
    }
  }

  Future<UserModel> signIn(String email, String password) async {
    try {
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user == null) throw Exception('Usuari no trobat');

      final Map<String, dynamic> data = await _supabase
          .from('profiles')
          .select()
          .eq('id', res.user!.id)
          .single();

      data['token'] = res.session?.accessToken;

      return UserModel.fromJson(data);
    } catch (e) {
      throw Exception('Error en l\'inici de sessió: $e');
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final res = await _supabase
          .from('profiles')
          .select('id')
          .eq('correu', email)
          .maybeSingle();

      return res != null;
    } catch (e) {
      debugPrint("Error checkEmailExists: $e");
      return false;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.constancy://login-callback',
      );
    } catch (e) {
      throw Exception('Error enviant correu de recuperació: $e');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword),);
    } catch (e) {
      throw Exception('Error actualitzant contrasenya: $e');
    }
  }

  Future<String?> getMFAFactorId() async {
    try {
      final res = await _supabase.auth.mfa.listFactors();
      if (res.all.isEmpty) return null;

      return res.all.firstWhere((f) => f.status == FactorStatus.verified).id;
    } catch (e) {
      debugPrint("Error obtenint MFA Factor ID: $e");
      return null;
    }
  }

  Future<dynamic> enrollMFA() async {
    try {
      final factorsRes = await _supabase.auth.mfa.listFactors();
      final unverifiedFactors = factorsRes.all.where((f) => f.status.name != 'verified');

      for (var factor in unverifiedFactors) {
        await _supabase.auth.mfa.unenroll(factor.id);
      }

      return await _supabase.auth.mfa.enroll(factorType: FactorType.totp, issuer: 'Constancy',);
    } catch (e) {
      throw Exception('Error en enrolar MFA: $e');
    }
  }

  Future<void> verifyMFA(String factorId, String code) async {
    try {
      final challenge = await _supabase.auth.mfa.challenge(factorId: factorId);

      await _supabase.auth.mfa.verify(factorId: factorId, challengeId: challenge.id, code: code,);

    } catch (e) {
      print("Error en verifyMFA: $e");
      rethrow;
    }
  }

  Future<void> unenrollMFA(String factorId) async {
    await _supabase.auth.mfa.unenroll(factorId);
  }

  Future<bool> isMFAEnabled() async {
    final res = await _supabase.auth.mfa.listFactors();
    return res.all.any((f) => f.status == FactorStatus.verified);
  }

  Future<void> loginMFAChallenge(String code) async {
    try {
      final factors = await _supabase.auth.mfa.listFactors();
      final verifiedFactor = factors.all.firstWhere((f) => f.status.name == 'verified');
      final challenge = await _supabase.auth.mfa.challenge(factorId: verifiedFactor.id);

      await _supabase.auth.mfa.verify(factorId: verifiedFactor.id, challengeId: challenge.id, code: code,);

    } catch (e) {
      print("Error en loginMFAChallenge: $e");
      throw Exception('MFA_ERROR');
    }
  }

  Future<void> deleteAccount() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      try {
        final String folderPath = user.id;
        final List<FileObject> files = await _supabase.storage.from('avatars').list(path: folderPath);
        if (files.isNotEmpty) {
          final List<String> toDelete = files.map((f) => '$folderPath/${f.name}').toList();
          await _supabase.storage.from('avatars').remove(toDelete);
        }
      } catch (e) {
        print("Error netejant Storage: $e");
      }

      await _supabase.rpc('delete_current_user');
      await _supabase.auth.signOut();

    } catch (e) {
      print("Error esborrant compte: $e");
      rethrow;
    }
  }

  static String getAalFromJWT(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return 'aal1';

      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final Map<String, dynamic> data = json.decode(payload);

      return data['aal'] ?? 'aal1';
    } catch (e) {
      print("Error decodificant JWT: $e");
      return 'aal1';
    }
  }
}

