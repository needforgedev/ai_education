import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/welcome_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/registration_screen.dart';
import '../features/auth/screens/cohort_confirmation_screen.dart';
import '../data/models/cohort.dart';
import '../data/models/course.dart';
import '../data/models/module.dart';

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

/// A ChangeNotifier that bridges Riverpod's AuthState to GoRouter's
/// refreshListenable. This lets GoRouter re-evaluate its redirect
/// without recreating the entire router (which destroys nav stack).
class _AuthNotifierBridge extends ChangeNotifier {
  _AuthNotifierBridge(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, _) {
      notifyListeners();
    });
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthNotifierBridge(ref);

  return GoRouter(
    initialLocation: AppRoutes.welcome,
    debugLogDiagnostics: false,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      // Read the CURRENT auth state inside redirect (not watched)
      final container = ProviderScope.containerOf(context);
      final authState = container.read(authProvider);

      final isLoading = authState.isLoading;
      final isAuthenticated = authState.isAuthenticated;
      final location = state.matchedLocation;

      // While loading auth state, don't redirect
      if (isLoading) return null;

      final isPublicRoute = location == AppRoutes.welcome ||
          location == AppRoutes.login ||
          location == AppRoutes.moderatorLogin ||
          location == AppRoutes.register ||
          location == AppRoutes.cohortConfirmation;

      // Not authenticated — only allow public routes
      if (!isAuthenticated) {
        return isPublicRoute ? null : AppRoutes.welcome;
      }

      // Authenticated and on the welcome page only — redirect to dashboard.
      // Don't redirect from login/register/cohort — those handle their own nav.
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
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const StudentHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.courseDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return CourseDetailScreen(course: extra['course'] as Course);
        },
      ),
      GoRoute(
        path: AppRoutes.moduleLesson,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ModuleLessonScreen(
            module: extra['module'] as CourseModule,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.quiz,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return QuizScreen(module: extra['module'] as CourseModule);
        },
      ),
      GoRoute(
        path: AppRoutes.quizResult,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return QuizResultScreen(
            module: extra['module'] as CourseModule,
            score: extra['score'] as int,
            totalQuestions: extra['totalQuestions'] as int,
            correctAnswers: extra['correctAnswers'] as int,
            isNewBest: extra['isNewBest'] as bool,
            passed: extra['passed'] as bool,
            previousBest: extra['previousBest'] as int?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.finalSubmission,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return FinalSubmissionScreen(course: extra['course'] as Course);
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
