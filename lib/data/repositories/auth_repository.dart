import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../core/supabase/supabase_client.dart';
import '../../core/constants.dart';

class AuthRepository {
  /// Sign up a new student with email and password.
  Future<supa.User> signUp({
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw Exception('Sign up failed — no user returned');
    }
    return user;
  }

  /// Sign in with email and password.
  Future<supa.User> signIn({
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw Exception('Sign in failed — no user returned');
    }
    return user;
  }

  /// Sign out the current user and clear the local session.
  Future<void> signOut() async {
    await supabase.auth.signOut(scope: supa.SignOutScope.local);
  }

  /// The currently authenticated user, or null.
  supa.User? get currentUser => supabase.auth.currentUser;

  /// Stream of auth state changes (sign in, sign out, token refresh).
  Stream<supa.AuthState> get onAuthStateChange =>
      supabase.auth.onAuthStateChange;

  /// Determine the role of the current user.
  /// Returns 'moderator', 'student', or null if no profile exists.
  Future<String?> getUserRole(String userId) async {
    // Check moderators first
    final modResult = await supabase
        .from(Tables.moderators)
        .select('id')
        .eq('id', userId)
        .maybeSingle();
    if (modResult != null) return 'moderator';

    // Check students
    final studentResult = await supabase
        .from(Tables.students)
        .select('id')
        .eq('id', userId)
        .maybeSingle();
    if (studentResult != null) return 'student';

    return null;
  }
}
