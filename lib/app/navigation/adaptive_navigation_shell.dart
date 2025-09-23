// 파일 경로: lib/app/navigation/adaptive_navigation_shell.dart
// 파일 설명: 화면 크기에 맞춰 탐색 인터페이스를 변환하는 반응형 스캐폴드.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:untitled3/features/auth/controllers/auth_controller.dart';

import 'app_destinations.dart';
import 'navigation_controller.dart';

class AdaptiveNavigationShell extends StatelessWidget {
  const AdaptiveNavigationShell({
    required this.state,
    required this.child,
    super.key,
  });

  final GoRouterState state;
  final Widget child;

  static const double _navigationBreakpoint = 650;

  @override
  Widget build(BuildContext context) {
    final navigation = context.watch<NavigationController>();
    final auth = context.watch<AuthController>();
    navigation.syncWithLocation(state.matchedLocation);

    return LayoutBuilder(
      builder: (context, constraints) {
        final useBottomNavigation = constraints.maxWidth <= _navigationBreakpoint;
        return Scaffold(
          appBar: AppBar(
            title: Text(_titleForRoute(state.matchedLocation)),
          ),
          drawer: AppDrawer(
            currentIndex: navigation.selectedIndex,
            authController: auth,
            onDestinationSelected: (index) {
              _handleDestinationSelection(context, navigation, auth, index);
            },
          ),
          body: useBottomNavigation
              ? child
              : Row(
                  children: [
                    NavigationRail(
                      selectedIndex: navigation.selectedIndex,
                      onDestinationSelected: (index) {
                        _handleDestinationSelection(context, navigation, auth, index);
                      },
                      labelType: NavigationRailLabelType.all,
                      destinations: [
                        for (final destination in appDestinations)
                          NavigationRailDestination(
                            icon: Icon(_iconForDestination(destination, auth)),
                            label: Text(_labelForDestination(destination, auth)),
                          ),
                      ],
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: child),
                  ],
                ),
          bottomNavigationBar: useBottomNavigation
              ? NavigationBar(
                  selectedIndex: navigation.selectedIndex,
                  onDestinationSelected: (index) {
                    _handleDestinationSelection(context, navigation, auth, index);
                  },
                  destinations: [
                    for (final destination in appDestinations)
                      NavigationDestination(
                        icon: Icon(_iconForDestination(destination, auth)),
                        label: _labelForDestination(destination, auth),
                      ),
                  ],
                )
              : null,
        );
      },
    );
  }

  String _titleForRoute(String location) {
    final match = appDestinations.firstWhere(
      (destination) => destination.location == location,
      orElse: () => appDestinations.first,
    );
    return match.label;
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    required this.currentIndex,
    required this.authController,
    required this.onDestinationSelected,
    super.key,
  });

  final int currentIndex;
  final AuthController authController;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  '청록 네트워크',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: appDestinations.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final destination = appDestinations[index];
                  final isSelected = currentIndex == index;
                  return ListTile(
                    leading: Icon(_iconForDestination(destination, authController)),
                    title: Text(_labelForDestination(destination, authController)),
                    selected: isSelected,
                    onTap: () {
                      Navigator.of(context).pop();
                      onDestinationSelected(index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _handleDestinationSelection(
  BuildContext context,
  NavigationController controller,
  AuthController authController,
  int index,
) {
  if (index < 0 || index >= appDestinations.length) {
    return;
  }
  final destination = appDestinations[index];
  if (destination.name == 'login' && authController.currentUser != null) {
    authController.logout();
  }
  controller.selectIndex(index);
  context.go(destination.location);
}

IconData _iconForDestination(AppDestination destination, AuthController authController) {
  if (destination.name == 'login' && authController.currentUser != null) {
    return Icons.logout;
  }
  return destination.icon;
}

String _labelForDestination(AppDestination destination, AuthController authController) {
  if (destination.name == 'login' && authController.currentUser != null) {
    return '로그아웃';
  }
  return destination.label;
}
