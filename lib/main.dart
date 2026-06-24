import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/models/focus_session.dart';
import 'data/repositories/session_repository.dart';

void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await Hive.initFlutter();
      Hive.registerAdapter(FocusSessionAdapter());
      await Hive.openBox<FocusSession>(sessionsBoxName);
    } catch (e, st) {
      runApp(StartupErrorApp(error: e.toString(), stack: st.toString()));
      return;
    }
    runApp(const ProviderScope(child: KoreanFocusApp()));
  }, (error, stack) {
    runApp(StartupErrorApp(error: error.toString(), stack: stack.toString()));
  });
}

/// 시작 단계에서 예외가 나면 흰 화면 대신 원인을 화면에 표시(디버깅용).
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.error, required this.stack});

  final String error;
  final String stack;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFFFF3F0),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('시작 중 오류가 발생했어요',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB3261E))),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      '$error\n\n$stack',
                      style: const TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: Color(0xFF442C2A)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
