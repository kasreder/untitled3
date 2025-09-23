// 파일 경로: lib/app/app_root.dart
// 파일 설명: 전역 의존성을 구성하고 루트 머티리얼 애플리케이션 셸을 구축.


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/features/auth/controllers/auth_controller.dart';
import 'package:untitled3/features/auth/data/dummy_user_repository.dart';
import 'package:untitled3/features/auth/services/crypto_service.dart';
import 'package:untitled3/features/auth/services/metamask_connector.dart';
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
    return MultiProvider(
      providers: [
        Provider<CryptoService>(
          create: (_) => CryptoService.withSecureDefaults(),
        ),
        Provider<DummyUserRepository>(
          create: (context) => DummyUserRepository(
            cryptoService: context.read<CryptoService>(),
          ),
        ),
        Provider<MetamaskConnector>(
          create: (_) => MetamaskConnector.secure(),
        ),
        ChangeNotifierProvider<NavigationController>(
          create: (_) => NavigationController(),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (context) => AuthController(
            userRepository: context.read<DummyUserRepository>(),
            metamaskConnector: context.read<MetamaskConnector>(),
          ),
        ),
      ],
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
