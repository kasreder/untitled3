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

/// DI 컨테이너와 라우터를 초기화하는 애플리케이션 루트 위젯.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

/// 루트 위젯이 보유한 상태. 라우터를 초기화하고 Providers를 묶어준다.
class _AppRootState extends State<AppRoot> {
  late final GoRouter _router = AppRouter().router;

  /// 전역 의존성 주입과 `MaterialApp.router`를 설정한다.
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
