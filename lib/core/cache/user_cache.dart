import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/student.dart';

/// Caches the last authenticated user's context — role, profile, school/cohort names —
/// so the app can open straight to the dashboard on cold start even without internet.
///
/// Supabase itself already persists the auth session (access + refresh tokens) to disk.
/// This cache fills in the *application-level* user data that Supabase doesn't know about.
class UserCache {
  static const String _boxName = 'user_cache';
  static const String _authContextKey = 'auth_context';

  static Future<void> init() async {
    await Hive.openBox<dynamic>(_boxName);
  }

  Box<dynamic> get _box => Hive.box<dynamic>(_boxName);

  Future<void> save({
    required String userId,
    required String role,
    Student? studentProfile,
    String? schoolName,
    String? cohortName,
  }) async {
    final payload = <String, dynamic>{
      'user_id': userId,
      'role': role,
      'student_profile': studentProfile?.toJson(),
      'school_name': schoolName,
      'cohort_name': cohortName,
    };
    await _box.put(_authContextKey, payload);
  }

  CachedAuthContext? load(String userId) {
    final raw = _box.get(_authContextKey);
    if (raw == null) return null;
    final map = Map<String, dynamic>.from(raw as Map);
    if (map['user_id'] != userId) return null;

    final profileRaw = map['student_profile'];
    final profile = profileRaw == null
        ? null
        : Student.fromJson(Map<String, dynamic>.from(profileRaw as Map));

    return CachedAuthContext(
      userId: map['user_id'] as String,
      role: map['role'] as String,
      studentProfile: profile,
      schoolName: map['school_name'] as String?,
      cohortName: map['cohort_name'] as String?,
    );
  }

  Future<void> clear() async {
    await _box.delete(_authContextKey);
  }
}

class CachedAuthContext {
  final String userId;
  final String role;
  final Student? studentProfile;
  final String? schoolName;
  final String? cohortName;

  const CachedAuthContext({
    required this.userId,
    required this.role,
    this.studentProfile,
    this.schoolName,
    this.cohortName,
  });
}
