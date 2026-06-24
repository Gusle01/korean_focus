import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class KoreanFocusApp extends StatelessWidget {
  const KoreanFocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '집중행',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}
