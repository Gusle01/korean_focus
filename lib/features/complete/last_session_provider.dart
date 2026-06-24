import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/focus_session.dart';
import '../../data/models/owned_collectible.dart';

/// 방금 완료한 세션 (완료 화면 표시용).
final lastCompletedSessionProvider = StateProvider<FocusSession?>((ref) => null);

/// 방금 도착해 획득한 컬렉션 (완료 화면 표시용). 획득 못 했으면 null.
final lastAwardedCollectibleProvider =
    StateProvider<OwnedCollectible?>((ref) => null);
