import '../../core/supabase/supabase_client.dart';
import '../../core/constants.dart';
import '../models/student.dart';
import '../models/cohort.dart';
import '../models/school.dart';

class StudentRepository {
  /// Validate a school registration code.
  /// Returns {school_id, school_name} if valid, null if invalid.
  Future<({String schoolId, String schoolName})?> validateSchoolCode(
      String code) async {
    final result = await supabase
        .rpc(RpcFunctions.validateSchoolCode, params: {'code': code.trim().toUpperCase()});

    final rows = result as List<dynamic>;
    if (rows.isEmpty) return null;

    final row = rows.first as Map<String, dynamic>;
    return (
      schoolId: row['school_id'] as String,
      schoolName: row['school_name'] as String,
    );
  }

  /// Create the student profile row after auth sign-up.
  Future<Student> createProfile({
    required String userId,
    required String fullName,
    required String email,
    required int grade,
    required String schoolId,
    required String cohortId,
    String? guardianContact,
  }) async {
    final data = {
      'id': userId,
      'full_name': fullName,
      'email': email,
      'grade': grade,
      'school_id': schoolId,
      'cohort_id': cohortId,
      'guardian_contact': guardianContact,
    };

    final result = await supabase
        .from(Tables.students)
        .insert(data)
        .select()
        .single();

    return Student.fromJson(result);
  }

  /// Update the student's display name. Returns the refreshed profile.
  Future<Student> updateFullName({
    required String userId,
    required String fullName,
  }) async {
    final result = await supabase
        .from(Tables.students)
        .update({'full_name': fullName})
        .eq('id', userId)
        .select()
        .single();
    return Student.fromJson(result);
  }

  /// Fetch the current student's profile.
  Future<Student?> getProfile(String userId) async {
    final result = await supabase
        .from(Tables.students)
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (result == null) return null;
    return Student.fromJson(result);
  }

  /// Fetch all cohorts.
  Future<List<Cohort>> getCohorts() async {
    final result = await supabase
        .from(Tables.cohorts)
        .select()
        .eq('is_active', true)
        .order('min_grade', ascending: true);

    return result.map((e) => Cohort.fromJson(e)).toList();
  }

  /// Find the cohort for a given grade.
  Future<Cohort?> getCohortForGrade(int grade) async {
    final result = await supabase
        .from(Tables.cohorts)
        .select()
        .lte('min_grade', grade)
        .gte('max_grade', grade)
        .eq('is_active', true)
        .maybeSingle();

    if (result == null) return null;
    return Cohort.fromJson(result);
  }

  /// Fetch all active schools.
  Future<List<School>> getSchools() async {
    final result = await supabase
        .from(Tables.schools)
        .select()
        .eq('is_active', true)
        .order('name', ascending: true);

    return result.map((e) => School.fromJson(e)).toList();
  }

  /// Get the name of a school by ID.
  Future<String?> getSchoolName(String schoolId) async {
    final result = await supabase
        .from(Tables.schools)
        .select('name')
        .eq('id', schoolId)
        .maybeSingle();
    return result?['name'] as String?;
  }

  /// Get the name of a cohort by ID.
  Future<String?> getCohortName(String cohortId) async {
    final result = await supabase
        .from(Tables.cohorts)
        .select('name')
        .eq('id', cohortId)
        .maybeSingle();
    return result?['name'] as String?;
  }
}
