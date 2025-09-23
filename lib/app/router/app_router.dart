// File: lib/app/router/app_router.dart
// Description: Declares the GoRouter configuration for the application shell.

import 'package:go_router/go_router.dart';

import '../navigation/adaptive_navigation_shell.dart';
import '../navigation/app_destinations.dart';

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
