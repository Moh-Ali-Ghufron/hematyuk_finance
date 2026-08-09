import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final currentUserProvider = StateProvider<UserModel?>((ref) {
  return UserModel.mock; // Auto-login with mock user for demo
});

class AuthRepository {
  UserModel? _currentUser = UserModel.mock; // Mock auto-login

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<UserModel?> signInWithEmail(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (email.isNotEmpty && password.length >= 6) {
      _currentUser = UserModel(
        uid: 'user_${email.hashCode}',
        displayName: email.split('@').first,
        email: email,
        photoURL: null,
        createdAt: DateTime.now(),
      );
      return _currentUser;
    }
    throw Exception('Email atau password salah');
  }

  Future<UserModel?> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = UserModel(
      uid: 'google_user_123',
      displayName: 'Rizky Pratama',
      email: 'rizky.pratama@gmail.com',
      photoURL: null,
      createdAt: DateTime.now(),
    );
    return _currentUser;
  }

  Future<UserModel?> register(
      String email, String password, String displayName) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = UserModel(
      uid: 'user_${email.hashCode}',
      displayName: displayName,
      email: email,
      photoURL: null,
      createdAt: DateTime.now(),
    );
    return _currentUser;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }
}
