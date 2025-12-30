import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamicquiz/data/models/user_model.dart';
import 'package:islamicquiz/data/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final userDataProvider = StateNotifierProvider<UserDataNotifier, AsyncValue<UserModel?>>((ref) {
  return UserDataNotifier(ref);
});

class UserDataNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final Ref _ref;

  UserDataNotifier(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _ref.listen(authStateProvider, (previous, next) {
      next.when(
        data: (user) async {
          if (user != null) {
            await loadUserData(user.uid);
          } else {
            state = const AsyncValue.data(null);
          }
        },
        loading: () => state = const AsyncValue.loading(),
        error: (e, st) => state = AsyncValue.error(e, st),
      );
    }, fireImmediately: true);
  }

  Future<void> loadUserData(String uid) async {
    try {
      state = const AsyncValue.loading();
      final authService = _ref.read(authServiceProvider);
      final userData = await authService.getUserData(uid);
      state = AsyncValue.data(userData);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updatePoints(int pointsToAdd) async {
    final currentUser = state.valueOrNull;
    if (currentUser == null) return;

    try {
      final authService = _ref.read(authServiceProvider);
      final updatedUser = await authService.updatePoints(currentUser.uid, pointsToAdd);
      state = AsyncValue.data(updatedUser);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clearUser() {
    state = const AsyncValue.data(null);
  }
}
