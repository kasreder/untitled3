// 파일 경로: lib/app/router/app_router.dart
// 파일 설명: 애플리케이션 셸에서 사용할 라우터 구성을 정의.

import 'package:go_router/go_router.dart';
import '../navigation/adaptive_navigation_shell.dart';
import '../navigation/app_destinations.dart';

/// 전역 라우팅 규칙과 셸 구성을 캡슐화한 클래스.
class AppRouter {
  AppRouter();

  late final GoRouter router = GoRouter(
    initialLocation: appDestinations.first.location,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AdaptiveNavigationShell(
          state: state,
          child: child,
        ),
        routes: [
          for (final destination in appDestinations)
            GoRoute(
              path: destination.location,
              name: destination.name,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: destination.builder(context),
              ),
            ),
        ],
      ),
    ],
  );
}
