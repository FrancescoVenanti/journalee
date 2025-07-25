import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';
import '../../core/exceptions/app_exceptions.dart';

class AuthRepository {
  final SupabaseService _supabaseService;

  AuthRepository({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService.instance;

  Stream<AuthState> get authStateChanges => _supabaseService.authStateChanges;

  User? get currentUser => _supabaseService.currentUser;

  bool get isAuthenticated => currentUser != null;

  Future<UserModel> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (response.user == null) {
        throw const AppAuthException(
          'Failed to create account. Please try again.',
        );
      }

      // Wait a bit for the trigger to create the profile
      await Future.delayed(const Duration(milliseconds: 500));

      // Get the user profile (it should be created by the trigger)
      try {
        final profile = await _getUserProfile(response.user!.id);
        return profile;
      } catch (e) {
        // If profile doesn't exist, create it manually
        await _createUserProfile(
          userId: response.user!.id,
          email: email,
          fullName: fullName,
        );
        return await _getUserProfile(response.user!.id);
      }
    } on AuthException catch (e) {
      throw AppAuthException(_getReadableAuthError(e.message));
    } catch (e) {
      throw AppAuthException(
          'An unexpected error occurred during sign up: ${e.toString()}');
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AppAuthException(
          'Invalid email or password. Please try again.',
        );
      }

      final profile = await _getUserProfile(response.user!.id);
      return profile;
    } on AuthException catch (e) {
      throw AppAuthException(_getReadableAuthError(e.message));
    } catch (e) {
      throw AppAuthException(
          'An unexpected error occurred during sign in: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
    } catch (e) {
      throw const AppAuthException('Failed to sign out. Please try again.');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabaseService.resetPassword(email);
    } on AuthException catch (e) {
      throw AppAuthException(_getReadableAuthError(e.message));
    } catch (e) {
      throw const AppAuthException(
          'Failed to send reset email. Please try again.');
    }
  }

  Future<UserModel> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) {
      throw const AppAuthException('No user is currently signed in.');
    }

    return await _getUserProfile(user.id);
  }

  Future<UserModel> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw const AppAuthException('No user is currently signed in.');
    }

    try {
      await _supabaseService.updateUserProfile(
        userId: user.id,
        fullName: fullName,
        avatarUrl: avatarUrl,
      );

      return await _getUserProfile(user.id);
    } catch (e) {
      throw AppAuthException('Failed to update profile: ${e.toString()}');
    }
  }

  Future<UserModel> _getUserProfile(String userId) async {
    try {
      final profileData = await _supabaseService.getUserProfile(userId);

      if (profileData == null) {
        throw const AppAuthException('User profile not found.');
      }

      return UserModel.fromJson(profileData);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      throw AppAuthException('Failed to load user profile: ${e.toString()}');
    }
  }

  Future<void> _createUserProfile({
    required String userId,
    required String email,
    String? fullName,
  }) async {
    try {
      await _supabaseService.from('profiles').insert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw AppAuthException('Failed to create user profile: ${e.toString()}');
    }
  }

  String _getReadableAuthError(String message) {
    // Convert Supabase auth errors to user-friendly messages
    if (message.contains('Invalid login credentials')) {
      return 'Invalid email or password. Please check your credentials and try again.';
    }
    if (message.contains('User already registered')) {
      return 'An account with this email already exists. Please sign in instead.';
    }
    if (message.contains('Password should be at least')) {
      return 'Password should be at least 6 characters long.';
    }
    if (message.contains('Invalid email')) {
      return 'Please enter a valid email address.';
    }
    if (message.contains('Email not confirmed')) {
      return 'Please check your email and confirm your account before signing in.';
    }
    if (message.contains('Email rate limit exceeded')) {
      return 'Too many requests. Please wait a moment before trying again.';
    }
    if (message.contains('Signup disabled')) {
      return 'Account creation is currently disabled. Please contact support.';
    }

    // Return original message if no specific case matches
    return message;
  }
}
