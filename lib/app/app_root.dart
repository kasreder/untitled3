import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'navigation/navigation_controller.dart';
import 'router/app_router.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late final GoRouter _router = AppRouter().router;

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
