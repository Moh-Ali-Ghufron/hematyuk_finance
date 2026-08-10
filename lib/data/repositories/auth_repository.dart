import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class CurrentUserNotifier extends StateNotifier<UserModel?> {
  static const String _userPrefsKey = 'saved_user_profile_json';

  CurrentUserNotifier() : super(UserModel.mock) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userPrefsKey);
      if (userJson != null && userJson.isNotEmpty) {
        state = UserModel.fromMap(Map<String, dynamic>.from(jsonDecode(userJson)));
      }
    } catch (_) {}
  }

  Future<void> updateProfile({required String displayName, required String email}) async {
    final current = state ?? UserModel.mock;
    final updated = current.copyWith(displayName: displayName, email: email);
    state = updated;
    await _save(updated);
  }

  Future<void> setUser(UserModel? user) async {
    state = user;
    await _save(user);
  }

  Future<void> _save(UserModel? user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (user != null) {
        await prefs.setString(_userPrefsKey, jsonEncode(user.toMap()));
      } else {
        await prefs.remove(_userPrefsKey);
      }
    } catch (_) {}
  }
}

final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, UserModel?>((ref) {
  return CurrentUserNotifier();
});

class AuthRepository {
  Future<UserModel?> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (email.isNotEmpty && password.length >= 6) {
      return UserModel(
        uid: 'user_${email.hashCode}',
        displayName: email.split('@').first,
        email: email,
        photoURL: null,
        createdAt: DateTime.now(),
      );
    }
    throw Exception('Email atau password salah');
  }

  Future<UserModel?> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return UserModel(
      uid: 'google_user_123',
      displayName: 'Rizky Pratama',
      email: 'rizky.pratama@gmail.com',
      photoURL: null,
      createdAt: DateTime.now(),
    );
  }

  Future<UserModel?> register(
      String email, String password, String displayName) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return UserModel(
      uid: 'user_${email.hashCode}',
      displayName: displayName,
      email: email,
      photoURL: null,
      createdAt: DateTime.now(),
    );
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
