import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/active_journey_repository.dart';
import '../../features/achievements/achievements_screen.dart';
import '../../features/collection/display_case_screen.dart';
import '../../features/complete/complete_screen.dart';
import '../../features/confirm/journey_confirm_screen.dart';
import '../../features/focus/focus_session_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/place/place_select_screen.dart';
import '../../features/stats/stats_screen.dart';
import '../../features/transport/transport_select_screen.dart';

/// 화면 전환 — 살짝 떠오르며 페이드 인(여정의 결).
CustomTransitionPage<void> _page(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (context, animation, secondary, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.025),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

final appRouter = GoRouter(
  initialLocation: '/',
  // 진행 중 여정이 있는데 홈으로 왔다면(앱 재실행 등) 집중 화면으로 복원.
  redirect: (context, state) {
    if (state.matchedLocation == '/' && hasActiveJourney()) return '/focus';
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _page(state, const HomeScreen()),
    ),
    GoRoute(
      path: '/transport',
      pageBuilder: (context, state) =>
          _page(state, const TransportSelectScreen()),
    ),
    GoRoute(
      path: '/place/:mode',
      pageBuilder: (context, state) {
        final mode = state.pathParameters['mode'] ?? 'origin';
        // mode별로 State(검색어)를 분리해 출발→도착 전환 시 초기화되도록.
        return _page(
          state,
          PlaceSelectScreen(key: ValueKey('place_$mode'), mode: mode),
        );
      },
    ),
    GoRoute(
      path: '/confirm',
      pageBuilder: (context, state) =>
          _page(state, const JourneyConfirmScreen()),
    ),
    GoRoute(
      path: '/focus',
      pageBuilder: (context, state) => _page(state, const FocusSessionScreen()),
    ),
    GoRoute(
      path: '/complete',
      pageBuilder: (context, state) => _page(state, const CompleteScreen()),
    ),
    GoRoute(
      path: '/collection',
      pageBuilder: (context, state) => _page(state, const DisplayCaseScreen()),
    ),
    GoRoute(
      path: '/stats',
      pageBuilder: (context, state) => _page(state, const StatsScreen()),
    ),
    GoRoute(
      path: '/achievements',
      pageBuilder: (context, state) =>
          _page(state, const AchievementsScreen()),
    ),
  ],
);
