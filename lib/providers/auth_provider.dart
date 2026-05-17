import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  User? _user;
  String? _errorMessage;
  bool _isConfirmationPending = false;

  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isConfirmationPending => _isConfirmationPending;

  AuthProvider() {
    _init();
  }

  void _init() {
    _user = _supabase.auth.currentUser;
    _supabase.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      _isConfirmationPending = false;
      notifyListeners();
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      _errorMessage = null;
      _isConfirmationPending = false;
      notifyListeners();
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return true;
    } on AuthException catch (e) {
      _errorMessage = _friendlyAuthError(e.message);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> signup(String email, String password, String name) async {
    try {
      _errorMessage = null;
      _isConfirmationPending = false;
      notifyListeners();

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      // If session is null but user exists → email confirmation required
      if (response.session == null && response.user != null) {
        _isConfirmationPending = true;
        notifyListeners();
        return true; // signup call succeeded, just needs confirmation
      }

      return true;
    } on AuthException catch (e) {
      _errorMessage = _friendlyAuthError(e.message);
      return false;
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('rate') || msg.contains('limit') || msg.contains('too many')) {
        _errorMessage =
            'Email rate limit reached. Please wait a few minutes and try again.';
      } else {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      }
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    _user = null;
    _isConfirmationPending = false;
    notifyListeners();
  }

  /// Opens browser for Google OAuth via Supabase.
  /// Requires Google provider to be enabled in Supabase Dashboard →
  /// Authentication → Providers → Google.
  Future<bool> signInWithGoogle() async {
    try {
      _errorMessage = null;
      notifyListeners();
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.notewiz://login-callback/',
      );
      return true;
    } on AuthException catch (e) {
      _errorMessage = _friendlyAuthError(e.message);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Google sign-in failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Opens browser for Apple OAuth via Supabase.
  /// Requires Apple provider to be enabled in Supabase Dashboard →
  /// Authentication → Providers → Apple.
  Future<bool> signInWithApple() async {
    try {
      _errorMessage = null;
      notifyListeners();
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.notewiz://login-callback/',
      );
      return true;
    } on AuthException catch (e) {
      _errorMessage = _friendlyAuthError(e.message);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Apple sign-in failed. Please try again.';
      notifyListeners();
      return false;
    }
  }


  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _errorMessage = null;
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } on AuthException catch (e) {
      _errorMessage = _friendlyAuthError(e.message);
      return false;
    } catch (e) {
      _errorMessage = 'Could not send reset email. Check your connection.';
      return false;
    } finally {
      notifyListeners();
    }
  }


  /// Converts raw Supabase error messages to friendly, readable ones.
  String _friendlyAuthError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('rate limit') ||
        lower.contains('email rate') ||
        lower.contains('too many') ||
        lower.contains('over_email_send_rate_limit') ||
        lower.contains('for security purposes')) {
      return 'Email rate limit reached.\n\nSupabase only allows a few sign-up '
          'emails per hour on the free plan. Please wait a few minutes before '
          'trying again, or use a different email address.';
    }
    if (lower.contains('user already registered') ||
        lower.contains('already registered') ||
        lower.contains('already been registered')) {
      return 'This email is already registered. Please login instead.';
    }
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid email or password') ||
        lower.contains('email not confirmed')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please confirm your email address before logging in.';
    }
    if (lower.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }
    if (lower.contains('password') && lower.contains('weak')) {
      return 'Password is too weak. Use at least 8 characters.';
    }
    if (lower.contains('network') || lower.contains('connection')) {
      return 'No internet connection. Please check your network and try again.';
    }
    return raw;
  }
}
