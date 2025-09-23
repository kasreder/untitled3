// 파일 경로: lib/app/navigation/app_destinations.dart
// 파일 설명: 어댑티브 셸 라우터에서 사용할 목적지를 정의.

import 'package:flutter/material.dart';

import 'package:untitled3/features/auth/view/login_page.dart';
import 'package:untitled3/features/simple_page/simple_page.dart';

class AppDestination {
  const AppDestination({
    required this.location,
    required this.name,
    required this.label,
    required this.icon,
    required this.builder,
  });

  final String location;
  final String name;
  final String label;
  final IconData icon;
  final WidgetBuilder builder;
}

final List<AppDestination> appDestinations = [
  AppDestination(
    location: '/',
    name: 'home',
    label: '홈',
    icon: Icons.home_filled,
    builder: (_) => const SimplePage(message: '홈 페이지가 준비 중입니다.'),
  ),
  AppDestination(
    location: '/news',
    name: 'news',
    label: '뉴스',
    icon: Icons.article_outlined,
    builder: (_) => const SimplePage(message: '최신 뉴스를 곧 전해드릴게요.'),
  ),
  AppDestination(
    location: '/free',
    name: 'free',
    label: '자유',
    icon: Icons.forum_outlined,
    builder: (_) => const SimplePage(message: '자유 게시판이 준비 중입니다.'),
  ),
  AppDestination(
    location: '/experiment',
    name: 'experiment',
    label: '실험',
    icon: Icons.science_outlined,
    builder: (_) => const SimplePage(message: '실험실 공간을 기대해 주세요.'),
  ),
  AppDestination(
    location: '/info',
    name: 'info',
    label: '정보',
    icon: Icons.info_outline,
    builder: (_) => const SimplePage(message: '유용한 정보를 모으는 중입니다.'),
  ),
  AppDestination(
    location: '/login',
    name: 'login',
    label: '로그인',
    icon: Icons.login,
    builder: (_) => const LoginPage(),
  ),
];
