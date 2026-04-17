import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/quiz_question.dart';
import '../../../data/repositories/quiz_repository.dart';

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository();
});

/// Fetches quiz questions for a module. Online-only.
final quizQuestionsProvider =
    FutureProvider.family<List<QuizQuestion>, String>((ref, moduleId) async {
  final repo = ref.read(quizRepositoryProvider);
  return repo.getQuestionsForModule(moduleId);
});
