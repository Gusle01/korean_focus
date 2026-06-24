import 'package:go_router/go_router.dart';

import '../../features/common/placeholder_screen.dart';
import '../../features/home/home_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/transport',
      builder: (context, state) => const PlaceholderScreen(
        title: '교통수단 선택',
        message: '버스 · 기차 · 비행기 선택\n\n(Phase 2에서 구현됩니다)',
      ),
    ),
  ],
);
