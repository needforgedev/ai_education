import '../../core/constants.dart';
import '../../core/supabase/supabase_client.dart';
import '../models/quiz_question.dart';

/// Quiz reads + writes: Supabase only (online required).
class QuizRepository {
  Future<List<QuizQuestion>> getQuestionsForModule(String moduleId) async {
    final result = await supabase
        .from(Tables.quizQuestions)
        .select()
        .eq('module_id', moduleId)
        .order('order_index');

    return (result as List)
        .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Records a quiz attempt AND updates module_progress (best score, passed, completed).
  /// Returns info the UI needs for the result screen.
  Future<QuizSubmitResult> submitAttempt({
    required String studentId,
    required String moduleId,
    required int scoreOutOf20,
    required List<int> answers,
  }) async {
    // 1. Insert the attempt row
    await supabase.from(Tables.quizAttempts).insert({
      'student_id': studentId,
      'module_id': moduleId,
      'score_out_of_20': scoreOutOf20,
      'answers': answers,
    });

    // 2. Fetch existing progress (if any)
    final existing = await supabase
        .from(Tables.moduleProgress)
        .select()
        .eq('student_id', studentId)
        .eq('module_id', moduleId)
        .maybeSingle();

    final now = DateTime.now().toUtc().toIso8601String();
    final int? previousBest = existing?['best_quiz_score'] as int?;
    final DateTime? lessonViewedAt = existing?['lesson_viewed_at'] != null
        ? DateTime.parse(existing!['lesson_viewed_at'] as String)
        : null;
    final DateTime? existingQuizPassedAt = existing?['quiz_passed_at'] != null
        ? DateTime.parse(existing!['quiz_passed_at'] as String)
        : null;
    final DateTime? existingCompletedAt = existing?['completed_at'] != null
        ? DateTime.parse(existing!['completed_at'] as String)
        : null;

    final bool passed = scoreOutOf20 >= 10;
    final bool isNewBest =
        previousBest == null || scoreOutOf20 > previousBest;
    final int newBest = isNewBest ? scoreOutOf20 : previousBest;

    final String? quizPassedAt = passed && existingQuizPassedAt == null
        ? now
        : existingQuizPassedAt?.toIso8601String();

    // Taking the quiz implies the lesson was viewed — guarantee lesson_viewed_at
    // is set so completed_at can be derived deterministically (fixes a race with
    // the fire-and-forget markLessonViewed write from module_lesson_screen).
    final String resolvedLessonViewedAt =
        lessonViewedAt?.toIso8601String() ?? now;

    final String? completedAt = existingCompletedAt?.toIso8601String() ??
        (passed ? now : null);

    await supabase.from(Tables.moduleProgress).upsert(
      {
        'student_id': studentId,
        'module_id': moduleId,
        'lesson_viewed_at': resolvedLessonViewedAt,
        'best_quiz_score': newBest,
        'quiz_passed_at': quizPassedAt,
        'completed_at': completedAt,
      },
      onConflict: 'student_id,module_id',
    );

    return QuizSubmitResult(
      score: scoreOutOf20,
      passed: passed,
      isNewBest: isNewBest,
      previousBest: previousBest,
    );
  }
}

class QuizSubmitResult {
  final int score;
  final bool passed;
  final bool isNewBest;
  final int? previousBest;

  const QuizSubmitResult({
    required this.score,
    required this.passed,
    required this.isNewBest,
    required this.previousBest,
  });
}
