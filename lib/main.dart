import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const AppRoot());
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late final GoRouter _router = _createRouter();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavigationController(),
      child: MaterialApp.router(
        title: '청록 웹 서비스',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E9D9D)),
          useMaterial3: true,
        ),
        routerConfig: _router,
      ),
    );
  }
}

GoRouter _createRouter() {
  return GoRouter(
    initialLocation: appDestinations.first.location,
    routes: [
      ShellRoute(
        builder: (context, state, child) => _AdaptiveNavigationShell(
          state: state,
          child: child,
        ),
        routes: [
          for (final destination in appDestinations)
            GoRoute(
              path: destination.path,
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

class _AdaptiveNavigationShell extends StatelessWidget {
  const _AdaptiveNavigationShell({
    required this.state,
    required this.child,
  });

  final GoRouterState state;
  final Widget child;

  static const double _navigationBreakpoint = 650;

  @override
  Widget build(BuildContext context) {
    final navigation = context.watch<NavigationController>();
    navigation.syncWithLocation(state.matchedLocation);

    return LayoutBuilder(
      builder: (context, constraints) {
        final useBottomNavigation = constraints.maxWidth <= _navigationBreakpoint;
        return Scaffold(
          appBar: AppBar(
            title: Text(_titleForRoute(state.matchedLocation)),
          ),
          drawer: _AppDrawer(
            currentIndex: navigation.selectedIndex,
            onDestinationSelected: (index) {
              _handleDestinationSelection(context, navigation, index);
            },
          ),
          body: useBottomNavigation
              ? child
              : Row(
                  children: [
                    NavigationRail(
                      selectedIndex: navigation.selectedIndex,
                      onDestinationSelected: (index) {
                        _handleDestinationSelection(context, navigation, index);
                      },
                      labelType: NavigationRailLabelType.all,
                      destinations: [
                        for (final destination in appDestinations)
                          NavigationRailDestination(
                            icon: Icon(destination.icon),
                            label: Text(destination.label),
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
                    _handleDestinationSelection(context, navigation, index);
                  },
                  destinations: [
                    for (final destination in appDestinations)
                      NavigationDestination(
                        icon: Icon(destination.icon),
                        label: destination.label,
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

void _handleDestinationSelection(
  BuildContext context,
  NavigationController controller,
  int index,
) {
  if (index < 0 || index >= appDestinations.length) {
    return;
  }
  final destination = appDestinations[index];
  controller.selectIndex(index);
  context.go(destination.location);
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
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
                    leading: Icon(destination.icon),
                    title: Text(destination.label),
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

class NavigationController extends ChangeNotifier {
  int _selectedIndex = 0;
  String _location = appDestinations.first.location;

  int get selectedIndex => _selectedIndex;

  void selectIndex(int index) {
    if (index == _selectedIndex) {
      return;
    }
    _selectedIndex = index;
    _location = appDestinations[index].location;
    notifyListeners();
  }

  void syncWithLocation(String location) {
    if (_location == location) {
      return;
    }
    _location = location;
    final matchIndex = appDestinations.indexWhere(
      (destination) => destination.location == location,
    );
    if (matchIndex != -1 && matchIndex != _selectedIndex) {
      _selectedIndex = matchIndex;
      notifyListeners();
    }
  }
}

class AppDestination {
  const AppDestination({
    required this.path,
    required this.name,
    required this.label,
    required this.icon,
    required this.builder,
  });

  final String path;
  final String name;
  final String label;
  final IconData icon;
  final WidgetBuilder builder;

  String get location => path.isEmpty ? '/' : '/$path';
}

final List<AppDestination> appDestinations = [
  AppDestination(
    path: '',
    name: 'home',
    label: '홈',
    icon: Icons.home_filled,
    builder: (_) => const _SimplePage(message: '홈 페이지가 준비 중입니다.'),
  ),
  AppDestination(
    path: 'news',
    name: 'news',
    label: '뉴스',
    icon: Icons.article_outlined,
    builder: (_) => const _SimplePage(message: '최신 뉴스를 곧 전해드릴게요.'),
  ),
  AppDestination(
    path: 'free',
    name: 'free',
    label: '자유',
    icon: Icons.forum_outlined,
    builder: (_) => const _SimplePage(message: '자유 게시판이 준비 중입니다.'),
  ),
  AppDestination(
    path: 'experiment',
    name: 'experiment',
    label: '실험',
    icon: Icons.science_outlined,
    builder: (_) => const _SimplePage(message: '실험실 공간을 기대해 주세요.'),
  ),
  AppDestination(
    path: 'info',
    name: 'info',
    label: '정보',
    icon: Icons.info_outline,
    builder: (_) => const _SimplePage(message: '유용한 정보를 모으는 중입니다.'),
  ),
  AppDestination(
    path: 'login',
    name: 'login',
    label: '로그인',
    icon: Icons.login,
    builder: (_) => const _SimplePage(message: '로그인 페이지입니다.'),
  ),
];

class _SimplePage extends StatelessWidget {
  const _SimplePage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
