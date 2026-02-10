import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/persona_selection_screen.dart';
import 'models/persona.dart';
import 'screens/dashboard_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/settings_screen.dart';

/// [Project] Buddy - AI 가계부 서비스
/// [File] AppRouter - go_router 기반 네비게이션
/// [Description]
/// 인증 상태에 따라 자동 리다이렉트 처리
/// PageView 방식에서 go_router로 전환하여 확장성 확보
///
/// * [Collaborators Note]
/// - 광진: 인증 상태 변경 시 redirect가 자동으로 화면 전환
/// - 준수: 새 화면 추가 시 이 파일에 라우트 등록

class AppRouter {
  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.isLoggedIn;
        final isOnLogin = state.matchedLocation == '/login';
        // 미로그인 상태 → 로그인 페이지로
        if (!isLoggedIn && !isOnLogin) return '/login';

        // 로그인 상태인데 로그인 페이지에 있으면 → 페르소나 설정 여부 확인
        if (isLoggedIn && isOnLogin) {
          final profile = authProvider.userProfile;
          // 신규 유저(페르소나 미선택) → 페르소나 선택으로
          if (profile == null || profile.personaType.isEmpty) {
            return '/persona';
          }
          return '/dashboard';
        }

        return null; // 리다이렉트 불필요
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/persona',
          builder: (context, state) => const PersonaSelectionScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/statistics',
          builder: (context, state) {
            final personaType = authProvider.userProfile?.personaType ?? 'F-type';
            final index = personaData.indexWhere((p) => p.type == personaType).clamp(0, personaData.length - 1);
            return StatisticsScreen(
              selectedPersonaIndex: index,
            );
          },
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    );
  }
}
