import 'package:flutter/material.dart';
import 'mock_data.dart';

/// In-memory app state that tracks all student/moderator progress.
/// Resets on app restart. No backend needed.
class AppState extends ChangeNotifier {
  // --- Current user ---
  String? studentName;
  int? grade;
  String? school;
  MockCohort? cohort;
  bool isModerator = false;

  // --- Module quiz scores: key = "courseId_moduleIndex" ---
  final Map<String, int> _bestQuizScores = {};

  // --- Module completion: key = "courseId_moduleIndex" ---
  final Set<String> _completedModules = {};

  // --- Submission state: key = courseId ---
  final Map<String, SubmissionState> _submissions = {};

  // --- Community posts ---
  final List<CommunityPost> communityPosts = [];

  // Singleton
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal() {
    _seedCommunityPosts();
  }

  void reset() {
    studentName = null;
    grade = null;
    school = null;
    cohort = null;
    isModerator = false;
    _bestQuizScores.clear();
    _completedModules.clear();
    _submissions.clear();
    communityPosts.clear();
    _seedCommunityPosts();
    notifyListeners();
  }

  // --- Registration ---

  void registerStudent({
    required String name,
    required int studentGrade,
    required String studentSchool,
  }) {
    studentName = name;
    grade = studentGrade;
    school = studentSchool;
    cohort = getCohortForGrade(studentGrade);
    isModerator = false;
    notifyListeners();
  }

  void loginAsModerator() {
    studentName = 'Moderator';
    isModerator = true;
    notifyListeners();
  }

  // --- Quiz scores ---

  String _quizKey(String courseId, int moduleIndex) => '${courseId}_$moduleIndex';

  int? getBestScore(String courseId, int moduleIndex) {
    return _bestQuizScores[_quizKey(courseId, moduleIndex)];
  }

  /// Returns true if this was a new best score.
  bool submitQuizScore(String courseId, int moduleIndex, int score) {
    final key = _quizKey(courseId, moduleIndex);
    final previous = _bestQuizScores[key];
    final isNewBest = previous == null || score > previous;

    if (isNewBest) {
      _bestQuizScores[key] = score;
    }

    // Mark module complete if passed (>=50% = 10/20)
    if (score >= 10) {
      _completedModules.add(key);
    }

    notifyListeners();
    return isNewBest;
  }

  // --- Module progress ---

  bool isModuleCompleted(String courseId, int moduleIndex) {
    return _completedModules.contains(_quizKey(courseId, moduleIndex));
  }

  bool isModuleUnlocked(String courseId, int moduleIndex) {
    if (moduleIndex == 0) return true;
    return isModuleCompleted(courseId, moduleIndex - 1);
  }

  int completedModuleCount(String courseId) {
    int count = 0;
    for (int i = 0; i < 10; i++) {
      if (isModuleCompleted(courseId, i)) count++;
    }
    return count;
  }

  int totalCompletedModules() {
    return _completedModules.length;
  }

  // --- Course progress ---

  double averageQuizScore(String courseId) {
    final scores = <int>[];
    for (int i = 0; i < 10; i++) {
      final s = getBestScore(courseId, i);
      if (s != null) scores.add(s);
    }
    if (scores.isEmpty) return 0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  bool allModulesCompleted(String courseId) {
    return completedModuleCount(courseId) == 10;
  }

  double? totalCourseScore(String courseId) {
    final sub = _submissions[courseId];
    if (sub == null || sub.scoreOutOf80 == null) return null;
    return averageQuizScore(courseId) + sub.scoreOutOf80!;
  }

  int coursesInProgress() {
    int count = 0;
    for (final course in mockCourses) {
      final completed = completedModuleCount(course.id);
      if (completed > 0 && completed < 10) count++;
    }
    return count;
  }

  int coursesCompleted() {
    int count = 0;
    for (final course in mockCourses) {
      if (allModulesCompleted(course.id)) count++;
    }
    return count;
  }

  // --- Submissions ---

  SubmissionState? getSubmission(String courseId) => _submissions[courseId];

  void submitProject(String courseId, String fileName, String fileType, String notes) {
    _submissions[courseId] = SubmissionState(
      courseId: courseId,
      fileName: fileName,
      fileType: fileType,
      notes: notes,
      submittedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void gradeSubmission(String courseId, int score, String feedback) {
    final sub = _submissions[courseId];
    if (sub != null) {
      sub.scoreOutOf80 = score;
      sub.moderatorFeedback = feedback;
      sub.gradedAt = DateTime.now();
      notifyListeners();
    }
  }

  List<SubmissionState> pendingSubmissions() {
    return _submissions.values
        .where((s) => s.scoreOutOf80 == null)
        .toList();
  }

  List<SubmissionState> allSubmissions() {
    return _submissions.values.toList();
  }

  // --- Community ---

  void _seedCommunityPosts() {
    communityPosts.addAll(mockCommunityPosts);
  }

  void addCommunityPost(String title, String body, String author, {bool isMod = false}) {
    communityPosts.insert(0, CommunityPost(
      id: 'post_${communityPosts.length}',
      author: author,
      title: title,
      body: body,
      createdAt: DateTime.now(),
      isModeratorPost: isMod,
    ));
    notifyListeners();
  }

  void addReply(String postId, String body, String author, {bool isMod = false}) {
    final post = communityPosts.firstWhere((p) => p.id == postId);
    post.replies.add(CommunityReply(
      author: author,
      body: body,
      createdAt: DateTime.now(),
      isModeratorReply: isMod,
    ));
    notifyListeners();
  }

  // --- Leaderboard (mock) ---

  List<LeaderboardEntry> getLeaderboard({String? courseId}) {
    final entries = mockLeaderboardEntries(school ?? 'Sunrise Public School');
    if (courseId != null) {
      return entries.where((e) => e.courseId == courseId || e.courseId == null).toList();
    }
    return entries;
  }
}

class SubmissionState {
  final String courseId;
  final String fileName;
  final String fileType;
  final String notes;
  final DateTime submittedAt;
  int? scoreOutOf80;
  String? moderatorFeedback;
  DateTime? gradedAt;

  SubmissionState({
    required this.courseId,
    required this.fileName,
    required this.fileType,
    required this.notes,
    required this.submittedAt,
    this.scoreOutOf80,
    this.moderatorFeedback,
    this.gradedAt,
  });

  String get studentName => AppState().studentName ?? 'Student';
  bool get isGraded => scoreOutOf80 != null;
}

class CommunityPost {
  final String id;
  final String author;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isModeratorPost;
  final List<CommunityReply> replies;

  CommunityPost({
    required this.id,
    required this.author,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isModeratorPost = false,
    List<CommunityReply>? replies,
  }) : replies = replies ?? [];
}

class CommunityReply {
  final String author;
  final String body;
  final DateTime createdAt;
  final bool isModeratorReply;

  CommunityReply({
    required this.author,
    required this.body,
    required this.createdAt,
    this.isModeratorReply = false,
  });
}
