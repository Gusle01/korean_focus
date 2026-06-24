import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/confirm/journey_confirm_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/place/place_select_screen.dart';
import '../../features/transport/transport_select_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/transport',
      builder: (context, state) => const TransportSelectScreen(),
    ),
    GoRoute(
      path: '/place/:mode',
      builder: (context, state) {
        final mode = state.pathParameters['mode'] ?? 'origin';
        // mode별로 State(검색어)를 분리해 출발→도착 전환 시 초기화되도록.
        return PlaceSelectScreen(key: ValueKey('place_$mode'), mode: mode);
      },
    ),
    GoRoute(
      path: '/confirm',
      builder: (context, state) => const JourneyConfirmScreen(),
    ),
  ],
);
