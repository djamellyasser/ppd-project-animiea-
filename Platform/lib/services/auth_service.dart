import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _client = Supabase.instance.client;

  // Current user
  User? get currentUser => _client.auth.currentUser;

  // Current user ID
  String? get currentUserId => _client.auth.currentUser?.id;

  // Auth state stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Sign up
  Future<AuthResponse> signUp(String email, String password) async {
    try {
      return await _client.auth.signUp(
        email: email.trim(),
        password: password.trim(),
      );
    } on AuthException catch (e) {
      print('AUTH EXCEPTION: ${e.message} | Status: ${e.statusCode}');
      throw _handleError(e);
    } catch (e) {
      print('UNKNOWN ERROR: $e');
      rethrow;
    }
  }

  // Login
  Future<AuthResponse> login(String email, String password) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on AuthException catch (e) {
      throw _handleError(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  String _handleError(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('user already registered')) {
      return 'An account already exists with this email.';
    } else if (msg.contains('invalid login credentials')) {
      return 'Incorrect email or password.';
    } else if (msg.contains('password should be at least')) {
      return 'Password must be at least 6 characters.';
    } else if (msg.contains('unable to validate email')) {
      return 'Please enter a valid email address.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }
}