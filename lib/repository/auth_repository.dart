import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_shopping_list/general_providers.dart';
import 'package:flutter_shopping_list/repository/custom_exception.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class BaseAuthRepository {
  Stream<User?> get authStateChanges;
  Future<void> signInAnonymously();
  User? getCurrentUser();
  Future<void> signOut();
}

final authServiceProvider =
    Provider<AuthRepository>((ref) => AuthRepository(ref.read));

class AuthRepository implements BaseAuthRepository {
  final Reader _read;

  const AuthRepository(this._read);
  @override
  // TODO: implement authStateChanges
  @override
  Stream<User?> get authStateChanges =>
      _read(firebaseAuthProvider).authStateChanges();

  @override
  Future<void> signInAnonymously() async {
    try {
      await _read(firebaseAuthProvider).signInAnonymously();
    } catch (e) {
      CustomException(message: "Firebase failed to sign in.");
    }
  }

  @override
  User? getCurrentUser() {
    return _read(firebaseAuthProvider).currentUser;
  }

  @override
  Future<void> signOut() async {
    await _read(firebaseAuthProvider).signInAnonymously();
  }
}
