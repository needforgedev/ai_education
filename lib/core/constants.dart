/// Supabase credentials — passed via --dart-define at build time.
/// flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=xxx
class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
}

/// Database table names
class Tables {
  static const String schools = 'schools';
  static const String cohorts = 'cohorts';
  static const String students = 'students';
  static const String moderators = 'moderators';
  static const String courses = 'courses';
  static const String modules = 'modules';
  static const String quizQuestions = 'quiz_questions';
  static const String quizAttempts = 'quiz_attempts';
  static const String moduleProgress = 'module_progress';
  static const String finalSubmissions = 'final_submissions';
  static const String communityThreads = 'community_threads';
  static const String communityReplies = 'community_replies';
  static const String notifications = 'notifications';
  static const String courseProgress = 'course_progress'; // view
}

/// Storage bucket names
class Buckets {
  static const String submissions = 'submissions';
}

/// Supabase RPC function names
class RpcFunctions {
  static const String validateSchoolCode = 'validate_school_code';
}
