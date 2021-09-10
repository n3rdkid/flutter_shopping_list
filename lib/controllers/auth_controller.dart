import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_shopping_list/repository/auth_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final authControllerProvider = StateNotifierProvider<AuthController, User?>(
    (ref) => AuthController(ref.read)..appStarted());

class AuthController extends StateNotifier<User?> {
  final Reader _read;
  StreamSubscription<User?>? _authChangesSubscription;
  AuthController(this._read) : super(null) {
    _authChangesSubscription?.cancel();
    _authChangesSubscription = _read(authRepositoryProvider)
        .authStateChanges
        .listen((user) => state = user);
  }
  @override
  void dispose() {
    _authChangesSubscription?.cancel();
    super.dispose();
  }

  void appStarted() {
    final user = _read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      _read(authRepositoryProvider).signInAnonymously();
    }
  }

  void signOut() async {
    await _read(authRepositoryProvider).signOut();
  }
}
