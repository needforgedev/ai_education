import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../data/models/student.dart';

// Repository providers
final authRepositoryProvider = Provider((ref) => AuthRepository());
final studentRepositoryProvider = Provider((ref) => StudentRepository());

/// Holds the current auth + profile state.
class AuthState {
  final supa.User? user;
  final String? role; // 'student' | 'moderator' | null
  final Student? studentProfile;
  final String? schoolName;
  final String? cohortName;
  final bool isLoading;

  const AuthState({
    this.user,
    this.role,
    this.studentProfile,
    this.schoolName,
    this.cohortName,
    this.isLoading = false,
  });

  bool get isAuthenticated => user != null;
  bool get isModerator => role == 'moderator';
  bool get isStudent => role == 'student';
  bool get hasProfile => role != null;

  AuthState copyWith({
    supa.User? user,
    String? role,
    Student? studentProfile,
    String? schoolName,
    String? cohortName,
    bool? isLoading,
    bool clearUser = false,
    bool clearRole = false,
    bool clearProfile = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      role: clearRole ? null : (role ?? this.role),
      studentProfile:
          clearProfile ? null : (studentProfile ?? this.studentProfile),
      schoolName: schoolName ?? this.schoolName,
      cohortName: cohortName ?? this.cohortName,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Main auth state notifier — manages sign in, sign up, sign out,
/// and listens to Supabase auth state changes.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepo;
  final StudentRepository _studentRepo;
  StreamSubscription<supa.AuthState>? _authSub;

  AuthNotifier(this._authRepo, this._studentRepo)
      : super(const AuthState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    final user = _authRepo.currentUser;
    if (user != null) {
      await _loadUserProfile(user);
    } else {
      state = const AuthState();
    }

    // Listen for future auth changes (sign out only — sign in is handled
    // explicitly by signIn/signUpStudent to avoid race conditions with
    // the router redirect)
    _authSub = _authRepo.onAuthStateChange.listen((authState) {
      if (authState.event == supa.AuthChangeEvent.signedOut) {
        state = const AuthState();
      }
    });
  }

  Future<void> _loadUserProfile(supa.User user) async {
    state = state.copyWith(user: user, isLoading: true);

    final role = await _authRepo.getUserRole(user.id);
    Student? profile;
    String? schoolName;
    String? cohortName;

    if (role == 'student') {
      profile = await _studentRepo.getProfile(user.id);
      if (profile != null) {
        schoolName = await _studentRepo.getSchoolName(profile.schoolId);
        cohortName = await _studentRepo.getCohortName(profile.cohortId);
      }
    }

    state = AuthState(
      user: user,
      role: role,
      studentProfile: profile,
      schoolName: schoolName,
      cohortName: cohortName,
      isLoading: false,
    );
  }

  /// Sign in with email/password, then load role + profile.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _authRepo.signIn(
        email: email,
        password: password,
      );
      await _loadUserProfile(user);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// Sign up, create student profile, then load state.
  /// Does NOT trigger router redirect — the registration screen
  /// handles navigation to cohort confirmation manually.
  Future<void> signUpStudent({
    required String email,
    required String password,
    required String fullName,
    required int grade,
    required String schoolId,
    required String cohortId,
    required String schoolName,
    required String cohortName,
    String? guardianContact,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _authRepo.signUp(
        email: email,
        password: password,
      );

      final profile = await _studentRepo.createProfile(
        userId: user.id,
        fullName: fullName,
        email: email,
        grade: grade,
        schoolId: schoolId,
        cohortId: cohortId,
        guardianContact: guardianContact,
      );

      state = AuthState(
        user: user,
        role: 'student',
        studentProfile: profile,
        schoolName: schoolName,
        cohortName: cohortName,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepo.signOut();
    } catch (_) {
      // Clear state even if network call fails
    }
    state = const AuthState();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

/// The global auth state provider.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authRepositoryProvider),
    ref.read(studentRepositoryProvider),
  );
});
