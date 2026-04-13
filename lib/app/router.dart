import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/welcome_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/registration_screen.dart';
import '../features/auth/screens/cohort_confirmation_screen.dart';
import '../data/models/cohort.dart';

// Old screens still in lib/screens/ — will migrate to features/ in later steps
import '../screens/student_home_screen.dart';
import '../screens/course_detail_screen.dart';
import '../screens/module_lesson_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/quiz_result_screen.dart';
import '../screens/final_submission_screen.dart';
import '../screens/moderator_dashboard_screen.dart';
import '../screens/submission_review_screen.dart';
import '../screens/settings_screen.dart';

/// Route path constants
class AppRoutes {
  // Auth
  static const welcome = '/welcome';
  static const login = '/login';
  static const moderatorLogin = '/moderator-login';
  static const register = '/register';
  static const cohortConfirmation = '/cohort-confirmation';

  // Student
  static const home = '/';
  static const courseDetail = '/course/:courseId';
  static const moduleLesson = '/course/:courseId/module/:moduleIndex';
  static const quiz = '/course/:courseId/module/:moduleIndex/quiz';
  static const quizResult = '/course/:courseId/module/:moduleIndex/quiz-result';
  static const finalSubmission = '/course/:courseId/submission';
  static const settings = '/settings';

  // Moderator
  static const moderatorDashboard = '/moderator';
  static const submissionReview = '/moderator/review';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.welcome,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final isAuthenticated = authState.isAuthenticated;
      final location = state.matchedLocation;

      // While loading auth state, don't redirect
      if (isLoading) return null;

      // Not authenticated — only allow auth routes
      if (!isAuthenticated) {
        final isPublicRoute = location == AppRoutes.welcome ||
            location == AppRoutes.login ||
            location == AppRoutes.moderatorLogin ||
            location == AppRoutes.register;
        return isPublicRoute ? null : AppRoutes.welcome;
      }

      // Authenticated — redirect ONLY from welcome page to dashboard.
      // Don't redirect from login/register/cohort-confirmation —
      // those screens handle their own post-auth navigation.
      if (isAuthenticated && location == AppRoutes.welcome) {
        if (authState.isModerator) return AppRoutes.moderatorDashboard;
        if (authState.isStudent) return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // ---- Auth routes ----
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.moderatorLogin,
        builder: (context, state) => const LoginScreen(isModerator: true),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: AppRoutes.cohortConfirmation,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return CohortConfirmationScreen(
            studentName: extra['studentName'] as String,
            grade: extra['grade'] as int,
            school: extra['school'] as String,
            cohort: extra['cohort'] as Cohort,
          );
        },
      ),

      // ---- Student routes ----
      // These still use old screens with mock types. The `extra` map passes
      // the mock objects directly. These will be updated when each feature
      // is migrated in Steps 6-10.
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const StudentHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.courseDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return CourseDetailScreen(course: extra['course']);
        },
      ),
      GoRoute(
        path: AppRoutes.moduleLesson,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ModuleLessonScreen(
            module: extra['module'],
            moduleIndex: int.parse(state.pathParameters['moduleIndex']!),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.quiz,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return QuizScreen(
            module: extra['module'],
            moduleIndex: int.parse(state.pathParameters['moduleIndex']!),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.quizResult,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return QuizResultScreen(
            module: extra['module'],
            moduleIndex: extra['moduleIndex'] as int,
            score: extra['score'] as int,
            totalQuestions: extra['totalQuestions'] as int,
            correctAnswers: extra['correctAnswers'] as int,
            isNewBest: extra['isNewBest'] as bool,
            passed: extra['passed'] as bool,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.finalSubmission,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return FinalSubmissionScreen(course: extra['course']);
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),

      // ---- Moderator routes ----
      GoRoute(
        path: AppRoutes.moderatorDashboard,
        builder: (context, state) => const ModeratorDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.submissionReview,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return SubmissionReviewScreen(
            submission: extra['submission'],
            course: extra['course'],
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
});
