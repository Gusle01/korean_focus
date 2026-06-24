import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/focus_session.dart';

/// 방금 완료한 세션 (완료 화면 표시용).
final lastCompletedSessionProvider = StateProvider<FocusSession?>((ref) => null);
