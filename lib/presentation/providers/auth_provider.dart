import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/exceptions/app_exceptions.dart';

// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Auth State Provider - Stream of current user
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges
      .map((authState) => authState.session?.user);
});

// Current User Profile Provider
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) async {
      if (user == null) return null;

      try {
        final authRepository = ref.read(authRepositoryProvider);
        return await authRepository.getCurrentUserProfile();
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Auth Controller
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository);
});

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AuthState.initial());

  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    state = const AuthState.loading();

    try {
      final user = await _authRepository.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      state = AuthState.success(user);
    } on AppAuthException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = const AuthState.error('An unexpected error occurred');
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();

    try {
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );

      state = AuthState.success(user);
    } on AppAuthException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = const AuthState.error('An unexpected error occurred');
    }
  }

  Future<void> signOut() async {
    state = const AuthState.loading();

    try {
      await _authRepository.signOut();
      state = const AuthState.signedOut();
    } catch (e) {
      state = const AuthState.error('Failed to sign out');
    }
  }

  Future<void> resetPassword(String email) async {
    state = const AuthState.loading();

    try {
      await _authRepository.resetPassword(email);
      state = const AuthState.passwordResetSent();
    } on AppAuthException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = const AuthState.error('Failed to send reset email');
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    state = const AuthState.loading();

    try {
      final user = await _authRepository.updateProfile(
        fullName: fullName,
        avatarUrl: avatarUrl,
      );

      state = AuthState.success(user);
    } catch (e) {
      state = const AuthState.error('Failed to update profile');
    }
  }

  void clearError() {
    if (state is AuthStateError) {
      state = const AuthState.initial();
    }
  }
}

// Auth State Classes
sealed class AuthState {
  const AuthState();

  const factory AuthState.initial() = AuthStateInitial;
  const factory AuthState.loading() = AuthStateLoading;
  const factory AuthState.success(UserModel user) = AuthStateSuccess;
  const factory AuthState.error(String message) = AuthStateError;
  const factory AuthState.signedOut() = AuthStateSignedOut;
  const factory AuthState.passwordResetSent() = AuthStatePasswordResetSent;
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateSuccess extends AuthState {
  final UserModel user;
  const AuthStateSuccess(this.user);
}

class AuthStateError extends AuthState {
  final String message;
  const AuthStateError(this.message);
}

class AuthStateSignedOut extends AuthState {
  const AuthStateSignedOut();
}

class AuthStatePasswordResetSent extends AuthState {
  const AuthStatePasswordResetSent();
}

// Helper providers for easier access
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (user) => user != null,
    orElse: () => false,
  );
});

final isLoadingProvider = Provider<bool>((ref) {
  final authController = ref.watch(authControllerProvider);
  return authController is AuthStateLoading;
});
