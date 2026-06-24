import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/models/focus_session.dart';
import 'data/repositories/session_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(FocusSessionAdapter());
  await Hive.openBox<FocusSession>(sessionsBoxName);
  runApp(const ProviderScope(child: KoreanFocusApp()));
}
